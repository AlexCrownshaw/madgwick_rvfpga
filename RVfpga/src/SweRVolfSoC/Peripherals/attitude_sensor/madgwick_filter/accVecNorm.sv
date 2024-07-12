//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2024 12:57:17
// Design Name: 
// Module Name: accVecNorm
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
`include "madgwickDefines.vh"


//module accVecNorm(
//    input wire clk,
//    input wire rst_n,
//    input wire valid_in,
//    output reg ready_in,
//    input wire [(`ACC_WIDTH*3)-1:0] data_in,
//    output reg valid_out,
//    input wire ready_out,
//    output reg [(`ACC_WIDTH*3)-1:0] data_out
    
//    // Debug
////    ,output reg valid_in_invSqrtAccNorm,
////    output reg ready_in_invSqrtAccNorm,
////    output reg [`ACC_MAG_SQR_WIDTH-1:0] data_in_invSqrtAccNorm,
////    output reg valid_out_invSqrtAccNorm,
////    output reg ready_out_invSqrtAccNorm,
////    output reg signed [`ACC_MAG_SQR_WIDTH-1:0] data_out_invSqrtAccNorm,
////    output reg [2:0] acc_norm_debug_state
//    );
    
//    wire signed [`ACC_WIDTH-1:0] a_x;
//    wire signed [`ACC_WIDTH-1:0] a_y;
//    wire signed [`ACC_WIDTH-1:0] a_z;
    
//    assign a_x = data_in[`ACC_WIDTH-1:0];
//    assign a_y = data_in[(`ACC_WIDTH*2)-1:`ACC_WIDTH];
//    assign a_z = data_in[(`ACC_WIDTH*3)-1:`ACC_WIDTH*2];
    
//    localparam ACC_NORM_INT_LSB_INDEX = `ACC_FRACT_WIDTH + `ACC_MAG_SQR_FRACT_WIDTH;
//    localparam ACC_NORM_INT_MSB_INDEX = ACC_NORM_INT_LSB_INDEX + `ACC_WIDTH - 1;
//    localparam ACC_NORM_FRACT_LSB_INDEX = ACC_NORM_INT_LSB_INDEX - `ACC_FRACT_WIDTH;
    
//    wire signed [`ACC_WIDTH-1:0] acc_norm_round_const;
//    assign acc_norm_round_const = `ACC_WIDTH'b1;
    
//    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_x_norm_temp;
//    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_y_norm_temp;
//    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_z_norm_temp;
    
//    wire signed [`ACC_WIDTH-1:0] a_x_norm;
//    wire signed [`ACC_WIDTH-1:0] a_y_norm;
//    wire signed [`ACC_WIDTH-1:0] a_z_norm; 
    
//    assign a_x_norm = a_x_norm_temp[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX] + acc_norm_round_const;
//    assign a_y_norm = a_y_norm_temp[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX] + acc_norm_round_const;
//    assign a_z_norm = a_z_norm_temp[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX] + acc_norm_round_const;
    
//    reg [(`ACC_WIDTH*2)+2:0] acc_norm_mag_sqr;
    
//    localparam ACC_MAG_SQR_INT_LSB_INDEX = (`ACC_FRACT_WIDTH * 2);
    
//    wire [(`ACC_WIDTH*2)+2:0] acc_norm_mag_sqr_round_const;
//    assign acc_norm_mag_sqr_round_const = `ACC_MAG_SQR_WIDTH'b1;
    
//    reg [`ACC_MAG_SQR_WIDTH-1:0] data_in_invSqrtAccNorm;
//    reg valid_in_invSqrtAccNorm;
//    wire ready_in_invSqrtAccNorm;
    
//    wire signed [`ACC_MAG_SQR_WIDTH-1:0] data_out_invSqrtAccNorm;
//    wire valid_out_invSqrtAccNorm;
//    reg ready_out_invSqrtAccNorm;
    
//    fastInvSqrt #(
//        .INT_WIDTH(`ACC_MAG_SQR_INT_WIDTH),
//        .FRACT_WIDTH(`ACC_MAG_SQR_FRACT_WIDTH)
//    ) invSqrtAccNorm (
//        .clk(clk),
//        .rst_n(rst_n),
//        .data_in(data_in_invSqrtAccNorm),
//        .valid_in(valid_in_invSqrtAccNorm),
//        .ready_in(ready_in_invSqrtAccNorm),
//        .data_out(data_out_invSqrtAccNorm),
//        .valid_out(valid_out_invSqrtAccNorm),
//        .ready_out(ready_out_invSqrtAccNorm)
//    );
    
//    typedef enum reg [2:0] {
//        ACC_NORM_IDLE,
//        ACC_NORM_MAG_SQR,
//        ACC_NORM_INV_SQRT_INIT,
//        ACC_NORM_INV_SQRT_DONE,
//        ACC_NORM_MULT,
//        ACC_NORM_DONE
//    } acc_norm_state_t;
//    acc_norm_state_t acc_norm_state, acc_norm_next_state;
    
////    // Debug state output
////    always @ (posedge clk or negedge rst_n) begin
////        if (!rst_n) begin
////            acc_norm_debug_state <= ACC_NORM_IDLE;
////        end else begin
////            acc_norm_debug_state <= acc_norm_state;
////        end
////    end
    
//    always @ (posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            acc_norm_state <= ACC_NORM_IDLE;
//        end else begin
//            acc_norm_state <= acc_norm_next_state;
//        end
//    end
    
//    always @ (*) begin
//        acc_norm_next_state = acc_norm_state;
//        case(acc_norm_state) 
//            ACC_NORM_IDLE: begin
//                if (valid_in && ready_in) acc_norm_next_state = ACC_NORM_MAG_SQR;
//            end
//            ACC_NORM_MAG_SQR: begin
//                acc_norm_next_state = ACC_NORM_INV_SQRT_INIT;
//            end
//            ACC_NORM_INV_SQRT_INIT: begin
//                if (valid_in_invSqrtAccNorm && ready_in_invSqrtAccNorm) acc_norm_next_state = ACC_NORM_INV_SQRT_DONE;
//            end
//            ACC_NORM_INV_SQRT_DONE: begin
//                if (valid_out_invSqrtAccNorm && ready_out_invSqrtAccNorm) acc_norm_next_state = ACC_NORM_MULT;
//            end
//            ACC_NORM_MULT: begin
//                acc_norm_next_state = ACC_NORM_DONE;
//            end
//            ACC_NORM_DONE: begin
//                if (valid_out) acc_norm_next_state = ACC_NORM_IDLE;
//            end
//        endcase
//    end
    
//    always @ (posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            ready_in <= 1'b0;   // Reset state machine signals
//            valid_out <= 1'b0;
    
//            data_in_invSqrtAccNorm <= `ACC_MAG_SQR_WIDTH'b0;    // Reset invSqrt signals
//            valid_in_invSqrtAccNorm <= 1'b0;
//            ready_out_invSqrtAccNorm <= 1'b0;
    
//            acc_norm_mag_sqr <= (`ACC_WIDTH*2)+3'b0;    // Reset internal signals   
//            a_x_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
//            a_y_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
//            a_z_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
//        end else begin
//            case(acc_norm_state)
//                ACC_NORM_IDLE: begin
//                    ready_in <= 1'b1;
//                    valid_out <= 1'b0;
//                end
//                ACC_NORM_MAG_SQR: begin
//                    ready_in <= 1'b0;
//                    acc_norm_mag_sqr <= (a_x * a_x + a_y * a_y + a_z * a_z);
//                end
//                ACC_NORM_INV_SQRT_INIT: begin
//                    data_in_invSqrtAccNorm <= acc_norm_mag_sqr[ACC_MAG_SQR_INT_LSB_INDEX+`ACC_MAG_SQR_INT_WIDTH-1:ACC_MAG_SQR_INT_LSB_INDEX-`ACC_MAG_SQR_FRACT_WIDTH] + acc_norm_mag_sqr_round_const;
//                    valid_in_invSqrtAccNorm <= 1'b1;
//                end
//                ACC_NORM_INV_SQRT_DONE: begin
//                    valid_in_invSqrtAccNorm <= 1'b0;
//                    ready_out_invSqrtAccNorm <= 1'b1;
//                end
//                ACC_NORM_MULT: begin
//                    ready_out_invSqrtAccNorm <= 1'b0;
                                        
//                    a_x_norm_temp <= (a_x * data_out_invSqrtAccNorm);
//                    a_y_norm_temp <= (a_y * data_out_invSqrtAccNorm);
//                    a_z_norm_temp <= (a_z * data_out_invSqrtAccNorm);
//                end
//                ACC_NORM_DONE: begin
//                    if (ready_out) begin    // Set and validate output when ready out asserted
//                        data_out <= {a_x_norm, a_y_norm, a_z_norm};  
//                        valid_out <= 1'b1;
//                    end
//                end
//            endcase
//        end
//    end
    
//endmodule


module accVecNorm(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg done,
    input wire [(`ACC_WIDTH*3)-1:0] data_in,
    output reg [(`ACC_WIDTH*3)-1:0] data_out
    
    // Debug
//    ,output reg valid_in_invSqrtAccNorm,
//    output reg ready_in_invSqrtAccNorm,
//    output reg [`ACC_MAG_SQR_WIDTH-1:0] data_in_invSqrtAccNorm,
//    output reg valid_out_invSqrtAccNorm,
//    output reg ready_out_invSqrtAccNorm,
//    output reg signed [`ACC_MAG_SQR_WIDTH-1:0] data_out_invSqrtAccNorm,
//    output reg [2:0] acc_norm_debug_state
    );
    
    wire signed [`ACC_WIDTH-1:0] a_x;
    wire signed [`ACC_WIDTH-1:0] a_y;
    wire signed [`ACC_WIDTH-1:0] a_z;
    
    assign a_x = data_in[`ACC_WIDTH-1:0];
    assign a_y = data_in[(`ACC_WIDTH*2)-1:`ACC_WIDTH];
    assign a_z = data_in[(`ACC_WIDTH*3)-1:`ACC_WIDTH*2];
    
    localparam ACC_NORM_INT_LSB_INDEX = `ACC_FRACT_WIDTH + `ACC_MAG_SQR_FRACT_WIDTH;
    localparam ACC_NORM_INT_MSB_INDEX = ACC_NORM_INT_LSB_INDEX + `ACC_WIDTH - 1;
    localparam ACC_NORM_FRACT_LSB_INDEX = ACC_NORM_INT_LSB_INDEX - `ACC_FRACT_WIDTH;
    
    wire signed [`ACC_WIDTH-1:0] acc_norm_round_const;
    assign acc_norm_round_const = `ACC_WIDTH'b1;
    
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_x_norm_temp;
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_y_norm_temp;
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_z_norm_temp;
    
    wire signed [`ACC_WIDTH-1:0] a_x_norm;
    wire signed [`ACC_WIDTH-1:0] a_y_norm;
    wire signed [`ACC_WIDTH-1:0] a_z_norm; 
    
    assign a_x_norm = a_x_norm_temp[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX] + acc_norm_round_const;
    assign a_y_norm = a_y_norm_temp[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX] + acc_norm_round_const;
    assign a_z_norm = a_z_norm_temp[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX] + acc_norm_round_const;
    
    reg [(`ACC_WIDTH*2)+2:0] acc_norm_mag_sqr;
    
    localparam ACC_MAG_SQR_INT_LSB_INDEX = (`ACC_FRACT_WIDTH * 2);
    
    wire [(`ACC_WIDTH*2)+2:0] acc_norm_mag_sqr_round_const;
    assign acc_norm_mag_sqr_round_const = `ACC_MAG_SQR_WIDTH'b1;
    
    reg [`ACC_MAG_SQR_WIDTH-1:0] data_in_invSqrtAccNorm;
    reg valid_in_invSqrtAccNorm;
    wire ready_in_invSqrtAccNorm;
    
    wire signed [`ACC_MAG_SQR_WIDTH-1:0] data_out_invSqrtAccNorm;
    wire valid_out_invSqrtAccNorm;
    reg ready_out_invSqrtAccNorm;
    
    fastInvSqrt #(
        .INT_WIDTH(`ACC_MAG_SQR_INT_WIDTH),
        .FRACT_WIDTH(`ACC_MAG_SQR_FRACT_WIDTH)
    ) invSqrtAccNorm (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in_invSqrtAccNorm),
        .valid_in(valid_in_invSqrtAccNorm),
        .ready_in(ready_in_invSqrtAccNorm),
        .data_out(data_out_invSqrtAccNorm),
        .valid_out(valid_out_invSqrtAccNorm),
        .ready_out(ready_out_invSqrtAccNorm)
    );
    
    typedef enum reg [2:0] {
        ACC_NORM_IDLE,
        ACC_NORM_MAG_SQR,
        ACC_NORM_INV_SQRT_INIT,
        ACC_NORM_INV_SQRT_DONE,
        ACC_NORM_MULT,
        ACC_NORM_DONE
    } acc_norm_state_t;
    acc_norm_state_t acc_norm_state, acc_norm_next_state;
    
//    // Debug state output
//    always @ (posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            acc_norm_debug_state <= ACC_NORM_IDLE;
//        end else begin
//            acc_norm_debug_state <= acc_norm_state;
//        end
//    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_norm_state <= ACC_NORM_IDLE;
        end else begin
            acc_norm_state <= acc_norm_next_state;
        end
    end
    
    always @ (*) begin
        acc_norm_next_state = acc_norm_state;
        case(acc_norm_state) 
            ACC_NORM_IDLE: begin
                if (start) acc_norm_next_state = ACC_NORM_MAG_SQR;
            end
            ACC_NORM_MAG_SQR: begin
                acc_norm_next_state = ACC_NORM_INV_SQRT_INIT;
            end
            ACC_NORM_INV_SQRT_INIT: begin
                if (valid_in_invSqrtAccNorm && ready_in_invSqrtAccNorm) acc_norm_next_state = ACC_NORM_INV_SQRT_DONE;
            end
            ACC_NORM_INV_SQRT_DONE: begin
                if (valid_out_invSqrtAccNorm && ready_out_invSqrtAccNorm) acc_norm_next_state = ACC_NORM_MULT;
            end
            ACC_NORM_MULT: begin
                acc_norm_next_state = ACC_NORM_DONE;
            end
            ACC_NORM_DONE: begin
                if (!start) acc_norm_next_state = ACC_NORM_IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;   // Reset state machine signals
    
            data_in_invSqrtAccNorm <= `ACC_MAG_SQR_WIDTH'b0;    // Reset invSqrt signals
            valid_in_invSqrtAccNorm <= 1'b0;
            ready_out_invSqrtAccNorm <= 1'b0;
    
            acc_norm_mag_sqr <= (`ACC_WIDTH*2)+3'b0;    // Reset internal signals   
            a_x_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
            a_y_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
            a_z_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
            
            data_out <= `ACC_WIDTH*3'b0;
        end else begin
            case(acc_norm_state)
                ACC_NORM_IDLE: begin
                    done <= 1'b0;
                end
                ACC_NORM_MAG_SQR: begin
                    acc_norm_mag_sqr <= (a_x * a_x + a_y * a_y + a_z * a_z);
                end
                ACC_NORM_INV_SQRT_INIT: begin
                    data_in_invSqrtAccNorm <= acc_norm_mag_sqr[ACC_MAG_SQR_INT_LSB_INDEX+`ACC_MAG_SQR_INT_WIDTH-1:ACC_MAG_SQR_INT_LSB_INDEX-`ACC_MAG_SQR_FRACT_WIDTH] + acc_norm_mag_sqr_round_const;
                    valid_in_invSqrtAccNorm <= 1'b1;
                end
                ACC_NORM_INV_SQRT_DONE: begin
                    valid_in_invSqrtAccNorm <= 1'b0;
                    ready_out_invSqrtAccNorm <= 1'b1;
                end
                ACC_NORM_MULT: begin
                    ready_out_invSqrtAccNorm <= 1'b0;
                                        
                    a_x_norm_temp <= (a_x * data_out_invSqrtAccNorm);
                    a_y_norm_temp <= (a_y * data_out_invSqrtAccNorm);
                    a_z_norm_temp <= (a_z * data_out_invSqrtAccNorm);
                end
                ACC_NORM_DONE: begin
                    data_out <= {a_x_norm, a_y_norm, a_z_norm};
                    if (start) begin
                        done <= 1'b1;
                    end else begin
                        done <= 1'b0;
                    end
                end
            endcase
        end
    end
    
endmodule
