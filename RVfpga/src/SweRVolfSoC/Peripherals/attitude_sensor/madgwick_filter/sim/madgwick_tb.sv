`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2024 11:07:11
// Design Name: 
// Module Name: madgwick_tb
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

module madgwick_tb;

    reg clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end

    // ---- Input/Output signals - Start ----
    
    reg rst_n;
    reg valid_in;
    wire ready_in;
    reg signed [`ACC_WIDTH-1:0] a_x;
    reg signed [`ACC_WIDTH-1:0] a_y;
    reg signed [`ACC_WIDTH-1:0] a_z;
    reg signed [`GYRO_WIDTH-1:0] w_x;
    reg signed [`GYRO_WIDTH-1:0] w_y;
    reg signed [`GYRO_WIDTH-1:0] w_z;
    wire valid_out;
    reg ready_out;
    wire signed [`Q_WIDTH-1:0] q_w;
    wire signed [`Q_WIDTH-1:0] q_x;
    wire signed [`Q_WIDTH-1:0] q_y;
    wire signed [`Q_WIDTH-1:0] q_z;
    
    // ---- Input/Output signals - End ----

    // ---- Debug signals - Start ----
    
    wire signed [`Q_WIDTH-1:0] q_w_half;    // Pre-compute
    wire signed [`Q_WIDTH-1:0] q_x_half;
    wire signed [`Q_WIDTH-1:0] q_y_half;
    wire signed [`Q_WIDTH-1:0] q_z_half;
    wire signed [`Q_WIDTH-1:0] q_w_two;
    wire signed [`Q_WIDTH-1:0] q_x_two;
    wire signed [`Q_WIDTH-1:0] q_y_two;
    wire signed [`Q_WIDTH-1:0] q_z_two;
    
    wire signed [`J_11_24_WIDTH-1:0] j_11_24; // Jacobian
    wire signed [`J_12_23_WIDTH-1:0] j_12_23;
    wire signed [`J_13_22_WIDTH-1:0] j_13_22;
    wire signed [`J_14_21_WIDTH-1:0] j_14_21;
    wire signed [`J_32_WIDTH-1:0] j_32;
    wire signed [`J_33_WIDTH-1:0] j_33;

    wire signed [`ACC_WIDTH-1:0] a_x_norm;  // Acc Norm
    wire signed [`ACC_WIDTH-1:0] a_y_norm;
    wire signed [`ACC_WIDTH-1:0] a_z_norm;
    wire start_acc_vec_norm;
    wire done_acc_vec_norm;

    wire signed [`Q_DOT_WIDTH-1:0] q_dot_w; // q_dot
    wire signed [`Q_DOT_WIDTH-1:0] q_dot_x;
    wire signed [`Q_DOT_WIDTH-1:0] q_dot_y;
    wire signed [`Q_DOT_WIDTH-1:0] q_dot_z;
    wire start_q_dot;
    wire done_q_dot;
    
    // ---- Debug signals - End ----
    
    madgwick dut (
    
        // ---- Input/Output signals inst - Start ----
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .a_x(a_x),
        .a_y(a_y),
        .a_z(a_z),
        .w_x(w_x),
        .w_y(w_y),
        .w_z(w_z),
        .valid_out(valid_out),
        .ready_out(ready_out),
        .q_w(q_w),
        .q_x(q_x),
        .q_y(q_y),
        .q_z(q_z)
        
        // ---- Input/Output signals inst - End ----

        // ---- Debug signals inst - Start ----
        
        ,.q_w_half(q_w_half),   // Pre-compute
        .q_x_half(q_x_half),
        .q_y_half(q_y_half),
        .q_z_half(q_z_half),
        .q_w_two(q_w_two),
        .q_x_two(q_x_two),
        .q_y_two(q_y_two),
        .q_z_two(q_z_two)
        
        ,.j_11_24(j_11_24),  // Jacobian
        .j_12_23(j_12_23),
        .j_13_22(j_13_22),
        .j_14_21(j_14_21),
        .j_32(j_32),
        .j_33(j_33)
        
        ,.a_x_norm(a_x_norm),   // Acc norm
        .a_y_norm(a_y_norm),
        .a_z_norm(a_z_norm)
        ,.start_acc_vec_norm(start_acc_vec_norm),
        .done_acc_vec_norm(done_acc_vec_norm)

        ,.q_dot_w(q_dot_w),  // q_dot
        .q_dot_x(q_dot_x),
        .q_dot_y(q_dot_y),
        .q_dot_z(q_dot_z),
        .start_q_dot(start_q_dot), 
        .done_q_dot(done_q_dot)
        
        // ---- Debug signals inst - End ----
    );
    
    initial begin
    
        // Init
        rst_n = 0;
        valid_in = 1'b0;
        a_x = `ACC_WIDTH'b0;
        a_y = `ACC_WIDTH'b0;
        a_z = `ACC_WIDTH'b0;
        w_x = `GYRO_WIDTH'b0;
        w_y = `GYRO_WIDTH'b0;
        w_z = `GYRO_WIDTH'b0;
        ready_out = 1'b0;
        #25 rst_n = 1;
        
        a_x = `ACC_WIDTH'b11110111000;
        a_y = `ACC_WIDTH'b00101001010;
        a_z = `ACC_WIDTH'b00011000100;
        w_x = `GYRO_WIDTH'b1111001000;
        w_y = `GYRO_WIDTH'b0000010111;
        w_z = `GYRO_WIDTH'b1111010101;
        valid_in = 1'b1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        valid_in = 1'b0;
        ready_out = 1'b1;
        wait(valid_out && ready_out);
        @ (posedge clk);
        ready_out = 1'b0;

        a_x = `ACC_WIDTH'b0;
        a_y = `ACC_WIDTH'b0;
        a_z = `ACC_WIDTH'b0;
        w_x = `GYRO_WIDTH'b0;
        w_y = `GYRO_WIDTH'b0;
        w_z = `GYRO_WIDTH'b0;
        valid_in = 1'b1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        valid_in = 1'b0;
        ready_out = 1'b1;
        wait(valid_out && ready_out);
        @ (posedge clk);
        ready_out = 1'b0;
        
    end
    
endmodule
