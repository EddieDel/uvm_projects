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


  // ===================================================================
  // ASSERTIONS FOR PROTOCOL CHECKING
  // ===================================================================
  
  //Psel stable during transaction
  property psel_stable;
    @(posedge pclk) disable iff (!preset_n) 
    (psel && !pready) |=> psel;
  endproperty
    
  // Penable must follow psel
  property penable_after_psel;
    @(posedge pclk) disable iff (!preset_n) 
    (psel && !penable) |=> penable;
  endproperty
  

  // Data stable during access phase
  property paddr_stable;
    @(posedge pclk) disable iff (!preset_n)
    ($past(psel) && psel && !pready) |-> $stable(paddr);
  endproperty

  property pwdata_stable;
    @(posedge pclk) disable iff (!preset_n)
    ($past(psel) && psel && !pready) |-> $stable(pwdata);
  endproperty
 
    
  // Penable only with psel
  property proper_penable;
    @(posedge pclk) disable iff (!preset_n)
    penable |-> psel;
  endproperty
  
  //Deassert penalbe after transfer
  property penable_deassert;
    @(posedge pclk) disable iff (!preset_n)
    (psel && penable && pready) |=> !penable;
  endproperty
  
  
  //Assertions instances
  assert_stable_psel: assert property (psel_stable)
    else $error ("ASSERTION FIRED : Psel didnt remain stable throughout transmission");
    
  assert_enable_after_se: assert property (penable_after_psel)
    else $error ("ASSERTION FIRED : Enable didnt rise after psel");
    
  assert_data_stable : assert property (pwdata_stable)
    else $error ("ASSERTION FIRED : Data didnt remain stable throughout transmission");
  
  assert_addr_stable: assert property (paddr_stable)
    else $error ("ASSERTION FIRED : Addr didnt remain stable throughout transmission");
  
  assert_penable_deassertion: assert property (penable_deassert)
    else $error ("ASSERTION FIRED : Enable didnt deassert while psel asserted");
 
  assert_proper_penalbe: assert property (proper_penable)
    else $error ("ASSERTION FIRED : Enable asserted without psel");
    
    
  //Coverage of assertions
   cover_psel_stable: cover property (psel_stable);
   cover_penable_after_psel: cover property (penable_after_psel);
   cover_data_stable: cover property (pwdata_stable);
   cover_addr_stable: cover property(paddr_stable);
   cover_penable_deassertion: cover property(penable_deassert);
   cover_proper_penable: cover property(proper_penable);
        

endinterface
  


