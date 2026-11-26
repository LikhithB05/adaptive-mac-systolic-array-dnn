`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2026 16:52:12
// Design Name: 
// Module Name: adaptive_mac_array_tb
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


module adaptive_mac_array_tb;

reg clk;
reg reset;

reg signed [31:0] A0,B0;
reg signed [31:0] A1,B1;
reg signed [31:0] A2,B2;
reg signed [31:0] A3,B3;

wire [1:0] mode0;
wire [1:0] mode1;
wire [1:0] mode2;
wire [1:0] mode3;

wire signed [63:0] cla0;
wire signed [63:0] cla1;
wire signed [63:0] cla2;
wire signed [63:0] cla3;

wire signed [65:0] dot_product_out;

adaptive_mac_array_2x2 uut(

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

always #5 clk = ~clk;

initial begin

    clk=0;
    reset=1;

    #20;
    reset=0;

    //////////////////////////////////////
    // TEST VECTOR 1
    //////////////////////////////////////

    A0=10; B0=2;
    A1=20; B1=3;
    A2=30; B2=4;
    A3=40; B3=5;

    #20;

    //////////////////////////////////////
    // TEST VECTOR 2
    //////////////////////////////////////

    A0=100; B0=10;
    A1=200; B1=20;
    A2=300; B2=30;
    A3=400; B3=40;

    #20;

    #100;

    $finish;

end

initial begin

$monitor(
"t=%0t DP=%0d M0=%b M1=%b M2=%b M3=%b",
$time,
dot_product_out,
mode0,
mode1,
mode2,
mode3
);

end

endmodule