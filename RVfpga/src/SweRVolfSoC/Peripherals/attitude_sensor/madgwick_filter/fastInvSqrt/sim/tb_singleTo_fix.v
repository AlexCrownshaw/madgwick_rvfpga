`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2024 10:35:17
// Design Name: 
// Module Name: tb_singleTo_fix
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


module tb_singleToFix;

    // Parameters for the singleToFix module
    parameter INT_WIDTH = 8;
    parameter FRACT_WIDTH = 8;
    
    // Inputs
    reg [31:0] single;

    // Outputs
    wire [INT_WIDTH + FRACT_WIDTH - 1:0] fixed_point;

    // Instantiate the singleToFix module
    singleToFix #(INT_WIDTH, FRACT_WIDTH) uut (
        .single(single),
        .fixed_point(fixed_point)
    );

initial begin
        // Initialize inputs
        single = 32'b0;

        // Display header
        $display("Single Precision Input          Fixed Point Output");
        $display("-----------------------------  -----------------------------");

        // Test case 1: Value near 0.1688 to test rounding up
        single = 32'b00111110001011001101100111011111; // 0.16879986
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 2: Value near 0.5 to test no rounding needed
        single = 32'b00111111000000000000000000000000; // 0.5
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 3: Value near 0.4999999 to test rounding down
        single = 32'b00111110111111111111111111111111; // ~0.5 (just below)
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 4: Value near 1.0 to test rounding up
        single = 32'b00111111100000000000000000000001; // ~1.0 (just above)
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 5: Value near 1.0 to test no rounding needed
        single = 32'b00111111100000000000000000000000; // 1.0
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 6: Value near 2.5 to test rounding down
        single = 32'b01000000000111111111111111111111; // ~2.5 (just below)
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 7: Value near 3.75 to test rounding up
        single = 32'b01000000011100000000000000000001; // ~3.75 (just above)
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 8: Small value to test rounding up
        single = 32'b00111001111000000000000000000000; // Small value near 0.03
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 9: Small value to test rounding down
        single = 32'b00111001110111111111111111111111; // Small value just below 0.03
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 10: Large value to test rounding up
        single = 32'b01000100100000000000000000000001; // ~1025.0 (just above)
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 11: Large value to test no rounding needed
        single = 32'b01000100100000000000000000000000; // 1024.0
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // Test case 12: Large value to test rounding down
        single = 32'b01000100011111111111111111111111; // ~1023.9999 (just below)
        #10; // Wait for 10 time units
        $display("%b  %b", single, fixed_point);

        // End simulation
        $stop;
    end

endmodule
