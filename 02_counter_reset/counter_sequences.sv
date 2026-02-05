`ifndef COUNTER_SEQUENCES_SV
 `define COUNTER_SEQUENCES_SV

// ===================================================================
// Sequence 1: Random Transactions
// ===================================================================

class counter_random_transactions extends uvm_sequence#(.REQ(seq_item_drv));
  `uvm_object_utils(counter_random_transactions)
  
  seq_item_drv item;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  
  virtual task body();
    item = seq_item_drv::type_id::create("item");
    repeat (30) begin
      `uvm_do(item);
    end
  endtask
endclass

// ===================================================================
// Sequence 2: Single Transaction
// ===================================================================

class counter_single_transaction extends uvm_sequence#(.REQ(seq_item_drv));
  `uvm_object_utils(counter_single_transaction)
  
  seq_item_drv item;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  
  virtual task body();
    item = seq_item_drv::type_id::create("item");

    `uvm_do(item);
    
  endtask
endclass



// ===================================================================
// Sequence 3: Max Reset (Reach max count then reset)
// ===================================================================

class counter_max_reset extends uvm_sequence#(.REQ(seq_item_drv));
  `uvm_object_utils(counter_max_reset)

  seq_item_drv item;
  counter_vif vif;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    item = seq_item_drv::type_id::create("item");
    if (!uvm_config_db#(virtual counter_if)::get(null, "uvm_test_top.env.agent", "vif", vif))
      `uvm_fatal("MAX_RESET_SEQ","Could not get vif");
    
    // Keep sending until count reaches 15
    while (vif.count != 15) begin
      `uvm_do_with(item, { enable == 1; enable_duration == 1; })
    end
    
    `uvm_info("MAX_RESET_SEQ", "Count reached 15", UVM_LOW)
  endtask
endclass


// ===================================================================
// Sequence 4: Overflow
// ===================================================================

class counter_overflow extends uvm_sequence#(.REQ(seq_item_drv));
  `uvm_object_utils(counter_overflow)
   seq_item_drv item;
 
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    item = seq_item_drv::type_id::create("item");
 
    `uvm_do_with(item, { enable == 1; enable_duration == 16; })
 
    `uvm_info("Overflow", "Enabled for 16 cycles, overflow happened", UVM_LOW)
  endtask
endclass


`endif
