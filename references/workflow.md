# Workflow Gating Detail

The full step-by-step workflow lives in `SKILL.md` (Execution Workflow). This file only supplements the per-step default-deny gating details, to avoid duplication with `SKILL.md`.

## Scan Disclosure

The system scan returns only the `installed` boolean by default. Path / version details require `STATSOFT_REVEAL=1`.

## Persistence Gate

`config.json` is written only with explicit authorization: `STATSOFT_AUTO_WRITE=1` (non-interactive / agent) or `STATSOFT_CONFIRM=1` + interactive `y`. All writes go through `scripts/common/write_config.py`:

- Accepts only the canonical `config.json` in the skill root as the target (single-path enforcement, fail-closed);
- Before writing, takes a timestamped backup `config.json.bak.yyyymmdd_hhmmss`, then atomically replaces.

Persistence happens only with explicit opt-in (`STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1` + interactive `y`). All writes go through `scripts/common/write_config.py`, which enforces a single canonical target and a timestamped backup before atomic replace.

## Third-party Binaries

Launching third-party binaries solely for version/checksum verification requires `STATSOFT_VERIFY=1`; compiling and running a user-supplied Stan model (untrusted native code) requires `STATSOFT_CMDSTAN_RUN=1`.