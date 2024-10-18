class amm_byte_inc_scoreboard #(
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local int total_tests  = 0;
  local int failed_tests = 0;

  local mailbox #( T ) drv2scb;
  local mailbox #( T ) mon2scb;

  local T tr_drv;
  local T tr_mon;

  function new( mailbox #( T ) drv2scb,
                mailbox #( T ) mon2scb);

    this.drv2scb = drv2scb;
    this.mon2scb = mon2scb;
  endfunction

  function void check_results();
    $display("====================================================");
    $display("Total tests sended: %0d", this.total_tests );
    $display("Failed tests: %0d",       this.failed_tests);
    $display("----------------------------------------------------");
    if( failed_tests > 0 )
      $display("Problems with tests");
    else
      $display("All tests passed");
    $display("====================================================");
    
  endfunction

  task reset();
    while (this.drv2scb.try_get(tr_drv)) begin end
    while (this.mon2scb.try_get(tr_mon)) begin end
  endtask

  task run();
    int left_ind;
    int right_ind;

    while( 1 )
      begin
        drv2scb.get(tr_drv);
        mon2scb.get(tr_mon);
        this.total_tests++;

        // check problems with control signals
        if( tr_drv.get_problem() != 0 )
          begin
            if( tr_drv.get_problem() == 1 )
              `SHOW_PROBLEM("Time-out", "Driver waiting waitrequest == 0 for a very long time");
              this.failed_tests++;
            continue;
          end

        // range of increment [left_ind...right_ind) (last index is not included)
        left_ind  = tr_drv.get_base_addr() * 8;
        right_ind = left_ind + tr_drv.get_length_add();

        for( int i = left_ind; ( i < right_ind ) && ( i < 2**ADDR_WIDTH * BYTE_CNT ); i++ )
          tr_drv.set_byte(i, tr_drv.get_byte(i) + 8'd1); // not necessary 8' but more better for view
        // check data after write
        for(int i = 0; i < 2**ADDR_WIDTH * BYTE_CNT; i++)
          if( tr_drv.get_byte(i) !== tr_mon.get_byte(i) )
            begin
              `SHOW_WRONG_SIGNALS($sformatf("%0h", tr_drv.get_byte(i)), 
                                  $sformatf("%0h", tr_mon.get_byte(i)), 
                                  $sformatf("Problem with word in address %0d", i / 8));
              this.failed_tests++;
              break;
            end
      end
  endtask

endclass