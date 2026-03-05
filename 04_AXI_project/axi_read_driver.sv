`ifndef AXI_READ_DRIVER_SV
`define AXI_READ_DRIVER_SV
class axi_read_driver extends uvm_driver#(.REQ(axi_read_tx));
  `uvm_component_utils(axi_read_driver)
   
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
      `uvm_fatal("Read Driver","Failed to get virtual interface")
    end
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    vif.cb_drv.arvalid <= 0;
    vif.cb_drv.rready  <= 0;
    
    @(vif.cb_drv);
    forever begin
      drive_transactions();
    end
  endtask
    
  virtual task drive_transactions();
    axi_read_tx item;
    seq_item_port.get_next_item(item);
    drive_transaction(item);
    seq_item_port.item_done(item);
  endtask
    
  virtual task drive_transaction(axi_read_tx item);
    
    `uvm_info("Read Driver",$sformatf("%0s: %0s",item.get_full_name(),item.convert2string()), UVM_NONE)
    
    burst_len = item.arlen + 1;
    
    // wait for reset to finish
    wait (vif.aresetn);
    @(vif.cb_drv);
    
    // AR Channel - drive read address
    vif.cb_drv.araddr  <= item.araddr;
    vif.cb_drv.arid    <= item.arid;
    vif.cb_drv.arlen   <= item.arlen;
    vif.cb_drv.arsize  <= item.arsize;
    vif.cb_drv.arburst <= item.arburst;
    vif.cb_drv.arvalid <= 1;
    
    // Wait for handshake 
    do @(vif.cb_drv);
    while (!(vif.cb_drv.arready));
    vif.cb_drv.arvalid <= 0;
    
    // R Channel - receive read data
    vif.cb_drv.rready <= 1;
    for (int i = 0; i < burst_len; i++) begin
      do @(vif.cb_drv);
      while (!vif.cb_drv.rvalid);
      
      item.rdata.push_back(vif.cb_drv.rdata);
      item.rresp = vif.cb_drv.rresp;
      item.rid   = vif.cb_drv.rid;
      
      // Check rlast on final beat
      if (i == (burst_len - 1)) begin
        if (!vif.cb_drv.rlast)
          `uvm_error("Read Driver", "rlast not asserted on final beat")
      end
    end
    
    // Return to idle
    vif.cb_drv.arvalid <= 0;
    vif.cb_drv.rready  <= 0;
    
  endtask
      
endclass
`endif
