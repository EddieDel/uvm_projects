`ifndef COUNTER_MONITOR_SV
`define COUNTER_MONITOR_SV

class counter_monitor extends uvm_monitor implements reset_handler;
  `uvm_component_utils(counter_monitor)
   
  agent_config ac;

  // Process for monitor_transactions()
  protected process process_monitor_transactions;

  // Analysis port for sending observed items
  uvm_analysis_port#(seq_item_drv) analysis_port;

  function new (string name ="", uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  // Main run_phase
  virtual task run_phase(uvm_phase phase);
    `uvm_info("Monitor", "Starting monitor run_phase", UVM_LOW)

    forever begin
      // Wait until reset is deasserted
      wait_reset_end();

      fork
        // Start monitoring transactions
        begin
          monitor_transactions();
        end

        // Watch for reset assertion
        begin
          wait_reset_start();
          `uvm_info("Monitor", "Reset detected, stopping monitor process", UVM_LOW)
                                                                 
          handle_reset(phase);
        end
      join_any

      disable fork; // Cleanly stop all forked processes before looping
    end
  endtask

  // Continuous transaction monitoring
  protected virtual task monitor_transactions();
    counter_vif vif = ac.get_vif();
    logic [3:0] prev_count;
    seq_item_drv item;
    process_monitor_transactions = process::self();
    
     
    forever begin
      
      @(vif.ckbm);
      
      //There should be checks such as static count when !enable and overflow checks!
      item = seq_item_drv::type_id::create("item");

      if (item == null) begin
          `uvm_error("Monitor", "Item creation failed!")
      end
      
      item.enable = vif.ckbm.enable;  
      item.reset_n = vif.ckbm.reset_n;
      item.count = vif.ckbm.count;
      `uvm_info("Monitor", $sformatf("Counter = %0d", item.count), UVM_NONE)
      
      
      if (!vif.ckbm.reset_n) begin
      	`uvm_info("Monitor", $sformatf("[%0t] ======= Reset =======", $time), UVM_NONE);
         prev_count = 0; //Reinitialize prev_count in case of reset.
      end

      // Overflow detection
      if( prev_count == 4'd15 && vif.ckbm.count == 4'd0 && vif.ckbm.enable && vif.ckbm.reset_n)
         `uvm_info("Monitor", $sformatf("[%0t] Overflow Happened", $time), UVM_NONE);

      if(!vif.ckbm.enable && vif.ckbm.reset_n) begin //static count check in case !enable.
        if(vif.ckbm.count !== prev_count)
          `uvm_error("Monitor", $sformatf("Count changed when disabled. Was: %0d , Now: %0d",prev_count,vif.ckbm.count));
      end
          
      analysis_port.write(item);
      prev_count = vif.ckbm.count; //Update for next cycle

    end
  endtask

  // Wait for reset start
  protected virtual task wait_reset_start();
    ac.wait_reset_start();
  endtask

  // Wait for reset end
  protected virtual task wait_reset_end(); 
    ac.wait_reset_end();
  endtask

  // Kill monitoring process during reset
  virtual function void handle_reset(uvm_phase phase);
    if (process_monitor_transactions != null) begin
      process_monitor_transactions.kill();
      process_monitor_transactions = null;
    end
  endfunction
  
endclass

`endif
  
  
