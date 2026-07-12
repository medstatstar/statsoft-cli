# Platform Support / 平台支持

## Full Matrix / 完整矩阵

| Category / 类别 | Software / 软件 | Notes / 备注 |
|-----------------|-----------------|--------------|
| ✅ All platforms (Win + Mac + Linux, CLI) | R, Stata, SAS, CmdStan, GenStat, Gretl, H2O.ai, JAGS, Julia, KNIME, Mathematica, Matlab, OpenBUGS, Orange, OxMetrics, PSPP, Rattle, SHAZAM, Stat/Transfer, Tanagra, TSP, Weka | Full CLI automation on all platforms |
| ✅ Win + Mac + Limited Linux | Mplus | Limited Linux support |
| ⚠️ Win + Limited Mac/Linux | Minitab | Limited Mac/Linux |
| 🔴 Windows only | SPSS Statistics, EViews, JMP, LIMDEP, Microfit, NCSS, NLOGIT, Origin, Q (MRKS), SPSS Modeler, Statistica | Windows-only CLI |
| 🔴 GUI-only (detection + manual-launch only) | AMOS, GraphPad Prism, JASP, jamovi | Can detect and guide manual GUI launch; no CLI batch automation |

## GUI-Only Software / GUI 仅限软件

GUI-only software (AMOS, GraphPad Prism, JASP, jamovi) is limited to **detection + manual-launch guidance** — this skill never drives them via CLI/headless automation, and never creates or modifies their project/data files (including GraphPad Prism `.pzfx`).

GUI 仅限软件（AMOS、GraphPad Prism、JASP、jamovi）仅提供**检测 + 手动启动 GUI 指引**，本技能不通过 CLI/无头方式驱动其批处理，也绝不创建或修改其项目/数据文件（包括 GraphPad Prism `.pzfx`）。

## Version-Specific Notes / 版本差异

See `version-specifics.md` for version differences (SPSS 26/30, R 4.5/4.1, Python 3.4/3.13).

详见 `version-specifics.md`（SPSS 26/30、R 4.5/4.1、Python 3.4/3.13）。
