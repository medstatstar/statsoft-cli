#!/usr/bin/env bash

# ============================================================
# Language Detection
# ============================================================
if [[ "${LANG:-}" == zh_* ]] || [[ "${LC_ALL:-}" == zh_* ]] || [[ "${LANGUAGE:-}" == zh_* ]]; then
    SCRIPT_LANG="zh"
else
    SCRIPT_LANG="en"
fi

LANG_ZH() { [[ "$SCRIPT_LANG" == "zh" ]] && echo "$1" || echo "$2"; }

# setup_knime.sh — Detect and configure KNIME (cross-platform)
set -euo pipefail

CONFIG_PATH="$(dirname "$0")/../../config.json"

KNIME_BIN=""
if command -v knime &>/dev/null; then
    KNIME_BIN="$(which knime)"
elif [ -n "${KNIME_HOME:-}" ] && [ -d "$KNIME_HOME" ]; then
    KNIME_BIN="$KNIME_HOME/knime"
elif [ -f "/Applications/KNIME 5.1.app/Contents/MacOS/knime" ]; then
    KNIME_BIN="/Applications/KNIME 5.1.app/Contents/MacOS/knime"
elif [ -d "/opt/knime" ]; then
    KNIME_BIN="/opt/knime/knime"
elif [ -d "$HOME/knime" ]; then
    KNIME_BIN="$HOME/knime/knime"
fi

if [ -z "$KNIME_BIN" ] || [ ! -f "$KNIME_BIN" ]; then
    LANG_ZH "错误: 未找到 KNIME。" "ERROR: KNIME not found."
    echo "  Download from https://www.knime.com/downloads"
    echo "  Or set KNIME_HOME env var"
    exit 1
fi

KNIME_DIR="$(dirname "$KNIME_BIN")"

LANG_ZH "KNIME: $KNIME_BIN" "KNIME: $KNIME_BIN"
LANG_ZH "Dir: $KNIME_DIR" "Dir: $KNIME_DIR"

if command -v python3 &>/dev/null; then
    python3 - <<EOF 2>/dev/null || LANG_ZH "警告: 无法更新 config.json" "WARN: Could not update config.json"
import json, os
cfg_path = "$CONFIG_PATH"
cfg = {}
if os.path.exists(cfg_path):
    with open(cfg_path, 'r') as f:
        cfg = json.load(f)
cfg["KNIME"] = {
    "installed": True,
    "path": "$KNIME_DIR",
    "binary": "$KNIME_BIN",
    "version": "unknown",
    "platform": "all"
}
# ── Backup & Confirm (mirrors windows-only *.ps1) ──
import os, shutil, datetime, sys, json
_T = cfg_path
_D = cfg
if os.path.exists(_T):
    _bak = _T + '.bak.' + datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    shutil.copy2(_T, _bak)
    print('Config backed up to: ' + _bak)
_tmp = _T + '.tmp.' + str(os.getpid())
with open(_tmp, 'w', encoding='utf-8') as f:
    json.dump(_D, f, indent=2, ensure_ascii=False)
# Confirmation gate: opt-in via STATSOFT_CONFIRM=1 (never blocks the agent).
# Default (agent/CI) = write with backup taken; strict mode requires explicit 'y'.
_confirm = os.environ.get('STATSOFT_CONFIRM') == '1'
if _confirm and sys.stdin.isatty():
    try:
        sys.stdout.write('Confirm write config.json? (y/N) ')
        sys.stdout.flush()
        _ans = sys.stdin.readline().strip().lower()
        _go = _ans in ('y', 'yes')
    except Exception:
        _go = False
else:
    _go = True
if not _go:
    print('Skipped config write (not confirmed).')
    try:
        os.remove(_tmp)
    except Exception:
        pass
else:
    os.replace(_tmp, _T)
    print('Config written to: ' + _T)
print("Config updated.")
EOF
fi

LANG_ZH "完成." "Done."
