// axi_write_sequences.sv - make sure guard matches!
`ifndef AXI_WRITE_SEQUENCES_SV
`define AXI_WRITE_SEQUENCES_SV

class axi_write_seq extends uvm_sequence#(axi_write_tx);
  `uvm_object_utils(axi_write_seq)
  
  rand bit [ADDR_WIDTH-1:0] addr;
  rand bit [7:0]  len;
  rand bit [2:0]  size;
  rand bit [1:0]  burst;
  
  function new(string name = "axi_write_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    axi_write_tx w_tx = axi_write_tx::type_id::create("w_tx");
    start_item(w_tx);
    assert(w_tx.randomize() with {
      awaddr  == local::addr;
      awlen   == local::len;
      awsize  == local::size;
      awburst == local::burst;
    });
    finish_item(w_tx);
  endtask
endclass

`endif
