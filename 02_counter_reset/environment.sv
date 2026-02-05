`ifndef ENVIRONMENT_SV
 `define ENVIRONMENT_SV

class environment extends uvm_env;
  `uvm_component_utils(environment)
  
  counter_agent agent;
  counter_scoreboard scoreboard;
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = counter_agent::type_id::create("agent",this);
    scoreboard = counter_scoreboard::type_id::create("scoreboard",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.analysis_port.connect(scoreboard.analysis_export);
  endfunction
  
endclass

`endif
