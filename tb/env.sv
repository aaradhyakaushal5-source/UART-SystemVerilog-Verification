class env;
  generator  g0;
  driver     d0;
  monitor    m0;
  scoreboard s0;
  
  mailbox shared_drv_mbx;
  mailbox shared_mon_mbx;
  mailbox shared_gen_mbx; // The shared mailbox for expected data

  // Virtual interface handle to pass down
  virtual uart_if vif;

  function new(virtual uart_if v);
    this.vif = v;
    
    // 1. Create the shared mailboxes in memory
    shared_drv_mbx = new(); 
    shared_mon_mbx = new();
    shared_gen_mbx = new(); // Create the memory space
    
    // 2. Instantiate the components
    g0 = new();
    d0 = new();
    m0 = new();
    s0 = new(shared_mon_mbx,shared_gen_mbx );
    
    // 3. Wire the Generator mailboxes
    g0.drv_mbx = shared_drv_mbx;
    g0.gen_mbx = shared_gen_mbx; // Give Generator access
    
    // 4. Wire the Driver
    d0.drv_mbx = shared_drv_mbx;
    d0.vif     = this.vif;
    
    // 5. Wire the Monitor
    m0.mon_mbx = shared_mon_mbx;
    m0.vif     = this.vif;
    
    // 6. Wire the Scoreboard
    s0.mon_mbx = shared_mon_mbx;
    s0.gen_mbx = shared_gen_mbx; // Give Scoreboard access
  endfunction

  task run();
    fork
      g0.run();
      d0.run();
      m0.run();
      s0.run();
    join_any
    
    // Wait until the Scoreboard has graded every packet the Generator created
    wait((s0.match_count + s0.error_count) == g0.num_packets); 
    
    // Add a small buffer to allow final console prints to clear
    #100; 
    
     s0.report(); 
      
    $display("T=%0t [Environment] Test Finished. Check Scoreboard for results.", $time);
    $finish;
  endtask

endclass