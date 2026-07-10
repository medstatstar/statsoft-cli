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
print('config.json updated.')
" "$CONFIG_FILE" "$TANAGRA_VERSION" "$TANAGRA_BIN"
fi

LANG_ZH "" ""
LANG_ZH "Tanagra CLI 用法:" "Tanagra CLI Usage:"
echo "  tanagra --help            # 显示 CLI 选项"
echo "  tanagra -f script.txt    # 执行批脚本"
LANG_ZH "" ""
LANG_ZH "支持：聚类、分类、关联规则、特征选择" "Supported: Clustering, Classification, Association Rules, Feature Selection"
