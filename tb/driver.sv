class driver;
  virtual uart_if vif;
  mailbox drv_mbx;

  task run();
    forever begin
      uart_item item;
      drv_mbx.get(item);
      
      // 1. Wait until the hardware is idle
      wait(vif.tx_busy == 0); 
      @(posedge vif.clk);

      // 2. Inject the data and pulse the write enable
      vif.data_in <= item.payload;
      vif.wr_en   <= 1;
      
      // 3. Hold write enable for exactly one clock cycle
      @(posedge vif.clk);
      vif.wr_en   <= 0;
      
      //$display("T=%0t [Driver] UART Payload = 0x%h", $time, item.payload);(bcz lot of data is transferre
      
      // 4. Wait for the hardware to acknowledge it is busy before looping
      // This prevents the driver from instantly looping and firing again 
      // before the hardware has time to raise the tx_busy flag.
      wait(vif.tx_busy == 1);
    end
  endtask
endclass