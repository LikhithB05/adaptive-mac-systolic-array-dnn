`timescale 1ns / 1ps

module systolic_array_4x4_accum_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg signed [31:0] A0, A1, A2, A3;
    reg signed [31:0] B0, B1, B2, B3;

    wire signed [79:0] accum_systolic_sum;
    wire valid_out;
    wire overflow_flag;

    // Memory for MNIST
    reg [31:0] activations [0:783];
    reg [31:0] weights     [0:783];

    // DUT (Clean Top-Level Interface)
    systolic_array_4x4_accum_top uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A0(A0), .A1(A1), .A2(A2), .A3(A3),
        .B0(B0), .B1(B1), .B2(B2), .B3(B3),
        .accum_systolic_sum(accum_systolic_sum),
        .valid_out(valid_out),
        .overflow_flag(overflow_flag)
    );

    // Hierarchical debug wires for full simulation visibility & verification checks
    wire signed [63:0] mac00 = uut.mac00; wire signed [63:0] mac01 = uut.mac01; wire signed [63:0] mac02 = uut.mac02; wire signed [63:0] mac03 = uut.mac03;
    wire signed [63:0] mac10 = uut.mac10; wire signed [63:0] mac11 = uut.mac11; wire signed [63:0] mac12 = uut.mac12; wire signed [63:0] mac13 = uut.mac13;
    wire signed [63:0] mac20 = uut.mac20; wire signed [63:0] mac21 = uut.mac21; wire signed [63:0] mac22 = uut.mac22; wire signed [63:0] mac23 = uut.mac23;
    wire signed [63:0] mac30 = uut.mac30; wire signed [63:0] mac31 = uut.mac31; wire signed [63:0] mac32 = uut.mac32; wire signed [63:0] mac33 = uut.mac33;

    wire [1:0] mode00 = uut.mode00; wire [1:0] mode01 = uut.mode01; wire [1:0] mode02 = uut.mode02; wire [1:0] mode03 = uut.mode03;
    wire [1:0] mode10 = uut.mode10; wire [1:0] mode11 = uut.mode11; wire [1:0] mode12 = uut.mode12; wire [1:0] mode13 = uut.mode13;
    wire [1:0] mode20 = uut.mode20; wire [1:0] mode21 = uut.mode21; wire [1:0] mode22 = uut.mode22; wire [1:0] mode23 = uut.mode23;
    wire [1:0] mode30 = uut.mode30; wire [1:0] mode31 = uut.mode31; wire [1:0] mode32 = uut.mode32; wire [1:0] mode33 = uut.mode33;

    wire signed [67:0] systolic_sum = uut.systolic_sum;

    wire signed [79:0] accum_pe00 = uut.accum_pe00; wire signed [79:0] accum_pe01 = uut.accum_pe01; wire signed [79:0] accum_pe02 = uut.accum_pe02; wire signed [79:0] accum_pe03 = uut.accum_pe03;
    wire signed [79:0] accum_pe10 = uut.accum_pe10; wire signed [79:0] accum_pe11 = uut.accum_pe11; wire signed [79:0] accum_pe12 = uut.accum_pe12; wire signed [79:0] accum_pe13 = uut.accum_pe13;
    wire signed [79:0] accum_pe20 = uut.accum_pe20; wire signed [79:0] accum_pe21 = uut.accum_pe21; wire signed [79:0] accum_pe22 = uut.accum_pe22; wire signed [79:0] accum_pe23 = uut.accum_pe23;
    wire signed [79:0] accum_pe30 = uut.accum_pe30; wire signed [79:0] accum_pe31 = uut.accum_pe31; wire signed [79:0] accum_pe32 = uut.accum_pe32; wire signed [79:0] accum_pe33 = uut.accum_pe33;

    always #5 clk = ~clk;

    integer i;
    integer errors = 0;
    integer tests_run = 0;

    // Parallel diagonal channels for dot product accumulation across 4 streams
    wire signed [79:0] pe_sum = accum_pe00 + accum_pe11 + accum_pe22 + accum_pe33;

    initial begin
        $readmemh("activations.mem", activations);
        $readmemh("weights.mem", weights);

        clk    = 0;
        reset  = 1;
        enable = 0;
        clear  = 0;
        A0 = 0; A1 = 0; A2 = 0; A3 = 0;
        B0 = 0; B1 = 0; B2 = 0; B3 = 0;

        #25;
        reset = 0;
        #15;

        $display("================================================================================");
        $display(" RUNNING VERIFICATION: systolic_array_4x4_accum_top");
        $display("================================================================================");

        // -------------------------------------------------------------------------
        // SECTION 1: DIRECTED TESTS
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 1] DIRECTED SYSTOLIC PROPAGATION & CONTROL TESTS ---");

        // Test 1.1: Zero Operands
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        enable = 1;
        A0 = 0; A1 = 0; A2 = 0; A3 = 0;
        B0 = 0; B1 = 0; B2 = 0; B3 = 0;
        #20;
        if (accum_systolic_sum !== 80'd0) begin
            $display("[FAIL] Test 1.1 Zero operand mismatch: accum=%0d", accum_systolic_sum);
            errors = errors + 1;
        end else begin
            $display("[PASS] Test 1.1: Zero Operands (accum=0)");
        end

        // Test 1.2: Directed 4x4 Matrix Multiplication Identity Test
        // Matrix A = Identity(4x4), Matrix B = diag(10, 20, 30, 40)
        // With exact systolic skew:
        //   t=0: A0=1, B0=10
        //   t=1: idle
        //   t=2: A1=1, B1=20
        //   t=3: idle
        //   t=4: A2=1, B2=30
        //   t=5: idle
        //   t=6: A3=1, B3=40
        // Expected diagonal C = diag(10, 20, 30, 40). Total sum = 100.
        tests_run = tests_run + 1;
        clear = 1; #10; clear = 0;
        enable = 1;

        // t=0:
        A0 = 1; A1 = 0; A2 = 0; A3 = 0;
        B0 = 10; B1 = 0; B2 = 0; B3 = 0; #10;
        // t=1:
        A0 = 0; A1 = 0; A2 = 0; A3 = 0;
        B0 = 0; B1 = 0; B2 = 0; B3 = 0; #10;
        // t=2:
        A0 = 0; A1 = 1; A2 = 0; A3 = 0;
        B0 = 0; B1 = 20; B2 = 0; B3 = 0; #10;
        // t=3:
        A0 = 0; A1 = 0; A2 = 0; A3 = 0;
        B0 = 0; B1 = 0; B2 = 0; B3 = 0; #10;
        // t=4:
        A0 = 0; A1 = 0; A2 = 1; A3 = 0;
        B0 = 0; B1 = 0; B2 = 30; B3 = 0; #10;
        // t=5:
        A0 = 0; A1 = 0; A2 = 0; A3 = 0;
        B0 = 0; B1 = 0; B2 = 0; B3 = 0; #10;
        // t=6:
        A0 = 0; A1 = 0; A2 = 0; A3 = 1;
        B0 = 0; B1 = 0; B2 = 0; B3 = 40; #10;

        // Flush pipeline cycles
        A0 = 0; A1 = 0; A2 = 0; A3 = 0;
        B0 = 0; B1 = 0; B2 = 0; B3 = 0;
        #60;
        enable = 0;

        $display("Diagonal Elements in PEs:");
        $display("  PE00: %0d (Expected: 10)", accum_pe00);
        $display("  PE11: %0d (Expected: 20)", accum_pe11);
        $display("  PE22: %0d (Expected: 30)", accum_pe22);
        $display("  PE33: %0d (Expected: 40)", accum_pe33);
        $display("  Total Matrix Sum: %0d (Expected: 100)", accum_systolic_sum);

        if (accum_pe00 === 80'sd10 && accum_pe11 === 80'sd20 &&
            accum_pe22 === 80'sd30 && accum_pe33 === 80'sd40 &&
            accum_systolic_sum === 80'sd100) begin
            $display("[PASS] Test 1.2: 4x4 Systolic Matrix Multiplication Passed!");
        end else begin
            $display("[FAIL] Test 1.2: Matrix multiplication elements mismatch!");
            errors = errors + 1;
        end

        // Test 1.3: Enable Pause Test
        tests_run = tests_run + 1;
        enable = 0;
        A0 = 50; B0 = 50;
        #20;
        if (accum_systolic_sum !== 80'sd100) begin
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
        // SECTION 2: 4-CHANNEL HIGH-THROUGHPUT SYSTOLIC WORKLOAD (196 CYCLES, 4x SPEEDUP)
        // -------------------------------------------------------------------------
        $display("\n--- [TEST SUITE 2] 4-CHANNEL HIGH-THROUGHPUT SYSTOLIC WORKLOAD (196 CYCLES) ---");
        $display("Streaming 784 vectors across all 4 channels (A0..A3, B0..B3) in parallel...");
        clear = 1; #10; clear = 0;
        enable = 1;

        // Feed 784 vectors across all 4 channels simultaneously (4 vectors per cycle)
        // Diagonal PEs (PE00, PE11, PE22, PE33) compute matching (A_i * B_i)
        // PE00: pairs 4*k+0 | PE11: pairs 4*k+1 | PE22: pairs 4*k+2 | PE33: pairs 4*k+3
        for (i = 0; i < 784; i = i + 4) begin
            A0 = $signed(activations[i]);
            B0 = $signed(weights[i]);
            A1 = $signed(activations[i+1]);
            B1 = $signed(weights[i+1]);
            A2 = $signed(activations[i+2]);
            B2 = $signed(weights[i+2]);
            A3 = $signed(activations[i+3]);
            B3 = $signed(weights[i+3]);
            #10;
        end

        // Pipeline flush cycles (4 cycles to allow diagonal propagation)
        A0 = 0; B0 = 0; A1 = 0; B1 = 0;
        A2 = 0; B2 = 0; A3 = 0; B3 = 0;
        #40;
        enable = 0;

        $display("\n--- 4-CHANNEL PARALLEL SYSTOLIC DNN RESULTS ---");
        $display("All 4 Input Channels (A0..A3, B0..B3) Actively Loaded in 196 cycles!");
        $display("PE00 Accumulator : %0d (Expected: 872730384)", accum_pe00);
        $display("PE11 Accumulator : %0d (Expected: 711712637)", accum_pe11);
        $display("PE22 Accumulator : %0d (Expected: 1570409239)", accum_pe22);
        $display("PE33 Accumulator : %0d (Expected: 840856912)", accum_pe33);

        // Combined Diagonal Dot Product Sum: accum_systolic_sum == pe_sum == 3995709172
        tests_run = tests_run + 1;
        if (accum_systolic_sum === 80'd3995709172 && pe_sum === 80'd3995709172) begin
            $display("DUT Top Accum Output (Decimal) : %0d", accum_systolic_sum);
            $display("DUT Top Accum Output (Hex)     : 0x%016X", accum_systolic_sum[63:0]);
            $display("PE Diagonal Sum      (Decimal) : %0d", pe_sum);
            $display("[PASS] Test 2.1: 4-Channel Parallel MNIST Golden Checkpoint Exactly Matched (3995709172)!");
        end else begin
            $display("[FAIL] Test 2.1: Checkpoint mismatch! accum_systolic_sum=%0d, pe_sum=%0d, Expected 3995709172", accum_systolic_sum, pe_sum);
            errors = errors + 1;
        end

        #50;
        $display("\n================================================================================");
        $display(" SUMMARY FOR systolic_array_4x4_accum_top:");
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
