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

# Setup script for OpenBUGS
# Bayesian statistical modeling using MCMC

OPENBUGS_VERSION="3.2.3"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== OpenBUGS 贝叶斯分析配置 ===" "=== OpenBUGS Setup ==="
LANG_ZH "版本: $OPENBUGS_VERSION" "Version: $OPENBUGS_VERSION"

# Detect OpenBUGS installation
OPENBUGS_BIN=""
if command -v openbugs &> /dev/null; then
    OPENBUGS_BIN=$(command -v openbugs)
elif [ -f /usr/local/bin/openbugs ]; then
    OPENBUGS_BIN=/usr/local/bin/openbugs
elif [ -f /usr/bin/openbugs ]; then
    OPENBUGS_BIN=/usr/bin/openbugs
elif [ -f "/opt/openbugs/openbugs" ]; then
    OPENBUGS_BIN="/opt/openbugs/openbugs"
fi

if [ -n "$OPENBUGS_BIN" ]; then
    LANG_ZH "找到 OpenBUGS: $OPENBUGS_BIN" "Found OpenBUGS: $OPENBUGS_BIN"
else
    LANG_ZH "未找到 OpenBUGS。" "OpenBUGS not found."
    LANG_ZH "安装选项:" "Install options:"
    echo "  Ubuntu:  apt-get install openbugs"
    echo "  macOS:   brew install openbugs"
    echo "  Windows: Download from https://openbugs.net/"
    OPENBUGS_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$OPENBUGS_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['OpenBUGS'] = {
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
" "$CONFIG_FILE" "$OPENBUGS_VERSION" "$OPENBUGS_BIN"
fi

LANG_ZH "" ""
LANG_ZH "OpenBUGS CLI 用法:" "OpenBUGS CLI Usage:"
echo "  openbugs --help            # 显示 CLI 选项"
echo "  openbugs -b script.txt    # 通过脚本批执行"
LANG_ZH "" ""
LANG_ZH "支持：贝叶斯分析、MCMC、层次模型" "Supported: Bayesian Analysis, MCMC, Hierarchical Models"
