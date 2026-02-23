`ifndef AXI_TEST_BASE_SV
 `define AXI_TEST_BASE_SV

class axi_test_base extends uvm_test;
  `uvm_component_utils(axi_test_base)
  
  axi_env environment;
  
  function new (string name = "", uvm_component parent);
    super.new (name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    environment = axi_env::type_id::create("environment",this);
  endfunction
  
  
endclass
`endif
