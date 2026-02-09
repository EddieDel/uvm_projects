// ============================================================================
// APB Slave DUT - Register Block
// ============================================================================
// 4 registers with different access types:
//   0x00: CTRL_REG   - RW  - Control register
//   0x04: STATUS_REG - RO  - Status register (hardwired + dynamic bits)
//   0x08: DATA_REG   - RW  - General purpose data register
//   0x0C: IRQ_REG    - W1C - Interrupt register (write-1-to-clear)
// ============================================================================

module apb_slave_dut #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    // Clock and Reset
    input  logic                    pclk,
    input  logic                    preset_n,

    // APB Interface
    input  logic                    psel,
    input  logic                    penable,
    input  logic                    pwrite,
    input  logic [ADDR_WIDTH-1:0]   paddr,
    input  logic [DATA_WIDTH-1:0]   pwdata,
    output logic [DATA_WIDTH-1:0]   prdata,
    output logic                    pready,
    output logic                    pslverr
);

    // ========================================================================
    // Register Addresses
    // ========================================================================
    localparam CTRL_ADDR   = 8'h00;
    localparam STATUS_ADDR = 8'h04;
    localparam DATA_ADDR   = 8'h08;
    localparam IRQ_ADDR    = 8'h0C;

    // ========================================================================
    // Register Storage
    // ========================================================================
    logic [DATA_WIDTH-1:0] ctrl_reg;      // RW
    logic [DATA_WIDTH-1:0] status_reg;    // RO (bits set by hardware)
    logic [DATA_WIDTH-1:0] data_reg;      // RW
    logic [DATA_WIDTH-1:0] irq_reg;       // W1C

    // ========================================================================
    // APB State Machine
    // ========================================================================
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        ACCESS = 2'b10
    } apb_state_t;

    apb_state_t state, next_state;

    // State register
    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (psel && !penable)
                    next_state = SETUP;
            end
            SETUP: begin
                if (psel && penable)
                    next_state = ACCESS;
                else if (!psel)
                    next_state = IDLE;
            end
            ACCESS: begin
                if (pready)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // ========================================================================
    // Ready and Error Logic
    // ========================================================================
    assign pready = (state == ACCESS) || (state == SETUP && psel && penable);

    // Error on invalid address access
    logic addr_valid;
    assign addr_valid = (paddr == CTRL_ADDR) ||
                        (paddr == STATUS_ADDR) ||
                        (paddr == DATA_ADDR) ||
                        (paddr == IRQ_ADDR);

    assign pslverr = (state == ACCESS) && !addr_valid;

    // ========================================================================
    // Write Logic
    // ========================================================================
    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n) begin
            ctrl_reg <= 32'h0000_0000;
            data_reg <= 32'h0000_0000;
            irq_reg  <= 32'h0000_0000;
        end
        else if (psel && penable && pwrite && pready) begin
            case (paddr)
                CTRL_ADDR: ctrl_reg <= pwdata;
                DATA_ADDR: data_reg <= pwdata;
                IRQ_ADDR:  irq_reg  <= irq_reg & ~pwdata;  // W1C
                default: ;
            endcase
        end
    end

    // ========================================================================
    // Status Register - Hardware controlled bits
    // ========================================================================
    always_comb begin
        status_reg[7:0]   = ctrl_reg[7:0];           // Mirror control bits
        status_reg[8]     = |irq_reg;                // IRQ pending
        status_reg[15:9]  = 7'b0;                    // Reserved
        status_reg[31:16] = 16'hABCD;                // Hardwired ID
    end

    // ========================================================================
    // Read Logic
    // ========================================================================
    always_comb begin
        prdata = 32'h0;
        if (psel && penable && !pwrite) begin
            case (paddr)
                CTRL_ADDR:   prdata = ctrl_reg;
                STATUS_ADDR: prdata = status_reg;
                DATA_ADDR:   prdata = data_reg;
                IRQ_ADDR:    prdata = irq_reg;
                default:     prdata = 32'hDEAD_BEEF;
            endcase
        end
    end

endmodule

