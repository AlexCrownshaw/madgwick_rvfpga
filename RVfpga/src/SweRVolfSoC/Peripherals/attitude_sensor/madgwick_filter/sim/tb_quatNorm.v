`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2024 09:49:24
// Design Name: 
// Module Name: tb_quatNorm
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


module tb_quatNorm;

    parameter INPUT_INT_WIDTH = `Q_HAT_DOT_TRUNC_INT_WIDTH;
    parameter INPUT_FRACT_WIDTH = `Q_HAT_DOT_TRUNC_FRACT_WIDTH;
    parameter MAG_SQR_INT_WIDTH = `Q_HAT_DOT_MAG_SQR_INT_WIDTH;
    parameter MAG_SQR_FRACT_WIDTH = `Q_HAT_DOT_MAG_SQR_FRACT_WIDTH;

//    parameter INPUT_INT_WIDTH = `Q_INT_WIDTH;
//    parameter INPUT_FRACT_WIDTH = `Q_FRACT_WIDTH;
//    parameter MAG_SQR_INT_WIDTH = `Q_MAG_SQR_INT_WIDTH;
//    parameter MAG_SQR_FRACT_WIDTH = `Q_MAG_SQR_FRACT_WIDTH;

    reg clk;
    reg rst_n;
    reg start;
    wire done;
    wire [((INPUT_INT_WIDTH + INPUT_FRACT_WIDTH) * 4) - 1:0] data_in;
    wire [((INPUT_INT_WIDTH + INPUT_FRACT_WIDTH) * 4) - 1:0] data_out;
    
    reg signed [INPUT_INT_WIDTH + INPUT_FRACT_WIDTH-1:0] q_w;
    reg signed [INPUT_INT_WIDTH + INPUT_FRACT_WIDTH-1:0] q_x;
    reg signed [INPUT_INT_WIDTH + INPUT_FRACT_WIDTH-1:0] q_y;
    reg signed [INPUT_INT_WIDTH + INPUT_FRACT_WIDTH-1:0] q_z;
    
    assign data_in = {q_w, q_x, q_y, q_z};

    // Debug signals
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH) - 1:0] q_w_norm_temp;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH) - 1:0] q_x_norm_temp;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH) - 1:0] q_y_norm_temp;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH) - 1:0] q_z_norm_temp;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH):0] q_w_norm_rounded;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH):0] q_x_norm_rounded;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH):0] q_y_norm_rounded;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH):0] q_z_norm_rounded;
    wire signed [(INPUT_INT_WIDTH + INPUT_FRACT_WIDTH + MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH) - 1:0] q_norm_round_const;
    wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_w_norm;
    wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_x_norm;
    wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_y_norm;
    wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_z_norm; 
    wire [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*2)+2:0] q_mag_sqr;
    wire [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*2)+2:0] q_mag_sqr_rounded;
    wire [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*2)+2:0] q_mag_sqr_round_const;
    wire [MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH-1:0] data_in_invSqrt;
    wire valid_in_invSqrt;
    wire ready_in_invSqrt;
    wire [MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH-1:0] data_out_invSqrt;
    wire valid_out_invSqrt;
    wire ready_out_invSqrt;
    wire [2:0] debug_state;

    quaternionNormalisation #(
        .INPUT_INT_WIDTH(INPUT_INT_WIDTH),
        .INPUT_FRACT_WIDTH(INPUT_FRACT_WIDTH),
        .MAG_SQR_INT_WIDTH(MAG_SQR_INT_WIDTH),
        .MAG_SQR_FRACT_WIDTH(MAG_SQR_FRACT_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done),
        .data_in(data_in),
        .data_out(data_out),
        
        .q_w_norm_temp(q_w_norm_temp),
        .q_x_norm_temp(q_x_norm_temp),
        .q_y_norm_temp(q_y_norm_temp),
        .q_z_norm_temp(q_z_norm_temp),
        .q_w_norm_rounded(q_w_norm_rounded),
        .q_x_norm_rounded(q_x_norm_rounded),
        .q_y_norm_rounded(q_y_norm_rounded),
        .q_z_norm_rounded(q_z_norm_rounded),
        .q_norm_round_const(q_norm_round_const),
        .q_w_norm(q_w_norm),
        .q_x_norm(q_x_norm),
        .q_y_norm(q_y_norm),
        .q_z_norm(q_z_norm),
        .q_mag_sqr(q_mag_sqr),
        .q_mag_sqr_rounded(q_mag_sqr_rounded),
        .q_mag_sqr_round_const(q_mag_sqr_round_const),
        .data_in_invSqrt(data_in_invSqrt),
        .valid_in_invSqrt(valid_in_invSqrt),
        .ready_in_invSqrt(ready_in_invSqrt),
        .data_out_invSqrt(data_out_invSqrt),
        .valid_out_invSqrt(valid_out_invSqrt),
        .ready_out_invSqrt(ready_out_invSqrt),
        .debug_state(debug_state)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end
    
    initial begin
        
        rst_n = 0;
        start = 1'b0;
        q_w = 'b0;
        q_x = 'b0;
        q_y = 'b0;
        q_z = 'b0;
        #25 rst_n = 1;
        
        #20;
        @ (posedge clk);
        q_w = 'b0000000000000000;
        q_x = 'b1111111000010000;
        q_y = 'b1111111110011000;
        q_z = 'b0000000000000000;

//        q_w = 'b0100000000000000;
//        q_x = 'b1111111111101110;
//        q_y = 'b0000000000001010;
//        q_z = 'b1111111111101111;
        start <= 1'b1;
        wait (done);
        @ (posedge clk);
        start <= 1'b0;
        
       #20; 
       @ (posedge clk);
        q_w = 'b0;
        q_x = 'b0;
        q_y = 'b0;
        q_z = 'b0;
        start <= 1'b1;
        wait (done);
        @ (posedge clk);
        start <= 1'b0;
    
    end
    
endmodule
