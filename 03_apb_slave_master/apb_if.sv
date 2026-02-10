interface apb_if (input pclk);
  logic           preset_n;
  logic           psel;    
  logic           penable;
  logic           pwrite;
  logic  [7:0]    paddr;
  logic  [31:0]   pwdata;
  logic  [31:0]   prdata;
  logic           pready;
  logic           pslverr;
  
  
  
  clocking cb_drv @(posedge pclk);
    default input #1step output #1;
    input   preset_n;
    input   pready;
    input   pslverr;
    input   prdata;
    output  psel;
    output  penable;
    output  pwrite;
    output  paddr;
    output  pwdata;
   
  endclocking
  
  clocking cb_mon @(posedge pclk);
    default input #1step;
    input preset_n;
    input  psel;
    input  penable;
    input  pwrite;
    input  paddr;
    input  pwdata;
    input  prdata;
    input  pready;
    input  pslverr;
  endclocking

  //ASSERTIONS LATER

endinterface
  
