# AXI4 Master VIP (WiP)

Work in progress UVM testbench for an AXI4 slave, with Register Abstraction Layer (RAL) integration and multiple agents for write and read.

### EDA Playground
1. Open: https://edaplayground.com/x/dPxT
2. Click "Run"


---

## Coverage Plan
## Write address

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`awlen`|length variations|0,1,3,7,15,255|100| 
|`awsize`|transfer size|0,1,2|100%||
|`awburst`|burst variation|00,01,10|100%||
|`awvalid`|valid transfer|0,1|100%||
|`awready`|ready transfer|0,1|100%||
|`awid`|id|0:15|100%|

# Write Data
| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`wvalid`|valid|0,1|100%|
|`wvready`|ready|0,1|100%|
|`wstrb`|strobe variations|4'b1111,4'b0001,4'b0011,4'b1100,4'b0000|hit multiple| 


# Write Response 
| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`bresp`|response status|00,01,10,11|100%|
|`bvalid`|valid|0,1|100%|
|`bready`|ready|0,1|100%|


## Read address

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`arlen`|length variations|1,2,4,8,16,32,64,128,256 bytes|all power of 2|
|`arsize`|transfer size|1,2,4,8,16,32,64,128,256 bytes|100%|
|`arburst`|burst variation|00,01,10|100%|
|`arvalid`|valid transfer|0,1|100%|
|`arready`|ready transfer|0,1|100%|


## Read Data

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`rresp`|response per transfer|00,01,10,11|100%|
|`rlast`|last transfer in burst |0,1|100%|
|`rvalid`|valid transfer|0,1|100%|
|`rready`|ready transfer|0,1|100%|



## Cross Coverage

| Coverpoint | Description | Goal |
|------------|-------------|------|
|`awburst x awsize `|burst cross size| 100%|
|`awburst x awlen `|burst cross len| 100%|
|`arburst x arsize `|burst cross size| 100%|
|`arburst x arlen `|burst cross len| 100%|
|`awvalid x awready`|handshake|100%|
|`arvalid x arready`|handshake|100%|
|`wvalid x wready`|handshake|100%|













