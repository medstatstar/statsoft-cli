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

# Setup script for GenStat
# Statistical analysis, data mining, and experimental design

GENSTAT_VERSION="23.0"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== GenStat 统计软件配置 ===" "=== GenStat Setup ==="
LANG_ZH "版本: $GENSTAT_VERSION" "Version: $GENSTAT_VERSION"

# Detect GenStat installation
GENSTAT_BIN=""
if command -v genstat &> /dev/null; then
    GENSTAT_BIN=$(command -v genstat)
elif [ -f /usr/local/bin/genstat ]; then
    GENSTAT_BIN=/usr/local/bin/genstat
elif [ -f /usr/bin/genstat ]; then
    GENSTAT_BIN=/usr/bin/genstat
elif [ -f "/opt/genstat/genstat" ]; then
    GENSTAT_BIN="/opt/genstat/genstat"
fi

if [ -n "$GENSTAT_BIN" ]; then
    LANG_ZH "找到 GenStat: $GENSTAT_BIN" "Found GenStat: $GENSTAT_BIN"
else
    LANG_ZH "未找到 GenStat。" "GenStat not found."
    LANG_ZH "安装：从 https://vsni.co.uk/genstat 下载" "Install: Download from https://vsni.co.uk/genstat"
    GENSTAT_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$GENSTAT_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['GenStat'] = {
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
print('config.json 已更新。')
" "$CONFIG_FILE" "$GENSTAT_VERSION" "$GENSTAT_BIN"
fi

LANG_ZH "" ""
LANG_ZH "GenStat CLI 用法:" "GenStat CLI Usage:"
echo "  genstat commands.txt      # Run GenStat command file"
echo "  genstat --help            # Show CLI options"
LANG_ZH "" ""
LANG_ZH "支持：混合模型、实验设计、RELD、空间分析、Meta 分析" "Supported: Mixed Models, Experimental Design, REML, Spatial Analysis, Meta-Analysis"
