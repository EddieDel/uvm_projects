`ifndef APB_ENVIRONMENT_SV
 `define APB_ENVIRONMENT_SV

class apb_environment extends uvm_env;
  `uvm_component_utils(apb_environment)
  
  apb_agent agent;
  //apb_scoreboard
  
  
  function new (string name= "", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = apb_agent::type_id::create("agent",this);
    //build scoreboard here later.
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //connect monitor analysis port with scoreboard
  endfunction

endclass

`endif
