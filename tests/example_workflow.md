# Multi-Software Workflow Example

> This file demonstrates how to combine multiple statistical software in a single AI Agent workflow.
> 本文件演示如何在单个 AI Agent 工作流中组合使用多款统计软件。

---

## Scenario

**Research Question**: Analyze customer churn factors using historical code assets from R, SPSS, Stata, and SAS.

**研究问题**: 使用 R、SPSS、Stata、SAS 的历史代码资产分析客户流失因素。

---

## Workflow

### Step 1: Data Preparation with R

**Purpose**: Clean and prepare raw data using existing R scripts.
**目的**: 使用现有 R 脚本清理和准备原始数据。

```r
# test_r_cleaning.R (historical code asset)
library(dplyr)
library(tidyr)

data <- read.csv("raw_customer_data.csv", fileEncoding="UTF-8")

# Clean data
data_clean <- data %>%
  filter(!is.na(customer_id)) %>%
  mutate(churn = ifelse(churn_flag == 1, "Yes", "No")) %>%
  select(customer_id, age, tenure, monthly_charges, churn)

# Export for SPSS
write.csv(data_clean, "data_clean.csv", row.names=FALSE, fileEncoding="UTF-8")
```

**AI Agent command**:
```
Run R script test_r_cleaning.R to clean customer data
```

---

### Step 2: Descriptive Statistics with SPSS

**Purpose**: Generate descriptive statistics and visualizations using existing SPSS syntax.
**目的**: 使用现有 SPSS 语法生成描述性统计和可视化。

```spss
* test_spss_descriptive.sps (historical code asset)
GET FILE="data_clean.csv".

* Descriptive statistics
SUMMARY
  /VARIABLES=age tenure monthly_charges
  /FORMAT=LIST.

* Churn distribution
CROSSTABS
  /TABLES=churn BY contract_type
  /FORMAT=AVALUE.

* Export results
OUTPUT EXPORT
  /CONTENTS EXPORT=ALL
  /TYPE=HTML
  /FILE="desc_stats.html".
```

**AI Agent command**:
```
Run SPSS syntax test_spss_descriptive.sps
```

---

### Step 3: Regression Analysis with Stata

**Purpose**: Run logistic regression using existing Stata do-files.
**目的**: 使用现有 Stata do-file 运行逻辑回归。

```stata
* test_stata_regression.do (historical code asset)
import delimited "data_clean.csv"

* Encode categorical variables
encode contract_type, gen(contract_num)
encode payment_method, gen(payment_num)

* Logistic regression
logit churn age tenure monthly_charges contract_num payment_num

* Odds ratios
logit, or

* Export results
outreg2 using "regression_results.doc", replace ctitle(Churn Model)
```

**AI Agent command**:
```
Run Stata do-file test_stata_regression.do
```

---

### Step 4: Report Generation with SAS

**Purpose**: Generate final report with tables and charts using existing SAS macros.
**目的**: 使用现有 SAS 宏程序生成包含表格和图表的终期报告。

```sas
* test_sas_report.sas (historical code asset);
proc import datafile="data_clean.csv"
    out=customer_data
    dbms=csv
    replace;
run;

* Generate summary table;
proc means data=customer_data mean std min max;
    var age tenure monthly_charges;
    class churn;
    output out=summary_table;
run;

* Export to Excel;
proc export data=summary_table
    outfile="final_report.xlsx"
    dbms=xlsx
    replace;
run;

* Print completion message;
%put NOTE: ✅ Final report generated: final_report.xlsx;
```

**AI Agent command**:
```
Run SAS program test_sas_report.sas
```

---

> ⚠️ **安全提示 / Safety**: 以下命令会依次执行外部脚本（R/SPSS/Stata/SAS）并在本地生成/覆盖文件。执行前请审阅所有被引用的脚本与输出路径，建议在隔离的工作目录中以最小权限运行。
> ⚠️ **Safety**: the commands below execute external scripts (R/SPSS/Stata/SAS) and create or overwrite local files. Review every referenced script and output path before running, and prefer an isolated working directory with least privilege.

## Multi-step Workflow — one explicit step at a time

> ⚠️ **Do NOT trigger a whole pipeline from a single broad prompt.** Each step
> executes an external statistical binary and may create/overwrite files, so it
> must be invoked **explicitly and individually**, with review between steps.
> 请勿用一句宽泛的自然语言指令触发整条流水线。每一步都会执行外部统计软件并可能
> 创建/覆盖文件，必须**逐条显式调用**，并在步骤之间进行审阅。

**Required practice for a multi-tool analysis / 多工具分析的必须做法**:

1. **Invoke each tool explicitly, one command per step** — name the exact script
   and the exact command. Do not ask the agent to "run the whole workflow".
   逐步显式调用，每步一条命令，指明确切脚本与命令，不要让 agent "自动跑完整流程"。
2. **Confirm before each step** — review the referenced script and the intended
   output path, and give explicit approval before that step runs.
   每步前确认——审阅被引用脚本与预期输出路径后再显式批准。
3. **No implicit data passing** — if the output of one step feeds the next,
   state that path explicitly; the agent must not infer and chain files silently.
   不做隐式数据传递——若上一步输出作为下一步输入，请显式给出路径。
4. **Allowlist script paths & isolate the working directory** — run only the
   named scripts, in a dedicated, least-privilege working directory.
   仅允许命名脚本，并在独立、最小权限的工作目录中运行。
5. **Dry-run / review first** — ask the agent to enumerate every command and every
   output file it *would* run/write, and approve that list, before any execution.
   先做 dry-run/审阅——让 agent 列出将执行的每条命令与将写入的每个文件并批准后再执行。

Example of the explicit, per-step style (run and confirm each separately):
逐步显式调用示例（分别执行并确认每一步）：

```
Step 1 (confirm first): Clean data — run test_r_cleaning.R, output to ./work/clean.csv
Step 2 (confirm first): Descriptive stats — run test_spss_descriptive.sps on ./work/clean.csv
Step 3 (confirm first): Regression — run test_stata_regression.do on ./work/clean.csv
Step 4 (confirm first): Report — run test_sas_report.sas
```

The agent must stop after each step for your review; it must not auto-chain steps
or pass data between tools without your explicit approval.

Agent 必须在每一步后停下等待您审阅；不得自动串联步骤或在未获显式批准时于工具间传递数据。

---

## Key Benefits

| Benefit / 优势 | Description / 说明 |
|----------------|-------------------|
| 🔄 **Code Reuse / 代码复用** | Leverage historical assets without rewriting |
| 🔗 **User-Approved Handoff / 用户批准的数据交接** | AI Agent supports explicit, per-step-approved data handoff between tools — never implicit/automatic chaining |
| ⚡ **Guided Multi-Turn / 引导式多轮** | One ongoing session with explicit confirmation before each step — "single conversation" means guided, not one-shot pipeline execution |
| 📊 **Best Tool for Each Task / 任务最优工具** | Use R for cleaning, SPSS for stats, Stata for regression, SAS for reporting |

> ⚠️ **No step runs and no data passes between tools without your explicit approval.** Each step stops for your review; the agent never auto-chains steps or transfers data implicitly.

---

## Test These Scripts

Use the test scripts in this directory to verify your software configuration:

使用本目录中的测试脚本验证您的软件配置：

| Script / 脚本 | Software | Command |
|--------|----------|---------|
| `test-syntax.sps` | SPSS Statistics | `stats.exe -syntax "test-syntax.sps"` |
| `test_r.r` | R | `Rscript --vanilla "test_r.r"` |
| `test_do.do` | Stata | `stata-mp -b do "test_do.do"` |
| `test_sas.sas` | SAS | `sas -sysin "test_sas.sas"` |

---

**📚 More Examples**: See [`ADDITIONAL_SOFTWARE.md`](../ADDITIONAL_SOFTWARE.md) for detailed use cases of all 31 supported software packages.