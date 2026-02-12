`ifndef APB_TX_SV
 `define APB_TX_SV


class apb_tx extends uvm_sequence_item;
  `uvm_object_utils(apb_tx)


  function new (string name = "");
    super.new(name);
  endfunction
  
  //request fields 
  rand apb_direction_e          direction;
  rand logic [ADDR_WIDTH-1:0]   paddr;
  rand logic [DATA_WIDTH-1:0]   pwdata;
  rand int                         pre_drive_delay;
  rand int                         post_drive_delay; 
  
  //response fields
  logic      [DATA_WIDTH-1:0]   prdata;  
  apb_response_e                  response; //ERROR - OK; 
  
  
  
  constraint pre_delay {
      soft pre_drive_delay  >= 0;
      soft pre_drive_delay <= 5;
  }

  constraint post_delay {
      soft post_drive_delay  >= 0;
      soft post_drive_delay <= 5;
  }
  
  constraint valid_addr {
    soft paddr inside { 8'h00, 8'h04, 8'h08, 8'h0C};
  }
  
  virtual function string convert2string_response();
    string result;
    result = $sformatf("Pre_drive_delay[%0d]",pre_drive_delay);
    
    if ( direction == WRITE) begin
      result = {result, $sformatf(",  Write DATA:%0h at ADDR:%0h",pwdata,paddr)};
    end
    else begin
      result = {result, $sformatf(", Read DATA:%0h from ADDR:%0h",prdata,paddr)};
    end
    result = {result, $sformatf (", Post_drive_delay[%0d]",post_drive_delay)};
    
    return result;
  endfunction
  
  
  virtual function string convert2string_request();
    string result;
     result = $sformatf("Pre_drive_delay[%0d]",pre_drive_delay);
     result = {result, $sformatf(",  Write DATA:%0h at ADDR:%0h",pwdata,paddr)};
     result = {result, $sformatf (", Post_drive_delay[%0d]",post_drive_delay)};
    return result;
  endfunction

endclass

`endif


