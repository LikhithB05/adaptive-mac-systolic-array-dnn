
`timescale 1ns / 1ps

module acc (
    input clk,
    input reset,
    input enable,
    input [64:0] in,
    output reg [64:0] out
);

    wire [63:0] cla_sum;
    wire cla_cout;
    wire upper_sum;

    // Lower 64-bit addition using CLA
    cla_64bit cla_acc (
        .A(out[63:0]),
        .B(in[63:0]),
        .Cin(1'b0),
        .Sum(cla_sum),
        .Cout(cla_cout)
    );

    // Calculate bit 64
    assign upper_sum = out[64] ^ in[64] ^ cla_cout;

    // Register the accumulated result with clock-enable gating
    always @(posedge clk or posedge reset) begin
        if (reset)
            out <= 65'd0;
        else if (enable)
            out <= {upper_sum, cla_sum};
    end

endmodule
