`ifndef APB_MASTER_DRIVER_SV
 `define APB_MASTER_DRIVER_SV

class apb_master_driver extends uvm_driver #(.REQ(apb_tx));
  `uvm_component_utils(apb_master_driver)
  
  //virtual interface handle
  virtual apb_if vif;
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_DRIVER", "Could not get vif from config_db")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      drive_transactions();
    end  
  endtask
  
  
  virtual task drive_transactions ();
      apb_tx item;
      seq_item_port.get_next_item(item);
      drive_transaction(item);    
      seq_item_port.item_done();
  endtask
  
  virtual task drive_transaction (apb_tx item);

    if (item.direction == WRITE) begin
      `uvm_info("[DRIVER]",$sformatf("\%0s\": %0s",item.get_full_name(),item.convert2string_request()), UVM_NONE)
    end
    
    //Pre drive delay
    for(int i = 0; i<item.pre_drive_delay; i++) begin
      @(vif.cb_drv);
    end
    
    //Wait for reset to finish
    wait(vif.preset_n);
    @(vif.cb_drv);
    
    //Setup Phase
    vif.cb_drv.psel      <= 1 ;
    vif.cb_drv.paddr     <= item.paddr;
    vif.cb_drv.penable   <= 0;
    vif.cb_drv.pwrite    <= item.direction;
    
    if(item.direction == WRITE) begin    
      vif.cb_drv.pwdata    <= item.pwdata;
    end
    
    //Access phase (Keep enable asserted as long as pready is not asserted)
    @(vif.cb_drv);
    vif.cb_drv.penable <= 1;
    
    while (!vif.cb_drv.pready) begin
     @(vif.cb_drv);
    end
    
    //Move to idle
      vif.cb_drv.psel    <= 0;
      vif.cb_drv.paddr   <= 0;
      vif.cb_drv.pwdata  <= 0;
      vif.cb_drv.penable <= 0;

    
    
    
    //Post drive delay
    for(int i =0; i<item.post_drive_delay; i++) begin
      @(vif.cb_drv);
    end
    

  endtask

endclass
`endif
