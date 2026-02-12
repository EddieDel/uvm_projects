`ifndef APB_MASTER_MONITOR_SV
`define APB_MASTER_MONITOR_SV

class apb_master_monitor extends uvm_monitor;
  `uvm_component_utils(apb_master_monitor)
   
  // Virtual interface handle
  virtual apb_if vif;
  
  // Analysis port
  uvm_analysis_port#(apb_tx) analysis_port;
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_MON", "Could not get vif from config_db")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      apb_tx txn;
      txn = apb_tx::type_id::create("txn");
      
      // Wait for SETUP phase (PSEL=1, PENABLE=0)
      wait(vif.cb_mon.psel && !vif.cb_mon.penable);
      @(vif.cb_mon);
      
      // Capture request
      txn.paddr = vif.cb_mon.paddr;
      txn.direction = apb_direction_e'(vif.cb_mon.pwrite); //Apb_direction_e' is used to cast to enum.
      if (txn.direction == WRITE)
        txn.pwdata = vif.cb_mon.pwdata;

      // Wait for ACCESS phase completion (PENABLE=1 && PREADY=1)
      @(vif.cb_mon);
      while (!(vif.cb_mon.penable && vif.cb_mon.pready))
        @(vif.cb_mon);
      
      // Capture response
      if (txn.direction == READ)
      	txn.prdata = vif.cb_mon.prdata;
        txn.response = apb_response_e'(vif.cb_mon.pslverr); //Cast to enum
      
      // Send to analysis port
      `uvm_info("APB_MON", $sformatf("Observed: %s", txn.convert2string()), UVM_MEDIUM)
      analysis_port.write(txn);
    end
  endtask

endclass

`endif
