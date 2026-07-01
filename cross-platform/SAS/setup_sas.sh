#!/bin/bash
# setup_sas.sh - Cross-platform SAS detection and setup
# Compatible with Windows (Git Bash), macOS, Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/_platform-detect.sh"

SAS_CMD=""
SAS_VERSION=""

log_info() { echo "[INFO] $1"; }
log_error() { echo "[ERROR] $1" >&2; }
log_success() { echo "[OK] $1"; }

detect_sas() {
    local search_paths=()

    case "$WB_OS" in
        windows)
            search_paths=(
                "C:/Program Files/SASFoundation/9.4"
                "C:/Program Files/SASFoundation/9.3"
                "C:/Program Files/SASFoundation/9.2"
                "C:/Program Files (x86)/SASFoundation/9.4"
                "D:/SASFoundation/9.4"
            )
            ;;
        mac)
            search_paths=(
                "/Applications/SASFoundation/9.4"
            )
            ;;
        linux)
            search_paths=(
                "/opt/SASFoundation/9.4"
                "/usr/local/SASFoundation/9.4"
            )
            ;;
    esac

    for dir in "${search_paths[@]}"; do
        local sas_names=("sas.exe" "sas" "sas_en" "sas_zh")
        for sas_name in "${sas_names[@]}"; do
            if [[ -x "$dir/$sas_name" ]]; then
                SAS_CMD="$dir/$sas_name"
                SAS_VERSION="${dir##*SASFoundation/}"
                SAS_VERSION="${SAS_VERSION%%/*}"
                log_success "Detected SAS $SAS_VERSION: $SAS_CMD"
                return 0
            fi
        done
    done

    # Windows: try registry via reg query
    if [[ "$WB_OS" == "windows" ]]; then
        local reg_bases=(
            "HKLM\\SOFTWARE\\SAS Institute Inc."
            "HKLM\\SOFTWARE\\Wow6432Node\\SAS Institute Inc."
        )
        for reg_base in "${reg_bases[@]}"; do
            local reg_output
            reg_output=$(reg query "$reg_base" /s 2>/dev/null | grep -i "InstallLocation" | head -1)
            if [[ -n "$reg_output" ]]; then
                local install_dir
                install_dir=$(echo "$reg_output" | awk -F'REG_SZ' '{print $2}' | xargs)
                if [[ -n "$install_dir" && -d "$install_dir" ]]; then
                    local exe="$install_dir/sas.exe"
                    if [[ -x "$exe" ]]; then
                        SAS_CMD="$exe"
                        SAS_VERSION="${install_dir##*SASFoundation/}"
                        SAS_VERSION="${SAS_VERSION%%/*}"
                        log_success "Detected SAS via registry: $SAS_CMD"
                        return 0
                    fi
                fi
            fi
        done
    fi

    # Try which/command -v as fallback
    if command -v sas &>/dev/null; then
        SAS_CMD="$(command -v sas)"
        log_success "Detected SAS in PATH: $SAS_CMD"
        return 0
    fi

    return 1
}

verify_sas() {
    if [[ -z "$SAS_CMD" ]]; then
        return 1
    fi

    echo ""
    echo "============================================"
    echo "  WARNING: 即将执行 SAS 验证"
    echo "  将运行: $SAS_CMD -sysin test_sas.sas"
    echo "============================================"
    echo ""
    read -p "确认执行? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "跳过 SAS 验证"
        return 0
    fi

    # Test SAS with a simple command
    cd /tmp
    echo "proc options; run;" > test_sas.sas
    "$SAS_CMD" -sysin test_sas.sas -log test_sas.log -print test_sas.lst &>/dev/null 2>&1
    local exit_code=$?

    return $exit_code
}

save_config() {
    local config_file="${1:-$ROOT_DIR/../config.json}"

    if [[ -f "$config_file" ]]; then
        # Merge with existing config
        log_info "Updating existing config: $config_file"
    else
        cat > "$config_file" << EOF
{
  "SAS": {
    "installed": true,
    "path": "$SAS_CMD",
    "version": "$SAS_VERSION",
    "platform": "$WB_OS",
    "mode": "simple"
  }
}
EOF
        log_success "Created config: $config_file"
    fi
}

main() {
    echo "=== SAS Setup (Cross-Platform) ==="
    echo "Platform: $WB_OS ($WB_ARCH)"
    echo ""

    if detect_sas; then
        log_success "SAS detected: $SAS_CMD"
        save_config
        verify_sas
        echo ""
        echo "=== Batch Execution Examples / 批处理调用示例 ==="
        echo "Simple batch:"
        echo "  $SAS_CMD -sysin \"path/to/program.sas\" -log \"path/to/output.log\" -print \"path/to/output.lst\""
        echo ""
        echo "Silent batch (no GUI):"
        echo "  $SAS_CMD -batch -nosplash -sysin \"path/to/program.sas\" -log \"path/to/output.log\""
        return 0
    fi

    log_error "SAS not detected."
    echo "Please confirm:"
    echo "  1. SAS Foundation installed?"
    echo "  2. Installation path?"

    local manual_path
    read -p "Enter SAS path: " manual_path
    if [[ -n "$manual_path" ]] && [[ -d "$manual_path" ]]; then
        SAS_CMD="$manual_path/sas"
        [[ "$WB_OS" == "windows" ]] && SAS_CMD="$manual_path/sas.exe"
        save_config
        verify_sas
        return $?
    fi

    return 1
}

main "$@"
