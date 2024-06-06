`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.05.2024 17:04:54
// Design Name: 
// Module Name: singleToFixQ12_4Seq
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


module singleToFixQ12_4Seq(
    // debug outputs
//    output reg s_axis_a_tvalid,
//    output s_axis_a_tready,
//    output reg [31:0] s_axis_a_tdata,
//    output m_axis_result_tvalid,
//    output reg m_axis_result_tready,
//    output [15:0] m_axis_result_tdata,
//    output reg [1:0] debug_state,

    input clk,
    input rst,
    input [31:0] data_in,
    input valid_in,
    output reg ready_in,
    output reg [15:0] data_out,
    output reg valid_out,
    input ready_out
    );
    
    reg s_axis_a_tvalid;
    wire s_axis_a_tready;
    reg [31:0] s_axis_a_tdata;
    wire m_axis_result_tvalid;
    reg m_axis_result_tready;
    wire [15:0] m_axis_result_tdata;
    
    singleToFixQ12_4 single_to_fix (
      .aclk(clk),                                   // input wire aclk
      .s_axis_a_tvalid(s_axis_a_tvalid),            // input wire s_axis_a_tvalid
      .s_axis_a_tready(s_axis_a_tready),            // output wire s_axis_a_tready
      .s_axis_a_tdata(s_axis_a_tdata),              // input wire [31 : 0] s_axis_a_tdata
      .m_axis_result_tvalid(m_axis_result_tvalid),  // output wire m_axis_result_tvalid
      .m_axis_result_tready(m_axis_result_tready),  // input wire m_axis_result_tready
      .m_axis_result_tdata(m_axis_result_tdata)     // output wire [15 : 0] m_axis_result_tdata
    );

    // State machine states
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
        next_state = state;  // Default to hold state
        case (state)
            IDLE: begin
                if (valid_in) begin
                    next_state = START;
                end
            end
            START: begin
                if (s_axis_a_tvalid && s_axis_a_tready) begin
                    next_state = WAIT_FOR_RESULT;
                end
            end
            WAIT_FOR_RESULT: begin
                if (m_axis_result_tvalid) begin
                    next_state = DONE;
                end
            end
            DONE: begin
                if (ready_out) begin
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    // Sequential logic for outputs and state transitions
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s_axis_a_tvalid <= 1'b0;
            m_axis_result_tready <= 1'b0;
            valid_out <= 1'b0;
            data_out <= 32'b0;
            ready_in <= 1'b0;
        end 
        else begin
            case (state)
                IDLE: begin  
                    ready_in <= 1'b1;   // Set ready_in flag
                    s_axis_a_tvalid <= 1'b0;
                    m_axis_result_tready <= 1'b0;
                    valid_out <= 1'b0;
                end
                START: begin
                    ready_in <= 1'b0;   // Remove ready_in flag
                    s_axis_a_tdata <= data_in;  // Set and validate converter input
                    s_axis_a_tvalid <= 1'b1;
                end
                WAIT_FOR_RESULT: begin
                    if (s_axis_a_tvalid && s_axis_a_tready) begin
                        s_axis_a_tvalid <= 1'b0;  // Deassert once data is accepted
                        m_axis_result_tready <= 1'b1;   // Set converter ready out flag
                    end
                end
                DONE: begin
                    if (ready_out) begin
                        data_out <= m_axis_result_tdata;    // Set and validate output data
                        valid_out <= 1'b1;
                        m_axis_result_tready <= 1'b0;  // Remove converter ready out flag
                    end else begin
                        valid_out <= 1'b0;
                    end
                end
            endcase
        end
    end

endmodule
