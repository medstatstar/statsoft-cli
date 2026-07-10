#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Centralized fail-closed config persistence gate for statsoft-cli.

This is the SINGLE confirmation gate for every persistent write performed by
the statsoft-cli setup scripts. It is invoked by the per-tool setup_*.sh /
setup_*.py scripts after they have *detected* a tool and built the desired
config document.

Contract
--------
  argv[1] : absolute/relative path of the target config.json
  argv[2] : (optional) path to a temp file containing the desired config as JSON
            If argv[2] is omitted, the JSON is read from stdin.

Behaviour (fail-closed by default)
----------------------------------
  * Detection-only is the DEFAULT. Nothing is written unless an explicit
    opt-in is present.
  * Persist only when ONE of:
      - STATSOFT_AUTO_WRITE=1            (non-interactive / agent contexts)
      - STATSOFT_CONFIRM=1 AND the session is interactive (a real TTY) AND the
        user answers 'y' at the prompt
  * When persisting: a timestamped backup (config.json.bak.yyyymmdd_hhmmss)
    is taken first, then the new file is written atomically via os.replace.
  * The caller is NEVER blocked: detection-only exits 0.

This module deliberately imports everything it needs and uses only variables
it defines itself, so it cannot suffer from the "undefined name" failures that
plagued the previous inline blocks.
"""
import os
import sys
import json
import shutil
import datetime


def _read_json(arg_path, from_stdin):
    if arg_path:
        try:
            with open(arg_path, "r", encoding="utf-8") as fh:
                return fh.read()
        except Exception as exc:  # pragma: no cover - defensive
            sys.stderr.write("write_config.py: cannot read JSON file %s: %s\n" % (arg_path, exc))
            return None
    if from_stdin:
        return sys.stdin.read()
    return None


def main():
    if len(sys.argv) < 2:
        sys.stderr.write("usage: write_config.py <config_path> [<json_file>]\n")
        return 2

    target_path = sys.argv[1]
    json_src = _read_json(sys.argv[2] if len(sys.argv) > 2 else None,
                          from_stdin=(len(sys.argv) < 3))

    if not json_src or not json_src.strip():
        sys.stderr.write("write_config.py: empty config payload; nothing to persist.\n")
        return 2

    try:
        data = json.loads(json_src)
    except Exception as exc:
        sys.stderr.write("write_config.py: invalid JSON payload: %s\n" % exc)
        return 2

    auto_write = os.environ.get("STATSOFT_AUTO_WRITE") == "1"
    confirm_env = os.environ.get("STATSOFT_CONFIRM") == "1"

    go = False
    if auto_write:
        go = True
    elif confirm_env and sys.stdin.isatty():
        try:
            sys.stdout.write("Persist detected config to config.json? (y/N) ")
            sys.stdout.flush()
            ans = sys.stdin.readline().strip().lower()
            go = ans in ("y", "yes")
        except Exception:
            go = False

    if not go:
        print("Detection-only: config.json NOT modified. "
              "Set STATSOFT_AUTO_WRITE=1 to persist, or STATSOFT_CONFIRM=1 for an interactive prompt.")
        return 0

    # Persist with timestamped backup + atomic replace.
    if os.path.exists(target_path):
        bak = target_path + ".bak." + datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        shutil.copy2(target_path, bak)
        print("Config backed up to: " + bak)

    tmp = target_path + ".tmp." + str(os.getpid())
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False)
    os.replace(tmp, target_path)
    print("Config written to: " + target_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
