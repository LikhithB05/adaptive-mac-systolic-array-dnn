`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 10:58:21
// Design Name: 
// Module Name: adaptive_processing_element
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

module adaptive_processing_element(

    input clk,
    input reset,

    input signed [31:0] A_in,
    input signed [31:0] B_in,

    output reg signed [31:0] A_out,
    output reg signed [31:0] B_out,

    output signed [63:0] mac_out,

    output [1:0] mode_out

);

//////////////////////////////////////////////////////
// PIPELINE REGISTERS
//////////////////////////////////////////////////////

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        A_out <= 32'd0;
        B_out <= 32'd0;
    end

    else
    begin
        A_out <= A_in;
        B_out <= B_in;
    end

end

//////////////////////////////////////////////////////
// ADAPTIVE MAC
//////////////////////////////////////////////////////

adaptive_mac_top MAC(

    .clk(clk),
    .reset(reset),

    .A(A_in),
    .B(B_in),

    .mode_out(mode_out),

    .A_eff_out(),
    .B_eff_out(),

    .booth_groups_out(),

    .neg_out(),
    .two_out(),
    .zero_out(),

    .partial_products_out(),

    .wallace_sum_out(),
    .wallace_carry_out(),

    .cla_sum_out(mac_out),

    .accumulator_out(),

    .final_output(),

    .final_carry_out()

);

endmodule