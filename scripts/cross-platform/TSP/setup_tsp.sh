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

# Setup script for TSP (Time Series Processor)
# Econometric analysis and forecasting

TSP_VERSION="5.0"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== TSP 时间序列分析配置 ===" "=== TSP Setup ==="
LANG_ZH "版本: $TSP_VERSION" "Version: $TSP_VERSION"

# Detect TSP installation
TSP_BIN=""
if command -v tsp &> /dev/null; then
    TSP_BIN=$(command -v tsp)
elif [ -f /usr/local/bin/tsp ]; then
    TSP_BIN=/usr/local/bin/tsp
elif [ -f /usr/bin/tsp ]; then
    TSP_BIN=/usr/bin/tsp
elif [ -f "/opt/tsp/tsp" ]; then
    TSP_BIN="/opt/tsp/tsp"
fi

if [ -n "$TSP_BIN" ]; then
    LANG_ZH "找到 TSP: $TSP_BIN" "Found TSP: $TSP_BIN"
else
    LANG_ZH "未找到 TSP。" "TSP not found."
    LANG_ZH "安装：从 https://www.tsp.com/ 下载" "Install: Download from https://www.tsp.com/"
    TSP_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$TSP_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['TSP'] = {
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
" "$CONFIG_FILE" "$TSP_VERSION" "$TSP_BIN"
fi

LANG_ZH "" ""
LANG_ZH "TSP CLI 用法:" "TSP CLI Usage:"
echo "  tsp commands.txt          # 执行 TSP 命令文件"
echo "  tsp --help               # 显示 CLI 选项"
LANG_ZH "" ""
LANG_ZH "支持：时间序列、计量经济学、假设检验" "Supported: Time Series, Econometrics, Hypothesis Testing"
