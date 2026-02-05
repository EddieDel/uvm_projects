`ifndef MUX_COVERAGE_SV
 `define MUX_COVERAGE_SV
`uvm_analysis_imp_decl(_item)

class mux_coverage extends uvm_component;
  `uvm_component_utils(mux_coverage)
  
  mux_agent_config agent_config;
  uvm_analysis_imp_item#(mux_item_drv, mux_coverage) port_item;
  
  
  covergroup cover_item with function sample(mux_item_drv item);
    option.per_instance = 1;
    
    sel: coverpoint item.sel {
      option.comment = "Which sel were chosen";
      bins sel_0 = {0};
      bins sel_1 = {1};
      bins sel_2 = {2};
      bins sel_3 = {3};
    }
    
    // Input data coverage
    in0_data: coverpoint item.in0 {
      option.comment = "Input 0 data patterns";
      bins zero = {8'h00};
      bins max = {8'hFF};
      bins low_range = {[8'h01:8'h7F]};
      bins high_range = {[8'h80:8'hFE]};
    }
    
    in1_data: coverpoint item.in1 {
      option.comment = "Input 1 data patterns";
      bins zero = {8'h00};
      bins max = {8'hFF};
      bins low_range = {[8'h01:8'h7F]};
      bins high_range = {[8'h80:8'hFE]};
    }
    
    in2_data: coverpoint item.in2 {
      option.comment = "Input 2 data patterns";
      bins zero = {8'h00};
      bins max = {8'hFF};
      bins low_range = {[8'h01:8'h7F]};
      bins high_range = {[8'h80:8'hFE]};
    }
    
    in3_data: coverpoint item.in3 {
      option.comment = "Input 3 data patterns";
      bins zero = {8'h00};
      bins max = {8'hFF};
      bins low_range = {[8'h01:8'h7F]};
      bins high_range = {[8'h80:8'hFE]};
    }
    
    // Cross coverage - each sel with different data patterns
    sel_x_in0: cross sel, in0_data {
      ignore_bins ignore = binsof(sel) intersect {1,2,3};
    }
    
    sel_x_in1: cross sel, in1_data {
      ignore_bins ignore = binsof(sel) intersect {0,2,3};
    }
    
    sel_x_in2: cross sel, in2_data {
      ignore_bins ignore = binsof(sel) intersect {0,1,3};
    }
    
    sel_x_in3: cross sel, in3_data {
      ignore_bins ignore = binsof(sel) intersect {0,1,2};
    }
    
    
    pre_drive: coverpoint item.pre_drive_delay {
      option.comment = "Delay before sending an item";
      bins delay_less_than_5 = {[1:5]};
      bins delay_0 = {0};
    }
    
  endgroup
  
  function new (string name = "", uvm_component parent);
    super.new (name,parent);
    port_item = new("port_item",this);
    cover_item = new();
    cover_item.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_item"));
  endfunction
  

  virtual function string coverage2string();
   string result;
    real sel_cov, pre_drive_cov, in0_cov, in1_cov, in2_cov, in3_cov;
    real cross_sel_in0, cross_sel_in1, cross_sel_in2, cross_sel_in3, total_cov;
    
    sel_cov = cover_item.sel.get_coverage();
    pre_drive_cov = cover_item.pre_drive.get_coverage();
    in0_cov = cover_item.in0_data.get_coverage();
    in1_cov = cover_item.in1_data.get_coverage();
    in2_cov = cover_item.in2_data.get_coverage();
    in3_cov = cover_item.in3_data.get_coverage();
    cross_sel_in0 = cover_item.sel_x_in0.get_coverage();
    cross_sel_in1 = cover_item.sel_x_in1.get_coverage();
    cross_sel_in2 = cover_item.sel_x_in2.get_coverage();
    cross_sel_in3 = cover_item.sel_x_in3.get_coverage();
    total_cov = cover_item.get_inst_coverage();
    
    result = $sformatf (" \n==============================================\n");
    result = {result, $sformatf(" Coverage Report for %s:\n",get_full_name())};
    result = {result, $sformatf(" ==============================================\n")};
    result = {result, $sformatf(" Coverpoint 'sel'          : %6.2f%%\n", sel_cov)};
    result = {result, $sformatf(" Coverpoint 'pre_drive'    : %6.2f%%\n", pre_drive_cov)};
    result = {result, $sformatf(" Coverpoint 'in0_data'     : %6.2f%%\n", in0_cov)};
    result = {result, $sformatf(" Coverpoint 'in1_data'     : %6.2f%%\n", in1_cov)};
    result = {result, $sformatf(" Coverpoint 'in2_data'     : %6.2f%%\n", in2_cov)};
    result = {result, $sformatf(" Coverpoint 'in3_data'     : %6.2f%%\n", in3_cov)};
    result = {result, $sformatf(" ----------------------------------------------\n")};
    result = {result, $sformatf(" Cross 'sel x in0'         : %6.2f%%\n", cross_sel_in0)};
    result = {result, $sformatf(" Cross 'sel x in1'         : %6.2f%%\n", cross_sel_in1)};
    result = {result, $sformatf(" Cross 'sel x in2'         : %6.2f%%\n", cross_sel_in2)};
    result = {result, $sformatf(" Cross 'sel x in3'         : %6.2f%%\n", cross_sel_in3)};
    result = {result, $sformatf(" ==============================================\n")};
    result = {result, $sformatf(" TOTAL COVERAGE            : %6.2f%%\n", total_cov)};
    result = {result, $sformatf(" ==============================================\n")};
    
    return result;
  endfunction


  virtual function void write_item(mux_item_drv item);
    cover_item.sample(item);
    
  endfunction
  
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("DEBUG", $sformatf("Coverage: %0s", coverage2string()), UVM_NONE)
  endfunction
  
endclass
`endif
    
    
