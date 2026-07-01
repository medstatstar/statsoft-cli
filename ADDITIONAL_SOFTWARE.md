# 附加统计软件支持 / Additional Statistical Software Support

本文件包含 `statsoft-cli` 技能新增的统计软件配置信息。

This file contains configuration information for additional statistical software added to the `statsoft-cli` skill.

---

## 目录 / Table of Contents

0. [Script Routing Tables / 完整脚本路由表](#script-routing-tables--完整脚本路由表)
1. [JMP](#jmp)
2. [GraphPad Prism](#graphpad-prism)
3. [Stat/Transfer](#stattransfer)
4. [Gretl](#gretl)
5. [Minitab](#minitab)
6. [Matlab](#matlab)
7. [Julia](#julia)
8. [EViews](#eviews)
9. [Statistica](#statistica)

---

## Script Routing Tables / 完整脚本路由表

### Cross-Platform / 跨平台

| 软件 / Software | 配置脚本 | CLI 包装器 | 验证 / Verify |
|-----------------|----------|-----------|--------------|
| Stat/Transfer | `cross-platform/StatTransfer/setup_stattransfer.sh` | `windows-only/StatTransfer/statsoft-stattransfer.ps1` + `st` (built-in) | `st -v` |
| Gretl | `cross-platform/Gretl/setup_gretl.sh` | `gretlcli` (built-in) | `gretlcli -v` |
| Minitab | `cross-platform/Minitab/setup_minitab.sh` | `Minitab` (built-in) | `Minitab -?` |
| Matlab | `cross-platform/Matlab/setup_matlab.sh` | `matlab -batch` (built-in) | `matlab -batch "exit"` |
| Julia | `cross-platform/Julia/setup_julia.sh` | `julia` | `julia -v` |

### Windows Only / 仅 Windows

| 软件 / Software | 配置脚本 | CLI 包装器 | 验证 / Verify |
|-----------------|----------|-----------|--------------|
| JMP | `windows-only/JMP/setup_jmp.ps1` | `windows-only/JMP/statsoft-jmp.ps1` | `JMP.exe /R "Exit();"` |
| GraphPad | `windows-only/GraphPad/setup_graphpad.ps1` | `windows-only/GraphPad/statsoft-graphpad.ps1` | `prism.exe -help` |
| EViews | `windows-only/EViews/setup_eviews.ps1` | `windows-only/EViews/statsoft-eviews.ps1` | `EViews.exe /?` |
| Statistica | `windows-only/Statistica/setup_statistica.ps1` | `windows-only/Statistica/statsoft-statistica.ps1` | `Statistica.exe /?` |

---

## JMP

### 简介 / Introduction

JMP 是 SAS 旗下的交互式可视化统计软件，支持 JSL 脚本批处理（`/R` 参数），运行时会有短暂闪屏（1-2秒）。

JMP is an interactive visualization statistical software by SAS, supports JSL script batch processing (`/R` parameter), may have brief splash screen (1-2 seconds) when running.

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅（`/R` 参数） | ⚠️ 短暂（1-2秒） |
| macOS | ✅ | ✅（`/R` 参数） | ⚠️ 短暂（1-2秒） |
| Linux | ❌ | ❌ | - |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\SAS\JMP\JMP.exe`
- `C:\Program Files\JMP\JMP\JMP.exe`

**macOS**:
- `/Applications/JMP.app/Contents/MacOS/JMP`

### 批处理命令 / Batch Command

```powershell
# Windows
"JMP.exe" /R "script.jsl"

# macOS
JMP -R "script.jsl"
```

### JSL 脚本模板 / JSL Script Template

```jsl
// script.jsl — JMP 脚本
Clear Log();

// 读取数据
dt = Open("data.csv");

// 分析
[分析平台](
    Y(:column1),
    X(:column2)
);

// 保存结果
Save(dt, "results.jmp");
Close(dt, NoSave);

// 退出（批处理模式）
Exit();
```

### ⚠️ 弹窗问题 / Splash Screen Issue

JMP 是 GUI 应用程序，即使使用 `/R` 批处理模式，运行时仍**可能显示启动闪屏**（splash screen）：
- 闪屏持续时间很短（1-2秒），脚本执行完毕后 JMP 会自动关闭（如果脚本末尾有 `Exit();`）
- **无法完全避免闪屏**，这是 JMP 的设计限制
- 如果完全不能接受闪屏，考虑使用其他统计软件（如 R 或 Python）

### 注意事项 / Notes

- JMP 脚本语言是 JSL（JMP Scripting Language）
- `/R` 参数表示以批处理模式运行脚本
- ⚠️ **脚本末尾必须加 `Exit();`**，否则 JMP GUI 会保持打开
- **与 GraphPad 对比**：
  - GraphPad：完全无 CLI，必须保持 GUI 打开，无法自动化
  - JMP：有 CLI（`/R` 参数），可以批处理，但仍有闪屏

### 配置完成提示 / Configuration Completion Notes

- ⚠️ JMP 运行时会有短暂闪屏（1-2秒），无法完全避免
- ⚠️ 脚本末尾必须加 `Exit();`，否则 JMP GUI 会保持打开
- ✅ 如果可以接受短暂闪屏，JMP CLI 可以正常使用
- ❌ 如果完全不能接受闪屏，考虑使用其他统计软件（如 R 或 Python）
- 💡 可用 JMP 的 `Save` 和 `Close` 命令保存结果并清理临时文件

---

## GraphPad Prism

### 简介 / Introduction

GraphPad Prism 是科学绘图与统计分析软件，**没有 CLI 模式**，调用时会弹出 GUI 界面（无法避免）。

GraphPad Prism is scientific graphing and statistical analysis software, **does not have a CLI mode** — calling it will launch the GUI (unavoidable).

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ❌（无 CLI） | ⚠️⚠️⚠️ 全程 GUI |
| macOS | ✅ | ❌（无 CLI） | ⚠️⚠️⚠️ 全程 GUI |
| Linux | ❌ | ❌ | - |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\GraphPad\Prism 8\prism.exe`
- `C:\Program Files\GraphPad\Prism 9\prism.exe`
- `C:\Program Files\GraphPad\Prism 10\prism.exe`

**macOS**:
- `/Applications/GraphPad Prism.app/Contents/MacOS/GraphPad Prism`

### 调用命令 / Invocation Command

```powershell
# Windows — 会弹出 GUI
"prism.exe" "file.pzfx"
```

⚠️ **重要限制 / Important Limitation**:

GraphPad Prism **没有 CLI 模式**，调用时会弹出 GUI 界面。这与 SPSS（Production Facility）、R（Rscript）、Stata（batch mode）不同。

GraphPad Prism **does not have a CLI mode** — calling it will launch the GUI. This differs from SPSS (Production Facility), R (Rscript), and Stata (batch mode).

### 替代方案 / Alternatives

| 方案 | 说明 |
|------|------|
| Python prismWriter | 后台操作 .pzfx 文件，无需 GUI |
| 手动打开 | 调用后界面弹出，可正常使用 |

| Solution | Description |
|----------|-------------|
| Python prismWriter | Manipulate .pzfx files in background, no GUI needed |
| Manual open | GUI launches after call, fully functional |

### .pzfx 文件说明 / .pzfx File Notes

- GraphPad Prism 的项目文件格式是 .pzfx（XML 格式，可压缩）
- 可用 Python 直接读写 .pzfx 文件内容（需要 `prismWriter` 或手动解析 XML）

### 配置完成提示 / Configuration Completion Notes

- ⚠️⚠️⚠️ GraphPad Prism **没有 CLI 模式**，调用时会弹出 GUI 界面（无法避免）
- ⚠️ 使用时会有以下现象：调用时弹出 GUI 界面，用户需手动操作
- 💡 替代方案：使用 Python `prismWriter` 库后台操作 .pzfx 文件（无需 GUI）

---

## Stat/Transfer

### 简介 / Introduction

Stat/Transfer 是纯 CLI 数据格式转换工具，完全无 GUI，适合自动化。支持 Stata、SPSS、SAS、R、Excel 等格式互转。

Stat/Transfer is a pure CLI data format conversion tool, completely GUI-free, suitable for automation. Supports format conversion between Stata, SPSS, SAS, R, Excel, etc.

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅ | ❌ |
| macOS | ✅ | ✅ | ❌ |
| Linux | ✅ | ✅ | ❌ |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\StatTransfer\st.exe`
- `C:\Program Files (x86)\StatTransfer\st.exe`

**macOS**:
- `/Applications/StatTransfer/st`
- 或 `st`（PATH）

**Linux**:
- `/usr/local/bin/st`
- 或 `st`（PATH）

### 命令行格式 / Command Line Format

```bash
# 单文件转换
"[ST_EXE_PATH]" in.sas7bdat out.dta

# 批量转换
"[ST_EXE_PATH]" in\*.sav out\*.dta

# 命令文件批处理
"[ST_EXE_PATH]" myfile.stcmd
```

### 支持格式 / Supported Formats

| 格式 | 扩展名 |
|------|--------|
| Stata | `.dta` |
| SPSS | `.sav`, `.por` |
| SAS | `.sas7bdat`, `.xpt` |
| R | `.rda`, `.rds` |
| Excel | `.xlsx`, `.xls` |
| CSV | `.csv`, `.tsv` |

### .stcmd 命令文件模板 / .stcmd Command File Template

```
# myfile.stcmd — Stat/Transfer 命令文件
copy in.sas7bdat out.sav

copy in2.dta out2.sav

# 变量选择
keep var1 var2 var3

# 记录筛选
where score > 80
```

### 在 AI 工作流中的角色 / Role in AI Workflow

```
历史数据（.sas7bdat）
      ↓  Stat/Transfer CLI
中间格式（.dta / .sav / .csv）
      ↓  R / Stata / SPSS CLI
分析结果
      ↓  Stat/Transfer CLI
交付格式（.xlsx / .sas7bdat）
```

### 配置完成提示 / Configuration Completion Notes

- ✅ Stat/Transfer 是纯 CLI 工具，完全无 GUI，适合自动化
- ⚠️ 转换前请确认目标格式支持所需的数据类型
- 💡 在 AI 工作流中的角色：数据格式转换桥梁（历史数据 → 中间格式 → 分析结果 → 交付格式）

---

## Gretl

### 简介 / Introduction

Gretl 是免费跨平台计量经济学软件，纯 CLI 支持，完全无闪屏。

Gretl is a free, cross-platform econometrics software with pure CLI support, completely splash-free.

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅ | ❌ |
| macOS | ✅ | ✅ | ❌ |
| Linux | ✅ | ✅ | ❌ |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\gretl\gretlcli.exe`
- `C:\Program Files (x86)\gretl\gretlcli.exe`

**macOS**:
- `/Applications/Gretl.app/Contents/MacOS/gretlcli`（Homebrew 安装）
- 或 `gretlcli`（PATH）

**Linux**:
- `gretlcli`（PATH，通过包管理器安装）

### 批处理命令 / Batch Command

```bash
# 运行脚本
gretlcli -b script.inp

# 示例脚本（script.inp）
open data4-1.gdt
ols y const x1 x2
store results.csv
```

### 配置完成提示 / Configuration Completion Notes

- ✅ Gretl 是纯 CLI 工具，完全无 GUI，无闪屏
- ✅ 免费软件，适合计量经济学分析
- 💡 支持 Stata `.dta`、SAS `.sas7bdat`、Excel `.xlsx` 等格式读取

---

## Minitab

### 简介 / Introduction

Minitab 是工业统计与六西格玛软件，有 CLI 支持（批处理模式），可能有短暂闪屏。

Minitab is an industrial statistics and Six Sigma software, has CLI support (batch mode), may have brief splash screen.

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅（批处理模式） | ⚠️ 短暂 |
| macOS | ⚠️ 有限 | ⚠️ 有限 | ⚠️ 短暂 |
| Linux | ⚠️ 有限 | ⚠️ 有限 | ⚠️ 短暂 |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\Minitab\Minitab 21\Minitab.exe`
- `C:\Program Files\Minitab\Minitab 20\Minitab.exe`

### 批处理命令 / Batch Command

```bash
# 运行 Minitab 宏
"Minitab.exe" "macro.mtb" /Q
```

### 配置完成提示 / Configuration Completion Notes

- ⚠️ Minitab 批处理模式可能有短暂闪屏
- ⚠️ 确保许可证有效
- 💡 适合质量控制和六西格玛项目

---

## Matlab

### 简介 / Introduction

Matlab 是工程计算与统计软件，有 CLI 支持（`-batch` 模式），完全无闪屏（使用 `-batch` 参数时）。

Matlab is an engineering computation and statistics software, has CLI support (`-batch` mode), completely splash-free (when using `-batch` parameter).

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅（`-batch`） | ❌（使用 -batch 时） |
| macOS | ✅ | ✅（`-batch`） | ❌（使用 -batch 时） |
| Linux | ✅ | ✅（`-batch`） | ❌（使用 -batch 时） |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\MATLAB\R2024a\bin\matlab.exe`

**macOS**:
- `/Applications/MATLAB_R2024a.app/bin/matlab`

**Linux**:
- `/usr/local/MATLAB/R2024a/bin/matlab`
- 或 `matlab`（PATH）

### 批处理命令 / Batch Command

```bash
# 运行脚本（无 GUI）
matlab -batch "run('script.m')"

# 或直接执行命令
matlab -batch "x = 1:10; mean(x)"
```

### 配置完成提示 / Configuration Completion Notes

- ✅ 使用 `-batch` 参数时完全无 GUI，无闪屏
- ⚠️ 需要 Statistics and Machine Learning Toolbox 进行统计分析
- 💡 适合工程统计、信号处理和机器学习

---

## Julia

### 简介 / Introduction

Julia 是高性能科学计算语言，纯 CLI 支持，完全无闪屏，适合贝叶斯统计和高性能计算。

Julia is a high-performance scientific computing language, pure CLI support, completely splash-free, suitable for Bayesian statistics and high-performance computing.

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅ | ❌ |
| macOS | ✅ | ✅ | ❌ |
| Linux | ✅ | ✅ | ❌ |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Julia-1.9.4\bin\julia.exe`

**macOS**:
- `/Applications/Julia-1.9.app/Contents/Resources/julia/bin/julia`
- 或 `julia`（PATH，通过 Homebrew 安装）

**Linux**:
- `/usr/local/julia/bin/julia`
- 或 `julia`（PATH）

### 批处理命令 / Batch Command

```bash
# 运行脚本
julia script.jl

# 示例脚本（script.jl）
using Statistics
data = [1, 2, 3, 5, 8]
println("Mean: ", mean(data))
```

### 配置完成提示 / Configuration Completion Notes

- ✅ Julia 是纯 CLI 工具，完全无 GUI，无闪屏
- ✅ 高性能，适合大数据和复杂统计计算
- 💡 常用包：`Statistics`、`HypothesisTests`、`GLM`、`Turing`（贝叶斯）

---

## EViews

### 简介 / Introduction

EViews 是计量经济学时间序列分析软件（Windows-only），有 CLI 支持（批处理模式），可能有闪屏。

EViews is an econometrics time series analysis software (Windows-only), has CLI support (batch mode), may have splash screen.

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅（批处理模式） | ⚠️ 可能有闪屏 |
| macOS | ❌ | ❌ | - |
| Linux | ❌ | ❌ | - |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\EViews\EViews13\EViews.exe`
- `C:\Program Files\EViews 12\EViews.exe`

### 批处理命令 / Batch Command

```bash
# 运行 EViews 程序文件
"EViews.exe" "program.prg" /r
```

### 配置完成提示 / Configuration Completion Notes

- ⚠️ EViews 批处理模式可能有闪屏
- ⚠️ Windows-only，不支持 macOS 和 Linux
- 💡 适合时间序列分析、回归和预测

---

## Statistica

### 简介 / Introduction

Statistica 是数据挖掘与机器学习软件（Windows-only），有 CLI 支持（SVB 脚本批处理），可能有闪屏。

Statistica is a data mining and machine learning software (Windows-only), has CLI support (SVB script batch processing), may have splash screen.

### 平台支持 / Platform Support

| 平台 / Platform | 支持 | CLI 支持 | 闪屏 |
|----------------|------|----------|------|
| Windows | ✅ | ✅（SVB 脚本） | ⚠️ 可能有闪屏 |
| macOS | ❌ | ❌ | - |
| Linux | ❌ | ❌ | - |

### 安装路径 / Installation Paths

**Windows**:
- `C:\Program Files\Statistica\Statistica.exe`
- `C:\Program Files (x86)\Statistica\Statistica.exe`

### 批处理命令 / Batch Command

```bash
# 运行 SVB 脚本
"Statistica.exe" /run "script.svb"
```

### 配置完成提示 / Configuration Completion Notes

- ⚠️ Statistica 批处理模式可能有闪屏
- ⚠️ Windows-only，不支持 macOS 和 Linux
- 💡 适合数据挖掘、机器学习和统计分析

---
