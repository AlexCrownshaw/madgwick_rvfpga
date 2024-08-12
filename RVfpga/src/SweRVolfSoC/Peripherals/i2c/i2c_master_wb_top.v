/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE revB.2 compliant I2C Master controller Top-level  ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/projects/i2c/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
//
// Change History:
//               Revision 1.11  2005/02/27 09:26:24  rherveille
//               Fixed register overwrite issue.
//               Removed full_case pragma, replaced it by a default statement.
//
//               Revision 1.10  2003/09/01 10:34:38  rherveille
//               Fix a blocking vs. non-blocking error in the wb_dat output mux.
//
//               Revision 1.9  2003/01/09 16:44:45  rherveille
//               Fixed a bug in the Command Register declaration.
//
//               Revision 1.8  2002/12/26 16:05:12  rherveille
//               Small code simplifications
//
//               Revision 1.7  2002/12/26 15:02:32  rherveille
//               Core is now a Multimaster I2C controller
//
//               Revision 1.6  2002/11/30 22:24:40  rherveille
//               Cleaned up code
//
//               Revision 1.5  2001/11/10 10:52:55  rherveille
//               Changed PRER reset value from 0x0000 to 0xffff, conform specs.
//


// synopsys translate_off
//`include "..\..\testbench\verilog\timescale.v"
//`include "timescale.v"
// synopsys translate_on


module i2c_master_wb_top(
	wb_clk_i, wb_rst_i, arst_i, wb_adr_i, wb_dat_i, wb_dat_o,
	wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_inta_o,
	scl, sda);
	////scl_pad_i, scl_pad_o, scl_padoen_o, sda_pad_i, sda_pad_o, sda_padoen_o );

	// parameters
	parameter ARST_LVL = 1'b0; // asynchronous reset level

	//
	// inputs & outputs
	//

	// wishbone signals
	input        wb_clk_i;     // master clock input
	input        wb_rst_i;     // synchronous active high reset
	input        arst_i;       // asynchronous reset
	input  [5:0] wb_adr_i;     // lower address bits
	input  [7:0] wb_dat_i;     // databus input
	output [7:0] wb_dat_o;     // databus output
	input        wb_we_i;      // write enable input
	input        wb_stb_i;     // stobe/core select signal
	input        wb_cyc_i;     // valid bus cycle input
	output       wb_ack_o;     // bus cycle acknowledge output
	output       wb_inta_o;    // interrupt request signal output

	reg [7:0] wb_dat_o;
	reg wb_ack_o;
	reg wb_inta_o;

	inout scl, sda; 

	//
	// variable declarations
	//


    // registers declaration             
	wire  [15:0] prer; // clock prescale register 
	wire  [ 7:0] ctr;  // control register        	
	wire  [ 7:0] txr;  // transmit register       	
	wire [ 7:0] rxr;  // receive register         	
	wire  [ 7:0] cr;   // command register        	
	wire [ 7:0] sr;   // status register          	
	
	// done signal: command completed, clear command register
	wire done;

	// core enable signal
	wire core_en;
	wire ien;

	// status register signals
	wire irxack;
/*	reg  rxack;       // received aknowledge from slave
	reg  tip;         // transfer in progress 
	reg  irq_flag;    // interrupt pending flag */
	wire i2c_busy;    // bus busy (start signal detected)
	wire i2c_al;      // i2c bus arbitration lost
/*	reg  al;          // status register arbitration lost bit */

	// status signals between byte controller and bit controller
	wire [3:0] core_cmd; // output from byte controller to input of bit controller
	wire core_txd;       // output from byte controller to input of bit controller
	wire core_ack, core_rxd; // output from bit controller to input of byte controller

	// assign scl and sda to individual wires
        wire scl_pad_i = scl;
	wire scl_pad_o;       
	wire scl_padoen_o; 

        wire sda_pad_i = sda;     
	wire sda_pad_o;       
	wire sda_padoen_o; 

	//
	// module body
	//

	// generate internal reset
	wire rst_i = (arst_i ^ ARST_LVL);
	
	// generate wishbone signals
	wire wb_wacc = wb_cyc_i & wb_stb_i & wb_we_i;
	
        // decode command register
	wire sta  = cr[7];
	wire sto  = cr[6];
	wire rd   = cr[5];
	wire wr   = cr[4];
	wire ack  = cr[3];
	wire iack = cr[0];

	// decode control register
	assign core_en = ctr[7];
	assign ien = ctr[6];


        // Wishbone outputs - wb_ack_o, wb_dat_o, and wb_inta_o//
	// generate acknowledge output signal
	always @(posedge wb_clk_i)
	  wb_ack_o <= #1 wb_cyc_i & wb_stb_i & ~wb_ack_o; // because timing is always honored

	// assign DAT_O
	always @(posedge wb_clk_i)
	begin
	  case (wb_adr_i) // synopsis parallel_case
	    5'h00: wb_dat_o <= #1 prer[ 7:0];
	    5'h04: wb_dat_o <= #1 prer[15:8];
	    5'h08: wb_dat_o <= #1 ctr;
	    5'h0c: wb_dat_o <= #1 rxr; // write is transmit register (txr)
	    5'h10: wb_dat_o <= #1 sr;  // write is command register (cr)
	    5'h14: wb_dat_o <= #1 txr;
	    5'h18: wb_dat_o <= #1 cr;
	    5'h1c: wb_dat_o <= #1 0;   // reserved
	  endcase
	end
	
        // generate interrupt request signals
	always @(posedge wb_clk_i or negedge rst_i)
	  if (!rst_i)
	    wb_inta_o <= #1 1'b0;
	  else if (wb_rst_i)
	    wb_inta_o <= #1 1'b0;
	  else
	    //wb_inta_o <= #1 irq_flag && ien; // interrupt signal is only generated when IEN (interrupt enable bit is set)
        wb_inta_o <= #1 sr[0] && ien; // interrupt signal is only generated when IEN (interrupt enable bit is set)

	

	// hookup byte controller block
	i2c_master_byte_ctrl byte_controller (
		.clk      ( wb_clk_i     ),
		.rst      ( wb_rst_i     ),
		.nReset   ( rst_i        ),
		//.ena      ( core_en      ),
		.clk_cnt  ( prer         ),
		.start    ( sta          ),
		.stop     ( sto          ),
		.read     ( rd           ),
		.write    ( wr           ),
		.ack_in   ( ack          ),
		.din      ( txr          ),
		.cmd_ack  ( done         ),
		.ack_out  ( irxack       ),
		.dout     ( rxr          ),
		//.i2c_busy ( i2c_busy     ),
		.i2c_al   ( i2c_al       ),
		//.scl_i    ( scl_pad_i    ),
		//.scl_o    ( scl_pad_o    ),
		//.scl_oen  ( scl_padoen_o ),
		//.sda_i    ( sda_pad_i    ),
		//.sda_o    ( sda_pad_o    ),
		//.sda_oen  ( sda_padoen_o ),
		.core_cmd ( core_cmd     ),
		.core_ack ( core_ack      ),
		.core_txd ( core_txd     ),
		.core_rxd ( core_rxd     )
	);
	
	i2c_master_bit_ctrl bit_controller (
		.clk     ( wb_clk_i ),
		.rst     ( wb_rst_i ),
		.nReset  ( rst_i    ),
		.ena     ( core_en  ),
		.clk_cnt ( prer     ),
		.cmd     ( core_cmd ),
		.cmd_ack ( core_ack ),
		.busy    ( i2c_busy ),
		.al      ( i2c_al   ),  // output to other modules
		.din     ( core_txd ),
		.dout    ( core_rxd ),
		.scl_i   ( scl_pad_i),
		.scl_o   ( scl_pad_o),
		.scl_oen ( scl_padoen_o ),
		.sda_i   ( sda_pad_i),
		.sda_o   ( sda_pad_o),
		.sda_oen ( sda_padoen_o  )
	);
	      
	i2c_master_registers registers(
		  .wb_clk_i(wb_clk_i), 
		  .rst_i(rst_i), 
		  .wb_rst_i(wb_rst_i),
		  .wb_dat_i(wb_dat_i),
                  .wb_wacc(wb_wacc), 
                  .wb_adr_i(wb_adr_i),
                  .i2c_al(i2c_al), 
                  .i2c_busy(i2c_busy),
                  .done(done),
                  //.sta(sta),
                  .irxack(irxack),
                  //.rd(rd), 
                  //.wr(wr),
                  //.iack(iack),
		  .prer(prer),                  
		  .ctr(ctr), 
                  .txr(txr), 
                  .cr(cr),  
                  .sr(sr)
                  );
                  
          // generate scl and sda pins
	  assign scl = (scl_padoen_o ? 1'bz : scl_pad_o);
	  assign sda = (sda_padoen_o ? 1'bz : sda_pad_o);
	  
	  

endmodule
