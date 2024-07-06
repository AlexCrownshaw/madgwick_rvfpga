`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2024 21:26:02
// Design Name: 
// Module Name: fastInvSqrt_top_tb
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


module fastInvSqrt_top_tb;

    reg clk;
    reg rst;
    reg [31:0] adr_i;
    reg [15:0] dat_i;
    wire [15:0] dat_o;
    reg we_i;
    reg stb_i;
    reg cyc_i;
    wire ack_o;
    
//    wire [15:0] data_in;
//    wire [15:0] data_out;
    
//    wire rst_fastInvSqrt;
//    wire [15:0] data_in_fastInvSqrt;
//    wire valid_in_fastInvSqrt;
//    wire ready_in_fastInvSqrt;
//    wire [15:0] data_out_fastInvSqrt;
//    wire valid_out_fastInvSqrt;
//    wire ready_out_fastInvSqrt;
//    wire [2:0] debug_state;

    // Instantiate the fastInvSqrt_top module
    fastInvSqrt_top uut (
        .clk(clk),
        .rst(rst),
        .adr_i(adr_i),
        .dat_i(dat_i),
        .dat_o(dat_o),
        .we_i(we_i),
        .stb_i(stb_i),
        .cyc_i(cyc_i),
        .ack_o(ack_o)        

//        .data_in(data_in),
//        .data_out(data_out),
//        .rst_fastInvSqrt(rst_fastInvSqrt),
//        .data_in_fastInvSqrt(data_in_fastInvSqrt),
//        .valid_in_fastInvSqrt(valid_in_fastInvSqrt),
//        .ready_in_fastInvSqrt(ready_in_fastInvSqrt),
//        .data_out_fastInvSqrt(data_out_fastInvSqrt),
//        .valid_out_fastInvSqrt(valid_out_fastInvSqrt),
//        .ready_out_fastInvSqrt(ready_out_fastInvSqrt),
//        .debug_state(debug_state)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        adr_i = 0;
        dat_i = 0;
        we_i = 0;
        stb_i = 0;
        cyc_i = 0;

        // Reset the DUT
        #10 rst = 0;

        // Wait for a few clock cycles
        #20;

        // Write operation
        adr_i = 32'h00000000; // Set address (not used in this example)
        dat_i = 16'b0000_0000_0000_1000; // Set data to write
        we_i = 1; // Enable write
        stb_i = 1; // Strobe signal
        cyc_i = 1; // Cycle signal

        // Wait for acknowledge
        wait (ack_o);

        // Deassert write signals
        we_i = 0;
        stb_i = 0;
        cyc_i = 0;
        
        # 200 // Delay before read operation

        // Read operation (assuming the output of the fastInvSqrt is immediate for this test)
        we_i = 0; // Disable write
        stb_i = 1; // Strobe signal
        cyc_i = 1; // Cycle signal

        // Wait for acknowledge
        wait (ack_o);
        @ (posedge clk);
        stb_i = 0;  // Deassert read signals
        cyc_i = 0;

        // End of test
        #10 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0d, clk: %b, rst: %b, adr_i: %h, dat_i: %h, dat_o: %h, we_i: %b, stb_i: %b, cyc_i: %b, ack_o: %b",
                 $time, clk, rst, adr_i, dat_i, dat_o, we_i, stb_i, cyc_i, ack_o);
    end

endmodule