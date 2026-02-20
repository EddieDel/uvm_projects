`ifndef AXI_WRITE_DRIVER_SV
 `define AXI_WRITE_DRIVER_SV


class axi_write_driver extends uvm_driver(.REQ(axi_write_tx));
  `uvm_component_utils(axi_write_driver)
   
  
  //Virtual interface handle
  virtual axi_if vif;
  int     burst_len;
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //Retrieve virtual interface
    if (!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif)) begin
        `uvm_fatal("AXI WRITE DRIVER","Failed to get virtual interface")
    end
  endfunction
  
      
  virtual task run_phase(uvm_phase phase);
    //Set awvalid initial value.
    vif.cb_drv.awvalid <= 0;
    vif.cb_drv.wvalid  <= 0;
    vif.cb_drv.bready  <= 0;
    vif.cb_drv.wlast   <= 0;
    
    forever begin
      drive_transactions();
    end
  endtask
    
  virtual task drive_transactions();
    axi_write_tx item;
    seq_item_port.get_next_item(item);
    drive_transaction(item);
    seq_item_port.item_done(item);
  endtask
    
  virtual task drive_transaction(axi_write_tx item);
    
    burst_len = item.wdata.size();
    
    // wait for reset to finish
    wait (vif.aresetn);
    @(vif.cb_drv);
    
    
    //In order from Idle to go to write data , awvalid must be asserted.
    vif.cb_drv.awvalid <= 1;
    
    //prepare signals      
    vif.cb_drv.awid    <= item.awid;
    vif.cb_drv.awaddr  <= item.awaddr;
    vif.cb_drv.awlen   <= item.awlen;
    vif.cb_drv.awsize  <= item.awsize;
    vif.cb_drv.awburst <= item.awburst; 
    
    //wait for handshake 
    wait (vif.cb_drv.awvalid && vif.cb_drv.awready);
    @(vif.cb_drv);
    vif.cb_drv.awvalid <= 0;
    
    //wready <= will assert from the dut.
    //awready <= will become 0 from the dut.

    //Data to be sent
    for (int i = 0; i<burst_len; i++) begin
      @(vif.cb_drv);
      vif.cb_drv.wdata   <= item.wdata[i];
      vif.cb_drv.wstrb   <= item.wstrb[i];
      vif.cb_drv.wvalid  <= 1;
      if (i == (burst_len - 1))
       vif.cb_drv.wlast   <= 1; //assert wlast at burst_len - 1, last iteration;
      // Wait for handshake
      do @(vif.cb_drv);
      while (!vif.cb_drv.wready);
    end

    //handshake for w_resp
    vif.cb_drv.bready <= 1;
    wait(vif.cb_drv.bvalid && vif.cb_drv.bready);
    @(vif.cb_drv);
    
    //capture wresp items;
    item.resp = vif.cb_drv.bresp;
    item.bid  = vif.cb_drv.bid;
    
    //if wlast happened okay, we have to move signals to idle.
    vif.cb_drv.awvalid <= 0;
    vif.cb_drv.wvalid  <= 0;
    vif.cb_drv.wlast   <= 0;
    vif.cb_drv.bready  <= 0;
    
  endtask
      
      
endclass
`endif
