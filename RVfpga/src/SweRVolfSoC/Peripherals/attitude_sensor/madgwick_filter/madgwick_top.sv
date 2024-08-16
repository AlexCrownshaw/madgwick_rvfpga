//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2024 15:41:29
// Design Name: 
// Module Name: madgwick_top
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


module madgwick_top(

    // ---- Wishbone interface signals - Start ----
    
    input wire clk,           // Clock signal
    input wire rst,           // Reset signal (active high)
    input wire [5:0] adr_i,  // Address input
    input wire [31:0] dat_i,  // Data input
    output reg [31:0] dat_o,  // Data output
    input wire we_i,          // Write enable input
    input wire stb_i,         // Strobe input
    input wire cyc_i,         // Cycle input
    output reg ack_o,         // Acknowledge output
    
    // ---- Wishbone interface signals - End ----
    
    // ---- Interupts interface signals - Start ----
    
    output reg inta_o         // Interrupt signal
    
    // ---- Interupts interface signals - End ----
    
    // ---- Debug I/O signals - Start ----
    
    ,output wire [`ACC_WIDTH-1:0] a_x_debug,
    output wire [`ACC_WIDTH-1:0] a_y_debug,
    output wire [`ACC_WIDTH-1:0] a_z_debug,
    output wire [`GYRO_WIDTH-1:0] w_x_debug,
    output wire [`GYRO_WIDTH-1:0] w_y_debug,
    output wire [`GYRO_WIDTH-1:0] w_z_debug,
    output wire [`Q_WIDTH-1:0] q_w_debug,
    output wire [`Q_WIDTH-1:0] q_x_debug,
    output wire [`Q_WIDTH-1:0] q_y_debug,
    output wire [`Q_WIDTH-1:0] q_z_debug
    
    ,output wire enable_debug,
    output wire start_debug,
    output wire done_debug
    
    ,output wire rst_n_madgwick_debug,
    output wire valid_in_madgwick_debug,
    output wire ready_in_madgwick_debug,
    output wire valid_out_madgwick_debug,
    output wire ready_out_madgwick_debug,

    output reg int_enable_debug
    
    // ---- Debug I/O signals - End ----
    );
    
    // ---- Madgwick instatiation - Start ----
    
    reg enable;
    
    reg [`ACC_WIDTH-1:0] a_x;
    reg [`ACC_WIDTH-1:0] a_y;
    reg [`ACC_WIDTH-1:0] a_z;
    
    reg [`GYRO_WIDTH-1:0] w_x;
    reg [`GYRO_WIDTH-1:0] w_y;
    reg [`GYRO_WIDTH-1:0] w_z;
    
    reg [`Q_WIDTH-1:0] q_w;
    reg [`Q_WIDTH-1:0] q_x;
    reg [`Q_WIDTH-1:0] q_y;
    reg [`Q_WIDTH-1:0] q_z;
    
    reg rst_n_madgwick;
    reg valid_in_madgwick;
    wire ready_in_madgwick;
    wire valid_out_madgwick;
    reg ready_out_madgwick;
    
    madgwick madgwick_inst (
        .clk(clk),
        .rst_n(rst_n_madgwick),
        .valid_in(valid_in_madgwick),
        .ready_in(ready_in_madgwick),
        .a_x(a_x),
        .a_y(a_y),
        .a_z(a_z),
        .w_x(w_x),
        .w_y(w_y),
        .w_z(w_z),
        .valid_out(valid_out_madgwick),
        .ready_out(ready_out_madgwick),
        .q_w_norm_output(q_w),
        .q_x_norm_output(q_x),
        .q_y_norm_output(q_y),
        .q_z_norm_output(q_z)
    );
    
    // ---- Madgwick instatiation - End ----
    
    // ---- Process sensor data - Start ----
    
    reg signed [15:0] a_x_sens, a_y_sens, a_z_sens;
    reg signed [15:0] w_x_sens, w_y_sens, w_z_sens;
    
    reg [`ACC_SENS_COEFF_WIDTH+15:0] a_x_temp; 
    reg [`ACC_SENS_COEFF_WIDTH+15:0] a_y_temp; 
    reg [`ACC_SENS_COEFF_WIDTH+15:0] a_z_temp; 
    
    reg [`GYRO_SENS_COEFF_WIDTH+15:0] w_x_temp; 
    reg [`GYRO_SENS_COEFF_WIDTH+15:0] w_y_temp; 
    reg [`GYRO_SENS_COEFF_WIDTH+15:0] w_z_temp; 

    wire signed [`ACC_SENS_COEFF_WIDTH-1:0] acc_sens_coeff;
    wire signed [`GYRO_SENS_COEFF_WIDTH-1:0] gyro_sens_coeff;
    
    if (`PROC_SENS_DATA) begin
        assign acc_sens_coeff = `ACC_SENS_COEFF_WIDTH'b`ACC_SENS_COEFF;
        assign gyro_sens_coeff = `GYRO_SENS_COEFF_WIDTH'b`GYRO_SENS_COEFF;
        
        localparam ACC_INT_MSB_INDEX = `ACC_SENS_COEFF_WIDTH + `ACC_INT_WIDTH;
        localparam ACC_FRACT_LSB_INDEX = `ACC_SENS_COEFF_WIDTH - `ACC_FRACT_WIDTH;
        
        localparam GYRO_INT_MSB_INDEX = `GYRO_SENS_COEFF_WIDTH + `GYRO_INT_WIDTH;
        localparam GYRO_FRACT_LSB_INDEX = `GYRO_SENS_COEFF_WIDTH - `GYRO_FRACT_WIDTH;
        
        assign a_x = a_x_temp[ACC_INT_MSB_INDEX: ACC_FRACT_LSB_INDEX];
        assign a_y = a_y_temp[ACC_INT_MSB_INDEX: ACC_FRACT_LSB_INDEX];
        assign a_z = a_z_temp[ACC_INT_MSB_INDEX: ACC_FRACT_LSB_INDEX];
        
        assign w_x = w_x_temp[GYRO_INT_MSB_INDEX: GYRO_FRACT_LSB_INDEX];
        assign w_y = w_y_temp[GYRO_INT_MSB_INDEX: GYRO_FRACT_LSB_INDEX];
        assign w_z = w_z_temp[GYRO_INT_MSB_INDEX: GYRO_FRACT_LSB_INDEX];
    end
        
    // ---- Process sensor data - End ----
    
    // ---- Madgwick control path - Start ----
    
    reg start;
    reg done;
    
     typedef enum reg [2:0] {
        IDLE,
        PROC_SENS_DATA,
        START,
        WAIT_FOR_RESULT,
        DONE
    } state_t;
    state_t state, next_state;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start) begin
                    if (`PROC_SENS_DATA) begin
                        next_state = PROC_SENS_DATA;
                    end else begin
                        next_state = START;
                    end
                end
            end
            PROC_SENS_DATA: begin
                next_state = START;
            end
            START: begin
                if (valid_in_madgwick && ready_in_madgwick) next_state = WAIT_FOR_RESULT;
            end
            WAIT_FOR_RESULT: begin
                if (valid_out_madgwick && ready_out_madgwick) next_state = DONE;
            end
            DONE: begin
                if (done && !start) next_state = IDLE;
            end
        endcase
    end
    
    always @ (posedge clk) begin
        if (rst || !enable) begin
            done <= 1'b0;   // Reset control signals
        
            rst_n_madgwick <= 'b0;  // Reset madgwick module
            valid_in_madgwick <= 'b0;
            ready_out_madgwick <= 'b0;
            
            if (`PROC_SENS_DATA) begin
                a_x_sens <= 16'b0;
                a_y_sens <= 16'b0;
                a_z_sens <= 16'b0;
                w_x_sens <= 16'b0;
                w_y_sens <= 16'b0;
                w_z_sens <= 16'b0;
            end
        end else begin
            rst_n_madgwick <= 'b1;  // De-assert madgwick rst_n flag
        
            case (state)
                IDLE: begin
                    done <= 1'b0;
                end
                PROC_SENS_DATA: begin
                    a_x_temp <= {a_x_sens, `ACC_FRACT_WIDTH'b0} * acc_sens_coeff;
                    a_y_temp <= {a_y_sens, `ACC_FRACT_WIDTH'b0} * acc_sens_coeff;
                    a_z_temp <= {a_z_sens, `ACC_FRACT_WIDTH'b0} * acc_sens_coeff;
                    w_x_temp <= {w_x_sens, `GYRO_FRACT_WIDTH'b0} * acc_sens_coeff;
                    w_y_temp <= {w_y_sens, `GYRO_FRACT_WIDTH'b0} * acc_sens_coeff;
                    w_z_temp <= {w_z_sens, `GYRO_FRACT_WIDTH'b0} * acc_sens_coeff;
                end
                START: begin
                    valid_in_madgwick <= 1'b1;
                end
                WAIT_FOR_RESULT: begin
                    valid_in_madgwick <= 1'b0;
                    ready_out_madgwick <= 1'b1;
                end
                DONE: begin
                    ready_out_madgwick <= 1'b0;
                    done <= 1'b1;
                end
            endcase
        end
    end
    
    // ---- Madgwick control path - End ----
    
    // ---- Interrupt signal driver - Start ----
    
    reg int_enable;    
    reg done_delay;
    reg int_pulse;
    
    always @ (posedge clk) begin
        if (rst) begin
            done_delay <= 0;
            int_pulse <= 0;
        end else begin
            done_delay <= done;
            int_pulse <= done & ~done_delay;
        end
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            inta_o <= 0;
        end else if (int_enable & int_pulse) begin
            inta_o <= 1'b1;
        end else begin
            inta_o <= 1'b0;
        end
    end
    
    // ---- Interrupt signal driver - End ----
    
    // ---- Wishbone interface - Start ----
    
    reg [7:0] ctrl_reg;     // Control register assignment
    assign ctrl_reg[0] = enable;
    assign ctrl_reg[1] = start;
    assign ctrl_reg[2] = done;
    assign ctrl_reg[3] = int_enable;
    assign ctrl_reg[7:4] = 4'b0;
    
    wire valid_wb;
    assign valid_wb = cyc_i && stb_i;
    
    always @(posedge clk) begin
        if (rst) begin
            ack_o <= 1'b0;  // Reset wb signals
            dat_o <= 32'h00000000;
                        
            enable <= 1'b0; // Reset control signals
            start <= 1'b0;
            int_enable <= 1'b0;
            
            a_x <= `ACC_WIDTH'b0;    // Reset input data registers
            a_y <= `ACC_WIDTH'b0;    
            a_z <= `ACC_WIDTH'b0;    
            w_x <= `GYRO_WIDTH'b0;  
            w_y <= `GYRO_WIDTH'b0;    
            w_z <= `GYRO_WIDTH'b0; 
        end else begin
            ack_o <= 1'b0; // Default to no acknowledge
            if (valid_wb && !ack_o) begin
                ack_o <= 1'b1; // Acknowledge the cycle
                if (we_i) begin
                    if (`PROC_SENS_DATA) begin
                        case (adr_i)
                            'h00: begin   // Decode control register
                                enable <= dat_i[0];
                                start <= dat_i[1];
                                int_enable <= dat_i[3];
                            end
                            6'h04: a_x_sens <= dat_i[15:0];   // Accel sensor data input
                            6'h08: a_y_sens <= dat_i[15:0];
                            6'h0c: a_z_sens <= dat_i[15:0];
                            6'h10: w_x_sens <= dat_i[15:0];   // Gyro sensor data input
                            6'h14: w_y_sens <= dat_i[15:0];
                            6'h18: w_z_sens <= dat_i[15:0];
                        endcase
                    end else begin
                        case (adr_i)
                            'h00: begin   // Decode control register
                                enable <= dat_i[0];
                                start <= dat_i[1];
                                int_enable <= dat_i[3];
                            end
                            6'h04: a_x <= dat_i[`ACC_WIDTH-1:0];   // Accel data input
                            6'h08: a_y <= dat_i[`ACC_WIDTH-1:0];
                            6'h0c: a_z <= dat_i[`ACC_WIDTH-1:0];
                            6'h10: w_x <= dat_i[`GYRO_WIDTH-1:0];   // Gyro data input
                            6'h14: w_y <= dat_i[`GYRO_WIDTH-1:0];
                            6'h18: w_z <= dat_i[`GYRO_WIDTH-1:0];
                        endcase
                    end
                end else begin
                    case (adr_i)
                        6'h00: dat_o <= ctrl_reg;    // Send control register
                        6'h1c: dat_o <= q_w;     // Send quaternion output data
                        6'h20: dat_o <= q_x;
                        6'h24: dat_o <= q_y;
                        6'h28: dat_o <= q_z;
                    endcase
                end
            end
        end
    end
    
    // ---- Wishbone interface - End ----
    
    // ---- Assign debug signals - Start ----
    
    assign a_x_debug = a_x;
    assign a_y_debug = a_y;
    assign a_z_debug = a_z;
    assign w_x_debug = w_x;
    assign w_y_debug = w_y;
    assign w_z_debug = w_z;
    assign q_w_debug = q_w;
    assign q_x_debug = q_x;
    assign q_y_debug = q_y;
    assign q_z_debug = q_z;
    
    assign enable_debug = enable;
    assign start_debug = start;
    assign done_debug = done;
    
    assign rst_n_madgwick_debug = rst_n_madgwick;
    assign valid_in_madgwick_debug = valid_in_madgwick;
    assign ready_in_madgwick_debug = ready_in_madgwick;
    assign valid_out_madgwick_debug = valid_out_madgwick;
    assign ready_out_madgwick_debug = ready_out_madgwick;
    
    assign int_enable_debug = int_enable;
    
    // ---- Assign debug signals - End ----
    
endmodule
