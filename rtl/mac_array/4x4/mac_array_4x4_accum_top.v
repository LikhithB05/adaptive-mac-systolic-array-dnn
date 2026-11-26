`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design: mac_array_4x4_accum_top
// Architecture: 4x4 Adaptive MAC Array with Integrated Dual-Mode Accumulators
// Description:
//   Standardized clean top-level interface for physical FPGA evaluation.
//   Total I/O: 1,110 pins (reduced from 3,514 pins by eliminating 2,404 internal debug pins).
//   Internal intermediate signals (cla, mode, per-PE accum) are maintained as
//   internal wires for hierarchical simulation visibility.
//////////////////////////////////////////////////////////////////////////////////

module mac_array_4x4_accum_top (
    input clk,
    input reset,
    input enable,
    input clear,

    input signed [31:0] A0,  input signed [31:0] B0,
    input signed [31:0] A1,  input signed [31:0] B1,
    input signed [31:0] A2,  input signed [31:0] B2,
    input signed [31:0] A3,  input signed [31:0] B3,
    input signed [31:0] A4,  input signed [31:0] B4,
    input signed [31:0] A5,  input signed [31:0] B5,
    input signed [31:0] A6,  input signed [31:0] B6,
    input signed [31:0] A7,  input signed [31:0] B7,
    input signed [31:0] A8,  input signed [31:0] B8,
    input signed [31:0] A9,  input signed [31:0] B9,
    input signed [31:0] A10, input signed [31:0] B10,
    input signed [31:0] A11, input signed [31:0] B11,
    input signed [31:0] A12, input signed [31:0] B12,
    input signed [31:0] A13, input signed [31:0] B13,
    input signed [31:0] A14, input signed [31:0] B14,
    input signed [31:0] A15, input signed [31:0] B15,

    output signed [79:0] accum_dot_product_out,
    output valid_out,
    output overflow_flag
);

    // Internal intermediate signals (accessible hierarchically for testbench inspection)
    wire [1:0] mode0,  mode1,  mode2,  mode3;
    wire [1:0] mode4,  mode5,  mode6,  mode7;
    wire [1:0] mode8,  mode9,  mode10, mode11;
    wire [1:0] mode12, mode13, mode14, mode15;

    wire signed [63:0] cla0,  cla1,  cla2,  cla3;
    wire signed [63:0] cla4,  cla5,  cla6,  cla7;
    wire signed [63:0] cla8,  cla9,  cla10, cla11;
    wire signed [63:0] cla12, cla13, cla14, cla15;

    wire signed [67:0] dot_product_out;

    wire signed [79:0] accum_pe0,  accum_pe1,  accum_pe2,  accum_pe3;
    wire signed [79:0] accum_pe4,  accum_pe5,  accum_pe6,  accum_pe7;
    wire signed [79:0] accum_pe8,  accum_pe9,  accum_pe10, accum_pe11;
    wire signed [79:0] accum_pe12, accum_pe13, accum_pe14, accum_pe15;

    // Instantiate unmodified original 4x4 array
    adaptive_mac_array_4x4 u_array (
        .clk(clk),
        .reset(reset),
        .A0(A0),   .B0(B0),
        .A1(A1),   .B1(B1),
        .A2(A2),   .B2(B2),
        .A3(A3),   .B3(B3),
        .A4(A4),   .B4(B4),
        .A5(A5),   .B5(B5),
        .A6(A6),   .B6(B6),
        .A7(A7),   .B7(B7),
        .A8(A8),   .B8(B8),
        .A9(A9),   .B9(B9),
        .A10(A10), .B10(B10),
        .A11(A11), .B11(B11),
        .A12(A12), .B12(B12),
        .A13(A13), .B13(B13),
        .A14(A14), .B14(B14),
        .A15(A15), .B15(B15),
        .mode0(mode0),   .mode1(mode1),   .mode2(mode2),   .mode3(mode3),
        .mode4(mode4),   .mode5(mode5),   .mode6(mode6),   .mode7(mode7),
        .mode8(mode8),   .mode9(mode9),   .mode10(mode10), .mode11(mode11),
        .mode12(mode12), .mode13(mode13), .mode14(mode14), .mode15(mode15),
        .cla0(cla0),   .cla1(cla1),   .cla2(cla2),   .cla3(cla3),
        .cla4(cla4),   .cla5(cla5),   .cla6(cla6),   .cla7(cla7),
        .cla8(cla8),   .cla9(cla9),   .cla10(cla10), .cla11(cla11),
        .cla12(cla12), .cla13(cla13), .cla14(cla14), .cla15(cla15),
        .dot_product_out(dot_product_out)
    );

    wire ovf_dp;
    wire [15:0] ovf_pe;
    wire val_dp;
    wire [15:0] val_pe;

    // Dot product temporal accumulator (68-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(
        .INPUT_WIDTH(68),
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

    // 16 Individual PE accumulators (64-bit input -> 80-bit accum)
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe0  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla0),  .accum_out(accum_pe0),  .valid_out(val_pe[0]),  .overflow_flag(ovf_pe[0]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe1  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla1),  .accum_out(accum_pe1),  .valid_out(val_pe[1]),  .overflow_flag(ovf_pe[1]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe2  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla2),  .accum_out(accum_pe2),  .valid_out(val_pe[2]),  .overflow_flag(ovf_pe[2]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe3  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla3),  .accum_out(accum_pe3),  .valid_out(val_pe[3]),  .overflow_flag(ovf_pe[3]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe4  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla4),  .accum_out(accum_pe4),  .valid_out(val_pe[4]),  .overflow_flag(ovf_pe[4]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe5  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla5),  .accum_out(accum_pe5),  .valid_out(val_pe[5]),  .overflow_flag(ovf_pe[5]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe6  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla6),  .accum_out(accum_pe6),  .valid_out(val_pe[6]),  .overflow_flag(ovf_pe[6]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe7  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla7),  .accum_out(accum_pe7),  .valid_out(val_pe[7]),  .overflow_flag(ovf_pe[7]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe8  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla8),  .accum_out(accum_pe8),  .valid_out(val_pe[8]),  .overflow_flag(ovf_pe[8]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe9  (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla9),  .accum_out(accum_pe9),  .valid_out(val_pe[9]),  .overflow_flag(ovf_pe[9]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe10 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla10), .accum_out(accum_pe10), .valid_out(val_pe[10]), .overflow_flag(ovf_pe[10]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe11 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla11), .accum_out(accum_pe11), .valid_out(val_pe[11]), .overflow_flag(ovf_pe[11]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe12 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla12), .accum_out(accum_pe12), .valid_out(val_pe[12]), .overflow_flag(ovf_pe[12]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe13 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla13), .accum_out(accum_pe13), .valid_out(val_pe[13]), .overflow_flag(ovf_pe[13]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe14 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla14), .accum_out(accum_pe14), .valid_out(val_pe[14]), .overflow_flag(ovf_pe[14]));
    adaptive_precision_accumulator #(.INPUT_WIDTH(64), .ACCUM_WIDTH(80)) u_accum_pe15 (.clk(clk), .reset(reset), .enable(enable), .clear(clear), .data_in(cla15), .accum_out(accum_pe15), .valid_out(val_pe[15]), .overflow_flag(ovf_pe[15]));

    assign valid_out     = val_dp;
    assign overflow_flag = ovf_dp | (|ovf_pe);

endmodule
