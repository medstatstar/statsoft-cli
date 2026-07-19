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
    "version": "2.6.22",
    "license": "MIT",
    "tags": ["统计软件", "Statistical Software", "CLI", "R", "SPSS", "Stata", "SAS", "Bayesian", "Machine Learning", "Econometrics", "SEM", "Data Mining"],
    "homepage": "https://github.com/medstatstar/statsoft-cli",
    "repository": "https://github.com/medstatstar/statsoft-cli"
  }
---

# Language / 语言

This skill responds in the **user's current input language** (中文 or English) and auto-detects / switches accordingly. / 本技能默认使用**用户当前输入的语言**进行回复（中文 ↔ English 自动切换）。

## Overview / 概述

Activates historical code assets locked in statistical software (syntax, scripts, projects) and wires them into AI workflows via automated detection, configuration, and execution. / 将分散在各统计软件中的历史代码资产（语法、脚本、项目）接入 AI 工作流，实现自动化检测、配置与执行。

## Core Functions / 核心功能

Covers 34+ statistical / data-science packages, auto-routed by platform; non-Windows auto-hides incompatible software:

- **Cross-platform (Win / Mac / Linux, CLI) / 全平台（Win / Mac / Linux，CLI）**: R, Stata, SAS, CmdStan, GenStat, Gretl, H2O.ai, JAGS, Julia, KNIME, Mathematica, Matlab, OpenBUGS, Orange, OxMetrics, PSPP, Rattle, SHAZAM, Stat/Transfer, Tanagra, TSP, Weka
- **Windows + limited cross-platform / Windows + 有限跨平台**: Mplus, Minitab
- **Windows-only CLI / 仅 Windows CLI**: SPSS Statistics, EViews, JMP, LIMDEP, Microfit, NCSS, NLOGIT, Origin, Q(MRKS), SPSS Modeler, Statistica
- **GUI-only detection + manual launch guide / GUI 仅检测 + 手动启动指引**: AMOS, GraphPad Prism, JASP, jamovi (never drive batch via CLI)

Full platform matrix in `references/platform-support.md`; extended config in `ADDITIONAL_SOFTWARE.md`. / 完整平台矩阵见 `references/platform-support.md`；扩展软件配置见 `ADDITIONAL_SOFTWARE.md`。

## Execution Workflow / 执行工作流

1. **Detect Platform / 检测平台** — cross-platform `source scripts/cross-platform/_platform-detect.sh` (sets `$PLATFORM`/`$OS`/`$ARCH`); Windows handled inside `.ps1` scripts, no source
2. **Pre-scan Confirmation / 扫描前确认** — before any scan, MUST prompt and wait / 执行任何扫描前，必须提示用户选择并等待:
   - English: "⚠️ Auto-scan may take a while (~30s on Windows). If you have ≤3 packages, specify paths to skip. Your choice?" Options: A) Auto-scan  B) Specify paths
   - 中文：「⚠️ 自动扫描系统可能耗时较长（Windows 约 30–60 秒）。若已安装软件 ≤3，建议直接指定路径跳过扫描。您的选择？」选项：A) 自动扫描  B) 手工指定路径
   - A → step 3; B → skip scan, go to step 4
3. **System Scan / 系统扫描** (only if A) — batch-detect installed software / 批量检测已安装软件:
   - Windows: `scripts/windows-only/scan/scan_all.ps1`; Mac/Linux: `scripts/cross-platform/scan/scan_all.sh`
   - Output JSON: `{"R":{"installed":true,"path":"...","version":"..."},...}`
   - By default only the `installed` boolean is returned; path / version disclosed only with `STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1`+interactive y (note: `STATSOFT_REVEAL` controls per-software setup-time output only, not batch scan results) / 默认仅回传 `installed` 布尔值；路径 / 版本需 `STATSOFT_AUTO_WRITE=1` 或 `STATSOFT_CONFIRM=1`+交互 y 才披露（`STATSOFT_REVEAL` 仅控制单个软件 setup 检测期输出，不控制扫描批量结果）
4. **Select Config Mode / 选择配置模式**: batch / specified / single-software (calls individual `setup_*.ps1` or `setup_*.sh`)
5. **Detect & Setup / 检测与配置** — route to the platform script; non-Windows auto-hides incompatible software
6. **Save Config / 保存配置** — detect-only by default; writes `config.json` only with explicit authorization (`STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1` + interactive y)
7. **Output Summary / 输出完成摘要** — per `references/completion-prompts.md` template

## Default-Deny Gates / 默认拒绝闸门

All persistence and sensitive operations are **off by default** and require explicit authorization (fail-closed), consistent with the scripts:

| Gate / 闸门 | Effect / 作用 | Default / 默认值 |
|-------------|---------------|------------------|
| `STATSOFT_AUTO_WRITE=1` | Persist `config.json` (non-interactive / agent context) / 持久化 `config.json`（非交互 / agent 上下文） | off / 关闭 |
| `STATSOFT_CONFIRM=1` + TTY y | Persist after interactive confirmation / 交互式确认后持久化 | off / 关闭 |
| `STATSOFT_REVEAL=1` | Reveal path / version details during detection / 检测期披露路径 / 版本等细节 | off / 关闭 |
| `STATSOFT_VERIFY=1` | Allow launching third-party binaries for version / verification / 允许启动第三方二进制做版本 / 校验 | off / 关闭 |
| `STATSOFT_CMDSTAN_RUN=1` | Allow compiling & running user Stan models (untrusted native code) / 允许编译并运行用户 Stan 模型（不可信原生代码） | off / 关闭 |

All writes go through `scripts/common/write_config.py`: accepts only the canonical `config.json` under the skill root, and before writing takes a timestamped backup (`config.json.bak.yyyymmdd_hhmmss`) then atomic-replaces. / 写入统一由 `scripts/common/write_config.py` 执行：仅接受技能根目录的规范 `config.json` 为目标，写入前先做时间戳备份（`config.json.bak.yyyymmdd_hhmmss`）再原子替换。

## Core Permissions / 核心权限

- **Local file read-write / 本地文件读写** — `config.json`, temp scripts
- **Process execution / 进程执行** — statistical software binaries
- **Network access / 网络访问** — CRAN / Anaconda repos

## Trust & Safety / 信任与安全

This skill performs high-risk operations; understand the risk levels before use / 本技能执行高风险操作，使用前请了解风险等级:

| Risk / 风险 | Level / 等级 |
|-------------|--------------|
| Execute local executables / 执行本地可执行文件 | 🔴 High / 高 |
| Download & install software / 下载与安装软件 | 🔴 High / 高 |
| Execute user scripts / 执行用户脚本 (e.g. `.sps` via SPSS Python) | 🔴 High / 高 |
| Modify config.json / 修改 config.json | 🟡 Medium / 中 |
| Network access / 网络访问 | 🟡 Medium / 中 |

**Pre-flight / 飞行前检查**: ✅ review all scripts; ✅ confirm config.json changes (auto-backup); ✅ confirm any downloads; ✅ inspect generated commands for sensitive projects. / ✅ 审查所有脚本；✅ 确认 config.json 变更（自动备份）；✅ 确认任何下载任务；✅ 敏感项目需检查生成命令。

## Reference Files / 参考文件

- `ADDITIONAL_SOFTWARE.md` — extended software config (31 packages) / 扩展软件配置（31 款）
- `references/command-examples.md` — per-software CLI command examples / 各软件 CLI 命令示例
- `references/version-specifics.md` — version differences / 版本差异
- `references/completion-prompts.md` — completion prompt templates / 完成提示模板
- `references/trust-and-safety.md` — risk levels & pre-flight details / 风险等级与飞行前检查详情
- `references/workflow.md` — workflow gating details / 工作流闸门细节
- `references/platform-support.md` — full platform support matrix / 完整平台支持矩阵
- `tests/` — automated test scripts / 自动化测试脚本
