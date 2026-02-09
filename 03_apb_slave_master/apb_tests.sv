`ifndef APB_TESTS_SV
 `define APB_TESTS_SV

class apb_tests extends apb_test_base;
  `uvm_component_utils(apb_tests)
  
  
  function new (string name = "", uvm_component parent);
    super.new (name,parent);
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this,"=========== Running Tests ===========");
    `uvm_info ("TESTS", "Placeholder for actual tests",UVM_LOW);    
    phase.drop_objection(this,"=========== Finished Tests ===========");
  endtask
               
  
  
endclass
`endif
