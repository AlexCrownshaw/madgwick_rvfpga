`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.06.2024 16:48:50
// Design Name: 
// Module Name: fastInvSqrt_q12_4_tb
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


module fastInvSqrt_q12_4_tb;

    reg clk;
    reg rst;
    
    reg valid_in;
    wire ready_in;
    wire valid_out;
    reg ready_out;
    
    reg [15:0] data_in;
    wire [15:0] data_out;
    
//    // Debug I/O
//    wire [15:0] x_half;
//    wire [31:0] x_single;
//    wire [31:0] y0_single;
//    wire [15:0] y0_fix;
//    wire [15:0] y;
    
//    wire [15:0] data_in_fixToSingle;
//    wire [31:0] data_in_singleToFix;

//    wire start_newt_raph;
//    wire done_newt_raph;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    fastInvSqrt #(
        .INT_WIDTH(12),
        .FRACT_WIDTH(4)
    ) dut (
        .clk(clk),
        .rst_n(rst),
        .data_in(data_in),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .data_out(data_out),
        .valid_out(valid_out),
        .ready_out(ready_out)
//        ,.start_newt_raph(start_newt_raph),
//        .done_newt_raph(done_newt_raph)
        
//        // Debug internal signals
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
        rst = 0;
        data_in = 16'b0;
        valid_in = 1'b0;
        ready_out = 1'b0;
        #25 rst = 1;
        
        data_in = 16'b0000001001010100;
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
        
        data_in = 16'b0000_0000_0000_1000; // 0.5
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
        
        data_in = 16'b0000_0000_0001_1000; // 1.5
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
        
        data_in = 16'b0000_0001_0111_0111; // 23.4375
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
        
        data_in = 16'b0000_0110_0100_1111; // 100.952
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
        
        data_in = 16'b0000_0000_0000_1000; // 0.5
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
