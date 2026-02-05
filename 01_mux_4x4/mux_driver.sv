`ifndef MUX_DRIVER_SV
 `define MUX_DRIVER_SV

class mux_driver extends uvm_driver#(.REQ(mux_item_drv));
  `uvm_component_utils(mux_driver);
  
  mux_agent_config agent_config;
  
  function new(string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
      drive_transactions();
  endtask
  
  protected virtual task drive_transaction(mux_item_drv item);
    mux_vif vif = agent_config.get_vif();
    `uvm_info("Driver", $sformatf("\"%0s\": %0s", item.get_full_name(), item.convert2string()), UVM_NONE)
    
    vif.ready <= 0;
    
    for(int i = 0; i < item.pre_drive_delay; i++) begin
      @(posedge vif.clk);
    end
        
    vif.sel <= item.sel;
    vif.in0 <= item.in0;
    vif.in1 <= item.in1;
    vif.in2 <= item.in2;
    vif.in3 <= item.in3;
    
    for(int i = 0; i < item.post_drive_delay; i++) begin
      @(posedge vif.clk);
    end
    
    @(posedge vif.clk);
    vif.valid <= 1;
    vif.ready <= 1;
    repeat(2) @(posedge vif.clk);
    vif.valid <= 0;
    vif.ready <= 0;
  endtask
  
  protected virtual task drive_transactions();
    forever begin
      mux_item_drv item;
      seq_item_port.get_next_item(item);
      drive_transaction(item);
      seq_item_port.item_done();
    end
  endtask
    
    

endclass
`endif
