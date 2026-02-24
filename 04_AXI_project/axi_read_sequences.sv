`ifndef AXI_READ_SEQUENCES_SV
 `define AXI_READ_SEQUENCES_SV

class axi_read_sequences extends uvm_sequence#(.REQ(axi_read_tx));
  `uvm_object_utils(axi_read_sequences)
  
  axi_read_tx tx_item;
  
  function new(string name ="");
    super.new(name);
  endfunction
  
  virtual task body();
    axi_read_tx rsp;
    repeat(30) begin
      `uvm_do(tx_item);
      get_response(rsp); // Get response for each item being sent
    end
  endtask
endclass


`endif
