`ifndef APB_RAL_SEQUENCES_SV
 `define APB_RAL_SEQUENCES_SV

// ========================================================================
// Ral Write then Read Sequence.
// ========================================================================

class apb_ral_write_read_seq extends uvm_reg_sequence;
  `uvm_object_utils(apb_ral_write_read_seq)
  
  apb_reg_block reg_block;
  
  function new(string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t wdata, rdata;
    
    // Get reg_block from the model property (set by test)
    if (!$cast(reg_block, model)) begin
      `uvm_fatal("SEQ", "Failed to cast model to apb_reg_block")
    end
    
    wdata = 32'hCAFEBABE;
    reg_block.m_ctrl_reg.write(status, wdata);
    
    if (status != UVM_IS_OK)
      `uvm_error("SEQ", "Write failed!")
    
    reg_block.m_ctrl_reg.read(status, rdata);
    
    if (status != UVM_IS_OK)
      `uvm_error("SEQ", "Read failed!")
    
    // Compare
    if (rdata !== wdata)
      `uvm_error("SEQ", $sformatf("Mismatch! Wrote: 0x%0h, Read: 0x%0h", wdata, rdata))
    else
      `uvm_info("SEQ", $sformatf("Match! Data: 0x%0h", rdata), UVM_LOW)
  endtask
endclass
`endif      
      
