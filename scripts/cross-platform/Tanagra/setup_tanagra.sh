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

# Setup script for Tanagra Data Mining
# Open source data mining and machine learning

TANAGRA_VERSION="1.8"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== Tanagra 数据挖掘工具配置 ===" "=== Tanagra Setup ==="
LANG_ZH "版本: $TANAGRA_VERSION" "Version: $TANAGRA_VERSION"

# Detect Tanagra installation
TANAGRA_BIN=""
if command -v tanagra &> /dev/null; then
    TANAGRA_BIN=$(command -v tanagra)
elif [ -f /usr/local/bin/tanagra ]; then
    TANAGRA_BIN=/usr/local/bin/tanagra
elif [ -f /usr/bin/tanagra ]; then
    TANAGRA_BIN=/usr/bin/tanagra
elif [ -f "/opt/tanagra/tanagra" ]; then
    TANAGRA_BIN="/opt/tanagra/tanagra"
fi

if [ -n "$TANAGRA_BIN" ]; then
    LANG_ZH "找到 Tanagra: $TANAGRA_BIN" "Found Tanagra: $TANAGRA_BIN"
else
    LANG_ZH "未找到 Tanagra。" "Tanagra not found."
    LANG_ZH "安装：从 http://data.mines-paristech.fr/tanagra/ 下载" "Install: Download from http://data.mines-paristech.fr/tanagra/"
    TANAGRA_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$TANAGRA_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['Tanagra'] = {
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
" "$CONFIG_FILE" "$TANAGRA_VERSION" "$TANAGRA_BIN"
fi

LANG_ZH "" ""
LANG_ZH "Tanagra CLI 用法:" "Tanagra CLI Usage:"
echo "  tanagra --help            # 显示 CLI 选项"
echo "  tanagra -f script.txt    # 执行批脚本"
LANG_ZH "" ""
LANG_ZH "支持：聚类、分类、关联规则、特征选择" "Supported: Clustering, Classification, Association Rules, Feature Selection"
