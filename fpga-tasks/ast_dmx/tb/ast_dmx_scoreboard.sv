class ast_dmx_scoreboard #(
  type T,

  parameter int DATA_WIDTH    = 64,
  parameter int CHANNEL_WIDTH = 8,
  parameter int EMPTY_WIDTH    = $clog2( DATA_WIDTH / 8 ),
  parameter int TX_DIR        = 4,
  parameter int DIR_SEL_WIDTH = TX_DIR == 1 ? 1 : $clog2( TX_DIR )
);
  local mailbox #( T ) drv2scb;
  local mailbox #( T ) mon2scb;

  local T tr_drv;
  local T tr_mon;

  local int counter_packets_mon = 0;
  local int counter_packets_drv = 0;

  function new( mailbox #( T ) drv2scb,
                mailbox #( T ) mon2scb);

    this.drv2scb = drv2scb;
    this.mon2scb = mon2scb;
  endfunction

  task check_remaining_packets();
    $display("driver sent %d packets", counter_packets_drv + this.drv2scb.num());
    $display("monitor received %d packets", counter_packets_mon + this.mon2scb.num());
    if( counter_packets_mon + this.mon2scb.num() != counter_packets_drv + this.drv2scb.num() )
      begin
        $display("PROBLEMS WITH PACKETS!");
        // etc
      end
    else
      begin
        $display("ALL PACKETS RECEIVED");
      end
  endtask

  task run();
    logic [7:0] last_byte_mon;
    logic [7:0] last_byte_drv;

    while(1)
      begin
        this.drv2scb.get(tr_drv);
        counter_packets_drv = counter_packets_drv + 1;
        this.mon2scb.get(tr_mon);
        counter_packets_mon = counter_packets_mon + 1;

        if (tr_drv.get_dir() != tr_mon.get_dir())
          begin
            `SHOW_WRONG_SIGNALS(tr_drv.get_dir(),
                                tr_mon.get_dir(),
                                "SCOREBOARD: DIFFERENT DIR");
            // $stop();
          end

        if( tr_drv.get_channel() != tr_mon.get_channel() )
          begin
            `SHOW_WRONG_SIGNALS(tr_drv.get_channel(),
                                tr_mon.get_channel(),
                                "SCOREBOARD: DIFFERENT CHANNEL");
            // $stop();
          end

        if( tr_drv.get_size_of_packet() != tr_mon.get_size_of_packet() )
          begin
            `SHOW_WRONG_SIGNALS(tr_drv.get_size_of_packet(),
                                tr_mon.get_size_of_packet(),
                                "SCOREBOARD: DIFFERENT BETWEEN PACKET SIZE");
            // $stop();
          end

        while(tr_drv.get_size_of_packet() > 0)
          begin
            last_byte_mon = tr_mon.get_next_byte();
            last_byte_drv = tr_drv.get_next_byte();


            if(last_byte_mon !== last_byte_drv)
              `SHOW_WRONG_SIGNALS(last_byte_drv,
                                  last_byte_mon,
                                  "SCOREBOARD: DIFFERENT BETWEEN DATA VALUE");
          end

      end
  endtask

endclass