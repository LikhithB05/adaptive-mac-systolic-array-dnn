# Authors and Academic Project Acknowledgments

## Lead Developer & Repository Maintainer

- **Likhith B** ([LikhithB05](https://github.com/LikhithB05)) — Lead Developer, Primary Technical Contributor & Repository Maintainer  
  Verified individual engineering contributions in this repository include:
  - Hardware architecture design and development
  - Verilog RTL implementation for 2×2 and 4×4 parallel MAC arrays (`mac_array_2x2_accum_top`, `mac_array_4x4_accum_top`) and 2×2 and 4×4 systolic arrays (`systolic_array_2x2_accum_top`, `systolic_array_4x4_accum_top`)
  - Adaptive processing element (`adaptive_processing_element`) and parameterized 80-bit `adaptive_precision_accumulator` integration
  - Hardware optimization, functional verification, and Vivado XSim / Python golden-reference simulation
  - FPGA resource, timing, and power scalability analysis (`2×2` vs. `4×4`) and technical documentation

## Academic Group Project Context

This work was undertaken as part of an academic Major project in the **Department of Electronics and Communication Engineering**, **JSS Academy of Technical Education, Bengaluru**, affiliated with **Visvesvaraya Technological University (VTU)** (Academic Year **2026–2027**).

### Original Academic Project Team
- **Likhith B** ([LikhithB05](https://github.com/LikhithB05))
- **Ananya S**
- **Apoorva Sheshadri**
- **K. S. Sindhura**

*(Project B builds directly upon the `adaptive_mac_top` core from the shared Major project codebase; individual roles for other team members on specific array variants are not specified.)*

### Academic Project Guide
- **Mrs. Sunita L. Shirahatti**, Assistant Professor, Department of Electronics and Communication Engineering, JSS Academy of Technical Education, Bengaluru *(Academic guidance and supervision)*.

## Repository Note & Licensing Status
- Original Verilog RTL, simulation testbenches, XDC constraints, and paired `.mem` datasets are preserved intact; explanatory documentation, SVG topology/scaling figures, and simulation runners support independent verification.
- No open-source license file has been added to this repository at this stage (`No license grant authorized`).
