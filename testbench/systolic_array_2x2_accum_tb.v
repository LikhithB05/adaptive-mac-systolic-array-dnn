`timescale 1ns / 1ps

module systolic_array_2x2_accum_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg signed [31:0] A0, A1;
    reg signed [31:0] B0, B1;

    wire signed [79:0] accum_systolic_sum;
    wire valid_out;
    wire overflow_flag;

    // Memory for MNIST
    reg [31:0] activations [0:783];
    reg [31:0] weights     [0:783];

    // DUT (Clean Top-Level Interface)
    systolic_array_2x2_accum_top uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A0(A0), .A1(A1),
        .B0(B0), .B1(B1),
        .accum_systolic_sum(accum_systolic_sum),
        .valid_out(valid_out),
        .overflow_flag(overflow_flag)
    );

    // Hierarchical debug wires for full simulation visibility & verification checks
    wire signed [63:0] mac00 = uut.mac00;
    wire signed [63:0] mac01 = uut.mac01;
    wire signed [63:0] mac10 = uut.mac10;
    wire signed [63:0] mac11 = uut.mac11;

    wire [1:0] mode00 = uut.mode00;
    wire [1:0] mode01 = uut.mode01;
    wire [1:0] mode10 = uut.mode10;
    wire [1:0] mode11 = uut.mode11;

    wire signed [65:0] systolic_sum = uut.systolic_sum;

    wire signed [79:0] accum_pe00 = uut.accum_pe00;
    wire signed [79:0] accum_pe01 = uut.accum_pe01;
    wire signed [79:0] accum_pe10 = uut.accum_pe10;
    wire signed [79:0] accum_pe11 = uut.accum_pe11;

    always #5 clk = ~clk;

    integer i;
    integer errors = 0;
    integer tests_run = 0;

    // Parallel diagonal channels for dot product accumulation across 2 streams
    wire signed [79:0] pe_sum = accum_pe00 + accum_pe11;

    initial begin
        $readmemh("activations.mem", activations);
        $readmemh("weights.mem", weights);

        clk    = 0;
        reset  = 1;
        enable = 0;
        clear  = 0;
        A0 = 0; A1 = 0;
        B0 = 0; B1 = 0;

        #25;
        reset = 0;
        #15;

        $display("================================================================================");
        $display(" RUNNING VERIFICATION: systolic_array_2x2_accum_top");
        $display("================================================================================");

        // -------------------------------------------------------------------------
        // SECTION 1: DIRECTED TESTS
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 1] DIRECTED SYSTOLIC PROPAGATION & CONTROL TESTS ---");

        // Test 1.1: Zero Operands
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        enable = 1;
        A0 = 0; A1 = 0; B0 = 0; B1 = 0;
        #20;
        if (accum_systolic_sum !== 80'd0) begin
            $display("[FAIL] Test 1.1 Zero operand mismatch: accum=%0d", accum_systolic_sum);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.1: Zero Operands (accum=0)");
        end

        // Test 1.2: Directed 2x2 Matrix Multiplication with Skewed Systolic Feed
        // A = [[1, 2], [3, 4]], B = [[5, 6], [7, 8]]
        // Skewed feeding:
        // Cycle 0: A0=1, A1=0,  B0=5, B1=0
        // Cycle 1: A0=2, A1=3,  B0=7, B1=6
        // Cycle 2: A0=0, A1=4,  B0=0, B1=8
        // Cycle 3: A0=0, A1=0,  B0=0, B1=0
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        enable = 1;

        // Cycle 0
        A0 = 1; A1 = 0; B0 = 5; B1 = 0; #10;
        // Cycle 1
        A0 = 2; A1 = 3; B0 = 7; B1 = 6; #10;
        // Cycle 2
        A0 = 0; A1 = 4; B0 = 0; B1 = 8; #10;
        // Cycle 3 (flush)
        A0 = 0; A1 = 0; B0 = 0; B1 = 0; #10;
        enable = 0; // stop accumulating

        $display("Matrix Multiply Result Elements in PEs:");
        $display("  PE00 (C00): %0d (Expected: 19)", accum_pe00);
        $display("  PE01 (C01): %0d (Expected: 22)", accum_pe01);
        $display("  PE10 (C10): %0d (Expected: 43)", accum_pe10);
        $display("  PE11 (C11): %0d (Expected: 50)", accum_pe11);
        $display("  Full Matrix Sum (All 4 PEs) : %0d (Expected: 134)", (accum_pe00 + accum_pe01 + accum_pe10 + accum_pe11));
        $display("  Diagonal Trace Output (DUT) : %0d (Expected: 69)", accum_systolic_sum);

        if (accum_pe00 === 80'sd19 && accum_pe01 === 80'sd22 &&
            accum_pe10 === 80'sd43 && accum_pe11 === 80'sd50 &&
            (accum_pe00 + accum_pe01 + accum_pe10 + accum_pe11) === 80'sd134 &&
            accum_systolic_sum === 80'sd69) begin
            $display("[PASS] Test 1.2: 2x2 Matrix Multiplication Passed with Exact Matrix Elements!");
        end else begin
            $display("[FAIL] Test 1.2: Matrix multiplication elements mismatch!");
            errors = errors + 1;
        end

        // Test 1.3: Enable Pause Test
        tests_run = tests_run + 1;
        enable = 0;
        A0 = 50; B0 = 50;
        #20;
        if (accum_systolic_sum !== 80'sd69) begin
            $display("[FAIL] Test 1.3 Enable pause failed: ACC changed to %0d while enable=0", accum_systolic_sum);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.3: Enable Pause (ACC held constant at %0d)", accum_systolic_sum);
        end

        // Test 1.4: Clear Test
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        if (accum_systolic_sum !== 80'sd0) begin
            $display("[FAIL] Test 1.4 Synchronous clear failed: ACC=%0d", accum_systolic_sum);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.4: Synchronous Clear (ACC reset to 0)");
        end

        // -------------------------------------------------------------------------
        // SECTION 2: 2-CHANNEL HIGH-THROUGHPUT SYSTOLIC WORKLOAD (392 CYCLES, 2x SPEEDUP)
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 2] 2-CHANNEL HIGH-THROUGHPUT SYSTOLIC WORKLOAD (392 CYCLES) ---");
        $display("Streaming 784 vectors across both channels (A0, A1 and B0, B1) in parallel...");
        clear = 1; #10; clear = 0;
        enable = 1;

        // Feed 784 vectors across both channels simultaneously (2 vectors per cycle)
        // Diagonal PEs (PE00, PE11) compute matching (A_i * B_i)
        // PE00: pairs 2*k+0 | PE11: pairs 2*k+1
        for (i = 0; i < 784; i = i + 2) begin
            A0 = $signed(activations[i]);
            B0 = $signed(weights[i]);
            A1 = $signed(activations[i+1]);
            B1 = $signed(weights[i+1]);
            #10;
        end

        // Pipeline flush cycles (2 cycles to allow diagonal propagation)
        A0 = 0; B0 = 0; A1 = 0; B1 = 0;
        #20;
        enable = 0;

        $display("\n--- 2-CHANNEL PARALLEL SYSTOLIC DNN RESULTS ---");
        $display("Both Input Channels (A0, A1 and B0, B1) Actively Loaded in 392 cycles!");
        $display("PE00 Accumulator : %0d (Expected: 2443139623)", accum_pe00);
        $display("PE11 Accumulator : %0d (Expected: 1552569549)", accum_pe11);

        // Combined Diagonal Dot Product Sum: accum_systolic_sum == pe_sum == 3995709172
        tests_run = tests_run + 1;
        if (accum_systolic_sum === 80'd3995709172 && pe_sum === 80'd3995709172) begin
            $display("DUT Top Accum Output (Decimal) : %0d", accum_systolic_sum);
            $display("DUT Top Accum Output (Hex)     : 0x%016X", accum_systolic_sum[63:0]);
            $display("PE Diagonal Sum      (Decimal) : %0d", pe_sum);
            $display("[PASS] Test 2.1: 2-Channel Parallel MNIST Golden Checkpoint Exactly Matched (3995709172)!");
        end else begin
            $display("[FAIL] Test 2.1: Checkpoint mismatch! accum_systolic_sum=%0d, pe_sum=%0d, Expected 3995709172", accum_systolic_sum, pe_sum);
            errors = errors + 1;
        end

        #50;
        $display("\n================================================================================");
        $display(" SUMMARY FOR systolic_array_2x2_accum_top:");
        $display(" Total Test Suites Run : %0d", tests_run);
        $display(" Total Failures        : %0d", errors);
        if (errors == 0)
            $display(" STATUS                : >>> PASS <<<");
        else
            $display(" STATUS                : >>> FAIL <<<");
        $display("================================================================================\n");

        $finish;
    end

endmodule
