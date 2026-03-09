`ifndef AXI_VIRTUAL_SEQUENCES_SV
`define AXI_VIRTUAL_SEQUENCES_SV

class write_read_back_seq extends uvm_sequence;
  `uvm_object_utils(write_read_back_seq)
  `uvm_declare_p_sequencer(axi_virtual_sequencer)
  
  axi_write_seq wr_seq;
  axi_read_seq  rd_seq;
  
  function new(string name = "write_read_back_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    // Create sub-sequences
    wr_seq = axi_write_seq::type_id::create("wr_seq");
    rd_seq = axi_read_seq::type_id::create("rd_seq");
    
    // Configure and start write
    wr_seq.addr  = 32'h100;
    wr_seq.len   = 3;
    wr_seq.size  = 2;
    wr_seq.burst = 2'b01;  // INCR
    wr_seq.start(p_sequencer.write_sqr);
    
    // Configure and start read
    rd_seq.addr  = 32'h100;
    rd_seq.len   = 3;
    rd_seq.size  = 2;
    rd_seq.burst = 2'b01;  // INCR
    rd_seq.start(p_sequencer.read_sqr);
  endtask
  
endclass

`endif
