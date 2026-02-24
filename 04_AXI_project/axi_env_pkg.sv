`ifndef AXI_ENV_PKG_SV
 `define AXI_ENV_PKG_SV

`include "uvm_macros.svh"
`include "axi_write_agent_pkg.sv"
`include "axi_read_agent_pkg.sv"

package axi_env_pkg;
import uvm_pkg::*;
import axi_write_agent_pkg::*;
import axi_read_agent_pkg::*;

`include "axi_env.sv";

endpackage

`endif
