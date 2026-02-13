`ifndef APB_ENVIRONMENT_SV
 `define APB_ENVIRONMENT_SV

class apb_environment extends uvm_env;
  `uvm_component_utils(apb_environment)
  
  apb_agent         agent;
  apb_scoreboard    scoreboard;
  apb_reg_block     reg_block;
  apb_reg_adapter   reg_adapter;
  uvm_reg_predictor #(apb_tx) predictor_inst;
  
  
  function new (string name= "", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent           = apb_agent::type_id::create("agent",this);
    scoreboard      = apb_scoreboard::type_id::create("scoreboard",this);
    
    reg_block       = apb_reg_block::type_id::create("reg_block",this);
    reg_block.configure(null);
    reg_block.build();
    reg_adapter     = apb_reg_adapter::type_id::create("reg_adapter",,get_full_name());
    predictor_inst  = uvm_reg_predictor#(apb_tx)::type_id::create("predictor_inst",this);   
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.master_monitor.analysis_port.connect(scoreboard.analysis_export);
    
    //ral connections
    reg_block.default_map.set_sequencer( .sequencer(agent.master_sequencer), .adapter(reg_adapter));
    reg_block.default_map.set_base_addr(0);
    predictor_inst.map  = reg_block.default_map;
    predictor_inst.adapter = reg_adapter;
    agent.master_monitor.analysis_port.connect(predictor_inst.bus_in);
  endfunction

endclass

`endif

