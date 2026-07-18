---
name: statsoft-cli
description: "Cross-platform statistical software CLI integration for AI Agent; supports 34+ packages. This skill performs high-risk, opt-in operations with broad reach that you must account for: (1) HOST INVENTORY - detection scans the host for installed software (system scanning); by default it reports only a boolean installed/not-installed, but the scan enumerates the host. (2) THIRD-PARTY BINARY EXECUTION - it launches third-party statistical binaries, INCLUDING running them solely to obtain version/verification output (gated by STATSOFT_VERIFY=1), and running user-supplied models. (3) FILE CREATION - persistent config.json with timestamped .bak backups (skill dir), ephemeral temp dirs (auto-cleaned), user-directed SPSS .spj/.spv only when output_dir is given, and CmdStan compiled artifacts written OUTSIDE the skill dir (next to the model) during execution. (4) UNTRUSTED NATIVE CODE - CmdStan model execution compiles the user-supplied .stan and runs the resulting native binary (user-directed, gated by explicit STATSOFT_CMDSTAN_RUN=1 opt-in). All operations are default-deny; proceed only with STATSOFT_AUTO_WRITE=1 (non-interactive) or STATSOFT_CONFIRM=1 + TTY 'y', and STATSOFT_CMDSTAN_RUN=1 for model runs. Detection details stay hidden unless STATSOFT_REVEAL=1. / 跨平台统计软件 CLI 集成，支持 34+ 款软件。本技能执行高风险、需显式授权的操作，作用范围很广：① 主机清单——检测会扫描主机已装软件（系统扫描），默认仅返回布尔值，但过程会枚举主机；② 第三方二进制执行——会启动第三方统计二进制，包括仅为获取版本/验证输出而启动它们（受 STATSOFT_VERIFY=1 门控），以及运行用户提供的模型；③ 文件创建——持久化 config.json 加时间戳 .bak 备份（技能目录内）、临时目录（自动清理）、仅在给定 output_dir 时生成用户指定的 SPSS .spj/.spv、以及 CmdStan 编译产物在执行期间写入技能目录之外（模型源文件旁）；④ 不可信原生代码——CmdStan 模型执行会编译用户提供的 .stan 并运行生成的原生二进制（用户指定、需显式 STATSOFT_CMDSTAN_RUN=1 授权）。所有操作默认拒绝；仅当 STATSOFT_AUTO_WRITE=1（非交互）或 STATSOFT_CONFIRM=1 且 TTY 输入 'y'（模型运行还需 STATSOFT_CMDSTAN_RUN=1）才继续。检测细节默认隐藏，除非 STATSOFT_REVEAL=1。"). Mere mentions of R / SPSS / statistics do NOT activate it.

**CN**: 仅当用户显式要求用 statsoft-cli 配置/运行某款具名软件时激活（例如「用 statsoft-cli 配置 SPSS」）。仅提及 R / SPSS / 统计软件本身不会激活。

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
