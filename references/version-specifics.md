# Version & Platform Specifics / 版本与平台细节

> Reference for version differences across statistical software.

---

## Platform Support Summary / 平台支持摘要

| Software | Windows | macOS | Linux |
|----------|---------|-------|-------|
| R | ✅ | ✅ | ✅ |
| Stata | ✅ | ✅ | ✅ |
| SAS | ✅ | ✅ | ✅ |
| StatTransfer | ✅ | ✅ | ❌ |
| Gretl | ✅ | ✅ | ✅ |
| Matlab | ✅ | ✅ | ✅ |
| Mathematica | ✅ | ✅ | ✅ |
| Julia | ✅ | ✅ | ✅ |
| Minitab | ✅ | ⚠️ | ⚠️ |
| SPSS Statistics | ✅ | ❌ | ❌ |
| SPSS Modeler | ✅ | ❌ | ❌ |
| JMP | ✅ | ⚠️ | ⚠️ |
| GraphPad Prism | ✅ | ❌ | ❌ |
| EViews | ✅ | ❌ | ❌ |
| Statistica | ✅ | ❌ | ❌ |
| CmdStan | ✅ | ✅ | ✅ |
| Weka | ✅ | ✅ | ✅ |
| KNIME | ✅ | ✅ | ✅ |
| jamovi | ✅ | ✅ | ✅ |
| JASP | ✅ | ✅ | ✅ |
| PSPP | ✅ | ✅ | ✅ |
| Mplus | ✅ | ✅ | ❌ |
| AMOS (IBM) | ✅ | ❌ | ❌ |
| Q / MRKS | ✅ | ❌ | ❌ |
| JAGS | ✅ | ✅ | ✅ |
| SHAZAM | ✅ | ✅ | ✅ |
| OxMetrics | ✅ | ✅ | ✅ |
| TSP | ✅ | ✅ | ✅ |
| Tanagra | ✅ | ✅ | ✅ |
| Orange | ✅ | ✅ | ✅ |
| H2O.ai | ✅ | ✅ | ✅ |
| GenStat | ✅ | ✅ | ✅ |
| Rattle | ✅ | ✅ | ✅ |
| OpenBUGS | ✅ | ✅ | ✅ |
| LIMDEP | ✅ | ❌ | ❌ |
| NLOGIT | ✅ | ❌ | ❌ |
| Microfit | ✅ | ❌ | ❌ |

---

## SPSS Statistics Version Differences / SPSS Statistics 版本差异

| Version | Bundled Python | f-string Support |
|---------|---------------|-----------------|
| 26 | Python 3.4 | ❌ |
| 27 | Python 3.8 | ✅ |
| 28 | Python 3.9 | ✅ |
| 29 | Python 3.10.4 | ✅ |
| 30 | Python 3.10 | ✅ |

### spss_helper.py Compatibility / spss_helper.py 兼容性

- SPSS Statistics 26: Script uses `%s` / `.format()`, no f-string
- SPSS Statistics 27+: Script can use f-string and modern Python

---

## SPSS Modeler Version Differences / SPSS Modeler 版本差异

| Version | clemb.exe Path | Notes |
|---------|---------------|-------|
| 18.6 | `...\Modeler\18.6\bin\clemb.exe` | Latest, Python scripting |
| 18.5 | `...\Modeler\18.5\bin\clemb.exe` | Performance improvements |
| 18.0 | `...\Modeler\18.0\bin\clemb.exe` | Classic stable |

### clemb.exe Common Arguments / clemb.exe 常用参数

```
-local          Run in local mode (batch recommended)
-stream <file>  Load and execute .str stream file
-script <file>  Load and execute Python script
-project <file> Load project
-execute        Execute loaded stream/script
-log <file>     Redirect log to file
-server         Server mode (requires Modeler Server)
-hostname <h>   Server address
-port <n>       Server port
-username <n>   Username
-password <p>   Password
```

---

## CmdStan Version Differences / CmdStan 版本差异

| Version | Notes |
|---------|-------|
| 2.30+ | Latest, improved threading, pathfinder |
| 2.28+ | Improved HMC adaptation |
| 2.26+ | Generated quantities redesign |

### CmdStan CLI Usage / CmdStan CLI 用法

```bash
# Compile model
cd $CMDSTAN && make /path/to/model

# Run sampling
./model sample num_samples=2000 num_warmup=1000 data file=init.csv output file=out.csv

# Summary
stansummary out.csv
```

---

## Weka CLI Usage / Weka CLI 用法

```bash
# Run filter/from command line
java -cp $WEKA_HOME/weka.jar weka.filters.unsupervised.attribute.StringToWVector \
  -i input.arff -o output.arff

# Classifier
java -cp $WEKA_HOME/weka.jar weka.classifiers.trees.RandomForest \
  -t train.arff -T test.arff -p 0
```

---

## KNIME Batch Usage / KNIME 批处理用法

```bash
# Headless batch mode
knime -nosplash -application org.knime.product.KNIME_BATCH_APPLICATION \
  -workflowFile=/path/to/workflow.knwf \
  -workflow.variable=threshold,0.5,double

# CLI only (KNIME Server)
knime -nosplash -application org.knime.product.KNIME_BATCH_APPLICATION \
  -workflowDir=/path/to/workflow_directory
```

---

## Mplus Version Differences / Mplus 版本差异

| Version | Notes |
|---------|-------|
| 8.11 | Latest (2025) |
| 8.10 | BCH method for mixture models |
| 8.8 | Improved multilevel |
| 8.0 | Baseline |

### Mplus CLI Usage / Mplus CLI 用法

```bash
# Batch mode — create .inp file with DATA/FILEDATA/SAVEDATA/OUTPUT
# Then:
mplus model.inp

# Example .inp file:
TITLE: My analysis
FILEDATA: FILE IS data.dat;
MODEL: y ON x1 x2;
OUTPUT: MODINDICES STANDARDIZED;
SAVEDATA: FILE IS results.dat;
```

---

## Stata Version Differences / Stata 版本差异

| Version | Windows Batch Flag | Mac/Linux Batch Flag |
|---------|-------------------|---------------------|
| ≤ 12 | `/e do "script.do"` | `-e do "script.do"` |
| ≥ 13 | `/b do "script.do"` | `-b do "script.do"` |

---

## R Version Differences / R 版本差异

| R Version | Bundled Python | SPSS Equivalent |
|-----------|---------------|-----------------|
| 3.4 | Python 3.4 | SPSS Statistics 26 |
| 3.5+ | Python 3.7+ | SPSS Statistics 27+ |
| 4.0+ | Python 3.9+ | SPSS Statistics 30+ |

---

## SAS Version Differences / SAS 版本差异

| Platform | Batch Mode |
|----------|-----------|
| Windows | `sas -sysin "prog.sas" -log "out.log" -print "out.lst"` |
| Linux | `sas -sysin "prog.sas" -log "out.log" -print "out.lst"` |
| macOS | `sas -sysin "prog.sas" -log "out.log" -print "out.lst"` |

---

## JMP Version Differences / JMP 版本差异

| Version | Extension | Batch Command |
|---------|-----------|--------------|
| 14/15/16 | `.jsl` | `JMP.exe /R "script.jsl"` |
| 16 Pro | `.jsl` | `JMP.exe /S /R "script.jsl"` |
| JMP Live | Web-based | Web API |

---

## jamovi Version Differences / jamovi 版本差异

| Version | Notes |
|---------|-------|
| 2.4+ | Latest, Rj module support |
| 2.3+ | Improved syntax export |

### jamovi Execution / jamovi 执行

> ⚠️ jamovi has **no pure CLI mode** and cannot run silently/batch. This skill provides detection and manual GUI-launch guidance only (GUI-only).

**Alternative (R script, no GUI)**: Use the `jmv` R package to run jamovi modules in the background:
```r
library(jmv)
descriptives <- jmv::descriptives(data = mydata, vars = c("var1", "var2"))
```

---

## JASP Version Differences / JASP 版本差异

| Version | Notes | CLI Status |
|---------|-------|-----------|
| 0.18+ | Latest | ⚠️ No stable CLI (GUI-only) |
| 0.16+ | Improved modules | ⚠️ Limited CLI |

### JASP Execution / JASP 执行

> ⚠️ JASP has **no pure CLI mode** and cannot run silently/batch. This skill provides detection and manual GUI-launch guidance only (GUI-only).

> This skill does NOT automate JASP via R/jaspTools in the background — JASP is GUI-only; detection + manual-launch guidance only.

---

## PSPP Version Differences / PSPP 版本差异

| Version | Notes |
|---------|-------|
| 2.0+ | Latest, improved compatibility |
| 1.6+ | Added GLM |

### PSPP CLI Usage / PSPP CLI 用法

```bash
# Run .sps syntax
pspp -o output.txt analysis.sps

# Pipe mode
pspp < analysis.sps
```

---

## AMOS Version Differences / AMOS 版本差异

| Version | Notes |
|---------|-------|
| 29.0 | Latest (SPSS Statistics 29 bundle) |
| 28.0 | Improved multi-group |
| 27.0 | Baseline |

### AMOS Execution / AMOS 执行

> ⚠️ AMOS has **no CLI mode** and cannot run silently/batch. This skill provides detection and manual GUI-launch guidance only (GUI-only).

> AMOS is GUI-only; this skill provides NO background automation (including any script shown in reference docs). For automation, the user must write it themselves outside this skill's scope.

---

## Q (MRKS) Version Differences / Q (MRKS) 版本差异

| Version | Notes |
|---------|-------|
| 6.0+ | Latest |
| 5.5+ | Improved R integration |

### Q Batch Usage / Q 批处理用法

```batch
REM Run QScript
Q.exe /QScript "c:\scripts\analysis.qs"
```

---

## Mathematica Version Differences / Mathematica 版本差异

| Version | Notes |
|---------|-------|
| 14.0 | Latest (2024), improved WolframScript |
| 13.0 | Baseline for modern Wolfram Language |
| 12.0 | First version with full WolframScript support |

### Mathematica CLI Usage / Mathematica CLI 用法

```bash
# Run Wolfram Language script
wolframscript -file script.wl

# Execute code directly
wolframscript -code "Table[i^2, {i, 10}]"

# Windows explicit MathKernel call
"C:\Program Files\Wolfram Research\Mathematica\14.0\MathKernel.exe" -noprompt < script.m
```

### Mathematica Common Errors / Mathematica 常见错误

| Error | Solution |
|-------|----------|
| `wolframscript not found` | Add Mathematica to PATH or use full path |
| License activation required | Run Mathematica GUI once to activate |
| `MathKernel` hangs | Use `-noprompt` flag for batch mode |

---

## Common Errors & Solutions / 常见错误与解决方案

| Software | Error | Solution |
|----------|-------|----------|
| SPSS Statistics | NullPointerException | Add `<output>` to .spj XML |
| SPSS Statistics | UnicodeDecodeError | Use `cp1252` or `errors='replace'` |
| SPSS Statistics | F-string error (v26) | Use `%s` formatting |
| SPSS Modeler | Stream not found | Verify file path and .str extension |
| CmdStan | `stanc` not found | Set CMDSTAN env var, run setup |
| CmdStan | Compilation fails | Check C++ toolchain |
| Weka | Out of memory | Use `-Xmx` JVM flag with Java |
| KNIME | `-workflowDir` not recognized | Update to KNIME 4.7+ |
| Mplus | License not found | Check license file |
| Mplus | Model not found | Verify .inp file and data path |
| Stata | Confirmation dialog | Loop: v≤12 → `/e`, v≥13 → `/b` |
| R | Package not installed | `install.packages()` |
| SAS | License expired | Update license file |

---

## JAGS Version Differences / JAGS 版本差异

| Version | Notes |
|---------|-------|
| 4.3.0 | Latest stable |
| 4.2.0 | Improved parallel chain support |

### JAGS CLI Usage / JAGS CLI 用法

```bash
# Run JAGS script
jags scriptfile

# Batch execution
jags-script script.txt

# With R interface
Rscript -e "library(rjags); jags.model('script.dat', data)"
```

### JAGS Common Errors / JAGS 常见错误

| Error | Solution |
|-------|----------|
| `Cannot find JAGS` | Install JAGS |
| Syntax error in model | Check BUGS syntax |
| MCMC did not converge | Increase burn-in and iterations |

---

## SHAZAM Version Differences / SHAZAM 版本差异

| Version | Notes |
|---------|-------|
| 12.0 | Latest, improved command language |
| 11.0 | Baseline |

### SHAZAM CLI Usage / SHAZAM CLI 用法

```bash
# Run SHAZAM command file
shazam commands.txt

# Sample command file content:
# /MODEL TITLE MYMODEL
# / X 1 100
# / PREDICT Y
# /END
```

---

## OxMetrics Version Differences / OxMetrics 版本差异

| Version | Notes |
|---------|-------|
| 8.0 | Latest (Ox 8) |
| 7.0 | Baseline |

### OxMetrics CLI Usage / OxMetrics CLI 用法

```bash
# Show CLI options
oxmetrics --help

# Run batch
oxmetrics -b commands.txt
```

---

## TSP Version Differences / TSP 版本差异

| Version | Notes |
|---------|-------|
| 5.0 | Latest |
| 4.5 | Baseline |

### TSP CLI Usage / TSP CLI 用法

```bash
# Run TSP command file
tsp commands.txt
```

---

## Tanagra Version Differences / Tanagra 版本差异

| Version | Notes |
|---------|-------|
| 1.8 | Latest |
| 1.5 | Baseline |

### Tanagra CLI Usage / Tanagra CLI 用法

```bash
# Show CLI options
tanagra --help

# Execute batch script
tanagra -f script.txt
```

---

## Orange Version Differences / Orange 版本差异

| Version | Notes |
|---------|-------|
| 3.36 | Latest |
| 3.30 | Baseline |

### Orange CLI Usage / Orange CLI 用法

```bash
# Show CLI options (GUI mode)
orange-canvas --help

# Python module approach (recommended) / Python 模块方式（推荐）
python3 -m Orange.canvas
```

### Orange Common Errors / Orange 常见错误

| Error | Solution |
|-------|----------|
| Module not found | `pip install orange3` |
| Conda issues | `conda install -c condaforge orange3` |

---

## H2O.ai Version Differences / H2O.ai 版本差异

| Version | Notes |
|---------|-------|
| 3.44 | Latest |
| 3.40 | AutoML improvements |

### H2O CLI Usage / H2O CLI 用法

```bash
# Show CLI options
h2o --help

# Start H2O server
h2o start

# Via Python (recommended)
python3 -c "import h2o; h2o.init()"
```

### H2O Common Errors / H2O 常见错误

| Error | Solution |
|-------|----------|
| Server not starting | Check Java, `java -version` |
| Out of memory | Set `-Xmx` in `h2o.start()` |
| Port conflict | Change port: `h2o.init(port=54322)` |

---

## GenStat Version Differences / GenStat 版本差异

| Version | Notes |
|---------|-------|
| 23.0 | Latest |
| 22.0 | Baseline |

### GenStat CLI Usage / GenStat CLI 用法

```bash
# Show CLI options
genstat --help

# Run GenStat command file
genstat commands.txt
```

---

## Rattle Version Differences / Rattle 版本差异

| Version | Notes |
|---------|-------|
| 5.5 | Latest |
| 5.0 | Baseline |

### Rattle CLI Usage / Rattle CLI 用法

```bash
# Run Rattle in CLI mode
rattle --cli

# Via R package
Rscript -e "library(rattle); rattle()"
```

---

## OpenBUGS Version Differences / OpenBUGS 版本差异

| Version | Notes |
|---------|-------|
| 3.2.3 | Latest stable |
| 3.2.2 | Baseline |

### OpenBUGS CLI Usage / OpenBUGS CLI 用法

```bash
# Show CLI options
openbugs --help

# Batch execution via script
openbugs -b script.txt
```

---

## LIMDEP Version Differences / LIMDEP 版本差异

| Version | Notes |
|---------|-------|
| 11.0 | Latest |
| 10.0 | Baseline |

### LIMDEP CLI Usage / LIMDEP CLI 用法

```batch
REM Run LIMDEP command file
limdep commands.txt
```

### LIMDEP Common Errors / LIMDEP 常见错误

| Error | Solution |
|-------|----------|
| License not found | Check license file |
| Data not found | Verify data path in command file |

---

## NLOGIT Version Differences / NLOGIT 版本差异

| Version | Notes |
|---------|-------|
| 6.0 | Latest |
| 5.0 | Discrete choice improvements |

### NLOGIT CLI Usage / NLOGIT CLI 用法

```batch
REM Run NLOGIT command file
nlogit commands.txt
```

### NLOGIT Common Errors / NLOGIT 常见错误

| Error | Solution |
|-------|----------|
| Model not converging | Check starting values |
| Sample size mismatch | Verify data dimensions |

---

## Microfit Version Differences / Microfit 版本差异

| Version | Notes |
|---------|-------|
| 5.0 | Latest |
| 4.0 | Baseline |

### Microfit CLI Usage / Microfit CLI 用法

```batch
REM Run Microfit command file
microfit commands.txt
```

---

## NCSS

### Platform Support / 平台支持

| Platform | Supported | CLI Support | Splash |
|----------|-----------|-------------|--------|
| Windows | ✅ | ✅ (/B parameter) | ❌ |
| macOS | ❌ | ❌ | — |
| Linux | ❌ | ❌ | — |

### Version Differences / 版本差异

| Version | Notes |
|---------|-------|
| 2024 | Latest, batch mode support |
| 2023 | Baseline |

### NCSS Invocation / NCSS 调用

> ⚠️ Reference only — this skill provides detection + manual-launch guidance for NCSS and does NOT auto-execute its CLI. To run batch analysis manually:
> `"NCSS.exe" /B "analysis.ncss"`

---

## Origin (OriginLab)

### Platform Support / 平台支持

| Platform | Supported | CLI Support | Splash |
|----------|-----------|-------------|--------|
| Windows | ✅ | ✅ (-h parameter) | ❌ |
| macOS | ✅ | ⚠️ Limited | ⚠️ May have |
| Linux | ❌ | ❌ | — |

### Version Differences / 版本差异

| Version | Notes |
|---------|-------|
| 2025 | Latest, improved LabTalk support |
| 2024 | Baseline |
| 2023 | Older versions may have limited CLI support |

### Origin Invocation / Origin 调用

> ⚠️ Reference only — this skill provides detection + manual-launch guidance for Origin and does NOT auto-execute its CLI. To run a LabTalk script manually:
> `origin97 -h script.ogs`