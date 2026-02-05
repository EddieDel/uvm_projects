`ifndef ENV_PKG_SV
`define ENV_PKG_SV

`include "uvm_macros.svh"
`include "aad_pkg.sv"

package env_pkg;
 import uvm_pkg::*;
 import aad_pkg::*;

 `include "mux_env.sv";
 
endpackage
 

`endif
