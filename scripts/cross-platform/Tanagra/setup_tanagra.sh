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

# Config persistence (fail-closed: detection-only by default; persists only on explicit opt-in)
if [ -f "$CONFIG_FILE" ] && [ "$TANAGRA_BIN" != "NOT_INSTALLED" ]; then
    LANG_ZH "默认仅检测；写入需 opt-in（STATSOFT_AUTO_WRITE=1）" "Detection-only by default; write requires opt-in (STATSOFT_AUTO_WRITE=1)"
    _NEW_CFG=$(python3 -c "
import json, sys
with open(sys.argv[1], 'r') as f:
    config = json.load(f)
config['Tanagra'] = {
    'version': sys.argv[2],
    'path': sys.argv[3],
    'platform': 'all',
    'mode': 'simple'
}
print(json.dumps(config, ensure_ascii=False))" "$CONFIG_FILE" "$TANAGRA_VERSION" "$TANAGRA_BIN")
    # Fail-closed by default — persist ONLY when explicitly opted in.
    if [ "${STATSOFT_AUTO_WRITE:-0}" = "1" ]; then
        STATSOFT_AUTO_WRITE=1 python3 "$(dirname "$0")/../../common/write_config.py" "$CONFIG_FILE" <<< "$_NEW_CFG"
    elif [ "${STATSOFT_CONFIRM:-0}" = "1" ] && [ -t 0 ]; then
        printf 'Persist detected config to config.json? (y/N) '
        read -r _ans
        case "$_ans" in y|Y|yes) STATSOFT_AUTO_WRITE=1 python3 "$(dirname "$0")/../../common/write_config.py" "$CONFIG_FILE" <<< "$_NEW_CFG" ;; *) echo "Detection-only: config.json NOT modified." ;; esac
    else
        echo "Detection-only: config.json NOT modified. Set STATSOFT_AUTO_WRITE=1 to persist, or STATSOFT_CONFIRM=1 for an interactive prompt."
    fi
fi

LANG_ZH "" ""
LANG_ZH "Tanagra CLI 用法:" "Tanagra CLI Usage:"
echo "  tanagra --help            # 显示 CLI 选项"
echo "  tanagra -f script.txt    # 执行批脚本"
LANG_ZH "" ""
LANG_ZH "支持：聚类、分类、关联规则、特征选择" "Supported: Clustering, Classification, Association Rules, Feature Selection"
