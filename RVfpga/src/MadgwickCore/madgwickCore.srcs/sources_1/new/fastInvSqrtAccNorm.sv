`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.05.2024 15:04:00
// Design Name: 
// Module Name: fastInvSqrtAccNorm
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


module fastInvSqrtAccNorm(
    // Debug I/O
    output reg [2:0] debug_state,
    output reg rst_fix_to_single,
    output reg valid_in_fix_to_single,
    output ready_in_fix_to_single,
    output valid_out_fix_to_single,
    output reg ready_out_fix_to_single,
    
    output reg rst_single_to_fix,
    output reg valid_in_single_to_fix,
    output ready_in_single_to_fix,
    output valid_out_single_to_fix,
    output reg ready_out_single_to_fix,
    
    output reg [15:0] x_half,
    output reg [31:0] x_float,
    output reg [31:0] y0_float,
    output reg [15:0] y0_fix,
    output reg [15:0] y,
       
    input clk,
    input rst,
    input [15:0] data_in,
    input valid_in,
    output reg ready_in,
    output reg [15:0] data_out,
    output reg valid_out,
    input ready_out
    );
    
//    // Registers
//    reg [15:0] x_half;
//    reg [31:0] x_float;
//    reg [31:0] y0_float;
//    reg [15:0] y0_fix;
//    reg [15:0] y;
    
//    // Fix to single module instantiation 
//    reg rst_fix_to_single;
//    reg valid_in_fix_to_single;
//    wire ready_in_fix_to_single;
//    wire valid_out_fix_to_single;
//    reg ready_out_fix_to_single;
    
    fixQ12_4ToSingleSeq fix_to_single(
        .clk(clk),
        .rst(rst_fix_to_single),
        .data_in(data_in),
        .valid_in(valid_in_fix_to_single),
        .ready_in(ready_in_fix_to_single),
        .data_out(x_float),
        .valid_out(valid_out_fix_to_single),
        .ready_out(ready_out_fix_to_single)
    );
    
//    // Single to fix module instantiation
//    reg rst_single_to_fix;
//    reg valid_in_single_to_fix;
//    wire ready_in_single_to_fix;
//    wire valid_out_single_to_fix;
//    reg ready_out_single_to_fix;
    
    singleToFixQ12_4Seq single_to_fix(
        .clk(clk),
        .rst(rst_single_to_fix),
        .data_in(y0_float),
        .valid_in(valid_in_single_to_fix),
        .ready_in(ready_in_single_to_fix),
        .data_out(y0_fix),
        .valid_out(valid_out_single_to_fix),
        .ready_out(ready_out_single_to_fix)
    );
    
    // Newton-Raphson logic instantiation
    newtonRaphson newt_raph_logic(
        .y0(y0_fix),
        .x_half(x_half),
        .y(y)
    );
    
    // State machine states
    typedef enum reg [2:0] {
        IDLE,
        START,
        FIX_TO_SINGLE,
        BIT_HACK,
        SINGLE_TO_FIX,
        DONE
    } state_t;
    state_t state, next_state;
    
    // Update debug_state for monitoring
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            debug_state <= IDLE;
        end else begin
            debug_state <= state;
        end
    end
    
    // Sequential logic for state transition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Combinational logic for next state
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (valid_in && ready_in)
                    next_state = START;
            end
            START: begin
                if (valid_in_fix_to_single && ready_in_fix_to_single)
                    next_state = FIX_TO_SINGLE;
            end
            FIX_TO_SINGLE: begin
                if (valid_out_fix_to_single && ready_out_fix_to_single)
                    next_state = BIT_HACK;
            end
            BIT_HACK: begin
                if (valid_in_single_to_fix && ready_in_single_to_fix)
                    next_state = SINGLE_TO_FIX;
            end
            SINGLE_TO_FIX: begin
                if (valid_out_single_to_fix && ready_out_single_to_fix)
                    next_state = DONE;
            end
            DONE: begin
                if (ready_out)
                    next_state = IDLE;
            end
        endcase
    end
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rst_fix_to_single <= 1'b1;  // Reset converter seqs
            rst_single_to_fix <= 1'b1;
            
            valid_in_fix_to_single <= 1'b0; // Invalidate converter signals
            ready_out_fix_to_single <= 1'b0;
            valid_in_single_to_fix <= 1'b0;
            ready_out_single_to_fix <= 1'b0;
            
            x_half <= 16'b0;    // Reset registers
            x_float <= 32'b0;
            y0_float <= 32'b0;
            y0_fix <= 16'b0;
              
            ready_in <= 1'b0;     // Invalidate and clear module outputs
            valid_out <= 1'b0;
            data_out <= 16'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    rst_fix_to_single <= 1'b0;  // De-assert converter resets
                    rst_single_to_fix <= 1'b0;
                                
                    ready_in <= 1'b1;   // Set ready_in flag
                    valid_out <= 1'b0;   // De-assert valid out 
                end
                START: begin                    
                    ready_in <= 1'b0;   // Clear ready in flag

					x_half <= data_in >> 1; // Compute x_half with logical bit shift right

                    valid_in_fix_to_single <= 1'b1; // Assert fix to single valid in
                end
                FIX_TO_SINGLE: begin
                    if (valid_in_fix_to_single && ready_in_fix_to_single) begin
                        valid_in_fix_to_single <= 1'b0; // De-assert fix to single valid in
                        ready_out_fix_to_single <= 1'b1;   // Assert fix to single ready_out
                    end
                end
                BIT_HACK: begin
                    if (valid_out_fix_to_single && ready_out_fix_to_single) begin
                        ready_out_fix_to_single <= 1'b0; // De-assert fix to single ready out
                        
                        y0_float <= 32'h5f3759df - (x_float >> 1);  // Integer subtract to compute y0 in single EEE754 representation
                        
                        valid_in_single_to_fix <= 1'b1; // Assert single to fix valid in
                    end
                end
                SINGLE_TO_FIX: begin
                    if (valid_in_single_to_fix && ready_in_single_to_fix) begin
                        valid_in_single_to_fix <= 1'b0; // De-assert single to fix valid in
                        ready_out_single_to_fix <= 1'b1;    // Assert single to fix ready out
                    end
                end
                DONE: begin
                    if (valid_out_single_to_fix && ready_out_single_to_fix) begin
                        ready_out_single_to_fix <= 1'b0;    // De-assert single to fix ready out
                    end
                    
                    if (ready_out) begin    // Set and validate output when ready out asserted
                        data_out <= y;  
                        valid_out <= 1'b1;
                    end else begin
                        data_out <= 1'b0;
                    end
                end
            endcase
        end
    end
    
endmodule
