`timescale 1ns / 1ps

// CLOCK GENERATION LOGIC FOR ACHIEVING A BAUD RATE OF 9600 
module baud_rate_genrator(
    input clock,
    input reset,
    output reg enb_tx,
    output reg enb_rx // Explicitly defined as reg to prevent wire inference
);
    
    parameter clk_freq = 100000000; // SYSTEM CLOCK FREQUENCY
    parameter baud_rate = 9600;     // REQUIRED BAUD RATE
    
    reg [15:0] counter_tx; // REGISTER FOR CREATING THE SENDER CLOCK
    reg [15:0] counter_rx; // REGISTER FOR CREATING THE RECIEVER CLOCK

    parameter divisor_tx = clk_freq / baud_rate;        // PRESCALAR OF SENDER
    parameter divisor_rx = clk_freq / (16 * baud_rate); // PRESCALAR OF RECIEVER
           
    // SENDER CLOCK GENERATION LOGIC
    always @(posedge clock) begin
        if (reset) begin
            counter_tx <= 0;
            enb_tx     <= 1'b0;
            // Removed illegal enb_rx assignment from this block
        end
        // FOR 10,416 CLOCK CYCLES OF SYSTEM CLOCK 1 CLOCK CYCLE IS GENERATED
        else if (counter_tx == divisor_tx - 1) begin
            enb_tx     <= 1'b1;
            counter_tx <= 0;
        end else begin
            counter_tx <= counter_tx + 1'b1;
            enb_tx     <= 1'b0;
        end
    end
     
    // LOGIC FOR RECIEVER CLOCK
    always @(posedge clock) begin
        if (reset) begin
            counter_rx <= 0;
            enb_rx     <= 1'b0; // Correctly isolated reset assignment for enb_rx
        end
        // FOR GENERATING 16x RECEIVER CLOCK
        else if (counter_rx == divisor_rx - 1) begin
            counter_rx <= 0;
            enb_rx     <= 1'b1;
        end else begin
            counter_rx <= counter_rx + 1'b1;
            enb_rx     <= 1'b0;
        end
    end

endmodule