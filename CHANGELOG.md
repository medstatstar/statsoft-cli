# Changelog / 更新日志

## v2.6.0 (2026-07-10)

ClawHub SkillSpector 审计修复（原 `suspicious` / `DO_NOT_INSTALL`，44 项发现）：

- **Fail-closed 配置写入（TP4 / SDI-4）**：全部 22 个跨平台 / `setup_amos.py` 配置写入脚本默认改为 **仅检测、不写入**。仅在显式 opt-in 时才持久化 `config.json`：
  - 非交互 / agent 场景：设 `STATSOFT_AUTO_WRITE=1`
  - 交互场景：设 `STATSOFT_CONFIRM=1` 且 TTY 下回答 `y`
  - 写入仍采用时间戳备份 + 原子 `os.replace`；绝不阻塞 agent。
- **GUI-only 边界（SDI-1）**：从 `ADDITIONAL_SOFTWARE.md`、`references/completion-prompts.md`、`references/config-templates.md`、`references/version-specifics.md` 中移除 GUI-only 软件（AMOS、GraphPad Prism、JASP、jamovi）的 CLI / 无头自动化示例，仅保留检测 + 手动启动 GUI 指引与只读 R 包替代方案。
- **GraphPad 包装器（TP4 真实违规）**：`scripts/windows-only/GraphPad/statsoft-graphpad.ps1` 不再执行 `prism.exe`，改为 GUI 启动 / 只读辅助工具（`open` / `data-info` 经 `prismwriter` / `read-log`）。
- SKILL.md 激活边界与「保存配置」小节同步说明 fail-closed 默认行为。

## v2.5.0 (2026-07-01)

- 完成 SkillSpector 审计 Themes A–J 修复（含 CmdStan 版本固定、语言尊重、GUI-only 措辞收紧等）。
- 修复 `setup_spss.ps1` PowerShell 解析缺陷。

## v2.4.0

- 安全审计修复（单字母触发词移除、描述更新、配置保存备份+确认、GUI-only 标注、环境变量修改告知、R 包安装前通知）。

## v2.1.0

- 首次公开发布到 ClawHub；双语（中文/English）支持；34 款统计软件集成。
