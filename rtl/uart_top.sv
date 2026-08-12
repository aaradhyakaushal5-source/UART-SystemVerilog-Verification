module uart_top (
    input  logic clk,
    input  logic rst,
    input  logic wr_en,
    input  logic [7:0] data_in,
    input  logic rx,
    input  logic rdy_clr,
    output logic tx,
    output logic tx_busy,
    output logic rdy,
    output logic [7:0] data_out
);

    // Internal wires connecting the baud generator to the sender and receiver
    logic enb_tx;
    logic enb_rx;

    // 1. Instantiate the Baud Rate Generator
    baud_rate_genrator baud_gen (
        .clock(clk),
        .reset(rst),
        .enb_tx(enb_tx),
        .enb_rx(enb_rx)
    );

    // 2. Instantiate the Transmitter (Sender)
    uart_sender sender (
        .clk(clk),
        .wr_en(wr_en),
        .enb(enb_tx),
        .rst(rst),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // 3. Instantiate the Receiver
    uart_reciever receiver (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rdy_clr(rdy_clr),
        .clken(enb_rx),
        .rdy(rdy),
        .data_out(data_out)
    );

endmodule