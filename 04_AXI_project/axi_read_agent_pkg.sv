`ifndef AXI_READ_AGENT_PKG_SV
 `define AXI_READ_AGENT_PKG_SV

`include "axi_pkg.sv"
`include "axi_if.sv"
`include "uvm_macros.svh"

package axi_read_agent_pkg;
import axi_pkg::*;
import uvm_pkg::*;

`include "axi_read_tx.sv";
`include "axi_read_sequences.sv";
`include "axi_read_sequencer.sv";
`include "axi_read_driver.sv";
`include "axi_read_monitor.sv";
`include "axi_read_agent.sv";
endpackage

`endif
