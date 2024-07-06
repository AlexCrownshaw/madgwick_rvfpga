`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2024 13:02:09
// Design Name: 
// Module Name: tb_accVecNorm
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


//module tb_accVecNorm;

//    reg clk;
//    reg rst_n;
//    reg valid_in;
//    wire ready_in;
//    wire [(`ACC_WIDTH*3)-1:0] data_in;
//    wire valid_out;
//    reg ready_out;
//    wire [(`ACC_WIDTH*3)-1:0] data_out;
    
//    wire valid_in_invSqrtAccNorm;
//    wire ready_in_invSqrtAccNorm;
//    wire [`ACC_MAG_SQR_WIDTH-1:0] data_in_invSqrtAccNorm;
//    wire valid_out_invSqrtAccNorm;
//    wire ready_out_invSqrtAccNorm;
//    wire signed [`ACC_MAG_SQR_WIDTH-1:0] data_out_invSqrtAccNorm;
//    wire [2:0] acc_norm_debug_state;
    
//    reg signed [`ACC_WIDTH-1:0] a_x;
//    reg signed [`ACC_WIDTH-1:0] a_y;
//    reg signed [`ACC_WIDTH-1:0] a_z;
    
//    assign data_in = {a_x, a_y, a_z};
    
//    wire signed [`ACC_WIDTH-1:0] a_x_norm;
//    wire signed [`ACC_WIDTH-1:0] a_y_norm;
//    wire signed [`ACC_WIDTH-1:0] a_z_norm; 
    
//    assign a_x_norm = data_out[`ACC_WIDTH-1:0];
//    assign a_y_norm = data_out[(`ACC_WIDTH*2)-1:`ACC_WIDTH];
//    assign a_z_norm = data_out[(`ACC_WIDTH*3)-1:`ACC_WIDTH*2];
    
//    initial begin
//        clk = 0;
//        forever #5 clk = ~clk; // 10ns clock period (100MHz)
//    end
    
//    accVecNorm dut (
//        .clk(clk),
//        .rst_n(rst_n),
//        .valid_in(valid_in),
//        .ready_in(ready_in),
//        .data_in(data_in),
//        .valid_out(valid_out),
//        .ready_out(ready_out),
//        .data_out(data_out)
        
//        // Debug
//        ,.valid_in_invSqrtAccNorm(valid_in_invSqrtAccNorm),
//        .ready_in_invSqrtAccNorm(ready_in_invSqrtAccNorm),
//        .data_in_invSqrtAccNorm(data_in_invSqrtAccNorm),
//        .valid_out_invSqrtAccNorm(valid_out_invSqrtAccNorm),
//        .ready_out_invSqrtAccNorm(ready_out_invSqrtAccNorm),
//        .data_out_invSqrtAccNorm(data_out_invSqrtAccNorm),
//        .acc_norm_debug_state(acc_norm_debug_state)
//    );
    
//    initial begin
    
//        rst_n = 0;
//        valid_in = 1'b0;
//        ready_out = 1'b0;
//        a_x = `ACC_WIDTH'b0;
//        a_y = `ACC_WIDTH'b0;
//        a_z = `ACC_WIDTH'b0;
//        #25 rst_n = 1;
        
//        a_x = `ACC_WIDTH'b11110111000;
//        a_y = `ACC_WIDTH'b00101001010;
//        a_z = `ACC_WIDTH'b00011000100;
//        valid_in = 1'b1;
//        wait (valid_in && ready_in);    // Simulate check for (valid_in && ready_in) over a clk cycle
//        @(posedge clk);
//        if (valid_in && ready_in) begin
//            @(posedge clk);
//            valid_in = 1'b0;
//            ready_out = 1'b1;
//        end
//        wait (valid_out && ready_out);    // Simulate check for (valid_out && ready_out) over a clk cycle
//        @(posedge clk);
//        if (valid_out && ready_out) begin
//            @(posedge clk);
//            ready_out = 1'b0;
//        end
       
//        a_x = `ACC_WIDTH'b0;
//        a_y = `ACC_WIDTH'b0;
//        a_z = `ACC_WIDTH'b0;
//        valid_in = 1'b1;
//        wait (valid_in && ready_in);    // Simulate check for (valid_in && ready_in) over a clk cycle
//        @(posedge clk);
//        if (valid_in && ready_in) begin
//            @(posedge clk);
//            valid_in = 1'b0;
//            ready_out = 1'b1;
//        end
//        wait (valid_out && ready_out);    // Simulate check for (valid_out && ready_out) over a clk cycle
//        @(posedge clk);
//        if (valid_out && ready_out) begin
//            @(posedge clk);
//            ready_out = 1'b0;
//        end
//    end
    
//endmodule


module tb_accVecNorm;

    reg clk;
    reg rst_n;
    reg start;
    wire done;
    wire [(`ACC_WIDTH*3)-1:0] data_in;
    wire [(`ACC_WIDTH*3)-1:0] data_out;
    
    wire valid_in_invSqrtAccNorm;
    wire ready_in_invSqrtAccNorm;
    wire [`ACC_MAG_SQR_WIDTH-1:0] data_in_invSqrtAccNorm;
    wire valid_out_invSqrtAccNorm;
    wire ready_out_invSqrtAccNorm;
    wire signed [`ACC_MAG_SQR_WIDTH-1:0] data_out_invSqrtAccNorm;
    wire [2:0] acc_norm_debug_state;
    
    reg signed [`ACC_WIDTH-1:0] a_x;
    reg signed [`ACC_WIDTH-1:0] a_y;
    reg signed [`ACC_WIDTH-1:0] a_z;
    
    assign data_in = {a_x, a_y, a_z};
    
    wire signed [`ACC_WIDTH-1:0] a_x_norm;
    wire signed [`ACC_WIDTH-1:0] a_y_norm;
    wire signed [`ACC_WIDTH-1:0] a_z_norm; 
    
    assign a_x_norm = data_out[`ACC_WIDTH-1:0];
    assign a_y_norm = data_out[(`ACC_WIDTH*2)-1:`ACC_WIDTH];
    assign a_z_norm = data_out[(`ACC_WIDTH*3)-1:`ACC_WIDTH*2];
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    accVecNorm dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done),
        .data_in(data_in),
        .data_out(data_out)
        
//        // Debug
//        ,.valid_in_invSqrtAccNorm(valid_in_invSqrtAccNorm),
//        .ready_in_invSqrtAccNorm(ready_in_invSqrtAccNorm),
//        .data_in_invSqrtAccNorm(data_in_invSqrtAccNorm),
//        .valid_out_invSqrtAccNorm(valid_out_invSqrtAccNorm),
//        .ready_out_invSqrtAccNorm(ready_out_invSqrtAccNorm),
//        .data_out_invSqrtAccNorm(data_out_invSqrtAccNorm),
//        .acc_norm_debug_state(acc_norm_debug_state)
    );
    
    initial begin
    
        rst_n = 0;
        start = 1'b0;
        a_x = `ACC_WIDTH'b0;
        a_y = `ACC_WIDTH'b0;
        a_z = `ACC_WIDTH'b0;
        #25 rst_n = 1;
        
        #20;
        @ (posedge clk);
        a_x = `ACC_WIDTH'b11110111000;
        a_y = `ACC_WIDTH'b00101001010;
        a_z = `ACC_WIDTH'b00011000100;
        start <= 1'b1;
        wait (done);
        @ (posedge clk);
        start <= 1'b0;
        
       #20; 
       @ (posedge clk);
        a_x = `ACC_WIDTH'b0;
        a_y = `ACC_WIDTH'b0;
        a_z = `ACC_WIDTH'b0;
        start <= 1'b1;
        wait (done);
        @ (posedge clk);
        start <= 1'b0;
    end
    
endmodule
