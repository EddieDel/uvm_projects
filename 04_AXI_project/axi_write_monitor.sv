`ifndef AXI_WRITE_MONITOR_SV
 `define AXI_WRITE_MONITOR_SV

class axi_write_monitor extends uvm_monitor;
  `uvm_component_utils(axi_write_monitor)
  
  //Declarations
  virtual axi_if vif;
  uvm_analysis_port#(axi_write_tx) analysis_port;
  
  function new(string name = "",uvm_component parent);
    super.new(name,parent);
    analysis_port = new("analysis_port",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif)) begin
      `uvm_fatal("Write Monitor","Failed to retrieve virtual interface")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      axi_write_tx tx_item = axi_write_tx::type_id::create("tx_item");
      int burst_len;
      //What should we capture and why
      //The first capture point should be the handshake of write address
      wait(vif.cb_mon.awvalid && vif.cb_mon.awready);
      @(vif.cb_mon);
      
      tx_item.awid     = vif.cb_mon.awid;
      tx_item.awaddr   = vif.cb_mon.awaddr;
      tx_item.awlen    = vif.cb_mon.awlen;
      tx_item.awsize   = vif.cb_mon.awsize;
      tx_item.awburst  = burst_t'(vif.cb_mon.awburst);
      burst_len = vif.cb_mon.awlen + 1; 
      
      //second handshake
      //Data to be sent
      
      for (int i = 0; i<burst_len; i++) begin
        wait(vif.cb_mon.wvalid && vif.cb_mon.wready);
        @(vif.cb_mon);
        tx_item.wdata.push_back(vif.cb_mon.wdata);
        tx_item.wstrb.push_back(vif.cb_mon.wstrb);
      end
      
      //third handshake
      wait(vif.cb_mon.bvalid && vif.cb_mon.bready);
      @(vif.cb_mon);
      tx_item.bid   = vif.cb_mon.bid;
      tx_item.resp  = response_t'(vif.cb_mon.bresp);
      
      `uvm_info("Write Monitor",$sformatf("Observerd: \%0s\": %0s",tx_item.get_full_name(),tx_item.convert2string()),UVM_LOW)
      analysis_port.write(tx_item);
    
    end
  endtask 
    
endclass
`endif
