class amm_byte_inc_monitor #(
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local mailbox #( T ) drv2mon;
  local mailbox #( T ) mon2scb;

  typedef struct packed {
    logic [DATA_WIDTH-1:0] data;
    logic [ADDR_WIDTH-1:0] address;
    logic [BYTE_CNT-1  :0] byteenable;
  } st_request_write;

  local virtual byte_inc_set_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) settings_if;

  local virtual amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) reader_if;

  local virtual amm_if #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .BYTE_CNT   ( BYTE_CNT   )
  ) writer_if;

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

    mailbox #( T ) drv2mon,  
    mailbox #( T ) mon2scb);

    this.settings_if = settings_if;
    this.reader_if   = reader_if;
    this.writer_if   = writer_if;

    this.drv2mon     = drv2mon;
    this.mon2scb     = mon2scb;
  endfunction

  task run();
    T tr;
    st_request_write write_requests [$];

    logic [DATA_WIDTH-1:0] prev_data;
    logic [ADDR_WIDTH-1:0] prev_address;
    logic [BYTE_CNT-1  :0] prev_byteenable;
    logic                  prev_write;

    while( 1 )
      begin
        if( this.writer_if.waitrequest === 0 && prev_write === 1 )
          begin
            st_request_write tmp_req;

            tmp_req.data       = prev_data;
            tmp_req.address    = prev_address;
            tmp_req.byteenable = prev_byteenable;

            write_requests.push_back(tmp_req);
          end

        if( drv2mon.try_get(tr) )
          begin
            st_request_write tmp_req;

            while( write_requests.size() > 0)
              begin
                tmp_req = write_requests.pop_front();
                for( int i = 0; i < BYTE_CNT; i++ )
                  if( tmp_req.byteenable[i] === 1 )
                    tr.set_byte(tmp_req.address*8 + i, tmp_req.data[i*8 +: 8]);
              end
  
            mon2scb.put(tr);
          end
        
        prev_data       = this.writer_if.data;
        prev_address    = this.writer_if.address;
        prev_byteenable = this.writer_if.byteenable;
        prev_write      = this.writer_if.write;
        @( this.writer_if.cb );

      end
  endtask

endclass 
      
