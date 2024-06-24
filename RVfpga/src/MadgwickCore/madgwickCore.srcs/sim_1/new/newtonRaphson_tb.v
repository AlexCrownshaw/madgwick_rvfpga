`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2024 21:50:43
// Design Name: 
// Module Name: newtonRaphson_tb
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


module newtonRaphson_tb;
    reg [15:0] y0;
    reg [15:0] x_half;
    wire [15:0] y;
    
    // Instantiate the newtonRaphson module
    newtonRaphson dut (
        .y0(y0),
        .x_half(x_half),
        .y(y)
    );

    initial begin
        // x = 0.5
        y0 = 16'b0000_0000_0001_0111;
        x_half = 16'b0000_0000_0000_0100;
        #10;
        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
        #10

        // x = 1.5
        y0 = 16'b0000_0000_0000_1101;
        x_half = 16'b0000_0000_0000_1100;
        #10;
        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
        #10
        
        // x = 23.4375
        y0 = 16'b0000_0000_0000_0011;
        x_half = 16'b0000_0000_1011_1011;
        #10;
        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
        #10
        
        // 100.952
        y0 = 16'b0000_0000_0000_0010;
        x_half = 16'b0000_0011_0010_0111;
        #10;
        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
       #10
        
        // 137.8125
        y0 = 16'b0000_0000_0000_0001;
        x_half = 16'b0000_0100_0100_1110;
        #10;
        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
        $finish;
    end
endmodule
