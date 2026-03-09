`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV

`uvm_analysis_imp_decl(_write_export)
`uvm_analysis_imp_decl(_read_export)

class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)
  
  // Analysis port implementations
  uvm_analysis_imp_write_export#(axi_write_tx, axi_scoreboard) write_export;
  uvm_analysis_imp_read_export#(axi_read_tx, axi_scoreboard) read_export;
  
  // Memory model - stores data AND strobe for each address
  typedef struct {
    logic [DATA_WIDTH-1:0] data;
    logic [DATA_WIDTH-1:0] strb;
  } mem_entry_t;
  
  mem_entry_t memory[logic [ADDR_WIDTH-1:0]];
  
  int burst_len    = 0;
  int rburst_len   = 0;
  logic [ADDR_WIDTH-1:0] calculated_addr;
  logic [ADDR_WIDTH-1:0] rcalculated_addr;
  logic [ADDR_WIDTH-1:0] wrap_boundary;
  logic [ADDR_WIDTH-1:0] lower_wrap_boundary;
  
  // Counters
  int slverr_count     = 0;
  int decrr_count      = 0;
  int okay_count       = 0;
  int writes           = 0;
  int reads            = 0;
  int matched          = 0;
  int mismatched       = 0;
  int unwritten_reads  = 0;
  int transactions     = 0;
  
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    write_export = new("write_export", this);
    read_export  = new("read_export", this);
  endfunction
  
  
  // Apply strobe mask to data - only keep bytes where strobe is set
  function logic [DATA_WIDTH-1:0] apply_strobe_mask(
    logic [DATA_WIDTH-1:0] data, 
    logic [DATA_WIDTH-1:0] strb
  );
    logic [DATA_WIDTH-1:0] masked = '0;
    for (int i = 0; i < DATA_WIDTH; i++) begin
      if (strb[i])
        masked[i*8 +: 8] = data[i*8 +: 8];
    end
    return masked;
  endfunction
  
  
  // Merge new write data with existing data based on strobe
  function mem_entry_t merge_write_data(
    mem_entry_t existing,
    logic [DATA_WIDTH-1:0] new_data,
    logic [DATA_WIDTH-1:0] new_strb
  );
    mem_entry_t result;
    result.data = existing.data;
    result.strb = existing.strb;
    
    // Merge each byte based on new strobe
    for (int i = 0; i < DATA_WIDTH; i++) begin
      if (new_strb[i]) begin
        result.data[i*8 +: 8] = new_data[i*8 +: 8];
        result.strb[i] = 1'b1;
      end
    end
    return result;
  endfunction
  
  
  virtual function void write_write_export(axi_write_tx witem);
    mem_entry_t entry;
    
    transactions++;
    burst_len = witem.awlen + 1;
    
    `uvm_info("Scoreboard", $sformatf("[WRITE] ID:%0d Addr:0x%0h Len:%0d Size:%0d Burst:%s", 
              witem.awid, witem.awaddr, witem.awlen, witem.awsize, 
              (witem.awburst == 2'b00) ? "FIXED" : (witem.awburst == 2'b01) ? "INCR" : "WRAP"), UVM_MEDIUM)
    
    if (witem.resp == OKAY || witem.resp == EXOKAY) begin
      for (int i = 0; i < burst_len; i++) begin
        case (witem.awburst)
          2'b00: calculated_addr = witem.awaddr;  // FIXED
          2'b01: calculated_addr = witem.awaddr + (i * 2**witem.awsize);  // INCR
          2'b10: begin  // WRAP
            wrap_boundary       = burst_len * (2**witem.awsize);
            lower_wrap_boundary = (witem.awaddr / wrap_boundary) * wrap_boundary;
            calculated_addr     = lower_wrap_boundary + 
                                  ((witem.awaddr + (i * 2**witem.awsize) - lower_wrap_boundary) % wrap_boundary);
          end
          default: `uvm_error("Scoreboard", "Unknown burst type")
        endcase
        
        // Merge with existing data if address was previously written
        if (memory.exists(calculated_addr)) begin
          entry = merge_write_data(memory[calculated_addr], witem.wdata[i], witem.wstrb[i]);
        end
        else begin
          entry.data = witem.wdata[i];
          entry.strb = witem.wstrb[i];
        end
        
        memory[calculated_addr] = entry;
        
        `uvm_info("Scoreboard", $sformatf("[WRITE STORED] Addr:0x%0h Data:0x%0h Strb:0x%0h Beat:%0d/%0d", 
                  calculated_addr, witem.wdata[i], witem.wstrb[i], i+1, burst_len), UVM_HIGH)
      end
      okay_count++;
      writes++;
    end
    else if (witem.resp == SLVERR) begin
      `uvm_error("Scoreboard", "We have a slave error")
      slverr_count++;
    end
    else begin
      `uvm_error("Scoreboard", "We have a DECERR error")
      decrr_count++;
    end
  endfunction
  
  
  virtual function void write_read_export(axi_read_tx ritem);
    logic [DATA_WIDTH-1:0] expected_masked;
    logic [DATA_WIDTH-1:0] actual_masked;
    logic [DATA_WIDTH-1:0] stored_strb;
    
    transactions++;
    rburst_len = ritem.arlen + 1;
    
    if (ritem.rresp == OKAY || ritem.rresp == EXOKAY) begin
      for (int i = 0; i < rburst_len; i++) begin
        case (ritem.arburst)
          2'b00: rcalculated_addr = ritem.araddr;  // FIXED
          2'b01: rcalculated_addr = ritem.araddr + (i * 2**ritem.arsize);  // INCR
          2'b10: begin  // WRAP
            wrap_boundary       = rburst_len * (2**ritem.arsize);
            lower_wrap_boundary = (ritem.araddr / wrap_boundary) * wrap_boundary;
            rcalculated_addr    = lower_wrap_boundary + 
                                  ((ritem.araddr + (i * 2**ritem.arsize) - lower_wrap_boundary) % wrap_boundary);
          end
          default: `uvm_error("Scoreboard", "Unknown burst type")
        endcase
        
        if (memory.exists(rcalculated_addr)) begin
          stored_strb     = memory[rcalculated_addr].strb;
          expected_masked = apply_strobe_mask(memory[rcalculated_addr].data, stored_strb);
          actual_masked   = apply_strobe_mask(ritem.rdata[i], stored_strb);
          
          if (expected_masked == actual_masked) begin
            `uvm_info("Scoreboard", $sformatf("[READ MATCH] ID:%0d Addr:0x%0h Expected:0x%0h Got:0x%0h Strb:0x%0h Beat:%0d/%0d", 
                      ritem.arid, rcalculated_addr, expected_masked, actual_masked, stored_strb, i+1, rburst_len), UVM_LOW)
            matched++;
          end
          else begin
            `uvm_error("Scoreboard", $sformatf("[READ MISMATCH] ID:%0d Addr:0x%0h Expected:0x%0h Got:0x%0h Strb:0x%0h Beat:%0d/%0d", 
                       ritem.arid, rcalculated_addr, expected_masked, actual_masked, stored_strb, i+1, rburst_len))
            mismatched++;
          end
        end
        else begin
          `uvm_warning("Scoreboard", $sformatf("[UNWRITTEN READ] Addr:0x%0h has not been written - skipping comparison", rcalculated_addr))
          unwritten_reads++;
        end
      end
      reads++;
      okay_count++;
    end
    else if (ritem.rresp == SLVERR) begin
      `uvm_error("Scoreboard", "We have a slave error")
      slverr_count++;
    end
    else begin
      `uvm_error("Scoreboard", "We have a DECERR error")
      decrr_count++;
    end
  endfunction
  
  
  virtual function string report_summary();
    string result;
    result = "\n=======================================\n";
    result = {result, "         Final Scoreboard Report       \n"};
    result = {result, "=======================================\n"};
    result = {result, $sformatf("Transactions    : %0d\n", transactions)};
    result = {result, $sformatf("Writes          : %0d\n", writes)};
    result = {result, $sformatf("Reads           : %0d\n", reads)};
    result = {result, $sformatf("Matches         : %0d\n", matched)};
    result = {result, $sformatf("Mismatches      : %0d\n", mismatched)};
    result = {result, $sformatf("Unwritten Reads : %0d\n", unwritten_reads)};
    result = {result, $sformatf("OKAY Responses  : %0d\n", okay_count)};
    result = {result, $sformatf("SLVERR Responses: %0d\n", slverr_count)};
    result = {result, $sformatf("DECERR Responses: %0d\n", decrr_count)};
    result = {result, "=======================================\n"};
    
    if (mismatched > 0 || slverr_count > 0 || decrr_count > 0)
      result = {result, "          **** TEST FAILED ****        \n"};
    else
      result = {result, "          **** TEST PASSED ****        \n"};
    
    result = {result, "=======================================\n"};
    return result;
  endfunction
  
  
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("Scoreboard", report_summary(), UVM_LOW)
  endfunction
  
endclass

`endif
