package calc_pkg;
    parameter int A_DWIDTH = 32;
    parameter int B_DWIDTH = 32;
    parameter int C_DWIDTH = 32;
    parameter int D_DWIDTH = 32;

    function automatic int max2(int a, b);
        return (a > b) ? a : b;
    endfunction

    function automatic int max3(int a, b, c);
        return max2(max2(a, b), c);
    endfunction

    // (a - b)(1 + 3c) - 4d -> a - b + 3ac - 3bc - 4d
    // -> check only width of ac, bc and d. Then add some bits for except overflow
    parameter int Q_DWIDTH = max3(A_DWIDTH + C_DWIDTH, B_DWIDTH + C_DWIDTH, D_DWIDTH) + 4;

    // without an interface because it's too much
endpackage
