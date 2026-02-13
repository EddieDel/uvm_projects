`ifndef APB_REG_MODEL_SV
 `define APB_REG_MODEL_SV

// Individual register classes
class ctrl_reg extends uvm_reg;
  `uvm_object_utils(ctrl_reg)
  
  rand uvm_reg_field data;
  
  function new (string name = "ctrl_reg");
    super.new(name, 32, UVM_NO_COVERAGE); //Name, size, coverage
  endfunction
               
  
  virtual function void build();
    data= uvm_reg_field::type_id::create("data");
    // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
    data.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
  endfunction

endclass

class status_reg extends uvm_reg;
  `uvm_object_utils(status_reg)
  
  rand uvm_reg_field ctrl_mirror;
  rand uvm_reg_field irq_pending;
  rand uvm_reg_field reserved;
  rand uvm_reg_field hw_id;
  
  function new (string name = "status_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    ctrl_mirror = uvm_reg_field::type_id::create("ctrl_mirror");
    irq_pending = uvm_reg_field::type_id::create("irq_pending");
    reserved    = uvm_reg_field::type_id::create("reserved");
    hw_id       = uvm_reg_field::type_id::create("hw_id");
    
    //configure
    ctrl_mirror.configure(this, 8, 0, "RO", 0, 0, 0, 1, 1);
    irq_pending.configure(this, 1, 8, "RO", 0, 0, 0, 1, 1);
    reserved.configure(this, 7, 9, "RO", 1, 32'h0, 0, 1, 1);
    hw_id.configure(this, 16, 16, "RO", 1, 16'hABCD, 0, 1, 1);
  endfunction
    
endclass

class data_reg extends uvm_reg;
  `uvm_object_utils(data_reg)
  
  rand uvm_reg_field data2;
  
  function new (string name = "data_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    data2 = uvm_reg_field::type_id::create("data");
    
    data2.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
  endfunction  
  
endclass

class irq_reg extends uvm_reg;
  `uvm_object_utils(irq_reg)
  
  rand uvm_reg_field flags;
  
  function new (string name = "irq_reg");
    super.new(name , 32, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    flags = uvm_reg_field::type_id::create("flags");
    flags.configure(this, 32, 0, "W1C", 0, 32'h0, 1, 1, 1);
  endfunction 
  
endclass


// Register block containing all registers
class apb_reg_block extends uvm_reg_block;
  `uvm_object_utils(apb_reg_block)
  
  rand ctrl_reg   m_ctrl_reg;
  rand status_reg m_status_reg;
  rand data_reg   m_data_reg;
  rand irq_reg    m_irq_reg;
  
  function new (string name = "apb_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    this.default_map = create_map("", 8'h00, 8, UVM_LITTLE_ENDIAN, 0);
    this.m_ctrl_reg  = ctrl_reg::type_id::create("m_ctrl_reg", , get_full_name());
    this.m_status_reg  = status_reg::type_id::create("m_status_reg", , get_full_name());
    this.m_data_reg  = data_reg::type_id::create("m_data_reg", , get_full_name());
    this.m_irq_reg  = irq_reg::type_id::create("m_irq_reg", , get_full_name());
    
    this.m_ctrl_reg.configure(this, null, "");
    this.m_status_reg.configure(this, null, "");
    this.m_data_reg.configure(this, null, "");
    this.m_irq_reg.configure(this, null, "");
    
    this.m_ctrl_reg.build();
    this.m_status_reg.build();
    this.m_data_reg.build();
    this.m_irq_reg.build();
    
    this.default_map.add_reg( this.m_ctrl_reg, `UVM_REG_ADDR_WIDTH'h00, "RW", 0);
    this.default_map.add_reg( this.m_status_reg, `UVM_REG_ADDR_WIDTH'h04, "RO", 0);
    this.default_map.add_reg( this.m_data_reg, `UVM_REG_ADDR_WIDTH'h08, "RW", 0);
    this.default_map.add_reg( this.m_irq_reg, `UVM_REG_ADDR_WIDTH'h0c, "W1C", 0);
    lock_model();
  endfunction  
  
endclass


`endif
