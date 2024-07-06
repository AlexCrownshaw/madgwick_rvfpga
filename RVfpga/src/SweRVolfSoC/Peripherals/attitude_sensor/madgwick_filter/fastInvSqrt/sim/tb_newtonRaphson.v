`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2024 12:16:50
// Design Name: 
// Module Name: tb_newtonRaphson
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


module tb_newtonRaphson;

    parameter INT_WIDTH = 12;
    parameter FRACT_WIDTH = 4;
    localparam WORD_WIDTH = INT_WIDTH + FRACT_WIDTH;

    reg [WORD_WIDTH-1:0] x_half;
    reg [WORD_WIDTH-1:0] y0;
    wire [WORD_WIDTH-1:0] y;
    
//    wire [(WORD_WIDTH*3)-1:0] one_point_five;
//    wire [(WORD_WIDTH*3)-1:0] A;
//    wire [(WORD_WIDTH*3):0] B;
//    wire [(WORD_WIDTH*4):0] C;
//    wire [WORD_WIDTH*4:0] round_const;
//    wire [(WORD_WIDTH*4)+1:0] y_temp;

//    newtonRaphson newt_raph_inst(
//        .y0(y0),
//        .x_half(x_half),
//        .y(y)
//    );

    newtonRaphson #(
        .INT_WIDTH(INT_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) uut (
        .x_half(x_half),
        .y0(y0),
        .y(y)
//        ,.one_point_five(one_point_five),
//        .A(A),
//        .B(B),
//        .C(C),
//        .round_const(round_const),
//        .y_temp(y_temp)
    );

    initial begin
    
        y0 = 16'b0000000000000010;
        x_half = 16'b0000000100101010;
        #10;
        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
//        #10
//        // x = 0.5
//        y0 = 16'b0000_0000_0001_0111;
//        x_half = 16'b0000_0000_0000_0100;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
//        #10

//        // x = 1.5
//        y0 = 16'b0000_0000_0000_1101;
//        x_half = 16'b0000_0000_0000_1100;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
//        #10
        
//        // x = 23.4375
//        y0 = 16'b0000_0000_0000_0011;
//        x_half = 16'b0000_0000_1011_1011;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
//        #10
        
//        // 100.952
//        y0 = 16'b0000_0000_0000_0010;
//        x_half = 16'b0000_0011_0010_0111;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
//       #10
        
//        // 137.8125
//        y0 = 16'b0000_0000_0000_0001;
//        x_half = 16'b0000_0100_0100_1110;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);

//        // x = 0.5 ans = '01011010'
//        y0 = 8'b01_011100;
//        x_half = 8'b00_010000;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
//        #10

//        // x = 1.5 ans = '00110100'
//        y0 = 8'b00_110101;
//        x_half = 8'b00_110001;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);
        
//        #10

//        // x = 0.0625 ans = '11111111'
//        y0 = 8'b11110111;
//        x_half = 8'b00_000010;
//        #10;
//        $display("y0: %b, x_half: %b, Output: %b", y0, x_half, y);

        $stop;
    end
endmodule

