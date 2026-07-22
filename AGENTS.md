# AGENTS.md — statsoft-cli

## Overview

`statsoft-cli`: cross-platform CLI integration for statistical software (34+ packages: R, Stata, SAS, SPSS, Python, Bayesian, ML). It auto-detects, configures, and executes historical code assets locked in statistical software (syntax, scripts, projects), wiring them into AI workflows. `SKILL.md` is the entry point; `README.md` (English) and `README_zh-CN.md` (Chinese) are language-specific guides.

---

## Core Rules

### 1. Language

- `SKILL.md` body, `references/*.md`, `ADDITIONAL_SOFTWARE.md`, and this file (`AGENTS.md`) are **English-only and agent-facing**.
- Bilingual human-readable content lives ONLY in the two READMEs; the `## Language` segment in `SKILL.md` links both. Never put Chinese into documentation headings or body.
- Runtime command prompts (from PowerShell / Bash setup scripts) switch to Chinese on a `zh-*` locale and English otherwise, via `$script:isZH` (PowerShell) / `SCRIPT_LANG` (Bash). This is runtime behavior, not doc content.
- `summary` is a **special field**: it MAY be Chinese-only even for a published skill (marketplace discovery relies on the bilingual `displayName` / `description` / `triggers`; `summary` alone does not need to be bilingual).

### 2. Config Write Safety (fail-closed)

- Detection scripts are **detect-only by default**. Writing to `config.json` is fail-closed: it requires explicit opt-in — `STATSOFT_AUTO_WRITE=1` (non-interactive / agent) or `STATSOFT_CONFIRM=1` plus a TTY "y" answer. Never block an agent.
- All `config.json` writes go through `scripts/common/write_config.py`: timestamped backup (`config.json.bak.yyyyMMdd_HHMMSS`) + atomic `os.replace`. Canonical targets: skill-root `config.json` and `scripts/windows-only/config.json`.
- GUI-only software (AMOS, GraphPad Prism, JASP, jamovi) are detected and given a manual launch guide only; never driven via CLI / headless.

### 3. Software / R Package Install

- Installing statistical software or R packages requires explicit user confirmation before any network download.

### 4. Activation Boundary

- Only respond to an explicit user request to configure / run a specific tool. Do not auto-trigger on vague mentions.

### 5. Reuse / Conventions

- Locale-switch helpers: PowerShell `Write-Lang` + `$script:isZH`; Bash `LANG_ZH()` + `SCRIPT_LANG`.
- Validation: `.sh` → `bash -n`; `.py` → `py_compile`; `.ps1` → `[System.Management.Automation.Language.Parser]::ParseInput` (NOT `System.Management.Automation.PSParser`, which lacks `ParseInput` in Windows PowerShell 5.1).
- Cross-platform `*.sh` MUST be LF (Git Bash rejects CRLF). `.ps1` containing Chinese MUST be UTF-8 BOM on WinPS 5.1 (else GBK misread).

---

## Dependencies

- Python: Anaconda `C:\Tools\anaconda3\python.exe` (per environment convention).
- R: `C:\Tools\R-4.5.1\bin\x64` (statistical computation).
- PowerShell 5.1 / Bash (Git Bash) for setup and scan scripts.

---

## Security Red Line

- Never transmit user data off-local. Network use is limited to reading public docs / installing local dependencies, disclosed per action.
