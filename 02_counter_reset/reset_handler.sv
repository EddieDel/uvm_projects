`ifndef RESET_HANDLER_SV
 `define RESET_HANDLER_SV

interface class reset_handler;
  
  pure virtual function void handle_reset(uvm_phase phase);
    
endclass    
    
`endif
