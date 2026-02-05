`ifndef MUX_AGENT_SV
 `define MUX_AGENT_SV

class mux_agent extends uvm_agent;
  `uvm_component_utils(mux_agent)
  
  typedef virtual mux_if mux_vif;

  mux_agent_config agent_config;
  mux_driver driver;
  mux_monitor monitor;
  mux_coverage coverage;
  uvm_sequencer#(mux_item_drv) sequencer;
  
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_config = mux_agent_config::type_id::create("agent_config",this);
    
    driver = mux_driver::type_id::create("driver",this);
    monitor = mux_monitor::type_id::create("monitor",this);
    
    if (agent_config.get_has_coverage()) begin
    	coverage = mux_coverage::type_id::create("coverage",this);
    end
    
    sequencer = uvm_sequencer#(mux_item_drv)::type_id::create("sequencer",this);
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
    mux_vif vif;
    string vif_name = "vif";
    
    super.connect_phase(phase);
  
    if(!uvm_config_db#(virtual mux_if)::get(this, "","vif", vif)) begin
      `uvm_fatal("MUX_NO_VIF", $sformatf("Could not get from the database the MUX virtual interface using name \"%0s\"", vif_name))
    end
    else begin
       agent_config.set_vif(vif);
    end
    
    monitor.agent_config = agent_config;
    //monitor.output_port.connect(coverage.port_item);
    
    if(agent_config.get_active_passive() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      driver.agent_config = agent_config;
    end
    
    if(agent_config.get_has_coverage()) begin
      coverage.agent_config = agent_config;
      monitor.output_port.connect(coverage.port_item);
    end

  endfunction
                                 
endclass

`endif
