`ifndef APB_ENV_PKG_SV
 `define APB_ENV_PKG_SV

`include "uvm_macros.svh"
`include "apb_agent_pkg.sv"

package apb_env_pkg;
 import uvm_pkg::*;

 import apb_agent_pkg::*;
  
 `include "apb_environment.sv";

endpackage
 

`endif
