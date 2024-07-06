`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2024 15:18:52
// Design Name: 
// Module Name: fastInvSqrt_q4_6_tb
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


module fastInvSqrt_q4_6_tb;

    parameter INT_WIDTH = 4;
    parameter FRACT_WIDTH = 6;

    reg clk;
    reg rst;
    
    reg valid_in;
    wire ready_in;
    wire valid_out;
    reg ready_out;
    
    reg [INT_WIDTH+FRACT_WIDTH-1:0] data_in;
    wire [INT_WIDTH+FRACT_WIDTH-1:0] data_out;
    
//    wire [15:0] x_half;
//    wire [31:0] x_single;
//    wire [31:0] y0_single;
//    wire [15:0] y0_fix;
//    wire [15:0] y;
    
//    wire [15:0] data_in_fixToSingle;
//    wire [31:0] data_in_singleToFix;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    fastInvSqrt #(
        .INT_WIDTH(INT_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .data_out(data_out),
        .valid_out(valid_out),
        .ready_out(ready_out)
        
         // Debug internal signals
//        ,
//        .x_half(x_half),
//        .x_single(x_single),
//        .y0_single(y0_single),
//        .y0_fix(y0_fix),
//        .y(y),
        
//        .data_in_fixToSingle(data_in_fixToSingle),
//        .data_in_singleToFix(data_in_singleToFix)
    );
    
    initial begin
        // Initialize Inputs
        rst = 1;
        data_in = 16'b0;
        valid_in = 1'b0;
        ready_out = 1'b0;
        #25 rst = 0;
        
         // 0.5 ans = '0001011010'
        data_in = 10'b0000_1000_00;
        valid_in = 1'b1;
        wait (valid_in && ready_in);    // Simulate check for (valid_in && ready_in) over a clk cycle
        @(posedge clk);
        if (valid_in && ready_in) begin
            @(posedge clk);
            valid_in = 1'b0;
            ready_out = 1'b1;
        end
        wait (valid_out && ready_out);    // Simulate check for (valid_out && ready_out) over a clk cycle
        @(posedge clk);
        if (valid_out && ready_out) begin
            @(posedge clk);
            ready_out = 1'b0;
        end
        
         // 1.5 ans = '0000110100'
        data_in = 10'b0001_1000_00;
        valid_in = 1'b1;
        wait (valid_in && ready_in);    // Simulate check for (valid_in && ready_in) over a clk cycle
        @(posedge clk);
        if (valid_in && ready_in) begin
            @(posedge clk);
            valid_in = 1'b0;
            ready_out = 1'b1;
        end
        wait (valid_out && ready_out);    // Simulate check for (valid_out && ready_out) over a clk cycle
        @(posedge clk);
        if (valid_out && ready_out) begin
            @(posedge clk);
            ready_out = 1'b0;
        end
        
        // 13.4375 ans = '0000010001'
        data_in = 10'b1101_0111_00;
        valid_in = 1'b1;
        wait (valid_in && ready_in);    // Simulate check for (valid_in && ready_in) over a clk cycle
        @(posedge clk);
        if (valid_in && ready_in) begin
            @(posedge clk);
            valid_in = 1'b0;
            ready_out = 1'b1;
        end
        wait (valid_out && ready_out);    // Simulate check for (valid_out && ready_out) over a clk cycle
        @(posedge clk);
        if (valid_out && ready_out) begin
            @(posedge clk);
            ready_out = 1'b0;
        end
        
        wait(ready_out);
        # 100;
        
        $finish;
    end

endmodule
