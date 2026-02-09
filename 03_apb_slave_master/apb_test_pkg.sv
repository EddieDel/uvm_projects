`include "uvm_macros.svh"
`include "apb_env_pkg.sv"

package apb_test_pkg;
 import uvm_pkg::*;
 import apb_env_pkg::*;

 `include "apb_test_base.sv";
 `include "apb_tests.sv";

endpackage
