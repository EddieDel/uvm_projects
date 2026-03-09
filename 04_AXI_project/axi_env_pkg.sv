`ifndef AXI_ENV_PKG_SV
 `define AXI_ENV_PKG_SV
`define AXI_ENV_PKG_SV
`include "uvm_macros.svh"
`include "axi_pkg.sv"
`include "axi_write_agent_pkg.sv"
`include "axi_read_agent_pkg.sv"

package axi_env_pkg;
  import uvm_pkg::*;
  import axi_pkg::*;
  import axi_write_agent_pkg::*;
  import axi_read_agent_pkg::*;
  
  `include "axi_write_sequences.sv" 
  `include "axi_read_sequences.sv"
  `include "axi_virtual_sequencer.sv"
  `include "axi_virtual_sequences.sv"   
  `include "axi_scoreboard.sv"
  `include "axi_coverage.sv"
  `include "axi_env.sv"
endpackage

`endif

