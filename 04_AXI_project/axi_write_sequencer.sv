`ifndef AXI_WRITE_SEQUENCER_SV
 `define AXI_WRITE_SEQUENCER_SV

class axi_write_sequencer extends uvm_sequencer#(.REQ(axi_write_tx));
  `uvm_component_utils(axi_write_sequencer)
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
    
endclass
`endif
