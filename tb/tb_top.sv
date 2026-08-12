`timescale 1ns / 1ps

// 1. Include all software classes
`include "uart_item.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "env.sv"

module tb_top;

  // 2. Generate System Clock and Reset
  bit clk;
  bit rst;

  always #5 clk = ~clk; // 100MHz System Clock (10ns period)

  // 3. Instantiate the Physical Interface
  uart_if vif(clk);

  // 4. Instantiate the Hardware (DUT)
  wire serial_tx_rx; // The wire connecting Sender TX to Receiver RX
  wire enb_tx;
  wire enb_rx;

  // Baud Rate Generator
  baud_rate_genrator baud_gen (
    .clock(clk),
    .reset(rst),
    .enb_tx(enb_tx),
    .enb_rx(enb_rx)
  );

  // UART Sender
  uart_sender sender (
    .clk(clk),
    .wr_en(vif.wr_en),
    .enb(enb_tx),
    .rst(rst),
    .data_in(vif.data_in),
    .tx(serial_tx_rx),     // Serial Output
    .tx_busy(vif.tx_busy)
  );

  // UART Receiver
  uart_reciever receiver (
    .clk(clk),
    .rst(rst),
    .rx(serial_tx_rx),     // Serial Input (Loopback)
    .rdy_clr(vif.rdy_clr),
    .clken(enb_rx),
    .rdy(vif.rdy),
    .data_out(vif.data_out)
  );

  // 5. Instantiate the Software Environment
  env environment;

  initial begin
    // Initialize Clock and Reset the hardware
    clk = 0;
    rst = 1;
    #100; // Hold reset for 100ns
    rst = 0;

    // Boot the software testbench and pass the physical interface pointer
    environment = new(vif);
    environment.run();
  end

endmodule