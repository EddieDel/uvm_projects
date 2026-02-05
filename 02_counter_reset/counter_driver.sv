`ifndef COUNTER_DRIVER_SV
 `define COUNTER_DRIVER_SV

class counter_driver extends uvm_driver#(.REQ(seq_item_drv)) implements reset_handler;
  `uvm_component_utils(counter_driver)
  
  //Agent Configuration Pointer
  agent_config ac;
  
  //Process for drive_transactions() task
  protected process process_drive_transactions;
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  protected virtual task drive_transaction(seq_item_drv item);
    counter_vif vif = ac.get_vif();
    `uvm_info("Driver",$sformatf("\%0s\": %0s",item.get_full_name(),item.convert2string()), UVM_NONE)

    for (int i = 0; i <item.pre_drive_delay; i++) begin
      @(posedge vif.clk);
    end
    
    @(posedge vif.clk);
    
    if(item.enable) begin
      for(int i = 0; i<item.enable_duration; i++)
        begin
          vif.enable = item.enable;
          @(posedge vif.clk);
        end
    end
    
    vif.enable = 0;
    

    for(int i = 0; i < item.post_drive_delay; i++) begin
      @(posedge vif.clk);
    end
    
  endtask

  
  protected virtual task drive_transactions();
   fork
    begin
      process_drive_transactions = process::self();
      forever begin
    	seq_item_drv item;
    	seq_item_port.get_next_item(item);
    	drive_transaction(item);
    	seq_item_port.item_done();
      end
    end
   join
  endtask
    
  
  virtual task run_phase(uvm_phase phase);
   `uvm_info("Driver", "Starting driver run_phase", UVM_LOW)
  
   forever begin
     // Wait for reset to finish
     wait_reset_end();

     fork
       // Drive transactions
       begin
         drive_transactions();
       end

       // Monitor for reset start
       begin
         wait_reset_start();
         `uvm_info("Driver", "Reset detected, stopping drive process", UVM_LOW)
         handle_reset(phase); // Kill any active driving
       end
     join_any

    disable fork; // Cleanly end the fork and wait for reset to end again
   end
  endtask
    

    
    
  virtual function void handle_reset(uvm_phase phase);
   counter_vif vif = ac.get_vif();
    
   if(process_drive_transactions != null) begin
     process_drive_transactions.kill();
      
     process_drive_transactions = null;
   end   
  endfunction
    
  virtual task wait_reset_start();
    ac.wait_reset_start();
  endtask
  
  virtual task wait_reset_end();
    ac.wait_reset_end();
  endtask
  
  
  
endclass
`endif
