`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 11:18:12
// Design Name: 
// Module Name: adaptive_systolic_array_2x2
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

`timescale 1ns / 1ps

module adaptive_systolic_array_2x2(

    input clk,
    input reset,

    input signed [31:0] A0,
    input signed [31:0] A1,

    input signed [31:0] B0,
    input signed [31:0] B1,

    output signed [63:0] mac00,
    output signed [63:0] mac01,
    output signed [63:0] mac10,
    output signed [63:0] mac11,

    output [1:0] mode00,
    output [1:0] mode01,
    output [1:0] mode10,
    output [1:0] mode11,

    output signed [65:0] systolic_sum

);

/////////////////////////////////////////////////////////
// INTERNAL WIRES
/////////////////////////////////////////////////////////

wire signed [31:0] A00_to_A01;
wire signed [31:0] B00_to_B10;

wire signed [31:0] A10_to_A11;
wire signed [31:0] B01_to_B11;

/////////////////////////////////////////////////////////
// PE00
/////////////////////////////////////////////////////////

adaptive_processing_element PE00(

    .clk(clk),
    .reset(reset),

    .A_in(A0),
    .B_in(B0),

    .A_out(A00_to_A01),
    .B_out(B00_to_B10),

    .mac_out(mac00),
    .mode_out(mode00)

);

/////////////////////////////////////////////////////////
// PE01
/////////////////////////////////////////////////////////

adaptive_processing_element PE01(

    .clk(clk),
    .reset(reset),

    .A_in(A00_to_A01),
    .B_in(B1),

    .A_out(),
    .B_out(B01_to_B11),

    .mac_out(mac01),
    .mode_out(mode01)

);

/////////////////////////////////////////////////////////
// PE10
/////////////////////////////////////////////////////////

adaptive_processing_element PE10(

    .clk(clk),
    .reset(reset),

    .A_in(A1),
    .B_in(B00_to_B10),

    .A_out(A10_to_A11),
    .B_out(),

    .mac_out(mac10),
    .mode_out(mode10)

);

/////////////////////////////////////////////////////////
// PE11
/////////////////////////////////////////////////////////

adaptive_processing_element PE11(

    .clk(clk),
    .reset(reset),

    .A_in(A10_to_A11),
    .B_in(B01_to_B11),

    .A_out(),
    .B_out(),

    .mac_out(mac11),
    .mode_out(mode11)

);

/////////////////////////////////////////////////////////
// TOTAL SUM
/////////////////////////////////////////////////////////

assign systolic_sum =
        $signed({mac00[63],mac00}) +
        $signed({mac01[63],mac01}) +
        $signed({mac10[63],mac10}) +
        $signed({mac11[63],mac11});

endmodule