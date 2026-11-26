`timescale 1ns / 1ps

module mac_array_2x2_accum_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg signed [31:0] A0, B0;
    reg signed [31:0] A1, B1;
    reg signed [31:0] A2, B2;
    reg signed [31:0] A3, B3;

    wire signed [79:0] accum_dot_product_out;
    wire valid_out;
    wire overflow_flag;

    // Memory for MNIST
    reg [31:0] activations [0:783];
    reg [31:0] weights     [0:783];

    // DUT (Clean Top-Level Interface)
    mac_array_2x2_accum_top uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A0(A0), .B0(B0),
        .A1(A1), .B1(B1),
        .A2(A2), .B2(B2),
        .A3(A3), .B3(B3),
        .accum_dot_product_out(accum_dot_product_out),
        .valid_out(valid_out),
        .overflow_flag(overflow_flag)
    );

    // Hierarchical debug wires for full simulation visibility & verification checks
    wire [1:0] mode0 = uut.mode0;
    wire [1:0] mode1 = uut.mode1;
    wire [1:0] mode2 = uut.mode2;
    wire [1:0] mode3 = uut.mode3;
    wire signed [63:0] cla0 = uut.cla0;
    wire signed [63:0] cla1 = uut.cla1;
    wire signed [63:0] cla2 = uut.cla2;
    wire signed [63:0] cla3 = uut.cla3;
    wire signed [65:0] dot_product_out = uut.dot_product_out;
    wire signed [79:0] accum_pe0 = uut.accum_pe0;
    wire signed [79:0] accum_pe1 = uut.accum_pe1;
    wire signed [79:0] accum_pe2 = uut.accum_pe2;
    wire signed [79:0] accum_pe3 = uut.accum_pe3;

    always #5 clk = ~clk;

    integer i, k;
    integer errors = 0;
    integer tests_run = 0;

    // Golden checkpoint
    localparam signed [79:0] GOLDEN_CHECKPOINT = 80'd3995709172;
    localparam signed [79:0] GOLDEN_PE0 = 80'd872730384;
    localparam signed [79:0] GOLDEN_PE1 = 80'd711712637;
    localparam signed [79:0] GOLDEN_PE2 = 80'd1570409239;
    localparam signed [79:0] GOLDEN_PE3 = 80'd840856912;

    initial begin
        $readmemh("activations.mem", activations);
        $readmemh("weights.mem", weights);

        clk    = 0;
        reset  = 1;
        enable = 0;
        clear  = 0;
        A0 = 0; B0 = 0;
        A1 = 0; B1 = 0;
        A2 = 0; B2 = 0;
        A3 = 0; B3 = 0;

        #25;
        reset = 0;
        #15;

        $display("================================================================================");
        $display(" RUNNING VERIFICATION: mac_array_2x2_accum_top");
        $display("================================================================================");

        // -------------------------------------------------------------------------
        // SECTION 1: DIRECTED TESTS
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 1] DIRECTED ARITHMETIC & CONTROL TESTS ---");

        // Test 1.1: Zero Operands
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        enable = 1;
        A0 = 0; B0 = 0; A1 = 0; B1 = 0; A2 = 0; B2 = 0; A3 = 0; B3 = 0;
        #10;
        if (dot_product_out !== 66'd0 || accum_dot_product_out !== 80'd0) begin
            $display("[FAIL] Test 1.1 Zero operand mismatch: DP=%0d, ACC=%0d", dot_product_out, accum_dot_product_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.1: Zero Operands (DP=0, ACC=0)");
        end

        // Test 1.2: Mixed Signs (+*+, -*+, +*-, -*-)
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        A0 = 32'sd10;  B0 = 32'sd2;   // +20
        A1 = -32'sd15; B1 = 32'sd4;   // -60
        A2 = 32'sd25;  B2 = -32'sd3;  // -75
        A3 = -32'sd8;  B3 = -32'sd7;  // +56
        // Expected DP = 20 - 60 - 75 + 56 = -59
        #10;
        if (dot_product_out !== -66'sd59 || accum_dot_product_out !== -80'sd59) begin
            $display("[FAIL] Test 1.2 Mixed Signs mismatch: expected -59, got DP=%0d, ACC=%0d", dot_product_out, accum_dot_product_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.2: Mixed Signs (cla: 20, -60, -75, 56 -> DP=-59, ACC=-59)");
        end

        // Test 1.3: Enable Pause Test
        tests_run = tests_run + 1;
        enable = 0;
        A0 = 32'sd100; B0 = 32'sd100;
        #20;
        if (accum_dot_product_out !== -80'sd59) begin
            $display("[FAIL] Test 1.3 Enable pause failed: ACC changed to %0d while enable=0", accum_dot_product_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.3: Enable Pause (ACC held constant at %0d)", accum_dot_product_out);
        end

        // Test 1.4: Clear Test
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        if (accum_dot_product_out !== 80'sd0) begin
            $display("[FAIL] Test 1.4 Synchronous clear failed: ACC=%0d", accum_dot_product_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.4: Synchronous Clear (ACC reset to 0)");
        end

        // Test 1.5: Precision Modes (8-bit, 16-bit, 32-bit limits)
        tests_run = tests_run + 1;
        A0 = 32'sd127;    B0 = -32'sd128;   // 8-bit mode (2'b00)
        A1 = 32'sd32767;  B1 = -32'sd32768; // 16-bit mode (2'b01)
        A2 = 32'sd100000; B2 = -32'sd50000; // 32-bit mode (2'b10)
        A3 = 32'sd0;      B3 = 32'sd0;
        #10;
        if (mode0 !== 2'b00 || mode1 !== 2'b01 || mode2 !== 2'b10) begin
            $display("[FAIL] Test 1.5 Precision mode mismatch: m0=%b, m1=%b, m2=%b", mode0, mode1, mode2);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.5: Precision Modes correctly detected: m0=00(8b), m1=01(16b), m2=10(32b)");
        end

        // -------------------------------------------------------------------------
        // SECTION 2: FULL MNIST WORKLOAD VALIDATION
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 2] FULL MNIST DNN WORKLOAD (784 VECTORS) ---");
        clear = 1; #10; clear = 0;
        enable = 1;

        for (k = 0; k < 196; k = k + 1) begin
            A0 = $signed(activations[4*k]);
            B0 = $signed(weights[4*k]);
            A1 = $signed(activations[4*k+1]);
            B1 = $signed(weights[4*k+1]);
            A2 = $signed(activations[4*k+2]);
            B2 = $signed(weights[4*k+2]);
            A3 = $signed(activations[4*k+3]);
            B3 = $signed(weights[4*k+3]);

            #10; // 1 clock cycle at 100MHz / 10ns per cycle

            // Cycle invariant check: DP == sum of clas
            if (dot_product_out !== (cla0 + cla1 + cla2 + cla3)) begin
                $display("[FAIL] Cycle %0d: dot_product_out mismatch! DP=%0d, sum=%0d",
                         k, dot_product_out, (cla0 + cla1 + cla2 + cla3));
                errors = errors + 1;
            end
        end

        // Checkpoint verification
        tests_run = tests_run + 1;
        $display("\n--- FINAL WORKLOAD RESULTS ---");
        $display("Actual Accum Dot Product (Decimal) : %0d", accum_dot_product_out);
        $display("Expected Checkpoint      (Decimal) : %0d", GOLDEN_CHECKPOINT);
        $display("Actual Accum Dot Product (Hex)     : 0x%016X", accum_dot_product_out[63:0]);
        $display("Expected Checkpoint      (Hex)     : 0x%016X", GOLDEN_CHECKPOINT[63:0]);
        $display("Individual PE Accumulators:");
        $display("  PE0: %0d (Expected: %0d)", accum_pe0, GOLDEN_PE0);
        $display("  PE1: %0d (Expected: %0d)", accum_pe1, GOLDEN_PE1);
        $display("  PE2: %0d (Expected: %0d)", accum_pe2, GOLDEN_PE2);
        $display("  PE3: %0d (Expected: %0d)", accum_pe3, GOLDEN_PE3);

        if (accum_dot_product_out === GOLDEN_CHECKPOINT &&
            accum_pe0 === GOLDEN_PE0 &&
            accum_pe1 === GOLDEN_PE1 &&
            accum_pe2 === GOLDEN_PE2 &&
            accum_pe3 === GOLDEN_PE3) begin
            $display("\n>>> [PASS] MANDATORY CHECKPOINT 3995709172 PASSED EXACTLY ON mac_array_2x2_accum_top! <<<");
        end else begin
            $display("\n>>> [FAIL] MANDATORY CHECKPOINT FAILED on mac_array_2x2_accum_top! <<<");
            errors = errors + 1;
        end

        // Invariant: sum of PE accumulators == accum_dot_product_out
        tests_run = tests_run + 1;
        if ((accum_pe0 + accum_pe1 + accum_pe2 + accum_pe3) !== accum_dot_product_out) begin
            $display("[FAIL] Invariant failed: PE sum != accum_dot_product_out");
            errors = errors + 1;
        end else begin
            $display("[PASS] Invariant Verified: accum_dot_product_out == sum(accum_pe[0..3])");
        end

        #50;
        $display("\n================================================================================");
        $display(" SUMMARY FOR mac_array_2x2_accum_top:");
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
