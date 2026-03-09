`ifndef AXI_PKG_SV
 `define AXI_PKG_SV

`include "uvm_macros.svh"

package axi_pkg;
 import uvm_pkg::*;

localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 32;
localparam ID_WIDTH   = 4;
localparam MEM_DEPTH  = 32;
 
typedef enum logic [1:0] { FIXED = 2'b00, INCR = 2'b01, WRAP = 2'b10} burst_t;
typedef enum logic [1:0] { OKAY = 2'b00, EXOKAY = 2'b01, SLVERR = 2'b10, DECERR = 2'b11} response_t;




endpackage

`endif
