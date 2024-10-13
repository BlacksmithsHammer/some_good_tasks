class amm_byte_inc_driver #(
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  typedef struct {
    int                    target_timestamp;
    logic [DATA_WIDTH-1:0] data;
  } read_msg;

  local virtual byte_inc_set_if settings_if;
  local virtual amm_if          reader_if;
  local virtual amm_if          writer_if;

  local mailbox #( T ) gen2drv;
  local mailbox #( T ) drv2scb;
  local mailbox #( T ) drv2mon;

  local mailbox #( T ) set2reader;
  local mailbox #( T ) set2writer;

  function new(
      virtual byte_inc_set_if #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .BYTE_CNT   ( BYTE_CNT   )
      ) settings_if,

      virtual amm_if #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .BYTE_CNT   ( BYTE_CNT   )
      ) reader_if,

      virtual amm_if #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .BYTE_CNT   ( BYTE_CNT   )
      ) writer_if,

      mailbox #( T ) gen2drv,
      mailbox #( T ) drv2mon,
      mailbox #( T ) drv2scb);

    this.settings_if = settings_if;
    this.reader_if   = reader_if;
    this.writer_if   = writer_if;

    this.gen2drv = gen2drv;
    this.drv2mon = drv2mon;
    this.drv2scb = drv2scb;
  endfunction

  function read_msg generate_new_msg( T tr, 
                                      int absolute_timestamp, 
                                      logic [ADDR_WIDTH-1:0] address);
    read_msg tmp_msg;
    tmp_msg.target_timestamp = tr.get_latency_of_read() + absolute_timestamp;
    
    for( int i = 0; i < DATA_WIDTH; i = i + 8)
      tmp_msg.data[i +: 8] = tr.get_byte(this.reader_if.address + i / 8);

    return tmp_msg;
  endfunction

  function void clear_settings();
    this.settings_if.base_addr <= 'x;
    this.settings_if.length    <= 'x;
    this.settings_if.run       <= 1'b0;
  endfunction

  function void clear_reader();
    this.reader_if.waitrequest <= 1'b0;
    this.reader_if.data        <=  'x;
    this.reader_if.datavalid   <= 1'b0;
  endfunction 

  function void send_settings(T tr);
    this.settings_if.base_addr <= tr.get_base_addr();
    this.settings_if.length    <= tr.get_length_add();
    this.settings_if.run       <= 1'b1;
  endfunction

  function void stop_writer();
    this.writer_if.waitrequest <= 1'b1;
  endfunction

  function void start_writer();
    this.writer_if.waitrequest <= 1'b0;
  endfunction

  task reset();
    this.settings_if.srst <= 1'b1;
    @( this.settings_if.cb );
    this.settings_if.srst <= 1'b0;
  endtask

  task settings_daemon();
    this.set2reader = new();
    this.set2writer = new();
    while(this.gen2drv.num() > 0)
      begin
        T tr;

        while( this.settings_if.waitrequest )
          begin
            @( this.settings_if.cb );

            // ДОБАВИТЬ СБРОС ЕСЛИ ТЕСТ ДОЛГО ВИСИТ
            if( this. )
          end

        this.gen2drv.get(tr);
        this.set2reader.put(tr);
        this.set2writer.put(tr);

        send_settings(tr);
        @( this.settings_if.cb );
        clear_settings();
      end
  endtask

  task reader_daemon();
    T tr;
    read_msg read_msg_queue[$];
    clear_reader();
    @( this.reader_if.cb );
    // get next transaction from mailbox
    while( 1 )
      begin
        // timestamp for calculating the difference in the delay in sending a packet
        // in cycles, not $time
        int absolute_timestamp = 0;
        logic [ADDR_WIDTH-1:0] prev_addr;
        logic                  prev_read;

        this.set2reader.get(tr);
        // work with transaction
        while( 1 )
          begin
            ////////////////////////////////////////////////////////////
            if( absolute_timestamp > 20 ) $stop();
            ////////////////////////////////////////////////////////////
            
            // read requests
            if( $urandom_range(99, 0) < tr.get_chance_of_read() )
              this.reader_if.waitrequest <= 1'b0;
            else
              this.reader_if.waitrequest <= 1'b1;

            if( prev_read === 1 && this.reader_if.waitrequest === 0 && absolute_timestamp > 0)
              begin
                //$display("Waitrequest: %0d, prev_addr: %0d, prev_read: %0d, time: %0d", this.reader_if.waitrequest, prev_addr, prev_read, $time);

                $display("add in queue: %0d", $time);
                if( $isunknown(prev_addr) )
                  begin
                    `SHOW_PROBLEM("Driver: problem with signal", "got x in address of reader");
                  end
                else
                  begin
                    read_msg tmp_msg;

                    tmp_msg.target_timestamp = tr.get_latency_of_read() + absolute_timestamp;
                    for( int i = 0; i < DATA_WIDTH; i = i + 8)
                      tmp_msg.data[i +: 8] = tr.get_byte(prev_addr + i / 8);
                    
                    read_msg_queue.push_back(tmp_msg);
                  end
              end
            // end read requests

            // send response
            if( read_msg_queue.size() > 0 && read_msg_queue[0].target_timestamp == absolute_timestamp + 1 )
              begin
                read_msg tmp_msg = read_msg_queue.pop_front();
                this.reader_if.data      <= tmp_msg.data;
                this.reader_if.datavalid <= 1'b1;
                $display("Send response: %0d", $time);
              end
            else
               begin
                 this.reader_if.data      <=  'x;
                 this.reader_if.datavalid <= 1'b0;
               end
            // end of send response



            if( absolute_timestamp > 0 && this.settings_if.waitrequest === 0 )
              break;
            prev_read = this.reader_if.read;
            prev_addr = this.reader_if.address;

            @( this.reader_if.cb );
            absolute_timestamp++;
          end
        
        // this.settings_if.srst <= 1'b1;
        // @( this.settings_if.cb );
        // this.settings_if.srst <= 1'b0;

  
      end
  endtask
  
  task writer_daemon();
    T tr;
    start_writer();
    this.set2writer.get(tr);

    while( 1 )
      begin
        if( set2writer.num() > 0)
          set2writer.get(tr); // try_get cause warning

        if( $urandom_range(99, 0) < tr.get_chance_of_write() )
          start_writer();
        else
          stop_writer();

        @( this.writer_if.cb );
      end
  endtask

  task run();
    reset();
    fork
      // may be rename in *thread*?
      settings_daemon();
      reader_daemon();
      writer_daemon();
    join_none
    
    // waiting
    #10000;
  endtask 

endclass
