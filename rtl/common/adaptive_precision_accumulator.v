`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design: Adaptive Precision Accumulator
// Target: High-Reliability Signed Arithmetic Accumulator
// Parameters:
//   INPUT_WIDTH: Width of the incoming product or partial sum (e.g., 64, 66, 68)
//   ACCUM_WIDTH: Width of the accumulator register (default 80-bit)
// Description:
//   Provides deterministic synchronous reset, clock enable gating, synchronous clear,
//   sign-extended two's complement accumulation, and overflow detection.
//////////////////////////////////////////////////////////////////////////////////

module adaptive_precision_accumulator #(
    parameter INPUT_WIDTH = 64,
    parameter ACCUM_WIDTH = 80
)(
    input clk,
    input reset,
    input enable,
    input clear,
    input signed [INPUT_WIDTH-1:0] data_in,
    output reg signed [ACCUM_WIDTH-1:0] accum_out,
    output reg valid_out,
    output reg overflow_flag
);

    wire signed [ACCUM_WIDTH-1:0] ext_data;
    generate
        if (ACCUM_WIDTH > INPUT_WIDTH) begin : GEN_SIGN_EXT
            assign ext_data = {{(ACCUM_WIDTH - INPUT_WIDTH){data_in[INPUT_WIDTH-1]}}, data_in};
        end else begin : GEN_NO_EXT
            assign ext_data = data_in[ACCUM_WIDTH-1:0];
        end
    endgenerate

    wire signed [ACCUM_WIDTH-1:0] next_accum;
    assign next_accum = accum_out + ext_data;

    // Detect overflow: when two positive numbers sum to negative, or two negatives sum to positive
    wire sign_a = accum_out[ACCUM_WIDTH-1];
    wire sign_b = ext_data[ACCUM_WIDTH-1];
    wire sign_r = next_accum[ACCUM_WIDTH-1];
    wire overflow_condition = (~sign_a & ~sign_b & sign_r) | (sign_a & sign_b & ~sign_r);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            accum_out     <= {ACCUM_WIDTH{1'b0}};
            valid_out     <= 1'b0;
            overflow_flag <= 1'b0;
        end else if (clear) begin
            accum_out     <= {ACCUM_WIDTH{1'b0}};
            valid_out     <= 1'b0;
            overflow_flag <= 1'b0;
        end else if (enable) begin
            accum_out     <= next_accum;
            valid_out     <= 1'b1;
            if (overflow_condition)
                overflow_flag <= 1'b1;
        end else begin
            valid_out     <= 1'b0;
        end
    end

endmodule
