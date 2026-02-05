`ifndef AGENT_CONFIG_SV
 `define AGENT_CONFIG_SV

class agent_config extends uvm_component;
  
    
  typedef virtual counter_if counter_vif;
  local counter_vif vif;
  local uvm_active_passive_enum active_passive;
  local bit has_coverage;
  
  `uvm_component_utils(agent_config)

  
  function new(string name = "", uvm_component parent);
    super.new(name,parent);
    active_passive = UVM_ACTIVE;
    has_coverage = 1;
  endfunction
  
  //Set and get for VIF
  virtual function counter_vif get_vif();
    return vif;
  endfunction
  
  virtual function void set_vif(counter_vif value);
    if(vif== null) begin
      vif = value;
    end
    else begin
      `uvm_fatal("Algorithm Issue", "Trying to set vif more than once");
    end
  endfunction
  
  //Set and Get active agent
  virtual function uvm_active_passive_enum get_active_passive();
     return active_passive;
  endfunction

  
  virtual function void set_active_passive(uvm_active_passive_enum value);
     active_passive = value;
  endfunction
  
  //Set and Get Has_Coverage
  virtual function bit get_has_coverage();
    return has_coverage;
  endfunction
  
  virtual function void set_has_coverage(bit value);
    has_coverage = value;
  endfunction 
  
  //Reset Logic consists of two tasks, start and end
  virtual task wait_reset_start();
    if (vif.reset_n === 1) begin
      @(negedge vif.reset_n);
    end else if (vif.reset_n === 0) begin
      //already in reset, continue
    end else begin
      wait (vif.reset_n === 0 || vif.reset_n === 1);
      if (vif.reset_n === 1)
        @(negedge vif.reset_n);
    end
    
  endtask
  
  virtual task wait_reset_end();
    `uvm_info("Agent_Config", $sformatf("Waiting for reset_n to go high. Current: %b", vif.reset_n), UVM_LOW);
    while (vif.reset_n == 0) begin
      @(posedge vif.reset_n);
    end
  endtask
    
        
endclass
  

`endif
