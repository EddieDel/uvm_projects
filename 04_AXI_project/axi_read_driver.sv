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
      `uvm_fatal("Write Driver","Failed to get virtual interface")
    end
  endfunction
  
      
  virtual task run_phase(uvm_phase phase);
    //Set awvalid initial value.
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
    
    `uvm_info("Read Driver",$sformatf("\%0s\": %0s",item.get_full_name(),item.convert2string()), UVM_NONE)
    
    burst_len = item.arlen + 1;
    
    // wait for reset to finish
    wait (vif.aresetn);
    @(vif.cb_drv);
    
    //prepare read signals      
    vif.cb_drv.araddr  <= item.araddr;
    vif.cb_drv.arid    <= item.arid;
    vif.cb_drv.arlen   <= item.arlen;
    vif.cb_drv.arsize  <= item.arsize;
    vif.cb_drv.arburst <= item.arburst;
    //In order from Idle to go to write data , awvalid must be asserted.
    vif.cb_drv.arvalid <= 1;
    
    //wait for handshake 
    wait (vif.cb_drv.arready);
    @(vif.cb_drv);
    vif.cb_drv.arvalid <= 0; //Deassert after handshake.
    
    //Master is ready to receive
    vif.cb_drv.rready <= 1;

    //Read Data DUT -> Master.
    for (int i = 0; i<burst_len; i++) begin
      wait(vif.cb_drv.rvalid);
      @(vif.cb_drv);
      item.rdata.push_back(vif.cb_drv.rdata);
    end

    //capture rresp items;
    item.rresp = vif.cb_drv.rresp;
    item.rid  = vif.cb_drv.rid;
    
    //if wlast happened okay, we have to move signals to idle.
    vif.cb_drv.arvalid <= 0;
    vif.cb_drv.rready  <= 0;
    
  endtask
      
      
endclass
`endif
