`ifndef AXI_READ_SEQUENCER_SV
 `define AXI_READ_SEQUENCER_SV

class axi_read_sequencer extends uvm_sequencer#(.REQ(axi_read_tx));
  `uvm_component_utils(axi_read_sequencer)
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
    
endclass
`endif
