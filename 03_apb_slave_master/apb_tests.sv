`ifndef APB_TESTS_SV
 `define APB_TESTS_SV

class apb_tests extends apb_test_base;
  `uvm_component_utils(apb_tests)
  
  
  // Sequences
  virtual apb_if vif;
  apb_write_sequence           write_sequence; 
  apb_random_sequences         random_sequences;
  apb_read_sequence            read_sequence;
  apb_write_then_read_sequence write_read;
  
  function new (string name = "", uvm_component parent);
    super.new (name,parent);
  endfunction
  
  virtual function void build_phase( uvm_phase phase);
    super.build_phase(phase);
    random_sequences             = apb_random_sequences::type_id::create("random_sequences");
    write_sequence               = apb_write_sequence::type_id::create("write_sequence");
    read_sequence                = apb_read_sequence::type_id::create("read_sequence");
    write_read                   = apb_write_then_read_sequence::type_id::create("write_read");
  endfunction
  

  virtual task run_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("Tests", "Could not get vif from config_db")
      
    phase.raise_objection(this,"=========== Running Tests ===========");
     
    `uvm_info ("Random Test", ">>> [1] Running Random Transactions Test...",UVM_LOW); 
     reset_dut(vif);
     random_sequences.start(environment.agent.master_sequencer);
    
    `uvm_info ("Write Test", ">>> [1] Running Write Transaction Test...",UVM_LOW); 
     reset_dut(vif);
     write_sequence.start(environment.agent.master_sequencer);
    
    `uvm_info ("Read Test", ">>> [1] Running Read Transaction Test...",UVM_LOW); 
     reset_dut(vif);
     read_sequence.start(environment.agent.master_sequencer);
    
    `uvm_info ("Read Test", ">>> [1] Running Write then Read Transaction Test...",UVM_LOW);
     reset_dut(vif);
     write_read.start(environment.agent.master_sequencer);
    
    
    phase.drop_objection(this,"=========== Finished Tests ===========");
  endtask
               
  //Reset Dut task
  task reset_dut(virtual apb_if vif);
    vif.preset_n <= 0;
    repeat(3) @(posedge vif.pclk);
    vif.preset_n <= 1;
    @(posedge vif.pclk);
  endtask
  
endclass
`endif



