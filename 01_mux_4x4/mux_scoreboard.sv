`ifndef MUX_SCOREBOARD_SV
 `define MUX_SCOREBOARD_SV

class mux_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(mux_scoreboard)
  
  uvm_analysis_imp#(mux_item_drv, mux_scoreboard) analysis_export;
  
  function new (string name = "",uvm_component parent);
    super.new(name,parent);
    analysis_export = new("output_port",this);
  endfunction
  
  int err = 0;
  int transaction_no = 0;
  
  virtual function void write(mux_item_drv item);
    
    `uvm_info("Scoreboard", $sformatf("Received item: %0s", item.convert2string()),  UVM_LOW);
    transaction_no ++;
    if( compare_data(item)) begin
      `uvm_info("Scoreboard","Values Match",UVM_LOW);
    end
    else begin
      `uvm_info("Scoreboard","Values MisMatch",UVM_LOW);
    err++;
    end

  endfunction

      
  function logic [7:0] compare_data(mux_item_drv item);
    logic [7:0] expected_data;
    
    case(item.sel)
      2'd0: expected_data = item.in0;
      2'd1: expected_data = item.in1;
      2'd2: expected_data = item.in2;
      2'd3: expected_data = item.in3;
    endcase
    return (expected_data == item.out);   
  endfunction
  
  
  virtual function string report_summary();
    string result;
    result = "\n---------------------------------------------\n";
    result = {result, " Final Scoreboard Report\n"};
    result = {result, $sformatf(" Total Transactions : %0d\n", transaction_no)};
    result = {result, $sformatf(" Total Errors : %0d\n", err)};
    result = {result, "----------------------------------------------\n"};
    return result;
  endfunction
 
  
  virtual function void final_phase(uvm_phase phase);
   super.final_phase(phase);
    `uvm_info("[Scoreboard]",report_summary(), UVM_LOW)
  endfunction


endclass

`endif
