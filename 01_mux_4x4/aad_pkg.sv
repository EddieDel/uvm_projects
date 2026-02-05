`ifndef AAD_PKG_SV
`define AAD_PKG_SV

`include "uvm_macros.svh"
`include "mux_if.sv"

package aad_pkg;
 import uvm_pkg::*;
  
  typedef virtual mux_if mux_vif;
 `include "mux_item_drv.sv";
 `include "mux_sequence.sv";
 `include "mux_invalid_sequence.sv";
 `include "mux_corner_sequences.sv";
 `include "mux_agent_config.sv";
 `include "mux_driver.sv"
 `include "mux_monitor.sv";
 `include "mux_coverage.sv";
 `include "mux_agent.sv";
 `include "mux_scoreboard.sv";

endpackage
 

`endif
