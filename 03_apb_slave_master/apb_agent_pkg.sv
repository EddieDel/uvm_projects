`ifndef APB_AGENT_PKG_SV
 `define APB_AGENT_PKG_SV

`include "uvm_macros.svh"
`include "apb_pkg.sv"
`include "apb_if.sv"

package apb_agent_pkg;
 import uvm_pkg::*;
 import apb_pkg::*;
  
 `include "apb_tx.sv";
 `include "apb_master_monitor.sv"; 
 `include "apb_agent.sv";

endpackage
 

`endif
