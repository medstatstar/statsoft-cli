# SPSS Splash-free Call Test / SPSS 无闪屏调用测试

## Test Purpose / 测试目的

验证 SPSS 无闪屏调用方式是否正常工作。

Verify that the SPSS splash-free call method works correctly.

> ⚠️ **副作用提示 / Side effects**：运行本测试会**执行第三方 SPSS 二进制**，并在磁盘上**写入文件** `test-data.sav`（约 5 条记录）。这是测试的预期产物，仅供手动执行；请勿在自动化流程中静默运行。测试完成后请参见文末「清理 / Cleanup」删除该文件。
>
> Running this test **executes the third-party SPSS binary** and **writes a file** `test-data.sav` (~5 rows) to disk. This is an expected artifact of a manually-run test — do not run it silently in automation. See "Cleanup" at the end to remove it afterward.

## Test Method / 测试方法

### Preferred Method (Completely Splash-free) / 首选方式（完全无闪屏）

使用 SPSS 内置 Python 的 `spss` 模块直接运行语法，不调用 `stats.exe`，完全无 GUI。

Use SPSS built-in Python's `spss` module to run syntax directly, without calling `stats.exe`, completely GUI-free.

```bash
# 通过 spss_helper.py 运行
"[SPSS_PYTHON_PATH]" "[SKILL_DIR]/windows-only/SPSS/spss_helper.py" run-internal "[SPS_FILE]"

# 示例
"C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe" \
  "[SKILL_DIR]/windows-only/SPSS/spss_helper.py" \
  run-internal \
  "[SKILL_DIR]/tests/test-syntax.sps"
```

### Backup Method (No Splash) / 备用方式（无闪屏）

通过 `stats.com`（控制台版）调用 .spj 文件，完全无闪屏：

```bash
# 示例
"C:\Program Files\IBM\SPSS\Statistics\26\stats.com" -production silent -nologo "[SKILL_DIR]/tests/test-job.spj"
```

`stats.com` 控制台版纯后台运行，绝无闪屏。

最后备选（可能有闪屏）： `stats.exe -production silent -nologo`。

Call .spj file via `stats.exe -production`. This method may display splash screen.

```bash
# 通过 spss_helper.py 运行
"[STATS_EXE_PATH]" -production "[SPJ_FILE]" silent -nologo

# 示例
"C:\Program Files\IBM\SPSS\Statistics\26\stats.exe" \
  -production \
  "[SKILL_DIR]/tests/test-job.spj"
```

## Test Files / 测试文件

- `test-syntax.sps` — SPSS 语法文件，生成测试数据并保存
- `test-job.spj` — SPSS 生产作业文件（备用方式使用）

## Expected Results / 预期结果

1. **无闪屏** — 运行时不显示 SPSS GUI 窗口
2. **输出文件生成** — 生成 `test-data.sav` 文件
3. **数据正确** — `test-data.sav` 包含 5 条记录，id 和 score 两列

## Verification Method / 验证方法

```bash
# 检查输出文件是否生成
ls -la "[SKILL_DIR]/test-data.sav"

# 读取 .sav 文件内容（需要 pyreadstat）
python -c "
import pyreadstat
df, meta = pyreadstat.read_sav('[SKILL_DIR]/test-data.sav')
print(df)
"
```

## Cleanup / 清理

测试会写入 `test-data.sav`。测试完成后删除该文件即可清除所有磁盘副作用 / The test writes `test-data.sav`; delete it after the test to remove all disk side effects:

```bash
rm -f "[SKILL_DIR]/test-data.sav"
```

## Notes / 注意事项

1. SPSS 26 内置 Python 3.4，不支持 f-string，所有字符串格式化必须用 `%s` 或 `.format()`
2. 确保输出路径有写权限
3. 如果测试失败，检查 SPSS 安装路径是否正确