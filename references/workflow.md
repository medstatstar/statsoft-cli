# Execution Workflow / 执行工作流

本技能执行以下标准工作流。每一步都有默认拒绝闸门。/ This skill follows the standard workflow below. Every step is gated by default-deny.

## Step 1: Detect Platform / 检测平台

Source `scripts/cross-platform/_platform-detect.sh` to identify OS and architecture.

## Step 2: Pre-scan Confirmation / 扫描前确认

Prompt the user before scanning:

**EN**: "⚠️ Auto-scan may take a while (~30s on Windows). Scanning is read-only. Options: A) Auto-scan B) Specify paths manually"
**CN**: "⚠️ 自动扫描系统可能耗时较长（Windows 约 30-60 秒）。扫描为只读操作。选项：A) 自动扫描 B) 手工指定软件路径"

User selects A → Step 3. User selects B → Step 4 (specify paths).

## Step 3: System Scan / 系统扫描

- **Windows**: `scripts/windows-only/scan/scan_all.ps1`
- **Mac/Linux**: `scripts/cross-platform/scan/scan_all.sh`

Output JSON: `{"R":{"installed":true,"path":"...","version":"..."},...}`

The scan **reveals only `installed` boolean by default**. Path/version details require `STATSOFT_REVEAL=1`.

## Step 4: Detect & Setup / 检测与配置

Route to platform-specific script:
- `scripts/windows-only/{tool}/setup_{tool}.ps1` (Windows)
- `scripts/cross-platform/{tool}/setup_{tool}.sh` (cross-platform)

## Step 5: Save Config / 保存配置

Detection-only by default. Persist `config.json` only when explicitly opted in (`STATSOFT_AUTO_WRITE=1` or `STATSOFT_CONFIRM=1` + interactive y).

The writer (`scripts/common/write_config.py`) enforces a single canonical path.

## Step 6: Output Summary / 输出完成摘要

Follow `references/completion-prompts.md`.
