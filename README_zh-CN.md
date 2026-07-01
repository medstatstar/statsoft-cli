# statsoft-cli

[🇨🇳 中文 (Chinese)](./README_zh-CN.md) | [🇬🇧 English](./README.md)

---

跨平台统计软件 CLI 集成技能，用于 AI Agent（如 WorkBuddy / OpenClaw ）。同一个软件支持多个版本共存，如 R4.5 和 R4.0 共存，只需要指定默认使用哪个版本即可，需要时用提示词可实现无缝切换。

支持 13 款统计软件：SPSS、R、Stata、SAS、JMP、GraphPad Prism、EViews、Statistica、Stat/Transfer、Gretl、Minitab、Matlab、Julia。

### 技能目的

很多统计软件都有 CLI（命令行）执行方式，但并不是每个人都会使用。本技能的目的是将这些统计软件整合到 AI 智能体环境下统一使用，从而方便统计师充分利用这些统计软件的能力。**本技能的核心价值在于盘活历史代码资产，解决 AI 工作流自动化中的可复用性难题**。在长期的项目积累中，团队已经沉淀了大量可复用的分析代码——R 的统计建模脚本、SPSS 的语法文件、SAS 的宏程序、Stata 的 do-file 等。然而，当试图将这些历史资产直接接入 AI 自动化工作流时，就需要分别提供每种统计软件合适的调用接口。本技能正是要解决这个问题——通过 AI 智能体将这些历史代码纳入统一的执行框架，使得这些代码可以作为 AI 工作流中的一个标准节点，被反复调用、组合和编排。

## 平台支持

| 类别 | 软件 |
|------|------|
| ✅ 全部平台 (Win + Mac + Linux) | R, Stata, SAS, Stat/Transfer, Gretl, Matlab, Julia |
| ⚠️ Win + 有限 Mac/Linux | Minitab |
| 🔴 Windows only | SPSS, JMP, GraphPad Prism, EViews, Statistica |

## 典型场景

1. **多软件混合工作流** — 同一会话中无缝调用 R 建模 + SPSS 描述 + Stata 数据整理
2. **历史代码资产复用** — 将 R 脚本、SPSS 语法、SAS 宏、Stata do-file 统一纳入 AI 工作流
3. **数据格式转换** — StatTransfer 在不同统计软件间迁移数据（SAS ↔ SPSS ↔ Stata ↔ Excel）
4. **SPSS 无闪屏批处理** — 通过内置 Python 引擎（spss.StartSPSS）运行 sps 语法，跳过闪屏
5. **SAS 批处理自动化** — 通过 SAS CLI 调度宏程序，生成定期报告

## 脚本路由表

### 核心软件

| 软件 | Windows 脚本 | 跨平台脚本 | 验证 |
|------|-------------|-----------|------|
| SPSS | SPSS/setup_spss.ps1 | — | spss.exe -production mode "exit.sps" |
| R | statsoft-r.ps1 | cross-platform/R/setup_r.sh | Rscript --version |
| Stata | — | cross-platform/Stata/setup_stata.sh | stata-mp -b do "exit" |
| SAS | statsoft-sas.ps1 | cross-platform/SAS/setup_sas.sh | sas -version |

（完整路由表含 EViews, Statistica, Gretl, Minitab, Matlab, Julia 等，详见 ADDITIONAL_SOFTWARE.md）

## 目录结构

```
statsoft-cli/
├── SKILL.md                          # 技能主文件
├── README_zh-CN.md                   # 中文 README
├── ADDITIONAL_SOFTWARE.md            # 扩展软件详细配置
├── LICENSE                           # MIT-0 许可证
├── config.json.example               # 配置模板
├── cross-platform/                   # 跨平台脚本
│   ├── _platform-detect.sh           # 平台检测
│   ├── R/setup_r.sh                  # R 配置
│   ├── Stata/setup_stata.sh          # Stata 配置
│   ├── SAS/setup_sas.sh              # SAS 配置
│   └── ...                           # 其他跨平台软件
├── windows-only/                     # Windows 专用脚本
│   ├── SPSS/                         # SPSS 全套 (setup + helper + internal)
│   ├── JMP/                          # JMP JSL 批处理
│   ├── GraphPad/                     # GraphPad Prism
│   ├── EViews/                       # EViews 计量经济
│   ├── Statistica/                   # Statistica 数据挖掘
│   ├── StatTransfer/                 # Stat/Transfer 数据格式转换
│   ├── statsoft-r.ps1                # R Windows 包装器
│   └── statsoft-sas.ps1              # SAS Windows 包装器
├── references/                       # 参考文件
│   ├── command-examples.md           # CLI 调用示例
│   ├── version-specifics.md          # 版本差异
│   ├── completion-prompts.md         # 配置完成提示
│   └── config-templates.md           # 配置模板
└── tests/                            # 测试文件
    ├── test-syntax.sps               # SPSS 测试语法
    ├── test-job.spj                  # SPSS 生产作业
    └── README.md                     # 测试说明
```

## 使用方式

在 AI Agent 对话中使用自然语言触发：

```
关联 SPSS
帮我配置 R 的命令行
将 data.sav 转换为 data.dta
运行 Stata do-file
```

## 安全说明

本技能执行**高风险操作**（执行本地可执行文件、修改配置、调用网络），使用前请了解风险。SKILL.md 中有完整 Trust & Safety 说明。

## License

[MIT-0](LICENSE)
