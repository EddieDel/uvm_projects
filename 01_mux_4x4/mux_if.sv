interface mux_if(input clk);
  logic       ready;
  logic       valid;
  logic [7:0] in0;
  logic [7:0] in1;
  logic [7:0] in2;
  logic [7:0] in3;
  logic [7:0] out;
  logic [1:0] sel;
  
  // ===================================================================
  // ASSERTIONS FOR PROTOCOL CHECKING
  // ===================================================================
  
  // Check valid and ready handshake protocol
  property p_valid_implies_stable_inputs;
    @(posedge clk) valid |-> ($stable(in0) && $stable(in1) && $stable(in2) && $stable(in3) && $stable(sel));
  endproperty
  
  property p_ready_valid_handshake;
    @(posedge clk) (valid && ready) |-> ##1 !valid;
  endproperty
  
  // Check MUX output correctness
  property p_mux_sel0;
    @(posedge clk) (valid && ready && sel == 2'b00) |-> (out == in0);
  endproperty
  
  property p_mux_sel1;
    @(posedge clk) (valid && ready && sel == 2'b01) |-> (out == in1);
  endproperty
  
  property p_mux_sel2;
    @(posedge clk) (valid && ready && sel == 2'b10) |-> (out == in2);
  endproperty
  
  property p_mux_sel3;
    @(posedge clk) (valid && ready && sel == 2'b11) |-> (out == in3);
  endproperty
  
  // Check sel stays within valid range
  property p_sel_valid_range;
    @(posedge clk) valid |-> (sel inside {[0:3]});
  endproperty
  
  // Check output doesn't go to X when valid
  property p_out_no_x_when_valid;
    @(posedge clk) valid |-> !$isunknown(out);
  endproperty
  
  // Assertion instantiations
  assert_valid_implies_stable_inputs: assert property(p_valid_implies_stable_inputs)
    else $error("[ASSERTION FAILED] Inputs changed while valid was asserted!");
    
  assert_ready_valid_handshake: assert property(p_ready_valid_handshake)
    else $error("[ASSERTION FAILED] Valid should deassert after ready-valid handshake!");
    
  assert_mux_sel0: assert property(p_mux_sel0)
    else $error("[ASSERTION FAILED] MUX output mismatch for sel=0! Expected in0=%h, Got out=%h", in0, out);
    
  assert_mux_sel1: assert property(p_mux_sel1)
    else $error("[ASSERTION FAILED] MUX output mismatch for sel=1! Expected in1=%h, Got out=%h", in1, out);
    
  assert_mux_sel2: assert property(p_mux_sel2)
    else $error("[ASSERTION FAILED] MUX output mismatch for sel=2! Expected in2=%h, Got out=%h", in2, out);
    
  assert_mux_sel3: assert property(p_mux_sel3)
    else $error("[ASSERTION FAILED] MUX output mismatch for sel=3! Expected in3=%h, Got out=%h", in3, out);
    
  assert_sel_valid_range: assert property(p_sel_valid_range)
    else $error("[ASSERTION FAILED] Select value %d is out of range [0:3]!", sel);
    
  assert_out_no_x_when_valid: assert property(p_out_no_x_when_valid)
    else $error("[ASSERTION FAILED] Output contains X/Z while valid=1!");
    
  // Coverage for assertion hits (useful for tracking which checks are exercised)
  cover_valid_implies_stable_inputs: cover property(p_valid_implies_stable_inputs);
  cover_ready_valid_handshake: cover property(p_ready_valid_handshake);
  cover_mux_sel0: cover property(p_mux_sel0);
  cover_mux_sel1: cover property(p_mux_sel1);
  cover_mux_sel2: cover property(p_mux_sel2);
  cover_mux_sel3: cover property(p_mux_sel3);
  
endinterface
