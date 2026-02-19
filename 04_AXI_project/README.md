# AXI4 Master VIP 

Complete UVM testbench for an AXI4 slave with Register Abstraction Layer (RAL) integration and multiple agents.

### EDA Playground
1. Open: https://edaplayground.com/x/dPxT
2. Click "Run"


---

## Coverage Plan
## Write address

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`awlen`|length variations|1,2,4,8,16,32,64,128,256 bytes|all power of 2| or maybe only min,max lengths
|`awsize`|transfer size|1,2,4,8,16,32,64,128,256 bytes|100%||
|`awburst`|burst variation|00,01,10|100%||
|`awvalid`|valid transfer|0,1|100%||
|`awready`|ready transfer|0,1|100%||
|`awid`|id|0,1|100%|

# Write Data
| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`wvalid`|valid|0,1|100%|
|`wvready`|ready|0,1|100%|
|`wstrb`|strobe variations|0,1|hit multiple| ( dont know how to model this one yet)


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


## Read address

| Coverpoint | Description | Bins | Goal |
|------------|-------------|------|------|
|`rresp`|response per transfer|00,01,10,11|100%|
|`rlast`|last transfer in burst |0,1|100%|



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










