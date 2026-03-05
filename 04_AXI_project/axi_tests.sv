`ifndef AXI_TESTS_SV
 `define AXI_TESTS_SV

class axi_tests extends axi_test_base;
  `uvm_component_utils(axi_tests)
  
  //Declare sequences here
  write_read_back_seq write_then_read;
  
  //Virtual interface handle
  virtual axi_if vif;
  
  function new (string name = "", uvm_component parent);
    super.new (name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    write_then_read = write_read_back_seq::type_id::create("write_then_read");
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "","vif",vif)) begin
      `uvm_fatal("Tests","Could not retrieve interface from db")
    end
    phase.raise_objection(this, "========= Start Tests =========");
    
    
    `uvm_info ("Tests",">>> Starting Sanity Write then read test...", UVM_LOW);
    reset_dut(vif);
    write_then_read.start(environment.v_sqr);
              
    
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
