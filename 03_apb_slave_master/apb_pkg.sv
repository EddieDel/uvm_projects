`ifndef APB_PKG_SV
`define APB_PKG_SV

`include "uvm_macros.svh"


package apb_pkg;
 import uvm_pkg::*;
 localparam ADDR_WIDTH = 8;
 localparam DATA_WIDTH = 32;
 typedef enum logic [1:0] { IDLE = 2'b00, SETUP = 2'b01, ACCESS = 2'b10} apb_state_t;
 typedef enum logic  {READ = 1'b0, WRITE = 1'b1} apb_direction_e;
 typedef enum logic  {OK = 1'b0, ERROR = 1'b1} apb_response_e;
 
endpackage
 

`endif
