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

# Setup script for SHAZAM Econometrics Software
# Comprehensive econometrics, statistics and analytics

SHAZAM_VERSION="12.0"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== SHAZAM 计量经济学配置 ===" "=== SHAZAM Setup ==="
LANG_ZH "版本: $SHAZAM_VERSION" "Version: $SHAZAM_VERSION"

# Detect SHAZAM installation
SHAZAM_BIN=""
if command -v shazam &> /dev/null; then
    SHAZAM_BIN=$(command -v shazam)
elif [ -f /usr/local/bin/shazam ]; then
    SHAZAM_BIN=/usr/local/bin/shazam
elif [ -f /usr/bin/shazam ]; then
    SHAZAM_BIN=/usr/bin/shazam
elif [ -f "/opt/shazam/shazam" ]; then
    SHAZAM_BIN="/opt/shazam/shazam"
fi

if [ -n "$SHAZAM_BIN" ]; then
    LANG_ZH "找到 SHAZAM: $SHAZAM_BIN" "Found SHAZAM: $SHAZAM_BIN"
    SHAZAM_VER=$($SHAZAM_BIN --version 2>&1 | head -1 || echo "unknown")
    LANG_ZH "版本: $SHAZAM_VER" "Version: $SHAZAM_VER"
else
    LANG_ZH "未找到 SHAZAM。" "SHAZAM not found."
    LANG_ZH "安装：从 https://www.econometrics.com/ 下载" "Install: Download from https://www.econometrics.com/"
    SHAZAM_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$SHAZAM_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['SHAZAM'] = {
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
" "$CONFIG_FILE" "$SHAZAM_VERSION" "$SHAZAM_BIN"
fi

LANG_ZH "" ""
LANG_ZH "SHAZAM CLI 用法:" "SHAZAM CLI Usage:"
echo "  shazam < commands.txt       # Run SHAZAM command file"
LANG_ZH "" ""
LANG_ZH "支持：计量经济学、时间序列、假设检验、回归" "Supported: Econometrics, Time Series, Hypothesis Testing, Regression"
