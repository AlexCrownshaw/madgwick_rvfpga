`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.05.2024 20:34:32
// Design Name: 
// Module Name: newtonRaphson
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

module newtonRaphson (
    input [15:0] y0, x_half,
    output reg [15:0] y
    );
    
    reg [47:0] A, B;
    reg [64:0] y_temp;

    always @ (y0) begin
        A = x_half * y0 * y0;
        B = (48'h1800 - A);
        y_temp = (y0 * B) + 65'h800;
        y = y_temp[27:12];
    end
    
endmodule
