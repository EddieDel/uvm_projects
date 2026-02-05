# Counter with Reset - UVM Verification Project

## Description
Complete UVM testbench for a 4-bit counter with synchronous reset and enable control.

### 0. EDA Playground
1. Open: https://edaplayground.com/x/YwFD
2. Click "Run"

---

## 1. DESIGN SPECIFICATION

### 1.1 Design Overview
The DUT is a 4-bit counter with:
- **Clock:** System clock input
- **Reset:** Active-low synchronous reset (reset_n)
- **Enable:** Counter enable signal
- **Count:** 4-bit output (0-15)

### 1.2 Functional Behavior
| Condition | Behavior |
|-----------|----------|
| `reset_n = 0` | Count resets to 0 (synchronous) |
| `enable = 1 && reset_n = 1` | Count increments on clock edge |
| `enable = 0 && reset_n = 1` | Count holds current value |
| `count = 15 && enable = 1` | Overflow: wraps to 0 |

---

## 2. VERIFICATION APPROACH

### 2.1 Methodology
- **Framework:** UVM (Universal Verification Methodology)
- **Coverage-Driven:** Functional coverage with transition bins
- **Assertion-Based:** SVA for protocol and correctness checking
- **Constrained Random:** Primary stimulus generation
- **Directed Tests:** Corner case scenarios


```
```

### 2.1 Key Features
- **Reset-Aware Architecture:** All components implement `reset_handler` interface
- **Clocking Block:** Monitor uses clocking block with `#1step` input skew
- **Reactive Sequences:** Sequences can read DUT state for adaptive stimulus
- **Process Management:** Clean process kill/restart on reset


## 3. TEST SCENARIOS

### 3.1 Basic Functional Tests
| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| TC-001 | Random Transactions | 30 randomized transactions | General coverage |
| TC-002 | Single Transaction | Single enable pulse | Basic sanity |

### 3.2 Overflow Tests
| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| TC-101 | Full Overflow | 16+ enabled cycles (0→15→0) | Overflow transition |
| TC-102 | Multiple Overflows | Count through multiple wrap-arounds | Overflow robustness |

### 3.3 Reset Tests
| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| TC-201 | Reset at Max | Reach count=15, then assert reset | Reset from max value |
| TC-202 | Short Reset | Reset for 1 clock cycle | Minimum reset duration |
| TC-203 | Long Reset | Reset for 10+ clock cycles | Extended reset |
| TC-204 | Mid-Operation Reset | Assert reset while counting | Reset recovery |

### 3.4 Enable Tests
| Test ID | Test Name | Description | Coverage Goal |
|---------|-----------|-------------|---------------|
| TC-301 | Enable Toggle | Toggle enable every cycle | Enable transitions |
| TC-302 | Enable Pulse | Single-cycle enable pulses | Pulse detection |
| TC-303 | Continuous Enable | Hold enable for extended period | Sustained counting |

### 3.5 Corner Cases
| Test ID | Test Name | Description | Expected Behavior |
|---------|-----------|-------------|-------------------|
| TC-401 | Simultaneous Edges | Reset deasserts same cycle enable asserts | Proper prioritization |
| TC-402 | Reset During Overflow | Assert reset when count=15 | Reset takes precedence |

---

## 4. COVERAGE PLAN

### 4.1 Value Coverage
| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
| `count` | All counter values | 16 individual bins (0-15) | 100% |
| `enable` | Enable signal | 2 bins (0, 1) | 100% |
| `reset_n` | Reset signal | 2 bins (0, 1) | 100% |
| `max` | Maximum count | 1 bin (15) | 100% |
| `min` | Minimum count | 1 bin (0) | 100% |

### 4.2 Transition Coverage
| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
| `consecutive` | Sequential increments | 15 bins (0→1, 1→2, ... 14→15) | 100% |
| `zero_to_non_zero` | Count leaving zero | 1 bin (0→[1:15]) | 100% |
| `overflow` | Wrap-around | 1 bin (15→0) | 100% |
| `enable_disable` | Enable transitions | 4 bins (rise, fall, pulse, hold_high) | 100% |

### 4.3 Cross Coverage
| Cross | Description | Goal |
|-------|-------------|------|
| `en_x_count` | Enable × Count combinations | 80% |
| `rs_x_count` | Reset × Count combinations | 80% |

### 4.4 Illegal Bins
| Illegal Bin | Description | Purpose |
|-------------|-------------|---------|
| `wrap_without_overflow` | Transition 15→[1:14] | Catch skipped states |

---

## 5. ASSERTIONS

### 5.1 Reset Assertions
| Assertion ID | Property | Disable Condition |
|--------------|----------|-------------------|
| p_reset_behavior | Count = 0 one cycle after reset asserts | None (checks reset) |

### 5.2 Increment Assertions
| Assertion ID | Property | Disable Condition |
|--------------|----------|-------------------|
| p_enable_reset_count | Count increments when enable=1, reset_n=1, count<15 | `disable iff (!reset_n)` |
| p_overflow_wrap | Count wraps 15→0 when enabled | `disable iff (!reset_n)` |

### 5.3 Stability Assertions
| Assertion ID | Property | Disable Condition |
|--------------|----------|-------------------|
| p_stable_count | Count stable when enable=0 | `disable iff (!reset_n)` |
| p_count_unknown | Count never X when enabled | `disable iff (!reset_n)` |

---
