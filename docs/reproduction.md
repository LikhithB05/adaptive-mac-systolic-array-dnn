# Run the array tests

Use Python 3 and the Vivado 2026.1 simulator (xvlog, xelab and xsim). The selected Verilog sources are self-contained, use no include search paths and require no external memory initialization files beyond the two supplied words files.

```sh
python scripts/check_dataset.py
python scripts/run_original_golden.py
python scripts/run_xsim.py --work build
```

On Windows, pass `--bin "C:/path/to/Vivado/bin"` if the Vivado command prompt is unavailable. Each run makes a new scratch subdirectory. It copies the RTL, the four integrated benches and both memories there, compiles with xvlog, elaborates a separate snapshot per bench and runs xsim -runall. Inspect the per-bench logs for the exact checkpoint and zero failures. The original golden script is staged alongside the matching memory files. It checks the scalar and both parallel-lane schedules. The original script begins a systolic model discussion, while the systolic schedules are checked by their RTL benches. The base benches can be compiled with the same RTL and memories, selecting the bench filename stem as elaboration top. Use a new scratch directory and keep only one bench top in each snapshot.

## Routed implementation

From a new empty scratch directory, run the following with the path to the repository substituted. This supplemental portable script recreates the documented implementation stages. The published figures come from the archived runs. Tool versions, seeds and constraint details can change routed values.

```sh
vivado -mode batch -source "/path/to/repository/scripts/route.tcl" -tclargs systolic_array_4x4_accum_top
```

The original scripts reference constraints_ooc.xdc, while the descriptive common XDC names the clock sys_clk. Historical timing reports label it clk and show a period of 83.333 ns. The supplied minimal XDC uses this recorded name and period. It leaves board-level pin assignments and input/output delays unspecified. Select one of the four integrated tops listed in the README and retain each run’s output in a separate directory.
