//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.06.2024 16:43:10
// Design Name: 
// Module Name: fixToSingle
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


module fixToSingle #(
    parameter INT_WIDTH = 12,      // Number of integer bits
    parameter FRACT_WIDTH = 4       // Number of fractional bits 
    )
    (
    input wire [(INT_WIDTH + FRACT_WIDTH - 1):0] fixed_point,  // Fixed-point input
    output reg [31:0] single    // IEEE 754 single-precision float output
    );
    
    reg [(INT_WIDTH + FRACT_WIDTH - 1):0] normalised;  // Normalised fixed-point representation
    reg [7:0] exponent; 
    reg [22:0] mantissa;
    reg [5:0] shift_amount; // Amount to shift to normalise the fixed-point number
    
    always @(*) begin
        // Handle the special case of zero input
        if (fixed_point == 0) begin
            single = 32'b0;
        end else begin
            normalised = fixed_point;
            
            // Normalise the fixed-point number (find the position of the most significant 1)
            shift_amount = 0;
            while (normalised[(INT_WIDTH + FRACT_WIDTH - 1)] == 0 && shift_amount < (INT_WIDTH + FRACT_WIDTH)) begin
                normalised = normalised << 1;
                shift_amount = shift_amount + 1;
            end
            
            exponent = 127 + ((INT_WIDTH - 1) - shift_amount);   // Calculate exponent using bias of 127 
            
            // Extract mantissa (drop the leading 1 and shift left by the fractional bit count)
            mantissa = normalised[(INT_WIDTH + FRACT_WIDTH - 2):0] << (23 - (INT_WIDTH + FRACT_WIDTH - 1));
            
            single = {1'b0, exponent, mantissa[22:0]};  // Assemble IEEE 754 single-precision float
        end
    end
endmodule


//module fixToSingle #(
//    parameter INT_WIDTH = 12,      // Number of integer bits
//    parameter FRACT_WIDTH = 4      // Number of fractional bits 
//    )
//    (
//    input wire clk,
//    input wire rst_n,
    
//    input wire valid_in,
//    output reg ready_in,
//    output reg valid_out,
//    input wire ready_out,
    
//    input wire [(INT_WIDTH + FRACT_WIDTH - 1):0] fixed_point,  // Fixed-point input
//    output reg [31:0] data_out    // IEEE 754 single-precision float output
    
//    // Debug I/O
////    ,output reg [2:0] debug_state
//    );
    
//    reg [31:0] single;
//    reg [(INT_WIDTH + FRACT_WIDTH - 1):0] normalised;  // Normalised fixed-point representation
//    reg [7:0] exponent; 
//    reg [22:0] mantissa;
//    reg [5:0] shift_amount; // Amount to shift to normalise the fixed-point number
    
//    // State machine states
//    typedef enum reg [2:0] {
//        IDLE,
//        SHIFT_AMOUNT,
//        NORMALISE,
//        COMPUTE,
//        ASSEMBLE,
//        DONE
//    } state_t;
//    state_t state, next_state;
    
////    // Update debug_state for monitoring
////    always @(posedge clk or posedge rst) begin
////        if (rst) begin
////            debug_state <= IDLE;
////        end else begin
////            debug_state <= state;
////        end
////    end
    
//    // Sequential logic for state transition
//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            state <= IDLE;
//        end else begin
//            state <= next_state;
//        end
//    end
    
//    always @ (*) begin
//        next_state = state;
//        case (state)
//            IDLE: begin
//                if (valid_in && ready_in) next_state = SHIFT_AMOUNT;
//            end
//            SHIFT_AMOUNT: begin
//                next_state = NORMALISE;
//            end
//            NORMALISE: begin
//                next_state = COMPUTE;
//            end
//            COMPUTE: begin
//                next_state = ASSEMBLE;
//            end
//            ASSEMBLE: begin
//                next_state = DONE;
//            end
//            DONE: begin
//                if (ready_out) next_state = IDLE;
//            end
//        endcase
//    end

//    always @ (posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            state <= IDLE;
//            ready_in <= 1'b0;
//            valid_out <= 1'b0;
            
//            single <= 32'b0;
            
//            normalised <= 0;
//            exponent <= 8'b0;
//            mantissa <= 23'b0;
//            shift_amount <= 6'b0;
//            data_out <= 32'b0;
//        end
//        else begin
//            case (state)
//                IDLE: begin
//                    ready_in <= 1'b1;
//                    valid_out <= 1'b0;
//                end
//                SHIFT_AMOUNT: begin
//                    ready_in <=0;
                    
//                    if (fixed_point[(INT_WIDTH + FRACT_WIDTH - 1)] == 0) begin
//                        for (shift_amount = 0; shift_amount < (INT_WIDTH + FRACT_WIDTH); shift_amount = shift_amount + 1) begin
//                            if (fixed_point[(INT_WIDTH + FRACT_WIDTH - 1) - shift_amount] == 1'b1) begin
//                                break;
//                            end
//                        end
//                    end
//                    else begin
//                        shift_amount <= 0;
//                    end
//                end
//                NORMALISE: begin
//                    normalised <= fixed_point << shift_amount;
//                end
//                COMPUTE: begin
//                    exponent <= 127 + ((INT_WIDTH - 1) - shift_amount);
//                    mantissa <= normalised[(INT_WIDTH + FRACT_WIDTH - 2):0] << (23 - (INT_WIDTH + FRACT_WIDTH - 1));
//                end
//                ASSEMBLE: begin
//                   if (fixed_point == 0) begin
//                        single <= 32'b0;
//                    end else begin
//                        single <= {1'b0, exponent, mantissa[22:0]};
//                    end
//                end
//                DONE: begin
//                    if (ready_out) begin    // Set and validate output when ready out asserted
//                        data_out <= single;  
//                        valid_out <= 1'b1;
//                    end
//                end
//            endcase
//        end
//    end

//endmodule
