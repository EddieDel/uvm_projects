`ifndef AGENT_PKG_SV
 `define AGENT_PKG_SV

`include "uvm_macros.svh"
`include "counter_if.sv"

package agent_pkg;
import uvm_pkg::*;

    typedef virtual counter_if counter_vif;
	`include "seq_item_drv.sv";
	`include "reset_handler.sv";
    `include "counter_sequences.sv";
    `include "agent_config.sv";
	`include "counter_sequencer.sv";
    `include "counter_driver.sv";
	`include "counter_monitor.sv";
    `include "counter_scoreboard.sv";
    `include "counter_coverage.sv";
    `include "counter_agent.sv";

endpackage

`endif
