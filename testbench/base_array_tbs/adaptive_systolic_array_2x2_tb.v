`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 11:19:26
// Design Name: 
// Module Name: adaptive_systolic_array_2x2_tb
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

module adaptive_systolic_array_2x2_tb;

/////////////////////////////////////////////////////////
// CLOCK RESET
/////////////////////////////////////////////////////////

reg clk;
reg reset;

/////////////////////////////////////////////////////////
// INPUTS
/////////////////////////////////////////////////////////

reg signed [31:0] A0;
reg signed [31:0] A1;

reg signed [31:0] B0;
reg signed [31:0] B1;

/////////////////////////////////////////////////////////
// OUTPUTS
/////////////////////////////////////////////////////////

wire signed [63:0] mac00;
wire signed [63:0] mac01;
wire signed [63:0] mac10;
wire signed [63:0] mac11;

wire [1:0] mode00;
wire [1:0] mode01;
wire [1:0] mode10;
wire [1:0] mode11;

wire signed [65:0] systolic_sum;

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////

adaptive_systolic_array_2x2 uut(

    .clk(clk),
    .reset(reset),

    .A0(A0),
    .A1(A1),

    .B0(B0),
    .B1(B1),

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

/////////////////////////////////////////////////////////
// CLOCK
/////////////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////

initial begin

    clk   = 0;
    reset = 1;

    A0 = 0;
    A1 = 0;

    B0 = 0;
    B1 = 0;

    #20;

    reset = 0;

    /////////////////////////////////////////////////////
    // TEST VECTOR
    /////////////////////////////////////////////////////

    A0 = 10;
    A1 = 20;

    B0 = 2;
    B1 = 3;

    /////////////////////////////////////////////////////
    // WAIT FOR DATA TO FLOW
    /////////////////////////////////////////////////////

    #100;

    $display("");
    $display("================================");
    $display("2x2 SYSTOLIC ARRAY REPORT");
    $display("================================");

    $display("PE00 = %0d", mac00);
    $display("PE01 = %0d", mac01);
    $display("PE10 = %0d", mac10);
    $display("PE11 = %0d", mac11);

    $display("--------------------------------");

    $display("TOTAL = %0d", systolic_sum);

    $display("================================");

    $finish;

end

/////////////////////////////////////////////////////////
// MONITOR
/////////////////////////////////////////////////////////

initial begin

    $monitor(
    "t=%0t | PE00=%0d PE01=%0d PE10=%0d PE11=%0d | SUM=%0d",
    $time,
    mac00,
    mac01,
    mac10,
    mac11,
    systolic_sum
    );

end

endmodule