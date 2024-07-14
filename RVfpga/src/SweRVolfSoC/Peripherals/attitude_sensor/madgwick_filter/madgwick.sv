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
    output reg signed [`Q_WIDTH-1:0] q_w_norm_output,
    output reg signed [`Q_WIDTH-1:0] q_x_norm_output,
    output reg signed [`Q_WIDTH-1:0] q_y_norm_output,
    output reg signed [`Q_WIDTH-1:0] q_z_norm_output
    
    // ---- Attitude quaternion output signals - End ----
    
    // ---- Debug I/O - Start ----
    
    ,output wire signed [`Q_HALF_WIDTH-1:0] q_w_half_debug,    // pre-compute signals
    output wire signed [`Q_HALF_WIDTH-1:0] q_x_half_debug,
    output wire signed [`Q_HALF_WIDTH-1:0] q_y_half_debug,
    output wire signed [`Q_HALF_WIDTH-1:0] q_z_half_debug,
    output wire signed [`Q_TWO_WIDTH-1:0] q_w_two_debug,
    output wire signed [`Q_TWO_WIDTH-1:0] q_x_two_debug,
    output wire signed [`Q_TWO_WIDTH-1:0] q_y_two_debug,
    output wire signed [`Q_TWO_WIDTH-1:0] q_z_two_debug
    
    ,output wire signed [`JACOBIAN_WIDTH-1:0] j_11_24_debug, // Jacobian
    output wire signed [`JACOBIAN_WIDTH-1:0] j_12_23_debug,
    output wire signed [`JACOBIAN_WIDTH-1:0] j_13_22_debug,
    output wire signed [`JACOBIAN_WIDTH-1:0] j_14_21_debug,
    output wire signed [`JACOBIAN_WIDTH:0] j_32_debug,
    output wire signed [`JACOBIAN_WIDTH:0] j_33_debug
    
    ,wire signed [`ACC_WIDTH-1:0] a_x_norm_debug, // Acc Norm
    wire signed [`ACC_WIDTH-1:0] a_y_norm_debug,
    wire signed [`ACC_WIDTH-1:0] a_z_norm_debug
    ,output reg start_acc_vec_norm_debug,
    output reg done_acc_vec_norm_debug

    ,output reg signed [`Q_DOT_WIDTH-1:0] q_dot_w_debug,  // q_dot
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_x_debug,
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_y_debug,
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_z_debug,
    output reg signed [`Q_HALF_WIDTH-1:0] q_w_half_q_dot_debug,
    output reg signed [`Q_HALF_WIDTH-1:0] q_x_half_q_dot_debug,
    output reg signed [`Q_HALF_WIDTH-1:0] q_y_half_q_dot_debug,
    output reg signed [`Q_HALF_WIDTH-1:0] q_z_half_q_dot_debug,
    output reg  signed [`Q_HALF_WIDTH:0] q_w_half_q_dot_rounded_debug,
    output reg  signed [`Q_HALF_WIDTH:0] q_x_half_q_dot_rounded_debug,
    output reg  signed [`Q_HALF_WIDTH:0] q_y_half_q_dot_rounded_debug,
    output reg  signed [`Q_HALF_WIDTH:0] q_z_half_q_dot_rounded_debug,
    output reg start_q_dot_debug,
    output reg done_q_dot_debug
    
    ,output reg signed [`OBJ_FUNC_WIDTH-1:0] f1_debug,    // Obj func
    output reg signed [`OBJ_FUNC_WIDTH-1:0] f2_debug,
    output reg signed [`OBJ_FUNC_WIDTH:0] f3_debug,
    output reg signed [`Q_TWO_WIDTH-1:0] q_w_two_obj_func_debug,
    output reg signed [`Q_TWO_WIDTH-1:0] q_x_two_obj_func_debug,
    output reg signed [`Q_TWO_WIDTH-1:0] q_y_two_obj_func_debug,
    output reg signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_x_norm_obj_func_debug,
    output reg signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_y_norm_obj_func_debug,
    output reg signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_z_norm_obj_func_debug,
    output reg start_obj_func_debug,
    output reg done_obj_func_debug
    
    ,output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_w_debug,  // Err grad
    output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_x_debug,
    output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_y_debug,
    output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_z_debug,
    output reg signed [(`OBJ_FUNC_WIDTH+`JACOBIAN_WIDTH+1)-1:0] q_hat_dot_w_temp_debug,
    output reg signed [(`OBJ_FUNC_WIDTH+`JACOBIAN_WIDTH+1)+1:0] q_hat_dot_x_temp_debug,
    output reg signed [(`OBJ_FUNC_WIDTH+`JACOBIAN_WIDTH+1)+2:0] q_hat_dot_y_temp_debug,
    output reg signed [(`OBJ_FUNC_WIDTH+`JACOBIAN_WIDTH+1)-1:0] q_hat_dot_z_temp_debug,
    output reg start_err_grad_debug,
    output reg done_err_grad_debug
    
    ,output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_w_norm_debug, // Err grad norm 
    output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_x_norm_debug, 
    output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_y_norm_debug, 
    output reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_z_norm_debug,
    output reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_w_norm_temp_debug,
    output reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_x_norm_temp_debug,
    output reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_y_norm_temp_debug,
    output reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_z_norm_temp_debug,
    output reg [(`Q_HAT_DOT_WIDTH*2)+2:0] q_hat_dot_mag_sqr_debug,
//    output reg [(`Q_HAT_DOT_WIDTH*4)-1:0] data_in_err_grad_norm_debug,
//    output reg [(`Q_HAT_DOT_WIDTH*4)-1:0] data_out_err_grad_norm_debug,
    output reg start_err_grad_norm_debug,
    output reg done_err_grad_norm_debug
    
    ,output reg signed [`BETA_WIDTH-1:0] beta_debug,    // Quat int
    output reg signed [`DELTA_T_WIDTH-1:0] delta_t_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_w_quat_int_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_x_quat_int_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_y_quat_int_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_z_quat_int_debug,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_w_quat_int_debug,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_x_quat_int_debug,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_y_quat_int_debug,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_z_quat_int_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_w_temp_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_x_temp_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_y_temp_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_z_temp_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_round_const_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_w_rounded_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_x_rounded_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_y_rounded_debug,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_z_rounded_debug,
    output reg signed [`Q_WIDTH-1:0] q_w_debug,
    output reg signed [`Q_WIDTH-1:0] q_x_debug,
    output reg signed [`Q_WIDTH-1:0] q_y_debug,
    output reg signed [`Q_WIDTH-1:0] q_z_debug,
    output reg start_quat_int_debug,
    output reg done_quat_int_debug
    
    ,output reg signed [`Q_WIDTH-1:0] q_w_norm_debug, // Quat norm
    output reg signed [`Q_WIDTH-1:0] q_x_norm_debug,
    output reg signed [`Q_WIDTH-1:0] q_y_norm_debug,
    output reg signed [`Q_WIDTH-1:0] q_z_norm_debug,
    output reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_w_norm_temp_debug,
    output reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_x_norm_temp_debug,
    output reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_y_norm_temp_debug,
    output reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_z_norm_temp_debug,
    output reg start_quat_norm_debug,
    output reg done_quat_norm_debug
    
    // ---- Debug I/O - End ----
    );
    
    // ---- Internal pre-compute signals - Start ----   
    
    reg signed [`Q_WIDTH-1:0] q_w_norm;
    reg signed [`Q_WIDTH-1:0] q_x_norm;
    reg signed [`Q_WIDTH-1:0] q_y_norm;
    reg signed [`Q_WIDTH-1:0] q_z_norm;
    
    wire signed [`Q_HALF_WIDTH-1:0] q_w_half;
    wire signed [`Q_HALF_WIDTH-1:0] q_x_half;
    wire signed [`Q_HALF_WIDTH-1:0] q_y_half;
    wire signed [`Q_HALF_WIDTH-1:0] q_z_half;
    
    assign q_w_half = q_w_norm >>> 1;
    assign q_x_half = q_x_norm >>> 1;
    assign q_y_half = q_y_norm >>> 1;
    assign q_z_half = q_z_norm >>> 1;
    
    wire signed [`Q_TWO_WIDTH-1:0] q_w_two;
    wire signed [`Q_TWO_WIDTH-1:0] q_x_two;
    wire signed [`Q_TWO_WIDTH-1:0] q_y_two;
    wire signed [`Q_TWO_WIDTH-1:0] q_z_two;
    
    assign q_w_two = q_w_norm <<< 1;
    assign q_x_two = q_x_norm <<< 1;
    assign q_y_two = q_y_norm <<< 1;
    assign q_z_two = q_z_norm <<< 1;
    
    // ---- Internal pre-compute signals - End ----   
    
    // ---- Jacobian matrix elements - Start ----
    
    wire signed [`JACOBIAN_WIDTH-1:0] j_11_24;
    wire signed [`JACOBIAN_WIDTH-1:0] j_12_23;
    wire signed [`JACOBIAN_WIDTH-1:0] j_13_22;
    wire signed [`JACOBIAN_WIDTH-1:0] j_14_21;
    wire signed [`JACOBIAN_WIDTH:0] j_32;
    wire signed [`JACOBIAN_WIDTH:0] j_33;
    
    assign j_11_24 = q_y_two;
    assign j_12_23 = q_z_norm <<< 1;
    assign j_13_22 = q_w_two;
    assign j_14_21 = q_x_two;
    assign j_32 = j_14_21 <<< 1;
    assign j_33 = j_11_24 <<< 1;
    
    // ---- Jacobian matrix - End ----
    
    // ---- Acceleration vector normalisation - Start ----

    reg start_acc_vec_norm;
    reg done_acc_vec_norm;

    // Magnitude squared registers
    localparam ACC_MAG_SQR_INT_LSB_INDEX = (`ACC_FRACT_WIDTH * 2);
    localparam ACC_MAG_SQR_INT_MSB_INDEX = ACC_MAG_SQR_INT_LSB_INDEX + `ACC_MAG_SQR_INT_WIDTH - 1;
    localparam ACC_MAG_SQR_FRACT_LSB_INDEX = ACC_MAG_SQR_INT_LSB_INDEX - `ACC_MAG_SQR_FRACT_WIDTH;
    
    reg [(`ACC_WIDTH*2)+2:0] acc_norm_mag_sqr;
    
    wire [(`ACC_WIDTH*2)+2:0] acc_norm_mag_sqr_round_const;
    assign acc_norm_mag_sqr_round_const = 1'b1 << (ACC_MAG_SQR_FRACT_LSB_INDEX - 1);
    
    reg [(`ACC_WIDTH*2)+3:0] acc_norm_mag_sqr_rounded;
    assign acc_norm_mag_sqr_rounded = acc_norm_mag_sqr + acc_norm_mag_sqr_round_const;
    
    // Normalised registers
    localparam ACC_NORM_INT_LSB_INDEX = `ACC_FRACT_WIDTH + `ACC_MAG_SQR_FRACT_WIDTH;
    localparam ACC_NORM_INT_MSB_INDEX = ACC_NORM_INT_LSB_INDEX + `ACC_WIDTH - 1;
    localparam ACC_NORM_FRACT_LSB_INDEX = ACC_NORM_INT_LSB_INDEX - `ACC_FRACT_WIDTH;
    
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_x_norm_temp;
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_y_norm_temp;
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] a_z_norm_temp;
    
    wire signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH)-1:0] acc_norm_round_const;
    assign acc_norm_round_const = 1'b1 << (ACC_NORM_FRACT_LSB_INDEX - 1);
    
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH):0] a_x_norm_rounded;
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH):0] a_y_norm_rounded;
    reg signed [(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH):0] a_z_norm_rounded;
    
    assign a_x_norm_rounded = a_x_norm_temp + acc_norm_round_const;
    assign a_y_norm_rounded = a_y_norm_temp + acc_norm_round_const;
    assign a_z_norm_rounded = a_z_norm_temp + acc_norm_round_const;
    
    wire signed [`ACC_WIDTH-1:0] a_x_norm;
    wire signed [`ACC_WIDTH-1:0] a_y_norm;
    wire signed [`ACC_WIDTH-1:0] a_z_norm; 
    
    assign a_x_norm = a_x_norm_rounded[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX];
    assign a_y_norm = a_y_norm_rounded[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX];
    assign a_z_norm = a_z_norm_rounded[ACC_NORM_INT_MSB_INDEX: ACC_NORM_FRACT_LSB_INDEX];
    
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
                if (start_acc_vec_norm) acc_norm_next_state = ACC_NORM_MAG_SQR;
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
                if (!start_acc_vec_norm) acc_norm_next_state = ACC_NORM_IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_acc_vec_norm <= 1'b0;   // Reset state machine signals
    
            data_in_invSqrtAccNorm <= `ACC_MAG_SQR_WIDTH'b0;    // Reset invSqrt signals
            valid_in_invSqrtAccNorm <= 1'b0;
            ready_out_invSqrtAccNorm <= 1'b0;
    
            acc_norm_mag_sqr <= (`ACC_WIDTH*2)+3'b0;    // Reset internal signals   
            a_x_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
            a_y_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
            a_z_norm_temp <= {(`ACC_WIDTH+`ACC_MAG_SQR_WIDTH){1'b0}};
        end else begin
            case(acc_norm_state)
                ACC_NORM_IDLE: begin
                    done_acc_vec_norm <= 1'b0;
                end
                ACC_NORM_MAG_SQR: begin
                    acc_norm_mag_sqr <= (a_x * a_x + a_y * a_y + a_z * a_z);
                end
                ACC_NORM_INV_SQRT_INIT: begin
                    data_in_invSqrtAccNorm <= acc_norm_mag_sqr_rounded[ACC_MAG_SQR_INT_MSB_INDEX:ACC_MAG_SQR_FRACT_LSB_INDEX];
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
                    if (start_acc_vec_norm) begin
                        done_acc_vec_norm <= 1'b1;
                    end else begin
                        done_acc_vec_norm <= 1'b0;
                    end
                end
            endcase
        end
    end
    
    // ---- Acceleration vector normalisation - End ----
    
    // ---- Gyro quaternion derivative - Start ----
    
    reg start_q_dot;
    reg done_q_dot;
    
    reg signed [`Q_DOT_WIDTH-1:0] q_dot_w;
    reg signed [`Q_DOT_WIDTH-1:0] q_dot_x;
    reg signed [`Q_DOT_WIDTH-1:0] q_dot_y;
    reg signed [`Q_DOT_WIDTH-1:0] q_dot_z;

    localparam Q_HALF_Q_DOT_BIT_SHIFT = `Q_HALF_FRACT_WIDTH - `GYRO_FRACT_WIDTH;

    wire signed [`Q_HALF_WIDTH-1:0] q_w_half_q_dot;
    wire signed [`Q_HALF_WIDTH-1:0] q_x_half_q_dot;
    wire signed [`Q_HALF_WIDTH-1:0] q_y_half_q_dot;
    wire signed [`Q_HALF_WIDTH-1:0] q_z_half_q_dot;
    
    wire signed [`Q_HALF_WIDTH:0] q_w_half_q_dot_rounded;
    wire signed [`Q_HALF_WIDTH:0] q_x_half_q_dot_rounded;
    wire signed [`Q_HALF_WIDTH:0] q_y_half_q_dot_rounded;
    wire signed [`Q_HALF_WIDTH:0] q_z_half_q_dot_rounded;
    
    wire signed [`Q_HALF_WIDTH:0] q_half_q_dot_round_const; 
    assign q_half_q_dot_round_const = 1'b1 << (Q_HALF_Q_DOT_BIT_SHIFT - 1);
    
    assign q_w_half_q_dot_rounded = q_w_half + q_half_q_dot_round_const;
    assign q_x_half_q_dot_rounded = q_x_half + q_half_q_dot_round_const;
    assign q_y_half_q_dot_rounded = q_y_half + q_half_q_dot_round_const;
    assign q_z_half_q_dot_rounded = q_z_half + q_half_q_dot_round_const;
    
    assign q_w_half_q_dot = q_w_half_q_dot_rounded >>> Q_HALF_Q_DOT_BIT_SHIFT;
    assign q_x_half_q_dot = q_x_half_q_dot_rounded >>> Q_HALF_Q_DOT_BIT_SHIFT;
    assign q_y_half_q_dot = q_y_half_q_dot_rounded >>> Q_HALF_Q_DOT_BIT_SHIFT;
    assign q_z_half_q_dot = q_z_half_q_dot_rounded >>> Q_HALF_Q_DOT_BIT_SHIFT;
    
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
                    q_dot_w <= -q_x_half_q_dot * w_x - q_y_half_q_dot * w_y - q_z_half_q_dot * w_z;
                end
                Q_DOT_X: begin
                    q_dot_x <= q_w_half_q_dot * w_x + q_y_half_q_dot * w_z - q_z_half_q_dot * w_y;
                end
                Q_DOT_Y: begin
                    q_dot_y <= q_w_half_q_dot * w_y - q_x_half_q_dot * w_z + q_z_half_q_dot * w_x;
                end
                Q_DOT_Z: begin
                    q_dot_z <= q_w_half_q_dot * w_z + q_x_half_q_dot * w_y - q_y_half_q_dot * w_x;
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
    
    reg start_obj_func;
    reg done_obj_func;
    
    reg signed [`OBJ_FUNC_WIDTH-1:0] f1;
    reg signed [`OBJ_FUNC_WIDTH-1:0] f2;
    reg signed [`OBJ_FUNC_WIDTH:0] f3;

    localparam Q_TWO_OBJ_FUNC_BIT_SHIFT = `Q_TWO_FRACT_WIDTH - `Q_FRACT_WIDTH;

    wire signed [`Q_TWO_WIDTH-1:0] q_w_two_obj_func;
    wire signed [`Q_TWO_WIDTH-1:0] q_x_two_obj_func;
    wire signed [`Q_TWO_WIDTH-1:0] q_y_two_obj_func;
        
    assign q_w_two_obj_func = q_w_two >>> Q_TWO_OBJ_FUNC_BIT_SHIFT;
    assign q_x_two_obj_func = q_x_two >>> Q_TWO_OBJ_FUNC_BIT_SHIFT;
    assign q_y_two_obj_func = q_y_two >>> Q_TWO_OBJ_FUNC_BIT_SHIFT;
    
    localparam ACC_NORM_OBJ_FUNC_BIT_SHIFT = (`Q_FRACT_WIDTH + `Q_TWO_FRACT_WIDTH) - `ACC_FRACT_WIDTH;

    wire signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_x_norm_obj_func;
    wire signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_y_norm_obj_func;
    wire signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_z_norm_obj_func;
    
    assign a_x_norm_obj_func = a_x_norm <<< ACC_NORM_OBJ_FUNC_BIT_SHIFT;
    assign a_y_norm_obj_func = a_y_norm <<< ACC_NORM_OBJ_FUNC_BIT_SHIFT;
    assign a_z_norm_obj_func = a_z_norm <<< ACC_NORM_OBJ_FUNC_BIT_SHIFT;
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_obj_func <= 0;
            
            f1 <= `OBJ_FUNC_WIDTH'b0;
            f2 <= `OBJ_FUNC_WIDTH'b0;
            f3 <= `OBJ_FUNC_WIDTH'b0;
        end else begin
            if (start_obj_func && !done_obj_func) begin
                f1 <= q_x_two_obj_func * q_z_norm - q_w_two_obj_func * q_y_norm - a_x_norm_obj_func;
                f2 <= q_w_two_obj_func * q_x_norm + q_y_two_obj_func * q_z_norm - a_y_norm_obj_func;
                f3 <= (1'b1 << `Q_FRACT_WIDTH+`Q_TWO_FRACT_WIDTH) - q_x_two_obj_func * q_x_norm - q_y_two_obj_func * q_y_norm - a_z_norm_obj_func;
                done_obj_func <= 1'b1;
            end else begin
                done_obj_func <= 1'b0;
            end
        end
    end
    
    // ---- Objective function - End ----
    
    // ---- Error gradient - Start ----
    
    localparam Q_HAT_DOT_TEMP_WIDTH = `OBJ_FUNC_WIDTH + `JACOBIAN_WIDTH + 1;
    
    reg start_err_grad;
    reg done_err_grad;
    
    reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_w;
    reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_x;
    reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_y;
    reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_z;

    localparam Q_HAT_DOT_INT_LSB_INDEX = `JACOBIAN_FRACT_WIDTH * 2;
    localparam Q_HAT_DOT_INT_MSB_INDEX = Q_HAT_DOT_INT_LSB_INDEX + `Q_HAT_DOT_INT_WIDTH - 1;
    localparam Q_HAT_DOT_FRACT_LSB_INDEX = Q_HAT_DOT_INT_LSB_INDEX - `Q_HAT_DOT_FRACT_WIDTH;

    reg signed [Q_HAT_DOT_TEMP_WIDTH-1:0] q_hat_dot_w_temp;
    reg signed [Q_HAT_DOT_TEMP_WIDTH+1:0] q_hat_dot_x_temp;
    reg signed [Q_HAT_DOT_TEMP_WIDTH+2:0] q_hat_dot_y_temp;
    reg signed [Q_HAT_DOT_TEMP_WIDTH-1:0] q_hat_dot_z_temp;
    
    assign q_hat_dot_w = q_hat_dot_w_temp[Q_HAT_DOT_INT_MSB_INDEX:Q_HAT_DOT_FRACT_LSB_INDEX];
    assign q_hat_dot_x = q_hat_dot_x_temp[Q_HAT_DOT_INT_MSB_INDEX:Q_HAT_DOT_FRACT_LSB_INDEX];
    assign q_hat_dot_y = q_hat_dot_y_temp[Q_HAT_DOT_INT_MSB_INDEX:Q_HAT_DOT_FRACT_LSB_INDEX];
    assign q_hat_dot_z = q_hat_dot_z_temp[Q_HAT_DOT_INT_MSB_INDEX:Q_HAT_DOT_FRACT_LSB_INDEX];

    localparam OBJ_FUNC_ERR_GRAD_BIT_SHIFT = `OBJ_FUNC_FRACT_WIDTH - `JACOBIAN_FRACT_WIDTH;

    wire signed [`OBJ_FUNC_WIDTH-1:0] f1_err_grad;
    wire signed [`OBJ_FUNC_WIDTH-1:0] f2_err_grad;
    wire signed [`OBJ_FUNC_WIDTH:0] f3_err_grad;
    
    assign f1_err_grad = f1 >>> OBJ_FUNC_ERR_GRAD_BIT_SHIFT;
    assign f2_err_grad = f2 >>> OBJ_FUNC_ERR_GRAD_BIT_SHIFT;
    assign f3_err_grad = f3 >>> OBJ_FUNC_ERR_GRAD_BIT_SHIFT;
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_err_grad <= 1'b0;
            
            q_hat_dot_w_temp <= 0;
            q_hat_dot_x_temp <= 0;
            q_hat_dot_y_temp <= 0;
            q_hat_dot_z_temp <= 0;
        end else begin
            if (start_err_grad && !done_err_grad) begin
                q_hat_dot_w_temp <= j_14_21 * f2_err_grad - j_11_24 * f1_err_grad;
                q_hat_dot_x_temp <= j_12_23 * f1_err_grad + j_13_22 * f2_err_grad - j_32 * f3_err_grad;
                q_hat_dot_y_temp <= j_12_23 * f2_err_grad - j_33 * f3_err_grad - j_13_22 * f1_err_grad;
                q_hat_dot_z_temp <= j_14_21 * f1_err_grad + j_11_24 * f2_err_grad;
                
                done_err_grad <= 1'b1;
            end else begin
                done_err_grad <= 1'b0;
            end
        end
    end
    
    // ---- Error gradient - End ----

    // ---- Normalise error gradient - Start ----

    reg start_err_grad_norm;
    reg done_err_grad_norm;

    // Magnitude squared registers
    localparam Q_HAT_DOT_MAG_SQR_INT_LSB_INDEX = (`Q_HAT_DOT_FRACT_WIDTH * 2);
    localparam Q_HAT_DOT_MAG_SQR_INT_MSB_INDEX = Q_HAT_DOT_MAG_SQR_INT_LSB_INDEX + `Q_HAT_DOT_MAG_SQR_INT_WIDTH - 1;
    localparam Q_HAT_DOT_MAG_SQR_FRACT_LSB_INDEX = Q_HAT_DOT_MAG_SQR_INT_LSB_INDEX - `Q_HAT_DOT_MAG_SQR_FRACT_WIDTH;
    
    reg [(`Q_HAT_DOT_WIDTH*2)+2:0] q_hat_dot_mag_sqr;
    
    wire [(`Q_HAT_DOT_WIDTH*2)+2:0] q_hat_dot_mag_sqr_round_const;
    assign q_hat_dot_mag_sqr_round_const = 1'b1 << (Q_HAT_DOT_MAG_SQR_FRACT_LSB_INDEX - 1);
    
    reg [(`Q_HAT_DOT_WIDTH*2)+3:0] q_hat_dot_mag_sqr_rounded;
    assign q_hat_dot_mag_sqr_rounded = q_hat_dot_mag_sqr + q_hat_dot_mag_sqr_round_const;
    
    // Normalised registers
    localparam Q_HAT_DOT_NORM_INT_LSB_INDEX = `Q_HAT_DOT_FRACT_WIDTH + `Q_HAT_DOT_MAG_SQR_FRACT_WIDTH;
    localparam Q_HAT_DOT_NORM_INT_MSB_INDEX = Q_HAT_DOT_NORM_INT_LSB_INDEX + `Q_HAT_DOT_INT_WIDTH - 1;
    localparam Q_HAT_DOT_NORM_FRACT_LSB_INDEX = Q_HAT_DOT_NORM_INT_LSB_INDEX - `Q_HAT_DOT_FRACT_WIDTH;
    
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_w_norm_temp;
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_x_norm_temp;
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_y_norm_temp;
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_z_norm_temp;

    wire signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH)-1:0] q_hat_dot_norm_round_const;
    assign q_hat_dot_norm_round_const = 1'b1 << (Q_HAT_DOT_NORM_FRACT_LSB_INDEX - 1);
    
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH):0] q_hat_dot_w_norm_rounded;
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH):0] q_hat_dot_x_norm_rounded;
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH):0] q_hat_dot_y_norm_rounded;
    reg signed [(`Q_HAT_DOT_WIDTH+`Q_HAT_DOT_MAG_SQR_WIDTH):0] q_hat_dot_z_norm_rounded;

    assign q_hat_dot_w_norm_rounded = q_hat_dot_w_norm_temp + q_hat_dot_norm_round_const;
    assign q_hat_dot_x_norm_rounded = q_hat_dot_x_norm_temp + q_hat_dot_norm_round_const;
    assign q_hat_dot_y_norm_rounded = q_hat_dot_y_norm_temp + q_hat_dot_norm_round_const;
    assign q_hat_dot_z_norm_rounded = q_hat_dot_z_norm_temp + q_hat_dot_norm_round_const;
    
    wire signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_w_norm;
    wire signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_x_norm;
    wire signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_y_norm;
    wire signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_z_norm;

    assign q_hat_dot_w_norm = q_hat_dot_w_norm_rounded[Q_HAT_DOT_NORM_INT_MSB_INDEX: Q_HAT_DOT_NORM_FRACT_LSB_INDEX];
    assign q_hat_dot_x_norm = q_hat_dot_x_norm_rounded[Q_HAT_DOT_NORM_INT_MSB_INDEX: Q_HAT_DOT_NORM_FRACT_LSB_INDEX];
    assign q_hat_dot_y_norm = q_hat_dot_y_norm_rounded[Q_HAT_DOT_NORM_INT_MSB_INDEX: Q_HAT_DOT_NORM_FRACT_LSB_INDEX];
    assign q_hat_dot_z_norm = q_hat_dot_z_norm_rounded[Q_HAT_DOT_NORM_INT_MSB_INDEX: Q_HAT_DOT_NORM_FRACT_LSB_INDEX];
    
    reg [`Q_HAT_DOT_MAG_SQR_WIDTH-1:0] data_in_invSqrtGradErrNorm;
    reg valid_in_invSqrtGradErrNorm;
    wire ready_in_invSqrtGradErrNorm;
    
    wire signed [`Q_HAT_DOT_MAG_SQR_WIDTH-1:0] data_out_invSqrtGradErrNorm;
    wire valid_out_invSqrtGradErrNorm;
    reg ready_out_invSqrtGradErrNorm;
    
    fastInvSqrt #(
        .INT_WIDTH(`Q_HAT_DOT_MAG_SQR_INT_WIDTH),
        .FRACT_WIDTH(`Q_HAT_DOT_MAG_SQR_FRACT_WIDTH)
    ) invSqrtErrGradNorm (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in_invSqrtGradErrNorm),
        .valid_in(valid_in_invSqrtGradErrNorm),
        .ready_in(ready_in_invSqrtGradErrNorm),
        .data_out(data_out_invSqrtGradErrNorm),
        .valid_out(valid_out_invSqrtGradErrNorm),
        .ready_out(ready_out_invSqrtGradErrNorm)
    );
    
    typedef enum reg [2:0] {
        ERR_GRAD_NORM_IDLE,
        ERR_GRAD_NORM_MAG_SQR,
        ERR_GRAD_NORM_INV_SQRT_INIT,
        ERR_GRAD_NORM_INV_SQRT_DONE,
        ERR_GRAD_NORM_MULT,
        ERR_GRAD_NORM_DONE
    } err_grad_norm_state_t;
    err_grad_norm_state_t err_grad_norm_state, err_grad_norm_next_state;
    
//    // Debug state output
//    always @ (posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            err_grad_norm_debug_state <= ERR_GRAD_NORM_IDLE;
//        end else begin
//            err_grad_norm_debug_state <= err_grad_norm_state;
//        end
//    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            err_grad_norm_state <= ERR_GRAD_NORM_IDLE;
        end else begin
            err_grad_norm_state <= err_grad_norm_next_state;
        end
    end
    
    always @ (*) begin
        err_grad_norm_next_state = err_grad_norm_state;
        case(err_grad_norm_state) 
            ERR_GRAD_NORM_IDLE: begin
                if (start_err_grad_norm) err_grad_norm_next_state = ERR_GRAD_NORM_MAG_SQR;
            end
            ERR_GRAD_NORM_MAG_SQR: begin
                err_grad_norm_next_state = ERR_GRAD_NORM_INV_SQRT_INIT;
            end
            ERR_GRAD_NORM_INV_SQRT_INIT: begin
                if (valid_in_invSqrtGradErrNorm && ready_in_invSqrtGradErrNorm) err_grad_norm_next_state = ERR_GRAD_NORM_INV_SQRT_DONE;
            end
            ERR_GRAD_NORM_INV_SQRT_DONE: begin
                if (valid_out_invSqrtGradErrNorm && ready_out_invSqrtGradErrNorm) err_grad_norm_next_state = ERR_GRAD_NORM_MULT;
            end
            ERR_GRAD_NORM_MULT: begin
                err_grad_norm_next_state = ERR_GRAD_NORM_DONE;
            end
            ERR_GRAD_NORM_DONE: begin
                if (!start_err_grad_norm) err_grad_norm_next_state = ERR_GRAD_NORM_IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_err_grad_norm <= 1'b0;   // Reset state machine signals
    
            data_in_invSqrtGradErrNorm <= `Q_HAT_DOT_MAG_SQR_WIDTH'b0;    // Reset invSqrt signals
            valid_in_invSqrtGradErrNorm <= 1'b0;
            ready_out_invSqrtGradErrNorm <= 1'b0;
    
            q_hat_dot_mag_sqr <= 0;    // Reset internal signals
            q_hat_dot_w_norm_temp <= 0;   
            q_hat_dot_x_norm_temp <= 0;   
            q_hat_dot_y_norm_temp <= 0;   
            q_hat_dot_z_norm_temp <= 0;   
        end else begin
            case(err_grad_norm_state)
                ERR_GRAD_NORM_IDLE: begin
                    done_err_grad_norm <= 1'b0;
                end
                ERR_GRAD_NORM_MAG_SQR: begin
                    q_hat_dot_mag_sqr <= (q_hat_dot_w * q_hat_dot_w + q_hat_dot_x * q_hat_dot_x + q_hat_dot_y * q_hat_dot_y + q_hat_dot_z * q_hat_dot_z);
                end
                ERR_GRAD_NORM_INV_SQRT_INIT: begin
                    data_in_invSqrtGradErrNorm <= q_hat_dot_mag_sqr_rounded[Q_HAT_DOT_MAG_SQR_INT_MSB_INDEX:Q_HAT_DOT_MAG_SQR_FRACT_LSB_INDEX];
                    valid_in_invSqrtGradErrNorm <= 1'b1;
                end
                ERR_GRAD_NORM_INV_SQRT_DONE: begin
                    valid_in_invSqrtGradErrNorm <= 1'b0;
                    ready_out_invSqrtGradErrNorm <= 1'b1;
                end
                ERR_GRAD_NORM_MULT: begin
                    ready_out_invSqrtGradErrNorm <= 1'b0;
                                        
                    q_hat_dot_w_norm_temp <= q_hat_dot_w * data_out_invSqrtGradErrNorm;
                    q_hat_dot_x_norm_temp <= q_hat_dot_x * data_out_invSqrtGradErrNorm;
                    q_hat_dot_y_norm_temp <= q_hat_dot_y * data_out_invSqrtGradErrNorm;
                    q_hat_dot_z_norm_temp <= q_hat_dot_z * data_out_invSqrtGradErrNorm;
                end
                ERR_GRAD_NORM_DONE: begin
                    if (start_err_grad_norm) begin
                        done_err_grad_norm <= 1'b1;
                    end else begin
                        done_err_grad_norm <= 1'b0;
                    end
                end
            endcase
        end
    end
    
    // ---- Normalise error gradient - End ----
    
    // ---- Integrate quaternion derivatives - Start ----
    
    reg start_quat_int;
    reg done_quat_int;
    
    wire signed [`BETA_WIDTH-1:0] beta;
    assign beta = `BETA_WIDTH'b`BETA;
    
    wire signed [`DELTA_T_WIDTH-1:0] delta_t;
    assign delta_t = `DELTA_T_WIDTH'b`DELTA_T;
    
    localparam Q_DOT_QUAT_INT_FRACT_WIDTH = `BETA_FRACT_WIDTH * 2;
    localparam Q_DOT_QUAT_INT_BIT_SHIFT = Q_DOT_QUAT_INT_FRACT_WIDTH - `Q_DOT_FRACT_WIDTH;
    
    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_w_quat_int;
    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_x_quat_int;
    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_y_quat_int;
    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_z_quat_int;
    
    assign q_dot_w_quat_int = q_dot_w >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    assign q_dot_x_quat_int = q_dot_x >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    assign q_dot_y_quat_int = q_dot_y >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    assign q_dot_z_quat_int = q_dot_z >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    
    localparam Q_QUAT_INT_FRACT_WIDTH = `DELTA_T_FRACT_WIDTH * 2;
    localparam Q_QUAT_BIT_SHIFT = Q_QUAT_INT_FRACT_WIDTH - `Q_FRACT_WIDTH;
    
    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_w_quat_int;
    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_x_quat_int;
    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_y_quat_int;
    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_z_quat_int;
    
    assign q_w_quat_int = q_w_norm <<< Q_QUAT_BIT_SHIFT;
    assign q_x_quat_int = q_x_norm <<< Q_QUAT_BIT_SHIFT;
    assign q_y_quat_int = q_y_norm <<< Q_QUAT_BIT_SHIFT;
    assign q_z_quat_int = q_z_norm <<< Q_QUAT_BIT_SHIFT;
    
    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_w_temp;
    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_x_temp;
    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_y_temp;
    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_z_temp;

    localparam Q_TEMP_INT_LSB_INDEX = (`BETA_FRACT_WIDTH*2) + `DELTA_T_FRACT_WIDTH;

    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_round_const;
    assign q_round_const = 1'b1 << (Q_TEMP_INT_LSB_INDEX - `Q_FRACT_WIDTH - 1);

    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_w_rounded;
    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_x_rounded;
    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_y_rounded;
    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_z_rounded;
    
    assign q_w_rounded = q_w_temp + q_round_const;
    assign q_x_rounded = q_x_temp + q_round_const;
    assign q_y_rounded = q_y_temp + q_round_const;
    assign q_z_rounded = q_z_temp + q_round_const;
    
    wire signed [`Q_WIDTH-1:0] q_w;
    wire signed [`Q_WIDTH-1:0] q_x;
    wire signed [`Q_WIDTH-1:0] q_y;
    wire signed [`Q_WIDTH-1:0] q_z;
    
    assign q_w = q_w_rounded[Q_TEMP_INT_LSB_INDEX+`Q_INT_WIDTH-1:Q_TEMP_INT_LSB_INDEX-`Q_FRACT_WIDTH];
    assign q_x = q_x_rounded[Q_TEMP_INT_LSB_INDEX+`Q_INT_WIDTH-1:Q_TEMP_INT_LSB_INDEX-`Q_FRACT_WIDTH];
    assign q_y = q_y_rounded[Q_TEMP_INT_LSB_INDEX+`Q_INT_WIDTH-1:Q_TEMP_INT_LSB_INDEX-`Q_FRACT_WIDTH];
    assign q_z = q_z_rounded[Q_TEMP_INT_LSB_INDEX+`Q_INT_WIDTH-1:Q_TEMP_INT_LSB_INDEX-`Q_FRACT_WIDTH];
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_quat_int <= 1'b0;
            
            q_w_temp <= `Q_TEMP_WIDTH'b0;
            q_x_temp <= `Q_TEMP_WIDTH'b0;
            q_y_temp <= `Q_TEMP_WIDTH'b0;
            q_z_temp <= `Q_TEMP_WIDTH'b0;
        end else if (start_quat_int) begin
            q_w_temp <= q_w_quat_int + (q_dot_w_quat_int - (beta * q_hat_dot_w_norm)) * delta_t;
            q_x_temp <= q_x_quat_int + (q_dot_x_quat_int - (beta * q_hat_dot_x_norm)) * delta_t;
            q_y_temp <= q_y_quat_int + (q_dot_y_quat_int - (beta * q_hat_dot_y_norm)) * delta_t;
            q_z_temp <= q_z_quat_int + (q_dot_z_quat_int - (beta * q_hat_dot_z_norm)) * delta_t;
            
            done_quat_int <= 1'b1;
        end else begin
            done_quat_int <= 1'b0;
        end
    end
    
    // ---- Integrate quaternion derivatives - End ----
    
//    // ---- Normalise quaternion - Start ----
    
//    reg start_quat_norm;
//    wire done_quat_norm;
    
//    wire [(`Q_WIDTH*4)-1:0] data_in_quat_norm;
//    wire [(`Q_WIDTH*4)-1:0] data_out_quat_norm;
    
//    assign data_in_quat_norm = {q_w, q_x, q_y, q_z};
    
//    assign q_w_norm_output = data_out_quat_norm[`Q_WIDTH-1:0];
//    assign q_x_norm_output = data_out_quat_norm[(`Q_WIDTH*2)-1:`Q_WIDTH];
//    assign q_y_norm_output = data_out_quat_norm[(`Q_WIDTH*3)-1:`Q_WIDTH*2];
//    assign q_z_norm_output = data_out_quat_norm[(`Q_WIDTH*4)-1:`Q_WIDTH*3];
    
//    quaternionNormalisation #(
//        .INPUT_INT_WIDTH(`Q_INT_WIDTH),
//        .INPUT_FRACT_WIDTH(`Q_FRACT_WIDTH),
//        .MAG_SQR_INT_WIDTH(`Q_MAG_SQR_INT_WIDTH),
//        .MAG_SQR_FRACT_WIDTH(`Q_MAG_SQR_FRACT_WIDTH)
//    ) quat_norm (
//        .clk(clk),
//        .rst_n(rst_n),
//        .start(start_quat_norm),
//        .done(done_quat_norm),
//        .data_in(data_in_quat_norm),
//        .data_out(data_out_quat_norm)
//    );
    
//    // ---- Normalise quaternion - End ----
    
    // ---- Normalise quaternion - Start ----
    
    reg start_quat_norm;
    reg done_quat_norm;

    // Magnitude squared registers
    localparam Q_MAG_SQR_INT_LSB_INDEX = (`Q_FRACT_WIDTH * 2);
    localparam Q_MAG_SQR_INT_MSB_INDEX = Q_MAG_SQR_INT_LSB_INDEX + `Q_MAG_SQR_INT_WIDTH - 1;
    localparam Q_MAG_SQR_FRACT_LSB_INDEX = Q_MAG_SQR_INT_LSB_INDEX - `Q_MAG_SQR_FRACT_WIDTH;
    
    reg [(`Q_WIDTH*2)+2:0] q_mag_sqr;
    
    wire [(`Q_WIDTH*2)+2:0] q_mag_sqr_round_const;
    assign q_mag_sqr_round_const = 1'b1 << (Q_MAG_SQR_FRACT_LSB_INDEX - 1);
    
    reg [(`Q_WIDTH*2)+3:0] q_mag_sqr_rounded;
    assign q_mag_sqr_rounded = q_mag_sqr + q_mag_sqr_round_const;
    
    // Normalised registers
    localparam Q_NORM_INT_LSB_INDEX = `Q_FRACT_WIDTH + `Q_MAG_SQR_FRACT_WIDTH;
    localparam Q_NORM_INT_MSB_INDEX = Q_NORM_INT_LSB_INDEX + `Q_INT_WIDTH - 1;
    localparam Q_NORM_FRACT_LSB_INDEX = Q_NORM_INT_LSB_INDEX - `Q_FRACT_WIDTH;
    
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_w_norm_temp;
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_x_norm_temp;
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_y_norm_temp;
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_z_norm_temp;

    wire signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH)-1:0] q_norm_round_const;
    assign q_norm_round_const = 1'b1 << (Q_NORM_FRACT_LSB_INDEX - 1);
    
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH):0] q_w_norm_rounded;
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH):0] q_x_norm_rounded;
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH):0] q_y_norm_rounded;
    reg signed [(`Q_WIDTH+`Q_MAG_SQR_WIDTH):0] q_z_norm_rounded;
    
    assign q_w_norm_rounded = q_w_norm_temp + q_norm_round_const;
    assign q_x_norm_rounded = q_x_norm_temp + q_norm_round_const;
    assign q_y_norm_rounded = q_y_norm_temp + q_norm_round_const;
    assign q_z_norm_rounded = q_z_norm_temp + q_norm_round_const;
    
    assign q_w_norm_output = q_w_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    assign q_x_norm_output = q_x_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    assign q_y_norm_output = q_y_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    assign q_z_norm_output = q_z_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    
    reg [`Q_MAG_SQR_WIDTH-1:0] data_in_invSqrtQuatNorm;
    reg valid_in_invSqrtQuatNorm;
    wire ready_in_invSqrtQuatNorm;
    
    wire signed [`Q_MAG_SQR_WIDTH-1:0] data_out_invSqrtQuatNorm;
    wire valid_out_invSqrtQuatNorm;
    reg ready_out_invSqrtQuatNorm;
    
    fastInvSqrt #(
        .INT_WIDTH(`Q_MAG_SQR_INT_WIDTH),
        .FRACT_WIDTH(`Q_MAG_SQR_FRACT_WIDTH)
    ) invSqrtQuatNorm (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in_invSqrtQuatNorm),
        .valid_in(valid_in_invSqrtQuatNorm),
        .ready_in(ready_in_invSqrtQuatNorm),
        .data_out(data_out_invSqrtQuatNorm),
        .valid_out(valid_out_invSqrtQuatNorm),
        .ready_out(ready_out_invSqrtQuatNorm)
    );
    
    typedef enum reg [2:0] {
        Q_NORM_IDLE,
        Q_NORM_MAG_SQR,
        Q_NORM_INV_SQRT_INIT,
        Q_NORM_INV_SQRT_DONE,
        Q_NORM_MULT,
        Q_NORM_DONE
    } q_norm_state_t;
    q_norm_state_t q_norm_state, q_norm_next_state;
    
//    // Debug state output
//    always @ (posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            q_norm_debug_state <= Q_NORM_IDLE;
//        end else begin
//            q_norm_debug_state <= q_norm_state;
//        end
//    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q_norm_state <= Q_NORM_IDLE;
        end else begin
            q_norm_state <= q_norm_next_state;
        end
    end
    
    always @ (*) begin
        q_norm_next_state = q_norm_state;
        case(q_norm_state) 
            Q_NORM_IDLE: begin
                if (start_quat_norm) q_norm_next_state = Q_NORM_MAG_SQR;
            end
            Q_NORM_MAG_SQR: begin
                q_norm_next_state = Q_NORM_INV_SQRT_INIT;
            end
            Q_NORM_INV_SQRT_INIT: begin
                if (valid_in_invSqrtQuatNorm && ready_in_invSqrtQuatNorm) q_norm_next_state = Q_NORM_INV_SQRT_DONE;
            end
            Q_NORM_INV_SQRT_DONE: begin
                if (valid_out_invSqrtQuatNorm && ready_out_invSqrtQuatNorm) q_norm_next_state = Q_NORM_MULT;
            end
            Q_NORM_MULT: begin
                q_norm_next_state = Q_NORM_DONE;
            end
            Q_NORM_DONE: begin
                if (!start_quat_norm) q_norm_next_state = Q_NORM_IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_quat_norm <= 1'b0;   // Reset state machine signals
    
            data_in_invSqrtQuatNorm <= `Q_MAG_SQR_WIDTH'b0;    // Reset invSqrt signals
            valid_in_invSqrtQuatNorm <= 1'b0;
            ready_out_invSqrtQuatNorm <= 1'b0;
    
            q_mag_sqr <= (`Q_WIDTH*2)+2'b0;    // Reset internal signals   
            q_w_norm_temp <= {(`Q_WIDTH+`Q_MAG_SQR_WIDTH){1'b0}};
            q_x_norm_temp <= {(`Q_WIDTH+`Q_MAG_SQR_WIDTH){1'b0}};
            q_y_norm_temp <= {(`Q_WIDTH+`Q_MAG_SQR_WIDTH){1'b0}};
            q_z_norm_temp <= {(`Q_WIDTH+`Q_MAG_SQR_WIDTH){1'b0}};
        end else begin
            case(q_norm_state)
                Q_NORM_IDLE: begin
                    done_quat_norm <= 1'b0;
                end
                Q_NORM_MAG_SQR: begin
                    q_mag_sqr <= (q_w * q_w + q_x * q_x + q_y * q_y + q_z * q_z);
                end
                Q_NORM_INV_SQRT_INIT: begin
                    data_in_invSqrtQuatNorm <= q_mag_sqr_rounded[Q_MAG_SQR_INT_MSB_INDEX: Q_MAG_SQR_FRACT_LSB_INDEX];
                    valid_in_invSqrtQuatNorm <= 1'b1;
                end
                Q_NORM_INV_SQRT_DONE: begin
                    valid_in_invSqrtQuatNorm <= 1'b0;
                    ready_out_invSqrtQuatNorm <= 1'b1;
                end
                Q_NORM_MULT: begin
                    ready_out_invSqrtQuatNorm <= 1'b0;
                                        
                    q_w_norm_temp <= (q_w * data_out_invSqrtQuatNorm);
                    q_x_norm_temp <= (q_x * data_out_invSqrtQuatNorm);
                    q_y_norm_temp <= (q_y * data_out_invSqrtQuatNorm);
                    q_z_norm_temp <= (q_z * data_out_invSqrtQuatNorm);
                end
                Q_NORM_DONE: begin
                    if (start_quat_norm) begin
                        done_quat_norm <= 1'b1;
                    end else begin
                        done_quat_norm <= 1'b0;
                    end
                end
            endcase
        end
    end

    // ---- Normalise quaternion - End ----
    
    // ---- Control path state machine - Start ----
    
    typedef enum reg [3:0] {
        IDLE,
        ACC_VEC_NORM_START,
        ACC_VEC_NORM_DONE,
        OBJ_FUNC_START,
        OBJ_FUNC_DONE,
        ERR_GRAD_START,
        ERR_GRAD_DONE,
        ERR_GRAD_NORMAL_START,
        ERR_GRAD_NORMAL_DONE,
        QUAT_INT_START,
        QUAT_INT_DONE,
        QUAT_NORMAL_START,
        QUAT_NORMAL_DONE,
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
                if (valid_in && ready_in) next_state = ACC_VEC_NORM_START;
            end
            ACC_VEC_NORM_START: begin
                next_state = ACC_VEC_NORM_DONE;
            end
            ACC_VEC_NORM_DONE: begin
                if (done_acc_vec_norm) next_state = OBJ_FUNC_START;
            end
            OBJ_FUNC_START: begin
                next_state = OBJ_FUNC_DONE;
            end
            OBJ_FUNC_DONE: begin
                if (done_obj_func) next_state = ERR_GRAD_START;
            end
            ERR_GRAD_START: begin
                next_state = ERR_GRAD_DONE;
            end
            ERR_GRAD_DONE: begin
                if (done_err_grad) next_state = ERR_GRAD_NORMAL_START;
            end
            ERR_GRAD_NORMAL_START: begin
                next_state = ERR_GRAD_NORMAL_DONE;
            end
            ERR_GRAD_NORMAL_DONE: begin
                if (done_err_grad_norm) next_state = QUAT_INT_START;
            end
            QUAT_INT_START: begin
                if (done_q_dot) next_state = QUAT_INT_DONE;
            end
            QUAT_INT_DONE: begin
                if (done_quat_int) next_state = QUAT_NORMAL_START;
            end
            QUAT_NORMAL_START: begin
                next_state = QUAT_NORMAL_DONE;
            end
            QUAT_NORMAL_DONE: begin
                if (done_quat_norm) next_state = Q_OUTPUT;
            end
            Q_OUTPUT: begin
                if (valid_out && ready_out) next_state = IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_in <= 1'b0;  // De-assert input ready signal
            
            q_w_norm <= `Q_WIDTH'b1 << `Q_FRACT_WIDTH;
            q_x_norm <= `Q_WIDTH'b0;
            q_y_norm <= `Q_WIDTH'b0;
            q_z_norm <= `Q_WIDTH'b0;
            
            q_w_norm_output <= `Q_WIDTH'b1 << `Q_FRACT_WIDTH;    // Reset output signals 
            q_x_norm_output <= `Q_WIDTH'b0;
            q_y_norm_output <= `Q_WIDTH'b0;
            q_z_norm_output <= `Q_WIDTH'b0;
            valid_out <= 1'b0;
            
            start_acc_vec_norm <= 1'b0; // Reset state machine control signals
            start_q_dot <= 1'b0;
            start_obj_func <= 1'b0;
            start_err_grad <= 1'b0;
            start_err_grad_norm <= 1'b0;
            start_quat_int <= 1'b0;
            start_quat_norm <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    ready_in <= 1'b1;
                    valid_out <= 1'b0; 
                end
                ACC_VEC_NORM_START: begin
                    ready_in <= 1'b0;
                    start_acc_vec_norm <= 1'b1;
                    start_q_dot <= 1'b1;
                end
                ACC_VEC_NORM_DONE: begin
                    if (done_acc_vec_norm) start_acc_vec_norm <= 1'b0;
                end
                OBJ_FUNC_START: begin
                    start_obj_func <= 1'b1;
                end
                OBJ_FUNC_DONE: begin
                    if (done_obj_func) start_obj_func <= 1'b0;
                end
                ERR_GRAD_START: begin
                    start_err_grad <= 1'b1;
                end
                ERR_GRAD_DONE: begin
                    if (done_err_grad) start_err_grad <= 1'b0;    
                end
                ERR_GRAD_NORMAL_START: begin
                    start_err_grad_norm <= 1'b1;
                end
                ERR_GRAD_NORMAL_DONE: begin
                    if (done_err_grad_norm) start_err_grad_norm <= 1'b0;    
                end
                QUAT_INT_START: begin
                    if (done_q_dot) begin
                        start_quat_int <= 1'b1;
                        start_q_dot <= 1'b0;
                    end
                end
                QUAT_INT_DONE: begin
                    if (done_quat_int) start_quat_int <= 1'b0;    
                end
                QUAT_NORMAL_START: begin
                    start_quat_norm <= 1'b1;
                end
                QUAT_NORMAL_DONE: begin
                    if (done_quat_norm) start_quat_norm <= 1'b0;    
                end
                Q_OUTPUT: begin
                    valid_out <= 1'b1;
                    
                    q_w_norm <= q_w_norm_output;
                    q_x_norm <= q_x_norm_output;
                    q_y_norm <= q_y_norm_output;
                    q_z_norm <= q_z_norm_output;
                end
            endcase
        end
    end
    
    // ---- Control path state machine - End ----
    
    // ---- Debug signal assignments - Start ----
    
    assign q_w_half_debug = q_w_half;
    assign q_x_half_debug = q_x_half;
    assign q_y_half_debug = q_y_half;
    assign q_z_half_debug = q_z_half;
    assign q_w_two_debug = q_w_two;
    assign q_x_two_debug = q_x_two;
    assign q_y_two_debug = q_y_two;
    assign q_z_two_debug = q_z_two;
    
    assign j_11_24_debug = j_11_24;
    assign j_12_23_debug = j_12_23;
    assign j_13_22_debug = j_13_22;
    assign j_14_21_debug = j_14_21;
    assign j_32_debug = j_32;
    assign j_33_debug = j_33;
    
    assign a_x_norm_debug = a_x_norm;
    assign a_y_norm_debug = a_y_norm;
    assign a_z_norm_debug = a_z_norm;
    
    assign start_acc_vec_norm_debug = start_acc_vec_norm;
    assign done_acc_vec_norm_debug = done_acc_vec_norm;
    
    assign q_dot_w_debug = q_dot_w;
    assign q_dot_x_debug = q_dot_x;
    assign q_dot_y_debug = q_dot_y;
    assign q_dot_z_debug = q_dot_z;
    assign q_w_half_q_dot_debug = q_w_half_q_dot;
    assign q_x_half_q_dot_debug = q_x_half_q_dot;
    assign q_y_half_q_dot_debug = q_y_half_q_dot;
    assign q_z_half_q_dot_debug = q_z_half_q_dot;
    assign q_w_half_q_dot_rounded_debug = q_w_half_q_dot_rounded;
    assign q_x_half_q_dot_rounded_debug = q_x_half_q_dot_rounded;
    assign q_y_half_q_dot_rounded_debug = q_y_half_q_dot_rounded;
    assign q_z_half_q_dot_rounded_debug = q_z_half_q_dot_rounded;
    assign start_q_dot_debug = start_q_dot;
    assign done_q_dot_debug = done_q_dot;
    
    assign f1_debug = f1;
    assign f2_debug = f2;
    assign f3_debug = f3;
    assign q_w_two_obj_func_debug = q_w_two_obj_func;
    assign q_x_two_obj_func_debug = q_x_two_obj_func;
    assign q_y_two_obj_func_debug = q_y_two_obj_func;
    assign a_x_norm_obj_func_debug = a_x_norm_obj_func;
    assign a_y_norm_obj_func_debug = a_y_norm_obj_func;
    assign a_z_norm_obj_func_debug = a_z_norm_obj_func;
    assign start_obj_func_debug = start_obj_func;
    assign done_obj_func_debug = done_obj_func;
    
    assign q_hat_dot_w_debug = q_hat_dot_w;
    assign q_hat_dot_x_debug = q_hat_dot_x;
    assign q_hat_dot_y_debug = q_hat_dot_y;
    assign q_hat_dot_z_debug = q_hat_dot_z;
    assign q_hat_dot_w_temp_debug = q_hat_dot_w_temp;
    assign q_hat_dot_x_temp_debug = q_hat_dot_x_temp;
    assign q_hat_dot_y_temp_debug = q_hat_dot_y_temp;
    assign q_hat_dot_z_temp_debug = q_hat_dot_z_temp;
    assign start_err_grad_debug = start_err_grad;
    assign done_err_grad_debug = done_err_grad;
    
    assign q_hat_dot_w_norm_debug = q_hat_dot_w_norm;
    assign q_hat_dot_x_norm_debug = q_hat_dot_x_norm;
    assign q_hat_dot_y_norm_debug = q_hat_dot_y_norm;
    assign q_hat_dot_z_norm_debug = q_hat_dot_z_norm;
    assign q_hat_dot_w_norm_temp_debug = q_hat_dot_w_norm_temp;
    assign q_hat_dot_x_norm_temp_debug = q_hat_dot_x_norm_temp;
    assign q_hat_dot_y_norm_temp_debug = q_hat_dot_y_norm_temp;
    assign q_hat_dot_z_norm_temp_debug = q_hat_dot_z_norm_temp;
    assign q_hat_dot_mag_sqr_debug = q_hat_dot_mag_sqr;
    assign start_err_grad_norm_debug = start_err_grad_norm;
    assign done_err_grad_norm_debug = done_err_grad_norm;
    
    assign beta_debug = beta;
    assign delta_t_debug = delta_t;
    assign q_dot_w_quat_int_debug = q_dot_w_quat_int;
    assign q_dot_x_quat_int_debug = q_dot_x_quat_int;
    assign q_dot_y_quat_int_debug = q_dot_y_quat_int;
    assign q_dot_z_quat_int_debug = q_dot_z_quat_int;
    assign q_w_quat_int_debug = q_w_quat_int;
    assign q_x_quat_int_debug = q_x_quat_int;
    assign q_y_quat_int_debug = q_y_quat_int;
    assign q_z_quat_int_debug = q_z_quat_int;
    assign q_w_temp_debug = q_w_temp;
    assign q_x_temp_debug = q_x_temp;
    assign q_y_temp_debug = q_y_temp;
    assign q_z_temp_debug = q_z_temp;
    assign q_round_const_debug = q_round_const;
    assign q_w_rounded_debug = q_w_rounded;
    assign q_x_rounded_debug = q_x_rounded;
    assign q_y_rounded_debug = q_y_rounded;
    assign q_z_rounded_debug = q_z_rounded;
    assign q_w_debug = q_w;
    assign q_x_debug = q_x;
    assign q_y_debug = q_y;
    assign q_z_debug = q_z;
    assign start_quat_int_debug = start_quat_int;
    assign done_quat_int_debug = done_quat_int;
    
    assign q_w_norm_debug = q_w_norm;
    assign q_x_norm_debug = q_x_norm;
    assign q_y_norm_debug = q_y_norm;
    assign q_z_norm_debug = q_z_norm;
    assign q_w_norm_temp_debug = q_w_norm_temp;
    assign q_x_norm_temp_debug = q_x_norm_temp;
    assign q_y_norm_temp_debug = q_y_norm_temp;
    assign q_z_norm_temp_debug = q_z_norm_temp;
    assign start_quat_norm_debug = start_quat_norm;
    assign done_quat_norm_debug = done_quat_norm;
    
    // ---- Debug signal assignments - End ----
    
endmodule
