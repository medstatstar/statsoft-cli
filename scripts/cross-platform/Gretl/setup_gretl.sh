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

# setup_gretl.sh - Gretl 统计软件环境检测与配置脚本
# Gretl: 免费跨平台计量经济学软件，纯 CLI 支持

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_platform-detect.sh"

    LANG_ZH "=== Gretl 环境检测" "Gretl Environment Detection ==="
    LANG_ZH "平台" "Platform: $WB_OS ($WB_ARCH)"
LANG_ZH "" ""

# 检测 Gretl 是否安装
detect_gretl() {
    local gretl_cmd=""
    
    if [ "$WB_OS" = "windows" ]; then
        # Windows: 检查常见安装路径
        local win_paths=(
            "C:/Program Files/gretl/gretlcli.exe"
            "C:/Program Files (x86)/gretl/gretlcli.exe"
        )
        for path in "${win_paths[@]}"; do
            if [ -f "$path" ]; then
                gretl_cmd="$path"
                break
            fi
        done
        
        # 检查 PATH
        if [ -z "$gretl_cmd" ]; then
            gretl_cmd=$(which gretlcli 2>/dev/null)
        fi
    else
        # Mac/Linux: 检查 PATH
        gretl_cmd=$(which gretlcli 2>/dev/null)
        
        # Mac: 检查应用程序目录
        if [ -z "$gretl_cmd" ] && [ "$WB_OS" = "mac" ]; then
            if [ -d "/Applications/Gretl.app" ]; then
                gretl_cmd="/Applications/Gretl.app/Contents/MacOS/gretlcli"
            fi
        fi
        
        # Linux: 检查包管理器
        if [ -z "$gretl_cmd" ] && [ "$WB_OS" = "linux" ]; then
            if command -v gretlcli &> /dev/null; then
                gretl_cmd=$(which gretlcli)
            fi
        fi
    fi
    
    if statsoft_reveal; then
        LANG_ZH "$gretl_cmd" "$gretl_cmd"
    else
        echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
    fi
statsoft_reveal() { [ "${STATSOFT_REVEAL:-0}" = "1" ]; }
}

# 主流程
main() {
    local gretl_path=$(detect_gretl)
    
    if [ -n "$gretl_path" ]; then
    LANG_ZH "✅ 检测到 Gretl 安装:" "Gretl installation detected:"
    if statsoft_reveal; then
        LANG_ZH "  路径: $gretl_path" "Path: $gretl_path"
    else
        echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
    fi
        
        # Version verification launches the detected third-party binary.
        # It runs ONLY when explicitly opted in (STATSOFT_VERIFY=1); default
        # detection reports the path only and never executes the binary (SDI-4).
        local version="unknown"
        if [ "${STATSOFT_VERIFY:-0}" = "1" ]; then
            version=$($gretl_path --version 2>&1 | head -1)
        fi
    if statsoft_reveal; then
        LANG_ZH "  版本: $version" "Version: $version"
    else
        echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
    fi
        
        # 输出配置信息（供 AI Agent 读取）
        LANG_ZH "" ""
    LANG_ZH "=== 配置信息" "Configuration Info ==="
        if statsoft_reveal; then
            LANG_ZH "GRETL_PATH=$gretl_path" "GRETL_PATH=$gretl_path"
        else
            echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
        fi
        if statsoft_reveal; then
            LANG_ZH "GRETL_VERSION=$version" "GRETL_VERSION=$version"
        else
            echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
        fi
        LANG_ZH "GRETL_OS=$WB_OS" "GRETL_OS=$WB_OS"
        LANG_ZH "GRETL_ARCH=$WB_ARCH" "GRETL_ARCH=$WB_ARCH"
        
        # 输出使用说明
        LANG_ZH "" ""
    LANG_ZH "=== 使用说明" "Usage Instructions ==="
    LANG_ZH "批处理命令" "Batch command:"
        if statsoft_reveal; then
            echo "  $gretl_cmd -b script.inp"
        else
            echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
        fi
        LANG_ZH "" ""
    LANG_ZH "脚本示例" "Script example:"
        echo "  # script.inp"
        echo "  open data4-1.gdt"
        echo "  ols y const x1 x2"
        echo "  store results.txt"
        
    else
    LANG_ZH "❌ 未检测到 Gretl 安装:" "Gretl installation not found:"
        LANG_ZH "" ""
    LANG_ZH "=== 安装指南" "Installation Guide ==="
        
        if [ "$WB_OS" = "windows" ]; then
    LANG_ZH "Windows 安装步骤" "Windows installation steps:"
            echo "  1. 访问 Gretl 官网: http://gretl.sourceforge.net/"
            echo "  2. 下载 Windows 安装包（.exe）"
            echo "  3. 运行安装程序，按默认设置安装"
            if statsoft_reveal; then
                echo "  4. 安装完成后，gretlcli.exe 通常在 C:\\Program Files\\gretl\\"
            else
                echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
            fi
        elif [ "$WB_OS" = "mac" ]; then
    LANG_ZH "macOS 安装步骤" "macOS installation steps:"
            echo "  1. 使用 Homebrew: brew install gretl"
            echo "  2. 或下载 .dmg 安装包: http://gretl.sourceforge.net/"
            if statsoft_reveal; then
                echo "  3. 安装完成后，命令行工具在 /Applications/Gretl.app/Contents/MacOS/gretlcli"
            else
                echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
            fi
        else
    LANG_ZH "Linux 安装步骤" "Linux installation steps:"
            echo "  Ubuntu/Debian: sudo apt-get install gretl"
            echo "  Fedora/RHEL: sudo dnf install gretl"
            echo "  Arch Linux: sudo pacman -S gretl"
        fi
        
        LANG_ZH "" ""
    LANG_ZH "=== Linux/macOS 特殊说明" "Linux/macOS Special Notes ==="
        echo "  - Linux: 确保安装 gretl-cli 包（命令行工具）"
        echo "  - macOS: 如果 Homebrew 安装失败，从官网下载 .dmg"
        if statsoft_reveal; then
            echo "  - 所有平台：安装后运行 'gretlcli --version' 验证"
        else
            echo "$(LANG_ZH "检测到软件（路径/版本已隐藏；设置 STATSOFT_REVEAL=1 可显示）" "Software detected (paths/versions hidden; set STATSOFT_REVEAL=1 to reveal).")"
        fi
    fi
}

main "$@"
