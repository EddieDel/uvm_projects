`ifndef AXI_COVERAGE_SV
 `define AXI_COVERAGE_SV

`uvm_analysis_imp_decl(_wr_item)
`uvm_analysis_imp_decl(_r_item)

class axi_coverage extends uvm_component;
  `uvm_component_utils(axi_coverage)
  
  //Analysis port implementations from read / write agents
  uvm_analysis_imp_wr_item#(axi_write_tx, axi_coverage) wr_item;
  uvm_analysis_imp_r_item#(axi_read_tx, axi_coverage) r_item; 
  
  function new (string name = "", uvm_component parent);
    super.new(name,parent);
    wr_item = new("wr_item", this);
    r_item  = new("r_item", this);
    
    write_cover_group = new();
    write_cover_group.set_inst_name("write_cover_group");
    
    read_cover_group = new();
    read_cover_group.set_inst_name("read_cover_group");
  endfunction
  
  covergroup write_cover_group with function sample (axi_write_tx wr_item);
    option.per_instance = 1;
    
  endgroup
  
  covergroup read_cover_group with function sample (axi_read_tx r_item);
    option.per_instance = 1;
    
  endgroup
  
  virtual function void write_wr_item(axi_write_tx wr_item);
    write_cover_group.sample(wr_item);
  endfunction  
  
  
  virtual function void write_r_item(axi_read_tx r_item);
    read_cover_group.sample(r_item);
  endfunction
  
  virtual function string coverage_results();
    string result;
    
    real total_cov;
    
    total_cov = (write_cover_group.get_coverage() + read_cover_group.get_coverage()) / 2.0;
    
    result = $sformatf (" \n==============================================\n");
    result = {result, $sformatf(" Coverage Report for %s:\n",get_full_name())};

    
    result = {result, $sformatf(" TOTAL COVERAGE            : %6.2f%%\n", total_cov)};
    result = {result, $sformatf(" ==============================================\n")};
    return result;  
  endfunction
 
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("Coverage",coverage_results(),UVM_LOW)
  endfunction
  
endclass
`endif
