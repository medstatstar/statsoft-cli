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

# Setup script for Rattle (R data mining GUI / CLI)
# Data mining with R, GUI + CLI

RATTLE_VERSION="5.5"
CONFIG_FILE="$(dirname "$0")/../../config.json"

LANG_ZH "=== Rattle 数据挖掘工具配置 ===" "=== Rattle Setup ==="
LANG_ZH "版本: $RATTLE_VERSION" "Version: $RATTLE_VERSION"

# Detect Rattle installation
RATTLE_BIN=""
if command -v rattle &> /dev/null; then
    RATTLE_BIN=$(command -v rattle)
elif [ -f /usr/local/bin/rattle ]; then
    RATTLE_BIN=/usr/local/bin/rattle
elif [ -f /usr/bin/rattle ]; then
    RATTLE_BIN=/usr/bin/rattle
fi

# Check R Rattle package
RATTLE_R=""
if Rscript -e "library(rattle)" 2>/dev/null; then
    RATTLE_R=$(Rscript -e "cat(system.file(package='rattle'))")
    LANG_ZH "Rattle R 包: $RATTLE_R" "Rattle R package: $RATTLE_R"
fi

if [ -n "$RATTLE_BIN" ] || [ -n "$RATTLE_R" ]; then
    LANG_ZH "找到 Rattle。" "Found Rattle."
else
    LANG_ZH "未找到 Rattle。" "Rattle not found."
    LANG_ZH "安装选项:" "Install options:"
    echo "  R: install.packages('rattle')"
    echo "  Download from https://rattle.togaware.com/"
    RATTLE_BIN="NOT_INSTALLED"
fi

# Update config.json
if [ -f "$CONFIG_FILE" ] && [ "$RATTLE_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "正在更新配置..." "Updating config.json..."
    python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['Rattle'] = {
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
" "$CONFIG_FILE" "$RATTLE_VERSION" "$RATTLE_BIN"
fi

LANG_ZH "" ""
LANG_ZH "Rattle CLI 用法:" "Rattle CLI Usage:"
echo "  rattle --cli               # CLI 模式运行 Rattle"
echo "  rattle --script file.R    # 执行脚本"
LANG_ZH "" ""
LANG_ZH "支持：数据挖掘、决策树、聚类、关联规则、文本挖掘" "Supported: Data Mining, Decision Trees, Clustering, Association Rules, Text Mining"
