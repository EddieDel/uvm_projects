class mux_test_cases extends mux_test_base;
  `uvm_component_utils(mux_test_cases)
  
  // Declare all sequences
  mux_sequence                    random_seq;
  mux_all_zeros_sequence          zeros_seq;
  mux_all_ones_sequence           ones_seq;
  mux_unique_values_sequence      unique_seq;
  mux_walking_ones_sequence       walking_seq;
  mux_back2back_sequence          back2back_seq;
  mux_select_toggle_sequence      toggle_seq;
  mux_same_input_sequence         same_input_seq;
  mux_alternating_pattern_sequence alt_pattern_seq;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create all sequences
    random_seq      = mux_sequence::type_id::create("random_seq");
    zeros_seq       = mux_all_zeros_sequence::type_id::create("zeros_seq");
    ones_seq        = mux_all_ones_sequence::type_id::create("ones_seq");
    unique_seq      = mux_unique_values_sequence::type_id::create("unique_seq");
    walking_seq     = mux_walking_ones_sequence::type_id::create("walking_seq");
    back2back_seq   = mux_back2back_sequence::type_id::create("back2back_seq");
    toggle_seq      = mux_select_toggle_sequence::type_id::create("toggle_seq");
    same_input_seq  = mux_same_input_sequence::type_id::create("same_input_seq");
    alt_pattern_seq = mux_alternating_pattern_sequence::type_id::create("alt_pattern_seq");
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this, "Running comprehensive mux test");
    
    `uvm_info("TEST", "========================================", UVM_NONE)
    `uvm_info("TEST", "  COMPREHENSIVE MUX VERIFICATION TEST  ", UVM_NONE)
    `uvm_info("TEST", "========================================", UVM_NONE)
    
    #100ns; // Initial settling time
    
    // Run corner case tests first
    `uvm_info("TEST", ">>> Running All Zeros Test...", UVM_NONE)
    zeros_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running All Ones Test...", UVM_NONE)
    ones_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running Unique Values Test...", UVM_NONE)
    unique_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running Walking Ones Test...", UVM_NONE)
    walking_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running Back-to-Back Test...", UVM_NONE)
    back2back_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running Select Toggle Test...", UVM_NONE)
    toggle_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running Same Input Test...", UVM_NONE)
    same_input_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running Alternating Pattern Test...", UVM_NONE)
    alt_pattern_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", ">>> Running Random Test for Coverage...", UVM_NONE)
    random_seq.start(env.agent.sequencer);
    
    `uvm_info("TEST", "========================================", UVM_NONE)
    `uvm_info("TEST", "   ALL TESTS COMPLETED SUCCESSFULLY    ", UVM_NONE)
    `uvm_info("TEST", "========================================", UVM_NONE)
    
    phase.drop_objection(this, "Completed comprehensive mux test");
  endtask
endclass
