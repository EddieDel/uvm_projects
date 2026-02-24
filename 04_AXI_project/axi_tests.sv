`ifndef AXI_TESTS_SV
 `define AXI_TESTS_SV

class axi_tests extends axi_test_base;
  `uvm_component_utils(axi_tests)
  
  //Declare sequences here
  axi_write_sequences random_write_sequences;
  axi_read_sequences  random_read_sequences;
  
  //Virtual interface handle
  virtual axi_if vif;
  
  function new (string name = "", uvm_component parent);
    super.new (name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    random_write_sequences = axi_write_sequences::type_id::create("random_write_sequences",this);
    random_read_sequences = axi_read_sequences::type_id::create("random_read_sequences",this);
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "","vif",vif)) begin
      `uvm_fatal("Tests","Could not retrieve interface from db")
    end
    phase.raise_objection(this, "========= Start Tests =========");
    
    
    `uvm_info ("Tests",">>> Starting random write and read sequences...", UVM_LOW);
    reset_dut(vif);
    random_write_sequences.start(environment.write_agent.write_sequencer);
    random_read_sequences.start(environment.read_agent.read_sequencer);
              
    
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
