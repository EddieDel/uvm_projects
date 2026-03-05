`ifndef AXI_READ_MONITOR_SV
`define AXI_READ_MONITOR_SV

class axi_read_monitor extends uvm_monitor;
  `uvm_component_utils(axi_read_monitor)
  
  virtual axi_if vif;
  uvm_analysis_port#(axi_read_tx) read_analysis_port;
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    read_analysis_port = new("analysis_port", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("Read Monitor", "Failed to retrieve virtual interface")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    // Wait for reset to complete ONCE at startup
    @(posedge vif.aresetn);
    @(vif.cb_mon);
    
    forever begin
      axi_read_tx tx_item = axi_read_tx::type_id::create("tx_item");
      int burst_len;
      
      // Wait for read address handshake
      @(vif.cb_mon iff (vif.cb_mon.arvalid && vif.cb_mon.arready));
      
      tx_item.arid    = vif.cb_mon.arid;
      tx_item.araddr  = vif.cb_mon.araddr;
      tx_item.arlen   = vif.cb_mon.arlen;
      tx_item.arsize  = vif.cb_mon.arsize;
      tx_item.arburst = burst_t'(vif.cb_mon.arburst);
      burst_len = vif.cb_mon.arlen + 1;
      
      // Capture read data beats
      for (int i = 0; i < burst_len; i++) begin
        @(vif.cb_mon iff (vif.cb_mon.rvalid && vif.cb_mon.rready));
        tx_item.rdata.push_back(vif.cb_mon.rdata);
        tx_item.rresp = response_t'(vif.cb_mon.rresp);
      end
      
      `uvm_info("Read Monitor", $sformatf("Observed: %s", tx_item.convert2string()), UVM_LOW)
      read_analysis_port.write(tx_item);
    end
  endtask
  
endclass

`endif
