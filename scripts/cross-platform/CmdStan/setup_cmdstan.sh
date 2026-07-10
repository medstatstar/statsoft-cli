#!/usr/bin/env bash

# ============================================================
# Language Detection
# ============================================================
if [[ "${LANG:-}" == zh_* ]] || [[ "${LC_ALL:-}" == zh_* ]] || [[ "${LANGUAGE:-}" == zh_* ]]; then
    SCRIPT_LANG="zh"
else
    SCRIPT_LANG="en"
fi

LANG_ZH() { [[ "$SCRIPT_LANG" == "zh" ]] && echo "$1" || echo "$2"; }

# setup_cmdstan.sh — Detect and configure CmdStan (cross-platform)
set -euo pipefail

CONFIG_PATH="$(dirname "$0")/../../config.json"

# Try to find CmdStan
CMDSTAN_PATH=""
if [ -n "${CMDSTAN:-}" ] && [ -d "$CMDSTAN" ]; then
    CMDSTAN_PATH="$CMDSTAN"
elif [ -d "$HOME/.cmdstan" ]; then
    CMDSTAN_PATH="$HOME/.cmdstan"
elif [ -d "$HOME/.cmdstanpy/cmdstan" ]; then
    CMDSTAN_PATH="$HOME/.cmdstanpy/cmdstan"
elif [ -d "/opt/cmdstan" ]; then
    CMDSTAN_PATH="/opt/cmdstan"
fi

if [ -z "$CMDSTAN_PATH" ]; then
    LANG_ZH "错误: 未找到 CmdStan。请设置 CMDSTAN 环境变量或通过 cmdstanpy 安装，或" "ERROR: CmdStan not found. Set CMDSTAN env var, install via cmdstanpy, or"
    echo "  推荐固定版本安装（请先核对版本号与脚本内容）："
    echo "  bash -c 'curl -sSL https://raw.githubusercontent.com/stan-dev/cmdstan/v2.37.0/install_cmdstan.sh -o install_cmdstan.sh && cat install_cmdstan.sh && bash install_cmdstan.sh'"
    echo "  ⚠️ 该命令会联网下载并直接执行脚本，请确认来源可信、已审阅内容后再运行；如需其他版本请替换 v2.37.0 为对应发布标签。"
    exit 1
fi

# Get version
VERSION=""
MAKEFILE="$CMDSTAN_PATH/make/local"
if [ -f "$MAKEFILE" ] && grep -q "STAN_THREADS" "$MAKEFILE" 2>/dev/null; then
    VERSION="2.30+"
fi
if [ -f "$CMDSTAN_PATH/VERSION" ]; then
    VERSION=$(cat "$CMDSTAN_PATH/VERSION")
fi


LANG_ZH "CmdStan: $CMDSTAN_PATH" "CmdStan: $CMDSTAN_PATH"
LANG_ZH "版本: ${VERSION:-unknown}" "Version: ${VERSION:-unknown}"

# Write to config if possible
if command -v python3 &>/dev/null; then
    _NEW_CFG=$(python3 - <<EOF
import json, os, sys
cfg_path = "$CONFIG_PATH"
cfg = {}
if os.path.exists(cfg_path):
    with open(cfg_path, 'r') as f:
        cfg = json.load(f)
cfg["CmdStan"] = {
    "installed": True,
    "path": "$CMDSTAN_PATH",
    "version": "${VERSION:-unknown}",
    "mode": "simple"
}
print(json.dumps(cfg, ensure_ascii=False))
EOF
)
    python3 "$(dirname "$0")/../../common/write_config.py" "$CONFIG_PATH" <<< "$_NEW_CFG"
fi

LANG_ZH "完成." "Done."
