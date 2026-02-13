`ifndef APB_REG_ADAPTER_SV
 `define APB_REG_ADAPTER_SV


class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)
  
  function new(string name = "apb_reg_adapter");
    super.new(name);
    supports_byte_enable = 0;
    provides_responses   = 1;
  endfunction
  
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_tx tx;
    tx = apb_tx::type_id::create("tx");
    tx.direction = (rw.kind == UVM_WRITE) ? 1 : 0;
    tx.paddr  = rw.addr;
    tx.pwdata = rw.data;
    `uvm_info ("adapter", $sformatf ("reg2bus addr=0x%0h data=0x%0h kind=%s", tx.paddr, tx.pwdata, rw.kind.name), UVM_DEBUG)
    return tx;
  endfunction
  
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_tx tx;
    
    // Cast bus_item to apb_tx
    if (!$cast(tx, bus_item)) begin
      `uvm_fatal("bus2reg","Failed to cast bus_item to pkt")
    end
    rw.kind   = tx.direction ? UVM_WRITE : UVM_READ;
    rw.addr   = tx.paddr;
    rw.data   = tx.prdata;
    rw.status = tx.response ? UVM_NOT_OK : UVM_IS_OK;
  endfunction
  
  
endclass
`endif
