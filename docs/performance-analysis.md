# Implementation evidence

The eight CSV rows cover each unaccumulated base and its integrated wrapper at 2×2 and 4×4. The original report headers identify routed Vivado 2026.1 designs. The Tcl flow synthesized out of context with -max_dsp 0, then optimized, placed, routed and emitted power, timing and utilization reports. The archived comparison data came from those reports. [All eight data rows](../results/comparisons/routed-ppa.csv) · [Report SHA-256 fingerprints](../results/comparisons/report-hashes.csv)

Power reports identify xc7a200tfbg676-2, typical process, commercial grade, no simulation activity file and zero bonded IOBs. Static estimates round to 122 mW for every row. The 12 MHz design clock is a constraint. Boundary input/output delays are absent, limiting timing conclusions for external data delivery. Neither an Fmax nor application throughput follows from these single path delays.

| 4×4 divided by 2×2 | PEs | LUTs | FFs | Dynamic estimate |
|---|---:|---:|---:|---:|
| Parallel integrated | 4× | 3.98× | 3.39× | 3.95× |
| Systolic integrated | 4× | 3.97× | 4.08× | 4.15× |

Each ratio is the larger integrated row divided by its smaller row, within the same architecture. Adding the wrapper changes observability and overflow logic. Comparing its routed path directly to a base port-to-port path would mix timing categories. The base 2×2 systolic selection even begins at asynchronous reset and ends at a register clear pin. An infinite slack entry represents a path without a finite requirement in the summary.

The 4×4 mesh’s 41.314 ns path consists of 9.129 ns logic and 32.185 ns routing. It starts at PE31/A_out_reg[12]/C and ends at the aggregate overflow register. The 4×4 parallel 4.835 ns path starts at bit 0 of a local accumulator and ends at that local overflow register. The constrained endpoints explain why those values cannot rank complete input-to-result operations. The 4×4 parallel top exposes 1,110 interface bits with zero bonded pads in this flow. Physical board integration would need a narrower external interface or a surrounding fabric.
