`ifndef AXI_IF_SV
`define AXI_IF_SV

interface axi_if #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32,
  parameter ID_WIDTH   = 4
)(
  input logic aclk
);

  // Reset
  logic                    aresetn;
  
  // Write Address Channel (AW)
  logic [ID_WIDTH-1:0]     awid;
  logic [ADDR_WIDTH-1:0]   awaddr;
  logic [7:0]              awlen;
  logic [2:0]              awsize;
  logic [1:0]              awburst;
  logic                    awvalid;
  logic                    awready;
  
  // Write Data Channel (W)
  logic [DATA_WIDTH-1:0]   wdata;
  logic [DATA_WIDTH/8-1:0] wstrb;
  logic                    wlast;
  logic                    wvalid;
  logic                    wready;
  
  // Write Response Channel (B)
  logic [ID_WIDTH-1:0]     bid;
  logic [1:0]              bresp;
  logic                    bvalid;
  logic                    bready;
  
  // Read Address Channel (AR)
  logic [ID_WIDTH-1:0]     arid;
  logic [ADDR_WIDTH-1:0]   araddr;
  logic [7:0]              arlen;
  logic [2:0]              arsize;
  logic [1:0]              arburst;
  logic                    arvalid;
  logic                    arready;
  
  // Read Data Channel (R)
  logic [ID_WIDTH-1:0]     rid;
  logic [DATA_WIDTH-1:0]   rdata;
  logic [1:0]              rresp;
  logic                    rlast;
  logic                    rvalid;
  logic                    rready;

  // Clocking blocks
  clocking cb_drv @(posedge aclk);
    default input #1step output #1;
    output awid, awaddr, awlen, awsize, awburst, awvalid;
    input  awready;
    output wdata, wstrb, wlast, wvalid;
    input  wready;
    input  bid, bresp, bvalid;
    output bready;
    output arid, araddr, arlen, arsize, arburst, arvalid;
    input  arready;
    input  rid, rdata, rresp, rlast, rvalid;
    output rready;
  endclocking

  clocking cb_mon @(posedge aclk);
    default input #1step;
    input awid, awaddr, awlen, awsize, awburst, awvalid, awready;
    input wdata, wstrb, wlast, wvalid, wready;
    input bid, bresp, bvalid, bready;
    input arid, araddr, arlen, arsize, arburst, arvalid, arready;
    input rid, rdata, rresp, rlast, rvalid, rready;
  endclocking

  modport driver  (clocking cb_drv, input aclk, aresetn);
  modport monitor (clocking cb_mon, input aclk, aresetn);

  //==========================================================================
  // ASSERTIONS
  //==========================================================================
  
  // Write burst tracking
  logic [7:0] aw_len_q;
  int unsigned wbeat_cnt;
  
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      aw_len_q  <= '0;
      wbeat_cnt <= 0;
    end else begin
      if (awvalid && awready) aw_len_q <= awlen;
      if (wvalid && wready)   wbeat_cnt <= wlast ? 0 : wbeat_cnt + 1;
    end
  end

  // 1. VALID stability
  property p_valid_stable(valid, ready);
    @(posedge aclk) disable iff (!aresetn)
    (valid && !ready) |=> valid;
  endproperty
  
  assert_awvalid_stable: assert property (p_valid_stable(awvalid, awready));
  assert_wvalid_stable:  assert property (p_valid_stable(wvalid, wready));

  // 2. Signal stability
  property p_aw_stable;
    @(posedge aclk) disable iff (!aresetn)
    (awvalid && !awready) |=> ($stable(awaddr) && $stable(awlen));
  endproperty
  
  property p_w_stable;
    @(posedge aclk) disable iff (!aresetn)
    (wvalid && !wready) |=> ($stable(wdata) && $stable(wstrb) && $stable(wlast));
  endproperty
  
  assert_aw_stable: assert property (p_aw_stable);
  assert_w_stable:  assert property (p_w_stable);

  // 3. WLAST correctness
  property p_wlast_correct;
    @(posedge aclk) disable iff (!aresetn)
    (wvalid && wready && wlast) |-> (wbeat_cnt == aw_len_q);
  endproperty
  
  assert_wlast_correct: assert property (p_wlast_correct);

endinterface

`endif


