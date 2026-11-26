`timescale 1ns/1ps
// Supplementary stimulus for the repository waveform. Original RTL is instantiated unchanged.
module waveform_tb;
    reg clk = 0, reset = 1;
    reg signed [31:0] A0 = 0, A1 = 0, B0 = 0, B1 = 0;
    reg enable = 0, clear = 0;
    wire signed [79:0] accum_systolic_sum;
    wire valid_out, overflow_flag;
    systolic_array_2x2_accum_top dut(.clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .A0(A0), .A1(A1), .B0(B0), .B1(B1), .accum_systolic_sum(accum_systolic_sum),
        .valid_out(valid_out), .overflow_flag(overflow_flag));
    wire signed [63:0] mac00 = dut.mac00, mac01 = dut.mac01, mac10 = dut.mac10, mac11 = dut.mac11;

    always #5 clk = ~clk;

    initial begin
        $dumpfile("trace.vcd");
        $dumpvars(0, clk, A0, B0, A1, B1, mac00, mac01, mac10, mac11, accum_systolic_sum);
        #1; A0 = 70000; B0 = 0; A1 = 70000; B1 = 0;
        #1; A0 = 0; A1 = 0;
        @(negedge clk); reset = 0; enable = 1; A0 = 2; B0 = 3;
        @(negedge clk); A0 = 0; B0 = 0; A1 = 5; B1 = 7;
        @(negedge clk); A1 = 0; B1 = 0;
        @(posedge clk); #1;
        if (accum_systolic_sum !== 80'sd41) $fatal(1, "Wrong terminal sum");
        @(negedge clk); enable = 0;
        @(posedge clk); #1;
        $display("Waveform terminal check passed");
        $finish;
    end
endmodule
