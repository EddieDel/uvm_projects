`ifndef AXI_ENV_SV
 `define AXI_ENV_SV


class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)
  
  //Declarations
  axi_write_agent        write_agent;
  axi_read_agent         read_agent;
  axi_scoreboard         scoreboard;
  axi_virtual_sequencer  v_sqr;
  
  
  function new(string name = "",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    write_agent = axi_write_agent::type_id::create("write_agent",this);
    read_agent  = axi_read_agent::type_id::create("read_agent",this);
    scoreboard  = axi_scoreboard::type_id::create("scoreboard",this);
    v_sqr       = axi_virtual_sequencer::type_id::create("v_sqr",this);
    //build coverage here
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    write_agent.write_monitor.analysis_port.connect(scoreboard.write_export);
    read_agent.read_monitor.read_analysis_port.connect(scoreboard.read_export);
    
    //connect virtual sequencer to actuall sequencers.
    v_sqr.write_sqr = write_agent.write_sequencer;
    v_sqr.read_sqr  = read_agent.read_sequencer;
        
    //connect analysis port with coverage
  endfunction
  
endclass

`endif
