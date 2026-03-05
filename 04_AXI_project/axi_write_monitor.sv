`ifndef AXI_WRITE_MONITOR_SV
`define AXI_WRITE_MONITOR_SV

class axi_write_monitor extends uvm_monitor;
  `uvm_component_utils(axi_write_monitor)
  
  virtual axi_if vif;
  uvm_analysis_port#(axi_write_tx) analysis_port;
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("Write Monitor", "Failed to retrieve virtual interface")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    // Wait for reset ONCE at startup
    @(posedge vif.aresetn);
    @(vif.cb_mon);
    
    forever begin
      axi_write_tx tx_item = axi_write_tx::type_id::create("tx_item");
      int burst_len;
      
      // Wait for write address handshake
      @(vif.cb_mon iff (vif.cb_mon.awvalid && vif.cb_mon.awready));
      
      tx_item.awid    = vif.cb_mon.awid;
      tx_item.awaddr  = vif.cb_mon.awaddr;
      tx_item.awlen   = vif.cb_mon.awlen;
      tx_item.awsize  = vif.cb_mon.awsize;
      tx_item.awburst = burst_t'(vif.cb_mon.awburst);
      burst_len = vif.cb_mon.awlen + 1;
      
      // Capture write data beats
      for (int i = 0; i < burst_len; i++) begin
        @(vif.cb_mon iff (vif.cb_mon.wvalid && vif.cb_mon.wready));
        tx_item.wdata.push_back(vif.cb_mon.wdata);
        tx_item.wstrb.push_back(vif.cb_mon.wstrb);
      end
      
      // Wait for write response handshake
      @(vif.cb_mon iff (vif.cb_mon.bvalid && vif.cb_mon.bready));
      tx_item.bid  = vif.cb_mon.bid;
      tx_item.resp = response_t'(vif.cb_mon.bresp);
      
      `uvm_info("Write Monitor", $sformatf("Observed: %s", tx_item.convert2string()), UVM_LOW)
      analysis_port.write(tx_item);
    end
  endtask
  
endclass

`endif

