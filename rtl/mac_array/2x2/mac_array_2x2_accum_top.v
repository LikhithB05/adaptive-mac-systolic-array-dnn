`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design: mac_array_2x2_accum_top
// Architecture: 2x2 Adaptive MAC Array with Integrated Dual-Mode Accumulators
// Description:
//   Standardized clean top-level interface for physical FPGA implementation.
//   Total I/O: 342 pins (Fits within the 400 user I/O pins of xc7a200tfbg676-2).
//   Internal intermediate signals (cla, mode, per-PE accum) are maintained as
//   internal wires for hierarchical simulation visibility.
//////////////////////////////////////////////////////////////////////////////////

module mac_array_2x2_accum_top (
    input clk,
    input reset,
    input enable,
    input clear,

    input signed [31:0] A0, input signed [31:0] B0,
    input signed [31:0] A1, input signed [31:0] B1,
    input signed [31:0] A2, input signed [31:0] B2,
    input signed [31:0] A3, input signed [31:0] B3,

    output signed [79:0] accum_dot_product_out,
    output valid_out,
    output overflow_flag
);

    // Internal intermediate signals (accessible hierarchically for testbench inspection)
    wire [1:0] mode0, mode1, mode2, mode3;
    wire signed [63:0] cla0, cla1, cla2, cla3;
    wire signed [65:0] dot_product_out;
    wire signed [79:0] accum_pe0, accum_pe1, accum_pe2, accum_pe3;

    // Instantiate unmodified original 2x2 array
    adaptive_mac_array_2x2 u_array (
        .clk(clk),
        .reset(reset),
        .A0(A0), .B0(B0),
        .A1(A1), .B1(B1),
        .A2(A2), .B2(B2),
        .A3(A3), .B3(B3),
        .mode0(mode0),
        .mode1(mode1),
        .mode2(mode2),
        .mode3(mode3),
        .cla0(cla0),
        .cla1(cla1),
        .cla2(cla2),
        .cla3(cla3),
        .dot_product_out(dot_product_out)
    );

    wire ovf_dp, ovf_0, ovf_1, ovf_2, ovf_3;
    wire val_dp, val_0, val_1, val_2, val_3;

    // Dot product temporal accumulator (66-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(
        .INPUT_WIDTH(66),
        .ACCUM_WIDTH(80)
    ) u_accum_dp (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .data_in(dot_product_out),
        .accum_out(accum_dot_product_out),
        .valid_out(val_dp),
        .overflow_flag(ovf_dp)
    );

    // Individual PE accumulators (64-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe0 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(cla0), .accum_out(accum_pe0), .valid_out(val_0), .overflow_flag(ovf_0)
    );

    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe1 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(cla1), .accum_out(accum_pe1), .valid_out(val_1), .overflow_flag(ovf_1)
    );

    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe2 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(cla2), .accum_out(accum_pe2), .valid_out(val_2), .overflow_flag(ovf_2)
    );

    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe3 (
        .clk(clk), .reset(reset), .enable(enable), .clear(clear),
        .data_in(cla3), .accum_out(accum_pe3), .valid_out(val_3), .overflow_flag(ovf_3)
    );

    assign valid_out     = val_dp;
    assign overflow_flag = ovf_dp | ovf_0 | ovf_1 | ovf_2 | ovf_3;

endmodule
