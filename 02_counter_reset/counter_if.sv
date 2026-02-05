`ifndef COUNTER_IF_SV
 `define COUNTER_IF_SV

interface counter_if(input clk);
  logic reset_n;
  logic enable;
  logic [3:0] count;
  


  //clocking block for monitor
  clocking ckbm @(posedge clk);
    default input #1step;
    input reset_n;
    input enable;
    input count;
  endclocking


  
  // ===================================================================
  // ASSERTIONS FOR PROTOCOL CHECKING
  // ===================================================================
  
  //Check reset behavior
  property p_reset_behavior;
    @(posedge clk) (!reset_n) |-> ##1 (count == 0);
  endproperty
  
  //Check enable and resert count
  property p_enable_reset_count;
    @(posedge clk) disable iff (!reset_n) 
    (enable && count < 15) |-> ##1 (count == $past(count) + 1);
  endproperty
  
  //Check for overflow wrap
  property p_overflow_wrap;
    @(posedge clk) disable iff (!reset_n)
    (enable && count == 15) |-> ##1 (count == 0);
  endproperty
  
  //Check count doesnt go to x when enable and reset
  property p_count_unknown;
    @(posedge clk) disable iff (!reset_n)
    (enable ) |-> !$isunknown(count);
  endproperty
  
  //Stable count assertion
  property p_stable_count;
    @(posedge clk) disable iff (!reset_n)
    (!enable) |-> ##1 (count == $past(count));
  endproperty
  
  //Assertion instantiations
  assert_p_reset_behavior: assert property (p_reset_behavior)
    else $error("[ASSERTION FAILED] Reset didnt reset count!");

  assert_p_enable_reset_count: assert property (p_enable_reset_count)
    else $error("[ASSERTION FAILED] Count didnt increment!");
    
  assert_p_count_unknown: assert property (p_count_unknown)
    else $error("[ASSERTION FAILED] Count has unknown values!");
    
  assert_p_overflow_wrap: assert property (p_overflow_wrap)
    else $error("[ASSERTION FAILED] Overflow wrap didnt happen!"); 
    
  assert_p_stable_count: assert property (p_stable_count)
    else $error ("[ASSERTION FAILED] Count changed while enable was low!");
  
endinterface

`endif

`endif
