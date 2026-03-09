`ifndef AXI_READ_TX_SV
 `define AXI_READ_TX_SV

class axi_read_tx extends uvm_sequence_item;
  `uvm_object_utils(axi_read_tx)
  
  function new (string name = "");
    super.new (name);
  endfunction
    
    
  
  rand logic [ID_WIDTH - 1:0]   arid;
  rand logic [ADDR_WIDTH - 1:0] araddr;
  rand logic [7:0]              arlen;
  rand logic [2:0]              arsize;
  rand burst_t                  arburst;
  
  logic [DATA_WIDTH - 1:0]   rdata[$];
  
  logic [ID_WIDTH - 1:0]          rid;
  response_t                      rresp;
  
   
  constraint ar_size {
    arsize inside {[0:$clog2(DATA_WIDTH/8)]};  // 0, 1, or 2 for 32-bit bus
  }
  
  constraint wrap_len {
    (arburst == WRAP) -> arlen inside {1, 3, 7, 15};
  }

  virtual function string convert2string();
    string result;
    result = $sformatf ("Sending [Read] transaction: ");
    result = {result, $sformatf(", ARID: %0d, ARADDR: %0h, ARLEN: %0d, ARSIZE: %0d, BURST_TYPE:%0s, and RDATA: %p", arid, araddr, arlen, arsize, arburst, rdata)};
    return result;
  endfunction

endclass
`endif
