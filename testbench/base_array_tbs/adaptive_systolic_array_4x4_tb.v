`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 12:03:40
// Design Name: 
// Module Name: adaptive_systolic_array_4x4_tb
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

module adaptive_systolic_array_4x4_tb;

/////////////////////////////////////////////////////////
// CLOCK RESET
/////////////////////////////////////////////////////////

reg clk;
reg reset;

/////////////////////////////////////////////////////////
// INPUTS
/////////////////////////////////////////////////////////

reg signed [31:0] A0,A1,A2,A3;
reg signed [31:0] B0,B1,B2,B3;

/////////////////////////////////////////////////////////
// OUTPUTS
/////////////////////////////////////////////////////////

wire signed [63:0] mac00,mac01,mac02,mac03;
wire signed [63:0] mac10,mac11,mac12,mac13;
wire signed [63:0] mac20,mac21,mac22,mac23;
wire signed [63:0] mac30,mac31,mac32,mac33;

wire [1:0] mode00,mode01,mode02,mode03;
wire [1:0] mode10,mode11,mode12,mode13;
wire [1:0] mode20,mode21,mode22,mode23;
wire [1:0] mode30,mode31,mode32,mode33;

wire signed [67:0] systolic_sum;

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////

adaptive_systolic_array_4x4 uut(

    .clk(clk),
    .reset(reset),

    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),

    .B0(B0),
    .B1(B1),
    .B2(B2),
    .B3(B3),

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

/////////////////////////////////////////////////////////
// CLOCK
/////////////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////////////
// STIMULUS
/////////////////////////////////////////////////////////

initial begin

    clk = 0;
    reset = 1;

    A0=0; A1=0; A2=0; A3=0;
    B0=0; B1=0; B2=0; B3=0;

    #20;

    reset = 0;

    /////////////////////////////////////////////////////
    // TEST VECTOR
    /////////////////////////////////////////////////////

    A0 = 1;
    A1 = 2;
    A2 = 3;
    A3 = 4;

    B0 = 1;
    B1 = 2;
    B2 = 3;
    B3 = 4;

    /////////////////////////////////////////////////////

    #150;

    $display("");
    $display("=================================");
    $display("4x4 SYSTOLIC ARRAY REPORT");
    $display("=================================");

    $display("mac00=%0d",mac00);
    $display("mac01=%0d",mac01);
    $display("mac02=%0d",mac02);
    $display("mac03=%0d",mac03);

    $display("mac10=%0d",mac10);
    $display("mac11=%0d",mac11);
    $display("mac12=%0d",mac12);
    $display("mac13=%0d",mac13);

    $display("mac20=%0d",mac20);
    $display("mac21=%0d",mac21);
    $display("mac22=%0d",mac22);
    $display("mac23=%0d",mac23);

    $display("mac30=%0d",mac30);
    $display("mac31=%0d",mac31);
    $display("mac32=%0d",mac32);
    $display("mac33=%0d",mac33);

    $display("---------------------------------");

    $display("TOTAL SUM = %0d",systolic_sum);

    $display("=================================");

    $finish;

end

endmodule
