//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2024 12:31:18
// Design Name: 
// Module Name: singleToFix
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


module singleToFix #(
    parameter INT_WIDTH = 12,      // Number of integer bits
    parameter FRACT_WIDTH = 4       // Number of fractional bits
    )   
    (
    input wire [31:0] single,
    output reg [INT_WIDTH + FRACT_WIDTH - 1:0] fixed_point
    );

    // IEEE 754 single-precision floating point breakdown
    wire sign;
    wire [7:0] exponent;
    wire [22:0] mantissa;

    assign sign = single[31];
    assign exponent = single[30:23];
    assign mantissa = single[22:0];

    // Bias for the exponent (127 for single precision)
    localparam integer BIAS = 127;
    localparam integer TOTAL_BITS = INT_WIDTH + FRACT_WIDTH;

    reg [31:0] normalised_mantissa;
    reg [31:0] fixed_point_value;
    integer shift_amount;

    // Convert to fixed point
    always @(*) begin
        if (exponent == 8'd0) begin
            // Handle denormalized numbers (exponent is 0)
            normalised_mantissa = {1'b0, mantissa} >> (23 - FRACT_WIDTH + 1);
            shift_amount = -BIAS + 1;
        end else begin
            // Normalized numbers
            normalised_mantissa = {1'b1, mantissa};
            shift_amount = exponent - BIAS - (23 - FRACT_WIDTH);
        end

        // Adjust mantissa based on exponent
        if (shift_amount < 0) begin
            fixed_point_value = normalised_mantissa >> (-shift_amount);
        end else begin
            fixed_point_value = normalised_mantissa << shift_amount;
        end

        // Rounding: Check the bit just below the LSB of the target fixed-point representation
        if (shift_amount < 0) begin
            if ((normalised_mantissa >> (-shift_amount - 1)) & 1) begin
                fixed_point_value = fixed_point_value + 1;
            end
        end else if ((normalised_mantissa << shift_amount) & (1 << (23 - FRACT_WIDTH - 1))) begin
            fixed_point_value = fixed_point_value + 1;
        end

        // Saturation
        if (fixed_point_value >= (1 << TOTAL_BITS)) begin
            fixed_point = {TOTAL_BITS{1'b1}};
        end else begin
            fixed_point = fixed_point_value[TOTAL_BITS-1:0];
        end
    end

endmodule


//module singleToFix #(
//    parameter INT_WIDTH = 12,      // Number of integer bits
//    parameter FRACT_WIDTH = 4       // Number of fractional bits
//    )   
//    (
//    input wire [31:0] single,
//    output reg [INT_WIDTH + FRACT_WIDTH - 1:0] fixed_point
//    );

//    // IEEE 754 single-precision floating point breakdown
//    wire sign;
//    wire [7:0] exponent;
//    wire [22:0] mantissa;

//    assign sign = single[31];
//    assign exponent = single[30:23];
//    assign mantissa = single[22:0];

//    // Bias for the exponent (127 for single precision)
//    localparam integer BIAS = 127;
//    localparam integer TOTAL_BITS = INT_WIDTH + FRACT_WIDTH;

//    reg [31:0] normalised_mantissa;
//    reg [31:0] fixed_point_value;
//    integer shift_amount;

//    // Convert to fixed point
//    always @(*) begin
//        if (exponent == 8'd0) begin
//            // Handle denormalized numbers (exponent is 0)
//            normalised_mantissa = {1'b0, mantissa} >> (23 - FRACT_WIDTH);
//            shift_amount = -BIAS + 1;
//        end else begin
//            // Normalised numbers
//            normalised_mantissa = {1'b1, mantissa};
//            shift_amount = exponent - BIAS - (23 - FRACT_WIDTH);
//        end

//        // Adjust mantissa based on exponent
//        if (shift_amount < 0) begin
//            fixed_point_value = normalised_mantissa >> (-shift_amount);
//        end else begin
//            fixed_point_value = normalised_mantissa << shift_amount;
//        end

//        fixed_point = fixed_point_value[TOTAL_BITS-1:0];    // Apply leading zero for sign
//    end

//endmodule