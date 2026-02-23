`ifndef AXI_WRITE_SEQUENCES_SV
`define AXI_WRITE_SEQUENCES_SV

class axi_write_sequences extends uvm_sequence#(.REQ(axi_write_tx));
  `uvm_object_utils(axi_write_sequences)
  
  axi_write_tx tx_item;
  
  function new(string name ="");
    super.new(name);
  endfunction
  
  virtual task body();
    axi_write_tx rsp;
    repeat(30) begin
      `uvm_do(tx_item);
      get_response(rsp); // Get response for each item being sent
    end
  endtask
endclass


`endif
