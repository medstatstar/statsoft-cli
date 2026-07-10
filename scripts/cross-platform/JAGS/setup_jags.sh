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

# Setup script for JAGS (Just Another Gibbs Sampler)
# Bayesian hierarchical models via MCMC

JAGS_VERSION="4.3.0"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== JAGS 贝叶斯抽样器配置 ===" "=== JAGS Setup ==="
LANG_ZH "版本: $JAGS_VERSION" "Version: $JAGS_VERSION"

# Detect JAGS installation
JAGS_BIN=""
if command -v jags &> /dev/null; then
    JAGS_BIN=$(command -v jags)
elif [ -f /usr/local/bin/jags ]; then
    JAGS_BIN=/usr/local/bin/jags
elif [ -f /usr/bin/jags ]; then
    JAGS_BIN=/usr/bin/jags
fi

if [ -n "$JAGS_BIN" ]; then
    LANG_ZH "找到 JAGS: $JAGS_BIN" "Found JAGS: $JAGS_BIN"
    JAGS_VER=$($JAGS_BIN --version 2>&1 | head -1 || echo "unknown")
    LANG_ZH "版本: $JAGS_VER" "Version: $JAGS_VER"
else
    LANG_ZH "未找到 JAGS。" "JAGS not found."
    LANG_ZH "安装选项:" "Install options:"
    echo "  macOS:   brew install jags"
    echo "  Ubuntu:  apt-get install jags"
    echo "  Windows: Download from https://sourceforge.net/projects/mcmc-jags/"
    JAGS_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$JAGS_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    # Use Python to update JSON (more reliable than jq)
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['JAGS'] = {
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
print('config.json 已更新。')
" "$CONFIG_FILE" "$JAGS_VERSION" "$JAGS_BIN"
fi

LANG_ZH "" ""
LANG_ZH "JAGS CLI 用法:" "JAGS CLI Usage:"
echo "  jags scriptfile          # Run JAGS script"
echo "  jags-script script.txt   # Batch execution"
LANG_ZH "" ""
LANG_ZH "支持：贝叶斯层次模型、MCMC 模拟" "Supported: Bayesian hierarchical models, MCMC simulation"
