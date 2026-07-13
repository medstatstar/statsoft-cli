---
name: statsoft-cli
description: "Cross-platform statistical software CLI integration for AI Agent. Supports 34+ statistical software packages. This skill performs high-risk operations: software detection, executing third-party statistical binaries, running user-supplied code (Stan/SPSS/SAS/R/Python), and installing dependencies over the network. File operations: (1) persistent config.json with timestamped backups, confined to the skill directory; (2) ephemeral temporary directories (mkdtemp, auto-cleaned); (3) user-directed SPSS job (.spj) and output (.spv) files when explicit output_dir supplied; (4) CmdStan build artifacts written into CmdStan tree during model execution. All operations are gated behind default-deny opt-in. / 跨平台统计软件 CLI 集成，支持 34+ 款统计软件。本技能执行高风险操作：只读检测、执行第三方统计二进制、运行用户提供的代码（Stan/SPSS/SAS/R/Python）、联网安装依赖。文件操作：(1) 持久化 config.json（含时间戳备份），限于技能目录；(2) 临时目录（mkdtemp，自动清理）；(3) 用户指定的 SPSS 作业文件 (.spj) 和输出 (.spv)——仅在显式指定 output_dir 时生成；(4) CmdStan 编译产物在模型执行期间写入 CmdStan 目录。所有操作均需显式 opt-in（默认拒绝）。"

triggers:
  - "use statsoft-cli to configure SPSS"
  - "statsoft-cli configure R"
  - "use statsoft-cli to run a JMP JSL script"
  - "statsoft-cli 配置 Stata"
  - "statsoft-cli 运行 SPSS 语法"
  - "call statsoft-cli for SAS"
  - "connect statistical software CLI via statsoft-cli"

metadata:
  openclaw:
    emoji: 🛠️
    icon: assets/icon.svg
  authors:
    - medstatstar
    - phoe-zip
  contributors:
    - medstatstar
    - phoe-zip
  version: "2.6.16"
  license: MIT
  capabilities:
    - shell_execution
    - file_read_write
    - network_access
    - process_execution
    - system_scanning
  tags:
    - 统计软件
    - Statistical Software
    - CLI
    - R
    - SPSS
    - Stata
    - SAS
    - Bayesian
    - Machine Learning
    - Econometrics
    - SEM
    - Data Mining
  homepage: https://github.com/medstatstar/statsoft-cli
  repository: https://github.com/medstatstar/statsoft-cli

---

# Purpose / 技能目的

This skill integrates 34+ statistical software packages into the AI Agent environment, enabling statisticians to fully leverage these tools. **Core value: integrating and leveraging all statistical software resources and historical assets within AI workflows.**

本技能将 34+ 款统计软件整合到 AI 智能体环境下统一使用，从而方便统计师充分利用这些统计软件的能力。**核心价值在于盘活历史代码资产，解决 AI 工作流自动化中的可复用性难题。**

---

# Platform Support / 平台支持

This skill supports statistical software across Windows, macOS, and Linux. The full platform matrix is in `references/platform-support.md`.

本技能支持 Windows、macOS 和 Linux 上的统计软件。完整平台支持矩阵见 `references/platform-support.md`。

| Category / 类别 | Software / 软件 |
|-----------------|-----------------|
| ✅ All platforms (Win + Mac + Linux) | R, Stata, SAS, CmdStan, GenStat, Gretl, H2O.ai, JAGS, Julia, KNIME, Mathematica, Matlab, OpenBUGS, Orange, OxMetrics, PSPP, Rattle, SHAZAM, Stat/Transfer, Tanagra, TSP, Weka |
| 🔴 Windows only | SPSS Statistics, EViews, JMP, LIMDEP, Microfit, NCSS, NLOGIT, Origin, Q (MRKS), SPSS Modeler, Statistica |
| 🔴 GUI-only (detection + manual-launch only) | AMOS, GraphPad Prism, JASP, jamovi |

GUI-only software is limited to **detection + manual-launch guidance** — this skill never drives them via CLI/headless automation, and never creates or modifies their project/data files (including GraphPad Prism `.pzfx`).

GUI 仅限软件仅提供**检测 + 手动启动 GUI 指引**，本技能不通过 CLI/无头方式驱动其批处理，也绝不创建或修改其项目/数据文件（包括 GraphPad Prism `.pzfx`）。

---

# Workflow / 工作流

This skill follows a 6-step standard workflow. Every step is gated by default-deny. See `references/workflow.md` for full details.

本技能遵循 6 步标准工作流，每步均有默认拒绝闸门。详见 `references/workflow.md`。

1. **Detect Platform** — Identify OS and architecture.
2. **Pre-scan Confirmation** — Prompt user before scanning (auto-scan vs. specify paths).
3. **System Scan** — Batch detect installed software. Reveals only `installed` boolean by default (path/version require `STATSOFT_REVEAL=1`).
4. **Detect & Setup** — Route to per-tool setup scripts.
5. **Save Config** — Detection-only by default. Persist `config.json` only on opt-in.
6. **Output Summary** — Follow `references/completion-prompts.md`.

---

# Trust Boundary / 信任边界

This skill performs **high-risk operations**: executing third-party statistical binaries, creating temporary scripts/job files, reading and executing user-supplied code, and installing dependencies over the network.

**File operations (all disclosed, all gated):**
- **Persistent**: `config.json` (with timestamped `.bak` backups) — confined to the skill directory.
- **Ephemeral temp dirs**: `mkdtemp` directories for SPSS runners/CmdStan output — auto-cleaned after use.
- **User-directed output**: SPSS job (`.spj`) and output (`.spv`) files — created ONLY when the user explicitly supplies `output_dir`.
- **Build artifacts**: CmdStan compilation writes `.o`/`.exe` into the CmdStan tree — inherent to Stan, occurs outside the skill directory.

本技能执行**高风险操作**：执行第三方统计二进制、创建临时脚本/作业文件、读取并执行用户提供的代码、联网安装依赖。

**文件操作（均已披露、均有闸门）：**
- **持久化**：`config.json`（含时间戳 `.bak` 备份）— 限于技能目录。
- **临时目录**：SPSS 运行器/CmdStan 输出使用 `mkdtemp` — 用后自动清理。
- **用户指定输出**：SPSS 作业 (`.spj`) 和输出 (`.spv`) 文件 — 仅在用户显式指定 `output_dir` 时生成。
- **编译产物**：CmdStan 编译将 `.o`/`.exe` 写入 CmdStan 目录 — Stan 固有行为，发生在技能目录外。

All user-provided scripts, syntax files, JSL, SAS macros, R/Python code, and data files are treated as **untrusted**; they require explicit confirmation plus path/allowlist validation before execution.

所有用户提供的脚本、语法文件、JSL、SAS 宏、R/Python 代码和数据文件均视为**不可信**；执行前须显式确认 + 路径/白名单校验。

See `references/trust-and-safety.md` for risk levels and pre-flight checks.

详见 `references/trust-and-safety.md`。

---

# Default-Deny Gates / 默认拒绝闸门

This skill has **four independent default-deny gates**. **No action happens without explicit opt-in.**

本技能有**四个独立默认拒绝闸门**。**无显式 opt-in 不执行任何操作。**

| Gate | Purpose / 用途 | Default / 默认 |
|------|---------|---------|
| `STATSOFT_AUTO_WRITE=1` | Persist `config.json` (the only file that persists in the skill directory) / 持久化 `config.json`（技能目录下唯一持久化文件） | Disabled / 禁用 |
| `STATSOFT_CONFIRM=1` | Interactive y/N prompt for persistence (TTY required) / 交互式 y/N 确认（需 TTY） | Disabled / 禁用 |
| `STATSOFT_REVEAL=1` | Disclose detection-phase details (paths, versions, package manifests, OS/architecture) / 披露检测期详情（路径、版本、包清单、OS/架构） | Disabled — detection reveals only boolean `installed` / 禁用 — 默认仅返回布尔 `installed` |
| `STATSOFT_VERIFY=1` | Launch third-party binaries for `--version` / verification queries / 启动第三方二进制进行版本查询 | Disabled — binaries are NEVER executed during detection / 禁用 — 检测期绝不执行二进制 |

The `STATSOFT_REVEAL` gate prevents host fingerprinting and information leakage in agent settings. The `STATSOFT_VERIFY` gate ensures binaries are never executed for version queries without consent.

`STATSOFT_REVEAL` 闸门防止主机指纹泄露和信息泄漏。`STATSOFT_VERIFY` 闸门确保版本查询不执行第三方二进制。

---

# Single-Path Enforcement / 单一路径强制

The centralized writer (`scripts/common/write_config.py`) enforces a single canonical path derived from its own location (`<skill-root>/config.json`). Any caller-supplied path that does not resolve to this canonical path is rejected outright — so a wrapper cannot redirect writes to an arbitrary location.

集中写入器（`scripts/common/write_config.py`）强制单一路径校验。传入非规范路径将被拒收，包装器无法将写入重定向到任意位置。

---

# Trigger Phrases / 触发短语

**EN**: Activates only on an explicit user request to configure/run a *specific named* tool via statsoft-cli (e.g. "use statsoft-cli to configure SPSS"). Mere mentions of R / SPSS / statistics do NOT activate it.

**CN**: 仅当用户显式要求用 statsoft-cli 配置/运行某款具名软件时激活（例如「用 statsoft-cli 配置 SPSS」）。仅提及 R / SPSS / 统计软件本身不会激活。

---

# Language / 语言

This skill responds in the **user's current input language** (中文 or English). It auto-detects and switches accordingly.

本技能默认使用**用户当前输入的语言**进行回复（中文 ↔ English 自动切换）。

---

# Core Permissions / 核心权限

- **Local file read-write** — `config.json`, temporary scripts.
- **Process execution** — Statistical software binaries.
- **Network access** — CRAN / Anaconda repositories.

本地文件读写 (config.json, temporary scripts)、进程执行 (statistical software binaries)、网络访问 (CRAn/Anaconda repositories)。

---

# Reference Files / 参考文件

- `ADDITIONAL_SOFTWARE.md` — Extended software configuration (31 packages) / 扩展软件配置
- `references/command-examples.md` — CLI command examples for all software / CLI 命令示例
- `references/version-specifics.md` — Version differences / 版本差异
- `references/completion-prompts.md` — Completion prompt templates / 完成提示模板
- `references/trust-and-safety.md` — Risk levels and pre-flight checks / 风险等级与飞行前检查
- `references/workflow.md` — Detailed execution workflow / 详细执行工作流
- `references/platform-support.md` — Full platform support matrix / 完整平台支持矩阵
- `tests/` — Automated test scripts / 自动化测试脚本
