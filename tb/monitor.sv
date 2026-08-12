class monitor;
  virtual uart_if vif;
  mailbox mon_mbx; // Mailbox to send captured data to the Scoreboard

  task run();
    forever begin
      uart_item item = new;
      
      // 1. Wait for the Receiver to signal a new byte has arrived
      wait(vif.rdy == 1);
      @(posedge vif.clk);
      
      // 2. Capture the payload from the hardware pins
      item.payload = vif.data_out;
      
      // 3. Handshake: Tell the Receiver to clear the ready flag
      vif.rdy_clr <= 1;
      @(posedge vif.clk);
      vif.rdy_clr <= 0;
      
      //$display("T=%0t [Monitor] UART Payload = 0x%h", $time, item.payload);
      
      // Send the captured packet to the Scoreboard
      mon_mbx.put(item);
      
      // 4. Critical Fix: Wait for the hardware to confirm the flag is down
      // This prevents the 20ns double-sampling loop
      wait(vif.rdy == 0);
    end
  endtask
endclass