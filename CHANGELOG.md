# Changelog / 更新日志

## v2.6.16 (2026-07-13)

TP4 root fix — description-behavior alignment:

- Description now explicitly discloses ALL file operations (persistent .json + .bak backups, ephemeral temp dirs, user-directed .spj/.spv, CmdStan build artifacts)
- Trust Boundary section rewritten with full file operation matrix
- Gretl: `"$gretl_path"` quoted (prevents word splitting)
- SPSS: `"$pyPath"` quoted (same fix)

## v2.6.15 (2026-07-12)

Bilingual restructure — SKILL.md 全面双语化（英中双语、英语在前）+ 内容精简：

- SKILL.md 从 20.6 KB 缩减到 9.2 KB（内容更紧凑）
- 正文采用英中双语段落（英→中），标题英中双语
- 详细内容移到 references（workflow.md、platform-support.md）
- description 字段改为英中双语
- Default-Deny Gates 表格改用英中混合四列表格
- 所有语言自动选择提示统一为 "the user's current input language"

## v2.6.14 (2026-07-12)

ClawHub SkillSpector v2.6.13→v2.6.14 修复 10 个 HIGH/MED 底层 issue（1 HIGH SDI-3 + 1 HIGH TP4 + 多个 MED）：

- **SDI-3 HIGH 致命修复**：移出 `fix_statsoft_functions.py`（代码维护工具误入生产运行时包，被审计器判定为违反"config.json 唯一持久化"模型）
- **TP4 HIGH 继续收紧**：H2O 安装引导加门、Mathematica MathKernel 路径已对齐 REVEAL 门
- **Python-shell 混合修复**：GenStat / OxMetrics 的 `python3 -c` 内不再包含 shell 函数定义，JSON 配置生成恢复正确
- **Rattle OPT-IN 对齐**：`Rscript` 调用全部移到 `STATSOFT_VERIFY=1` 门后，默认仅被动检测
- **Windows ps1 未授权读 config 修复**：Limdep / Q_MRKS / SHAZAM 的 config.json 读取 + config 配置构建移到 opt-in gate 之后，真正 fail-closed
- **SPSS spss_helper.py create_spj 修复移除回归**：删除在 finally 块中清理 temp_dir 的代码，spj 文件的路径在调用者使用期间保持有效
- **SKILL.md v2.6.14 更新**

## v2.6.13 (2026-07-12)

ClawHub SkillSpector v2.6.12 扫描 15 项全清（1 HIGH + 13 MEDIUM + 1 LOW）：

- **TP4/HIGH (SKILL.md)**: H2O setup 模块路径无 REVEAL 门 → 已加门
- **SDI-3/HIGH (Mathematica)**: 验证例程无 STATSOFT_VERIFY 门启动 wolframscript → 已加门；MathKernel 路径泄漏 → 已加 REVEAL 门
- **SDI-4 (Gretl)**: `statsoft_reveal()` 函数嵌在 `detect_gretl()` 函数体内（malformed function structure）→ 移到顶层
- **SDI-4 (JAGS)**: python3 -c 内出现 shell 函数定义（`statsoft_reveal()`），损坏 JSON 配置生成 → 已清理
- **SDI-3 (H2O)**: Python 模块路径无 REVEAL 门 → 已加门
- **SDI-4 (OpenBUGS)**: 同 JAGS inline-shell 混合 → 已清理
- **SDI-4 (Orange)**: Python 模块路径无 REVEAL 门 → 已加门
- **SDI-4 (Rattle)**: R 包路径无 REVEAL 门 → 已加门
- **SDI-4 (SHAZAM)**: python3 -c 内非法 shell 函数定义 → 已清理
- **SDI-1 (NCSS)**: 持久化时不区分 REVEAL → 改为默认仅保存 `installed=true`
- **SDI-3 (SPSS run-spss-internal.py)**: 主机扫描 + 路径打印无 REVEAL 门 → 顶部增加门检查
- **SDI-4 (SPSS spss_helper.py create_spj)**: 输出目录可写到任意位置 → 默认使用 `tempfile.mkdtemp()` 临时目录 + 自动清理；显式 output_dir 需 containment 检查
- **SDI-1 (command-examples.md H2O)**: `h2o.init()` 启动本地服务器未醒目警告 → 已加警告
- **AST4 (CmdStan)**: 已有 `user_authorized_to_run()` + temp 目录约束；审计器标记为 CmdStan 固有非恶意 → 无需修改
- **全局（28 个 .sh 文件）**: 9 个文件中 `statsoft_reveal()` / `statsoft_verify()` 定义在函数体内（缩进）引发 malformed structure → 全部移至顶层定义

## v2.6.12 (2026-07-12)

ClawHub SkillSpector 审计深层修复（v2.6.11 扫描 22 项，TP4 主干 HIGH 直击「文档-代码不匹配」根因；本轮不仅逐条修复被抽样命中的文件，更对全部 43 脚本做防雷机分层抽样的系统性门类加固；审计页面显示的 v2.6.11 遗留 16 项本轮全部处理）。本轮核心修复：

- **TP4/HIGH `write_config.py` 单一路径强制执行（根因性修复）**：此前脚本接受任意调用者传入的 `target_path` 并执行「创建目录→备份→原子替换」，审计器标记为"可成为通用文件写入原语"。现从脚本自身位置推导规范路径 `../../config.json`，任何偏离的被拒收（fail-closed），彻底消除任意路径写入风险。直接修复 HIGH #2 与 MED #3。
- **TP4/HIGH `statsoft-spss.ps1` show_version 增加 `STATSOFT_VERIFY=1` 闸门**：version 命令启动 SPSS 内置 Python 并拉起 SPSS 引擎（第三方代码执行），现需独立 `STATSOFT_VERIFY=1` 才能运行。修复 HIGH #16。
- **TP4/HIGH `statsoft-spss.ps1` 顶部裸路径打印增加 REVEAL 闸门**：L79-81 发现 SPSS 即打印 `stats.com`/`python.exe`/`stats.exe` 完整路径，现纳入 `STATSOFT_REVEAL=1` 披露门；默认仅报告检测到的组件列表（不含路径）。
- **TP4/HIGH `SKILL.md` 继续对齐（之三）**：进一步收紧「唯一持久化文件 `config.json`（仅限技能目录）」声明，明确 `write_config.py` 单一路径强制校验；新增披露 show_version 受 `STATSOFT_VERIFY=1` 约束。
- **TP4/多层级 Wave 1+2 全门类加固（43 脚本）**：新增 `STATSOFT_REVEAL`（检测输出披露，默认关闭）+ `STATSOFT_VERIFY`（第三方二进制验证，默认关闭）双门体系，覆盖全部检测期路径/版本/包清单打印与二进制启动用例；与既有 `STATSOFT_AUTO_WRITE`/`STATSOFT_CONFIRM`（持久化门）形成完整四门体系。

## v2.6.11 (2026-07-12)

ClawHub SkillSpector 审计继续修复（v2.6.10 仍 `suspicious`，11 项发现，新增 AST4 类型；本轮对扫描器"分层抽样"暴露的整类根因做一次性系统性修复）。逐条 + 整类修复：

- **TP4/HIGH `SKILL.md` 描述再对齐（之二）**：显式声明"所有持久化写入仅落在单一技能目录 `config.json`（绝不在 `$HOME` 等用户主目录）"；声明包清单扫描（`scan_all`）与单目标探测均受显式授权门槛约束、未授权仅返回布尔 `installed`；声明验证步骤启动第三方二进制（如 `--version`）需 `STATSOFT_VERIFY=1`。（直接回应审计器点名的"硬编码 `$HOME` 路径冲突"与"清单扫描未门槛化"。）
- **SDI-1/HIGH `setup_stattransfer.sh` 配置路径非技能目录写入**：原脚本将 `config.json` 硬编码写入 `$HOME/.workbuddy/skills/statsoft-cli/config.json`，与"技能目录 config.json"声明直接冲突；改为脚本相对路径 `ROOT_DIR/../config.json`，与全技能其他 setup 脚本一致。
- **SDI-4 `setup_stattransfer.sh` 手动路径授权 + 可执行校验**：手动录入安装路径前加 `STATSOFT_VERIFY=1`/`STATSOFT_CONFIRM=1` 显式授权门槛，并验证为真实可执行文件（而非仅存在），杜绝把受攻击者影响的路径持久化。
- **SDI-1/SDI-4 `setup_stata.sh` 保存前 verify + 统一验证管道**：自动检测分支在 `save_config` 前调用 `verify_stata` 并重检可执行性；手动分支调整为 `verify` 在 `save` 之前，auto/手动/edition-rewrite 三源走同一验证管道。
- **SDI-1 `scan_all.ps1` 单目标探测授权 + 去二进制执行**：任何检测（broad 或 narrow `-Target`）reveal 安装路径/版本都需显式 opt-in，未授权仅输出布尔 `installed`；移除 Python 检测中的 `& python --version` 二进制执行，版本置 `unknown`；顶部注释同步更新。
- **AST4/SDI-4/OH1 `statsoft-cmdstan.py` 模型路径解析与输出收敛**：`make` 目标改用模型文件完整路径去 `.stan` 后缀（不再用 `basename`+`cwd` 混淆，防构建重定向）；运行二进制路径与 `make` 目标一致（CmdStan 行为）；docstring 准确描述 `make -C` 产物位置；subprocess 输出截断（≤8000 字符）并按可信状态/不可信输出分离（保留 `user_authorized_to_run` 默认拒绝闸门）。

## v2.6.10 (2026-07-12)

ClawHub SkillSpector 审计继续修复（v2.6.9 仍 `suspicious`，12 项发现；本轮对审计器"分层抽样"暴露的整类根因做一次性系统性修复，而非逐个打地鼠）。本轮逐条 + 整类修复：

- **TP4/HIGH `SKILL.md` 描述再对齐**：显式披露 RUN 命令经 SPSS Production Facility 写入临时 `.spj` 作业文件（运行后自动删除）与 `.spv` 分析输出（保留）至**用户工作目录**（非技能目录、仅显式授权运行才写）；并声明用户提供的手动安装路径会先做存在性 + 真实可执行文件校验再持久化。
- **SDI-4 验证阶段第三方二进制执行（整类）**：新增 `STATSOFT_VERIFY=1` 显式 opt-in 闸门——检测默认仅报告路径、不执行任何第三方二进制；仅当用户设置 `STATSOFT_VERIFY=1` 时才查询版本（Gretl/JAGS/SHAZAM/Julia/R/StatTransfer/SPSS-setup 共 7 处，含此前未扫描到的平行实例）。
- **SDI-4 持久化环境变量指引移除（整类）**：SPSS/GraphPad/JMP 的 setup 脚本不再打印 `set STATSOFT_*` / `$env:STATSOFT_*` 持久化环境变量指引，改为统一指向 config.json opt-in 模型。
- **版本硬编码 → 安装路径推导（整类）**：Origin（`2025`）、NCSS（`2024`）不再硬编码版本字符串，改为从安装路径正则提取 4 位年份、失败回退 `unknown`。
- **SDI-3 `setup_microfit.ps1` 配置读取前置修复**：config.json 的读取/修改/保存严格限定在显式 opt-in 之后（autoWrite 或 confirm+tty），杜绝未授权前的配置读取。
- **SDI-1 `data-info` 行为对齐（SAS + SPSS）**：SAS `data-info` 不再硬编码 `proc contents data=sashelp.class` 忽略输入，改为检查用户提供的文件；SPSS `data-info` 移除回退到宿主 `python.exe` 的逻辑，强制要求 SPSS 内置解释器（fail-closed）。
- **SDI-1 `statsoft-cmdstan.py` 构建产物披露与收敛**：运行时输出收敛到受限临时目录、显式告知用户、并提供清理；消除编译产物/输出散落技能目录外的问题。
- **`statsoft-spss.ps1` RUN 命令内联披露**：`run`/`run-batch` 在执行前带内明确告知将写入临时 `.spj` 与 `.spv` 至用户工作目录（TP4 要求的"显式披露"）。

## v2.6.9 (2026-07-12)

ClawHub SkillSpector 审计继续修复（v2.6.8 仍 `suspicious`，13 项发现；v2.6.7 的 25 项已清零，本轮聚焦声明-实现一致性与剩余执行/写入闸门缺口）。本轮逐条修复：

- **TP4/HIGH `SKILL.md` 描述声明对齐**：在 `description` 显式披露全部真实行为——HOST-WIDE 主机级软件清单（只读扫描、不落盘）、第三方二进制执行（含 setup 验证阶段）、可选依赖/软件安装流程、以及 config.json 持久化（唯一可持久化文件、限于技能目录）；消除"tightly constrained"表述与实际广行为的自相矛盾。
- **RA2/MEDIUM `SKILL.md` 持久化模型**：明确声明持久化最小化、仅显式 opt-in、限于技能目录、不含敏感数据、备份/回滚确定性；与既有 fail-closed 段一致。
- **SDI-1/SDI-4 `setup_sas.sh` 临时文件清理**：验证步骤改用 `mktemp -d` 私有临时目录 + `trap EXIT` 清理，不再在 `/tmp` 残留 `test_sas.sas/.log/.lst`（此前泄露执行痕迹）。
- **SDI-1 `setup_stata.sh` 手动路径校验**：手动回退不再接受任意目录作为 `STATA_CMD`；解析为真实可执行文件（`-f`+`-x`，或在给定目录内搜索已知 Stata 可执行名），校验失败则拒绝保存，避免把被破坏/受攻击者影响的路径持久化进 config.json。
- **SDI-1 `setup_amos.ps1` 辅助脚本闸门**：调用 `setup_amos.py` 时显式传 `--consent`（已授权）或 `--no-write`（默认检测态），不再仅靠继承环境变量；仅当确实授权时才重载 config.json。
- **SDI-1 `setup_amos.py` 显式持久化开关**：新增 `--consent`/`--no-write` 参数；`--no-write` 永远赢得检测态，且向集中式 `write_config.py` 透传 `--consent`，绝不自我授权。
- **SDI-1/SDI-4 `statsoft-spss.ps1` version 闸门**：`version` 命令启动 SPSS 内置 Python 并拉起 SPSS 引擎（第三方代码执行），现与 `run/run-batch/data-info` 一致先过 `Test-UserAuthorizedToRun` 默认拒绝闸门；同步修正 `data-info` 注释枚举所有需授权命令。
- **SDI-1 `statsoft-stattransfer.ps1` run/batch 写入闸门**：新增 `Test-StatTransferAuthorized` 默认拒绝闸门（STATSOFT_AUTO_WRITE=1 或 STATSOFT_CONFIRM=1 交互确认），在创建输出目录/执行转换前强制校验；并新增 `STATSOFT_DRY_RUN=1` 试运行模式（只报告计划、不写文件、不执行）。
- **SDI-4/SQP-3 `tests/example_workflow.md` 去隐含串联**：核心优势表将"无缝集成/AI Agent handles data passing"改为"用户批准的数据交接（绝不隐式串联）"，"single conversation"改为"引导式多轮（每步显式确认，非一次性流水线）"，并加醒目提示"无显式批准不运行任何步骤、不在工具间传递数据"。
- **SQP-2 `references/completion-prompts.md` H2O 警告**：在 H2O 示例前新增安全提示，说明 `h2o.init()` 会启动本地 H2O 服务器（JVM、可能监听端口）、`h2o.import_file()` 会把数据集传入该服务，需显式用户确认方可运行。

## v2.6.8 (2026-07-12)

ClawHub SkillSpector 审计继续修复（v2.6.7 仍 `suspicious`，25 项发现；其中 v2.6.6 的 16 项已清零，本轮聚焦新增/未覆盖文件：文档声明与实现一致性、GUI-only 文件写入、MEMORY.md 误述、远程执行示例、以及 10 个 setup 脚本的自授权环境变量）。

- **删除自相矛盾的 `environment_variable_modification` 能力声明（TP4/SDI-1/SDI-4，`SKILL.md`）**：manifest `capabilities` 移除该项，消除与"绝不写环境变量"声明及 fail-closed 持久化模型的自相矛盾；description 显式声明 NCSS/NLOGIT/Origin 等软件（消 scope drift），并补充"启动第三方二进制时可设置进程级临时环境变量如 PATH、绝不持久化"的披露。
- **GraphPad Prism 后台 `.pzfx` 写入推荐移除（SDI-1/SDI-4 HIGH，`ADDITIONAL_SOFTWARE.md`）**：删除 `prismWriter` 后台操作 `.pzfx` 的建议，改为明确声明本技能不创建/修改任何 Prism 项目/数据文件，此类自动化超出范围。
- **trust-and-safety 删除 MEMORY.md 误述（SDI-1/SDI-4 HIGH，`trust-and-safety.md`）**：移除"写入 MEMORY.md"风险行，与"唯一可持久化文件为 config.json"的强制模型一致。
- **远程 Modeler Server 执行示例移除（SDI-1，`command-examples.md`）**：删除 `server-run`（hostname/port/凭据）远程执行段，与 `statsoft-modeler` 仅 `-local` 模式一致。
- **version-specifics NCSS/Origin scope drift 消除（SDI-1，`version-specifics.md` 间接）**：通过 manifest 显式声明 NCSS/Origin 归属已支持软件集解决。
- **集中式 `--consent` 授权参数（SDI-1/SDI-4，`write_config.py` + 10 个 `setup_*.ps1`）**：新增显式 `--consent` 命令行参数（替代脚本自设 `$env:STATSOFT_AUTO_WRITE="1"` 的混淆代理自授权）；AMOS/Limdep/Mathematica/Microfit/Mplus/NCSS/NLOGIT/Origin/Q_MRKS/SPSS-Modeler 共 10 个脚本改为传 `--consent` 而非污染共享环境变量，授权范围限定于该子进程。

## v2.6.7 (2026-07-11)

ClawHub SkillSpector 审计继续修复（v2.6.6 仍 `suspicious`，16 项发现；审计聚焦 data-info 授权缺口、参数注入、Prism 文件写入示例、文档持久化一致性、临时/缓存文件与广度枚举）。本轮按 remediation 逐条修复：

- **SAS `data-info` 补授权闸门 + try/finally（SDI-1 HIGH，`statsoft-sas.ps1`）**：`data-info` 分支此前不经 `Test-UserAuthorizedToRun` 即执行 SAS 并写临时 `.sas`，现与 `run` 一致先做 default-deny 授权，且临时文件用 `try/finally` 保证清理；文件头注释重写为准确描述"SAS 执行包装器 + 临时/日志写入 + 哪些命令需授权"（SDI-4）。修正 `$script=isZH` 笔误。
- **CmdStan 参数消毒（OH1 HIGH，`statsoft-cmdstan.py`）**：新增 `_safe_arg()`，对回显的 `model_file`/`data_file` 及重建的命令行做 shell 引用 + 去 ANSI/控制字符 + 折叠换行/回车/制表，防止恶意文件名向终端/日志注入或伪造记录。
- **GraphPad Prism 自相矛盾示例移除（SDI-1/SDI-4 HIGH，`command-examples.md`）**：删除写 `.pzfx` 的 `prismWriter` 代码示例，改为明确声明本技能不创建/读取/修改任何 Prism 文件（含 `.pzfx`），此类操作超出技能范围。
- **spss_helper output_dir 收敛（SDI-4，`spss_helper.py`）**：`create_spj` 将 `.sps` 父目录设为 allowed base，用 `os.path.realpath` + `commonpath` 强制 output_dir 必须等于或位于其下，拒绝 `..`/绝对路径逃逸；已存在目标文件时二次确认覆盖。
- **setup_r.sh 包清单不落盘（SDI-1/SDI-4，`setup_r.sh`）**：移除 `STATSOFT_CACHE` 持久缓存分支；改用 `mktemp -d` 私有目录（`chmod 700`）+ `RETURN` trap 保证函数返回时（含出错）删除，包清单严格临时、不再打印临时路径。
- **scan_all.ps1 收窄枚举范围（SDI-1/SDI-4，`scan_all.ps1`）**：新增 `-Target <name>` 单产品探测（按需、免主机级同意）；无 `-Target` 的全量枚举保留显式 opt-in 同意闸门并修正误导性注释（如实说明会枚举多款产品）；顺带修复多处 `Get-Nlis*` 笔误（应为 `Get-Nsis*`）。
- **SPSS Modeler 移除 server-run（SDI-1/SDI-4，`statsoft-modeler.ps1`）**：删除超范围的 `server-run` 远程执行模式及 server/hostname/port 等选项，仅保留 `-local` 本地执行，消除文档-实现不一致（usage 声称支持 `-hostname/-port` 实则硬编码 localhost:80）。
- **example_workflow.md 去广义触发（SQP-1，`tests/example_workflow.md`）**：将"用一句自然语言触发整条流水线"改写为逐步显式调用 + 每步前确认 + 脚本白名单 + 隔离工作目录 + dry-run 审阅 + 禁止隐式数据传递。
- **文档持久化模型一致化（TP4 / SDI-4 / RA2，`SKILL.md`/`README.md`/`README_zh-CN.md`）**：统一表述为"绝不写环境变量/opt-in 开关，唯一可持久化文件为技能目录下 `config.json`（仅显式 opt-in 后写入，带时间戳备份，删除即回滚），不写 `~/.workbuddy/MEMORY.md`"；移除 SKILL.md 中写入 `~/.workbuddy/MEMORY.md` 的工作流步骤以缩小影响面；GUI-only 段补充"不创建/修改其项目文件（含 Prism `.pzfx`）"。

## v2.6.6 (2026-07-11)

ClawHub SkillSpector 审计继续修复（v2.6.5 仍 `suspicious`，17 项发现；审计器进一步聚焦临时/日志文件写入、过度承诺的"安全过滤"措辞、以及触发词过宽）。本轮定向修复：

- **SPSS 包装脚本改临时目录 + 清理（SDI-1 HIGH，`spss_helper.py`）**：`run_internal` 的 `_spss_runner.py` 包装脚本改写入 `tempfile.mkdtemp()` 私有目录，`try/finally` 中 `shutil.rmtree` 清理，不再在技能目录留下持久化包装文件；`create_spj` 增加 opt-in 写入闸门（披露 .spj 路径，未确认返回 None）。
- **SPSS 语法校验去除过度承诺（SDI-4，`run-spss-internal.py`）**：头注释与 `validate_syntax` docstring 重写为"TRUSTED-INPUT-ONLY / 有限黑名单绊线，非安全保证、可被绕过"，消除"危险指令已过滤"的虚假安全感。
- **PowerShell 临时/日志文件（SDI-1，多处）**：`statsoft-modeler.ps1` 默认 `nolog`（新增 `Get-LogArg`，仅用户显式 `-log` 时才写日志）；`statsoft-stattransfer.ps1` 的 stderr 改用 `New-TemporaryFile` + `finally` 删除；`statsoft-spss.ps1` 的 `data-info` 增加执行授权闸门并优先使用 SPSS 内置解释器（非通用 `python.exe`）。
- **SAS/EViews 授权闸门 + 日志路径约束（SDI-1 / SQP-2）**：`statsoft-sas.ps1` 新增 `Test-UserAuthorizedToRun`（default-deny）与 `Resolve-SafeLogPath`（拒绝绝对路径/父级穿越，仅允许当前目录文件名）；`statsoft-eviews.ps1` 新增默认拒绝授权闸门并将 `.prg` 明确标注为可执行代码。
- **setup shell 脚本（SDI-1/4）**：`setup_sas.sh` 在"未检测到"回退分支不再交互式索要手动路径 / 写入配置，仅打印手动配置指引；`setup_stata.sh` 的 `verify_stata` 改用 `mktemp -d` 私有目录 + 自生成 `verify.do` + 全路径调用 + `rm -rf` 清理，不再 `cd /tmp` 执行硬编码 do-file。
- **文档一致性（TP4 / RA2 / TR2）**：`SKILL.md` 移除过宽触发词 `"run statsoft-cli"`（TR2 Shadow Command Trigger），信任边界"文件创建"段披露临时文件即用即删、日志仅显式请求时写入且路径受限；`tests/README.md` 在测试目的处前置"执行第三方二进制 + 写入 test-data.sav"副作用提示并新增清理步骤。

## v2.6.5 (2026-07-11)

ClawHub SkillSpector 审计继续修复（v2.6.4 仍 `suspicious`，20 项发现；审计主题进一步升级到「默认拒绝授权 / 最小子进程环境 / 临时脚本注入 / 环境变量持久化 / 文档范围漂移」）。本轮按审计器 remediation 模式彻底修复：

- **全部授权闸门改为默认拒绝（SDI-4，多处 MEDIUM）**：`Test-UserAuthorizedToRun`（`statsoft-spss.ps1` / `statsoft-statistica.ps1` / `statsoft-r.ps1`）与 `user_authorized_to_run`（`statsoft-cmdstan.py`）、`_opt_in_confirm`（`spss_helper.py`）由「默认 proceed」翻转为 **default-deny**：默认返回 False，仅当 `STATSOFT_AUTO_WRITE=1`（非交互/agent）或 `STATSOFT_CONFIRM=1`+TTY 回答 y 时才放行。SPSS 授权提示补述「将执行第三方外部二进制」。
- **SPSS 子进程最小环境（E2 HIGH）**：`spss_helper.py` 新增 `_minimal_env()`，以允许列表（PATH/SYSTEMROOT 等 + 必要 PYTHONPATH）构建子进程环境，替换 `run_internal` / `show_version` 中的 `os.environ.copy()`，防止把用户密钥泄漏给 SPSS 子进程。
- **SPSS .spj 语法校验（AST4 MEDIUM）**：`spss_helper.py` 新增 `_validate_spj()`，在 `run_console` / `run_exe` 执行前拒绝 .spj/.sps 中的 `HOST COMMAND` / `INSERT FILE` / `PRESERVE` / `RESTORE` 等危险语法。
- **SPSS run_internal 去插值（SQP-2）**：语法路径改为经 `sys.argv[2]` 传参，不再插值进包装脚本字面量。
- **CmdStan 输出净化 + 默认拒绝（OH1 HIGH / SDI-4）**：`cmdstan_info` 的 `stanc --version` 输出经 `_sanitize()` 后再打印；`user_authorized_to_run` 默认拒绝。
- **临时脚本改 argv 传参（SQP-2，JMP/GraphPad/R）**：`statsoft-jmp.ps1`（新增 `Test-UserAuthorizedToRun` + `Test-SafePath`）、`statsoft-graphpad.ps1`、`statsoft-r.ps1` 的 `data-info` 临时脚本改为经 `commandArgs`/`sys.argv`/安全路径校验传入数据文件路径，不再插值；披露临时文件并在 `finally` 清理。
- **setup 脚本改为纯检测（SDI-1 HIGH，GraphPad/JMP/SPSS）**：`setup_graphpad.ps1` / `setup_jmp.ps1` / `setup_spss.ps1` 删除全部 `SetEnvironmentVariable(..., "User")` 写入，改为打印手动设置指引；头注释标注 DETECTION-ONLY。**本技能不再写入任何用户环境变量。**
- **SHAZAM 强制放行移除（SDI-4）**：`setup_shazam.ps1` 删除调用 `write_config.py` 前强制 `$env:STATSOFT_AUTO_WRITE = "1"` 的越权行。
- **文档范围收窄（SDI-1 / TP4）**：`references/version-specifics.md` 的 JASP `jaspTools` / AMOS Python 扩展改为 GUI-only 非自动化警告；NCSS / Origin CLI 段标注「仅供参考——检测 + 手动启动，不自动执行」。
- **SKILL.md 收窄（TP4 / SQP-1 / RA2）**：`description` 重写为按需激活 + default-deny + 不写用户环境变量 + setup 仅检测；`triggers` 收窄为显式「用 statsoft-cli 配置/运行 X」句式；移除过时「环境变量修改说明」工作流步骤；信任边界声明 config.json 为唯一持久化状态。`README_zh-CN.md` 澄清 opt-in 开关为只读放行、非持久化写入。

## v2.6.4 (2026-07-10)

ClawHub SkillSpector 审计继续修复（v2.6.3 仍 `suspicious`，15 项发现；扫描器已把审计主题扩展到注入 / 清单 / 信任边界 / 输出净化）。本轮定向修复：

- **Statistica 改造为仅检测 + 受控运行（SDI-1 HIGH / SDI-4）**：v2.6.3 的 `setup_statistica.ps1` 仍执行持久化配置（GUI 导向工具被扩展为状态变更 setup）。现改为**纯检测脚本**，仅报告路径与版本、**绝不写入 config.json**；删除 `Save-StatSoftConfig` / `Configure-Statistica`，仅打印手动启动与 SVB 运行指引。其执行入口 `statsoft-statistica.ps1` 补齐 `Test-UserAuthorizedToRun` 闸门（与 SPSS/R 运行器一致：默认仅用户显式调用时执行，`STATSOFT_AUTO_WRITE=1` 非交互放行，`STATSOFT_CONFIRM=1`+TTY 提示 y/N）。
- **SPSS `data-info` 注入修复（SDI-1 / MEDIUM）**：移除把 `$savFile` 直接插值进 Python 原始字符串字面量、再用通用 `python.exe` 执行的代码注入路径；改为调用固定辅助脚本 `_data_info.py` 并以 `argv` 安全传参，消除任意代码执行。
- **SPSS 解释器固定（SDI-2 / MEDIUM）**：`data-info` 不再裸调 `python.exe`（PATH 解析可被劫持），改为 `Get-Command python.exe` 解析为**绝对路径**后再执行。
- **Statistica / StatTransfer 预置建目录（SDI-4）**：删除检测阶段提前 `New-Item -ItemType Directory` / `mkdir -p`，目录仅在 `write_config.py` 真正持久化时才创建，确保仅检测零写入。
- **JMP COM 自动化示例（SDI-2 / MEDIUM）**：从 `setup_jmp.ps1` 输出中移除 COM 自动化示例，仅保留经批准的 JMP CLI/JSL 调用示例。
- **清单收集同意闸门（SQP-2）**：`scan_all.sh` / `scan_all.ps1` 在主机级软件清单前新增显式同意闸门（默认跳过；`STATSOFT_AUTO_WRITE=1` 或 `STATSOFT_CONFIRM=1`+TTY 才执行），并披露将收集的本地工具路径/版本。
- **CmdStan 输出净化（OH1 HIGH）**：`statsoft-cmdstan.py` 新增 `_ANSI_RE` + `_sanitize()`，对执行的模型二进制 `stdout`/`stderr` 剥离 ANSI/控制字符后再打印，防止终端/日志注入。
- **信任边界与触发收窄（TP4 / RA2 / SQP-1）**：`SKILL.md` 新增 `## 信任边界 / Trust Boundary` 段，显式声明代码执行/文件创建/包安装/用户脚本与下载依赖均属高风险、需显式确认与路径校验；描述补述 Statistica 仅检测 + 受控运行；`README.md` / `README_zh-CN.md` 的 `Usage/使用方式` 明确「仅限明确、限定范围的请求（指名工具+动作）才激活」，并列出非触发示例与执行前确认要求。
- **安装/工作流警示（SQP-2）**：`references/command-examples.md` 的 Orange `pip install orange3` / `conda install` 段补充「需联网、修改本地环境、仅经显式确认后运行」警告；`tests/example_workflow.md` 在多工具工作流前新增安全提示（审阅脚本、最小权限、隔离目录）。

## v2.6.3 (2026-07-10)

ClawHub SkillSpector 审计迭代修复（扫描器非确定性，需对每个持久化写入/外部执行路径补齐显式内联 opt-in 闸门）：

- **环境变量持久化写入补齐闸门（SDI-1 收尾）**：对最后 3 个无闸门的持久化写入——`setup_graphpad.ps1`、`setup_jmp.ps1`、`setup_spss.ps1` 的 `SetEnvironmentVariable(..., "User")`——统一包裹为 `STATSOFT_AUTO_WRITE=1` 持久化 / `STATSOFT_CONFIRM=1`+TTY 读 y/N / 否则仅检测不写 的 fail-closed 模式，与 config.json 闸门一致。
- **执行授权闸门（SDI-1 / 类比 CmdStan `make` 外部执行）**：为实际执行外部进程或联网安装的运行入口补齐 `user_authorized_to_run` / `Test-UserAuthorizedToRun` 闸门（默认 proceed，因用户显式调用即视为意图；`STATSOFT_CONFIRM=1`+TTY 才提示，绝不阻塞 agent）：
  - SPSS 运行器：`statsoft-spss.ps1` 的 `run`/`run-batch` 派发、`spss_helper.py` 的 `run-console`/`run-internal`（此前仅 `run-exe` 有）。
  - R 运行器：`statsoft-r.ps1` 的 `install` 及 `.dta`/`.sav` 缺失 `haven` 时的自动安装分支（联网安装，强制 opt-in）。
  - SAS 验证探针：`setup_sas.sh` 的验证运行改为 fail-closed（默认仅检测跳过，需 `STATSOFT_AUTO_WRITE=1` 或 `STATSOFT_CONFIRM=1`+TTY 才执行）。
- **PowerShell 写入路径归一化（修复潜在 latent bug）**：全部 12 个 `setup_*.ps1` 的 config.json 路径统一为 `..\config.json`（config.json 实际位于 `scripts/windows-only/config.json`），修正 Limdep/Microfit/NLOGIT 曾硬编码到不存在的技能根路径、NCSS/Origin 多退一级、AMOS/Mplus/Q_MRKS 退两级等错误路径。

## v2.6.2 (2026-07-10)

ClawHub SkillSpector 审计三次修复（v2.6.1 仍 `suspicious` / `DO_NOT_INSTALL`，25 项发现；扫描器对调用 `write_config.py` 的脚本判定为「无内联 opt-in 闸门」）。本轮按审计器自身给出的 remediation 模式彻底修复：

- **每个调用方显式内联 opt-in 闸门（SDI-1 根因）**：在全部 22 个跨平台 `setup_*.sh` + `setup_amos.py` 中，把「直接调用 `write_config.py`」改为显式可见的 `if [ STATSOFT_AUTO_WRITE=1 ] → 持久化；elif [ STATSOFT_CONFIRM=1 ] && TTY → 读取 y/N；else → 仅检测、打印「未修改」`。`write_config.py` 仍负责备份 + 原子写入，形成双层防护。
- **消除误导信息（SDI-4）**：将脚本中「Updating config.json… / 正在更新配置… / Write to config if possible」等表述改为「默认仅检测；写入需 opt-in」，与 fail-closed 行为一致。
- **文档与声明一致（SDI-1 / SDI-2 / SDI-4 / TP4）**：
  - `ADDITIONAL_SOFTWARE.md` GUI-only 措辞由「检测与启动能力」改为「检测与手动启动指引（绝不自动启动 GUI）」。
  - `command-examples.md` GraphPad 段消除「无 CLI 却又给 prismWriter 后台自动化」的矛盾，明确 prismWriter 为纯 Python 文件格式辅助（不启动/驱动 Prism）。
  - `config-templates.md` JMP 高级模式行补充「仅执行用户提供的 JSL、需确认」。
  - `SKILL.md` 描述补全行为披露（执行第三方二进制、创建临时脚本/作业文件、验证运行、下载/安装），并显式声明 Mathematica / Julia / Matlab / JMP(Windows CLI) 支持。

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
