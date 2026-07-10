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

# setup_weka.sh — Detect and configure Weka (cross-platform)
set -euo pipefail

CONFIG_PATH="$(dirname "$0")/../../config.json"

WEKA_DIR=""
if command -v weka &>/dev/null; then
    WEKA_DIR="$(dirname "$(which weka)")"
elif [ -n "${WEKA_HOME:-}" ] && [ -d "$WEKA_HOME" ]; then
    WEKA_DIR="$WEKA_HOME"
elif [ -d "/usr/share/weka" ]; then
    WEKA_DIR="/usr/share/weka"
elif [ -d "/usr/local/share/weka" ]; then
    WEKA_DIR="/usr/local/share/weka"
elif [ -d "$HOME/weka" ]; then
    WEKA_DIR="$HOME/weka"
elif [ -d "$HOME/.local/share/weka" ]; then
    WEKA_DIR="$HOME/.local/share/weka"
fi

if [ -z "$WEKA_DIR" ]; then
    LANG_ZH "错误: 未找到 Weka。" "ERROR: Weka not found."
    echo "  Install from https://www.cs.waikato.ac.nz/ml/weka/downloading.html"
    echo "  Or set WEKA_HOME env var"
    exit 1
fi

# Detect WEKA version
VERSION=""
if [ -f "$WEKA_DIR/weka.jar" ]; then
    # Try to extract version from manifest
    VERSION=$(unzip -p "$WEKA_DIR/weka.jar" META-INF/MANIFEST.MF 2>/dev/null | grep -i "Implementation-Version" | head -1 | awk '{print $2}' | tr -d '\r\n')
    [ -z "$VERSION" ] && VERSION="installed"
fi

LANG_ZH "Weka: $WEKA_DIR" "Weka: $WEKA_DIR"
LANG_ZH "版本: ${VERSION:-unknown}" "Version: ${VERSION:-unknown}"

# Write to config
if command -v python3 &>/dev/null; then
    python3 - <<EOF 2>/dev/null || LANG_ZH "警告: 无法更新 config.json" "WARN: Could not update config.json"
import json, os
cfg_path = "$CONFIG_PATH"
cfg = {}
if os.path.exists(cfg_path):
    with open(cfg_path, 'r') as f:
        cfg = json.load(f)
cfg["Weka"] = {
    "installed": True,
    "path": "$WEKA_DIR",
    "version": "${VERSION:-unknown}",
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
