`include "axi_test_pkg.sv"

module testbench();
  import uvm_pkg::*;
  import axi_test_pkg::*;
  
  
  reg clk;
  
  //clock generator
  initial begin
    clk = 0;
    
    forever begin
      clk = #5 ~clk;
    end
  end
  

  
  //connect dut with tb
  axi_if axif(.aclk(clk));
  
  
  axi_slave_mem dut(.aclk(axif.aclk),
                    .aresetn(axif.aresetn),
                    .awid(axif.awid),
                    .awaddr(axif.awaddr),
                    .awlen(axif.awlen),
                    .awsize(axif.awsize),
                    .awburst(axif.awburst),
                    .awvalid(axif.awvalid),
                    .awready(axif.awready),
                    
                    .wdata(axif.wdata),
                    .wstrb(axif.wstrb),
                    .wlast(axif.wlast),
                    .wvalid(axif.wvalid),
                    .wready(axif.wready),
                    
                    .bid(axif.bid),
                    .bresp(axif.bresp),
                    .bvalid(axif.bvalid),
                    .bready(axif.bready),
                    
                    .arid(axif.arid),
                    .araddr(axif.araddr),
                    .arlen(axif.arlen),
                    .arsize(axif.arsize),
                    .arburst(axif.arburst),
                    .arvalid(axif.arvalid),
                    .arready(axif.arready),
                    
                    .rid(axif.rid),
                    .rdata(axif.rdata),
                    .rresp(axif.rresp),
                    .rlast(axif.rlast),
                    .rvalid(axif.rvalid),
                    .rready(axif.rready)
                   );
  
  //Initial reset
  initial begin
    axif.aresetn <= 0;
    #20ns;
    axif.aresetn <= 1; 
  end
  
  initial begin
    axif.arvalid = 0;
    axif.rready  = 0;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    // set interface in database
    uvm_config_db#(virtual axi_if)::set(null,"","vif",axif);
    run_test("");
  end
  
  
endmodule
