"""Run the original parallel-array reference alongside frozen operand words."""
from pathlib import Path
import argparse
import shutil
import subprocess
import sys
import tempfile

repo = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--work", type=Path, default=repo / "build")
args = parser.parse_args()
args.work.mkdir(parents=True, exist_ok=True)
run = Path(tempfile.mkdtemp(prefix="golden-", dir=args.work.resolve()))
original = repo / "software/golden_reference/golden_reference_model.py"

for name in ("activations.mem", "weights.mem"):
    shutil.copyfile(repo / "datasets" / name, run / name)
shutil.copyfile(original, run / original.name)
subprocess.run([sys.executable, "-B", original.name], cwd=run, check=True)
print("Summary:", run / "golden_reference_summary.txt")
