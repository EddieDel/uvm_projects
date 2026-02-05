`ifndef MUX_SEQUENCE_SV
 `define MUX_SEQUENCE_SV

class mux_sequence extends uvm_sequence#(.REQ(mux_item_drv));

  
   mux_item_drv item;
  
  `uvm_object_utils(mux_sequence)
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    item = mux_item_drv::type_id::create("item");
    repeat (40) begin    
    `uvm_do(item);
    end
  endtask
  
  
  
endclass

`endif
