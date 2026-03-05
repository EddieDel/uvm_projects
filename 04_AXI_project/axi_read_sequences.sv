// axi_read_sequences.sv
`ifndef AXI_READ_SEQUENCES_SV
`define AXI_READ_SEQUENCES_SV

class axi_read_seq extends uvm_sequence#(axi_read_tx);
  `uvm_object_utils(axi_read_seq)
  
  rand bit [ADDR_WIDTH-1:0] addr;
  rand bit [7:0]  len;
  rand bit [2:0]  size;
  rand bit [1:0]  burst;
  
  function new(string name = "axi_read_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    axi_read_tx r_tx = axi_read_tx::type_id::create("r_tx");
    start_item(r_tx);
    assert(r_tx.randomize() with {
      araddr  == local::addr;
      arlen   == local::len;
      arsize  == local::size;
      arburst == local::burst;
    });
    finish_item(r_tx);
  endtask
endclass

`endif
