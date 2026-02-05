`ifndef MUX_TEST_PKG_SV
`define MUX_TEST_PKG_SV

`include "uvm_macros.svh"
`include "env_pkg.sv"


package mux_test_pkg;
 import uvm_pkg::*;
 import env_pkg::*;
 import aad_pkg::*;
 
 `include "mux_test_base.sv";
 `include "mux_test_cases.sv";

 
endpackage
 

`endif
