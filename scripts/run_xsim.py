from pathlib import Path
import argparse
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
TOPS = [f"{kind}_array_{size}_accum_tb" for kind in ("mac", "systolic") for size in ("2x2", "4x4")]
parser = argparse.ArgumentParser(description="Compile and check the four original integration benches using XSim.")
parser.add_argument("--work", type=Path, default=ROOT / "build")
parser.add_argument("--bin", type=Path, help="Vivado bin directory (otherwise use PATH)")
opts = parser.parse_args()
opts.work.mkdir(parents=True, exist_ok=True)
run = Path(tempfile.mkdtemp(prefix="arrays-", dir=opts.work.resolve()))
print("Simulation directory", run, flush=True)
for f in (ROOT / "datasets").glob("*.mem"):
    shutil.copyfile(f, run / f.name)
env = os.environ.copy()
for key in ("TEMP", "TMP", "TMPDIR", "XILINX_LOCAL_USER_DATA"):
    directory = run / key
    directory.mkdir()
    env[key] = str(directory)
if opts.bin and os.name == "nt":
    install = opts.bin.resolve().parent
    env["XILINX_VIVADO"] = str(install)
    env["PATH"] = os.pathsep.join((str(opts.bin.resolve()), str(install / "lib/win64.o"), env["PATH"]))

def execute(tool, args):
    exe = shutil.which(tool, path=str(opts.bin) if opts.bin else None)
    if not exe:
        raise SystemExit(f"Missing executable {tool}")
    print(tool, *args[:2], flush=True)
    subprocess.run([exe, *args], cwd=run, env=env, check=True)

sources = sorted((ROOT / "rtl").rglob("*.v")) + sorted((ROOT / "testbench").glob("*.v"))
# Use simple local names for vendor batch wrappers and long Windows paths.
for f in sources:
    shutil.copyfile(f, run / f.name)
execute("xvlog", [f.name for f in sources])
for index, top in enumerate(TOPS):
    execute("xelab", ["-mt", "off", "-debug", "typical", top, "-s", f"s{index}"])
    execute("xsim", [f"s{index}", "-runall", "-log", top + ".log"])
    report = (run / (top + ".log")).read_text(errors="replace")
    if ">>> PASS <<<" not in report or "[FAIL]" in report or "3995709172" not in report:
        raise SystemExit(f"{top}: expected self-checks absent or failed")
print("All four integrated tops passed.")

