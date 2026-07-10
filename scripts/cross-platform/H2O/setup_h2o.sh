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

# Setup script for H2O.ai
# Open source machine learning platform and AutoML

H2O_VERSION="3.44"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== H2O.ai 机器学习平台配置 ===" "=== H2O.ai Setup ==="
LANG_ZH "版本: $H2O_VERSION" "Version: $H2O_VERSION"

# Detect H2O installation
H2O_BIN=""
if command -v h2o &> /dev/null; then
    H2O_BIN=$(command -v h2o)
elif [ -f /usr/local/bin/h2o ]; then
    H2O_BIN=/usr/local/bin/h2o
elif [ -f /usr/bin/h2o ]; then
    H2O_BIN=/usr/bin/h2o
elif [ -f "$HOME/h2o/h2o.jar" ]; then
    H2O_BIN="$HOME/h2o/h2o.jar"
fi

# Check Python H2O module
H2O_PY=""
if python3 -c "import h2o" 2>/dev/null; then
    H2O_PY=$(python3 -c "import h2o; print(h2o.__path__[0])")
    LANG_ZH "H2O Python 模块: $H2O_PY" "H2O Python module: $H2O_PY"
fi

if [ -n "$H2O_BIN" ] || [ -n "$H2O_PY" ]; then
    LANG_ZH "找到 H2O.ai。" "Found H2O.ai."
else
    LANG_ZH "未找到 H2O。" "H2O not found."
    LANG_ZH "安装选项:" "Install options:"
    echo "  pip install h2o"
    echo "  Download jar from https://h2o.ai/download/"
    H2O_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$H2O_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['H2O'] = {
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
" "$CONFIG_FILE" "$H2O_VERSION" "$H2O_BIN"
fi

LANG_ZH "" ""
LANG_ZH "H2O CLI 用法:" "H2O CLI Usage:"
echo "  h2o --help                # Show CLI options"
echo "  h2o start                 # Start H2O server"
echo "  python3 -c 'import h2o; h2o.init()'  # Initialize via Python"
LANG_ZH "" ""
LANG_ZH "支持：分布式机器学习、AutoML、深度学习、NLP、时间序列" "Supported: Distributed ML, AutoML, Deep Learning, NLP, Time Series"
