`ifndef AXI_VIRTUAL_SEQUENCER_SV
 `define AXI_VIRTUAL_SEQUENCER_SV

class axi_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_virtual_sequencer)
  
  uvm_sequencer_base write_sqr;
  uvm_sequencer_base read_sqr;
  
  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction
endclass

`endif
