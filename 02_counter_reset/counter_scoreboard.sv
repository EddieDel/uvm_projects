`ifndef COUNTER_SCOREBOARD_SV
`define COUNTER_SCOREBOARD_SV

class counter_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(counter_scoreboard)

  // Analysis port to receive items from monitor
  uvm_analysis_imp#(seq_item_drv, counter_scoreboard) analysis_export;

  function new (string name = "", uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction

  // Counters
  int reset_count;
  int trans_count;
  int error_count;

  // Expected count prediction
  logic [3:0] expected_count = 0;


  virtual function void write(seq_item_drv item);
    string error_type = "";  // LOCAL variable - resets each call

    trans_count++;

    // Reset case - resync expected, no checking needed
    if (!item.reset_n) begin
      expected_count = 0;
      reset_count++;
      `uvm_info("SCOREBOARD", "Reset detected - resyncing expected_count to 0", UVM_LOW)
      return;
    end

    // UPDATE expected FIRST (predict post-increment value)
    if (item.enable && item.reset_n) begin
      expected_count = (expected_count + 1) % 16;
    end

    // THEN check against predicted value
    if (item.count != expected_count) begin
      error_type = "COUNT_MISMATCH";

      `uvm_error("SCOREBOARD", $sformatf({
        "\n============ ERROR REPORT ============",
        "\n  Type:      %s",
        "\n  Time:      %0t",
        "\n  Expected:  %0d",
        "\n  Actual:    %0d",
        "\n  Enable:    %0b",
        "\n  Reset_n:   %0b",
        "\n  Trans #:   %0d",
        "\n======================================"},
        error_type, $time, expected_count, item.count,
        item.enable, item.reset_n, trans_count))

      error_count++;  // Count ONCE only

    end else begin
      `uvm_info("SCOREBOARD", $sformatf("PASS: count=%0d matches expected=%0d (trans #%0d)",
                item.count, expected_count, trans_count), UVM_HIGH)
    end

  endfunction


  virtual function string report_summary();
    string result;
    result = "\n---------------------------------------------\n";
    result = {result, " Final Scoreboard Report\n"};
    result = {result, $sformatf(" Total Transactions : %0d\n", trans_count)};
    result = {result, $sformatf(" Total Errors       : %0d\n", error_count)};
    result = {result, $sformatf(" Total Resets       : %0d\n", reset_count)};
    result = {result, "---------------------------------------------\n"};
    return result;
  endfunction


  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("SCOREBOARD", report_summary(), UVM_LOW)
  endfunction

endclass

`endif
