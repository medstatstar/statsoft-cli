# Workflow Gating Detail / 工作流门控细节

The full step-by-step workflow lives in `SKILL.md` (Execution Workflow). This file only supplements the per-step default-deny gating details, to avoid duplication with `SKILL.md`.

## Scan Disclosure / 扫描披露

The system scan returns only the `installed` boolean by default. Path / version details require `STATSOFT_REVEAL=1`.

## Persistence Gate / 持久化闸门

`config.json` is written only with explicit authorization: `STATSOFT_AUTO_WRITE=1` (non-interactive / agent) or `STATSOFT_CONFIRM=1` + interactive `y`. All writes go through `scripts/common/write_config.py`:

- Accepts only the canonical `config.json` in the skill root as the target (single-path enforcement, fail-closed);
- Before writing, takes a timestamped backup `config.json.bak.yyyymmdd_hhmmss`, then atomically replaces.

Persistence happens only with explicit opt-in (`STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1` + interactive `y`). All writes go through `scripts/common/write_config.py`, which enforces a single canonical target and a timestamped backup before atomic replace.

## Third-party Binaries / 第三方二进制文件

Launching third-party binaries solely for version/checksum verification requires `STATSOFT_VERIFY=1`; compiling and running a user-supplied Stan model (untrusted native code) requires `STATSOFT_CMDSTAN_RUN=1`.