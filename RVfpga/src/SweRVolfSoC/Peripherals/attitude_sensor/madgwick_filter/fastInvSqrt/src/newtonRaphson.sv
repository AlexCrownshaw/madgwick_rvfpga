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


module newtonRaphson #(
    parameter INT_WIDTH = 12,      // Number of integer bits
    parameter FRACT_WIDTH = 4       // Number of fractional bits 
    )    
    (
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg done,   
    input wire [INT_WIDTH+FRACT_WIDTH-1:0] x_half,
    input wire [INT_WIDTH+FRACT_WIDTH-1:0] y0,
    output wire [INT_WIDTH+FRACT_WIDTH-1:0] y
    
//    ,output reg [((INT_WIDTH+FRACT_WIDTH)*3)-1:0] one_point_five,
//    output reg [((INT_WIDTH+FRACT_WIDTH)*3)-1:0] A,
//    output reg [((INT_WIDTH+FRACT_WIDTH)*3):0] B,
//    output reg [((INT_WIDTH+FRACT_WIDTH)*4)-1:0] C,
//    output reg [((INT_WIDTH+FRACT_WIDTH)*4):0] y_temp,
//    output reg [(INT_WIDTH+FRACT_WIDTH)*4:0] round_const
    );
    
    localparam WORD_WIDTH = INT_WIDTH + FRACT_WIDTH;
    localparam INT_LSB_INDEX = FRACT_WIDTH * 4;
    localparam INT_MSB_INDEX = INT_LSB_INDEX + INT_WIDTH-1;
    localparam FRACT_LSB_INDEX = INT_LSB_INDEX - FRACT_WIDTH;
    
    wire [(WORD_WIDTH*3)-1:0] one_point_five;
    assign one_point_five = (1 << (FRACT_WIDTH * 3)) + (1 << ((FRACT_WIDTH * 3) - 1)); // 1.5 in fixed-point

    reg [(WORD_WIDTH*3)-1:0] A;
    reg [(WORD_WIDTH*4):0] y_temp;
    
    wire [(WORD_WIDTH*4)+1:0] y_rounded;
    wire [WORD_WIDTH*4:0] round_const;
    assign round_const = 1'b1 << (FRACT_LSB_INDEX - 1);
    assign y_rounded = y_temp + round_const;
    
    assign y = y_rounded[INT_MSB_INDEX: FRACT_LSB_INDEX];
    
    typedef enum reg [1:0] {
        IDLE,
        STATE_1,
        STATE_2,
        DONE
    } state_t;
    state_t state, next_state;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) next_state = STATE_1;
            end
            STATE_1: begin
                next_state = STATE_2;
            end
            STATE_2: begin
                next_state = DONE;
            end
            DONE: begin
                if (!start) next_state = IDLE;
            end
        endcase
    end
    
    always @ (posedge clk) begin
        if (!rst_n) begin
            done <= 1'b0;
            
            A <= 0;
            y_temp <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                end
                STATE_1: begin
                    A <= x_half * y0 * y0;
                end
                STATE_2: begin
                    y_temp <= y0 * (one_point_five - A);
                end
                DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
    
endmodule


//module newtonRaphson #(
//    parameter INT_WIDTH = 12,      // Number of integer bits
//    parameter FRACT_WIDTH = 4       // Number of fractional bits 
//    )    
//    (    
//    input wire [INT_WIDTH+FRACT_WIDTH-1:0] x_half,
//    input wire [INT_WIDTH+FRACT_WIDTH-1:0] y0,
//    output reg [INT_WIDTH+FRACT_WIDTH-1:0] y
    
////    ,output reg [((INT_WIDTH+FRACT_WIDTH)*3)-1:0] one_point_five,
////    output reg [((INT_WIDTH+FRACT_WIDTH)*3)-1:0] A,
////    output reg [((INT_WIDTH+FRACT_WIDTH)*3):0] B,
////    output reg [((INT_WIDTH+FRACT_WIDTH)*4)-1:0] C,
////    output reg [((INT_WIDTH+FRACT_WIDTH)*4):0] y_temp,
////    output reg [(INT_WIDTH+FRACT_WIDTH)*4:0] round_const
//    );
    
//    localparam WORD_WIDTH = INT_WIDTH + FRACT_WIDTH;
//    localparam INT_LSB_INDEX = FRACT_WIDTH * 4;

//    reg [(WORD_WIDTH*3)-1:0] A;
//    reg [(WORD_WIDTH*3):0] B;
//    reg [(WORD_WIDTH*4)-1:0] C;
//    reg [(WORD_WIDTH*4):0] y_temp;
    
//    wire [(WORD_WIDTH*3)-1:0] one_point_five;
//    assign one_point_five = (1 << (FRACT_WIDTH * 3)) + (1 << ((FRACT_WIDTH * 3) - 1)); // 1.5 in fixed-point
    
//    wire [WORD_WIDTH*4:0] round_const;
//    assign round_const = (1 << (FRACT_WIDTH * 3) - 1);
    
//    always @ (y0) begin
//        A = x_half * y0 * y0;
//        B = (one_point_five - A);
//        C = (y0 * B);
        
//        if (C[INT_LSB_INDEX+INT_WIDTH-1:INT_LSB_INDEX-FRACT_WIDTH] == {WORD_WIDTH{1'b1}}) begin
//            y_temp = {1'b0, C};
//        end else begin
//            y_temp = C  + round_const;
//        end
        
//        y = y_temp[INT_LSB_INDEX+INT_WIDTH-1:INT_LSB_INDEX-FRACT_WIDTH];
//    end
    
//endmodule
