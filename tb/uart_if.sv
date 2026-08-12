// 2. THE HARDWARE/SOFTWARE INTERFACE
interface uart_if (input bit clk);
  logic rst;

  // Sender parallel side (Driven by the Driver)
  logic [7:0] data_in;
  logic       wr_en;
  logic       tx_busy;
  logic       tx_busy;

  // Receiver parallel side (Watched by the Monitor)
  logic [7:0] data_out;
  logic       rdy;
  logic       rdy_clr;
endinterface