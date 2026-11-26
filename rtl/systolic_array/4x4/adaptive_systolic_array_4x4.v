`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 11:53:48
// Design Name: 
// Module Name: adaptive_systolic_array_4x4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module adaptive_systolic_array_4x4(
    input clk,
    input reset,

    input signed [31:0] A0,
    input signed [31:0] A1,
    input signed [31:0] A2,
    input signed [31:0] A3,

    input signed [31:0] B0,
    input signed [31:0] B1,
    input signed [31:0] B2,
    input signed [31:0] B3,

    output signed [63:0] mac00, mac01, mac02, mac03,
    output signed [63:0] mac10, mac11, mac12, mac13,
    output signed [63:0] mac20, mac21, mac22, mac23,
    output signed [63:0] mac30, mac31, mac32, mac33,

    output [1:0] mode00, mode01, mode02, mode03,
    output [1:0] mode10, mode11, mode12, mode13,
    output [1:0] mode20, mode21, mode22, mode23,
    output [1:0] mode30, mode31, mode32, mode33,

    output signed [67:0] systolic_sum
);

//////////////////////////////////////////////////////
// INTERNAL A WIRES (horizontal propagation)
//////////////////////////////////////////////////////

wire signed [31:0] A00_out, A01_out, A02_out, A03_out;
wire signed [31:0] A10_out, A11_out, A12_out, A13_out;
wire signed [31:0] A20_out, A21_out, A22_out, A23_out;
wire signed [31:0] A30_out, A31_out, A32_out, A33_out;

//////////////////////////////////////////////////////
// INTERNAL B WIRES (vertical propagation)
//////////////////////////////////////////////////////

wire signed [31:0] B00_out, B01_out, B02_out, B03_out;
wire signed [31:0] B10_out, B11_out, B12_out, B13_out;
wire signed [31:0] B20_out, B21_out, B22_out, B23_out;
wire signed [31:0] B30_out, B31_out, B32_out, B33_out;

//////////////////////////////////////////////////////
// ROW 0
//////////////////////////////////////////////////////

adaptive_processing_element PE00(
    .clk(clk), .reset(reset),
    .A_in(A0), .B_in(B0),
    .A_out(A00_out), .B_out(B00_out),
    .mac_out(mac00), .mode_out(mode00)
);

adaptive_processing_element PE01(
    .clk(clk), .reset(reset),
    .A_in(A00_out), .B_in(B1),
    .A_out(A01_out), .B_out(B01_out),
    .mac_out(mac01), .mode_out(mode01)
);

adaptive_processing_element PE02(
    .clk(clk), .reset(reset),
    .A_in(A01_out), .B_in(B2),
    .A_out(A02_out), .B_out(B02_out),
    .mac_out(mac02), .mode_out(mode02)
);

adaptive_processing_element PE03(
    .clk(clk), .reset(reset),
    .A_in(A02_out), .B_in(B3),
    .A_out(A03_out), .B_out(B03_out),
    .mac_out(mac03), .mode_out(mode03)
);

//////////////////////////////////////////////////////
// ROW 1
//////////////////////////////////////////////////////

adaptive_processing_element PE10(
    .clk(clk), .reset(reset),
    .A_in(A1), .B_in(B00_out),
    .A_out(A10_out), .B_out(B10_out),
    .mac_out(mac10), .mode_out(mode10)
);

adaptive_processing_element PE11(
    .clk(clk), .reset(reset),
    .A_in(A10_out), .B_in(B01_out),
    .A_out(A11_out), .B_out(B11_out),
    .mac_out(mac11), .mode_out(mode11)
);

adaptive_processing_element PE12(
    .clk(clk), .reset(reset),
    .A_in(A11_out), .B_in(B02_out),
    .A_out(A12_out), .B_out(B12_out),
    .mac_out(mac12), .mode_out(mode12)
);

adaptive_processing_element PE13(
    .clk(clk), .reset(reset),
    .A_in(A12_out), .B_in(B03_out),
    .A_out(A13_out), .B_out(B13_out),
    .mac_out(mac13), .mode_out(mode13)
);

//////////////////////////////////////////////////////
// ROW 2
//////////////////////////////////////////////////////

adaptive_processing_element PE20(
    .clk(clk), .reset(reset),
    .A_in(A2), .B_in(B10_out),
    .A_out(A20_out), .B_out(B20_out),
    .mac_out(mac20), .mode_out(mode20)
);

adaptive_processing_element PE21(
    .clk(clk), .reset(reset),
    .A_in(A20_out), .B_in(B11_out),
    .A_out(A21_out), .B_out(B21_out),
    .mac_out(mac21), .mode_out(mode21)
);

adaptive_processing_element PE22(
    .clk(clk), .reset(reset),
    .A_in(A21_out), .B_in(B12_out),
    .A_out(A22_out), .B_out(B22_out),
    .mac_out(mac22), .mode_out(mode22)
);

adaptive_processing_element PE23(
    .clk(clk), .reset(reset),
    .A_in(A22_out), .B_in(B13_out),
    .A_out(A23_out), .B_out(B23_out),
    .mac_out(mac23), .mode_out(mode23)
);

//////////////////////////////////////////////////////
// ROW 3
//////////////////////////////////////////////////////

adaptive_processing_element PE30(
    .clk(clk), .reset(reset),
    .A_in(A3), .B_in(B20_out),
    .A_out(A30_out), .B_out(B30_out),
    .mac_out(mac30), .mode_out(mode30)
);

adaptive_processing_element PE31(
    .clk(clk), .reset(reset),
    .A_in(A30_out), .B_in(B21_out),
    .A_out(A31_out), .B_out(B31_out),
    .mac_out(mac31), .mode_out(mode31)
);

adaptive_processing_element PE32(
    .clk(clk), .reset(reset),
    .A_in(A31_out), .B_in(B22_out),
    .A_out(A32_out), .B_out(B32_out),
    .mac_out(mac32), .mode_out(mode32)
);

adaptive_processing_element PE33(
    .clk(clk), .reset(reset),
    .A_in(A32_out), .B_in(B23_out),
    .A_out(A33_out), .B_out(B33_out),
    .mac_out(mac33), .mode_out(mode33)
);

//////////////////////////////////////////////////////
// SYSTOLIC SUM (sign-extended to 68 bits)
//////////////////////////////////////////////////////

assign systolic_sum =
    {{4{mac00[63]}}, mac00} +
    {{4{mac01[63]}}, mac01} +
    {{4{mac02[63]}}, mac02} +
    {{4{mac03[63]}}, mac03} +
    {{4{mac10[63]}}, mac10} +
    {{4{mac11[63]}}, mac11} +
    {{4{mac12[63]}}, mac12} +
    {{4{mac13[63]}}, mac13} +
    {{4{mac20[63]}}, mac20} +
    {{4{mac21[63]}}, mac21} +
    {{4{mac22[63]}}, mac22} +
    {{4{mac23[63]}}, mac23} +
    {{4{mac30[63]}}, mac30} +
    {{4{mac31[63]}}, mac31} +
    {{4{mac32[63]}}, mac32} +
    {{4{mac33[63]}}, mac33};

endmodule