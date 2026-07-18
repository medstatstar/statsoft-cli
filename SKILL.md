---
name: statsoft-cli
slug: statsoft-cli
displayName: Statsoft-CLI / 统计软件接入助手
version: 2.6.19
summary: Cross-platform statistical software CLI integration for AI Agent; 34+ packages (R/Stata/SAS/SPSS/Python/Bayesian/ML), bilingual. Core value: activating historical code assets for AI workflow automation. / 跨平台统计软件 CLI 集成，面向 AI Agent；覆盖 34+ 款软件（R/Stata/SAS/SPSS/Python/贝叶斯/ML，双语。核心价值：激活历史代码资产，用于 AI 工作流自动化。
license: MIT
description: "Cross-platform statistical software CLI integration for AI Agent; supports 34+ packages. / 跨平台统计软件 CLI 集成，支持 34+ 款软件。
---

# Language / 语言

This skill responds in the **user's current input language** (中文 or English). It auto-detects and switches accordingly.

本技能默认使用**用户当前输入的语言**进行回复（中文 ↔ English 自动切换）。

> **本技能适用「双语语言策略」**（用户级规范，见 `~/.workbuddy/MEMORY.md`）。
> 适用原因：本技能属**统计分析类**且**已发布 ClawHub**，故需双语。
> 其专属的「中文前、英文后严格顺序」排版约定，与本策略（更底层的语言选择 / 切换规则）**不冲突**，两者同时遵守。

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
