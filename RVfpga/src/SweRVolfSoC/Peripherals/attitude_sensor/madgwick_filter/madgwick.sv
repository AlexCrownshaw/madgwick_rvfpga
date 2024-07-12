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
    
    ,output wire signed [`Q_HALF_WIDTH-1:0] q_w_half,    // pre-compute signals
    output wire signed [`Q_HALF_WIDTH-1:0] q_x_half,
    output wire signed [`Q_HALF_WIDTH-1:0] q_y_half,
    output wire signed [`Q_HALF_WIDTH-1:0] q_z_half,
    output wire signed [`Q_TWO_WIDTH-1:0] q_w_two,
    output wire signed [`Q_TWO_WIDTH-1:0] q_x_two,
    output wire signed [`Q_TWO_WIDTH-1:0] q_y_two,
    output wire signed [`Q_TWO_WIDTH-1:0] q_z_two
    
    ,output wire signed [`JACOBIAN_WIDTH-1:0] j_11_24, // Jacobian
    output wire signed [`JACOBIAN_WIDTH-1:0] j_12_23,
    output wire signed [`JACOBIAN_WIDTH-1:0] j_13_22,
    output wire signed [`JACOBIAN_WIDTH-1:0] j_14_21,
    output wire signed [`JACOBIAN_WIDTH:0] j_32,
    output wire signed [`JACOBIAN_WIDTH:0] j_33
    
    ,wire signed [`ACC_WIDTH-1:0] a_x_norm, // Acc Norm
    wire signed [`ACC_WIDTH-1:0] a_y_norm,
    wire signed [`ACC_WIDTH-1:0] a_z_norm
    ,output reg start_acc_vec_norm,
    output reg done_acc_vec_norm

    ,output reg signed [`Q_DOT_WIDTH-1:0] q_dot_w,  // q_dot
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_x,
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_y,
    output reg signed [`Q_DOT_WIDTH-1:0] q_dot_z,
    output reg signed [`Q_HALF_WIDTH-1:0] q_w_half_q_dot,
    output reg signed [`Q_HALF_WIDTH-1:0] q_x_half_q_dot,
    output reg signed [`Q_HALF_WIDTH-1:0] q_y_half_q_dot,
    output reg signed [`Q_HALF_WIDTH-1:0] q_z_half_q_dot,
    output reg start_q_dot,
    output reg done_q_dot
    
    ,output reg signed [`OBJ_FUNC_WIDTH-1:0] f1,    // Obj func
    output reg signed [`OBJ_FUNC_WIDTH-1:0] f2,
    output reg signed [`OBJ_FUNC_WIDTH:0] f3,
    output reg signed [`Q_TWO_WIDTH-1:0] q_w_two_obj_func,
    output reg signed [`Q_TWO_WIDTH-1:0] q_x_two_obj_func,
    output reg signed [`Q_TWO_WIDTH-1:0] q_y_two_obj_func,
    output reg signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_x_norm_obj_func,
    output reg signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_y_norm_obj_func,
    output reg signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_z_norm_obj_func,
    output reg start_obj_func,
    output reg done_obj_func
    
    ,output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_w,  // Err grad
    output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_x,
    output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_y,
    output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_z,
    output reg start_err_grad,
    output reg done_err_grad
    
    ,output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_w_norm, // Err grad norm 
    output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_x_norm, 
    output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_y_norm, 
    output reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_z_norm,
    output reg [(`Q_HAT_DOT_TRUNC_WIDTH*4)-1:0] data_in_err_grad_norm,
    output reg [(`Q_HAT_DOT_TRUNC_WIDTH*4)-1:0] data_out_err_grad_norm,
    output reg start_err_grad_norm,
    output reg done_err_grad_norm
    
    ,output reg signed [`BETA_WIDTH-1:0] beta,    // Quat int
    output reg signed [`DELTA_T_WIDTH-1:0] delta_t,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_w_quat_int,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_x_quat_int,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_y_quat_int,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)-1:0] q_dot_z_quat_int,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_w_quat_int,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_x_quat_int,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_y_quat_int,
    output reg signed [`Q_INT_WIDTH+(`DELTA_T_FRACT_WIDTH * 2)-1:0] q_z_quat_int,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_w_temp,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_x_temp,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_y_temp,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_WIDTH+1:0] q_z_temp,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_round_const,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_w_rounded,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_x_rounded,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_y_rounded,
    output reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_z_rounded,
    output reg signed [`Q_WIDTH-1:0] q_w,
    output reg signed [`Q_WIDTH-1:0] q_x,
    output reg signed [`Q_WIDTH-1:0] q_y,
    output reg signed [`Q_WIDTH-1:0] q_z,
    output reg start_quat_int,
    output reg done_quat_int
    
    ,output reg signed [`Q_WIDTH-1:0] q_w_norm, // Quat norm
    output reg signed [`Q_WIDTH-1:0] q_x_norm,
    output reg signed [`Q_WIDTH-1:0] q_y_norm,
    output reg signed [`Q_WIDTH-1:0] q_z_norm,
    output reg [(`Q_WIDTH*4)-1:0] data_in_quat_norm,
    output reg [(`Q_WIDTH*4)-1:0] data_out_quat_norm,
    output reg start_quat_norm,
    output reg done_quat_norm
    
    // ---- Debug I/O - End ----
    );
    
    // ---- Internal pre-compute signals - Start ----   
    
//    reg signed [`Q_WIDTH-1:0] q_w_norm;
//    reg signed [`Q_WIDTH-1:0] q_x_norm;
//    reg signed [`Q_WIDTH-1:0] q_y_norm;
//    reg signed [`Q_WIDTH-1:0] q_z_norm;
    
//    wire signed [`Q_HALF_WIDTH-1:0] q_w_half;
//    wire signed [`Q_HALF_WIDTH-1:0] q_x_half;
//    wire signed [`Q_HALF_WIDTH-1:0] q_y_half;
//    wire signed [`Q_HALF_WIDTH-1:0] q_z_half;
    
    assign q_w_half = q_w_norm >>> 1;
    assign q_x_half = q_x_norm >>> 1;
    assign q_y_half = q_y_norm >>> 1;
    assign q_z_half = q_z_norm >>> 1;
    
//    wire signed [`Q_TWO_WIDTH-1:0] q_w_two;
//    wire signed [`Q_TWO_WIDTH-1:0] q_x_two;
//    wire signed [`Q_TWO_WIDTH-1:0] q_y_two;
//    wire signed [`Q_TWO_WIDTH-1:0] q_z_two;
    
    assign q_w_two = q_w_norm <<< 1;
    assign q_x_two = q_x_norm <<< 1;
    assign q_y_two = q_y_norm <<< 1;
    assign q_z_two = q_z_norm <<< 1;
    
    // ---- Internal pre-compute signals - End ----   
    
    // ---- Jacobian matrix elements - Start ----
    
//    wire signed [`JACOBIAN_WIDTH-1:0] j_11_24;
//    wire signed [`JACOBIAN_WIDTH-1:0] j_12_23;
//    wire signed [`JACOBIAN_WIDTH-1:0] j_13_22;
//    wire signed [`JACOBIAN_WIDTH-1:0] j_14_21;
//    wire signed [`JACOBIAN_WIDTH:0] j_32;
//    wire signed [`JACOBIAN_WIDTH:0] j_33;
    
    assign j_11_24 = q_y_two;
    assign j_12_23 = q_z_norm <<< 1;
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

    localparam Q_HALF_Q_DOT_BIT_SHIFT = `Q_HALF_FRACT_WIDTH - `GYRO_FRACT_WIDTH;

//    wire signed [`Q_HALF_WIDTH-1:0] q_w_half_q_dot;
//    wire signed [`Q_HALF_WIDTH-1:0] q_x_half_q_dot;
//    wire signed [`Q_HALF_WIDTH-1:0] q_y_half_q_dot;
//    wire signed [`Q_HALF_WIDTH-1:0] q_z_half_q_dot;
    
    assign q_w_half_q_dot = q_w_half >>> Q_HALF_Q_DOT_BIT_SHIFT;
    assign q_x_half_q_dot = q_x_half >>> Q_HALF_Q_DOT_BIT_SHIFT;
    assign q_y_half_q_dot = q_y_half >>> Q_HALF_Q_DOT_BIT_SHIFT;
    assign q_z_half_q_dot = q_z_half >>> Q_HALF_Q_DOT_BIT_SHIFT;
    
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
    
//    reg start_obj_func;
//    reg done_obj_func;
    
//    reg signed [`OBJ_FUNC_WIDTH-1:0] f1;
//    reg signed [`OBJ_FUNC_WIDTH-1:0] f2;
//    reg signed [`OBJ_FUNC_WIDTH:0] f3;

    localparam Q_TWO_OBJ_FUNC_BIT_SHIFT = `Q_TWO_FRACT_WIDTH - `Q_FRACT_WIDTH;

//    wire signed [`Q_TWO_WIDTH-1:0] q_w_two_obj_func;
//    wire signed [`Q_TWO_WIDTH-1:0] q_x_two_obj_func;
//    wire signed [`Q_TWO_WIDTH-1:0] q_y_two_obj_func;
        
    assign q_w_two_obj_func = q_w_two >>> Q_TWO_OBJ_FUNC_BIT_SHIFT;
    assign q_x_two_obj_func = q_x_two >>> Q_TWO_OBJ_FUNC_BIT_SHIFT;
    assign q_y_two_obj_func = q_y_two >>> Q_TWO_OBJ_FUNC_BIT_SHIFT;
    
    localparam ACC_NORM_OBJ_FUNC_BIT_SHIFT = (`Q_FRACT_WIDTH + `Q_TWO_FRACT_WIDTH) - `ACC_FRACT_WIDTH;

//    wire signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_x_norm_obj_func;
//    wire signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_y_norm_obj_func;
//    wire signed [`Q_WIDTH+`Q_TWO_WIDTH-1:0] a_z_norm_obj_func;
    
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
    
//    reg start_err_grad;
//    reg done_err_grad;
    
//    reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_w;
//    reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_x;
//    reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_y;
//    reg signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_z;

    localparam Q_HAT_DOT_INT_LSB_INDEX = `Q_HAT_DOT_FRACT_WIDTH;
    localparam Q_HAT_DOT_INT_MSB_INDEX = Q_HAT_DOT_INT_LSB_INDEX + `Q_HAT_DOT_TRUNC_INT_WIDTH - 1;
    localparam Q_HAT_DOT_FRACT_LSB_INDEX = Q_HAT_DOT_INT_LSB_INDEX - `Q_HAT_DOT_TRUNC_FRACT_WIDTH;

    reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_w_temp;
    reg signed [`Q_HAT_DOT_WIDTH+1:0] q_hat_dot_x_temp;
    reg signed [`Q_HAT_DOT_WIDTH+2:0] q_hat_dot_y_temp;
    reg signed [`Q_HAT_DOT_WIDTH-1:0] q_hat_dot_z_temp;
    
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
            
            q_hat_dot_w_temp <= `Q_HAT_DOT_WIDTH'b0;
            q_hat_dot_x_temp <= `Q_HAT_DOT_WIDTH'b0;
            q_hat_dot_y_temp <= `Q_HAT_DOT_WIDTH'b0;
            q_hat_dot_z_temp <= `Q_HAT_DOT_WIDTH'b0;
        end else begin
            if (start_err_grad && !done_err_grad) begin
                q_hat_dot_w_temp <= j_14_21 * f2_err_grad - j_11_24 * f1_err_grad;
                q_hat_dot_x_temp <= j_12_23 * f1_err_grad + j_13_22 * f2_err_grad - j_32 * f3_err_grad;
                q_hat_dot_y_temp <= j_12_23 * f2_err_grad - j_33 * f3_err_grad - j_13_22 * f1_err_grad;
                q_hat_dot_z_temp <= j_14_21 * f1_err_grad + j_11_24 * f2_err_grad;
                
                done_err_grad <= 1'b1;
            end
        end
    end
    
    // ---- Error gradient - End ----
    
    // ---- Normalise error gradient - Start ----
    
//    reg start_err_grad_norm;
//    wire done_err_grad_norm;
    
//    wire [(`Q_HAT_DOT_TRUNC_WIDTH*4)-1:0] data_in_err_grad_norm;
//    wire [(`Q_HAT_DOT_TRUNC_WIDTH*4)-1:0] data_out_err_grad_norm;
    
    assign data_in_err_grad_norm = {q_hat_dot_w, q_hat_dot_x, q_hat_dot_y, q_hat_dot_z};
    
//    wire signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_w_norm; 
//    wire signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_x_norm; 
//    wire signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_y_norm; 
//    wire signed [`Q_HAT_DOT_TRUNC_WIDTH-1:0] q_hat_dot_z_norm; 
    
    assign q_hat_dot_w_norm = data_out_err_grad_norm[`Q_HAT_DOT_TRUNC_WIDTH-1:0];
    assign q_hat_dot_x_norm = data_out_err_grad_norm[(`Q_HAT_DOT_TRUNC_WIDTH*2)-1:`Q_HAT_DOT_TRUNC_WIDTH];
    assign q_hat_dot_y_norm = data_out_err_grad_norm[(`Q_HAT_DOT_TRUNC_WIDTH*3)-1:`Q_HAT_DOT_TRUNC_WIDTH*2];
    assign q_hat_dot_z_norm = data_out_err_grad_norm[(`Q_HAT_DOT_TRUNC_WIDTH*4)-1:`Q_HAT_DOT_TRUNC_WIDTH*3];
    
    quaternionNormalisation #(
        .INPUT_INT_WIDTH(`Q_HAT_DOT_TRUNC_INT_WIDTH),
        .INPUT_FRACT_WIDTH(`Q_HAT_DOT_TRUNC_FRACT_WIDTH),
        .MAG_SQR_INT_WIDTH(`Q_HAT_DOT_MAG_SQR_INT_WIDTH),
        .MAG_SQR_FRACT_WIDTH(`Q_HAT_DOT_MAG_SQR_FRACT_WIDTH)
    ) q_hat_dot_norm (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_err_grad_norm),
        .done(done_err_grad_norm),
        .data_in(data_in_err_grad_norm),
        .data_out(data_out_err_grad_norm)
    );
    
    // ---- Normalise error gradient - End ----
    
    // ---- Integrate quaternion derivatives - Start ----
    
//    reg start_quat_int;
//    reg done_quat_int;
    
//    wire signed [`BETA_WIDTH-1:0] beta;
    assign beta = `BETA_WIDTH'b`BETA;
    
//    wire signed [`DELTA_T_WIDTH-1:0] delta_t;
    assign delta_t = `DELTA_T_WIDTH'b`DELTA_T;
    
    localparam Q_DOT_QUAT_INT_FRACT_WIDTH = `BETA_FRACT_WIDTH * 2;
    localparam Q_DOT_QUAT_INT_BIT_SHIFT = Q_DOT_QUAT_INT_FRACT_WIDTH - `Q_DOT_FRACT_WIDTH;
    
//    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_w_quat_int;
//    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_x_quat_int;
//    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_y_quat_int;
//    wire signed [`Q_DOT_INT_WIDTH+Q_DOT_QUAT_INT_FRACT_WIDTH-1:0] q_dot_z_quat_int;
    
    assign q_dot_w_quat_int = q_dot_w >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    assign q_dot_x_quat_int = q_dot_x >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    assign q_dot_y_quat_int = q_dot_y >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    assign q_dot_z_quat_int = q_dot_z >>> Q_DOT_QUAT_INT_BIT_SHIFT;
    
    localparam Q_QUAT_INT_FRACT_WIDTH = `DELTA_T_FRACT_WIDTH * 2;
    localparam Q_QUAT_BIT_SHIFT = Q_QUAT_INT_FRACT_WIDTH - `Q_FRACT_WIDTH;
    
//    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_w_quat_int;
//    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_x_quat_int;
//    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_y_quat_int;
//    wire signed [`Q_INT_WIDTH+Q_QUAT_INT_FRACT_WIDTH-1:0] q_z_quat_int;
    
    assign q_w_quat_int = q_w_norm <<< Q_QUAT_BIT_SHIFT;
    assign q_x_quat_int = q_x_norm <<< Q_QUAT_BIT_SHIFT;
    assign q_y_quat_int = q_y_norm <<< Q_QUAT_BIT_SHIFT;
    assign q_z_quat_int = q_z_norm <<< Q_QUAT_BIT_SHIFT;
    
//    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_w_temp;
//    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_x_temp;
//    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_y_temp;
//    reg signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_z_temp;

    localparam Q_TEMP_INT_LSB_INDEX = (`BETA_FRACT_WIDTH*2) + `DELTA_T_FRACT_WIDTH;

//    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+1:0] q_round_const;
    assign q_round_const = 1'b1 << (Q_TEMP_INT_LSB_INDEX - `Q_FRACT_WIDTH - 2);

//    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_w_rounded;
//    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_x_rounded;
//    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_y_rounded;
//    wire signed [`Q_DOT_INT_WIDTH+(`BETA_FRACT_WIDTH*2)+`DELTA_T_FRACT_WIDTH+2:0] q_z_rounded;
    
    assign q_w_rounded = q_w_temp + q_round_const;
    assign q_x_rounded = q_x_temp + q_round_const;
    assign q_y_rounded = q_y_temp + q_round_const;
    assign q_z_rounded = q_z_temp + q_round_const;
    
//    wire signed [`Q_WIDTH-1:0] q_w;
//    wire signed [`Q_WIDTH-1:0] q_x;
//    wire signed [`Q_WIDTH-1:0] q_y;
//    wire signed [`Q_WIDTH-1:0] q_z;
    
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
        end if (start_quat_int) begin
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
    
    // ---- Normalise quaternion - Start ----
    
//    reg start_quat_norm;
//    wire done_quat_norm;
    
//    wire [(`Q_WIDTH*4)-1:0] data_in_quat_norm;
//    wire [(`Q_WIDTH*4)-1:0] data_out_quat_norm;
    
    assign data_in_quat_norm = {q_w, q_x, q_y, q_z};
    
    assign q_w_norm_output = data_out_quat_norm[`Q_WIDTH-1:0];
    assign q_x_norm_output = data_out_quat_norm[(`Q_WIDTH*2)-1:`Q_WIDTH];
    assign q_y_norm_output = data_out_quat_norm[(`Q_WIDTH*3)-1:`Q_WIDTH*2];
    assign q_z_norm_output = data_out_quat_norm[(`Q_WIDTH*4)-1:`Q_WIDTH*3];
    
    quaternionNormalisation #(
        .INPUT_INT_WIDTH(`Q_INT_WIDTH),
        .INPUT_FRACT_WIDTH(`Q_FRACT_WIDTH),
        .MAG_SQR_INT_WIDTH(`Q_MAG_SQR_INT_WIDTH),
        .MAG_SQR_FRACT_WIDTH(`Q_MAG_SQR_FRACT_WIDTH)
    ) quat_norm (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_quat_norm),
        .done(done_quat_norm),
        .data_in(data_in_quat_norm),
        .data_out(data_out_quat_norm)
    );
    
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
        ERR_GRAD_NORM_START,
        ERR_GRAD_NORM_DONE,
        QUAT_INT_START,
        QUAT_INT_DONE,
        QUAT_NORM_START,
        QUAT_NORM_DONE,
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
                if (done_err_grad) next_state = ERR_GRAD_NORM_START;
            end
            ERR_GRAD_NORM_START: begin
                next_state = ERR_GRAD_NORM_DONE;
            end
            ERR_GRAD_NORM_DONE: begin
                if (done_err_grad_norm) next_state = QUAT_INT_START;
            end
            QUAT_INT_START: begin
                next_state = QUAT_INT_DONE;
            end
            QUAT_INT_DONE: begin
                if (done_quat_int) next_state = QUAT_NORM_START;
            end
            QUAT_NORM_START: begin
                next_state = QUAT_NORM_DONE;
            end
            QUAT_NORM_DONE: begin
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
                ERR_GRAD_NORM_START: begin
                    start_err_grad_norm <= 1'b1;
                end
                ERR_GRAD_NORM_DONE: begin
                    if (done_err_grad_norm) start_err_grad_norm <= 1'b0;    
                end
                QUAT_INT_START: begin
                    start_quat_int <= 1'b1;
                end
                QUAT_INT_DONE: begin
                    if (done_quat_int) start_quat_int <= 1'b0;    
                end
                QUAT_NORM_START: begin
                    start_quat_norm <= 1'b1;
                end
                QUAT_NORM_DONE: begin
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
    
endmodule
