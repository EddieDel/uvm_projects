`ifndef MUX_AGENT_CONFIG_SV
 `define MUX_AGENT_CONFIG_SV

class mux_agent_config extends uvm_component;
 
  typedef virtual mux_if mux_vif;
  local mux_vif vif;
  local uvm_active_passive_enum active_passive;
  local bit has_coverage;
  
   `uvm_component_utils(mux_agent_config)
  
  function new (string name = "",uvm_component parent);
    super.new(name,parent);
    active_passive =UVM_ACTIVE;
    has_coverage = 1;
  endfunction
  
 
  virtual function mux_vif get_vif();
    return vif;
  endfunction
  
  virtual function void set_vif(mux_vif value);
    if(vif == null) begin
      vif = value;
    end
    else begin
      `uvm_fatal ("Test Issue", "Trying to set vif more than once");
    end
  endfunction
 
  virtual function uvm_active_passive_enum get_active_passive();
     return active_passive;
  endfunction

  
  virtual function void set_active_passive(uvm_active_passive_enum value);
     active_passive = value;
  endfunction

  virtual function bit get_has_coverage();
    return has_coverage;
  endfunction
  
  virtual function void set_has_coverage(bit value);
    has_coverage = value;
  endfunction    
        
endclass

`endif
