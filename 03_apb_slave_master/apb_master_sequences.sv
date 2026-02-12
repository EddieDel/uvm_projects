`ifndef APB_MASTER_SEQUENCES_SV
 `define APB_MASTER_SEQUENCES_SV

class apb_master_sequences extends uvm_sequence#(.REQ(apb_tx));
  `uvm_object_utils(apb_master_sequences)

  function new (string name = "");
    super.new(name);
  endfunction
  
endclass
  
// ========================================================================
// Random Transaction items
// ========================================================================



class apb_random_sequences extends uvm_sequence#(.REQ(apb_tx));
  `uvm_object_utils(apb_random_sequences)
  
  apb_tx item;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();    
    repeat(50) begin
      `uvm_do(item);
    end
  endtask
endclass




// ========================================================================
// Write Transaction 
// ========================================================================

class apb_write_sequence extends uvm_sequence#(.REQ(apb_tx));
  `uvm_object_utils(apb_write_sequence)
  
  apb_tx item;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    begin
      `uvm_do_with(item, {direction == WRITE;});
    end
  endtask
endclass




// ========================================================================
// Read Transaction 
// ========================================================================

class apb_read_sequence extends uvm_sequence#(.REQ(apb_tx));
  `uvm_object_utils(apb_read_sequence)
  
  apb_tx item;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();    
    begin
      `uvm_do_with(item, {direction == READ;});
    end
  endtask
endclass


// ========================================================================
// Write then read sequence
// ========================================================================

class apb_write_then_read_sequence extends uvm_sequence#(.REQ(apb_tx));
  `uvm_object_utils(apb_write_then_read_sequence)
  
  apb_tx item;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();    
    `uvm_do_with(item, {direction == WRITE; paddr == 8'h00;});
    `uvm_do_with(item, {direction == READ; paddr == 8'h00;});
  endtask
endclass


// ========================================================================
// Invalid Addr Sequence
// ========================================================================

class apb_invalid_addr_sequence extends uvm_sequence#(.REQ(apb_tx));
  `uvm_object_utils(apb_invalid_addr_sequence)
  
  apb_tx item;
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat (5) begin
    `uvm_do_with(item, {direction == WRITE; paddr == 8'hFF;});
    end
  endtask
endclass


`endif

