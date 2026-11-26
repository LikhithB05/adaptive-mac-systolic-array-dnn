`timescale 1ns / 1ps

module adaptive_systolic_array_4x4_dnn_tb;

/////////////////////////////////////////////////////////
// CLOCK RESET
/////////////////////////////////////////////////////////

reg clk;
reg reset;

/////////////////////////////////////////////////////////
// DNN MEMORY
/////////////////////////////////////////////////////////

reg [31:0] weights     [0:783];
reg [31:0] activations [0:783];

/////////////////////////////////////////////////////////
// ARRAY INPUTS
/////////////////////////////////////////////////////////

reg signed [31:0] A0, A1, A2, A3;
reg signed [31:0] B0, B1, B2, B3;

/////////////////////////////////////////////////////////
// LOOP VARIABLES
/////////////////////////////////////////////////////////

integer i;

/////////////////////////////////////////////////////////
// STATISTICS
/////////////////////////////////////////////////////////

integer mode8_count;
integer mode16_count;
integer mode32_count;

integer total_batches;
integer skip_count;
integer execute_count;

/////////////////////////////////////////////////////////
// OUTPUTS
/////////////////////////////////////////////////////////

wire signed [63:0] mac00, mac01, mac02, mac03;
wire signed [63:0] mac10, mac11, mac12, mac13;
wire signed [63:0] mac20, mac21, mac22, mac23;
wire signed [63:0] mac30, mac31, mac32, mac33;

wire [1:0] mode00, mode01, mode02, mode03;
wire [1:0] mode10, mode11, mode12, mode13;
wire [1:0] mode20, mode21, mode22, mode23;
wire [1:0] mode30, mode31, mode32, mode33;

wire signed [67:0] systolic_sum;

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////

adaptive_systolic_array_4x4 uut(
    .clk(clk),
    .reset(reset),

    .A0(A0), .A1(A1), .A2(A2), .A3(A3),
    .B0(B0), .B1(B1), .B2(B2), .B3(B3),

    .mac00(mac00), .mac01(mac01), .mac02(mac02), .mac03(mac03),
    .mac10(mac10), .mac11(mac11), .mac12(mac12), .mac13(mac13),
    .mac20(mac20), .mac21(mac21), .mac22(mac22), .mac23(mac23),
    .mac30(mac30), .mac31(mac31), .mac32(mac32), .mac33(mac33),

    .mode00(mode00), .mode01(mode01), .mode02(mode02), .mode03(mode03),
    .mode10(mode10), .mode11(mode11), .mode12(mode12), .mode13(mode13),
    .mode20(mode20), .mode21(mode21), .mode22(mode22), .mode23(mode23),
    .mode30(mode30), .mode31(mode31), .mode32(mode32), .mode33(mode33),

    .systolic_sum(systolic_sum)
);

/////////////////////////////////////////////////////////
// CLOCK
/////////////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////////////
// MODE COUNT TASK
/////////////////////////////////////////////////////////

task count_mode;
    input [1:0] mode;
    begin
        case(mode)
            2'b00: mode8_count  = mode8_count  + 1;
            2'b01: mode16_count = mode16_count + 1;
            2'b10: mode32_count = mode32_count + 1;
            default: ;
        endcase
    end
endtask

/////////////////////////////////////////////////////////
// LOAD MEM FILES
/////////////////////////////////////////////////////////

initial begin
    $readmemh("weights.mem",     weights);
    $readmemh("activations.mem", activations);
end

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////

initial begin

    clk   = 0;
    reset = 1;

    A0 = 0; A1 = 0; A2 = 0; A3 = 0;
    B0 = 0; B1 = 0; B2 = 0; B3 = 0;

    mode8_count  = 0;
    mode16_count = 0;
    mode32_count = 0;

    total_batches    = 0;
    skip_count       = 0;
    execute_count    = 0;

    #20;
    reset = 0;

    /////////////////////////////////////////////////////
    // FEED DNN DATA - flush and report are OUTSIDE loop
    /////////////////////////////////////////////////////

    for (i = 0; i < 784; i = i + 16)
    begin

        A0 = $signed(activations[i]);
        A1 = $signed(activations[i+1]);
        A2 = $signed(activations[i+2]);
        A3 = $signed(activations[i+3]);

        B0 = $signed(weights[i]);
        B1 = $signed(weights[i+1]);
        B2 = $signed(weights[i+2]);
        B3 = $signed(weights[i+3]);

        total_batches = total_batches + 1;

        #20;

        /////////////////////////////////////////////////
        // COUNT ALL 16 PE MODES
        /////////////////////////////////////////////////

        count_mode(mode00); count_mode(mode01);
        count_mode(mode02); count_mode(mode03);

        count_mode(mode10); count_mode(mode11);
        count_mode(mode12); count_mode(mode13);

        count_mode(mode20); count_mode(mode21);
        count_mode(mode22); count_mode(mode23);

        count_mode(mode30); count_mode(mode31);
        count_mode(mode32); count_mode(mode33);

        /////////////////////////////////////////////////
        // SPARSITY COUNT
        /////////////////////////////////////////////////

        if (mac00 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac01 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac02 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac03 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;

        if (mac10 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac11 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac12 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac13 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;

        if (mac20 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac21 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac22 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac23 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;

        if (mac30 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac31 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac32 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;
        if (mac33 == 0) skip_count = skip_count + 1; else execute_count = execute_count + 1;

    end  // END FOR LOOP

    /////////////////////////////////////////////////////
    // PIPELINE FLUSH - happens ONCE after all batches
    /////////////////////////////////////////////////////

    #200;

    /////////////////////////////////////////////////////
    // REPORT - happens ONCE after flush
    /////////////////////////////////////////////////////

    $display("");
    $display("========================================");
    $display("4x4 ADAPTIVE SYSTOLIC DNN REPORT");
    $display("========================================");

    $display("Total Batches     = %0d", total_batches);
    $display("----------------------------------------");

    $display("Skipped  MACs     = %0d", skip_count);
    $display("Executed MACs     = %0d", execute_count);
    $display("----------------------------------------");

    $display("8-bit  Count      = %0d", mode8_count);
    $display("16-bit Count      = %0d", mode16_count);
    $display("32-bit Count      = %0d", mode32_count);
    $display("----------------------------------------");

    if ((skip_count + execute_count) != 0)
    begin
        $display("Sparsity %%   = %0f",
            (skip_count   * 100.0) / (skip_count + execute_count));
        $display("Execution %%  = %0f",
            (execute_count * 100.0) / (skip_count + execute_count));
    end

    $display("----------------------------------------");

    if ((mode8_count + mode16_count + mode32_count) != 0)
    begin
        $display("8-bit  %%  = %0f",
            (mode8_count  * 100.0) / (mode8_count + mode16_count + mode32_count));
        $display("16-bit %%  = %0f",
            (mode16_count * 100.0) / (mode8_count + mode16_count + mode32_count));
        $display("32-bit %%  = %0f",
            (mode32_count * 100.0) / (mode8_count + mode16_count + mode32_count));
    end

    $display("========================================");

    $finish;

end

/////////////////////////////////////////////////////////
// MONITOR
/////////////////////////////////////////////////////////

initial begin
    $monitor(
        "t=%0t SUM=%0d MODE00=%b MODE01=%b MODE02=%b MODE03=%b",
        $time,
        systolic_sum,
        mode00, mode01, mode02, mode03
    );
end

endmodule