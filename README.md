# statsoft-cli

[🇨🇳 中文 (Chinese)](./README_zh-CN.md) | [🇬🇧 English](./README.md)

---

Cross-platform statistical software CLI integration for AI Agent (such as WorkBuddy / OpenClaw). 

Supports 34 statistical software packages: SPSS Statistics, R, Stata, SAS, AMOS, CmdStan, EViews, GenStat, GraphPad Prism, Gretl, H2O.ai, JAGS, JASP, JMP, Julia, KNIME, LIMDEP, Mathematica, Matlab, Microfit, Minitab, Mplus, NCSS, NLOGIT, OpenBUGS, Orange, OriginLab Origin, OxMetrics, PSPP, Q (MRKS), Rattle, SHAZAM, Stat/Transfer, Statistica, TSP, Tanagra, Weka, jamovi. (Note: AMOS, GraphPad Prism, JASP, and jamovi are GUI-only — they can be detected and launched but have no CLI batch mode.)

Multiple versions of the same software can coexist — for example, R4.5 and R4.0 can coexist, with a default version configured. Switch versions seamlessly by mentioning it in your prompt.

Note: If your goal is to **seamlessly read various statistical data files or convert between formats without loss**, we strongly recommend installing the standalone skill **statdata-transfer**. This skill can perfectly achieve data format conversion without relying on any statistical software support.

## Purpose

Many statistical software packages have CLI (Command Line Interface) execution modes, but not everyone knows how to use them. This skill integrates these tools into the AI Agent environment for unified access, enabling statisticians to fully leverage these tools' capabilities. **The core value of this skill lies in activating historical code assets and solving the reusability problem in AI workflow automation**. Over years of project accumulation, teams have gathered reusable analysis code—R modeling scripts, SPSS syntax files, SAS macro programs, Stata do-files—and this skill brings them into a unified execution framework as standard AI workflow nodes.

## Quick Start

### One-Click Setup

Trigger in AI Agent conversation:
```
Connect SPSS 26
Configure R statistical software
```

The Agent will auto-detect the software path. **By default it only reports the detected path and does NOT modify `config.json`** (fail-closed / detection-only). To persist the result, opt in explicitly: set `STATSOFT_AUTO_WRITE=1` (non-interactive / agent) or `STATSOFT_CONFIRM=1` and answer `y` at the prompt (interactive).

### Verify Installation

```
Run SPSS syntax: SHOW VERSION.
Convert data.sav to data.dta
```

---

## Use Cases

### 1. Multi-Software Mixed Workflow
Seamlessly invoke R modeling + SPSS descriptive + Stata data prep in a single AI Agent session.

### 2. Historical Code Asset Reuse
Bring R scripts, SPSS syntax, SAS macros, Stata do-files into the AI workflow as standard nodes.

### 3. Data Format Conversion
Stat/Transfer (a supported CLI tool) migrates data between software (SAS ↔ SPSS ↔ Stata ↔ Excel). For general format conversion without statistical software, use the statdata-transfer skill.

### 4. SPSS Statistics Splash-Free Batch
Execute `.sps` syntax via built-in Python engine, skipping splash screen.

### 5. SAS Batch Automation
Schedule SAS macro programs via SAS CLI for periodic reporting.

### 6. SPSS Modeler Batch
Execute `.str` streams via `clemb.exe` in local mode.

> 📚 **Full details for all 34 software packages** → see [`ADDITIONAL_SOFTWARE.md`](./ADDITIONAL_SOFTWARE.md)

---

## Important Notes

Splash Screen: The 34 supported statistical software packages have **varying levels of CLI support**. Some are fully command-line driven, while others may still require GUI interaction during use. The specific behavior varies by software:

- ✅ **Pure CLI, no splash screen** (e.g., R, Stata, SAS, CmdStan, Julia, Gretl, Mathematica)
- ⚠️ **CLI mode with brief splash screen** (e.g., JMP, Minitab, EViews, Statistica)
- 🔴 **GUI required, cannot be avoided** (e.g., AMOS, GraphPad Prism, jamovi, JASP)

After configuration is complete, the AI Agent will provide detailed notifications about the behavior of each software.

---

## Excluded Software

The following software was evaluated but not included due to listed reasons. For data format conversion without statistical software dependency, see the statdata-transfer skill.

| Software | Reason |
|----------|--------|
| Systat | Market severely squeezed by SPSS/R/Python, user base shrinking |
| MaxStat | Niche positioning, very few users, limited functionality |
| SmartPLS | GUI-only, no CLI or batch mode |
| WinBUGS | Fully superseded by OpenBUGS (both Bayesian MCMC sampling) |

---

## Platform Support

### Core Software

| Software | Windows Script | Cross-Platform Script | Verify |
|----------|---------------|----------------------|--------|
| SPSS Statistics | `scripts/windows-only/SPSS/setup_spss.ps1` | — | `stats.com -production silent -nologo "exit.spj"` |
| R | `scripts/windows-only/statsoft-r.ps1` | `scripts/cross-platform/R/setup_r.sh` | `Rscript --version` |
| Stata | — | `scripts/cross-platform/Stata/setup_stata.sh` | `stata-mp -b do "exit"` |
| SAS | `scripts/windows-only/statsoft-sas.ps1` | `scripts/cross-platform/SAS/setup_sas.sh` | `sas -version` |

(Full routing table with all additional software packages — see ADDITIONAL_SOFTWARE.md)

## Project Structure

```
statsoft-cli/
├── SKILL.md                          # Main skill file
├── README_zh-CN.md                   # Chinese README
├── ADDITIONAL_SOFTWARE.md            # Extended software configs
├── LICENSE                           # MIT license
├── config.json.example               # Config template
├── scripts/
│   ├── cross-platform/              # Cross-platform setup scripts
│   │   ├── _platform-detect.sh      # Platform detection
│   │   ├── scan/                    # System scan scripts
│   │   │   └── scan_all.sh          # Batch detection (Linux/Mac/Win)
│   │   ├── R/                       # R setup
│   │   ├── Stata/                   # Stata setup
│   │   ├── SAS/                     # SAS setup
│   │   ├── CmdStan/                 # CmdStan (Bayesian MCMC)
│   │   ├── Weka/                    # Weka (Data Mining)
│   │   ├── KNIME/                   # KNIME (Workflow)
│   │   ├── jamovi/                  # jamovi (Stats)
│   │   ├── JASP/                    # JASP (Stats)
│   │   ├── PSPP/                    # PSPP (SPSS alternative)
│   │   ├── Mplus/                   # Mplus (SEM, Win/Mac)
│   │   ├── JAGS/                    # JAGS (Bayesian MCMC)
│   │   ├── SHAZAM/                  # SHAZAM (Econometrics)
│   │   ├── OxMetrics/               # OxMetrics (Econometrics)
│   │   ├── TSP/                     # TSP (Time Series)
│   │   ├── Tanagra/                 # Tanagra (Data Mining)
│   │   ├── Orange/                  # Orange (Data Mining)
│   │   ├── H2O/                     # H2O.ai (AutoML)
│   │   ├── GenStat/                 # GenStat (Statistics)
│   │   ├── Mathematica/             # Mathematica (Math/Stats)
│   │   ├── Rattle/                  # Rattle (R Data Mining)
│   │   └── OpenBUGS/                # OpenBUGS (Bayesian)
│   └── windows-only/                # Windows-only scripts
│       ├── scan/
│       │   └── scan_all.ps1         # Batch detection (Windows, registry-based)
│       ├── SPSS/                    # SPSS Statistics + Modeler
│       ├── JMP/                     # JMP JSL batch
│       ├── GraphPad/                # GraphPad Prism
│       ├── EViews/                  # EViews econometrics
│       ├── Statistica/              # Statistica data mining
│       ├── StatTransfer/            # Stat/Transfer data conversion
│       ├── Mplus/                   # Mplus (Win/Mac)
│       ├── AMOS/                    # AMOS (SPSS family)
│       ├── Q_MRKS/                  # Q Research (MRKS)
│       ├── Limdep/                  # LIMDEP (Econometrics)
│       ├── NLOGIT/                  # NLOGIT (Discrete Choice)
│       ├── SHAZAM/                  # SHAZAM (Econometrics)
│       ├── Microfit/                # Microfit (Time Series)
│       ├── statsoft-r.ps1           # R Windows wrapper
│       └── statsoft-sas.ps1         # SAS Windows wrapper
├── references/                       # Reference files
│   ├── command-examples.md           # CLI examples
│   ├── version-specifics.md          # Version differences
│   ├── completion-prompts.md         # Completion templates
│   └── config-templates.md           # Config templates
└── tests/                            # Test files

## Usage

This skill activates only on an **explicit, narrowly scoped request** that names the target tool and action (for example `configure R`, `run Stata <file>`, `convert data.sav to data.dta`). Free-form phrases like "configure statistical software" are intentionally not auto-activated for high-risk execution.

Trigger examples (require naming the tool/action):

```
Connect SPSS 26
Configure R statistical software
Convert data.sav to data.dta
Run a Stata .do file in batch mode
```

Before any execution, install, network fetch, or persistent write, the skill requires explicit confirmation (interactive) or an opt-in environment flag (`STATSOFT_AUTO_WRITE=1` / `STATSOFT_CONFIRM=1`). Read-only detection is the default.

Non-trigger examples (treated as ordinary conversation, NOT activated):

```
I read a paper about R
Can you explain what Stata is?
```

## Trust & Safety

This skill executes **high-risk operations** (running local executables, modifying configs, network access). See SKILL.md for full Trust & Safety documentation.

## License

[MIT](LICENSE)
