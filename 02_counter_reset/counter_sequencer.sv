`ifndef COUNTER_SEQUENCER_SV
 `define COUNTER_SEQUENCER_SV

class counter_sequencer extends uvm_sequencer#(.REQ(seq_item_drv)) implements reset_handler;
  `uvm_component_utils(counter_sequencer);
  
  
  function new(string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
  
    /* Reset Logic of Sequencer.
    1) Stops all the sequences.
    2) Drop all the objections.
    3) Restart it  */
    virtual function void handle_reset(uvm_phase phase);
      int objections_count;
      stop_sequences();

      objections_count = uvm_test_done.get_objection_count(this);

      if(objections_count > 0) begin
        uvm_test_done.drop_objection(this, $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
      end

      start_phase_sequence(phase); 
    endfunction
    
  
endclass

`endif

