# APB Master VIP - UVM Verification Project with RAL

Complete UVM testbench for an APB slave with Register Abstraction Layer (RAL) integration.


## Quick Start

### EDA Playground
1. Open: https://edaplayground.com/x/r9sU
2. Click "Run"

---

## Design Specification

### Design Overview
The DUT is an APB slave with the following interface:

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `pclk` | 1 | Input | APB clock |
| `preset_n` | 1 | Input | Active-low asynchronous reset |
| `psel` | 1 | Input | Slave select signal |
| `penable` | 1 | Input | Access phase indicator |
| `pwrite` | 1 | Input | Write/Read control |
| `paddr` | 8 | Input | Address bus |
| `pwdata` | 32 | Input | Write data bus |
| `prdata` | 32 | Output | Read data bus |

### Register Map

| Address | Register | Access | Reset Value | Description |
|---------|----------|--------|-------------|-------------|
| `0x00` | CTRL_REG | RW | `0x00000000` | Control register |
| `0x04` | STATUS_REG | RO | `0xABCD0000` | Status with HW_ID |
| `0x08` | DATA_REG | RW | `0x00000000` | Data register |
| `0x0C` | IRQ_REG | W1C | `0x00000000` | Interrupt flags (Write-1-to-Clear) |

### Functional Behavior

| Condition | Phase/Operation | Description |
|-----------|-----------------|-------------|
| `psel=1, penable=0` | SETUP | Address and control signals stable |
| `psel=1, penable=1` | ACCESS | Data transfer occurs |
| `pwrite=1` | WRITE | Write operation |
| `pwrite=0` | READ | Read operation |
| `pready=1` | COMPLETE | Transfer complete |

---

## Verification Approach

### Methodology
- **Framework:** UVM (Universal Verification Methodology)
- **RAL Integration:** Register model with adapter and predictor
- **Coverage-Driven:** Address, direction, and cross coverage
- **Assertion-Based:** SVA for APB protocol compliance
- **Constrained Random:** Primary stimulus generation method

### Key Features
**RAL from Scratch** - Complete register model with adapter and predictor  
**Response Handling** - Driver returns responses via `item_done(item)` for RAL  
**Package Organization** - Separate `apb_reg_pkg` avoids circular dependencies  
**Protocol Assertions** - SVA with proper `$past()` timing for stability checks  

---

## Test Scenarios

### Basic Functional Tests

| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| **TC-001** | Random Transactions | 50 randomized read/write operations | General coverage |
| **TC-002** | Write Sequence | Single write operation | Write path verification |
| **TC-003** | Read Sequence | Single read operation | Read path verification |

### Data Integrity Tests

| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| **TC-101** | Write-Then-Read | Write data, read back, compare values | Data integrity |
| **TC-102** | RAL Write-Read | RAL-based write `0xCAFEBABE`, verify | RAL functionality |

### Error Handling Tests

| Test ID | Test Name | Description | Expected Behavior |
|---------|-----------|-------------|-------------------|
| **TC-201** | Invalid Address | Write to address `0xFF` | Scoreboard catches missing ERROR |
| **TC-202** | RO Register Write | Attempt write to STATUS_REG | Write ignored, value unchanged |



---

## Coverage Plan

### Address Coverage

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
| `addr` | Valid register addresses | 4 bins (`0x00`, `0x04`, `0x08`, `0x0C`) | 100% |
| `invalid_addr` | Invalid address access | 1 bin (`0xFF`) | Hit once |

### Direction Coverage

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
| `direction` | Transaction type | 2 bins (READ, WRITE) | 100% |

### Response Coverage

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
| `response` | Slave response type | 2 bins (OK, ERROR) | 100% |

### Cross Coverage

| Cross | Description | Goal |
|-------|-------------|------|
| `addr_x_direction` | Address × Direction combinations | 100% |
| `addr_x_response` | Address × Response combinations | 80% |

---

## Assertions

### Stability Assertions

| Assertion ID | Property | Description |
|--------------|----------|-------------|
| `paddr_stable` | Address stability | Address must remain stable during transaction |
| `pwdata_stable` | Write data stability | Write data must remain stable during transaction |

**Disable Condition:** `disable iff (!preset_n)` - All assertions disabled during reset

### Protocol Assertions

| Assertion ID | Property | Description |
|--------------|----------|-------------|
| `penable_after_psel` | Enable follows select | `penable` can only be asserted when `psel=1` |
| `psel_penable_timing` | SETUP→ACCESS timing | Proper two-phase APB protocol timing |

---

## RAL Implementation

### Register Model Architecture
```
apb_reg_block (uvm_reg_block)
├── ctrl_reg (uvm_reg) - RW
├── status_reg (uvm_reg) - RO
├── data_reg (uvm_reg) - RW
└── irq_reg (uvm_reg) - W1C
```

### RAL Adapter Methods

| Method | Direction | Description |
|--------|-----------|-------------|
| `reg2bus()` | RAL → APB | Converts `uvm_reg_bus_op` to `apb_tx` |
| `bus2reg()` | APB → RAL | Extracts response from `apb_tx` |






