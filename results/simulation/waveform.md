# A skewed operand pair crosses the 2 × 2 mesh

A0/B0 carry 2/3 followed one cycle later by A1/B1 = 5/7. PE00 contributes 6 and PE11 contributes 35. PE01 and PE10 visibly form 14 and 15; the integrated aggregate selects the diagonal, so its terminal value is 41. The figure shows the interval from 5 ns to 46 ns. Values come directly from the original RTL. The stimuli and trace were generated during the supplementary audit using Icarus Verilog 13 and VVP. The 10 ns simulation clock is independent of implementation constraints.

From the repository root, on a working Icarus installation, compile the file list and run the image:

```sh
iverilog -g2012 -s waveform_tb -o waveform.vvp -f results/simulation/waveform_sources.f
vvp waveform.vvp
```

The bench writes trace.vcd in the current directory and checks the terminal accumulator value. waveform.csv contains the decoded changes, including the initial reset interval. Signed operand, product and accumulator buses use decimal values. Internal probes are diagnostic signals. Simulation time gives event ordering without post-route delays.
