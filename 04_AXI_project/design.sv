`ifndef AXI_SLAVE_MEM_SV
`define AXI_SLAVE_MEM_SV

module axi_slave_mem #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32,
  parameter ID_WIDTH   = 4,
  parameter MEM_DEPTH  = 256
)(
  input  logic                    aclk,
  input  logic                    aresetn,

  // Write Address Channel
  input  logic [ID_WIDTH-1:0]     awid,
  input  logic [ADDR_WIDTH-1:0]   awaddr,
  input  logic [7:0]              awlen,
  input  logic [2:0]              awsize,
  input  logic [1:0]              awburst,
  input  logic                    awvalid,
  output logic                    awready,

  // Write Data Channel
  input  logic [DATA_WIDTH-1:0]   wdata,
  input  logic [DATA_WIDTH/8-1:0] wstrb,
  input  logic                    wlast,
  input  logic                    wvalid,
  output logic                    wready,

  // Write Response Channel
  output logic [ID_WIDTH-1:0]     bid,
  output logic [1:0]              bresp,
  output logic                    bvalid,
  input  logic                    bready,

  // Read Address Channel
  input  logic [ID_WIDTH-1:0]     arid,
  input  logic [ADDR_WIDTH-1:0]   araddr,
  input  logic [7:0]              arlen,
  input  logic [2:0]              arsize,
  input  logic [1:0]              arburst,
  input  logic                    arvalid,
  output logic                    arready,

  // Read Data Channel
  output logic [ID_WIDTH-1:0]     rid,
  output logic [DATA_WIDTH-1:0]   rdata,
  output logic [1:0]              rresp,
  output logic                    rlast,
  output logic                    rvalid,
  input  logic                    rready
);

  // Memory storage
  logic [7:0] mem [0:MEM_DEPTH-1];

  // Internal state
  typedef enum logic [1:0] {
    W_IDLE, W_DATA, W_RESP
  } write_state_e;

  typedef enum logic [1:0] {
    R_IDLE, R_DATA
  } read_state_e;

  write_state_e w_state;
  read_state_e  r_state;

  // Write channel registers
  logic [ID_WIDTH-1:0]   aw_id_reg;
  logic [ADDR_WIDTH-1:0] aw_addr_reg;
  logic [7:0]            aw_len_reg;
  logic [2:0]            aw_size_reg;
  logic [1:0]            aw_burst_reg;
  logic [7:0]            w_beat_cnt;

  // Read channel registers
  logic [ID_WIDTH-1:0]   ar_id_reg;
  logic [ADDR_WIDTH-1:0] ar_addr_reg;
  logic [7:0]            ar_len_reg;
  logic [2:0]            ar_size_reg;
  logic [1:0]            ar_burst_reg;
  logic [7:0]            r_beat_cnt;

  // Address calculation
  function automatic logic [ADDR_WIDTH-1:0] next_burst_addr(
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [2:0]            size,
    input logic [1:0]            burst,
    input logic [7:0]            len
  );
    logic [ADDR_WIDTH-1:0] aligned_addr;
    logic [ADDR_WIDTH-1:0] wrap_boundary;
    integer num_bytes;

    num_bytes = 1 << size;

    case (burst)
      2'b00: return addr;                          // FIXED
      2'b01: return addr + num_bytes;              // INCR
      2'b10: begin                                 // WRAP
        wrap_boundary = ((len + 1) * num_bytes);
        aligned_addr  = addr + num_bytes;
        if ((aligned_addr % wrap_boundary) == 0)
          return aligned_addr - wrap_boundary;
        else
          return aligned_addr;
      end
      default: return addr + num_bytes;
    endcase
  endfunction

  // =====================
  // Write State Machine
  // =====================
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      w_state     <= W_IDLE;
      awready     <= 1'b1;
      wready      <= 1'b0;
      bvalid      <= 1'b0;
      bid         <= '0;
      bresp       <= 2'b00;
      aw_id_reg   <= '0;
      aw_addr_reg <= '0;
      aw_len_reg  <= '0;
      aw_size_reg <= '0;
      aw_burst_reg<= '0;
      w_beat_cnt  <= '0;
    end else begin
      case (w_state)
        W_IDLE: begin
          bvalid <= 1'b0;
          if (awvalid && awready) begin
            aw_id_reg    <= awid;
            aw_addr_reg  <= awaddr;
            aw_len_reg   <= awlen;
            aw_size_reg  <= awsize;
            aw_burst_reg <= awburst;
            w_beat_cnt   <= '0;
            awready      <= 1'b0;
            wready       <= 1'b1;
            w_state      <= W_DATA;
          end
        end

        W_DATA: begin
          if (wvalid && wready) begin
            // Write bytes based on wstrb
            for (int i = 0; i < DATA_WIDTH/8; i++) begin
              if (wstrb[i]) begin
                mem[aw_addr_reg[7:0] + i] <= wdata[i*8 +: 8];
              end
            end

            // Update address for next beat
            aw_addr_reg <= next_burst_addr(aw_addr_reg, aw_size_reg, aw_burst_reg, aw_len_reg);
            w_beat_cnt  <= w_beat_cnt + 1;

            if (wlast) begin
              wready  <= 1'b0;
              bvalid  <= 1'b1;
              bid     <= aw_id_reg;
              bresp   <= 2'b00; // OKAY
              w_state <= W_RESP;
            end
          end
        end

        W_RESP: begin
          if (bvalid && bready) begin
            bvalid  <= 1'b0;
            awready <= 1'b1;
            w_state <= W_IDLE;
          end
        end
      endcase
    end
  end

  // =====================
  // Read State Machine
  // =====================
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      r_state     <= R_IDLE;
      arready     <= 1'b1;
      rvalid      <= 1'b0;
      rid         <= '0;
      rdata       <= '0;
      rresp       <= 2'b00;
      rlast       <= 1'b0;
      ar_id_reg   <= '0;
      ar_addr_reg <= '0;
      ar_len_reg  <= '0;
      ar_size_reg <= '0;
      ar_burst_reg<= '0;
      r_beat_cnt  <= '0;
    end else begin
      case (r_state)
        R_IDLE: begin
          if (arvalid && arready) begin
            ar_id_reg    <= arid;
            ar_addr_reg  <= araddr;
            ar_len_reg   <= arlen;
            ar_size_reg  <= arsize;
            ar_burst_reg <= arburst;
            r_beat_cnt   <= '0;
            arready      <= 1'b0;
            rvalid       <= 1'b1;
            rid          <= arid;
            rresp        <= 2'b00; // OKAY

            // Read first beat
            for (int i = 0; i < DATA_WIDTH/8; i++) begin
              rdata[i*8 +: 8] <= mem[araddr[7:0] + i];
            end

            rlast <= (arlen == 0);
            r_state <= R_DATA;
          end
        end

        R_DATA: begin
          if (rvalid && rready) begin
            if (rlast) begin
              rvalid  <= 1'b0;
              rlast   <= 1'b0;
              arready <= 1'b1;
              r_state <= R_IDLE;
            end else begin
              r_beat_cnt  <= r_beat_cnt + 1;
              ar_addr_reg <= next_burst_addr(ar_addr_reg, ar_size_reg, ar_burst_reg, ar_len_reg);

              // Read next beat
              for (int i = 0; i < DATA_WIDTH/8; i++) begin
                rdata[i*8 +: 8] <= mem[next_burst_addr(ar_addr_reg, ar_size_reg, ar_burst_reg, ar_len_reg) + i];
              end

              rlast <= ((r_beat_cnt + 1) == ar_len_reg);
            end
          end
        end
      endcase
    end
  end

  // Initialize memory
  initial begin
    for (int i = 0; i < MEM_DEPTH; i++) begin
      mem[i] = '0;
    end
  end

endmodule

`endif
