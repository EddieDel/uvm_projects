`ifndef APB_AGENT_SV
 `define APB_AGENT_SV

class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  

   virtual apb_if vif;
   apb_master_monitor master_monitor;
  
  function new (string name =" ",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_AGENT", "Could not get vif from config_db")
      
    
                     
    //create driver instance
      master_monitor = apb_master_monitor::type_id::create("master_monitor",this);
    master_monitor.vif = vif;
    
    //create sequencer instance
    
    //set interface in database? here or in tesbench.sv???
                     
                     
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //connect driver with sequencer
  endfunction
  
    
  
  
endclass
`endif
