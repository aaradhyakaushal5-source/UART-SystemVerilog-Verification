`timescale 1ns / 1ps

module uart_top (
    input clk,
    input rst,
    input [7:0] data_in,
    input wr_en,
    input rdy_clr,
    output rdy,
    output busy,
    output [7:0] data_out
);

    wire rx_clk_en; 
    wire tx_clk_en; 
    wire tx_temp; // Internal loopback wire connecting sender TX to receiver RX

    baud_rate_genrator bg (
        .clock(clk),
        .reset(rst),
        .enb_tx(tx_clk_en),
        .enb_rx(rx_clk_en)
    );

    uart_sender us (
        .clk(clk),
        .wr_en(wr_en),
        .enb(tx_clk_en),
        .rst(rst),
        .data_in(data_in),
        .tx(tx_temp),
        .tx_busy(busy)
    );

    uart_reciever ur (
        .clk(clk),
        .rst(rst),
        .rx(tx_temp),
        .rdy_clr(rdy_clr),
        .clken(rx_clk_en),
        .rdy(rdy),
        .data_out(data_out)
    );

endmodule