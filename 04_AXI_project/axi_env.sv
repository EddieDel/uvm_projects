`ifndef AXI_ENV_SV
 `define AXI_ENV_SV

class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)
  
  //Declarations
  axi_write_agent write_agent;
  
  
  function new(string name = "",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    write_agent = axi_write_agent::type_id::create("write_agent",this);
    //build scoreboard here
    //build coverage here
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //connect analysis port with scb
    //connect analysis port with coverage
  endfunction
  
endclass

`endif
