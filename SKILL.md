---
name: statsoft-cli
slug: statsoft-cli
displayName: 统计软件接入助手 / Statsoft-CLI
description: "跨平台统计软件 CLI 集成，面向 AI Agent；覆盖 34+ 款软件（R/Stata/SAS/SPSS/Python/贝叶斯/ML），双语。核心价值：激活历史代码资产，用于 AI 工作流自动化。 / Cross-platform statistical software CLI integration for AI Agent; 34+ packages (R/Stata/SAS/SPSS/Python/Bayesian/ML), bilingual. Core value: activating historical code assets for AI workflow automation."
triggers:
  - "SPSS"
  - "SPSS Statistics"
  - "R"
  - "R命令行"
  - "Stata"
  - "SAS"
  - "统计软件"
  - "连接统计软件"
  - "statsoft-cli"
  - "connect statistical software"
metadata:
  {
    "openclaw": { "emoji": "🛠️", "icon": "assets/icon.svg" },
    "authors": ["medstatstar", "phoe-zip"],
    "contributors": ["medstatstar", "phoe-zip"],
    "version": "2.6.23",
    "license": "MIT",
    "tags": ["Statistical Software", "CLI", "R", "SPSS", "Stata", "SAS", "Bayesian", "Machine Learning", "Econometrics", "SEM", "Data Mining"],
    "homepage": "https://github.com/medstatstar/statsoft-cli",
    "repository": "https://github.com/medstatstar/statsoft-cli"
  }
---

# Language / 语言

This skill responds in the user's current input language (Chinese or English) and auto-detects / switches accordingly. The runtime scripts embed a locale check (`$script:isZH` in PowerShell, `SCRIPT_LANG` in Bash) so all user-facing prompts switch to Chinese on a `zh-*` UI culture and to English otherwise. Code comments and documentation are English-only.

## Overview / 概述

Activates historical code assets locked in statistical software (syntax, scripts, projects) and wires them into AI workflows via automated detection, configuration, and execution.

## Core Functions / 核心功能

Covers 34+ statistical / data-science packages, auto-routed by platform; non-Windows auto-hides incompatible software:

- **Cross-platform (Win / Mac / Linux, CLI)**: R, Stata, SAS, CmdStan, GenStat, Gretl, H2O.ai, JAGS, Julia, KNIME, Mathematica, Matlab, OpenBUGS, Orange, OxMetrics, PSPP, Rattle, SHAZAM, Stat/Transfer, Tanagra, TSP, Weka
- **Windows + limited cross-platform**: Mplus, Minitab
- **Windows-only CLI**: SPSS Statistics, EViews, JMP, LIMDEP, Microfit, NCSS, NLOGIT, Origin, Q(MRKS), SPSS Modeler, Statistica
- **GUI-only detection + manual launch guide**: AMOS, GraphPad Prism, JASP, jamovi (never drive batch via CLI)

Full platform matrix in `references/platform-support.md`; extended config in `ADDITIONAL_SOFTWARE.md`.

## Execution Workflow / 执行工作流

1. **Detect Platform** — cross-platform `source scripts/cross-platform/_platform-detect.sh` (sets `$PLATFORM`/`$OS`/`$ARCH`); Windows handled inside `.ps1` scripts, no source
2. **Pre-scan Confirmation** — before any scan, MUST prompt and wait:
   - Prompt (English by default; auto-switched to Chinese on a `zh-*` locale): "⚠️ Auto-scan may take a while (~30s on Windows). If you have ≤3 packages, specify paths to skip. Your choice?" Options: A) Auto-scan  B) Specify paths
   - A → step 3; B → skip scan, go to step 4
3. **System Scan** (only if A) — batch-detect installed software:
   - Windows: `scripts/windows-only/scan/scan_all.ps1`; Mac/Linux: `scripts/cross-platform/scan/scan_all.sh`
   - Output JSON: `{"R":{"installed":true,"path":"...","version":"..."},...}`
   - By default only the `installed` boolean is returned; path / version disclosed only with `STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1`+interactive y (note: `STATSOFT_REVEAL` controls per-software setup-time output only, not batch scan results)
4. **Select Config Mode** — batch / specified / single-software (calls individual `setup_*.ps1` or `setup_*.sh`)
5. **Detect & Setup** — route to the platform script; non-Windows auto-hides incompatible software
6. **Save Config** — detect-only by default; writes `config.json` only with explicit authorization (`STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1` + interactive y)
7. **Output Summary** — per `references/completion-prompts.md` template

## Default-Deny Gates / 默认拒绝闸门

All persistence and sensitive operations are **off by default** and require explicit authorization (fail-closed), consistent with the scripts:

| Gate | Effect | Default |
|------|--------|---------|
| `STATSOFT_AUTO_WRITE=1` | Persist `config.json` (non-interactive / agent context) | off |
| `STATSOFT_CONFIRM=1` + TTY y | Persist after interactive confirmation | off |
| `STATSOFT_REVEAL=1` | Reveal path / version details during detection | off |
| `STATSOFT_VERIFY=1` | Allow launching third-party binaries for version / verification | off |
| `STATSOFT_CMDSTAN_RUN=1` | Allow compiling & running user Stan models (untrusted native code) | off |

All writes go through `scripts/common/write_config.py`: accepts only the canonical `config.json` under the skill root, and before writing takes a timestamped backup (`config.json.bak.yyyymmdd_hhmmss`) then atomic-replaces.

## Core Permissions / 核心权限

- **Local file read-write** — `config.json`, temp scripts
- **Process execution** — statistical software binaries
- **Network access** — CRAN / Anaconda repos

## Trust & Safety / 信任与安全

This skill performs high-risk operations; understand the risk levels before use:

| Risk | Level |
|------|-------|
| Execute local executables | 🔴 High |
| Download & install software | 🔴 High |
| Execute user scripts (e.g. `.sps` via SPSS Python) | 🔴 High |
| Modify config.json | 🟡 Medium |
| Network access | 🟡 Medium |

**Pre-flight**: ✅ review all scripts; ✅ confirm config.json changes (auto-backup); ✅ confirm any downloads; ✅ inspect generated commands for sensitive projects.

## Reference Files / 参考文件

- `ADDITIONAL_SOFTWARE.md` — extended software config (31 packages)
- `references/command-examples.md` — per-software CLI command examples
- `references/config-templates.md` — `config.json` templates & field reference
- `references/version-specifics.md` — version differences
- `references/completion-prompts.md` — completion prompt templates
- `references/trust-and-safety.md` — risk levels & pre-flight details
- `references/workflow.md` — workflow gating details
- `references/platform-support.md` — full platform support matrix
- `tests/` — automated test scripts