// 1. THE TRANSACTION ITEM
class uart_item;
  rand bit [7:0] payload;

  function void print(string tag="");
    $display("T=%0t [%s] UART Payload = 0x%h", $time, tag, payload);
  endfunction
endclass