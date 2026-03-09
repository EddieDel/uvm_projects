`ifndef AXI_COVERAGE_SV
`define AXI_COVERAGE_SV

`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class axi_coverage extends uvm_component;
  `uvm_component_utils(axi_coverage)
  
  // Analysis imports
  uvm_analysis_imp_wr#(axi_write_tx, axi_coverage) wr_item;
  uvm_analysis_imp_rd#(axi_read_tx, axi_coverage)  r_item;
  
  // Local variable for sampling wstrb queue elements
  logic [DATA_WIDTH/8 - 1:0] sampled_wstrb;
  
  //============================================================
  // WRITE COVERGROUP
  //============================================================
  covergroup write_cover_group with function sample(axi_write_tx t);
    option.per_instance = 1;
    
    cp_awlen: coverpoint t.awlen {
      bins len[] = {0,1,3,7,15,255};
    }
    
    cp_awsize: coverpoint t.awsize {
      bins size[] = {0,1,2};
    }
    
    cp_awburst: coverpoint t.awburst {
      bins burst[] = {FIXED, INCR, WRAP};
    }
    
    cp_awid: coverpoint t.awid {
      bins id[] = {[0:15]};
    }
    
    cp_awaddr: coverpoint t.awaddr[1:0] {
      bins aligned   = {2'b00};
      bins unaligned = {[1:3]};
    }
    
    cp_resp: coverpoint t.resp {
      bins resp[] = {OKAY, EXOKAY, SLVERR, DECERR};
    }
    
    cp_bid: coverpoint t.bid {
      bins id[] = {[0:15]};
    }
    
    cross_awburst_awsize: cross cp_awburst, cp_awsize;
    cross_awburst_awlen:  cross cp_awburst, cp_awlen;
    cross_awid_bid:       cross cp_awid, cp_bid;
    
  endgroup
  
  //============================================================
  // WSTRB COVERGROUP
  //============================================================
  covergroup wstrb_cover_group;
    option.per_instance = 1;
    
    cp_wstrb: coverpoint sampled_wstrb {
      bins all_bytes  = {4'b1111};
      bins byte_0     = {4'b0001};
      bins bytes_01   = {4'b0011};
      bins bytes_23   = {4'b1100};
      bins no_bytes   = {4'b0000};
      bins others     = default;
    }
  endgroup
  
  //============================================================
  // READ COVERGROUP
  //============================================================
  covergroup read_cover_group with function sample(axi_read_tx t);
    option.per_instance = 1;
    
    cp_arlen: coverpoint t.arlen {
      bins len[] = {0,1,3,7,15,31,63,127,255};
    }
    
    cp_arsize: coverpoint t.arsize {
      bins size[] = {0,1,2};
    }
    
    cp_arburst: coverpoint t.arburst {
      bins burst[] = {FIXED, INCR, WRAP};
    }
    
    cp_arid: coverpoint t.arid {
      bins id[] = {[0:15]};
    }
    
    cp_araddr: coverpoint t.araddr[1:0] {
      bins aligned   = {2'b00};
      bins unaligned = {[1:3]};
    }
    
    cp_rresp: coverpoint t.rresp {
      bins resp[] = {OKAY, EXOKAY, SLVERR, DECERR};
    }
    
    cp_rid: coverpoint t.rid {
      bins id[] = {[0:15]};
    }
    
    cross_arburst_arsize: cross cp_arburst, cp_arsize;
    cross_arburst_arlen:  cross cp_arburst, cp_arlen;
    cross_arid_rid:       cross cp_arid, cp_rid;
    
  endgroup

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    write_cover_group = new();
    read_cover_group  = new();
    wstrb_cover_group = new();
    wr_item = new("wr_item", this);
    r_item  = new("r_item", this);
  endfunction
  

  function void write_wr(axi_write_tx t);
    write_cover_group.sample(t);
    foreach(t.wstrb[i]) begin
      sampled_wstrb = t.wstrb[i];
      wstrb_cover_group.sample();
    end
  endfunction
  
  function void write_rd(axi_read_tx t);
    read_cover_group.sample(t);
  endfunction
  

  virtual function string coverage_results();
    string result;
    
    real awlen, awsize, awburst, awid, awaddr, resp, bid;
    real cross_burst_size_w, cross_burst_len_w, cross_id_w;
    real wstrb, write_total;
    
    real arlen, arsize, arburst, arid, araddr, rresp, rid;
    real cross_burst_size_r, cross_burst_len_r, cross_id_r;
    real read_total;
    
    awlen            = write_cover_group.cp_awlen.get_coverage();
    awsize           = write_cover_group.cp_awsize.get_coverage();
    awburst          = write_cover_group.cp_awburst.get_coverage();
    awid             = write_cover_group.cp_awid.get_coverage();
    awaddr           = write_cover_group.cp_awaddr.get_coverage();
    resp             = write_cover_group.cp_resp.get_coverage();
    bid              = write_cover_group.cp_bid.get_coverage();
    cross_burst_size_w = write_cover_group.cross_awburst_awsize.get_coverage();
    cross_burst_len_w  = write_cover_group.cross_awburst_awlen.get_coverage();
    cross_id_w         = write_cover_group.cross_awid_bid.get_coverage();
    wstrb            = wstrb_cover_group.cp_wstrb.get_coverage();
    write_total      = write_cover_group.get_inst_coverage();
    
    arlen            = read_cover_group.cp_arlen.get_coverage();
    arsize           = read_cover_group.cp_arsize.get_coverage();
    arburst          = read_cover_group.cp_arburst.get_coverage();
    arid             = read_cover_group.cp_arid.get_coverage();
    araddr           = read_cover_group.cp_araddr.get_coverage();
    rresp            = read_cover_group.cp_rresp.get_coverage();
    rid              = read_cover_group.cp_rid.get_coverage();
    cross_burst_size_r = read_cover_group.cross_arburst_arsize.get_coverage();
    cross_burst_len_r  = read_cover_group.cross_arburst_arlen.get_coverage();
    cross_id_r         = read_cover_group.cross_arid_rid.get_coverage();
    read_total       = read_cover_group.get_inst_coverage();
    
    result = $sformatf("\n==============================================\n");
    result = {result, $sformatf(" AXI Coverage Report for %s:\n", get_full_name())};
    result = {result, $sformatf("==============================================\n")};
    result = {result, $sformatf(" WRITE CHANNEL\n")};
    result = {result, $sformatf("----------------------------------------------\n")};
    result = {result, $sformatf(" Coverpoint 'awlen'            : %6.2f%%\n", awlen)};
    result = {result, $sformatf(" Coverpoint 'awsize'           : %6.2f%%\n", awsize)};
    result = {result, $sformatf(" Coverpoint 'awburst'          : %6.2f%%\n", awburst)};
    result = {result, $sformatf(" Coverpoint 'awid'             : %6.2f%%\n", awid)};
    result = {result, $sformatf(" Coverpoint 'awaddr align'     : %6.2f%%\n", awaddr)};
    result = {result, $sformatf(" Coverpoint 'wstrb'            : %6.2f%%\n", wstrb)};
    result = {result, $sformatf(" Coverpoint 'resp'             : %6.2f%%\n", resp)};
    result = {result, $sformatf(" Coverpoint 'bid'              : %6.2f%%\n", bid)};
    result = {result, $sformatf("----------------------------------------------\n")};
    result = {result, $sformatf(" Cross 'awburst x awsize'      : %6.2f%%\n", cross_burst_size_w)};
    result = {result, $sformatf(" Cross 'awburst x awlen'       : %6.2f%%\n", cross_burst_len_w)};
    result = {result, $sformatf(" Cross 'awid x bid'            : %6.2f%%\n", cross_id_w)};
    result = {result, $sformatf("----------------------------------------------\n")};
    result = {result, $sformatf(" WRITE TOTAL                   : %6.2f%%\n", write_total)};
    result = {result, $sformatf("==============================================\n")};
    result = {result, $sformatf(" READ CHANNEL\n")};
    result = {result, $sformatf("----------------------------------------------\n")};
    result = {result, $sformatf(" Coverpoint 'arlen'            : %6.2f%%\n", arlen)};
    result = {result, $sformatf(" Coverpoint 'arsize'           : %6.2f%%\n", arsize)};
    result = {result, $sformatf(" Coverpoint 'arburst'          : %6.2f%%\n", arburst)};
    result = {result, $sformatf(" Coverpoint 'arid'             : %6.2f%%\n", arid)};
    result = {result, $sformatf(" Coverpoint 'araddr align'     : %6.2f%%\n", araddr)};
    result = {result, $sformatf(" Coverpoint 'rresp'            : %6.2f%%\n", rresp)};
    result = {result, $sformatf(" Coverpoint 'rid'              : %6.2f%%\n", rid)};
    result = {result, $sformatf("----------------------------------------------\n")};
    result = {result, $sformatf(" Cross 'arburst x arsize'      : %6.2f%%\n", cross_burst_size_r)};
    result = {result, $sformatf(" Cross 'arburst x arlen'       : %6.2f%%\n", cross_burst_len_r)};
    result = {result, $sformatf(" Cross 'arid x rid'            : %6.2f%%\n", cross_id_r)};
    result = {result, $sformatf("----------------------------------------------\n")};
    result = {result, $sformatf(" READ TOTAL                    : %6.2f%%\n", read_total)};
    result = {result, $sformatf("==============================================\n")};
    result = {result, $sformatf(" OVERALL COVERAGE              : %6.2f%%\n", (write_total + read_total) / 2.0)};
    result = {result, $sformatf("==============================================\n")};
    
    return result;
  endfunction
  

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("AXI_COVERAGE", coverage_results(), UVM_LOW)
  endfunction
  
endclass
`endif
