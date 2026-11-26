# Verification scope

The project benches load signed 32-bit hexadecimal words using $readmemh. An independent Python check reads both 784-word files, converts two’s-complement values to integers and sums all paired products. There are 629 zero products and the dot product is 3,995,709,172. The benches name this workload MNIST. Its checkpoint establishes a fixed arithmetic result, independent of any claim about training provenance.

| Original integration bench | Checks passed in XSim replay | Distinguishing checks |
|---|---:|---|
| [2×2 parallel](../results/simulation/mac_array_2x2_accum_tb.txt) | 7 | Mixed-sign group totals −59, INT8/16/32 detection, local-sum invariant |
| [4×4 parallel](../results/simulation/mac_array_4x4_accum_tb.txt) | 7 | Sum of squares 1…16 = 1,496, individual PE golden sums and combined invariant |
| [2×2 systolic](../results/simulation/systolic_array_2x2_accum_tb.txt) | 5 | Four exact matrix entries, trace 69, two-channel stream |
| [4×4 systolic](../results/simulation/systolic_array_4x4_accum_tb.txt) | 5 | Identity × diagonal, four-channel stream |

All four benches check the 784-pair checkpoint, zero inputs, enable hold and synchronous clear. Their counters count individual checked cases across two test sections, although the display labels the count “Test Suites”. The independent replay reported zero failures in each. No full-range formal signed multiplication proof, forced 80-bit overflow, randomized reset/enable sequence, broad 4×4 dense-matrix sweep or post-route simulation is claimed.

The eight base benches in testbench/base_array_tbs exercise the PE and base arrays. Several print examples without asserting a verdict. A separate 4×4 DNN demonstration steps i by 16 while driving only pairs i through i+3. Its 49 snapshots of sixteen PE outputs include 637 zeros. This is a property of that sampling schedule. The integrated streaming test visits all 784 pairs. A zero product in the demonstration does not measure switching activity or power.
