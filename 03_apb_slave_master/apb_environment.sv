`ifndef APB_ENVIRONMENT_SV
 `define APB_ENVIRONMENT_SV

class apb_environment extends uvm_env;
  `uvm_component_utils(apb_environment)
  
  apb_agent agent;
  apb_scoreboard scoreboard;
  
  
  function new (string name= "", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = apb_agent::type_id::create("agent",this);
    scoreboard   = apb_scoreboard::type_id::create("scoreboard",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.master_monitor.analysis_port.connect(scoreboard.analysis_export);
  endfunction

endclass

`endif
