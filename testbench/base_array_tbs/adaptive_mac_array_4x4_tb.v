`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 19:41:21
// Design Name: 
// Module Name: adaptive_mac_array_4x4_tb
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

module adaptive_mac_array_4x4_tb;

/////////////////////////////////////////////////////////
// CLOCK RESET
/////////////////////////////////////////////////////////

reg clk;
reg reset;

/////////////////////////////////////////////////////////
// INPUTS
/////////////////////////////////////////////////////////

reg signed [31:0] A0,B0;
reg signed [31:0] A1,B1;
reg signed [31:0] A2,B2;
reg signed [31:0] A3,B3;

reg signed [31:0] A4,B4;
reg signed [31:0] A5,B5;
reg signed [31:0] A6,B6;
reg signed [31:0] A7,B7;

reg signed [31:0] A8,B8;
reg signed [31:0] A9,B9;
reg signed [31:0] A10,B10;
reg signed [31:0] A11,B11;

reg signed [31:0] A12,B12;
reg signed [31:0] A13,B13;
reg signed [31:0] A14,B14;
reg signed [31:0] A15,B15;

/////////////////////////////////////////////////////////
// OUTPUTS
/////////////////////////////////////////////////////////

wire [1:0] mode0,mode1,mode2,mode3;
wire [1:0] mode4,mode5,mode6,mode7;
wire [1:0] mode8,mode9,mode10,mode11;
wire [1:0] mode12,mode13,mode14,mode15;

wire signed [63:0] cla0,cla1,cla2,cla3;
wire signed [63:0] cla4,cla5,cla6,cla7;
wire signed [63:0] cla8,cla9,cla10,cla11;
wire signed [63:0] cla12,cla13,cla14,cla15;

wire signed [67:0] dot_product_out;

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////

adaptive_mac_array_4x4 uut(

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

    .mode0(mode0),
    .mode1(mode1),
    .mode2(mode2),
    .mode3(mode3),

    .mode4(mode4),
    .mode5(mode5),
    .mode6(mode6),
    .mode7(mode7),

    .mode8(mode8),
    .mode9(mode9),
    .mode10(mode10),
    .mode11(mode11),

    .mode12(mode12),
    .mode13(mode13),
    .mode14(mode14),
    .mode15(mode15),

    .cla0(cla0),
    .cla1(cla1),
    .cla2(cla2),
    .cla3(cla3),

    .cla4(cla4),
    .cla5(cla5),
    .cla6(cla6),
    .cla7(cla7),

    .cla8(cla8),
    .cla9(cla9),
    .cla10(cla10),
    .cla11(cla11),

    .cla12(cla12),
    .cla13(cla13),
    .cla14(cla14),
    .cla15(cla15),

    .dot_product_out(dot_product_out)

);

/////////////////////////////////////////////////////////
// CLOCK
/////////////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////

initial begin

    clk = 0;
    reset = 1;

    #20;
    reset = 0;

    /////////////////////////////////////////////////////
    // 1^2 + 2^2 + ... + 16^2
    /////////////////////////////////////////////////////

    A0=1;   B0=1;
    A1=2;   B1=2;
    A2=3;   B2=3;
    A3=4;   B3=4;

    A4=5;   B4=5;
    A5=6;   B5=6;
    A6=7;   B6=7;
    A7=8;   B7=8;

    A8=9;   B8=9;
    A9=10;  B9=10;
    A10=11; B10=11;
    A11=12; B11=12;

    A12=13; B12=13;
    A13=14; B13=14;
    A14=15; B14=15;
    A15=16; B15=16;

    #100;

    $display("");
    $display("====================================");
    $display(" 4x4 ARRAY REPORT ");
    $display("====================================");

    $display("DOT PRODUCT = %0d", dot_product_out);

    $display("====================================");

    $finish;

end

endmodule
