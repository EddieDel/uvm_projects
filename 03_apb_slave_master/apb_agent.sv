`ifndef APB_AGENT_SV
 `define APB_AGENT_SV

class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  

   virtual apb_if vif;
   
   apb_master_monitor   master_monitor;
   apb_master_driver    master_driver;
   apb_master_sequencer master_sequencer;
   apb_master_coverage  master_coverage;

  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_AGENT", "Could not get vif from config_db")
           
    //create components
    master_monitor   = apb_master_monitor::type_id::create("master_monitor",this);
    master_driver    = apb_master_driver::type_id::create("master_driver",this);
    master_sequencer = apb_master_sequencer::type_id::create("master_sequencer",this);
    master_coverage  = apb_master_coverage::type_id::create("master_coverage",this);
    master_monitor.vif = vif;
    master_driver.vif = vif;
                
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    master_driver.seq_item_port.connect(master_sequencer.seq_item_export);  // Driver - sequencer seq_item_port
    master_monitor.analysis_port.connect(master_coverage.port_item);
  endfunction
  
    
  
  
endclass
`endif
