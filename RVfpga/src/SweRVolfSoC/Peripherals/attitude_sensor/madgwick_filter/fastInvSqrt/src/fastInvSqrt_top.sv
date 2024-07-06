//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2024 11:12:18
// Design Name: 
// Module Name: fastInvSqrt_top
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


module fastInvSqrt_top(
    input wire clk,           // Clock signal
    input wire rst,           // Reset signal (active high)
    input wire [31:0] adr_i,  // Address input
    input wire [15:0] dat_i,  // Data input
    output reg [15:0] dat_o,  // Data output
    input wire we_i,          // Write enable input
    input wire stb_i,         // Strobe input
    input wire cyc_i,         // Cycle input
    output reg ack_o          // Acknowledge output
    
//    // Debug I/O
//    ,output reg [15:0] data_in,
//    output reg [15:0] data_out
    
//    ,
//    output reg rst_fastInvSqrt,
//    output reg [15:0] data_in_fastInvSqrt,
//    output reg valid_in_fastInvSqrt,
//    output reg ready_in_fastInvSqrt,
//    output reg [15:0] data_out_fastInvSqrt,
//    output reg valid_out_fastInvSqrt,
//    output reg ready_out_fastInvSqrt,
//    output reg [2:0] debug_state

    );

    // ---- fastInvSqrt module instatiation ----
    reg rst_fastInvSqrt;
    reg [15:0] data_in_fastInvSqrt;
    reg valid_in_fastInvSqrt;
    wire ready_in_fastInvSqrt;
    wire [15:0] data_out_fastInvSqrt;
    wire valid_out_fastInvSqrt;
    reg ready_out_fastInvSqrt;
        
    fastInvSqrt #(
        .INT_WIDTH(12),
        .FRACT_WIDTH(4)
    ) fastInvSqrt_q12_4 (
        .clk(clk),
        .rst_n(~rst_fastInvSqrt),
        .data_in(data_in_fastInvSqrt),
        .valid_in(valid_in_fastInvSqrt),
        .ready_in(ready_in_fastInvSqrt),
        .data_out(data_out_fastInvSqrt),
        .valid_out(valid_out_fastInvSqrt),
        .ready_out(ready_out_fastInvSqrt)
    );

    //  ----- Wishbone Interface ----
    reg [15:0] data_in;
    reg [15:0] data_out;

    wire valid_wb; // Valid cycle detection
    assign valid_wb = cyc_i && stb_i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ack_o <= 1'b0;
            dat_o <= 32'h00000000;
        end else begin
            ack_o <= 1'b0; // Default to no acknowledge
            if (valid_wb && !ack_o) begin
                ack_o <= 1'b1; // Acknowledge the cycle
                if (we_i) begin
                    data_in <= dat_i;   // Write operation
                end else begin
                    dat_o <= data_out;
                end
            end
            // if (ack_o) begin
            //     dat_o <= data_out; // Output data during acknowledge
            // end
        end
    end

    // ---- fastInvSqrt control path ----
    typedef enum reg [1:0] {
        IDLE,
        START,
        WAIT_FOR_RESULT,
        DONE
    } state_t;
    state_t state, next_state;
    
//    // Update debug_state for monitoring
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            debug_state <= IDLE;
//        end else begin
//            debug_state <= state;
//        end
//    end
    
    always @(posedge clk or posedge rst) begin
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
                if (valid_wb && we_i)  // If valid write cycle completed 
                    next_state = START;
            end
            START: begin
                if (valid_in_fastInvSqrt && ready_in_fastInvSqrt)
                    next_state = WAIT_FOR_RESULT;
            end
            WAIT_FOR_RESULT: begin
                if (valid_out_fastInvSqrt && ready_out_fastInvSqrt)
                    next_state = DONE;
            end
            DONE: begin
                if (valid_wb && ack_o && !we_i)
                    next_state = IDLE;
            end 
        endcase
    end
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rst_fastInvSqrt <= 1'b1;  // Reset fastInvSqrt module
            data_in_fastInvSqrt <= 16'b0;   // Reset module input signals
            valid_in_fastInvSqrt <= 1'b0;
            ready_out_fastInvSqrt <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    rst_fastInvSqrt <= 1'b0;  // De-assert fastInvSqrt module reset signal
                end
                START: begin
                    data_in_fastInvSqrt <= data_in; // Set fastInvSqrt data in
                    valid_in_fastInvSqrt <= 1'b1;    // Assert valid_in
                end
                WAIT_FOR_RESULT: begin
                    if (valid_in_fastInvSqrt && ready_in_fastInvSqrt) begin
                        valid_in_fastInvSqrt <= 1'b0;   // De-assert valid_in
                        ready_out_fastInvSqrt <= 1'b1;  // Assert ready_out
                    end
                end
                DONE: begin
                    data_out <= data_out_fastInvSqrt;
                    ready_out_fastInvSqrt <= 1'b0;  // De-assert ready_out  
                end
            endcase
        end
    end

endmodule
