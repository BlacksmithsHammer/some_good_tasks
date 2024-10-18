class amm_byte_inc_generator #(
  type T,

  parameter int DATA_WIDTH = 64,
  parameter int ADDR_WIDTH = 10,
  parameter int BYTE_CNT   = DATA_WIDTH/8
);
  local mailbox #( T ) gen2drv;

  typedef enum {
    GEN_PATTERN_RANDOM,  // every data is random
    GEN_PATTERN_PLAIN,   // (8'd)gen_start, (8'd)gen_start+1, (8'd)gen_start+2...
    GEN_PATTERN_SAME     // (8'd)gen_start, (8'd)gen_start,   (8'd)gen_start...
  } gen_data_pattern;

  function new( input mailbox #( T ) gen2drv );
    this.gen2drv = gen2drv;
  endfunction

  // start_data_num - the data[0] byte for initialization other data by pattern
  task gen_by_pattern(gen_data_pattern _pattern,
                      int              base_addr,
                      int              length_add,
                      int              chance_of_read,
                      int              chance_of_write,
                      int              latency_of_read,
                      int              start_data_num);
    T tr;
    tr = new( base_addr, length_add, 
              chance_of_read, chance_of_write,
              latency_of_read);

    case( _pattern )
      GEN_PATTERN_SAME:
        begin
          for(int i = 0; i < 2**ADDR_WIDTH * BYTE_CNT; i++)
            tr.set_byte(i, start_data_num);
        end

      GEN_PATTERN_PLAIN:
        begin
          for(int i = 0; i < 2**ADDR_WIDTH * BYTE_CNT; i++)
            tr.set_byte(i, start_data_num + i);
        end

      GEN_PATTERN_RANDOM:
        begin
          for(int i = 0; i < 2**ADDR_WIDTH * BYTE_CNT; i++)
            tr.set_byte(i, $urandom_range(255, 0));
        end

      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG GENERATOR PATTERN");
        end
    endcase
    
    this.gen2drv.put(tr);
  endtask


  task generate_test( test_case _test );
    T tr;

    case( _test )
      MVP:
        begin

                    // gen_by_pattern( GEN_PATTERN_RANDOM, 
                    //       10, 10, 
                    //       100, 100,
                    //       1,
                    //       255);
          gen_by_pattern( GEN_PATTERN_RANDOM, 
                          10, 40, 
                          10, 10,
                          2,
                          255);

          gen_by_pattern( GEN_PATTERN_RANDOM, 
                          10, 10, 
                          100, 100,
                          1,
                          255);

          gen_by_pattern( GEN_PATTERN_RANDOM, 
                          10, 400, 
                          100, 100,
                          2,
                          255);
          gen_by_pattern( GEN_PATTERN_RANDOM, 
                          10, 40, 
                          100, 100,
                          2,
                          255);
        end

      default:
        begin
          `THROW_CRITICAL_ERROR("WRONG TEST CASE");
        end

    endcase
    // fix for work in fork-thread
    #100_000;

  endtask

endclass