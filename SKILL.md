---
name: statsoft-cli
description: "Cross-platform statistical software CLI integration for AI Agent. Supports R, Stata, SAS, SPSS, JMP, GraphPad Prism, and Stat/Transfer. Auto-detects platform, hides incompatible software, bilingual (中文/English)."
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
    "authors": ["medstatstar", "phoe-zip"],
    "version": "1.4.0",
    "license": "MIT",
    "tags": ["SPSS", "R", "SAS", "Stata", "JMP", "GraphPad", "StatTransfer", "统计软件", "Statistical Software", "Data Analysis", "Data Conversion", "CLI"]
  }
---

# 🛡️ Trust & Safety / 信任与安全

本技能执行**高风险操作**，使用前请了解风险等级 / This skill performs **high-risk operations**. Understand risk levels before use:

| 风险 / Risk | 等级 / Level | 说明 / Description |
|-------------|--------------|-------------------|
| 执行本地可执行文件 / Execute local executables | 🔴 高/High | Launches detected statistical software (e.g., `stats.exe`, `Rscript.exe`) |
| 下载与安装软件 / Download & install software | 🔴 高/High | Fetches R installer from CRAN, Anaconda installer from Anaconda repos |
| 修改 config.json / Modify config.json | 🟡 中/Medium | Writes software paths, backs up existing config |
| 设置环境变量 / Set environment variables | 🟡 中/Medium | Persists `STATSOFT_*` paths in user environment |
| 执行用户脚本 / Execute user-provided scripts | 🔴 高/High | Runs `.sps` content via SPSS Python, creating temporary wrapper scripts |
| 写入 MEMORY.md / Write to MEMORY.md | 🟡 中/Medium | Stores environment info in agent memory |
| 网络访问 / Network access | 🟡 中/Medium | Downloads installers from CRAN, Anaconda repositories |

**所需权限 / Permissions**: 本地文件读写 (config.json, temporary scripts)、进程执行 (statistical software binaries)、环境变量修改 (user-scoped)、网络访问 (CRAN/Anaconda repositories)。

**飞行前检查 / Pre-flight**: ✅ 审查所有脚本；✅ 确认 config.json 变更（自动备份）；✅ 确认任何下载任务；✅ 敏感项目需检查生成命令。

---

## Purpose / 技能目的

很多统计软件都有 CLI（命令行）执行方式，但并不是每个人都会使用。本技能的目的是将这些统计软件整合到 AI 智能体环境下统一使用，从而方便统计师充分利用这些统计软件的能力。**本技能的核心价值在于盘活历史代码资产，解决 AI 工作流自动化中的可复用性难题**。在长期的项目积累中，团队已经沉淀了大量可复用的分析代码——R 的统计建模脚本、SPSS 的语法文件、SAS 的宏程序、Stata 的 do-file 等。然而，当试图将这些历史资产直接接入 AI 自动化工作流时，就需要分别提供每种统计软件合适的调用接口。本技能正是要解决这个问题——通过 AI 智能体将这些历史代码纳入统一的执行框架，使得这些代码可以作为 AI 工作流中的一个标准节点，被反复调用、组合和编排。

Many statistical software packages have CLI (Command Line Interface) execution modes, but not everyone knows how to use them. This skill integrates these statistical software packages into the AI Agent environment for unified access, enabling statisticians to fully leverage these tools' capabilities. From a deeper perspective, **the core value of this skill is integrating and leveraging all statistical software resources and historical assets within AI workflows**. Over years of project accumulation, teams have gathered a wealth of reusable analysis code—R statistical modeling scripts, SPSS syntax files, SAS macro programs, Stata do-files, and more. However, when attempting to plug these historical assets directly into AI automation workflows, the challenge emerges: each statistical software requires its own appropriate invocation interface. This skill addresses exactly this issue—through the AI Agent, it brings historical code into a unified execution framework, enabling these codes to serve as standard nodes in AI workflows, repeatedly callable, composable, and schedulable.

---

## Platform Support / 平台支持

| 类别 / Category | 软件 / Software |
|-----------------|-----------------|
| ✅ 全部平台 (Win + Mac + Linux) | R, Stata, SAS, Stat/Transfer, Gretl, Matlab, Julia |
| ⚠️ Win + 有限 Mac/Linux | Minitab |
| 🔴 Windows only | SPSS, JMP, GraphPad Prism, EViews, Statistica |

*(详细平台支持及路径参考 `ADDITIONAL_SOFTWARE.md`)*

---

## Execution Workflow / 执行工作流

1. **检测平台 / Detect Platform** — `source cross-platform/_platform-detect.sh`
2. **收集信息 / Gather Info** — 先询问用户软件类型与路径，不知路径则自动搜索
3. **选择模式 / Select Mode** — Simple（每文件一条命令）或 Advanced（日志捕获、批处理、数据查看）
4. **检测与配置 / Detect & Setup** — 按平台路由到对应脚本，非 Windows 自动隐藏不兼容软件
5. **保存配置 / Save Config** — 写入 `config.json`
6. **写入记忆 / Write Memory** (需用户同意) — 询问后追加到 `~/.workbuddy/MEMORY.md`
7. **输出完成摘要 / Output Completion Summary** — 按 `references/completion-prompts.md` 模板输出

---

## Script Routing Table / 脚本路由表

### Core / 核心软件

| 软件 / Software | Windows 脚本 | 跨平台脚本 | 验证 / Verify |
|-----------------|-------------|------------|--------------|
| SPSS | `windows-only/SPSS/setup_sps.ps1` | — | `spss.exe -production mode "exit.sps"` |
| R | `windows-only/statsoft-r.ps1` | `cross-platform/R/setup_r.sh` | `Rscript --version` |
| Stata | — | `cross-platform/Stata/setup_stata.sh` | `stata-mp -b do "exit"` |
| SAS | `windows-only/statsoft-sas.ps1` | `cross-platform/SAS/setup_sas.sh` | `sas -version` |

*(完整路由表含 EViews, Statistica, Gretl, Minitab, Matlab, Julia 等扩展软件，详见 ADDITIONAL_SOFTWARE.md)*

---

## Detailed Configuration / 详细配置

- `ADDITIONAL_SOFTWARE.md` — JMP, GraphPad, Stat/Transfer, Gretl, Minitab, Matlab, Julia, EViews, Statistica 等扩展软件配置
- `references/command-examples.md` — 所有支持软件的 CLI 命令示例（~261 行）
- `references/version-specifics.md` — 版本差异：SPSS 26/30, R 4.5/4.1, Python 3.4/3.13（~247 行）
- `references/completion-prompts.md` — 配置完成提示模板（~327 行）
- `tests/` — `README.md`, `test-syntax.sps`, `test-job.spj`

---

## When to Read Reference Files / 何时阅读参考文件

- 版本差异问题？ → `references/version-specifics.md`
- 需要命令示例？ → `references/command-examples.md`
- 编写完成提示？ → `references/completion-prompts.md`

---

## Use Cases / 典型场景

### 1. 多软件混合工作流 / Multi-Softs Mixed Workflow

同一会话中无缝调用 R 建模 + SPSS 描述 + Stata 数据统计分析，让团队积累的各类统计代码在 AI 环境中协同工作。

Seamlessly invoke R modeling + SPSS descriptions + Stata data preparation in a single AI Agent session, enabling historically accumulated statistical code to work collaboratively in the AI environment.

### 2. 历史代码资产复用 / Historical Code Asset Reuse

将 R 脚本、SPSS 语法、SAS 宏、Stata do-file 等统一纳入 AI 工作流，作为标准化节点被反复调用、组合和编排。

Bring R scripts, SPSS syntax, SAS macros, Stata do-files, etc. into the AI workflow as standard nodes — repeatedly callable, composable, and schedulable.

### 3. 数据格式转换 / Data Conversion with StatTransfer

在不同统计软件间迁移数据资产（如 SAS → SPSS、SPSS → Stata、Excel → R），作为 AI 工作流中的数据桥梁。

Migrate data assets between statistical software (e.g., SAS → SPSS, SPSS → Stata, Excel → R), serving as a data bridge in AI workflows.

```bash
statsoft-stattransfer run data.sav data.dta
statsoft-stattransfer batch "C:\data\*.sas7bdat" "C:\output\"
```

### 4. SPSS 无闪屏批处理 / SPSS Splash-Free Batch

在 SPSS 26/27/30+ 中，通过内置 Python 引擎直接在后台执行语法，**跳过 splash screen**，无需 VBS。适合：历史 `.sps` 文件资产接入 AI 工作流；大批量描述统计 / 数据清洗 / 报表生成。

In SPSS 26/27/30+, execute syntax directly via the built-in Python engine, **skipping the splash screen** — no VBS required. Ideal for: integrating historical `.sps` assets into AI workflows; batch descriptive statistics / data cleaning / report generation.

```bash
python windows-only\SPSS\spss_helper.py run-internal
```

### 5. SAS 批处理自动化 / SAS Batch Automation

通过 SAS CLI 调度宏程序，生成报告并导出结果。适合定期报表、合规审计、历史宏程序复用等场景。

Schedule SAS macro programs via the SAS CLI, generating reports and exporting results. Ideal for periodic reporting, compliance audits, and historical macro reuse.

---

## Trigger Phrases / 触发短语

**中文**: 连接统计软件, 关联SPSS, Stata CLI, R命令行, SAS批处理, JMP, GraphPad Prism, statsoft-cli

**English**: connect SPSS, Stata CLI, R command line, SAS batch, JMP scripting, GraphPad Prism
