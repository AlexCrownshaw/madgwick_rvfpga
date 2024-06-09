`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 22:43:56
// Design Name: 
// Module Name: fixQ12_4ToSingleSeq_tb
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


module fixQ12_4ToSingleSeq_tb;
    
    // Testbench signals
    reg clk;
    reg rst;
    reg [15:0] data_in;
    reg valid_in;
    wire ready_in;
    wire [31:0] data_out;
    wire valid_out;
    reg ready_out;

//    wire s_axis_a_tvalid;
//    wire s_axis_a_tready;
//    wire [15:0] s_axis_a_tdata;
//    wire m_axis_result_tvalid;
//    wire m_axis_result_tready;
//    wire[31:0] m_axis_result_tdata;
    wire [1:0] debug_state;
    
    // Instantiate the DUT (Device Under Test)
    fixQ12_4ToSingleSeq dut (
//        .s_axis_a_tvalid(s_axis_a_tvalid),
//        .s_axis_a_tready(s_axis_a_tready),
//        .s_axis_a_tdata(s_axis_a_tdata),
//        .m_axis_result_tvalid(m_axis_result_tvalid),
//        .m_axis_result_tready(m_axis_result_tready),
//        .m_axis_result_tdata(m_axis_result_tdata),
        .debug_state(debug_state),
        
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .data_out(data_out),
        .valid_out(valid_out),
        .ready_out(ready_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period (100MHz)
    end
    
    // Test Sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        data_in = 16'b0;
        valid_in = 1'b0;
        ready_out = 1'b0;
        #25 rst = 0;

        data_in = 16'b0000000000010000; // 1.0
        valid_in = 1'b1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end 
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        
        data_in = 16'b0000000010100000; // 2.5
        valid_in = 1'b1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end 
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        
        data_in = 16'b0000000000000001; // 0.0625
        valid_in = 1'b1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end 
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        
        data_in = 16'b0000100101100100; // 150.25
        valid_in = 1'b1;
        wait (valid_in && ready_in);
        @ (posedge clk);
        if (valid_in && ready_in) begin
            valid_in = 1'b0;
            ready_out <= 1'b1;
        end 
        wait (valid_out && ready_out);
        @ (posedge clk);
        if (valid_out && ready_out) begin
            ready_out <= 1'b0;
        end
        
        #100;
        $finish;
    end

endmodule
