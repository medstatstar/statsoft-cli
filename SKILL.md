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
    "version": "2.6.21",
    "license": "MIT",
    "tags": ["统计软件", "Statistical Software", "CLI", "R", "SPSS", "Stata", "SAS", "Bayesian", "Machine Learning", "Econometrics", "SEM", "Data Mining"],
    "homepage": "https://github.com/medstatstar/statsoft-cli",
    "repository": "https://github.com/medstatstar/statsoft-cli"
  }
---

# 语言 / Language

本技能默认使用**用户当前输入的语言**进行回复（中文 ↔ English 自动切换）。

This skill responds in the **user's current input language** (中文 or English). It auto-detects and switches accordingly.

## 概述 / Overview

将分散在各统计软件中的历史代码资产（语法、脚本、项目）接入 AI 工作流，实现自动化检测、配置与执行。

Activates historical code assets locked in statistical software (syntax, scripts, projects) and wires them into AI workflows via automated detection, configuration, and execution.

## 核心功能 / Core Functions

覆盖 34+ 款统计 / 数据科学软件，按平台自动路由，非 Windows 自动隐藏不兼容软件：

- **全平台（Win / Mac / Linux，CLI）**：R、Stata、SAS、CmdStan、GenStat、Gretl、H2O.ai、JAGS、Julia、KNIME、Mathematica、Matlab、OpenBUGS、Orange、OxMetrics、PSPP、Rattle、SHAZAM、Stat/Transfer、Tanagra、TSP、Weka
- **Windows + 有限跨平台**：Mplus、Minitab
- **仅 Windows CLI**：SPSS Statistics、EViews、JMP、LIMDEP、Microfit、NCSS、NLOGIT、Origin、Q(MRKS)、SPSS Modeler、Statistica
- **GUI 仅检测 + 手动启动指引**：AMOS、GraphPad Prism、JASP、jamovi（绝不通过 CLI 驱动其批处理）

完整平台矩阵见 `references/platform-support.md`；扩展软件配置见 `ADDITIONAL_SOFTWARE.md`。

## 执行工作流 / Execution Workflow

1. **检测平台 / Detect Platform** — 跨平台 `source scripts/cross-platform/_platform-detect.sh`（设置 `$PLATFORM`/`$OS`/`$ARCH`）；Windows 由 `.ps1` 脚本内部处理，不 source 此文件
2. **扫描前确认 / Pre-scan Confirmation** — 执行任何扫描前，必须提示用户选择并等待确认 / Before any scan, MUST prompt and wait：
   - 中文：「⚠️ 自动扫描系统可能耗时较长（Windows 约 30–60 秒）。若已安装软件 ≤3，建议直接指定路径跳过扫描。您的选择？」选项：A) 自动扫描  B) 手工指定路径
   - English: "⚠️ Auto-scan may take a while (~30s on Windows). If you have ≤3 packages, specify paths to skip. Your choice?" Options: A) Auto-scan  B) Specify paths
   - 选 A → 进入第 3 步；选 B → 跳过扫描，直接进入第 4 步
3. **系统扫描 / System Scan**（仅当选 A）— 批量检测已安装软件 / Batch detect installed software：
   - Windows：`scripts/windows-only/scan/scan_all.ps1`；Mac/Linux：`scripts/cross-platform/scan/scan_all.sh`
   - 输出 JSON：`{"R":{"installed":true,"path":"...","version":"..."},...}`
   - 默认仅回传 `installed` 布尔值；路径 / 版本需 `STATSOFT_AUTO_WRITE=1` 或 `STATSOFT_CONFIRM=1`+交互 y 才披露（注：`STATSOFT_REVEAL` 仅控制单个软件的 setup 检测期输出，不控制扫描批量结果）
4. **选择配置模式 / Select Config Mode**：批量 / 指定 / 单软件（调用单个 `setup_*.ps1` 或 `setup_*.sh`）
5. **检测与配置 / Detect & Setup** — 按平台路由到对应脚本，非 Windows 自动隐藏不兼容软件
6. **保存配置 / Save Config** — 默认仅检测；仅当用户显式授权（`STATSOFT_AUTO_WRITE=1` 或 `STATSOFT_CONFIRM=1` + 交互 y）才写入 `config.json`
7. **输出完成摘要 / Output Summary** — 按 `references/completion-prompts.md` 模板输出

## 默认拒绝闸门 / Default-Deny Gates

所有持久化与敏感操作**默认关闭**，需显式授权才执行（fail-closed），与脚本实现一致：

| 闸门 / Gate | 作用 / Effect | 默认值 / Default |
|-------------|---------------|------------------|
| `STATSOFT_AUTO_WRITE=1` | 持久化 `config.json`（非交互 / agent 上下文） | 关闭 / off |
| `STATSOFT_CONFIRM=1` + TTY 回答 y | 交互式确认后持久化 | 关闭 / off |
| `STATSOFT_REVEAL=1` | 检测期披露路径 / 版本等细节 | 关闭 / off |
| `STATSOFT_VERIFY=1` | 允许启动第三方二进制做版本 / 校验 | 关闭 / off |
| `STATSOFT_CMDSTAN_RUN=1` | 允许编译并运行用户 Stan 模型（不可信原生代码） | 关闭 / off |

写入统一由 `scripts/common/write_config.py` 执行：仅接受技能根目录的规范 `config.json` 为目标，写入前先做时间戳备份（`config.json.bak.yyyymmdd_hhmmss`）再原子替换。

## 核心权限 / Core Permissions

- **本地文件读写 / Local file read-write** — `config.json`、临时脚本
- **进程执行 / Process execution** — 统计软件二进制
- **网络访问 / Network access** — CRAN / Anaconda 仓库

## 信任与安全 / Trust & Safety

本技能执行高风险操作，使用前请了解风险等级 / This skill performs high-risk operations:

| 风险 / Risk | 等级 / Level |
|-------------|--------------|
| 执行本地可执行文件 / Execute local executables | 🔴 高 / High |
| 下载与安装软件 / Download & install software | 🔴 高 / High |
| 执行用户脚本 / Execute user scripts（如 `.sps` 经 SPSS Python） | 🔴 高 / High |
| 修改 config.json / Modify config.json | 🟡 中 / Medium |
| 网络访问 / Network access | 🟡 中 / Medium |

**飞行前检查 / Pre-flight**：✅ 审查所有脚本；✅ 确认 config.json 变更（自动备份）；✅ 确认任何下载任务；✅ 敏感项目需检查生成命令。

## 参考文件 / Reference Files

- `ADDITIONAL_SOFTWARE.md` — 扩展软件配置（31 款）/ Extended software config
- `references/command-examples.md` — 各软件 CLI 命令示例 / CLI examples
- `references/version-specifics.md` — 版本差异 / Version differences
- `references/completion-prompts.md` — 完成提示模板 / Completion templates
- `references/trust-and-safety.md` — 风险等级与飞行前检查详情 / Risk & pre-flight detail
- `references/workflow.md` — 工作流闸门细节 / Workflow gating detail
- `references/platform-support.md` — 完整平台支持矩阵 / Full platform matrix
- `tests/` — 自动化测试脚本 / Automated tests
