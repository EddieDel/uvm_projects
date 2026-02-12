`ifndef APB_SCOREBOARD_SV
 `define APB_SCOREBOARD_SV

class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)
  
  //Analysis port 
  uvm_analysis_imp#(apb_tx, apb_scoreboard) analysis_export;
  
  
  
  //Register modeling 
  logic [DATA_WIDTH - 1:0] ctrl_reg;
  logic [DATA_WIDTH - 1:0] expected_status;
  logic [DATA_WIDTH - 1:0] data_reg;
  logic [DATA_WIDTH - 1:0] irq_reg;
  
  //Statistics count
  int unsigned trans_count;
  int unsigned write_count;
  int unsigned read_count;
  int unsigned pass_count;
  int unsigned fail_count;

    
  
  function new (string name = "",uvm_component parent);
    super.new(name,parent);
    analysis_export = new("analysis_export",this);
  endfunction
  
  
  //function to reset model if reset happens
  function void reset_model();
       ctrl_reg = '0;
       data_reg = '0;
       irq_reg  = '0;
  endfunction
  
  
  virtual function void write(apb_tx item);
    
    trans_count ++;
    
    expected_status[7:0]   = ctrl_reg[7:0];
    expected_status[8]     = |irq_reg;
    expected_status[15:9]  = 7'b0;
    expected_status[31:16] = 16'hABCD;
    


    if (item.direction == WRITE) begin  // First check if writes are happening as expected.
      begin
        case(item.paddr)
          8'h00: begin
                 if (item.response == OK) begin
                       ctrl_reg = item.pwdata;  // Update model
                       pass_count++;
                   `uvm_info("SCOREBOARD", "Write to CTRL_REG completed OK", UVM_LOW)
                   end else begin
                       fail_count++;
                     `uvm_error("SCOREBOARD", "Write to CTRL_REG got unexpected ERROR!")
                   end
                 end
          8'h04: begin
                   if (item.response == OK) begin
                      // Don't update model - RO register ignores writes
                      pass_count++;
                     `uvm_info("SCOREBOARD", "Write to STATUS_REG (RO) completed OK (ignored)", UVM_LOW)
                   end else begin
                      fail_count++;
                      `uvm_error("SCOREBOARD", "Write to STATUS_REG got unexpected ERROR!")
                   end
                 end
          8'h08: begin
                   if (item.response == OK) begin
                      data_reg = item.pwdata;
                      pass_count++;
                   end else begin
                      fail_count++;
                      `uvm_error("SCOREBOARD", "Write to DATA_REG got unexpected ERROR!")
                   end
                 end
         8'h0c: begin
                   if (item.response == OK) begin
                      irq_reg = irq_reg & ~item.pwdata; 
                      pass_count++;
                   end else begin
                      fail_count++;
                      `uvm_error("SCOREBOARD", "Write to DATA_REG got unexpected ERROR!")
                   end
                 end
         default: begin  // Check if errors are happening as expected.
                   if (item.response == ERROR) begin 
                      pass_count++;
                      `uvm_info("SCOREBOARD", $sformatf("Write to invalid addr %0h correctly returned ERROR", item.paddr), UVM_LOW)
                   end else begin
                      fail_count++;
                      `uvm_error("SCOREBOARD", $sformatf("Write to invalid addr %0h should have returned ERROR!", item.paddr))
                  end
         end
        endcase
         write_count++;
      end
    end
    else begin
      case(item.paddr)  // Check read behavior 
        8'h00: if (ctrl_reg == item.prdata && item.response == OK) begin
                 `uvm_info("SCOREBOARD",$sformatf("[%0d] Data Match for ADDR: %0h, DATA: %0h",$time,item.paddr,item.prdata),UVM_LOW)
                  pass_count++;
               end else begin
                 `uvm_error("SCOREBOARD", $sformatf("MISMATCH! ADDR:%0h EXP:%0h ACT:%0h", item.paddr, ctrl_reg, item.prdata))
                  fail_count++;
               end
        
        8'h04: if( item.prdata == expected_status && item.response == OK) begin
                  `uvm_info("SCOREBOARD",$sformatf("[%0d] Data Match for ADDR: %0h, DATA: %0h",$time,item.paddr,item.prdata),UVM_LOW)
                   pass_count++;
               end else begin
                  `uvm_error("SCOREBOARD", $sformatf("MISMATCH! ADDR:%0h EXP:%0h ACT:%0h", item.paddr, expected_status, item.prdata))
                   fail_count++;
               end
        8'h08: if (data_reg == item.prdata && item.response == OK) begin
                 `uvm_info("SCOREBOARD",$sformatf("[%0d] Data Match for ADDR: %0h, DATA: %0h",$time,item.paddr,item.prdata),UVM_LOW)
                  pass_count++;
               end else begin
                 `uvm_error("SCOREBOARD", $sformatf("MISMATCH! ADDR:%0h EXP:%0h ACT:%0h", item.paddr, data_reg, item.prdata))
                  fail_count++;
               end
        8'h0c: if(item.prdata  == irq_reg && item.response == OK) begin
                 `uvm_info("SCOREBOARD",$sformatf("[%0d] Data Match for ADDR: %0h, DATA: %0h",$time,item.paddr,item.prdata),UVM_LOW)
                  pass_count++;
               end else begin
                 `uvm_error("SCOREBOARD", $sformatf("MISMATCH! ADDR:%0h EXP:%0h ACT:%0h", item.paddr, irq_reg, item.prdata))
                  fail_count++;
               end
        default: begin //Check expected error behavior
                   if (item.response == ERROR && item.prdata == 32'hDEAD_BEEF) begin
                    `uvm_info("SCOREBOARD", $sformatf("Invalid addr %0h correctly returned ERROR", item.paddr), UVM_LOW)
                     pass_count++;
                   end else begin
                    `uvm_error("SCOREBOARD", $sformatf("Invalid addr %0h: expected ERROR/DEADBEEF, got resp=%0s data=%0h", item.paddr, item.response.name(), item.prdata))
                     fail_count++;
                   end
                 end 
      endcase
      read_count++;
    end

  endfunction
      
  virtual function string report_summary();
    string result;
    result = "\n---------------------------------------\n";
    result = {result, "Final Scoreboard Report \n"};
    result = {result, $sformatf("Transactions : %0d\n", trans_count)};
    result = {result, $sformatf("Writes : %0d\n", write_count)};
    result = {result, $sformatf("Read : %0d\n", read_count)};
    result = {result, $sformatf("Passing transactions :%0d\n", pass_count)};
    result = {result, $sformatf("Failing transactions :%0d\n", fail_count)};   
    result = {result, "----------------------------------------\n"};
     if (fail_count == 0)
       result = {result, "\n**** TEST_PASSED ****\n"};
     else
       result = {result, "\n**** TEST_FAILED ****\n"};    
    result = {result, "\n----------------------------------------\n"};
    
    return result;  
  endfunction
  
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("Scoreboard", report_summary(), UVM_LOW) 
      
  endfunction
endclass
  
    
    
`endif
