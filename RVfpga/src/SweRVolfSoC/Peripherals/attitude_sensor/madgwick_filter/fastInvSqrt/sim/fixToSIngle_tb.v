`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2024 21:41:44
// Design Name: 
// Module Name: fixToSingle_tb
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


module fixToSingle_tb;

    parameter INT_WIDTH = 8;
    parameter FRACT_WIDTH = 8;

    reg clk;
    reg rst;
    reg valid_in;
    reg ready_out;
    wire ready_in;
    wire valid_out;
    reg [(INT_WIDTH + FRACT_WIDTH - 1):0] fixed_point;
    wire [31:0] data_out;
//    wire [2:0] debug_state;

    fixToSingle #(
        .INT_WIDTH(INT_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .valid_out(valid_out),
        .ready_out(ready_out),
        .fixed_point(fixed_point),
        .data_out(data_out)
//        .debug_state(debug_state)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test vector generation and control signals
    initial begin
        // Initialize signals
        rst = 1;
        valid_in = 0;
        ready_out = 0;
        fixed_point = 0;

        // Reset the UUTs
        #25;
        rst = 0;
        
//        fixed_point = 16'b0000000000010000; // 1.0
        fixed_point = 16'b0000_0001_0000_0000
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
//        fixed_point = 16'b0000000000101000; // 2.5
        fixed_point = 16'b0000_0010_1000_0000
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
//        fixed_point = 16'b0000000000111100; // 3.75
        fixed_point = 16'b0000_0011_1100_0000
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
//        fixed_point = 16'b0000000001010010; // 5.125
        fixed_point = 16'b0000_0101_0010_0000
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
//        fixed_point = 16'b1111111111111111; // 4095.9375
        fixed_point = 16'b1111_1111_1111_1111   // 255.9960938
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
        fixed_point = 16'b0111111111111111; // 2047.9375  // 127.9960938
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
        fixed_point = 16'b1111111111110000; // 4095 // 255.9375
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
        fixed_point = 16'b0000000000000001; // 0.0625 // 0.00390625 
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
        fixed_point = 16'b1000000000000000; // 2048 // 128
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);
        
        fixed_point = 16'b0000000000000000; // 0.0
        valid_in = 1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        $display("Fixed-point: %b, Floating-point: %b", fixed_point, data_out);

        $finish;
    end

endmodule