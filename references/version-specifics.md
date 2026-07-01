# 版本差异 / Version Specifics

> 本文档由 SKILL.md 精简时拆出，包含各统计软件的版本差异信息。

---

## SPSS 版本差异

### Python 版本对比表

| SPSS 版本 | 内置 Python | f-string 支持 | 推荐使用方式 |
|-----------|-------------|---------------|--------------|
| 26 |  **Python 3.4**（含 spss 模块）/ Python 2.7（旧 API，不建议） | ❌ 不支持 | 内置 Python 3.4（无 f-string），脚本需用 `%s` 或 `.format()` |
| 27 | Python 3.8 | ✅ 支持 | 内置 Python 3.8 |
| 28 | Python 3.9 | ✅ 支持 | 内置 Python 3.9 |
| 29 | Python 3.10.4 | ✅ 支持 | 内置 Python 3.10.4 |
| 30 | Python 3.10 | ✅ 支持 | 内置 Python 3.10 |
| 31 | Python 3.10 | ✅ 支持 | 内置 Python 3.10 |

### 影响与注意事项

#### 1. spss_helper.py 脚本兼容性

- **SPSS 26**：内置 Python 3.4，不支持 f-string，脚本必须使用 `%s` 或 `.format()`
- **SPSS 27+**：内置 Python 3.8+，支持 f-string

**解决方案**：
- `spss_helper.py` 脚本已确保兼容 Python 3.4（不使用 f-string）
- 如需使用 f-string，请升级到 SPSS 27 或更高版本

#### 2. 生产模式差异

| 版本 | 生产作业文件格式 | 变化 |
|------|-----------------|------|
| 26 | `.spj` (XML 格式) | 无变化 |
| 27-31 | `.spj` (XML 格式) | 无变化 |

**注意**：从 SPSS 16.0 开始，生产作业文件格式从 `.spp` 改为 `.spj`。本技能使用 `.spj` 格式。

#### 3. 版本检测方法

在 `setup_spss.ps1` 中，通过读取注册表或安装目录名称来检测版本：

```powershell
# 从安装路径提取版本号
$version = "26"
if ($installPath -match "Statistics\(\d+)") {
    $version = $matches[1]
}

# 根据版本设置 Python 兼容性标志
if ([int]$version -le 26) {
    $useFString = $false
} else {
    $useFString = $true
}
```

#### 4. 推荐配置策略

**对于 SPSS 26 用户**：
- ✅ 使用内置 Python 3.4 调用 `spss` 模块（完全无闪屏）
- ⚠️ 脚本中**禁止使用 f-string**
- 💡 复杂任务建议使用外部 Python（Anaconda）

**对于 SPSS 27+ 用户**：
- ✅ 使用内置 Python（支持 f-string）
- ✅ 可以使用现代 Python 语法
- ✅ 性能更好

### 官方文档链接

- SPSS 26: https://www.ibm.com/docs/zh/spss-statistics/26.0.0
- SPSS 27: https://www.ibm.com/docs/zh/spss-statistics/27.0.0
- SPSS 28: https://www.ibm.com/docs/zh/spss-statistics/28.0.0
- SPSS 29: https://www.ibm.com/docs/zh/spss-statistics/29.0.0
- SPSS 30: https://www.ibm.com/docs/zh/spss-statistics/30.0.0
- SPSS 31: https://www.ibm.com/docs/zh/spss-statistics/31.0.0

---

## Stata 版本差异

### 版本与可执行文件对照

| 版本 | MP | SE | BE |
|------|----|----|-----|
| Stata ≤ 12 | `StataMP` | `StataSE` | `Stata` |
| Stata 13/14/15 | `StataMP` | `StataSE` | `Stata` |
| Stata 16+ | `StataMP-64.exe` | `StataSE-64.exe` | `Stata-64.exe` |

### ⚠️ 批处理命令行参数差异（重要）

| 版本 | Windows 静默参数 | Mac/Linux 静默参数 | 说明 |
|------|-----------------|-------------------|------|
| **Stata ≤ 12** | `/e do "script.do"` | `-e do "script.do"` | `-e` 参数禁止弹出确认框 |
| **Stata ≥ 13** | `/b do "script.do"` | `-b do "script.do"` | `-b` 参数禁止弹出确认框 |

**关键**：Stata 12 **不支持 `-b` 参数**！必须用 `-e`。新版本（13+）`-e` 已被废除，必须用 `-b`。

### 版本特定变化

| 变化 | 版本 | 说明 |
|------|------|------|
| 新增 `/b` 参数 | Stata 13+ | 替代旧的 `/e` 参数，效果相同 |
| 新增 `-64` 后缀 | Stata 16+ | 可执行文件名增加 `-64` 后缀 |
| Python 集成 | Stata 16+ | 可从 Stata 调用 Python |
| PyStata | Stata 17+ | 可从 Python 调用 Stata |
| StataNow | Stata 19+ | 引入 StataNow 快速更新机制 |

### Windows 安装路径差异

| 版本 | 默认安装路径 |
|------|-------------|
| Stata 14-18 | `C:\Program Files\StataNN`（NN 为版本号） |
| Stata 19+ | `C:\Program Files\Stata19` 或 `C:\Program Files\StataNow19` |

---

## R 版本差异

### Python 版本兼容性

| R 版本 | 兼容 Python 版本 | 对应 SPSS 版本 |
|--------|-----------------|---------------|
| 3.4 | Python 3.4 | SPSS 26 |
| 3.5 | Python 3.5 | — |
| 3.6 | Python 3.6 | — |
| 3.7+ | Python 3.7+ | — |
| 3.8+ | Python 3.8+ | SPSS 27+ |
| 3.10+ | Python 3.10+ | SPSS 29+ / 30 / 31 |

### Anaconda Python 与 R 兼容性

| Anaconda Version | Python | 备注 |
|-----------------|--------|------|
| Anaconda 2.x | Python 2.7 | 已弃用，不建议使用 |
| Anaconda 3.x | 3.7+ | 与 Python 3.4 的 SPSS 内置 Python 可共存 |
| Anaconda 3.x | 3.10+ | 需要与 SPSS 内置 Python 分开安装 |

### R Packages 兼容性

| R 版本 | 推荐 Packages | 替代方案 |
|--------|---------------|----------|
| R 3.4 | base, survival | — |
| R 3.5+ | tidyverse, caret | data.table + mlr3 |
| R 3.6+ | renv | packrat |
| R 4.0+ | vroom, arrow | readr, data.table |

---

## SAS 版本差异

### 平台与版本对照

| 平台 | 默认安装路径 |
|------|-------------|
| Windows | `C:\Program Files\SASFoundation\9.4\` |
| Mac | `/Applications/SASFoundation/9.4/` |
| Linux | `/opt/SASFoundation/9.4/` |

### SAS 批处理模式输出文件

| 文件扩展名 | 说明 |
|-----------|------|
| `.sas` | SAS 程序源文件 |
| `.log` | 日志文件（执行记录） |
| `.lst` | 输出列表（结果） |
| `.sas7bdat` | SAS 数据集 |

---

## JMP 版本差异

| 版本 | 文件扩展名 | 批处理命令 |
|------|-----------|-----------|
| JMP 14/15/16 | `.jsl` | `JMP.exe /R "script.jsl"` |
| JMP 16 Pro | `.jsl` | `JMP.exe /S /R "script.jsl"` |
| JMP Live | Web-based | Web API |

---

## GraphPad Prism 版本差异

| 版本 | 安装路径 | 限制 |
|------|---------|------|
| 8 | `C:\Program Files\GraphPad\Prism 8\` | 无 CLI |
| 9 | `C:\Program Files\GraphPad\Prism 9\` | 无 CLI |
| 10 | `C:\Program Files\GraphPad\Prism 10\` | 无 CLI |

⚠️ 所有版本均无 CLI 模式，调用时都会弹出 GUI 界面。

### 替代方案

| 方案 | 说明 |
|------|------|
| Python prismWriter | 后台操作 .pzfx 文件（无需 GUI） |
| Windows COM/OLE | 通过 pywin32 调用 GraphPad Prism 自动化接口 |
| GraphPad Script | 内置脚本语言（非 CLI） |
| AppleScript | macOS 上通过 AppleScript 控制 Prism |

---

## 操作系统版本差异

### Python 在 Windows 上的编码问题

| 版本 | `python.exe` 默认编码 | 说明 |
|------|---------------------|------|
| Python 2.7 | `cp1252` / `gbk` | 需 `sys.setdefaultencoding('utf-8')`，2.7版本太老，不建议使用 |
| Python 3.4 | `cp1252` | SPSS 内置 Python 3.4 使用此编码 |
| Python 3.8+ | `utf-8`（Windows 10 1903+） | 推荐使用 |
| Python 3.10+ | `utf-8` | 默认 UTF-8 |

**注意**：SPSS 输出含非 UTF-8 字符，读取时需用 `cp1252` 或 `errors='replace'` 处理。

### 路径差异

| 操作系统 | 路径分隔符 | 示例 |
|---------|-----------|------|
| Windows | `\`（反斜杠） | `C:\Program Files\IBM\SPSS\...` |
| macOS | `/`（正斜杠） | `/Library/Frameworks/R.framework/...` |
| Linux | `/`（正斜杠） | `/usr/lib/R/...` |

**注意**：R 脚本中 `\` 是转义符，需使用正斜杠 `/` 或双反斜杠 `\\`。
