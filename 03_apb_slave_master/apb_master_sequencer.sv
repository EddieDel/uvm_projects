`ifndef APB_MASTER_SEQUENCER_SV
 `define APB_MASTER_SEQUENCER_SV

class apb_master_sequencer extends uvm_sequencer#(.REQ(apb_tx));
  `uvm_component_utils(apb_master_sequencer)
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
    
endclass
`endif
