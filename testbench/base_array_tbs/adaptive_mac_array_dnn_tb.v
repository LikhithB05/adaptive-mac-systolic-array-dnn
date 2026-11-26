`timescale 1ns / 1ps

module adaptive_mac_array_dnn_tb;

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

/////////////////////////////////////////////////////////
// MEMORY
/////////////////////////////////////////////////////////

reg [31:0] activations [0:783];
reg [31:0] weights     [0:783];

integer i;

/////////////////////////////////////////////////////////
// OUTPUTS
/////////////////////////////////////////////////////////

wire [1:0] mode0;
wire [1:0] mode1;
wire [1:0] mode2;
wire [1:0] mode3;

wire signed [63:0] cla0;
wire signed [63:0] cla1;
wire signed [63:0] cla2;
wire signed [63:0] cla3;

wire signed [65:0] dot_product_out;

/////////////////////////////////////////////////////////
// STATISTICS COUNTERS
/////////////////////////////////////////////////////////

integer mode8_count;
integer mode16_count;
integer mode32_count;

integer add8;
integer add16;
integer add32;

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////

adaptive_mac_array_2x2 uut(

    .clk(clk),
    .reset(reset),

    .A0(A0),
    .B0(B0),

    .A1(A1),
    .B1(B1),

    .A2(A2),
    .B2(B2),

    .A3(A3),
    .B3(B3),

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
// ACCURATE MODE COUNTER
/////////////////////////////////////////////////////////

always @(posedge clk)
begin

    if(!reset)
    begin

        add8  = 0;
        add16 = 0;
        add32 = 0;

        case(mode0)
            2'b00: add8  = add8  + 1;
            2'b01: add16 = add16 + 1;
            2'b10: add32 = add32 + 1;
        endcase

        case(mode1)
            2'b00: add8  = add8  + 1;
            2'b01: add16 = add16 + 1;
            2'b10: add32 = add32 + 1;
        endcase

        case(mode2)
            2'b00: add8  = add8  + 1;
            2'b01: add16 = add16 + 1;
            2'b10: add32 = add32 + 1;
        endcase

        case(mode3)
            2'b00: add8  = add8  + 1;
            2'b01: add16 = add16 + 1;
            2'b10: add32 = add32 + 1;
        endcase

        mode8_count  = mode8_count  + add8;
        mode16_count = mode16_count + add16;
        mode32_count = mode32_count + add32;

    end

end

/////////////////////////////////////////////////////////
// STIMULUS
/////////////////////////////////////////////////////////

initial begin

    clk = 0;

    reset = 1;

    A0 = 0; B0 = 0;
    A1 = 0; B1 = 0;
    A2 = 0; B2 = 0;
    A3 = 0; B3 = 0;

    mode8_count  = 0;
    mode16_count = 0;
    mode32_count = 0;

    #20;
    reset = 0;

    /////////////////////////////////////////////////////
    // REAL DNN WORKLOAD
    /////////////////////////////////////////////////////

    for(i = 0; i < 784; i = i + 4)
    begin

        A0 = $signed(activations[i]);
        B0 = $signed(weights[i]);

        A1 = $signed(activations[i+1]);
        B1 = $signed(weights[i+1]);

        A2 = $signed(activations[i+2]);
        B2 = $signed(weights[i+2]);

        A3 = $signed(activations[i+3]);
        B3 = $signed(weights[i+3]);

        #20;

    end

    #100;

    /////////////////////////////////////////////////////
    // FINAL REPORT
    /////////////////////////////////////////////////////

    $display("");
    $display("========================================");
    $display(" 2x2 ADAPTIVE MAC ARRAY DNN REPORT ");
    $display("========================================");

    $display("8-bit Operations  = %0d", mode8_count);
    $display("16-bit Operations = %0d", mode16_count);
    $display("32-bit Operations = %0d", mode32_count);

    $display("----------------------------------------");

    $display("Total Operations = %0d",
             mode8_count +
             mode16_count +
             mode32_count);

    $display("----------------------------------------");

    $display("Final Dot Product = %0d",
             dot_product_out);

    $display("========================================");

    $finish;

end

/////////////////////////////////////////////////////////
// MONITOR
/////////////////////////////////////////////////////////

initial begin

    $monitor(
    "t=%0t | DP=%0d | M0=%b M1=%b M2=%b M3=%b",
    $time,
    dot_product_out,
    mode0,
    mode1,
    mode2,
    mode3
    );

end

endmodule