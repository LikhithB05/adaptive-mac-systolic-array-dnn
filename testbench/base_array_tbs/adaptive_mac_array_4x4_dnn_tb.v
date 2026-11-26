`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2026 20:17:05
// Design Name: 
// Module Name: adaptive_mac_array_4x4_dnn_tb
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

module adaptive_mac_array_4x4_dnn_tb;

/////////////////////////////////////////////////////////
// CLOCK RESET
/////////////////////////////////////////////////////////

reg clk;
reg reset;

/////////////////////////////////////////////////////////
// INPUTS
/////////////////////////////////////////////////////////

reg signed [31:0] A0,A1,A2,A3,A4,A5,A6,A7;
reg signed [31:0] A8,A9,A10,A11,A12,A13,A14,A15;

reg signed [31:0] B0,B1,B2,B3,B4,B5,B6,B7;
reg signed [31:0] B8,B9,B10,B11,B12,B13,B14,B15;

/////////////////////////////////////////////////////////
// MEMORIES
/////////////////////////////////////////////////////////

reg [31:0] activations [0:783];
reg [31:0] weights     [0:783];

integer i;

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
// STATISTICS
/////////////////////////////////////////////////////////

integer mode8_count;
integer mode16_count;
integer mode32_count;

integer total_batches;

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

    .mode0(mode0), .mode1(mode1),
    .mode2(mode2), .mode3(mode3),

    .mode4(mode4), .mode5(mode5),
    .mode6(mode6), .mode7(mode7),

    .mode8(mode8), .mode9(mode9),
    .mode10(mode10), .mode11(mode11),

    .mode12(mode12), .mode13(mode13),
    .mode14(mode14), .mode15(mode15),

    .cla0(cla0), .cla1(cla1),
    .cla2(cla2), .cla3(cla3),

    .cla4(cla4), .cla5(cla5),
    .cla6(cla6), .cla7(cla7),

    .cla8(cla8), .cla9(cla9),
    .cla10(cla10), .cla11(cla11),

    .cla12(cla12), .cla13(cla13),
    .cla14(cla14), .cla15(cla15),

    .dot_product_out(dot_product_out)

);

/////////////////////////////////////////////////////////
// CLOCK
/////////////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////////////
// LOAD MEM FILES
/////////////////////////////////////////////////////////

initial begin
    $readmemh("activations.mem", activations);
    $readmemh("weights.mem", weights);
end

/////////////////////////////////////////////////////////
// MODE COUNTER TASK
/////////////////////////////////////////////////////////

task count_mode;
input [1:0] mode;
begin
    case(mode)
        2'b00: mode8_count  = mode8_count + 1;
        2'b01: mode16_count = mode16_count + 1;
        2'b10: mode32_count = mode32_count + 1;
    endcase
end
endtask

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////

initial begin

    clk = 0;
    reset = 1;

    mode8_count  = 0;
    mode16_count = 0;
    mode32_count = 0;
    total_batches = 0;

    #20;
    reset = 0;

    /////////////////////////////////////////////////////
    // FEED 16 VALUES PER CYCLE
    /////////////////////////////////////////////////////

    for(i=0;i<784;i=i+16)
    begin

        A0  = $signed(activations[i+0]);
        B0  = $signed(weights[i+0]);

        A1  = $signed(activations[i+1]);
        B1  = $signed(weights[i+1]);

        A2  = $signed(activations[i+2]);
        B2  = $signed(weights[i+2]);

        A3  = $signed(activations[i+3]);
        B3  = $signed(weights[i+3]);

        A4  = $signed(activations[i+4]);
        B4  = $signed(weights[i+4]);

        A5  = $signed(activations[i+5]);
        B5  = $signed(weights[i+5]);

        A6  = $signed(activations[i+6]);
        B6  = $signed(weights[i+6]);

        A7  = $signed(activations[i+7]);
        B7  = $signed(weights[i+7]);

        A8  = $signed(activations[i+8]);
        B8  = $signed(weights[i+8]);

        A9  = $signed(activations[i+9]);
        B9  = $signed(weights[i+9]);

        A10 = $signed(activations[i+10]);
        B10 = $signed(weights[i+10]);

        A11 = $signed(activations[i+11]);
        B11 = $signed(weights[i+11]);

        A12 = $signed(activations[i+12]);
        B12 = $signed(weights[i+12]);

        A13 = $signed(activations[i+13]);
        B13 = $signed(weights[i+13]);

        A14 = $signed(activations[i+14]);
        B14 = $signed(weights[i+14]);

        A15 = $signed(activations[i+15]);
        B15 = $signed(weights[i+15]);

        #1;

        count_mode(mode0);
        count_mode(mode1);
        count_mode(mode2);
        count_mode(mode3);

        count_mode(mode4);
        count_mode(mode5);
        count_mode(mode6);
        count_mode(mode7);

        count_mode(mode8);
        count_mode(mode9);
        count_mode(mode10);
        count_mode(mode11);

        count_mode(mode12);
        count_mode(mode13);
        count_mode(mode14);
        count_mode(mode15);

        total_batches = total_batches + 1;

        #19;

    end

    #100;

    $display("");
    $display("====================================");
    $display("4x4 DNN REPORT");
    $display("====================================");

    $display("Total Batches = %0d", total_batches);

    $display("8-bit Ops     = %0d", mode8_count);
    $display("16-bit Ops    = %0d", mode16_count);
    $display("32-bit Ops    = %0d", mode32_count);

    $display("------------------------------------");

    $display("Total Ops     = %0d",
        mode8_count +
        mode16_count +
        mode32_count);

    $display("------------------------------------");

    $display("Final Dot Product = %0d",
        dot_product_out);

    $display("====================================");

    $finish;

end

endmodule