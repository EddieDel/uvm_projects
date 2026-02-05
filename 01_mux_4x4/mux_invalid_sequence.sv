`ifndef MUX_INVALID_SEQUENCE_SV
 `define MUX_INVALID_SEQUENCE_SV

class mux_invalid_sequence extends uvm_sequence#(.REQ(mux_item_drv));

  
   mux_item_drv item;
  
  `uvm_object_utils(mux_invalid_sequence)
  function new (string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10) begin
     item = mux_item_drv::type_id::create("item");
      start_item(item);
      item.sel = $urandom_range(4, 7);
      item.in0 = 1'hx;
      finish_item(item); 
    end
       
  endtask
  
  
  
endclass

`endif
