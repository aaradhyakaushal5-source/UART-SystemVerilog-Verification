`timescale 1ns / 1ps

module tb_uart_sanity_check();
    // Inputs to UUT
    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg wr_en;
    reg rdy_clr;

    // Outputs from UUT
    wire rdy;
    wire busy;
    wire [7:0] data_out;

    // Instantiate the Top Module
    uart_top uut (
        .rst(rst),
        .data_in(data_in),
        .wr_en(wr_en),
        .clk(clk),
        .rdy_clr(rdy_clr),
        .rdy(rdy),
        .busy(busy),
        .data_out(data_out)
    );

    // Generate a 100 MHz clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0; 
        rst = 1; 
        data_in = 8'h00; 
        wr_en = 0; 
        rdy_clr = 0;

        // Release reset after 100ns
        #100 rst = 0; 
        #100;

        // --- TEST 1: Send 8'h55 (Binary 01010101) ---
        $display("[%0t] Starting transmission of 8'h55...", $time);
        data_in = 8'h55;
        wr_en = 1;
        #10 wr_en = 0; // Pulse write enable for 1 clock cycle

        // Wait for receiver to flag that data is ready
        @(posedge rdy);
        $display("[%0t] Reception complete. Expected: 55, Received: %h", $time, data_out);
        
        // Clear the ready flag
        #10 rdy_clr = 1; 
        #10 rdy_clr = 0;
        
        #100; // Small delay before next test

        // --- TEST 2: Send 8'hAA (Binary 10101010) ---
        $display("[%0t] Starting transmission of 8'hAA...", $time);
        data_in = 8'hAA;
        wr_en = 1;
        #10 wr_en = 0;

        @(posedge rdy);
        $display("[%0t] Reception complete. Expected: aa, Received: %h", $time, data_out);

        // End simulation
        #100;
        $finish;
    end
endmodule