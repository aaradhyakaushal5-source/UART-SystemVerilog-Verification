class scoreboard;
  mailbox mon_mbx;
  mailbox gen_mbx;
  
  int match_count;
  int error_count;
  
  bit [7:0] sample_payload;
  
  covergroup cg;
    payload_cov: coverpoint sample_payload {
      option.auto_bin_max = 256; 
    }
  endgroup
  
  function new(mailbox mon_mbx, mailbox gen_mbx);
    this.mon_mbx = mon_mbx;
    this.gen_mbx = gen_mbx;
    cg = new(); 
  endfunction
  
  task run();
    forever begin
      uart_item expected_item;
      uart_item actual_item;
      
      gen_mbx.get(expected_item);
      mon_mbx.get(actual_item);
      
      if (expected_item.payload == actual_item.payload) begin
        match_count++; 
        
        sample_payload = actual_item.payload;
        cg.sample();
        
        
        
      end else begin
        error_count++; 
      end
    end
  endtask
  
  function void report();
    real total_packets;
    real success_rate;
    real coverage_rate;
    
    total_packets = match_count + error_count;
    coverage_rate = cg.get_coverage();
    
    if (total_packets > 0) begin
      success_rate = (match_count / total_packets) * 100.0;
      $display("==================================================");
      $display(" [VERIFICATION SUMMARY] ");
      $display(" Total Packets Processed : %0d", total_packets);
      $display(" Total Matches (PASS)    : %0d", match_count);
      $display(" Total Errors (FAIL)     : %0d", error_count);
      $display(" Final Success Rate      : %0.2f%%", success_rate);
      $display(" Final Coverage Rate     : %0.2f%%", coverage_rate);
      $display("==================================================");
    end
  endfunction
endclass