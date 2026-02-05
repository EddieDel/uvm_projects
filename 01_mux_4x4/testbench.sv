`include "mux_test_pkg.sv"

module testbench();
  
  import uvm_pkg::*;
  
  import mux_test_pkg::*;

  
  reg clk;
  
  initial begin
    clk = 0;
    
    forever begin
      clk= #5ns ~clk;
    end
  end
  
  mux_if mif(.clk(clk));
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    uvm_config_db#(virtual mux_if)::set(null,"uvm_test_top.env.agent","vif",mif);
    
    run_test("");
  end
  
  

  mux4 dut(
    .clk(clk),
    .ready(mif.ready),
    .valid(mif.valid),
    .in0(mif.in0),
    .in1(mif.in1),
    .in2(mif.in2),
    .in3(mif.in3),
    .sel(mif.sel),
    .out(mif.out)
  );
  
endmodule
