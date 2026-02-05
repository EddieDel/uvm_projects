`ifndef MUX_CORNER_SEQUENCES_SV
 `define MUX_CORNER_SEQUENCES_SV

// ===================================================================
// Sequence 1: All Zeros Test
// ===================================================================
class mux_all_zeros_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_all_zeros_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    // Test all select values with all inputs = 0
    for(int i = 0; i < 4; i++) begin
      item = mux_item_drv::type_id::create("item");
      start_item(item);
      item.in0 = 8'h00;
      item.in1 = 8'h00;
      item.in2 = 8'h00;
      item.in3 = 8'h00;
      item.sel = i;
      item.pre_drive_delay = 0;
      item.post_drive_delay = 0;
      finish_item(item);
    end
  endtask
endclass

// ===================================================================
// Sequence 2: All Ones Test (Max Values)
// ===================================================================
class mux_all_ones_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_all_ones_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    // Test all select values with all inputs = 0xFF
    for(int i = 0; i < 4; i++) begin
      item = mux_item_drv::type_id::create("item");
      start_item(item);
      item.in0 = 8'hFF;
      item.in1 = 8'hFF;
      item.in2 = 8'hFF;
      item.in3 = 8'hFF;
      item.sel = i;
      item.pre_drive_delay = 0;
      item.post_drive_delay = 0;
      finish_item(item);
    end
  endtask
endclass

// ===================================================================
// Sequence 3: Unique Values Test
// ===================================================================
class mux_unique_values_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_unique_values_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    // Each input has unique value, test all selects
    for(int i = 0; i < 4; i++) begin
      item = mux_item_drv::type_id::create("item");
      start_item(item);
      item.in0 = 8'hAA;
      item.in1 = 8'h55;
      item.in2 = 8'hCC;
      item.in3 = 8'h33;
      item.sel = i;
      item.pre_drive_delay = 0;
      item.post_drive_delay = 0;
      finish_item(item);
    end
  endtask
endclass

// ===================================================================
// Sequence 4: Walking Ones Test
// ===================================================================
class mux_walking_ones_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_walking_ones_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    // Walking 1s pattern for each select
    for(int sel_val = 0; sel_val < 4; sel_val++) begin
      for(int bit_pos = 0; bit_pos < 8; bit_pos++) begin
        item = mux_item_drv::type_id::create("item");
        start_item(item);
        item.in0 = (1 << bit_pos);
        item.in1 = (1 << bit_pos);
        item.in2 = (1 << bit_pos);
        item.in3 = (1 << bit_pos);
        item.sel = sel_val;
        item.pre_drive_delay = 0;
        item.post_drive_delay = 0;
        finish_item(item);
      end
    end
  endtask
endclass

// ===================================================================
// Sequence 5: Back-to-Back Transactions (No Delay)
// ===================================================================
class mux_back2back_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_back2back_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    repeat(20) begin
      item = mux_item_drv::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {
        pre_drive_delay == 0;
        post_drive_delay == 0;
      });
      finish_item(item);
    end
  endtask
endclass

// ===================================================================
// Sequence 6: Select Toggle Test (Rapid Select Changes)
// ===================================================================
class mux_select_toggle_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_select_toggle_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    // Toggle through all select values rapidly
    repeat(10) begin
      for(int i = 0; i < 4; i++) begin
        item = mux_item_drv::type_id::create("item");
        start_item(item);
        assert(item.randomize() with {
          sel == i;
          pre_drive_delay == 0;
          post_drive_delay == 0;
        });
        finish_item(item);
      end
    end
  endtask
endclass

// ===================================================================
// Sequence 7: Same Input Different Selects
// ===================================================================
class mux_same_input_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_same_input_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    logic [7:0] test_val = $urandom;
    
    // Keep same input values, cycle through selects
    for(int i = 0; i < 4; i++) begin
      item = mux_item_drv::type_id::create("item");
      start_item(item);
      item.in0 = test_val;
      item.in1 = test_val;
      item.in2 = test_val;
      item.in3 = test_val;
      item.sel = i;
      item.pre_drive_delay = 0;
      item.post_drive_delay = 0;
      finish_item(item);
    end
  endtask
endclass

// ===================================================================
// Sequence 8: Alternating Pattern
// ===================================================================
class mux_alternating_pattern_sequence extends uvm_sequence#(.REQ(mux_item_drv));
  `uvm_object_utils(mux_alternating_pattern_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    mux_item_drv item;
    // Test with alternating 0xAA and 0x55 patterns
    for(int i = 0; i < 4; i++) begin
      item = mux_item_drv::type_id::create("item");
      start_item(item);
      item.in0 = 8'hAA;
      item.in1 = 8'h55;
      item.in2 = 8'hAA;
      item.in3 = 8'h55;
      item.sel = i;
      item.pre_drive_delay = 0;
      item.post_drive_delay = 0;
      finish_item(item);
    end
  endtask
endclass

`endif
