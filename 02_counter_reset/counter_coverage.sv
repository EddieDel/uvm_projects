`ifndef COUNTER_COVERAGE_SV
 `define COUNTER_COVERAGE_SV
 `uvm_analysis_imp_decl(_item)

class counter_coverage extends uvm_component;
  `uvm_component_utils(counter_coverage)
  
  agent_config ac;
  uvm_analysis_imp_item#(seq_item_drv, counter_coverage) port_item;
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
    port_item = new("port_item",this);
	cover_item = new();
    cover_item.set_inst_name("cover_item");

    cg_overflow = new();
    cg_overflow.set_inst_name("cg_overflow");
  endfunction
  

  covergroup cover_item with function sample(seq_item_drv item);
    option.per_instance = 1;
     
    count: coverpoint item.count iff (!$isunknown(item.count)) {
      bins zero_to_15[] = {[0:15]};
    }
    
    enable: coverpoint item.enable {
      option.comment = "Enable Values";
      bins enable_1 = {1};
      bins enable_0 = {0};
    }
    
    reset_n: coverpoint item.reset_n {
      option.comment = "Reset Values";
      bins reset_1 = {1};
      bins reset_0 = {0};
    } 
         
    max: coverpoint item.count {
      option.comment = "Max Count";
      bins max_val = {15};
    }

    min: coverpoint item.count {
      option.comment = "Min Count";
      bins min_val = {0};
    }
    
    //cross coverage 
    //Check when enable - count
    en_x_count: cross enable, count;
    
    //Check when reset - count 
    rs_x_count: cross reset_n, count;   


    //transition coverage
    //cover from count 0 -> non-zero
    zero_to_non_zero: coverpoint item.count {
      bins bb = (0 => [1:15]);
    }
    
    enable_disable : coverpoint item.enable {
      bins rise = (0 => 1);
      bins fall = (1 => 0);
      bins pulse = (0 => 1 => 0);
      bins hold_high = ( 1 => 1);
    }  
    
    consecutive: coverpoint item.count iff (!$isunknown(item.count)) {
      bins b0 = (0 => 1);
      bins b1 = (1 => 2);
      bins b2 = (2 => 3);
      bins b3 = (3 => 4);
      bins b4 = (4 => 5);
      bins b5 = (5 => 6);
      bins b6 = (6 => 7);
      bins b7 = (7 => 8);
      bins b8 = (8 => 9);
      bins b9 = (9 => 10);
      bins b10 = (10 => 11);
      bins b11 = (11 => 12);
      bins b12 = (12 => 13);
      bins b13 = (13 => 14);
      bins b14 = (14 => 15);
      
      illegal_bins wrap_without_overflow = (15 => [1:14]);
    }  
    
  endgroup
  
  covergroup cg_overflow with function sample(seq_item_drv item);
    option.per_instance = 1;
    overflow: coverpoint item.count {
      bins overflow_transition = (15 => 0);
    }
  endgroup
  

  virtual function void write_item(seq_item_drv item);
    cover_item.sample(item);
    cg_overflow.sample(item);
  endfunction
  
  
  virtual function string coverage2string();
   string result;
    real count, enable, reset_n, max, min, zero_to_non_zero, consecutive,overflow, enable_disable;
    real en_x_count, rs_x_count, total_cov;
    
    overflow = cg_overflow.overflow.get_coverage();
    count = cover_item.count.get_coverage();
    enable = cover_item.enable.get_coverage();
    reset_n = cover_item.reset_n.get_coverage();
    max = cover_item.max.get_coverage();
    min = cover_item.min.get_coverage();
    zero_to_non_zero = cover_item.zero_to_non_zero.get_coverage();
    consecutive = cover_item.consecutive.get_coverage();
    enable_disable = cover_item.enable_disable.get_coverage();
    en_x_count = cover_item.en_x_count.get_coverage();
    rs_x_count = cover_item.rs_x_count.get_coverage();
    total_cov = cover_item.get_inst_coverage();
    
    result = $sformatf (" \n==============================================\n");
    result = {result, $sformatf(" Coverage Report for %s:\n",get_full_name())};
    result = {result, $sformatf(" ==============================================\n")};
    result = {result, $sformatf(" Coverpoint 'count'          : %6.2f%%\n", count)};
    result = {result, $sformatf(" Coverpoint 'enable'    : %6.2f%%\n", enable)};
    result = {result, $sformatf(" Coverpoint 'reset_n'     : %6.2f%%\n", reset_n)};
    result = {result, $sformatf(" Coverpoint 'max'     : %6.2f%%\n", max)};
    result = {result, $sformatf(" Coverpoint 'min'     : %6.2f%%\n", min)};
    result = {result, $sformatf(" Coverpoint 'zero_to_non_zero'     : %6.2f%%\n", zero_to_non_zero)};
    result = {result, $sformatf(" Coverpoint 'consecutive'     : %6.2f%%\n", consecutive)};
    result = {result, $sformatf(" Coverpoint 'enable_disable'  : %6.2f%%\n", enable_disable)};
    result = {result, $sformatf(" Coverpoint 'overflow'     : %6.2f%%\n", overflow)};
    result = {result, $sformatf(" ----------------------------------------------\n")};
    result = {result, $sformatf(" Cross 'en  x count'         : %6.2f%%\n", en_x_count)};
    result = {result, $sformatf(" Cross 'rs  x count'         : %6.2f%%\n", rs_x_count)};
    result = {result, $sformatf(" ==============================================\n")};
    result = {result, $sformatf(" TOTAL COVERAGE            : %6.2f%%\n", total_cov)};
    result = {result, $sformatf(" ==============================================\n")};
    
    return result;
  endfunction
   
  
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("DEBUG", $sformatf("Coverage: %0s", coverage2string()), UVM_NONE)
  endfunction
  
endclass
`endif
