`ifndef COUNTER_AGENT_SV
 `define COUNTER_AGENT_SV


class counter_agent extends uvm_agent implements reset_handler;
  `uvm_component_utils(counter_agent);
  typedef virtual counter_if counter_vif;
  
  agent_config ac;
  counter_driver driver;
  counter_monitor monitor;
  counter_coverage coverage;
  counter_sequencer#(seq_item_drv) sequencer;
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ac = agent_config::type_id::create("ac",this);
    driver=counter_driver::type_id::create("driver",this);
    monitor = counter_monitor::type_id::create("monitor",this);
    sequencer = counter_sequencer#(seq_item_drv)::type_id::create("sequencer",this);
    
    if(ac.get_has_coverage()) begin
      coverage = counter_coverage::type_id::create("coverage",this);
    end
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    counter_vif vif;
    string vif_name = "vif";
    
    super.connect_phase(phase);
      
    if(!uvm_config_db#(virtual counter_if)::get(this, "","vif", vif)) begin
      	`uvm_fatal("MUX_NO_VIF", $sformatf("Could not get from the database the MUX virtual interface using name \"%0s\"", vif_name))
    end
    else begin
       ac.set_vif(vif);
    end
      monitor.ac = ac;
    if(ac.get_active_passive() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      driver.ac = ac;
    end
    
    if(ac.get_has_coverage()) begin
      coverage.ac = ac;
      monitor.analysis_port.connect(coverage.port_item);      
    end
      
  endfunction
  
  //Reset Logic
  // Children refers to the components instanciated under agent.
  
  virtual function void handle_reset(uvm_phase phase);
    uvm_component children[$];
    get_children(children);
    
    foreach (children[idx]) begin
      reset_handler reset_handler;
      
      if($cast(reset_handler, children[idx])) begin
        reset_handler.handle_reset(phase);
      end
    end
  endfunction

  virtual task wait_reset_start();
    ac.wait_reset_start();
  endtask
  
  virtual task wait_reset_end();
    ac.wait_reset_end();
  endtask
  
  
  virtual task run_phase(uvm_phase phase);
  	forever begin
      wait_reset_start();
      handle_reset(phase);
      wait_reset_end();
    end  
  endtask
  
  
  
  
  
endclass
`endif
