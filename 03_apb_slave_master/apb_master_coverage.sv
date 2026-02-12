`ifndef APB_MASTER_COVERAGE_SV
 `define APB_MASTER_COVERAGE_SV
`uvm_analysis_imp_decl(_item)

class apb_master_coverage extends uvm_component;
  `uvm_component_utils(apb_master_coverage)
  
  uvm_analysis_imp_item#(apb_tx, apb_master_coverage) port_item;
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
    //new port item
    port_item = new("port_item",this);
    
     //new covergroups
    cover_group = new();
    cover_group.set_inst_name("cover_group");
  endfunction
  
  
  covergroup cover_group with function sample (apb_tx item);
    option.per_instance = 1;
    
    addr: coverpoint item.paddr iff (!$isunknown(item.paddr)) {
      bins valid_addr[] = {8'h00, 8'h04, 8'h08, 8'h0c};
      bins invalid_addr = default;
    }
    
    slverr: coverpoint item.response iff (!$isunknown(item.response)) {
      bins okay  = {0};
      bins error = {1};
    }
    
    write_read: coverpoint item.direction iff (!$isunknown(item.direction)) {
      bins write  = {1};
      bins read   = {0};
    }
    
    //Transition coverage
    transition: coverpoint item.direction iff (!$isunknown(item.direction)) { 
      bins b0  = (1 => 0);
      bins b1  = (1 => 1);
      bins b2  = (0 => 1);
      bins b3  = (0 => 0);
    }
       
    //Cross coverage    
    addr_x_operation: cross addr, write_read;
    err_x_operation:  cross slverr, write_read;
    err_x_reg:        cross slverr, addr;
  endgroup
  
  virtual function void write_item(apb_tx item);
    cover_group.sample(item);
  endfunction
  
  virtual function string coverage_results();
    string result;
    
    real addr, slverr, write_read, transition;
    real addr_x_operation, err_x_operation, err_x_reg, total_cov;
    
    addr             = cover_group.addr.get_coverage();
    slverr           = cover_group.slverr.get_coverage();
    write_read       = cover_group.write_read.get_coverage();
    transition       = cover_group.transition.get_coverage();
    addr_x_operation = cover_group.addr_x_operation.get_coverage();
    err_x_operation  = cover_group.err_x_operation.get_coverage();
    err_x_reg        = cover_group.err_x_reg.get_coverage();
    total_cov        = cover_group.get_inst_coverage();
    
    result = $sformatf (" \n==============================================\n");
    result = {result, $sformatf(" Coverage Report for %s:\n",get_full_name())};
    result = {result, $sformatf(" ==============================================\n")};
    result = {result, $sformatf(" Coverpoint 'Addr'          : %6.2f%%\n", addr)};
    result = {result, $sformatf(" Coverpoint 'Slverr'    : %6.2f%%\n", slverr)};
    result = {result, $sformatf(" Coverpoint 'Write_Read'     : %6.2f%%\n", write_read)};
    result = {result, $sformatf(" Coverpoint 'Transition'     : %6.2f%%\n", transition)};
    result = {result, $sformatf(" ----------------------------------------------\n")};
    result = {result, $sformatf(" Cross 'Addr  x Direction'         : %6.2f%%\n", addr_x_operation)};
    result = {result, $sformatf(" Cross 'Err  x Direction'         : %6.2f%%\n", err_x_operation)};
    result = {result, $sformatf(" Cross 'Err  x Reg'         : %6.2f%%\n", err_x_reg)};
    result = {result, $sformatf(" ==============================================\n")};
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
