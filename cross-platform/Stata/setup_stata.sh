#!/bin/bash
# setup_stata.sh - Cross-platform Stata edition detection and setup
# Compatible with Windows (Git Bash), macOS, Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/_platform-detect.sh"

STATA_CMD=""
STATA_EDITION=""
STATA_VERSION=""

log_info() { echo "[INFO] $1"; }
log_error() { echo "[ERROR] $1" >&2; }
log_success() { echo "[OK] $1"; }
log_warn() { echo "[WARN] $1"; }

detect_stata() {
    # 注意：Stata 14/15 使用 StataMP、StataSE、StataBE（无-64后缀）
    # Stata 16+ 使用 StataMP-64、StataSE-64、StataBE-64（有-64后缀）
    local edisions=("StataMP-64" "StataSE-64" "StataBE-64" "StataMP" "StataSE" "StataBE" "stata-mp" "stata-se" "stata")
    local search_paths=()

    case "$WB_OS" in
        windows)
            search_paths=(
                "C:/Program Files/Stata19"
                "C:/Program Files/Stata18"
                "C:/Program Files/Stata17"
                "C:/Program Files/Stata16"
                "C:/Program Files/Stata15"
                "C:/Program Files/Stata14"
                "D:/Stata19"
                "D:/Stata18"
                "D:/Stata17"
                "D:/Stata16"
                "D:/Stata15"
                "D:/Stata14"
            )
            ;;
        mac)
            search_paths=(
                "/Applications/Stata"
            )
            ;;
        linux)
            search_paths=(
                "/usr/local/stata19"
                "/usr/local/stata18"
                "/usr/local/stata17"
                "/usr/local/stata16"
                "/usr/local/stata15"
                "/usr/local/stata14"
                "/opt/stata19"
                "/opt/stata18"
                "/opt/stata17"
                "/opt/stata16"
                "/opt/stata15"
                "/opt/stata14"
            )
            ;;
    esac

    for dir in "${search_paths[@]}"; do
        for exe_name in "${edisions[@]}"; do
            if [[ -x "$dir/$exe_name" ]] || [[ -x "$dir/$exe_name.exe" ]]; then
                STATA_CMD="$dir/$exe_name"
                [[ -x "$dir/$exe_name.exe" ]] && STATA_CMD="$dir/$exe_name.exe"
                if [[ "$exe_name" == *"MP"* ]] || [[ "$exe_name" == *"mp"* ]]; then
                    STATA_EDITION="MP"
                elif [[ "$exe_name" == *"SE"* ]] || [[ "$exe_name" == *"se"* ]]; then
                    STATA_EDITION="SE"
                else
                    STATA_EDITION="BE"
                fi
                STATA_VERSION="${dir##*Stata}"
                STATA_VERSION="${stata_version%%/*}"
                log_success "Detected Stata $STATA_VERSION ($STATA_EDITION): $STATA_CMD"
                return 0
            fi
        done
    done

    return 1
}

verify_stata() {
    if [[ -z "$STATA_CMD" ]]; then
        return 1
    fi

    # Test Stata with a simple command
    cd /tmp
    echo "display 1" > test_stata.do
    "$STATA_CMD" /b do test_stata.do &>/dev/null 2>&1
    local exit_code=$?

    return $exit_code
}

save_config() {
    local config_file="${1:-$ROOT_DIR/../config.json}"

    cat > "$config_file" << EOF
{
  "Stata": {
    "installed": true,
    "path": "$STATA_CMD",
    "$STATA_EDITION": "$STATA_VERSION",
    "platform": "$WB_OS",
    "mode": "simple"
  }
}
EOF

    if [[ $? -eq 0 ]]; then
        log_success "Created config: $config_file"
    fi
}

main() {
    echo "=== Stata Setup (Cross-Platform) ==="
    echo "Platform: $WB_OS ($WB_ARCH)"
    echo ""

    if detect_stata; then
        log_info "Stata edition: $STATA_EDITION"
        echo ""
        read -p "Correct? (Y/n, or type MP/SE/BE to change): " confirm
        if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
            detect_stata
        elif [[ -n "$confirm" ]]; then
            STATA_EDITION="$confirm"
            STATA_CMD="${STATA_CMD/MP/$STATA_EDITION}"
            STATA_CMD="${STATA_CMD/SE/$STATA_EDITION}"
            STATA_CMD="${STATA_CMD/BE/$STATA_EDITION}"
        fi
        save_config
        return 0
    fi

    log_error "Stata not detected."
    echo ""
    echo "Please confirm:"
    echo "  1. Stata installed?"
    echo "  2. Version (16/17/18)?"
    echo "  3. Edition (MP/SE/BE)?"
    echo ""
    echo "Edition Guide / 版本类型说明:"
    echo "  MP = 多核并行版 (Multi-Processor)"
    echo "      · 大数据首选，支持 10-20B 变量"
    echo "      · 充分利用多核 CPU 加速"
    echo "      · 适用于大规模数据分析"
    echo ""
    echo "  SE = 标准版 (Standard Edition)"
    echo "      · 最多 32,767 变量"
    echo "      · 适用于中等规模数据"
    echo "      · 单核执行"
    echo ""
    echo "  BE = 基础版 (Basic Edition)"
    echo "      · 最多 2,048 变量"
    echo "      · 适用于教学和小型项目"
    echo "      · 单核执行"

    local manual_path
    read -p "Enter Stata path (e.g., /usr/local/stata18): " manual_path
    if [[ -n "$manual_path" ]] && [[ -d "$manual_path" ]]; then
        STATA_CMD="$manual_path"
        save_config
        verify_stata
        return $?
    fi

    return 1
}

main "$@"
