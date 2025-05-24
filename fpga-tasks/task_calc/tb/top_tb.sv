`timescale 1ns/1ns

import calc_pkg::*;

module top_tb ();

    bit clk;
    bit srst;

    initial
      forever 
        #5 clk = !clk;

    logic                tvalid_i;
    logic [A_DWIDTH-1:0] a;
    logic [B_DWIDTH-1:0] b;
    logic [C_DWIDTH-1:0] c;
    logic [D_DWIDTH-1:0] d;

    logic                tvalid_o;
    logic [Q_DWIDTH-1:0] q;

    calc #() calc_dut (
        .clk        (clk     ),
        .srst       (srst    ),

        .tvalid_i   (tvalid_i),
        .a_i        (a       ),
        .b_i        (b       ),
        .c_i        (c       ),
        .d_i        (d       ),

        .tvalid_o   (tvalid_o),
        .q_o        (q       )
    );

    task send_test_case(logic [A_DWIDTH-1:0] data_a,
                        logic [B_DWIDTH-1:0] data_b,
                        logic [C_DWIDTH-1:0] data_c,
                        logic [D_DWIDTH-1:0] data_d);
        tvalid_i <= 1;
        a        <= data_a;
        b        <= data_b;
        c        <= data_c;
        d        <= data_d;
        #10;
        tvalid_i <= 0;
    endtask

    initial begin
        // patterns for extra-case
        logic signed [A_DWIDTH-1:0] test_patterns_a [4] = '{
            2**(A_DWIDTH-1) - 1, 
            2**(A_DWIDTH-1) - 2, 
            -2**(A_DWIDTH-1),
            -2**(A_DWIDTH-1) + 1};

        logic signed [B_DWIDTH-1:0] test_patterns_b [4] = '{
            2**(B_DWIDTH-1) - 1, 
            2**(B_DWIDTH-1) - 2, 
            -2**(B_DWIDTH-1),
            -2**(B_DWIDTH-1) + 1};

        logic signed [C_DWIDTH-1:0] test_patterns_c [4] = '{
            2**(C_DWIDTH-1) - 1, 
            2**(C_DWIDTH-1) - 2, 
            -2**(C_DWIDTH-1),
            -2**(C_DWIDTH-1) + 1};

        logic signed [D_DWIDTH-1:0] test_patterns_d [4] = '{
            2**(D_DWIDTH-1) - 1, 
            2**(D_DWIDTH-1) - 2, 
            -2**(D_DWIDTH-1),
            -2**(D_DWIDTH-1) + 1}; 

        srst <= 1;
        #15;
        srst <= 0;
        send_test_case(1, 2, 3, 5);
        send_test_case(1, 1000, 100500, 6000);
        send_test_case(325, 37, 1245, 33);
        send_test_case(0, 0, 0, 0);
        send_test_case(1, 1, 1, 1);

        for (int i_1 = 0;  i_1 < 4;  i_1++) begin
            for (int i_2 = 0;  i_2 < 4;  i_2++) begin
                for (int i_3 = 0;  i_3 < 4;  i_3++) begin
                    for (int i_4 = 0;  i_4 < 4;  i_4++) begin
                        send_test_case(
                            test_patterns_a[i_1],
                            test_patterns_b[i_2],
                            test_patterns_c[i_3],
                            test_patterns_d[i_4]
                        );
                    end
                end
            end
        end
        #1000;

        $stop();
    end

endmodule