`ifndef AXI_WRITE_AGENT_SV
 `define AXI_WRITE_AGENT_SV

class axi_write_agent extends uvm_agent;
  `uvm_component_utils(axi_write_agent)
  
  //Variable declarations
  virtual axi_if      vif;
  axi_write_driver    write_driver;
  axi_write_sequencer write_sequencer;
  axi_write_monitor   write_monitor;
  
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif)) begin
      `uvm_fatal("Write Agent","Could not retrieve vif")
    end
    write_driver    = axi_write_driver::type_id::create("write_driver",this);
    write_sequencer = axi_write_sequencer::type_id::create("write_sequencer",this);
    write_monitor   = axi_write_monitor::type_id::create("write_monitor",this);
    write_driver.vif  = vif;
    write_monitor.vif = vif;    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    write_driver.seq_item_port.connect(write_sequencer.seq_item_export);
  endfunction
  
endclass

`endif
