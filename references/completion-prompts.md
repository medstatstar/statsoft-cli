# 配置完成提示模板 / Configuration Completion Prompts

> 本文档由 SKILL.md 精简时拆出，包含各统计软件配置完成后的提示模板。
> 软件统计完成后，AI 应按以下模板输出提示信息给用户。

---

## SPSS 配置完成提示

```
✅ SPSS 关联配置已完成！

⭐ 首选调用方式（完全无闪屏）：
  通过 SPSS 内置 Python 的 spss 模块直接运行语法，不调用 stats.exe，完全无 GUI。

⚠️ 备用调用方式（可能有闪屏）：
  通过 stats.exe --production 调用 .spj 文件。此方式可能显示闪屏，建议优先使用首选方式。

📊 配置信息：
  - SPSS 版本: [26/27/28/29/30/31]
  - SPSS 主程序: [stats.exe 路径]
  - 内置 Python: [Python 路径]
  - Python 版本: [Python 版本号]
  - f-string 支持: [✅ 支持 / ❌ 不支持]

⚠️ 重要注意事项：
  1. SPSS 26 内置 Python 3.4，不支持 f-string，所有字符串格式化必须用 %s 或 .format()
  2. SPSS 27+ 内置 Python 3.8+，支持 f-string，可使用现代 Python 语法
  3. .spj 文件必须包含 <output> 元素，否则会报 NullPointerException
  4. SPSS 输出含非 UTF-8 字符，读取时需用 cp1252 或 errors='replace' 处理

📋 推荐使用方式：
  AI Agent (Bash 工具)
    → "[Python路径]" spss_helper.py run-internal <sps_file>
        → SPSS 后台执行（无 GUI，无闪屏）

  💡 复杂任务：建议使用外部 Anaconda Python 的 pyreadstat 包读取 .sav 和 .spv 文件
```

### English Version

```
✅ SPSS connection configuration complete!

⭐ Preferred invocation method (completely splash-free):
  Use SPSS built-in Python's spss module to run syntax directly, without calling stats.exe, completely GUI-free.

⚠️ Backup invocation method (may have splash screen):
  Call .spj file via stats.exe --production. This method may display splash screen, recommend using preferred method first.

📊 Configuration Information:
  - SPSS Version: [26/27/28/29/30/31]
  - SPSS Main Executable: [stats.exe path]
  - Bundled Python: [Python path]
  - Python Version: [Python version]
  - f-string Support: [✅ Supported / ❌ Not supported]

⚠️ Important notes:
  1. SPSS 26 built-in Python 3.4 does not support f-string, all string formatting must use %s or .format()
  2. SPSS 27+ built-in Python 3.8+ supports f-string, can use modern Python syntax
  3. .spj file must include <output> element, otherwise NullPointerException will occur
  4. SPSS output contains non-UTF-8 characters, use cp1252 or errors='replace' when reading

📋 Recommended usage:
  AI Agent (Bash tool)
    → "[Python path]" spss_helper.py run-internal <sps_file>
        → SPSS runs in background (no GUI, no splash screen)

  💡 Complex tasks: Consider using external Anaconda Python pyreadstat package to read .sav and .spv files
```

---

## Stata 配置完成提示

```
✅ Stata 关联配置已完成！

⚠️ 重要注意事项：
  1. **⚠️⚠️ Stata 版本与批处理参数（重要）**：
     - **Stata 12 及更早** → Windows: `/e do "script.do"`, Mac/Linux: `-e do "script.do"`
     - **Stata 13 及之后** → Windows: `/b do "script.do"`, Mac/Linux: `-b do "script.do"`
     - ❌ **用错版本参数会导致弹出确认框！**
  2. 路径中含有空格时必须用双引号包裹，否则会报 file not found 错误
  3. **许可证匹配**：调用 Stata 时必须使用与许可证匹配的版本可执行文件
     - 有 MP 许可证 → 使用 StataMP-64.exe（Windows）或 stata-mp（Mac/Linux）
     - 有 SE 许可证 → 使用 StataSE-64.exe（Windows）或 stata-se（Mac/Linux）
     - 有 BE 许可证 → 使用 Stata-64.exe（Windows）或 stata（Mac/Linux）
     - ❌ 如果用错版本（如用 MP 版但没有 MP 许可证），Stata 会启动失败或报错
  4. **版本功能差异**：
     - MP（Multiprocessing）：支持多核并行，适合大数据
     - SE（Special Edition）：单核，适合中等数据
     - BE（Basic Edition）：功能受限，不支持并行
  5. **版本特定变化**：
     - Stata 14/15：可执行文件名为 StataMP、StataSE（无 -64 后缀）
     - Stata 16+：可执行文件名为 StataMP-64、StataSE-64（新增 -64 后缀）
     - Stata 16+：支持 Python 集成（可从 Stata 调用 Python）
     - Stata 17+：引入 PyStata（可从 Python 调用 Stata）
     - Stata 19+：引入 StataNow 快速更新机制
  6. **Windows 安装路径差异**：
     - Stata 14-18: `C:\Program Files\StataNN`（NN为版本号）
     - Stata 19: `C:\Program Files\Stata19` 或 `C:\Program Files\StataNow19`

📋 推荐使用方式：
  # Windows（根据许可证选择正确版本）
  "StataMP-64.exe" /b do "script.do"   # MP 版（Stata 16+）
  "StataSE-64.exe" /b do "script.do"   # SE 版（Stata 16+）
  "Stata-64.exe" /b do "script.do"     # BE 版（Stata 16+）
  "StataMP" /b do "script.do"          # MP 版（Stata 14/15）

  # Mac/Linux（根据许可证选择正确版本）
  stata-mp -b do "script.do"   # MP 版
  stata-se -b do "script.do"   # SE 版
  stata -b do "script.do"      # BE 版
```

---

## R 配置完成提示

```
✅ R 关联配置已完成！

⚠️ 重要注意事项：
  1. 批处理模式使用 Rscript 命令，不要用 R GUI
  2. 安装新 R 包时使用 quiet=TRUE 参数实现静默安装
  3. 中文乱码问题：用 fileEncoding="UTF-8" 参数指定文件编码
  4. 内存不足时：使用 data.table 或 arrow 包处理大数据

📋 推荐使用方式：
  Rscript --vanilla "script.R"

  # 静默安装包
  Rscript -e "install.packages('[PKG]', repos='https://cran.r-project.org', quiet=TRUE)"

  # 读取 SPSS .sav 文件
  Rscript -e "library(haven); df <- read_sav('data.sav'); print(head(df))"

💡 无 R 时的替代方案：
  如果未安装 R 且不愿意安装，可以使用 Anaconda Python 环境作为替代：
  - dplyr / tidyr → pandas
  - ggplot2 → matplotlib / seaborn
  - caret / xgboost → scikit-learn
  - survival → lifelines
  - lme4 / nlme → statsmodels
  - metafor → PyMC
```

---

## SAS 配置完成提示

```
✅ SAS 关联配置已完成！

⚠️ 重要注意事项：
  1. 批处理模式会生成 .log（日志）和 .lst（输出列表）文件，确保输出路径有写权限
  2. 中文乱码问题：在程序开头加 options encoding='utf-8';
  3. SAS 许可证过期会导致 ERROR: License 过期，需更新许可证文件

📋 推荐使用方式：
  # Windows
  "sas.exe" -sysin "prog.sas" -log "out.log" -print "out.lst"

  # Mac/Linux
  sas -sysin "prog.sas" -log "out.log" -print "out.lst"
```

---

## JMP 配置完成提示

- ⚠️ JMP 运行时会有短暂闪屏（1-2秒），无法完全避免
- ⚠️ 脚本末尾必须加 `Exit();`，否则 JMP GUI 会保持打开

> 详细配置信息和注意事项请参考 [ADDITIONAL_SOFTWARE.md → JMP](ADDITIONAL_SOFTWARE.md#jmp)


---

## GraphPad Prism 配置完成提示

- ⚠️⚠️⚠️ GraphPad Prism **没有 CLI 模式**，调用时会弹出 GUI 界面（无法避免）
- ⚠️ 使用时会有以下现象：调用时弹出 GUI 界面，用户需手动操作

**替代方案**：
| 方案 | 说明 |
|------|------|
| Python `prismWriter` | 后台操作 .pzfx 文件（无需 GUI） |
| Windows COM/OLE | 通过 pywin32 调用 GraphPad Prism 自动化接口 |

> 详细配置信息和注意事项请参考 [ADDITIONAL_SOFTWARE.md → GraphPad Prism](ADDITIONAL_SOFTWARE.md#graphpad-prism)


---

## Stat/Transfer 配置完成提示

- ✅ Stat/Transfer 是纯 CLI 工具，完全无 GUI，适合自动化
- ⚠️ 转换前请确认目标格式支持所需的数据类型

> 详细配置信息请参考 [ADDITIONAL_SOFTWARE.md → Stat/Transfer](ADDITIONAL_SOFTWARE.md#stattransfer)


---

## Gretl 配置完成提示

- ✅ Gretl 是纯 CLI 工具，完全无 GUI，无闪屏
- ✅ 免费软件，适合计量经济学分析
- 💡 支持 Stata .dta、SAS .sas7bdat、Excel .xlsx 等格式读取

> 详细配置信息请参考 [ADDITIONAL_SOFTWARE.md → Gretl](ADDITIONAL_SOFTWARE.md#gretl)


---

## Minitab 配置完成提示

- ⚠️ Minitab 批处理模式可能有短暂闪屏
- ⚠️ 确保许可证有效
- 💡 适合质量控制和六西格玛项目

> 详细配置信息请参考 [ADDITIONAL_SOFTWARE.md → Minitab](ADDITIONAL_SOFTWARE.md#minitab)


---

## Matlab 配置完成提示

- ✅ 使用 `-batch` 参数时完全无 GUI，无闪屏
- ⚠️ 需要 Statistics and Machine Learning Toolbox 进行统计分析
- 💡 适合工程统计、信号处理和机器学习

> 详细配置信息请参考 [ADDITIONAL_SOFTWARE.md → Matlab](ADDITIONAL_SOFTWARE.md#matlab)


---

## Julia 配置完成提示

- ✅ Julia 是纯 CLI 工具，完全无 GUI，无闪屏
- ✅ 高性能，适合大数据和复杂统计计算
- 💡 常用包：`Statistics`、`HypothesisTests`、`GLM`、`Turing`（贝叶斯）

> 详细配置信息请参考 [ADDITIONAL_SOFTWARE.md → Julia](ADDITIONAL_SOFTWARE.md#julia)


---

## EViews 配置完成提示

- ⚠️ EViews 批处理模式可能有闪屏
- ⚠️ Windows-only，不支持 macOS 和 Linux
- 💡 适合时间序列分析、回归和预测

> 详细配置信息请参考 [ADDITIONAL_SOFTWARE.md → EViews](ADDITIONAL_SOFTWARE.md#eviews)


---

## Statistica 配置完成提示

- ⚠️ Statistica 批处理模式可能有闪屏
- ⚠️ Windows-only，不支持 macOS 和 Linux
- 💡 适合数据挖掘、机器学习和统计分析

> 详细配置信息请参考 [ADDITIONAL_SOFTWARE.md → Statistica](ADDITIONAL_SOFTWARE.md#statistica)


---

## 通用记忆模板格式

如果软件未在本文档中列出，可使用以下通用模板：

### 中文记忆模板

```
### [软件名] 环境配置 / [Software] Environment

- **版本 / Version**：[版本号]
- **主程序路径 / Executable Path**：`[路径]`
- **批处理命令行格式 / Batch Command Format**：
  ```bash
  [调用命令]
  ```
- **脚本模板 / Script Template**：
  ```[语言]
  [示例代码]
  ```
- **常见错误与解决方案 / Common Errors & Solutions**：
  | 错误 | 原因 | 解决方案 |
  |------|------|---------|
  | [错误1] | [原因] | [方案] |
- **配置完成提示 / Configuration Completion Notes**：
  - ✅ [优点1]
  - ⚠️ [注意事项1]
```

### English Memory Template

```
### [Software] Environment

- **Version**: [version]
- **Executable Path**: `[path]`
- **Batch Command Format**:
  ```bash
  [command]
  ```
- **Script Template**:
  ```[language]
  [code]
  ```
- **Common Errors & Solutions**:
  | Error | Cause | Solution |
  |-------|-------|---------|
  | [error1] | [cause] | [solution] |
- **Configuration Completion Notes**:
  - ✅ [benefit1]
  - ⚠️ [caution1]
```
