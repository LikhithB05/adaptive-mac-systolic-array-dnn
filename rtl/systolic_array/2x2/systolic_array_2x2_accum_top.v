`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design: systolic_array_2x2_accum_top
// Architecture: 2x2 Adaptive Systolic Array with Integrated Accumulators
// Description:
//   Standardized clean top-level interface for physical FPGA implementation.
//   Total I/O: 214 pins (Fits within the 400 user I/O pins of xc7a200tfbg676-2).
//   Internal intermediate signals (mac, mode, per-PE accum) are maintained as
//   internal wires for hierarchical simulation visibility.
//////////////////////////////////////////////////////////////////////////////////

module systolic_array_2x2_accum_top (
    input clk,
    input reset,
    input enable,
    input clear,

    input signed [31:0] A0,
    input signed [31:0] A1,
    input signed [31:0] B0,
    input signed [31:0] B1,

    output signed [79:0] accum_systolic_sum,
    output valid_out,
    output overflow_flag
);

    // Internal intermediate signals (accessible hierarchically for testbench inspection)
    wire signed [63:0] mac00, mac01, mac10, mac11;
    wire [1:0] mode00, mode01, mode10, mode11;
    wire signed [65:0] systolic_sum;
    wire signed [79:0] accum_pe00, accum_pe01, accum_pe10, accum_pe11;

    // Instantiate unmodified original 2x2 systolic array
    adaptive_systolic_array_2x2 u_sys_array (
        .clk(clk),
        .reset(reset),
        .A0(A0), .A1(A1),
        .B0(B0), .B1(B1),
        .mac00(mac00),
        .mac01(mac01),
        .mac10(mac10),
        .mac11(mac11),
        .mode00(mode00),
        .mode01(mode01),
        .mode10(mode10),
        .mode11(mode11),
        .systolic_sum(systolic_sum)
    );

    wire ovf_sum, ovf_00, ovf_01, ovf_10, ovf_11;
    wire val_sum, val_00, val_01, val_10, val_11;

    // 2-Channel Parallel Systolic Dot Product Sum (Diagonal PEs)
    wire signed [65:0] systolic_parallel_sum =
        {{2{mac00[63]}}, mac00} +
        {{2{mac11[63]}}, mac11};

    // Systolic sum temporal accumulator (66-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(
        .INPUT_WIDTH(66),
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

    // Individual PE accumulators (64-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe00 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(mac00), .accum_out(accum_pe00), .valid_out(val_00), .overflow_flag(ovf_00)
    );

    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe01 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(mac01), .accum_out(accum_pe01), .valid_out(val_01), .overflow_flag(ovf_01)
    );

    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe10 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(mac10), .accum_out(accum_pe10), .valid_out(val_10), .overflow_flag(ovf_10)
    );

    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe11 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(mac11), .accum_out(accum_pe11), .valid_out(val_11), .overflow_flag(ovf_11)
    );

    assign valid_out     = val_sum;
    assign overflow_flag = ovf_sum | ovf_00 | ovf_01 | ovf_10 | ovf_11;

endmodule
