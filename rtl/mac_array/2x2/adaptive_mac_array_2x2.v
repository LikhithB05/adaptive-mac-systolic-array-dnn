`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2026 16:51:08
// Design Name: 
// Module Name: adaptive_mac_array_2x2
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


module adaptive_mac_array_2x2(

    input clk,
    input reset,

    input signed [31:0] A0,
    input signed [31:0] B0,

    input signed [31:0] A1,
    input signed [31:0] B1,

    input signed [31:0] A2,
    input signed [31:0] B2,

    input signed [31:0] A3,
    input signed [31:0] B3,

    output [1:0] mode0,
    output [1:0] mode1,
    output [1:0] mode2,
    output [1:0] mode3,

    output signed [63:0] cla0,
    output signed [63:0] cla1,
    output signed [63:0] cla2,
    output signed [63:0] cla3,

    output signed [65:0] dot_product_out

);

//////////////////////////////////////////////////////
// MAC 0
//////////////////////////////////////////////////////

adaptive_mac_top MAC0(

    .clk(clk),
    .reset(reset),

    .A(A0),
    .B(B0),

    .mode_out(mode0),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla0),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);

//////////////////////////////////////////////////////
// MAC 1
//////////////////////////////////////////////////////

adaptive_mac_top MAC1(

    .clk(clk),
    .reset(reset),

    .A(A1),
    .B(B1),

    .mode_out(mode1),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla1),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);

//////////////////////////////////////////////////////
// MAC 2
//////////////////////////////////////////////////////

adaptive_mac_top MAC2(

    .clk(clk),
    .reset(reset),

    .A(A2),
    .B(B2),

    .mode_out(mode2),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla2),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);

//////////////////////////////////////////////////////
// MAC 3
//////////////////////////////////////////////////////

adaptive_mac_top MAC3(

    .clk(clk),
    .reset(reset),

    .A(A3),
    .B(B3),

    .mode_out(mode3),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla3),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);

//////////////////////////////////////////////////////
// DOT PRODUCT
//////////////////////////////////////////////////////

assign dot_product_out =
        $signed({cla0[63],cla0}) +
        $signed({cla1[63],cla1}) +
        $signed({cla2[63],cla2}) +
        $signed({cla3[63],cla3});

endmodule
