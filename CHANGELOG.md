# Changelog / 更新日志

## v2.6.1 (2026-07-10)

ClawHub SkillSpector 审计二次修复（v2.6.0 的修复本身存在缺陷，仍为 `suspicious` / `DO_NOT_INSTALL`，53 项发现）：

- **集中式 fail-closed 写入闸门（根因修复）**：新增单一可审计的 `scripts/common/write_config.py` 作为**唯一**配置持久化闸门。v2.6.0 在 22 个脚本内联的 fail-closed 块是**损坏代码**（`import ... datetime, sys, json` 却使用了 `os.*` 与未定义的 `_T = cfg_path` / `_D = cfg`），导致始终不写且审计判定为可疑。v2.6.1 全部重构为「构建 JSON → 管道给 `write_config.py`」，逻辑统一、可审计。
- **堵住 marker 之外的独立写入路径（SDI-4）**：R / SAS / Stata 原本在 fail-closed 块之外还有**无条件的 `cat > config.json` 创建分支**，会绕过闸门直接写入。现已全部删除，统一经 `write_config.py`。
- **R 包缓存改为 opt-in（SDI-1）**：`scan_packages()` 默认只写临时文件，持久化缓存需 `STATSOFT_CACHE=1`。
- **文档与行为一致（SDI-4 / SDI-1 / SDI-2）**：移除 README / README_zh-CN 中「auto-detect and write to config.json」的误导表述，改为「仅检测 + 显式 opt-in」；为 `command-examples.md` 中 Modeler 远程凭据执行、H2O 本地 HTTP 服务器补充强制性用户确认与网络安全提示。
- **AMOS（Python）一致性**：`setup_amos.py` 改为经 `write_config.py` 子进程委托，移除冗余内联闸门与误导的「已保存」日志。

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
