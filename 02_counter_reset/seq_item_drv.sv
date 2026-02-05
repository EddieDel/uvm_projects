`ifndef SEQ_ITEM_DRV_SV
 `define SEQ_ITEM_DRV_SV

class seq_item_drv extends uvm_sequence_item;
  `uvm_object_utils(seq_item_drv)
  
  function new (string name ="");
    super.new(name);
  endfunction
  
  rand logic enable;
  logic [3:0] count;
  logic reset_n;
  rand int    pre_drive_delay;
  rand int    post_drive_delay;
  rand int        enable_duration;
  
  
  constraint pre_delay {
    soft pre_drive_delay >= 0;
    soft pre_drive_delay <= 5;
  }
  
  constraint post_delay {
    soft post_drive_delay >= 0;
    soft post_drive_delay <= 5;
  }
  
  constraint enable_active {
    soft enable_duration >  0;
    soft enable_duration <= 5;
  }
  
  
  virtual function string convert2string();
    string result;
    result = $sformatf("Pre_delay[%0d]",pre_drive_delay);
    
    if(enable) begin
      result = {result, $sformatf(", Enabled: %0h for [%0d] cycles", enable, enable_duration)};
    end
    
    result = {result, $sformatf(", Post_delay[%0d]", post_drive_delay)};
    

    return result;
  endfunction
  

endclass

`endif
