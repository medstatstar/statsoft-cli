# statsoft-cli 潜在 Bug 检查案例设计（10 例，简单 → 复杂）

> 设计目的：用 10 个由简到繁的对话/执行场景，覆盖 gate-0 分级、fail-closed 闸门、
> 双 `config.json`、locale 机制、文档-代码一致性等高风险面，暴露潜在 bug。
> 每例给出：用户输入 → gate-0 分类 → 实际执行路径（脚本）→ 预期行为 → 潜在 bug 探针 → 判定标准。
> 标注 **[已实证]** 的为本次审查已通过运行/静态检查确认存在、可直接复现的问题。

---

## 〇、本次已实证确认的 Bug（先于案例，作为回归基线）

| # | 类型 | 现象 | 证据 | 严重度 |
|---|------|------|------|--------|
| B1 | 测试回归 | `tests/run_all.py` 断言 SKILL.md 含 6 条路由路径（`scripts/windows-only/SPSS/setup_spss.ps1`、`statsoft-r.ps1`、`setup_r.sh`、`setup_stata.sh`、`statsoft-sas.ps1`、`setup_sas.sh`），**6 条全部失败** → 套件变红（42 通过 / 6 失败）。对齐 §10.7 时删掉了显式脚本路径。 | 运行 `tests/run_all.py` | 高（既有 CI 红） |
| B2 | 文档-代码矛盾 | SKILL.md 称 `_platform-detect.sh` "设置 `$PLATFORM`/`$OS`/`$ARCH`"，**实际只设 `WB_OS`/`WB_ARCH`**（且 `scan_all.sh` 用的就是 `WB_OS`）。 | `grep` 脚本确认 | 中（下游若按文档取变量会空值） |
| B3 | 文档-代码矛盾 | gate 表称 `STATSOFT_REVEAL set to 1`="检测时披露路径/版本"；但 `scan_all.sh` **从不读取 REVEAL**，且**无 consent 时零 JSON 输出**（仅打印 skipped），与正文"默认只返回 installed 布尔"三处矛盾。 | 运行 `scan_all.sh` 无/有 REVEAL 均 skipped | 高（安全声明误导） |
| B4 | 编码风险 | **26 个 `.ps1` 缺 UTF-8 BOM**（含 `statsoft-r.ps1` 等带中文字面量者）。WinPS 5.1 无 BOM 会按系统 codepage 解析 → 中文乱码。 | 字节级 BOM 扫描 | 中（仅 WinPS 5.1 触发） |
| B5 | 架构歧义 | root `config.json` 与 `scripts/windows-only/config.json` 并存；`write_config.py` 接受两者，`statsoft-r.ps1` 读 `..\config.json`（即 windows-only 那份）。两套真相源可能分歧。 | 读 `write_config.py` / `statsoft-r.ps1` | 中 |

---

## 案例清单（简单 → 复杂）

### Case 1 — 单工具检测（Simple / 纯检测，无写盘）
- **用户输入**：`Connect SPSS 26` / `连接 SPSS 26`
- **gate-0**：Simple（明确单意图）
- **路径**：`scripts/windows-only/SPSS/setup_spss.ps1`（detect-only）
- **预期**：直接检测，**不弹**扫描/配置菜单；只报 installed 状态；不写 config.json。
- **bug 探针**：① gate-0 Simple 是否真的跳过菜单；② detect-only 是否零文件系统写入（`write_config.py` 仅在 go 时建目录）。
- **判定**：无菜单、无 config.json 改动、`exit 0`、结果含 installed 状态。

### Case 2 — 具体数据转换（Simple / 触发外部二进制）
- **用户输入**：`Convert mydata.sav to mydata.dta`
- **gate-0**：Simple
- **路径**：R + `haven`（`statsoft-r.ps1 data-info` 或转换分支）
- **预期**：明确指出需执行 R（外部二进制），请求执行确认；未确认则优雅取消，**不静默失败**。
- **bug 探针**：Simple 路径承诺"直接动作"，但执行受 `STATSOFT_VERIFY` 闸门拦截 → 是否给出清晰"需确认/设 VERIFY"提示，而非生硬取消。
- **判定**：未授权时输出"需确认执行"，不抛错、不假装完成。

### Case 3 — 运行既有语法文件（Simple / 执行闸门交互）
- **用户输入**：`Run my analysis.do (Stata)`
- **gate-0**：Simple
- **路径**：`cross-platform/Stata/setup_stata.sh` / Stata runner
- **预期**：识别为执行动作；`STATSOFT_VERIFY` 关闭时提示需显式授权。
- **bug 探针**：gate-0 Simple "act in one pass" 与 VERIFY fail-closed 冲突——用户期待直接跑，实际被拦。验证提示是否自洽。
- **判定**：授权提示清晰；`VERIFY=1` 后真正执行。

### Case 4 — 全量自动配置（Complex / 扫描 consent）
- **用户输入**：`帮我配置所有装了的统计软件` / `I'm not sure what's installed`
- **gate-0**：Complex → 弹路由菜单（auto-scan vs 指定路径）
- **路径**：`scan_all.sh` / `scan_all.ps1`（需 consent）
- **预期**：无 consent 时**诚实报 skipped** 并给出开启方式；**绝不伪造**扫描结果。
- **bug 探针**：**[B3]** 无 consent 时 `scan_all.sh` 输出空（仅 skipped），与文档"默认返回 installed 布尔 JSON"矛盾——验证技能是否会把"空输出"误当"未安装"或编造结果。
- **判定**：skipped 状态被如实呈现；提供 `STATSOFT_AUTO_WRITE set to 1` 指引；不臆造 JSON。

### Case 5 — 模糊意图澄清（Vague / grill-me）
- **用户输入**：`我想用统计软件但不知道从哪开始`
- **gate-0**：Vague → grill-me 逐分支追问
- **路径**：无脚本，纯对话澄清
- **预期**：每轮 1–3 个结论性提问（装了哪些？想跑旧脚本/转数据/新建分析？headless 还是 GUI？）；**绝不甩 34 款清单**、不替用户拍板。
- **bug 探针**：澄清循环是否收敛（避免无限追问）；是否误判为 Simple/Complex 而直接弹菜单或强执行。
- **判定**：不输出工具清单；问题聚焦；收敛到具体工具+动作。

### Case 6 — 多工具单意图（边界 / 分类歧义）
- **用户输入**：`Connect R and Python`
- **gate-0**：歧义（两工具但意图明确）→ 应仍判 Simple
- **路径**：`setup_r.sh` + Python 检测
- **预期**：直接检测两个，不强制完整扫描菜单；可"顺带扫描其余？"可选。
- **bug 探针**：若误判 Complex → 强行弹扫描菜单（过度）；验证分类规则对"多工具但明确"的处理。
- **判定**：直检 R+Python；可选 deeper scan；不强制菜单。

### Case 7 — 配置缺失时运行（边界 / 双 config 分歧 + 空值）
- **用户输入**：`statsoft-r.ps1 run x.R`（在 `windows-only/config.json` 缺 `R.Path` 时）
- **gate-0**：Simple（执行动作）
- **路径**：`scripts/windows-only/statsoft-r.ps1` 读 `..\config.json`
- **预期**：缺 `R.Path` 时给出干净"R 未配置，请先 setup"，**非 PowerShell 空引用异常**。
- **bug 探针**：**[B5]** `$config.R.Path` 为 `$null` → `Test-Path $null` 抛错；且 root 与 windows-only 两份 config 可能不一致。
- **判定**：干净报错退出；不崩栈；提示先运行检测。

### Case 8 — locale 分歧（边界 / 双语机制割裂）
- **用户输入**：在 Git Bash 设 `LANG=zh_CN.UTF-8` 但 Windows UI culture=en 的环境跑 `scan_all.sh` + `statsoft-r.ps1`
- **gate-0**：N/A（混合执行）
- **路径**：`scan_all.sh`(取 `LANG`) vs `statsoft-*.ps1`(取 `CurrentUICulture`)
- **预期**：同一次会话输出语言一致，或文档明确说明-split。
- **bug 探针**：两类脚本 locale 来源不同 → 同一回复中英混杂；菜单语言与系统不符。
- **判定**：语言一致或文档已声明差异；不出现半中半英。

### Case 9 — 写盘双重目标（复杂 / 两份 config.json 真相源）
- **用户输入**：授权持久化配置（`STATSOFT_AUTO_WRITE set to 1` 或 `STATSOFT_CONFIRM set to 1`）
- **gate-0**：Complex
- **路径**：`write_config.py` 接受 root **或** `windows-only/config.json`
- **预期**：明确哪份是权威；windows 的 `setup_*.ps1` 写 windows-only 份，cross-platform `setup_*.sh` 写 root 份，但运行时读取方（`statsoft-r.ps1` 读 windows-only）须与写入方一致。
- **bug 探针**：**[B5]** 两份 config 可能分歧（root 有 R、windows-only 无），导致 `statsoft-r.ps1` 读不到刚写入的配置。
- **判定**：单一真相源，或文档+代码明确双份的读写归属。

### Case 10 — 文档-代码一致性全检 + 既有测试（复杂 / 回归）
- **用户输入**：运行 `tests/run_all.py` 并核对 SKILL.md 声明
- **gate-0**：N/A（静态/回归）
- **路径**：`tests/run_all.py` + 文档比对
- **预期**：套件全绿；SKILL.md 变量名(`$PLATFORM/$OS/$ARCH`)、REVEAL 语义、scan 输出格式与代码一致。
- **bug 探针**：**[B1/B2/B3]** 当前 6 条路由断言失败；变量名声明错；REVEAL 与 scan 代码不符。
- **判定**：套件 0 失败；文档三处矛盾已修正。

---

## 用法建议
1. 先跑 `tests/run_all.py` 固化 B1 现状（当前 6 失败）。
2. 按 Case 1→10 顺序手动/半自动执行，每例记录实际输出与判定。
3. B1–B4 建议在**改代码前**先修（B1 修测试或补回路由路径；B3 改文档或给 scan 加 REVEAL 逻辑；B4 给 26 个 ps1 加 BOM）；B5 需决定单一真相源。
4. 本文件可作为回归基线纳入 `tests/`。
