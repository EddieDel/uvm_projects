`ifndef AXI_IF_SV
`define AXI_IF_SV

interface axi_if #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32,
  parameter ID_WIDTH   = 4
)(
  input logic aclk,
  input logic aresetn
);

  // Write Address Channel (AW)
  logic [ID_WIDTH-1:0]    awid;
  logic [ADDR_WIDTH-1:0]  awaddr;
  logic [7:0]             awlen;
  logic [2:0]             awsize;
  logic [1:0]             awburst;
  logic                   awvalid;
  logic                   awready;

  // Write Data Channel (W)
  logic [DATA_WIDTH-1:0]  wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                   wlast;
  logic                   wvalid;
  logic                   wready;

  // Write Response Channel (B)
  logic [ID_WIDTH-1:0]    bid;
  logic [1:0]             bresp;
  logic                   bvalid;
  logic                   bready;

  // Read Address Channel (AR)
  logic [ID_WIDTH-1:0]    arid;
  logic [ADDR_WIDTH-1:0]  araddr;
  logic [7:0]             arlen;
  logic [2:0]             arsize;
  logic [1:0]             arburst;
  logic                   arvalid;
  logic                   arready;

  // Read Data Channel (R)
  logic [ID_WIDTH-1:0]    rid;
  logic [DATA_WIDTH-1:0]  rdata;
  logic [1:0]             rresp;
  logic                   rlast;
  logic                   rvalid;
  logic                   rready;

  // Clocking blocks
  clocking cb_drv @(posedge aclk);
    default input #1step output #1;
    // AW
    output awid, awaddr, awlen, awsize, awburst, awvalid;
    input  awready;
    // W
    output wdata, wstrb, wlast, wvalid;
    input  wready;
    // B
    input  bid, bresp, bvalid;
    output bready;
    // AR
    output arid, araddr, arlen, arsize, arburst, arvalid;
    input  arready;
    // R
    input  rid, rdata, rresp, rlast, rvalid;
    output rready;
  endclocking

  clocking cb_mon @(posedge aclk);
    default input #1step;
    // AW
    input awid, awaddr, awlen, awsize, awburst, awvalid, awready;
    // W
    input wdata, wstrb, wlast, wvalid, wready;
    // B
    input bid, bresp, bvalid, bready;
    // AR
    input arid, araddr, arlen, arsize, arburst, arvalid, arready;
    // R
    input rid, rdata, rresp, rlast, rvalid, rready;
  endclocking

  modport driver  (clocking cb_drv, input aclk, aresetn);
  modport monitor (clocking cb_mon, input aclk, aresetn);

endinterface

`endif
