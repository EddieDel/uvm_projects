`ifndef AXI_TESTS_SV
`define AXI_TESTS_SV

class axi_tests extends axi_test_base;
  `uvm_component_utils(axi_tests)
  
  // Sequences
  write_read_back_seq  write_then_read;
  burst_types_seq      burst_types;
  back_to_back_seq     back_to_back;
  burst_length_seq     burst_lengths;
  random_stress_seq    random_stress;
  
  virtual axi_if vif;
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    write_then_read = write_read_back_seq::type_id::create("write_then_read");
    burst_types     = burst_types_seq::type_id::create("burst_types");
    back_to_back    = back_to_back_seq::type_id::create("back_to_back");
    burst_lengths   = burst_length_seq::type_id::create("burst_lengths");
    random_stress   = random_stress_seq::type_id::create("random_stress");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("Tests", "Could not retrieve interface from db")
    end
    
    phase.raise_objection(this, "========= Start Tests =========");
    
    // Test 1: Basic write-read
    `uvm_info("Tests", ">>> [1/5] Write-Read-Back Test", UVM_LOW)
    reset_dut(vif);
    write_then_read.start(environment.v_sqr);
    
    // Test 2: Burst types
    `uvm_info("Tests", ">>> [2/5] Burst Types Test (FIXED/INCR/WRAP)", UVM_LOW)
    reset_dut(vif);
    burst_types.start(environment.v_sqr);
    
    // Test 3: Back-to-back
    `uvm_info("Tests", ">>> [3/5] Back-to-Back Stress Test", UVM_LOW)
    reset_dut(vif);
    back_to_back.start(environment.v_sqr);
    
    // Test 4: Burst lengths
    `uvm_info("Tests", ">>> [4/5] Burst Length Variations", UVM_LOW)
    reset_dut(vif);
    burst_lengths.start(environment.v_sqr);
    
    // Test 5: Random stress
    `uvm_info("Tests", ">>> [5/5] Random Stress Test", UVM_LOW)
    reset_dut(vif);
    random_stress.start(environment.v_sqr);
    
    `uvm_info("Tests", ">>> ALL TESTS COMPLETE", UVM_LOW)
    phase.drop_objection(this, "========= End Tests =========");
  endtask
  
  task reset_dut(virtual axi_if vif);
    vif.aresetn <= 0;
    repeat(3) @(posedge vif.aclk);
    vif.aresetn <= 1;
    @(posedge vif.aclk);
  endtask
  
endclass

`endif
