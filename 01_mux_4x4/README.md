# Mux 4x4 UVM Verification Project

## Description
Complete UVM testbench for 4x4 multiplexer verification.

eda link: https://edaplayground.com/x/gcCH

## 1. DESIGN SPECIFICATION

### 1.1 Design Overview
The DUT is a 4-to-1 multiplexer with:
- **Inputs:** 4 data inputs (in0, in1, in2, in3) - 8 bits each
- **Select:** 2-bit select signal (sel)
- **Output:** 8-bit output (out)
- **Protocol:** Ready-Valid handshake

### 2 Verification Approach
- **Methodology:** UVM (Universal Verification Methodology)
- **Coverage-Driven:** Functional and code coverage targets
- **Assertion-Based:** SVA for protocol and correctness checking
- **Constrained Random:** Primary stimulus generation
- **Directed Tests:** Corner case scenarios

- ## 3. TEST SCENARIOS

### 3.1 Basic Functional Tests
| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| TC-001 | All Zeros | All inputs = 0x00, cycle through all selects | Edge case |
| TC-002 | All Ones | All inputs = 0xFF, cycle through all selects | Edge case |
| TC-003 | Unique Values | Each input has unique value (0xAA, 0x55, 0xCC, 0x33) | Select verification |
| TC-004 | Walking Ones | 1-bit walking pattern on all inputs | Bit-level verification |

### 3.2 Protocol Tests
| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| TC-101 | Back-to-Back | Transactions with zero delay between them | Performance |
| TC-102 | Select Toggle | Rapid select line changes | Select stability |
| TC-103 | Same Input | All inputs same value, verify all selects work | Sanity |

### 3.3 Stress Tests
| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| TC-201 | Random Test | Fully randomized inputs and select (40 trans) | Coverage closure |
| TC-202 | Alternating Pattern | 0xAA/0x55 patterns | Pattern detection |

### 3.4 Negative Tests
| Test ID | Test Name | Description | Expected Behavior |
|---------|-----------|-------------|-------------------|
| TC-301 | Invalid Select | sel values 4-7 | Assertions should catch |
| TC-302 | X on inputs | Drive X values when valid=1 | Assertions should catch |

---

## 4. COVERAGE PLAN

### 4.1 Functional Coverage Goals

#### 4.1.1 Select Coverage
- **Bins:** Individual bins for sel = 0, 1, 2, 3


#### 4.1.2 Data Pattern Coverage
- **Coverpoints:**
  - Zero values (0x00)
  - Max values (0xFF)
  - Low range (0x01-0x7F)
  - High range (0x80-0xFE)


#### 4.1.3 Cross Coverage
- **Crosses:**
  - sel × in0_data (only when sel=0)
  - sel × in1_data (only when sel=1)
  - sel × in2_data (only when sel=2)
  - sel × in3_data (only when sel=3)


## 5. ASSERTIONS

### 5.1 Protocol Assertions
| Assertion ID | Property | Severity |
|--------------|----------|----------|
| AST-001 | Inputs stable when valid=1 | ERROR |
| AST-002 | Valid deasserts after handshake | ERROR |
| AST-003 | No X on output when valid=1 | ERROR |

### 5.2 Functional Assertions
| Assertion ID | Property | Severity |
|--------------|----------|----------|
| AST-101 | out == in0 when sel=00 && valid && ready | ERROR |
| AST-102 | out == in1 when sel=01 && valid && ready | ERROR |
| AST-103 | out == in2 when sel=10 && valid && ready | ERROR |
| AST-104 | out == in3 when sel=11 && valid && ready | ERROR |
| AST-105 | sel within valid range [0:3] | ERROR |

All assertions implemented in mux_if.sv
