//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2024 16:00:45
// Design Name: 
// Module Name: quaternionNormalisation
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


module quaternionNormalisation # (
    parameter INPUT_INT_WIDTH = 8,
    parameter INPUT_FRACT_WIDTH = 8,
    parameter MAG_SQR_INT_WIDTH = 8,
    parameter MAG_SQR_FRACT_WIDTH = 8
    )
    (
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg done,
    input wire [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*4)-1:0] data_in,
    output reg [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*4)-1:0] data_out
    
    // Debug
    ,output reg signed [(INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH)-1:0] q_w_norm_temp,
    output reg signed [(INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH)-1:0] q_x_norm_temp,
    output reg signed [(INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH)-1:0] q_y_norm_temp,
    output reg signed [(INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH)-1:0] q_z_norm_temp,
    output reg signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH:0] q_w_norm_rounded,
    output reg signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH:0] q_x_norm_rounded,
    output reg signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH:0] q_y_norm_rounded,
    output reg signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH:0] q_z_norm_rounded,
    output reg signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH+MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH-1:0] q_norm_round_const,
    output wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_w_norm,
    output wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_x_norm,
    output wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_y_norm,
    output wire signed [INPUT_INT_WIDTH+INPUT_FRACT_WIDTH-1:0] q_z_norm, 
    output reg [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*2)+2:0] q_mag_sqr,
    output reg [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*2)+2:0] q_mag_sqr_rounded,
    output reg [((INPUT_INT_WIDTH+INPUT_FRACT_WIDTH)*2)+2:0] q_mag_sqr_round_const,
    output reg [MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH-1:0] data_in_invSqrt,
    output reg valid_in_invSqrt,
    output wire ready_in_invSqrt,
    output wire signed [MAG_SQR_INT_WIDTH+MAG_SQR_FRACT_WIDTH-1:0] data_out_invSqrt,
    output wire valid_out_invSqrt,
    output reg ready_out_invSqrt,
    output reg [2:0] debug_state
    );
    
    localparam INPUT_WIDTH = INPUT_INT_WIDTH + INPUT_FRACT_WIDTH;
    localparam MAG_SQR_WIDTH = MAG_SQR_INT_WIDTH + MAG_SQR_FRACT_WIDTH;
    
    wire signed [INPUT_WIDTH-1:0] q_w;
    wire signed [INPUT_WIDTH-1:0] q_x;
    wire signed [INPUT_WIDTH-1:0] q_y;
    wire signed [INPUT_WIDTH-1:0] q_z;
    
    assign q_w = data_in[INPUT_WIDTH-1:0];
    assign q_x = data_in[(INPUT_WIDTH*2)-1:INPUT_WIDTH];
    assign q_y = data_in[(INPUT_WIDTH*3)-1:INPUT_WIDTH*2];
    assign q_z = data_in[(INPUT_WIDTH*4)-1:INPUT_WIDTH*3];
    
    localparam Q_NORM_INT_LSB_INDEX = INPUT_FRACT_WIDTH + MAG_SQR_FRACT_WIDTH;
    localparam Q_NORM_INT_MSB_INDEX = Q_NORM_INT_LSB_INDEX + INPUT_WIDTH - 1;
    localparam Q_NORM_FRACT_LSB_INDEX = Q_NORM_INT_LSB_INDEX - INPUT_FRACT_WIDTH;
    
//    wire signed [INPUT_WIDTH+MAG_SQR_WIDTH-1:0] q_norm_round_const;
    assign q_norm_round_const = 1'b1 << (Q_NORM_FRACT_LSB_INDEX - 1);
    
//    reg signed [(INPUT_WIDTH+MAG_SQR_WIDTH)-1:0] q_w_norm_temp;
//    reg signed [(INPUT_WIDTH+MAG_SQR_WIDTH)-1:0] q_x_norm_temp;
//    reg signed [(INPUT_WIDTH+MAG_SQR_WIDTH)-1:0] q_y_norm_temp;
//    reg signed [(INPUT_WIDTH+MAG_SQR_WIDTH)-1:0] q_z_norm_temp;

//    reg signed [INPUT_WIDTH+MAG_SQR_WIDTH:0] q_w_norm_rounded;
//    reg signed [INPUT_WIDTH+MAG_SQR_WIDTH:0] q_x_norm_rounded;
//    reg signed [INPUT_WIDTH+MAG_SQR_WIDTH:0] q_y_norm_rounded;
//    reg signed [INPUT_WIDTH+MAG_SQR_WIDTH:0] q_z_norm_rounded;
    
    assign q_w_norm_rounded = q_w_norm_temp + q_norm_round_const;
    assign q_x_norm_rounded = q_x_norm_temp + q_norm_round_const;
    assign q_y_norm_rounded = q_y_norm_temp + q_norm_round_const;
    assign q_z_norm_rounded = q_z_norm_temp + q_norm_round_const;
    
//    wire signed [INPUT_WIDTH-1:0] q_w_norm;
//    wire signed [INPUT_WIDTH-1:0] q_x_norm;
//    wire signed [INPUT_WIDTH-1:0] q_y_norm;
//    wire signed [INPUT_WIDTH-1:0] q_z_norm; 
    
    assign q_w_norm = q_w_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    assign q_x_norm = q_x_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    assign q_y_norm = q_y_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    assign q_z_norm = q_z_norm_rounded[Q_NORM_INT_MSB_INDEX: Q_NORM_FRACT_LSB_INDEX];
    
//    reg [(INPUT_WIDTH*2)+2:0] q_mag_sqr;
//    wire [(INPUT_WIDTH*2)+2:0] q_mag_sqr_rounded;
//    wire [(INPUT_WIDTH*2)+2:0] q_mag_sqr_round_const;
    assign q_mag_sqr_round_const = 1'b1 << ((INPUT_FRACT_WIDTH * 2) - MAG_SQR_FRACT_WIDTH - 2);
    assign q_mag_sqr_rounded = q_mag_sqr + q_mag_sqr_round_const;
    
    localparam Q_MAG_SQR_INT_LSB_INDEX = (INPUT_FRACT_WIDTH * 2);
    
//    reg [MAG_SQR_WIDTH-1:0] data_in_invSqrt;
//    reg valid_in_invSqrt;
//    wire ready_in_invSqrt;
    
//    wire signed [MAG_SQR_WIDTH-1:0] data_out_invSqrt;
//    wire valid_out_invSqrt;
//    reg ready_out_invSqrt;
    
    fastInvSqrt #(
        .INT_WIDTH(MAG_SQR_INT_WIDTH),
        .FRACT_WIDTH(MAG_SQR_FRACT_WIDTH)
    ) invSqrtAccNorm (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in_invSqrt),
        .valid_in(valid_in_invSqrt),
        .ready_in(ready_in_invSqrt),
        .data_out(data_out_invSqrt),
        .valid_out(valid_out_invSqrt),
        .ready_out(ready_out_invSqrt)
    );
    
    typedef enum reg [2:0] {
        IDLE,
        MAG_SQR,
        INV_SQRT_INIT,
        INV_SQRT_DONE,
        MULT,
        DONE
    } state_t;
    state_t state, next_state;
    
    // Debug state output
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            debug_state <= IDLE;
        end else begin
            debug_state <= state;
        end
    end
    
    always @ (posedge clk or negedge rst_n) begin
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
                if (start) next_state = MAG_SQR;
            end
            MAG_SQR: begin
                next_state = INV_SQRT_INIT;
            end
            INV_SQRT_INIT: begin
                if (valid_in_invSqrt && ready_in_invSqrt) next_state = INV_SQRT_DONE;
            end
            INV_SQRT_DONE: begin
                if (valid_out_invSqrt && ready_out_invSqrt) next_state = MULT;
            end
            MULT: begin
                next_state = DONE;
            end
            DONE: begin
                if (!start) next_state = IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;   // Reset state machine signals
    
            data_in_invSqrt <= 0;    // Reset invSqrt signals
            valid_in_invSqrt <= 1'b0;
            ready_out_invSqrt <= 1'b0;
    
            q_mag_sqr <= 0;    // Reset internal signals   

            q_w_norm_temp <= {(INPUT_WIDTH+MAG_SQR_WIDTH){1'b0}};
            q_x_norm_temp <= {(INPUT_WIDTH+MAG_SQR_WIDTH){1'b0}};
            q_y_norm_temp <= {(INPUT_WIDTH+MAG_SQR_WIDTH){1'b0}};
            q_z_norm_temp <= {(INPUT_WIDTH+MAG_SQR_WIDTH){1'b0}};
            
            data_out <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 1'b0;
                end
                MAG_SQR: begin
                    q_mag_sqr <= (q_w * q_w + q_x * q_x + q_y * q_y + q_z * q_z);
                end
                INV_SQRT_INIT: begin
                    data_in_invSqrt <= q_mag_sqr_rounded[Q_MAG_SQR_INT_LSB_INDEX+MAG_SQR_INT_WIDTH-1:Q_MAG_SQR_INT_LSB_INDEX-MAG_SQR_FRACT_WIDTH];
                    valid_in_invSqrt <= 1'b1;
                end
                INV_SQRT_DONE: begin
                    valid_in_invSqrt <= 1'b0;
                    ready_out_invSqrt <= 1'b1;
                end
                MULT: begin
                    ready_out_invSqrt <= 1'b0;
                        
                    q_w_norm_temp <= q_w * data_out_invSqrt;
                    q_x_norm_temp <= q_x * data_out_invSqrt;
                    q_y_norm_temp <= q_y * data_out_invSqrt;
                    q_z_norm_temp <= q_z * data_out_invSqrt;
                end
                DONE: begin
                    data_out <= {q_w_norm, q_x_norm, q_y_norm, q_z_norm};
                    
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
