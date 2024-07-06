//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2024 14:44:56
// Design Name: 
// Module Name: madgwick
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


module madgwick (
    input wire clk,
    input wire rst_n,
    
    // ---- Input signals - Start ----
    
    input wire valid_in,
    output reg ready_in,
    input wire signed [`ACC_WIDTH-1:0] a_x, // Acceleration vector input signals
    input wire signed [`ACC_WIDTH-1:0] a_y,
    input wire signed [`ACC_WIDTH-1:0] a_z,
    input wire signed [`GYRO_WIDTH-1:0] w_x,    // Gyro rate vector input signals
    input wire signed [`GYRO_WIDTH-1:0] w_y,
    input wire signed [`GYRO_WIDTH-1:0] w_z,
    
    // ---- Input signals - End ----
    
    // ---- Attitude quaternion output signals - Start ----
    
    output reg valid_out,
    input wire ready_out,
    output reg signed [`Q_WIDTH-1:0] q_w,
    output reg signed [`Q_WIDTH-1:0] q_x,
    output reg signed [`Q_WIDTH-1:0] q_y,
    output reg signed [`Q_WIDTH-1:0] q_z
    
    // ---- Attitude quaternion output signals - End ----
    
    // ---- Debug I/O - Start ----
    
    ,output wire signed [`Q_HALF_WIDTH-1:0] q_w_half,    // pre-compute signals
    output wire signed [`Q_HALF_WIDTH-1:0] q_x_half,
    output wire signed [`Q_HALF_WIDTH-1:0] q_y_half,
    output wire signed [`Q_HALF_WIDTH-1:0] q_z_half,
    output wire signed [`Q_TWO_WIDTH-1:0] q_w_two,
    output wire signed [`Q_TWO_WIDTH-1:0] q_x_two,
    output wire signed [`Q_TWO_WIDTH-1:0] q_y_two,
    output wire signed [`Q_TWO_WIDTH-1:0] q_z_two
    
    ,output wire signed [`J_11_24_WIDTH-1:0] j_11_24, // Jacobian
    output wire signed [`J_12_23_WIDTH-1:0] j_12_23,
    output wire signed [`J_13_22_WIDTH-1:0] j_13_22,
    output wire signed [`J_14_21_WIDTH-1:0] j_14_21,
    output wire signed [`J_32_WIDTH-1:0] j_32,
    output wire signed [`J_33_WIDTH-1:0] j_33
    
    ,wire signed [`ACC_WIDTH-1:0] a_x_norm, // Acc Norm
    wire signed [`ACC_WIDTH-1:0] a_y_norm,
    wire signed [`ACC_WIDTH-1:0] a_z_norm
    ,output reg start_acc_vec_norm,
    output reg done_acc_vec_norm

    ,output reg signed [`Q_DOT_WIDTH-1:0] q_dot_w,  // q_dot
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_x,
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_y,
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_z,
    output reg start_q_dot,
    output reg done_q_dot
    
    // ---- Debug I/O - End ----
    );
    
    // ---- Internal pre-compute signals - Start ----   
    
//    wire signed [`Q_HALF_WIDTH-1:0] q_w_half;
//    wire signed [`Q_HALF_WIDTH-1:0] q_x_half;
//    wire signed [`Q_HALF_WIDTH-1:0] q_y_half;
//    wire signed [`Q_HALF_WIDTH-1:0] q_z_half;
    
    assign q_w_half = q_w >>> 1;
    assign q_x_half = q_x >>> 1;
    assign q_y_half = q_y >>> 1;
    assign q_z_half = q_z >>> 1;
    
//    wire signed [`Q_TWO_WIDTH-1:0] q_w_two;
//    wire signed [`Q_TWO_WIDTH-1:0] q_x_two;
//    wire signed [`Q_TWO_WIDTH-1:0] q_y_two;
//    wire signed [`Q_TWO_WIDTH-1:0] q_z_two;
    
    assign q_w_two = q_w <<< 1;
    assign q_x_two = q_x <<< 1;
    assign q_y_two = q_y <<< 1;
    assign q_z_two = q_z <<< 1;
    
    // ---- Internal pre-compute signals - End ----   
    
    // ---- Jacobian matrix elements - Start ----
    
//    wire signed [`J_11_24_WIDTH-1:0] j_11_24;
//    wire signed [`J_12_23_WIDTH-1:0] j_12_23;
//    wire signed [`J_13_22_WIDTH-1:0] j_13_22;
//    wire signed [`J_14_21_WIDTH-1:0] j_14_21;
//    wire signed [`J_32_WIDTH-1:0] j_32;
//    wire signed [`J_33_WIDTH-1:0] j_33;
    
    assign j_11_24 = q_y_two;
    assign j_12_23 = q_z <<< 1;
    assign j_13_22 = q_w_two;
    assign j_14_21 = q_x_two;
    assign j_32 = j_14_21 <<< 1;
    assign j_33 = j_11_24 <<< 1;
    
    // ---- Jacobian matrix - End ----
    
    // ---- Acceleration vector normalisation - Start ----
    
//    reg start_acc_vec_norm;
//    wire done_acc_vec_norm;
    wire [(`ACC_WIDTH*3)-1:0] data_in_acc_vec_norm;
    reg [(`ACC_WIDTH*3)-1:0] data_out_acc_vec_norm;
    
    assign data_in_acc_vec_norm = {a_x, a_y, a_z};
    
//    wire signed [`ACC_WIDTH-1:0] a_x_norm;
//    wire signed [`ACC_WIDTH-1:0] a_y_norm;
//    wire signed [`ACC_WIDTH-1:0] a_z_norm; 
    
    assign a_x_norm = data_out_acc_vec_norm[`ACC_WIDTH-1:0];
    assign a_y_norm = data_out_acc_vec_norm[(`ACC_WIDTH*2)-1:`ACC_WIDTH];
    assign a_z_norm = data_out_acc_vec_norm[(`ACC_WIDTH*3)-1:`ACC_WIDTH*2];
        
    accVecNorm acc_vec_norm (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_acc_vec_norm),
        .done(done_acc_vec_norm),
        .data_in(data_in_acc_vec_norm),
        .data_out(data_out_acc_vec_norm)
    );
    
    // ---- Acceleration vector normalisation - End ----
    
    // ---- Gyro quaternion derivative - Start ----
    
//    reg start_q_dot;
//    reg done_q_dot;
    
//    reg signed [`Q_DOT_WIDTH-1:0] q_dot_w;
//    reg signed [`Q_DOT_WIDTH-1:0] q_dot_x;
//    reg signed [`Q_DOT_WIDTH-1:0] q_dot_y;
//    reg signed [`Q_DOT_WIDTH-1:0] q_dot_z;
    
    typedef enum reg [2:0] {
        Q_DOT_IDLE,
        Q_DOT_W,
        Q_DOT_X,
        Q_DOT_Y,
        Q_DOT_Z,
        Q_DOT_DONE
    } q_dot_state_t;
    q_dot_state_t q_dot_state, q_dot_next_state;
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q_dot_state <= Q_DOT_IDLE;
        end else begin
            q_dot_state <= q_dot_next_state;
        end
    end
    
    always @ (*) begin
        q_dot_next_state = q_dot_state;
        case(q_dot_state) 
            Q_DOT_IDLE: begin
                if (start_q_dot) q_dot_next_state = Q_DOT_W;
            end
            Q_DOT_W: begin
                q_dot_next_state = Q_DOT_X;
            end
            Q_DOT_X: begin
                q_dot_next_state = Q_DOT_Y;
            end
            Q_DOT_Y: begin
                q_dot_next_state = Q_DOT_Z;
            end
            Q_DOT_Z: begin
                q_dot_next_state = Q_DOT_DONE;
            end
            Q_DOT_DONE: begin
                if (!start_q_dot) q_dot_next_state = Q_DOT_IDLE;
            end
        endcase
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            done_q_dot <= 1'b0;
            
            q_dot_w <= `Q_DOT_WIDTH'b0;
            q_dot_x <= `Q_DOT_WIDTH'b0;
            q_dot_y <= `Q_DOT_WIDTH'b0;
            q_dot_z <= `Q_DOT_WIDTH'b0;
        end else begin
            case(q_dot_state)
                Q_DOT_IDLE: begin
                    done_q_dot <= 1'b0;
                end
                Q_DOT_W: begin
                    q_dot_w <= -q_x_half * w_x - q_y_half * w_y - q_z_half * w_z;
                end
                Q_DOT_X: begin
                    q_dot_x <= q_w_half * w_x + q_y_half * w_z - q_z_half * w_y;
                end
                Q_DOT_Y: begin
                    q_dot_y <= q_w_half * w_y - q_x_half * w_z + q_z_half * w_x;
                end
                Q_DOT_Z: begin
                    q_dot_z <= q_w_half * w_z + q_x_half * w_y - q_y_half * w_x;
                end
                Q_DOT_DONE: begin
                    if (start_q_dot) begin
                        done_q_dot <= 1'b1;
                    end else begin
                        done_q_dot <= 1'b0;
                    end
                end
            endcase
        end
    end
    
    // ---- Gyro quaternion derivative - End ----
    
    // ---- Objective function - Start ----
    
    
    
    // ---- Objective function - End ----
    
    // ---- Control path state machine - Start ----
    
    typedef enum reg [2:0] {
        IDLE,
        STATE_1_START,
        STATE_1_DONE,
        Q_OUTPUT
    } state_t;
    state_t state, next_state;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always @ (*) begin
        next_state = state;
        case(state)
            IDLE: begin
                if (valid_in && ready_in) next_state = STATE_1_START;
            end
            STATE_1_START: begin
                next_state = STATE_1_DONE;
            end
            STATE_1_DONE: begin
                if (done_acc_vec_norm && done_q_dot && !start_acc_vec_norm && !start_q_dot) next_state = Q_OUTPUT;
            end
            Q_OUTPUT: begin
                if (valid_out && ready_out) next_state = IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_in <= 1'b0;  // De-assert input ready signal
            
            q_w <= `Q_WIDTH'b1 << `Q_FRACT_WIDTH;    // Reset output signals 
            q_x <= `Q_WIDTH'b0;
            q_y <= `Q_WIDTH'b0;
            q_z <= `Q_WIDTH'b0;
            valid_out <= 1'b0;
            
            start_acc_vec_norm <= 1'b0; // Reset state machine control signals
            start_q_dot <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    ready_in <= 1'b1;
                    valid_out <= 1'b0; 
                end
                STATE_1_START: begin
                    ready_in <= 1'b0;
                    
                    start_acc_vec_norm <= 1'b1;
                    start_q_dot <= 1'b1;
                end
                STATE_1_DONE: begin
                    if (done_acc_vec_norm && done_q_dot) begin
                        start_acc_vec_norm <= 1'b0;
                        start_q_dot <= 1'b0;
                    end
                end
                Q_OUTPUT: begin
                    valid_out <= 1'b1;
                end
            endcase
        end
    end
    
    // ---- Control path state machine - End ----
    
endmodule
