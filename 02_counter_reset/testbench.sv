`include "test_pkg.sv"

module testbench();

  import uvm_pkg::*;
  import test_pkg::*;
  
  
  reg clk;
  
  initial begin
    clk = 0;
    
    forever begin
      clk = #5ns ~clk;
    end
  end
  
  
  counter_if cif(.clk(clk));
  counter dut(
    .clk(clk),
    .reset_n (cif.reset_n),
    .enable  (cif.enable),
    .count   (cif.count)
  );
  
  
  // Initial reset for test
  initial begin
    cif.reset_n <= 1;
    #10ns;
    cif.reset_n <= 0;
    #30ns;
    cif.reset_n <= 1;
  end 
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    //Set Interface
    uvm_config_db#(virtual counter_if)::set(null,"uvm_test_top.env.agent","vif",cif); //Incase it doesnt work change config with agent
    run_test("test_counter");
  end
  
  
endmodule
    
    
  
