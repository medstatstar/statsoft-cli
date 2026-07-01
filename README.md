# statsoft-cli

Cross-platform statistical software CLI integration for AI Agent (OpenClaw / ClawHub).

Supports 13 statistical software packages: SPSS, R, Stata, SAS, JMP, GraphPad Prism, EViews, Statistica, Stat/Transfer, Gretl, Minitab, Matlab, Julia.

## Purpose

Many statistical software packages have CLI (Command Line Interface) execution modes, but not everyone knows how to use them. This skill integrates these tools into the AI Agent environment for unified access, enabling statisticians to fully leverage these tools' capabilities. **The core value of this skill lies in activating historical code assets and solving the reusability problem in AI workflow automation**. Over years of project accumulation, teams have gathered reusable analysis code—R modeling scripts, SPSS syntax files, SAS macro programs, Stata do-files—and this skill brings them into a unified execution framework as standard AI workflow nodes.

## Platform Support

| Category | Software |
|----------|----------|
| ✅ Full platform (Win + Mac + Linux) | R, Stata, SAS, Stat/Transfer, Gretl, Matlab, Julia |
| ⚠️ Win + limited Mac/Linux | Minitab |
| 🔴 Windows only | SPSS, JMP, GraphPad Prism, EViews, Statistica |

## Use Cases

1. **Multi-software mixed workflow** — Seamlessly invoke R modeling + SPSS descriptive + Stata data prep in a single AI Agent session
2. **Historical code asset reuse** — Bring R scripts, SPSS syntax, SAS macros, Stata do-files into the AI workflow
3. **Data format conversion** — StatTransfer migrates data between software (SAS ↔ SPSS ↔ Stata ↔ Excel)
4. **SPSS splash-free batch** — Execute .sps syntax via built-in Python engine (spss.StartSPSS), skipping splash screen
5. **SAS batch automation** — Schedule SAS macro programs via SAS CLI for periodic reporting

## Script Routing Table

### Core Software

| Software | Windows Script | Cross-Platform Script | Verify |
|----------|---------------|----------------------|--------|
| SPSS | `windows-only/SPSS/setup_spss.ps1` | — | `spss.exe -production mode "exit.sps"` |
| R | `windows-only/statsoft-r.ps1` | `cross-platform/R/setup_r.sh` | `Rscript --version` |
| Stata | — | `cross-platform/Stata/setup_stata.sh` | `stata-mp -b do "exit"` |
| SAS | `windows-only/statsoft-sas.ps1` | `cross-platform/SAS/setup_sas.sh` | `sas -version` |

(Full routing table with EViews, Statistica, Gretl, Minitab, Matlab, Julia, etc. — see ADDITIONAL_SOFTWARE.md)

## Project Structure

```
statsoft-cli/
├── SKILL.md                          # Main skill file
├── README_zh-CN.md                   # Chinese README
├── ADDITIONAL_SOFTWARE.md            # Extended software configs
├── LICENSE                           # MIT-0
├── config.json.example               # Config template
├── cross-platform/                   # Cross-platform setup scripts
│   ├── _platform-detect.sh           # Platform detection
│   ├── R/setup_r.sh                  # R setup
│   ├── Stata/setup_stata.sh          # Stata setup
│   ├── SAS/setup_sas.sh              # SAS setup
│   └── ...                           # Other cross-platform software
├── windows-only/                     # Windows-only scripts
│   ├── SPSS/                         # SPSS suite (setup + helper + internal)
│   ├── JMP/                          # JMP JSL batch
│   ├── GraphPad/                     # GraphPad Prism
│   ├── EViews/                       # EViews econometrics
│   ├── Statistica/                   # Statistica data mining
│   ├── StatTransfer/                 # Stat/Transfer data conversion
│   ├── statsoft-r.ps1                # R Windows wrapper
│   └── statsoft-sas.ps1              # SAS Windows wrapper
├── references/                       # Reference files
│   ├── command-examples.md           # CLI examples
│   ├── version-specifics.md          # Version differences
│   ├── completion-prompts.md         # Completion templates
│   └── config-templates.md           # Config templates
└── tests/                            # Test files
    ├── test-syntax.sps               # SPSS test syntax
    ├── test-job.spj                  # SPSS production job
    └── README.md                     # Test instructions
```

## Usage

Trigger with natural language in AI Agent conversations:

```
Connect SPSS
Help me configure R command line
Convert data.sav to data.dta
Run Stata do-file
```

## Trust & Safety

This skill executes **high-risk operations** (running local executables, modifying configs, network access). See SKILL.md for full Trust & Safety documentation.

## License

[MIT-0](LICENSE)
