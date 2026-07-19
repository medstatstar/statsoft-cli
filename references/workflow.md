# 工作流闸门细节 / Workflow Gating Detail

完整工作流步骤见 `SKILL.md` 的「执行工作流」一节。本文件仅补充各步骤的**默认拒绝闸门**细节，避免与 SKILL.md 重复。

The full step-by-step workflow lives in `SKILL.md` (Execution Workflow). This file only supplements the per-step default-deny gating details, to avoid duplication with SKILL.md.

## 扫描披露 / Scan Disclosure

系统扫描默认仅回传 `installed` 布尔值。路径、版本等敏感细节需显式 `STATSOFT_REVEAL=1` 才输出。

The system scan returns only the `installed` boolean by default. Path / version details require `STATSOFT_REVEAL=1`.

## 持久化闸门 / Persistence Gate

`config.json` 仅在显式授权时写入：`STATSOFT_AUTO_WRITE=1`（非交互 / agent）或 `STATSOFT_CONFIRM=1` + 交互式 y。所有写入统一经 `scripts/common/write_config.py`：

- 仅接受技能根目录的规范 `config.json` 为目标（单一路径强制，fail-closed）；
- 写入前先做时间戳备份 `config.json.bak.yyyymmdd_hhmmss`，再原子替换。

Persistence happens only with explicit opt-in (`STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1` + interactive y). All writes go through `scripts/common/write_config.py`, which enforces a single canonical target and a timestamped backup before atomic replace.

## 第三方二进制 / Third-party Binaries

仅为版本 / 校验而启动第三方二进制需 `STATSOFT_VERIFY=1`；编译并运行用户 Stan 模型（不可信原生代码）需 `STATSOFT_CMDSTAN_RUN=1`。
