`ifndef APB_TEST_BASE_SV
 `define APB_TEST_BASE_SV

class apb_test_base extends uvm_test;
  `uvm_component_utils(apb_test_base)
  
  apb_environment environment;
  
  function new (string name = "", uvm_component parent);
    super.new (name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    environment = apb_environment::type_id::create("environment",this);
  endfunction
  
  
endclass
`endif
