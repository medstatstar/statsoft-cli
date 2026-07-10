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
# ── Backup & Confirm (fail-closed: detection-only by default) ──
# Persistence requires explicit opt-in:
#   * non-interactive/agent : STATSOFT_AUTO_WRITE=1            -> persist
#   * interactive           : STATSOFT_CONFIRM=1 + 'y' at prompt -> persist
# Otherwise this script only reports the detected path and does NOT modify config.json.
import shutil, datetime, sys, json
_T = cfg_path
_D = cfg
_auto_write = os.environ.get('STATSOFT_AUTO_WRITE') == '1'
_confirm_env = os.environ.get('STATSOFT_CONFIRM') == '1'
_go = False
if _auto_write:
    _go = True
elif _confirm_env and sys.stdin.isatty():
    try:
        sys.stdout.write('Persist detected config to config.json? (y/N) ')
        sys.stdout.flush()
        _ans = sys.stdin.readline().strip().lower()
        _go = _ans in ('y', 'yes')
    except Exception:
        _go = False
if not _go:
    print('Detection-only: config.json NOT modified. Set STATSOFT_AUTO_WRITE=1 to persist, or STATSOFT_CONFIRM=1 for an interactive prompt.')
else:
    if os.path.exists(_T):
        _bak = _T + '.bak.' + datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        shutil.copy2(_T, _bak)
        print('Config backed up to: ' + _bak)
    _tmp = _T + '.tmp.' + str(os.getpid())
    with open(_tmp, 'w', encoding='utf-8') as f:
        json.dump(_D, f, indent=2, ensure_ascii=False)
    os.replace(_tmp, _T)
    print('Config written to: ' + _T)
EOF
fi

LANG_ZH "完成." "Done."
