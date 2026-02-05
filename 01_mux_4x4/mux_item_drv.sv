`ifndef MUX_ITEM_DRV_SV
 `define MUX_ITEM_DRV_SV

class mux_item_drv extends uvm_sequence_item;
  `uvm_object_utils(mux_item_drv);
  
  function new (string name ="");
    super.new(name);
  endfunction
  
  rand logic [7:0] in0;
  rand logic [7:0] in1;
  rand logic [7:0] in2;
  rand logic [7:0] in3;
  rand logic [1:0] sel;
  logic      [7:0] out;
  rand int              pre_drive_delay;
  rand int              post_drive_delay;
  
  
  constraint pre_delay {
    soft pre_drive_delay >= 0;
    soft pre_drive_delay <  6;
  }
  
  constraint  post_delay { 
    soft post_drive_delay >= 0;
    soft post_drive_delay <  6;
  }
  
  constraint sel_def {
    sel inside {0,1,2,3};} 
  
  virtual function string convert2string();
    string result = $sformatf("Sel = %0d  In0 = %0h  In1 = %0h  In2 = %0h and  In3 = %0h",sel,in0,in1,in2,in3);
    return result;
  endfunction
  
  
  
endclass

`endif
