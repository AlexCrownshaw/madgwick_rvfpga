//==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   Copyright (c) 2013 by Lattice Semiconductor Corporation ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
  
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Lattice provides no warranty
//   regarding the use or functionality of this code.
//
//   --------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//					Singapore 307591
//	
//
//                  TEL: 1-800-Lattice (USA and Canada)
//						 +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   --------------------------------------------------------------------
//

// Name:  i2c_master_registers.v   
// 
// Description: This module contains the registers used in the i2c core
//   
//-------------------------------------------------------------------------
// Code Revision History :
//-------------------------------------------------------------------------
// Ver: | Author	|Mod. Date	|Changes Made:
// V2.0 | cm		|12/2008    |Init ver - move the logic from top module
//-------------------------------------------------------------------------

//`include "..\..\testbench\verilog\timescale.v"
//`include "timescale.v"
module i2c_master_registers (wb_clk_i, rst_i, wb_rst_i,wb_dat_i,wb_adr_i,
                  wb_wacc, i2c_al, i2c_busy, 
                  done,irxack,
		  prer,                  
		  ctr, 
                  txr, 
                  cr,  
                  sr);
           
input wb_clk_i;     
input rst_i;        
input wb_rst_i;
input [7:0] wb_dat_i;
input [5:0] wb_adr_i;
input wb_wacc;
input i2c_al;    
input i2c_busy;
input  done, irxack;
output  [15:0] prer; // clock prescale register  
output  [ 7:0] ctr;  // control register         
output  [ 7:0] txr;  // transmit register                
output  [ 7:0] cr;   // command register         
output  [ 7:0] sr;   // status register          

reg  [15:0] prer; // clock prescale register                 
reg  [ 7:0] ctr;  // control register                    
reg  [ 7:0] txr;  // transmit register        
//wire [ 7:0] rxr;  // receive register         
reg  [ 7:0] cr;   // command register         
wire [ 7:0] sr;   // status register   

// generate prescale regisres, control registers, and transmit register                                                         
always @(posedge wb_clk_i or negedge rst_i)   
  if (!rst_i)                                             
    begin                                                 
        prer <= #1 16'hffff;                              
        ctr  <= #1  8'h0;                                 
        txr  <= #1  8'h0;                                 
    end                                                   
  else if (wb_rst_i)                                      
    begin                                                 
        prer <= #1 16'hffff;                              
        ctr  <= #1  8'h0;                                 
        txr  <= #1  8'h0;                                 
    end                                                   
  else                                                    
    if (wb_wacc)                                          
      case (wb_adr_i) // synopsis parallel_case           
         5'h00 : prer [ 7:0] <= #1 wb_dat_i;             
         5'h04 : prer [15:8] <= #1 wb_dat_i;             
         5'h08 : ctr         <= #1 wb_dat_i;             
         5'h0c : txr         <= #1 wb_dat_i;             
         default: ;                                       
      endcase                                             
                                                          
// generate command register (special case)                             
always @(posedge wb_clk_i or negedge rst_i )    
  if (~rst_i)                                             
    cr <= #1 8'h0;                                        
  else if (wb_rst_i)                                      
    cr <= #1 8'h0;                                        
  else if (wb_wacc)                                       
    begin                                                 
        //if (core_en & (wb_adr_i == 3'b100) ) 
        if (ctr[7] & (wb_adr_i == 5'h10) )              
          cr <= #1 wb_dat_i;                              
    end                                                   
  else                                                    
    begin                                                 
        if (done | i2c_al)                                
          cr[7:4] <= #1 4'h0;           // clear command b
                                        // or when aribitr
        cr[2:1] <= #1 2'b0;             // reserved bits  
        cr[0]   <= #1 2'b0;             // clear IRQ_ACK b
    end                                                   
    
reg  al;          // status register arbitration lost bit              
reg  rxack;       // received aknowledge from slave
reg  tip;         // transfer in progress
reg  irq_flag;    // interrupt pending flag           
                                                          
                                                          
// generate status register block + interrupt request signal  
// each output will be assigned to corresponding sr register locations on top level                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
always @(posedge wb_clk_i or negedge rst_i ) 
  if (!rst_i)                                                                                                                                                                                                                                                                                                                                                                                                                              
    begin                                                                                                                                                                                                                                                                                                                                                                                                                                  
        al       <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                                               
        rxack    <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                                               
        tip      <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                                               
        irq_flag <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                  
    end                                                                                                                                                                                                                                                                                                                                                                                                       
  else if (wb_rst_i)                                                                                                                                                                                                                                                                                                                                                                                          
    begin                                                                                                                                                                                                                                                                                                                                                                                                     
        al       <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                  
        rxack    <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                  
        tip      <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                  
        irq_flag <= #1 1'b0;                                                                                                                                                                                                                                                                                                                                                                                  
    end                                                                                                                                                                                                                                                                                                                                                                                                       
  else                                                                                                                                                                                                                                                                                                                                                                                                        
    begin                                                                                                                                                                                                                                                                                                                                                                                                     
        //al       <= #1 i2c_al | (al & ~sta);   
        al       <= #1 i2c_al | (al & ~cr[7]);                                                                                                                                                                                                                                                                                                                                                                 
        rxack    <= #1 irxack;                                                                                                                                                                                                                                                                                                                                                                                
        //tip      <= #1 (rd | wr);
        tip      <= #1 (cr[5] | cr[4]);                                                                                                                                                                                                                                                                                                                                                                              
        //irq_flag <= #1 (done | i2c_al | irq_flag) & ~iack;     
        irq_flag <= #1 (done | i2c_al | irq_flag) & ~cr[0];  // interrupt request flag is always generated                                                                                                                                                                                                                                                                                                
    end
        
// assign status register bits               
assign sr[7]   = rxack;               
assign sr[6]   = i2c_busy;            
assign sr[5]   = al;                  
assign sr[4:2] = 3'h0; // reserved    
assign sr[1]   = tip;                 
assign sr[0]   = irq_flag;  

endmodule         
