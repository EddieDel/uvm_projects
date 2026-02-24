`ifndef AXI_READ_AGENT_SV
 `define AXI_READ_AGENT_SV

class axi_read_agent extends uvm_agent;
  `uvm_component_utils(axi_read_agent)
  
  //Variable declarations
  virtual axi_if      vif;
  axi_read_driver    read_driver;
  axi_read_sequencer read_sequencer;
  axi_read_monitor   read_monitor;
  
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif)) begin
      `uvm_fatal("Write Agent","Could not retrieve vif")
    end
    read_driver    = axi_read_driver::type_id::create("read_driver",this);
    read_sequencer = axi_read_sequencer::type_id::create("read_sequencer",this);
    read_monitor   = axi_read_monitor::type_id::create("read_monitor",this);
    read_driver.vif  = vif;
    read_monitor.vif = vif;    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    read_driver.seq_item_port.connect(read_sequencer.seq_item_export);
  endfunction
  
endclass

`endif
