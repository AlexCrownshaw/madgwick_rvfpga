`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2024 18:40:45
// Design Name: 
// Module Name: fastInvSqrtAccNorm_tb
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


module fastInvSqrtAccNorm_tb;
    reg clk;
    reg rst;
    
    reg valid_in;
    wire ready_in;
    wire valid_out;
    reg ready_out;
    
    wire [2:0] debug_state;
    wire rst_fix_to_single;
    wire valid_in_fix_to_single;
    wire ready_in_fix_to_single;
    wire valid_out_fix_to_single;
    wire ready_out_fix_to_single;
    
    wire rst_single_to_fix;
    wire valid_in_single_to_fix;
    wire ready_in_single_to_fix;
    wire valid_out_single_to_fix;
    wire ready_out_single_to_fix;
    
    reg [15:0] data_in;
    wire [15:0] x_half;
    wire [31:0] x_float;
    wire [31:0] y0_float;
    wire [15:0] y0_fix;
    wire [15:0] y;
    wire [15:0] data_out;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    fastInvSqrtAccNorm dut(
        .debug_state(debug_state),
        .rst_fix_to_single(rst_fix_to_single),
        .valid_in_fix_to_single(valid_in_fix_to_single),
        .ready_in_fix_to_single(ready_in_fix_to_single),
        .valid_out_fix_to_single(valid_out_fix_to_single),
        .ready_out_fix_to_single(ready_out_fix_to_single),
        
        .rst_single_to_fix(rst_single_to_fix),
        .valid_in_single_to_fix(valid_in_single_to_fix),
        .ready_in_single_to_fix(ready_in_single_to_fix),
        .valid_out_single_to_fix(valid_out_single_to_fix),
        .ready_out_single_to_fix(ready_out_single_to_fix),
        
        .x_half(x_half),
        .x_float(x_float),
        .y0_float(y0_float),
        .y0_fix(y0_fix),
        .y(y),
            
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .data_out(data_out),
        .valid_out(valid_out),
        .ready_out(ready_out)
    );
    
    initial begin
        // Initialize Inputs
        rst = 1;
        data_in = 16'b0;
        valid_in = 1'b0;
        ready_out = 1'b0;
        #25 rst = 0;
        
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
        
        data_in = 16'b0000_1000_1001_1101; // 137.8125
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
