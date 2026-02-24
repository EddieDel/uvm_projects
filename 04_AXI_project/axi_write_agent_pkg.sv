`ifndef AXI_WRITE_AGENT_PKG_SV
 `define AXI_WRITE_AGENT_PKG_SV

`include "axi_pkg.sv"
`include "axi_if.sv"
`include "uvm_macros.svh"

package axi_write_agent_pkg;
import axi_pkg::*;
import uvm_pkg::*;
`include "axi_write_tx.sv";
`include "axi_write_sequences.sv";
`include "axi_write_sequencer.sv";
`include "axi_write_driver.sv";
`include "axi_write_monitor.sv";
`include "axi_write_agent.sv";

endpackage

`endif
