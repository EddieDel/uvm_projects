`include "apb_test_pkg.sv"

module testbench ();

  import uvm_pkg::*;
  import apb_test_pkg::*;

  
  reg clk;
  
  // Clock generator
  
  initial begin
    clk = 0;
    
    forever begin
      clk = #5 ~clk;
    end
  end
  
  //connect dut with interface
   apb_if aif(.pclk(clk));
  
   apb_slave_dut  dut (.pclk(aif.pclk),
                   .preset_n (aif.preset_n),
                   .penable(aif.penable),
                   .pwrite(aif.pwrite),
                   .paddr(aif.paddr),
                   .pwdata(aif.pwdata),
                   .prdata(aif.prdata),
                   .pready(aif.pready),
                   .pslverr(aif.pslverr),
                   .psel(aif.psel)
                  );
  
  //Initial reset so values dont have x
  initial begin
    aif.preset_n <= 1;
    #10ns;
    aif.preset_n <= 0;
    #20ns;
    aif.preset_n <= 1;
  end
  
  
  //put interface in database
  initial begin
   $dumpfile("dump.vcd");
   $dumpvars;
    uvm_config_db#(virtual apb_if)::set(null,"","vif",aif);
   run_test("");
  end
  
endmodule


       
  


