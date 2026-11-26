`timescale 1ns / 1ps

module mac_array_4x4_accum_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg signed [31:0] A0,  B0,  A1,  B1,  A2,  B2,  A3,  B3;
    reg signed [31:0] A4,  B4,  A5,  B5,  A6,  B6,  A7,  B7;
    reg signed [31:0] A8,  B8,  A9,  B9,  A10, B10, A11, B11;
    reg signed [31:0] A12, B12, A13, B13, A14, B14, A15, B15;

    wire signed [79:0] accum_dot_product_out;
    wire valid_out;
    wire overflow_flag;

    // Memory for MNIST
    reg [31:0] activations [0:783];
    reg [31:0] weights     [0:783];

    // DUT (Clean Top-Level Interface)
    mac_array_4x4_accum_top uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A0(A0),   .B0(B0),   .A1(A1),   .B1(B1),   .A2(A2),   .B2(B2),   .A3(A3),   .B3(B3),
        .A4(A4),   .B4(B4),   .A5(A5),   .B5(B5),   .A6(A6),   .B6(B6),   .A7(A7),   .B7(B7),
        .A8(A8),   .B8(B8),   .A9(A9),   .B9(B9),   .A10(A10), .B10(B10), .A11(A11), .B11(B11),
        .A12(A12), .B12(B12), .A13(A13), .B13(B13), .A14(A14), .B14(B14), .A15(A15), .B15(B15),
        .accum_dot_product_out(accum_dot_product_out),
        .valid_out(valid_out),
        .overflow_flag(overflow_flag)
    );

    // Hierarchical debug wires for full simulation visibility & verification checks
    wire [1:0] mode0  = uut.mode0;  wire [1:0] mode1  = uut.mode1;  wire [1:0] mode2  = uut.mode2;  wire [1:0] mode3  = uut.mode3;
    wire [1:0] mode4  = uut.mode4;  wire [1:0] mode5  = uut.mode5;  wire [1:0] mode6  = uut.mode6;  wire [1:0] mode7  = uut.mode7;
    wire [1:0] mode8  = uut.mode8;  wire [1:0] mode9  = uut.mode9;  wire [1:0] mode10 = uut.mode10; wire [1:0] mode11 = uut.mode11;
    wire [1:0] mode12 = uut.mode12; wire [1:0] mode13 = uut.mode13; wire [1:0] mode14 = uut.mode14; wire [1:0] mode15 = uut.mode15;

    wire signed [63:0] cla0  = uut.cla0;  wire signed [63:0] cla1  = uut.cla1;  wire signed [63:0] cla2  = uut.cla2;  wire signed [63:0] cla3  = uut.cla3;
    wire signed [63:0] cla4  = uut.cla4;  wire signed [63:0] cla5  = uut.cla5;  wire signed [63:0] cla6  = uut.cla6;  wire signed [63:0] cla7  = uut.cla7;
    wire signed [63:0] cla8  = uut.cla8;  wire signed [63:0] cla9  = uut.cla9;  wire signed [63:0] cla10 = uut.cla10; wire signed [63:0] cla11 = uut.cla11;
    wire signed [63:0] cla12 = uut.cla12; wire signed [63:0] cla13 = uut.cla13; wire signed [63:0] cla14 = uut.cla14; wire signed [63:0] cla15 = uut.cla15;

    wire signed [67:0] dot_product_out = uut.dot_product_out;

    wire signed [79:0] accum_pe0  = uut.accum_pe0;  wire signed [79:0] accum_pe1  = uut.accum_pe1;  wire signed [79:0] accum_pe2  = uut.accum_pe2;  wire signed [79:0] accum_pe3  = uut.accum_pe3;
    wire signed [79:0] accum_pe4  = uut.accum_pe4;  wire signed [79:0] accum_pe5  = uut.accum_pe5;  wire signed [79:0] accum_pe6  = uut.accum_pe6;  wire signed [79:0] accum_pe7  = uut.accum_pe7;
    wire signed [79:0] accum_pe8  = uut.accum_pe8;  wire signed [79:0] accum_pe9  = uut.accum_pe9;  wire signed [79:0] accum_pe10 = uut.accum_pe10; wire signed [79:0] accum_pe11 = uut.accum_pe11;
    wire signed [79:0] accum_pe12 = uut.accum_pe12; wire signed [79:0] accum_pe13 = uut.accum_pe13; wire signed [79:0] accum_pe14 = uut.accum_pe14; wire signed [79:0] accum_pe15 = uut.accum_pe15;

    always #5 clk = ~clk;

    integer b, m;
    integer errors = 0;
    integer tests_run = 0;

    localparam signed [79:0] GOLDEN_CHECKPOINT = 80'd3995709172;

    // Golden values for each of the 16 PEs from independent python reference
    reg signed [79:0] golden_pe [0:15];
    initial begin
        golden_pe[0]  = -80'sd2625279;
        golden_pe[1]  =  80'sd956944055;
        golden_pe[2]  =  80'sd1018845896;
        golden_pe[3]  =  80'sd306245600;
        golden_pe[4]  =  80'sd17219172;
        golden_pe[5]  = -80'sd706171033;
        golden_pe[6]  =  80'sd43964151;
        golden_pe[7]  =  80'sd699893018;
        golden_pe[8]  =  80'sd987214978;
        golden_pe[9]  =  80'sd116885640;
        golden_pe[10] =  80'sd493078871;
        golden_pe[11] =  80'sd118907298;
        golden_pe[12] = -80'sd129078487;
        golden_pe[13] =  80'sd344053975;
        golden_pe[14] =  80'sd14520321;
        golden_pe[15] = -80'sd284189004;
    end

    wire signed [79:0] pe_sum = accum_pe0 + accum_pe1 + accum_pe2 + accum_pe3 +
                               accum_pe4 + accum_pe5 + accum_pe6 + accum_pe7 +
                               accum_pe8 + accum_pe9 + accum_pe10 + accum_pe11 +
                               accum_pe12 + accum_pe13 + accum_pe14 + accum_pe15;

    initial begin
        $readmemh("activations.mem", activations);
        $readmemh("weights.mem", weights);

        clk    = 0;
        reset  = 1;
        enable = 0;
        clear  = 0;
        A0=0; B0=0; A1=0; B1=0; A2=0; B2=0; A3=0; B3=0;
        A4=0; B4=0; A5=0; B5=0; A6=0; B6=0; A7=0; B7=0;
        A8=0; B8=0; A9=0; B9=0; A10=0; B10=0; A11=0; B11=0;
        A12=0; B12=0; A13=0; B13=0; A14=0; B14=0; A15=0; B15=0;

        #25;
        reset = 0;
        #15;

        $display("================================================================================");
        $display(" RUNNING VERIFICATION: mac_array_4x4_accum_top");
        $display("================================================================================");

        // -------------------------------------------------------------------------
        // SECTION 1: DIRECTED TESTS
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 1] DIRECTED ARITHMETIC & CONTROL TESTS ---");

        // Test 1.1: Zero Operands
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        enable = 1;
        #10;
        if (dot_product_out !== 68'd0 || accum_dot_product_out !== 80'd0) begin
            $display("[FAIL] Test 1.1 Zero operand mismatch: DP=%0d, ACC=%0d", dot_product_out, accum_dot_product_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.1: Zero Operands (DP=0, ACC=0)");
        end

        // Test 1.2: Directed Vector Sum (1^2 + 2^2 + ... + 16^2 = 1496)
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        A0=1;  B0=1;   A1=2;  B1=2;   A2=3;  B2=3;   A3=4;  B3=4;
        A4=5;  B4=5;   A5=6;  B5=6;   A6=7;  B6=7;   A7=8;  B7=8;
        A8=9;  B8=9;   A9=10; B9=10;  A10=11; B10=11; A11=12; B11=12;
        A12=13; B12=13; A13=14; B13=14; A14=15; B14=15; A15=16; B15=16;
        #10;
        if (dot_product_out !== 68'sd1496 || accum_dot_product_out !== 80'sd1496) begin
            $display("[FAIL] Test 1.2 Sum of squares mismatch: expected 1496, got DP=%0d, ACC=%0d", dot_product_out, accum_dot_product_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.2: Sum of squares 1..16 (DP=1496, ACC=1496)");
        end

        // Test 1.3: Enable Pause Test
        tests_run = tests_run + 1;
        enable = 0;
        A0 = 100; B0 = 100;
        #20;
        if (accum_dot_product_out !== 80'sd1496) begin
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

        // -------------------------------------------------------------------------
        // SECTION 2: FULL MNIST WORKLOAD VALIDATION (49 BATCHES OF 16 = 784)
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 2] FULL MNIST DNN WORKLOAD (784 VECTORS IN 49 BATCHES) ---");
        clear = 1; #10; clear = 0;
        enable = 1;

        for (b = 0; b < 49; b = b + 1) begin
            A0  = $signed(activations[16*b + 0]);  B0  = $signed(weights[16*b + 0]);
            A1  = $signed(activations[16*b + 1]);  B1  = $signed(weights[16*b + 1]);
            A2  = $signed(activations[16*b + 2]);  B2  = $signed(weights[16*b + 2]);
            A3  = $signed(activations[16*b + 3]);  B3  = $signed(weights[16*b + 3]);
            A4  = $signed(activations[16*b + 4]);  B4  = $signed(weights[16*b + 4]);
            A5  = $signed(activations[16*b + 5]);  B5  = $signed(weights[16*b + 5]);
            A6  = $signed(activations[16*b + 6]);  B6  = $signed(weights[16*b + 6]);
            A7  = $signed(activations[16*b + 7]);  B7  = $signed(weights[16*b + 7]);
            A8  = $signed(activations[16*b + 8]);  B8  = $signed(weights[16*b + 8]);
            A9  = $signed(activations[16*b + 9]);  B9  = $signed(weights[16*b + 9]);
            A10 = $signed(activations[16*b + 10]); B10 = $signed(weights[16*b + 10]);
            A11 = $signed(activations[16*b + 11]); B11 = $signed(weights[16*b + 11]);
            A12 = $signed(activations[16*b + 12]); B12 = $signed(weights[16*b + 12]);
            A13 = $signed(activations[16*b + 13]); B13 = $signed(weights[16*b + 13]);
            A14 = $signed(activations[16*b + 14]); B14 = $signed(weights[16*b + 14]);
            A15 = $signed(activations[16*b + 15]); B15 = $signed(weights[16*b + 15]);

            #10;
        end

        // Checkpoint verification
        tests_run = tests_run + 1;
        $display("\n--- FINAL WORKLOAD RESULTS ---");
        $display("Actual Accum Dot Product (Decimal) : %0d", accum_dot_product_out);
        $display("Expected Checkpoint      (Decimal) : %0d", GOLDEN_CHECKPOINT);
        $display("Actual Accum Dot Product (Hex)     : 0x%016X", accum_dot_product_out[63:0]);
        $display("Expected Checkpoint      (Hex)     : 0x%016X", GOLDEN_CHECKPOINT[63:0]);

        if (accum_dot_product_out === GOLDEN_CHECKPOINT) begin
            $display("\n>>> [PASS] MANDATORY CHECKPOINT 3995709172 PASSED EXACTLY ON mac_array_4x4_accum_top! <<<");
        end else begin
            $display("\n>>> [FAIL] MANDATORY CHECKPOINT FAILED on mac_array_4x4_accum_top! <<<");
            errors = errors + 1;
        end

        // Verify all 16 PE accumulators against independent golden model
        tests_run = tests_run + 1;
        $display("\nChecking 16 Individual PE Accumulators against Python Golden Model:");
        if (accum_pe0  === golden_pe[0]  && accum_pe1  === golden_pe[1]  &&
            accum_pe2  === golden_pe[2]  && accum_pe3  === golden_pe[3]  &&
            accum_pe4  === golden_pe[4]  && accum_pe5  === golden_pe[5]  &&
            accum_pe6  === golden_pe[6]  && accum_pe7  === golden_pe[7]  &&
            accum_pe8  === golden_pe[8]  && accum_pe9  === golden_pe[9]  &&
            accum_pe10 === golden_pe[10] && accum_pe11 === golden_pe[11] &&
            accum_pe12 === golden_pe[12] && accum_pe13 === golden_pe[13] &&
            accum_pe14 === golden_pe[14] && accum_pe15 === golden_pe[15]) begin
            $display("[PASS] All 16 PE accumulators match independent golden reference model!");
        end else begin
            $display("[FAIL] Individual PE accumulator mismatch detected!");
            errors = errors + 1;
        end

        // Invariant: sum of all 16 PE accumulators == accum_dot_product_out
        tests_run = tests_run + 1;
        if (pe_sum !== accum_dot_product_out) begin
            $display("[FAIL] Invariant failed: PE sum (%0d) != accum_dot_product_out (%0d)", pe_sum, accum_dot_product_out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Invariant Verified: accum_dot_product_out == sum(accum_pe[0..15])");
        end

        #50;
        $display("\n================================================================================");
        $display(" SUMMARY FOR mac_array_4x4_accum_top:");
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
