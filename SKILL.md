---
name: statsoft-cli
description: "Cross-platform statistical software CLI integration for WorkBuddy. Supports R, Stata, SAS, SPSS, JMP, GraphPad Prism, Gretl, Minitab, Matlab, Julia, EViews, Statistica, and Stat/Transfer. Auto-detects platform, hides incompatible software, bilingual (中文/English). Core value: integrate and leverage statistical software resources within AI workflows."
triggers:
  - "关联统计软件"
  - "SPSS"
  - "R command line"
  - "Stata CLI"
  - "SAS batch"
  - "GraphPad"
  - "JMP"
  - "connect statistical software"
  - "statsoft-cli"
metadata:
  {
    "openclaw": { "emoji": "🛠️" },
    "authors": ["medstatstar", "phoebeuwu"],
    "version": "1.0.0",
    "license": "MIT",
    "tags": ["SPSS", "Stata", "R", "SAS", "StatTransfer", "Gretl", "Minitab", "Matlab", "Julia", "EViews", "Statistica", "统计软件", "Statistical Software", "Data Analysis", "Data Conversion", "CLI", "Econometrics", "Machine Learning"]
  }
---

# Statistical Software CLI Integration

## Platform Support

| Software | Windows | Mac | Linux |
|----------|---------|-----|-------|
| SPSS | ✅ | ❌ | ❌ |
| R | ✅ | ✅ | ✅ |
| Stata | ✅ | ✅ | ✅ |
| SAS | ✅ | ✅ | ✅ |
| JMP | ✅ | ❌ | ❌ |
| GraphPad | ✅ | ❌ | ❌ |
| Stat/Transfer | ✅ | ✅ | ✅ |
| Gretl | ✅ | ✅ | ✅ |
| Minitab | ✅ | ⚠️ | ⚠️ |
| Matlab | ✅ | ✅ | ✅ |
| Julia | ✅ | ✅ | ✅ |
| EViews | ✅ | ❌ | ❌ |
| Statistica | ✅ | ❌ | ❌ |

## Execution Workflow

### Step 0: Detect Platform

```bash
source cross-platform/_platform-detect.sh  # sets WB_OS, WB_ARCH
```

### Step 1: Gather Info

Ask which software + install path. Auto-search if path unknown. (User provides path first, no auto-scan until needed.)

### Step 2: Select Mode

- **Simple** — one command per syntax file
- **Advanced** — log capture, batch concatenation, data viewing

### Step 3: Detect & Setup

Route to correct script per platform (non-Windows auto-hides SPSS/JMP/GraphPad).

### Step 4: Save Config

```json
{ "platform": "windows", "statssoftware": { "installed": true, "path": "...", "version": "...", "mode": "simple" } }
```

### Step 5: Write Memory

Append environment config to `~/.workbuddy/MEMORY.md`.

### Step 6: Output Completion Summary

## Script Routing Table

| Software | Windows Script | Cross-Platform Script | Verification |
|----------|---------------|----------------------|-------------|
| SPSS | `windows-only/SPSS/setup_spss.ps1` | — | `spss.exe -production mode "exit.sps"` |
| Stata | `cross-platform/Stata/setup_stata.sh` | same | `stata-mp -b do "exit"` |
| R | `cross-platform/R/setup_r.sh` | same | `Rscript --version` |
| SAS | `cross-platform/SAS/setup_sas.sh` | same | `sas -version` |
| JMP | `windows-only/JMP/setup_jmp.ps1` | — | `JMP.exe /R "Exit();"` |
| GraphPad | `windows-only/GraphPad/setup_graphpad.ps1` | — | `prism.exe -help` |

## Test Files

`tests/` → `README.md`, `test-syntax.sps`, `test-job.spj`

## Detailed Configuration

For full software configs, version differences, completion prompt templates, and search paths:
- `ADDITIONAL_SOFTWARE.md` — JMP, GraphPad, Stat/Transfer, Gretl, Minitab, Matlab, Julia, EViews, Statistica

## Trigger Phrases

中文: 连接统计软件, 关联SPSS, Stata CLI, R命令行, SAS批处理, JMP, GraphPad Prism, statsoft-cli
English: connect SPSS, Stata CLI, R command line, SAS batch, JMP scripting, GraphPad Prism
