`ifndef AXI_WRITE_TX_SV
 `define AXI_WRITE_TX_SV

class axi_write_tx extends uvm_sequence_item;
  `uvm_object_utils(axi_write_tx)
  
  function new (string name = "");
    super.new (name);
  endfunction
    
  
  rand logic [ID_WIDTH - 1:0]   awid;
  rand logic [ADDR_WIDTH - 1:0] awaddr;
  rand logic [7:0]              awlen;
  rand logic [2:0]              awsize;
  rand burst_t                  awburst;
  
  rand logic [DATA_WIDTH - 1:0]   wdata[$];
  rand logic [DATA_WIDTH/8 - 1:0] wstrb[$];
  
  logic [ID_WIDTH - 1:0]          bid;
  response_t                      resp;
  
  
  constraint que_size {
    wdata.size() == awlen + 1;
    wstrb.size() == awlen + 1;
  }
   
  constraint aw_size {
    awsize inside {[0:$clog2(DATA_WIDTH/8)]};  // 0, 1, or 2 for 32-bit bus
  }
  
  constraint wrap_len {
  (awburst == WRAP) -> awlen inside {1, 3, 7, 15};
  }

  virtual function string convert2string();
    string result;
    result = $sformatf ("Sending [Write] transaction: ");
    result = {result, $sformatf(", AWID: %0d, AWADDR: %0h, AWLEN: %0d, AWSIZE: %0d, BURST_TYPE:%0s,WDATA: %p and WSTROBE: %p", awid, awaddr, awlen, awsize, awburst, wdata, wstrb)};
    return result;
  endfunction

endclass
`endif
