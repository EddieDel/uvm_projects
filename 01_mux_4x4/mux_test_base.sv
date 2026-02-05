`ifndef MUX_TEST_BASE_SV
 `define MUX_TEST_BASE_SV



class mux_test_base extends uvm_test;
  `uvm_component_utils(mux_test_base)
  
  mux_env env;
  
  function new(string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = mux_env::type_id::create("env",this); 
  endfunction
  
endclass

`endif
