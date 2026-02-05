`ifndef TEST_COUNTER_SV
 `define TEST_COUNTER_SV

class test_counter extends test_base;
  `uvm_component_utils(test_counter)
  
  //Declare all sequences
  counter_random_transactions random_transactions;
  counter_single_transaction  single_transaction;
  counter_max_reset           max_reset;
  counter_overflow            overflow;
  
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //Create all sequences
    random_transactions    = counter_random_transactions::type_id::create("random_transactions");
    single_transaction     = counter_single_transaction::type_id::create("single_transaction");
    max_reset              = counter_max_reset::type_id::create("max_reset");
    overflow               = counter_overflow::type_id::create("overflow");
  endfunction
  
  
  
  virtual task run_phase(uvm_phase phase);
    counter_vif vif = env.agent.ac.get_vif();
  
    `uvm_info("TEST", "Entered run_phase", UVM_LOW)
    phase.raise_objection(this, "=========== Running All tests ===========");

     // ========================================
     // TEST 1: Random Transactions
     // ========================================
     `uvm_info("TEST", ">>> [1] Random Transactions", UVM_LOW)
      reset_dut(vif);  // Helper task to reset
      random_transactions.start(env.agent.sequencer);

     // ========================================
     // TEST 2: Overflow (0 -> 15 -> 0)
     // ========================================
      `uvm_info("TEST", ">>> [2] Overflow Test", UVM_LOW)
       reset_dut(vif);
       overflow.start(env.agent.sequencer);

     // ========================================
     // TEST 3: Max count then reset
     // ========================================
      `uvm_info("TEST", ">>> [3] Reset at Max Count", UVM_LOW)
       reset_dut(vif);
       max_reset.start(env.agent.sequencer);  // Uses your reactive sequence
       // Now count is guaranteed to be 15
       vif.reset_n <= 0;
       repeat(3) @(posedge vif.clk);
       vif.reset_n <= 1;
       `uvm_info("TEST", "Reset asserted at max count", UVM_LOW)

     // ========================================
     // TEST 4: Long reset duration
     // ========================================
      `uvm_info("TEST", ">>> [4] Long Reset Duration", UVM_LOW)
       single_transaction.start(env.agent.sequencer);
       vif.reset_n <= 0;
       repeat(10) @(posedge vif.clk);  // Hold reset for 10 cycles
       vif.reset_n <= 1;
       @(posedge vif.clk);
       single_transaction.start(env.agent.sequencer);  // Continue after reset

       `uvm_info("TEST", "=========== ALL TESTS COMPLETED ===========", UVM_LOW)
       phase.drop_objection(this);
  endtask

  //Reset task
  task reset_dut(counter_vif vif);
       vif.reset_n <= 0;
       repeat(3) @(posedge vif.clk);
       vif.reset_n <= 1;
       @(posedge vif.clk);
  endtask
endclass
`endif
