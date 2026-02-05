`ifndef MUX_ENV_SV
 `define MUX_ENV_SV

class mux_env extends uvm_env;
  `uvm_component_utils(mux_env)
  
  mux_agent agent;
  mux_scoreboard scoreboard;

  
  function new (string name = "",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = mux_agent::type_id::create("agent",this);
    
    scoreboard = mux_scoreboard::type_id::create("scoreboard",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.output_port.connect(scoreboard.analysis_export);
  endfunction
  
endclass
`endif
