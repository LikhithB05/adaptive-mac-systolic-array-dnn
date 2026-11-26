`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design: systolic_array_4x4_accum_top
// Architecture: 4x4 Adaptive Systolic Array with Integrated Accumulators
// Description:
//   Standardized clean top-level interface for physical FPGA implementation.
//   Total I/O: 342 pins (Fits within the 400 user I/O pins of xc7a200tfbg676-2).
//   Internal intermediate signals (mac, mode, per-PE accum) are maintained as
//   internal wires for hierarchical simulation visibility.
//////////////////////////////////////////////////////////////////////////////////

module systolic_array_4x4_accum_top (
    input clk,
    input reset,
    input enable,
    input clear,

    input signed [31:0] A0, input signed [31:0] A1,
    input signed [31:0] A2, input signed [31:0] A3,

    input signed [31:0] B0, input signed [31:0] B1,
    input signed [31:0] B2, input signed [31:0] B3,

    output signed [79:0] accum_systolic_sum,
    output valid_out,
    output overflow_flag
);

    // Internal intermediate signals (accessible hierarchically for testbench inspection)
    wire signed [63:0] mac00, mac01, mac02, mac03;
    wire signed [63:0] mac10, mac11, mac12, mac13;
    wire signed [63:0] mac20, mac21, mac22, mac23;
    wire signed [63:0] mac30, mac31, mac32, mac33;

    wire [1:0] mode00, mode01, mode02, mode03;
    wire [1:0] mode10, mode11, mode12, mode13;
    wire [1:0] mode20, mode21, mode22, mode23;
    wire [1:0] mode30, mode31, mode32, mode33;

    wire signed [67:0] systolic_sum;

    wire signed [79:0] accum_pe00, accum_pe01, accum_pe02, accum_pe03;
    wire signed [79:0] accum_pe10, accum_pe11, accum_pe12, accum_pe13;
    wire signed [79:0] accum_pe20, accum_pe21, accum_pe22, accum_pe23;
    wire signed [79:0] accum_pe30, accum_pe31, accum_pe32, accum_pe33;

    // Instantiate unmodified original 4x4 systolic array
    adaptive_systolic_array_4x4 u_sys_array (
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

    wire ovf_sum;
    wire [15:0] ovf_pe;
    wire val_sum;
    wire [15:0] val_pe;

    // 4-Channel Parallel Systolic Dot Product Sum (Diagonal PEs)
    wire signed [67:0] systolic_parallel_sum =
        {{4{mac00[63]}}, mac00} +
        {{4{mac11[63]}}, mac11} +
        {{4{mac22[63]}}, mac22} +
        {{4{mac33[63]}}, mac33};

    // Systolic sum temporal accumulator (68-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(
        .INPUT_WIDTH(68),
        .ACCUM_WIDTH(80)
    ) u_accum_sum (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .data_in(systolic_parallel_sum),
        .accum_out(accum_systolic_sum),
        .valid_out(val_sum),
        .overflow_flag(ovf_sum)
    );

    // 16 PE-Level Output-Stationary Accumulators (64-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe00 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac00), .accum_out(accum_pe00), .valid_out(val_pe[0]),  .overflow_flag(ovf_pe[0]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe01 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac01), .accum_out(accum_pe01), .valid_out(val_pe[1]),  .overflow_flag(ovf_pe[1]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe02 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac02), .accum_out(accum_pe02), .valid_out(val_pe[2]),  .overflow_flag(ovf_pe[2]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe03 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac03), .accum_out(accum_pe03), .valid_out(val_pe[3]),  .overflow_flag(ovf_pe[3]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe10 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac10), .accum_out(accum_pe10), .valid_out(val_pe[4]),  .overflow_flag(ovf_pe[4]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe11 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac11), .accum_out(accum_pe11), .valid_out(val_pe[5]),  .overflow_flag(ovf_pe[5]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe12 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac12), .accum_out(accum_pe12), .valid_out(val_pe[6]),  .overflow_flag(ovf_pe[6]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe13 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac13), .accum_out(accum_pe13), .valid_out(val_pe[7]),  .overflow_flag(ovf_pe[7]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe20 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac20), .accum_out(accum_pe20), .valid_out(val_pe[8]),  .overflow_flag(ovf_pe[8]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe21 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac21), .accum_out(accum_pe21), .valid_out(val_pe[9]),  .overflow_flag(ovf_pe[9]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe22 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac22), .accum_out(accum_pe22), .valid_out(val_pe[10]), .overflow_flag(ovf_pe[10]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe23 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac23), .accum_out(accum_pe23), .valid_out(val_pe[11]), .overflow_flag(ovf_pe[11]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe30 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac30), .accum_out(accum_pe30), .valid_out(val_pe[12]), .overflow_flag(ovf_pe[12]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe31 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac31), .accum_out(accum_pe31), .valid_out(val_pe[13]), .overflow_flag(ovf_pe[13]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe32 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac32), .accum_out(accum_pe32), .valid_out(val_pe[14]), .overflow_flag(ovf_pe[14]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe33 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(mac33), .accum_out(accum_pe33), .valid_out(val_pe[15]), .overflow_flag(ovf_pe[15]));

    assign valid_out     = val_sum;
    assign overflow_flag = ovf_sum | (|ovf_pe);

endmodule
