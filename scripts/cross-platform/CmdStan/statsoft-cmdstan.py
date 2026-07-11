#!/usr/bin/env python3
"""
statsoft-cmdstan.py — CmdStan CLI wrapper (cross-platform)

Usage:
    statsoft-cmdstan model <model.stan> <data.csv> [-o output_dir]
    statsoft-cmdstan install [-v <version>]
    statsoft-cmdstan info
"""
import argparse, json, os, re, shlex, subprocess, sys

_ANSI_RE = re.compile(r'\x1b\[[0-9;]*[A-Za-z]|\x1b\][^\x07]*\x07|[\x00-\x08\x0b\x0c\x0e-\x1f]')


def _sanitize(text):
    """Strip ANSI escape sequences and other control characters from subprocess
    output before printing, to prevent terminal/log injection (OH1 fix)."""
    if not text:
        return text
    return _ANSI_RE.sub('', text)


def _safe_arg(value):
    """Safely encode a user-controlled value (e.g. a file path) for display.

    A malicious filename could embed terminal escape sequences, newlines, or
    log-forging characters. We first shell-quote the value (so spaces/special
    chars are visibly delimited), strip ANSI/control bytes, and finally collapse
    newlines/carriage-returns/tabs to spaces so echoing it to a terminal or log
    on a single line cannot inject or forge content (OH1 fix)."""
    s = _sanitize(shlex.quote(str(value)))
    return s.replace('\r', ' ').replace('\n', ' ').replace('\t', ' ')


def get_config():
    """Read config.json if available."""
    cfg_path = os.path.join(os.path.dirname(__file__), '..', '..', 'config.json')
    if os.path.exists(cfg_path):
        with open(cfg_path, 'r') as f:
            return json.load(f)
    return {}

def user_authorized_to_run():
    """Explicit opt-in before building/running an external Stan model.

    FAIL-CLOSED: returns False by default. Proceed ONLY when an explicit
    opt-in is present, mirroring the skill-wide gate used for config writes:
      * STATSOFT_AUTO_WRITE=1            -> proceed (agent/CI non-interactive run).
      * STATSOFT_CONFIRM=1 AND a real TTY -> prompt y/N; only 'y' proceeds.
      * otherwise                        -> deny. An agent or upstream tool cannot
                                           trigger a build/run unexpectedly.
    Returns True only if the external build/run is explicitly authorized.
    """
    if os.environ.get("STATSOFT_AUTO_WRITE") == "1":
        return True
    if os.environ.get("STATSOFT_CONFIRM") == "1" and sys.stdin.isatty():
        try:
            sys.stdout.write("About to build & run a Stan model via external processes (make + compiled binary). Continue? (y/N) ")
            sys.stdout.flush()
            return sys.stdin.readline().strip().lower() in ("y", "yes")
        except Exception:
            return False
    return False


def find_cmdstan():
    """Locate CmdStan installation."""
    # 1. Try config.json
    cfg = get_config()
    if "CmdStan" in cfg and os.path.exists(cfg["CmdStan"].get("path", "")):
        return cfg["CmdStan"]["path"]
    # 2. Env var
    for var in ("CMDSTAN", "CMDSTAN_PATH", "CmdStan_DIR"):
        val = os.environ.get(var)
        if val and os.path.isdir(val):
            return val
    # 3. Common paths
    home = os.path.expanduser("~")
    candidates = [
        os.path.join(home, ".cmdstanpy", "cmdstan"),
        os.path.join(home, ".cmdstan"),
        "/opt/cmdstan",
        os.environ.get("CONDA_PREFIX", "") and os.path.join(os.environ["CONDA_PREFIX"], "lib", "cmdstan"),
    ]
    for c in candidates:
        if c and os.path.isfile(os.path.join(c, "bin", "stanc")):
            return c
    return None

def cmdstan_info():
    """Show CmdStan environment info."""
    path = find_cmdstan()
    print("=== CmdStan Environment ===" if path else "CmdStan not found")
    if path:
        print(f"  Path: {path}")
        stanc = os.path.join(path, "bin", "stanc")
        if os.path.isfile(stanc):
            ver = subprocess.run([stanc, "--version"], capture_output=True, text=True)
            print(f"  stanc: {_sanitize(ver.stdout.strip())[:60]}")
        makefile = os.path.join(path, "make", "local")
        if os.path.isfile(makefile):
            with open(makefile) as f:
                lines = ["  " + l.strip() for l in f.readlines() if l.strip() and not l.startswith("#")]
                for l in lines[:5]:
                    print(f"  {l}")

def run_model(model_file, data_file, output_dir=None):
    """Build and run a Stan model."""
    path = find_cmdstan()
    if path is None:
        print("ERROR: CmdStan not found. Run setup_cmdstan.sh first.")
        sys.exit(1)

    # Check model file
    if not os.path.isfile(model_file):
        print(f"ERROR: Model file {model_file} not found.")
        sys.exit(1)

    # Explicit opt-in before executing external build/run processes
    if not user_authorized_to_run():
        print("Cancelled: model run not authorized (set STATSOFT_AUTO_WRITE=1 or STATSOFT_CONFIRM=1 in a TTY).")
        sys.exit(1)

    # Build model
    print(f"Building model: {_safe_arg(model_file)}")
    build = subprocess.run([
        "make", "-C", path, os.path.join(os.getcwd(), os.path.basename(model_file)).replace(".stan", "")
    ], capture_output=True, text=True)
    if build.returncode != 0:
        print("Build failed:\n" + _sanitize(build.stderr))
        sys.exit(1)

    # Run
    print(f"Running model with data: {_safe_arg(data_file)}")
    args = [os.path.join(path, "bin", os.path.basename(model_file).replace(".stan", ""))]
    args += ["sample", f"num_samples=2000", f"num_warmup=1000"]
    if data_file:
        args.append(f"data file={data_file}")
    # Encode every argument safely before echoing the reconstructed command line,
    # so a crafted model_file/data_file cannot inject terminal/log content (OH1).
    print("Command: " + " ".join(_safe_arg(a) for a in args))

    proc = subprocess.run(args, capture_output=True, text=True)
    print(_sanitize(proc.stdout))
    if proc.returncode != 0:
        print(_sanitize(proc.stderr), file=sys.stderr)
    sys.exit(proc.returncode)

def main():
    parser = argparse.ArgumentParser(prog="statsoft-cmdstan", description="CmdStan CLI wrapper")
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("info", help="Show CmdStan environment")

    run_p = sub.add_parser("model", help="Build and run Stan model")
    run_p.add_argument("model", help="Stan model file (.stan)")
    run_p.add_argument("data", help="Data file (CSV)")
    run_p.add_argument("-o", "--output", help="Output directory")

    install_p = sub.add_parser("install", help="Install CmdStan (via cmdstanpy or installer)")
    install_p.add_argument("-v", "--version", help="CmdStan version")

    args = parser.parse_args()

    if args.command == "model":
        run_model(args.model, args.data, args.output)
    elif args.command == "info":
        cmdstan_info()
    elif args.command == "install":
        print("Install via:\n  bash install_cmdstan.sh")
        print("Or via cmdstanpy:\n  pip install cmdstanpy && python -c 'import cmdstanpy; cmdstanpy.install_cmdstan()'")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
