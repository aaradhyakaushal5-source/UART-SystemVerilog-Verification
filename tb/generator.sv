class generator;
  mailbox drv_mbx;
  mailbox gen_mbx; // Mailbox to send expected data to Scoreboard
  event drv_done;
  
  // Volume Testing: Increased from 10 to 10000
  int num_packets = 2000; 

  task run();
    for (int i = 0; i < num_packets; i++) begin
      uart_item item = new();
      item.randomize();
      
      // Send a copy to the Scoreboard FIRST
      gen_mbx.put(item); 
      
      // Send the item to the Driver SECOND
      drv_mbx.put(item);
    end
    
    ->drv_done;
  endtask
endclass