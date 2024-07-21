`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.07.2024 16:52:54
// Design Name: 
// Module Name: tb_madgwick_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "madgwickDefines.vh"


module tb_madgwick_top;

    reg clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    reg rst;
    reg [5:0] adr_i;
    reg [31:0] dat_i;
    wire [31:0] dat_o;
    reg we_i;
    reg stb_i;
    reg cyc_i;
    wire ack_o;
    
    wire [`ACC_WIDTH-1:0] a_x_debug;
    wire [`ACC_WIDTH-1:0] a_y_debug;
    wire [`ACC_WIDTH-1:0] a_z_debug;
    
    wire [`GYRO_WIDTH-1:0] w_x_debug;
    wire [`GYRO_WIDTH-1:0] w_y_debug;
    wire [`GYRO_WIDTH-1:0] w_z_debug;
    
    wire [`Q_WIDTH-1:0] q_w_debug;
    wire [`Q_WIDTH-1:0] q_x_debug;
    wire [`Q_WIDTH-1:0] q_y_debug;
    wire [`Q_WIDTH-1:0] q_z_debug;
    
    wire enable_debug;
    wire start_debug;
    wire done_debug;
    
    wire rst_n_madgwick;
    wire valid_in_madgwick;
    wire ready_in_madgwick;
    wire valid_out_madgwick;
    wire ready_out_madgwick;
    
    madgwick_top dut (
        .clk(clk),
        .rst(rst),
        .adr_i(adr_i),
        .dat_i(dat_i),
        .dat_o(dat_o),
        .we_i(we_i),
        .stb_i(stb_i),
        .cyc_i(cyc_i),
        .ack_o(ack_o)
        
//        ,.a_x_debug(a_x_debug),
//        .a_y_debug(a_y_debug),
//        .a_z_debug(a_z_debug),
//        .w_x_debug(w_x_debug),
//        .w_y_debug(w_y_debug),
//        .w_z_debug(w_z_debug),
//        .q_w_debug(q_w_debug),
//        .q_x_debug(q_x_debug),
//        .q_y_debug(q_y_debug),
//        .q_z_debug(q_z_debug),
//        .enable_debug(enable_debug),
//        .start_debug(start_debug),
//        .done_debug(done_debug),
//        .rst_n_madgwick_debug(rst_n_madgwick),
//        .valid_in_madgwick_debug(valid_in_madgwick),
//        .ready_in_madgwick_debug(ready_in_madgwick),
//        .valid_out_madgwick_debug(valid_out_madgwick),
//        .ready_out_madgwick_debug(ready_out_madgwick)
    );
    
    reg [7:0] ctrl_reg_w;
    reg [7:0] ctrl_reg_r;
    wire enable;
    wire start;
    wire done;
    assign enable = ctrl_reg_r[0];
    assign start = ctrl_reg_r[1];
    assign done = ctrl_reg_r[2];
    
    reg [31:0] a_x;
    reg [31:0] a_y;
    reg [31:0] a_z;
    
    reg [31:0] w_x;
    reg [31:0] w_y;
    reg [31:0] w_z;
    
    reg [31:0] q_w;
    reg [31:0] q_x;
    reg [31:0] q_y;
    reg [31:0] q_z;
    
    initial begin
        rst = 1;
        adr_i = 0;
        dat_i = 0;
        we_i = 0;
        stb_i = 0;
        cyc_i = 0;
        
        a_x = 32'b11110111000;
        a_y = 32'b00101001010;
        a_z = 32'b00011000100;
       
        w_x = 32'b11111100011111;
        w_y = 32'b00000001011100;
        w_z = 32'b11111101010100;
        
        # 25;
        rst = 0;
        
        @ (posedge clk);
        
        // Read control register
        adr_i = 6'b000000;  // Control register 
        stb_i = 1'b1;
        cyc_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        ctrl_reg_r = dat_o[7:0];
        stb_i = 1'b0;
        cyc_i = 1'b0;
        
        @ (posedge clk);
        
        // Set enable flag
        ctrl_reg_w = 8'b1;
        adr_i = 6'b000000;  // Control register 
        dat_i = ctrl_reg_w;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Read control register
        adr_i = 6'b000000;  // Control register 
        stb_i = 1'b1;
        cyc_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        ctrl_reg_r = dat_o[7:0];
        stb_i = 1'b0;
        cyc_i = 1'b0;
        
        @ (posedge clk);
        
        // Write a_x
        adr_i = 6'b000001;
        dat_i = a_x;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Write a_y
        adr_i = 6'b000101;
        dat_i = a_y;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Write a_z
        adr_i = 6'b001001;
        dat_i = a_z;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Write w_x
        adr_i = 6'b001101;
        dat_i = w_x;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Write w_y
        adr_i = 6'b010001;
        dat_i = w_y;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Write w_z
        adr_i = 6'b010101;
        dat_i = w_y;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);

        // Set start flag
        ctrl_reg_w = 8'b11;
        adr_i = 6'b000000;  // Control register 
        dat_i = ctrl_reg_w;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Wait for done flag
        while (!done) begin
            // Read control register
            adr_i = 6'b000000;  // Control register 
            stb_i = 1'b1;
            cyc_i = 1'b1;
            wait (ack_o);
            @ (posedge clk);
            ctrl_reg_r = dat_o[7:0];
            stb_i = 1'b0;
            cyc_i = 1'b0;
            @ (posedge clk);
        end
                
        // De-assert start flag 
        ctrl_reg_w = 8'b1;
        adr_i = 6'b000000;  // Control register 
        dat_i = ctrl_reg_w;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        we_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        stb_i = 1'b0;
        cyc_i = 1'b0;
        we_i = 1'b0;
        
        @ (posedge clk);
        
        // Read control register
        adr_i = 6'b000000;  // Control register 
        stb_i = 1'b1;
        cyc_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        ctrl_reg_r = dat_o[7:0];
        stb_i = 1'b0;
        cyc_i = 1'b0;
        
        @ (posedge clk);
        
        // Read q_w
        adr_i = 6'b011001;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        q_w = dat_o;
        stb_i = 1'b0;
        cyc_i = 1'b0;
        
        @ (posedge clk);
        
        // Read q_x
        adr_i = 6'b011101;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        q_x = dat_o;
        stb_i = 1'b0;
        cyc_i = 1'b0;
        
        @ (posedge clk);
        
        // Read q_y
        adr_i = 6'b100001;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        q_y = dat_o;
        stb_i = 1'b0;
        cyc_i = 1'b0;
        
        @ (posedge clk);
        
        // Read q_z
        adr_i = 6'b100101;
        stb_i = 1'b1;
        cyc_i = 1'b1;
        wait (ack_o);
        @ (posedge clk);
        q_z = dat_o;
        stb_i = 1'b0;
        cyc_i = 1'b0;
    end 
    
endmodule
