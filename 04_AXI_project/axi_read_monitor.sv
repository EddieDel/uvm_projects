`ifndef AXI_READ_MONITOR_SV
 `define AXI_READ_MONITOR_SV

class axi_read_monitor extends uvm_monitor;
  `uvm_component_utils(axi_read_monitor)
  
  //Declarations
  virtual axi_if vif;
  uvm_analysis_port#(axi_read_tx) read_analysis_port;
  
  function new(string name = "",uvm_component parent);
    super.new(name,parent);
    read_analysis_port = new("analysis_port",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif)) begin
      `uvm_fatal("Write Monitor","Failed to retrieve virtual interface")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      axi_read_tx tx_item = axi_read_tx::type_id::create("tx_item");
      int burst_len;
      //What should we capture and why
      //The first capture point should be the handshake of read address
      wait(vif.cb_mon.arvalid && vif.cb_mon.arready);
      @(vif.cb_mon);
      
      tx_item.arid     = vif.cb_mon.arid;
      tx_item.araddr   = vif.cb_mon.araddr;
      tx_item.arlen    = vif.cb_mon.arlen;
      tx_item.arsize   = vif.cb_mon.arsize;
      tx_item.arburst  = burst_t'(vif.cb_mon.arburst);
      burst_len = vif.cb_mon.arlen + 1; 
      
      //second handshake
      //Data to be read
      
      for (int i = 0; i<burst_len; i++) begin
        wait(vif.cb_mon.rvalid && vif.cb_mon.rready);
        @(vif.cb_mon);
        tx_item.rdata.push_back(vif.cb_mon.rdata);
      end
      

      `uvm_info("Write Monitor",$sformatf("Observerd: \%0s\": %0s",tx_item.get_full_name(),tx_item.convert2string()),UVM_LOW)
      read_analysis_port.write(tx_item);
    
    end
  endtask 
    
endclass
`endif
