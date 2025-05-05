import calc_pkg::*;

module calc #(
    parameter int A_DWIDTH = calc_pkg::A_DWIDTH,
    parameter int B_DWIDTH = calc_pkg::B_DWIDTH,
    parameter int C_DWIDTH = calc_pkg::C_DWIDTH,
    parameter int D_DWIDTH = calc_pkg::D_DWIDTH,

    parameter int Q_DWIDTH = calc_pkg::Q_DWIDTH
) (
    input  logic clk,
    input  logic srst,

    input  logic                       tvalid_i,
    input  logic signed [A_DWIDTH-1:0] a_i,
    input  logic signed [B_DWIDTH-1:0] b_i,
    input  logic signed [C_DWIDTH-1:0] c_i,
    input  logic signed [D_DWIDTH-1:0] d_i, 

    output logic                       tvalid_o,
    output logic signed [Q_DWIDTH-1:0] q_o
);
    localparam CALC_LATENCY = 4;

    logic [CALC_LATENCY-1:0] tvalid;

    always_ff @( posedge clk ) begin
        if (srst) begin
            tvalid <= '0;
        end else begin
            tvalid <= {tvalid, tvalid_i};
        end
    end
    
    assign tvalid_o = tvalid[CALC_LATENCY-1];
    
    logic signed [A_DWIDTH-1:0] a;
    logic signed [B_DWIDTH-1:0] b;
    logic signed [C_DWIDTH-1:0] c;
    logic signed [D_DWIDTH-1:0] d;

    always_ff @( posedge clk ) begin
        a <= a_i;
        b <= b_i;
        c <= c_i;
        d <= d_i;
    end

    // pipe 1
    logic signed [max2(A_DWIDTH, B_DWIDTH):0] sub_ab; // a - b
    logic signed [C_DWIDTH + 2:0            ] mult_c; // 1 + 3c
    logic signed [D_DWIDTH + 1:0            ] mult_d; // 4d

    always_ff @( posedge clk ) begin
        sub_ab <= a - b;
        mult_c <= (c << 1) + c + 1;
        mult_d <= d << 2;
    end

    // pipe 2
    logic signed [max2(A_DWIDTH, B_DWIDTH) + C_DWIDTH + 2:0] mult_sub_add; //
    logic signed [D_DWIDTH + 1:0                           ] mult_d_dff;   // dff for 3d from prev pipe

    always_ff @( posedge clk ) begin
        mult_sub_add <= sub_ab * mult_c;
        mult_d_dff   <= mult_d;
    end

    // pipe 3
    always_ff @( posedge clk ) begin
        q_o <= (mult_sub_add - mult_d_dff) >>> 1;
    end

    // synthesis translate_off
    integer FILE_in = $fopen("./input.txt", "w");
    integer FILE_out = $fopen("./output.txt", "w");

    always_ff @( posedge clk ) begin
        if ( tvalid_i ) begin
            $fdisplay(FILE_in, "%0d %0d %0d %0d", a_i, b_i, c_i, d_i);
        end
    end

    always_ff @( posedge clk ) begin
        if ( tvalid_o ) begin
            $fdisplay(FILE_out, "%0d", q_o);
        end
    end
    // synthesis translate_on

endmodule