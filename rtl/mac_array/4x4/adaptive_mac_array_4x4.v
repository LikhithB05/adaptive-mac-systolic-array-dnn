`timescale 1ns / 1ps

module adaptive_mac_array_4x4(

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
    input signed [31:0] A4,
    input signed [31:0] B4,
    input signed [31:0] A5,
    input signed [31:0] B5,
    input signed [31:0] A6,
    input signed [31:0] B6,
    input signed [31:0] A7,
    input signed [31:0] B7,
    input signed [31:0] A8,
    input signed [31:0] B8,
    input signed [31:0] A9,
    input signed [31:0] B9,
    input signed [31:0] A10,
    input signed [31:0] B10,
    input signed [31:0] A11,
    input signed [31:0] B11,
    input signed [31:0] A12,
    input signed [31:0] B12,
    input signed [31:0] A13,
    input signed [31:0] B13,
    input signed [31:0] A14,
    input signed [31:0] B14,
    input signed [31:0] A15,
    input signed [31:0] B15,

    output [1:0] mode0,
    output [1:0] mode1,
    output [1:0] mode2,
    output [1:0] mode3,
    output [1:0] mode4,
    output [1:0] mode5,
    output [1:0] mode6,
    output [1:0] mode7,
    output [1:0] mode8,
    output [1:0] mode9,
    output [1:0] mode10,
    output [1:0] mode11,
    output [1:0] mode12,
    output [1:0] mode13,
    output [1:0] mode14,
    output [1:0] mode15,

    output signed [63:0] cla0,
    output signed [63:0] cla1,
    output signed [63:0] cla2,
    output signed [63:0] cla3,
    output signed [63:0] cla4,
    output signed [63:0] cla5,
    output signed [63:0] cla6,
    output signed [63:0] cla7,
    output signed [63:0] cla8,
    output signed [63:0] cla9,
    output signed [63:0] cla10,
    output signed [63:0] cla11,
    output signed [63:0] cla12,
    output signed [63:0] cla13,
    output signed [63:0] cla14,
    output signed [63:0] cla15,

    output signed [67:0] dot_product_out

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
// MAC 4
//////////////////////////////////////////////////////

adaptive_mac_top MAC4(

    .clk(clk),
    .reset(reset),

    .A(A4),
    .B(B4),

    .mode_out(mode4),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla4),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 5
//////////////////////////////////////////////////////

adaptive_mac_top MAC5(

    .clk(clk),
    .reset(reset),

    .A(A5),
    .B(B5),

    .mode_out(mode5),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla5),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 6
//////////////////////////////////////////////////////

adaptive_mac_top MAC6(

    .clk(clk),
    .reset(reset),

    .A(A6),
    .B(B6),

    .mode_out(mode6),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla6),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 7
//////////////////////////////////////////////////////

adaptive_mac_top MAC7(

    .clk(clk),
    .reset(reset),

    .A(A7),
    .B(B7),

    .mode_out(mode7),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla7),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 8
//////////////////////////////////////////////////////

adaptive_mac_top MAC8(

    .clk(clk),
    .reset(reset),

    .A(A8),
    .B(B8),

    .mode_out(mode8),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla8),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 9
//////////////////////////////////////////////////////

adaptive_mac_top MAC9(

    .clk(clk),
    .reset(reset),

    .A(A9),
    .B(B9),

    .mode_out(mode9),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla9),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 10
//////////////////////////////////////////////////////

adaptive_mac_top MAC10(

    .clk(clk),
    .reset(reset),

    .A(A10),
    .B(B10),

    .mode_out(mode10),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla10),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 11
//////////////////////////////////////////////////////

adaptive_mac_top MAC11(

    .clk(clk),
    .reset(reset),

    .A(A11),
    .B(B11),

    .mode_out(mode11),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla11),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 12
//////////////////////////////////////////////////////

adaptive_mac_top MAC12(

    .clk(clk),
    .reset(reset),

    .A(A12),
    .B(B12),

    .mode_out(mode12),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla12),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 13
//////////////////////////////////////////////////////

adaptive_mac_top MAC13(

    .clk(clk),
    .reset(reset),

    .A(A13),
    .B(B13),

    .mode_out(mode13),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla13),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 14
//////////////////////////////////////////////////////

adaptive_mac_top MAC14(

    .clk(clk),
    .reset(reset),

    .A(A14),
    .B(B14),

    .mode_out(mode14),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla14),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);


//////////////////////////////////////////////////////
// MAC 15
//////////////////////////////////////////////////////

adaptive_mac_top MAC15(

    .clk(clk),
    .reset(reset),

    .A(A15),
    .B(B15),

    .mode_out(mode15),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(cla15),

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
        $signed({cla3[63],cla3}) +
        $signed({cla4[63],cla4}) +
        $signed({cla5[63],cla5}) +
        $signed({cla6[63],cla6}) +
        $signed({cla7[63],cla7}) +
        $signed({cla8[63],cla8}) +
        $signed({cla9[63],cla9}) +
        $signed({cla10[63],cla10}) +
        $signed({cla11[63],cla11}) +
        $signed({cla12[63],cla12}) +
        $signed({cla13[63],cla13}) +
        $signed({cla14[63],cla14}) +
        $signed({cla15[63],cla15});

endmodule
