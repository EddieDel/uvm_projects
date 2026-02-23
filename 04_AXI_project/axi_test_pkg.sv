`ifndef AXI_TEST_PKG_SV
 `define AXI_TEST_PKG_SV

`include "uvm_macros.svh"
`include "axi_if.sv"
`include "axi_env_pkg.sv"
`include "axi_write_agent_pkg.sv"

package axi_test_pkg;
import uvm_pkg::*;
import axi_env_pkg::*;
import axi_write_agent_pkg::*;

 `include "axi_test_base.sv";
 `include "axi_tests.sv";


endpackage
`endif
