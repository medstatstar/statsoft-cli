#!/bin/bash

# ============================================================
# Language Detection
# ============================================================
if [[ "${LANG:-}" == zh_* ]] || [[ "${LC_ALL:-}" == zh_* ]] || [[ "${LANGUAGE:-}" == zh_* ]]; then
    SCRIPT_LANG="zh"
else
    SCRIPT_LANG="en"
fi

LANG_ZH() { [[ "$SCRIPT_LANG" == "zh" ]] && echo "$1" || echo "$2"; }

# Setup script for Orange Data Mining
# Data mining, visualization, and machine learning

ORANGE_VERSION="3.36"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== Orange 数据挖掘平台配置 ===" "=== Orange Setup ==="
LANG_ZH "版本: $ORANGE_VERSION" "Version: $ORANGE_VERSION"

# Detect Orange installation
ORANGE_BIN=""
if command -v orange-canvas &> /dev/null; then
    ORANGE_BIN=$(command -v orange-canvas)
elif [ -f /usr/local/bin/orange-canvas ]; then
    ORANGE_BIN=/usr/local/bin/orange-canvas
elif [ -f /usr/bin/orange-canvas ]; then
    ORANGE_BIN=/usr/bin/orange-canvas
elif [ -f "/opt/orange/orange-canvas" ]; then
    ORANGE_BIN="/opt/orange/orange-canvas"
elif [ -f "/Applications/Orange.app/Contents/MacOS/Orange" ]; then
    ORANGE_BIN="/Applications/Orange.app/Contents/MacOS/Orange"
fi

# Check Python Orange3 module
ORANGE_PY=""
if python3 -c "import Orange" 2>/dev/null; then
    ORANGE_PY=$(python3 -c "import Orange; print(Orange.__path__[0])")
    LANG_ZH "Orange3 Python 模块: $ORANGE_PY" "Orange3 Python module: $ORANGE_PY"
fi

if [ -n "$ORANGE_BIN" ] || [ -n "$ORANGE_PY" ]; then
    LANG_ZH "找到 Orange。" "Found Orange."
else
    LANG_ZH "未找到 Orange。" "Orange not found."
    LANG_ZH "安装选项:" "Install options:"
    echo "  pip install orange3"
    echo "  conda install -c conda-forge orange3"
    ORANGE_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$ORANGE_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['Orange'] = {
    'version': sys.argv[2],
    'path': sys.argv[3],
    'platform': 'all',
    'mode': 'simple'
}
# ── Backup & Confirm (mirrors windows-only *.ps1) ──
import os, shutil, datetime, sys, json
_T = sys.argv[1]
_D = config
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
print('config.json updated.')
" "$CONFIG_FILE" "$ORANGE_VERSION" "$ORANGE_BIN"
fi

LANG_ZH "" ""
LANG_ZH "Orange CLI 用法:" "Orange CLI Usage:"
echo "  orange-canvas --help       # 显示 CLI 选项"
echo "  python3 -m Orange ...      # 直接使用 Orange Python 模块"
LANG_ZH "" ""
LANG_ZH "支持：数据挖掘、可视化、机器学习、文本挖掘" "Supported: Data Mining, Visualization, Machine Learning, Text Mining"
