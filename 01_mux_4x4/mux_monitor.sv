`ifndef MUX_MONITOR_SV
 `define MUX_MONITOR_SV

class mux_monitor extends uvm_monitor;
  `uvm_component_utils(mux_monitor)
  
  mux_agent_config agent_config;
  uvm_analysis_port#(mux_item_drv) output_port;
  
  function new (string name ="",uvm_component parent);
    super.new(name,parent);
    output_port = new("output_port",this);
  endfunction
  
   virtual task run_phase(uvm_phase phase);
    forever begin
      
      monitor_transactions();
    end
  endtask
  
  protected virtual task monitor_transactions();
    mux_vif vif = agent_config.get_vif();
    mux_item_drv item;
    
    forever @(posedge vif.clk) begin
      if (vif.ready && vif.valid) begin
       item = mux_item_drv::type_id::create("item"); 
       item.sel = vif.sel;
       item.in0 = vif.in0;
       item.in1 = vif.in1;
       item.in2 = vif.in2;
       item.in3 = vif.in3;
       item.out = vif.out;
       output_port.write(item);

      end
    @(posedge vif.clk);
    end
  endtask
  
  
  
endclass

`endif
