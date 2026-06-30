#!/bin/bash
# setup_r.sh - Cross-platform R setup and detection
# Compatible with Windows (Git Bash), macOS, Linux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Source platform detection
source "$ROOT_DIR/_platform-detect.sh"

R_CMD=""
R_VERSION=""

log_info() { echo "[INFO] $1"; }
log_error() { echo "[ERROR] $1" >&2; }
log_success() { echo "[OK] $1"; }

detect_r() {
    # Check PATH first
    if command -v Rscript &>/dev/null; then
        R_CMD="$(command -v Rscript)"
        R_VERSION="$("$R_CMD" --version 2>&1 | head -1)"
        log_success "Detected R: $R_CMD ($R_VERSION)"
        return 0
    fi

    # Platform-specific paths
    local search_paths=()
    case "$WB_OS" in
        windows)
            search_paths=(
                "C:/Program Files/R/"
                "C:/Program Files (x86)/R/"
            )
            ;;
        mac)
            search_paths=(
                "/Library/Frameworks/R.framework/Resources/bin/"
                "/usr/local/bin/"
                "/opt/homebrew/bin/"
            )
            ;;
        linux)
            search_paths=(
                "/usr/bin/"
                "/usr/local/bin/"
                "/opt/R/*/bin/"
            )
            ;;
    esac

    for pattern in "${search_paths[@]}"; do
        # Handle glob patterns
        for dir in $pattern; do
            if [[ -x "$dir/Rscript" ]]; then
                R_CMD="$dir/Rscript"
                R_VERSION="$("$R_CMD" --version 2>&1 | head -1)"
                log_success "Detected R: $R_CMD ($R_VERSION)"
                return 0
            fi
        done
    done

    return 1
}

install_r() {
    local install_path="${1:-}"

    if [[ -z "$install_path" ]]; then
        install_path="$(get_r_default_path)"
    fi

    log_info "Installing R to: $install_path"

    case "$WB_OS" in
        windows)
            # Download R installer from CRAN pre-compiled binary (fast, not compile)
            local r_url="https://cran.r-project.org/bin/windows/base/R-4.5.1-win.exe"
            local installer="${TEMP:-/tmp}/R-installer.exe"

            log_info "Downloading R installer from CRAN..."
            if command -v curl &>/dev/null; then
                curl -fsSL -o "$installer" "$r_url"
            elif command -v wget &>/dev/null; then
                wget -q -O "$installer" "$r_url"
            else
                log_error "Neither curl nor wget found. Please install R manually from https://cran.r-project.org/bin/windows/base/"
                return 1
            fi

            if [[ ! -f "$installer" ]]; then
                log_error "Download failed. Please install R manually from https://cran.r-project.org/bin/windows/base/"
                return 1
            fi

            log_info "Download complete. Installing silently..."
            # Silent install with /SILENT flag (Inno Setup), add to PATH
            "$installer" /SILENT /COMPONENTS="main,x64,translations"

            # Refresh PATH for current session (check common locations)
            local r_bin_dirs=(
                "C:/Program Files/R/bin"
                "C:/Program Files/R/R-4.5.1/bin"
                "$HOME/AppData/Local/Programs/R/bin"
            )
            for rbin in "${r_bin_dirs[@]}"; do
                if [[ -d "$rbin" ]]; then
                    export PATH="$rbin:$PATH"
                    log_success "Added R to PATH: $rbin"
                    break
                fi
            done

            log_info "Installation complete."
            return 0
            ;;
        mac)
            if command -v brew &>/dev/null; then
                brew install --cask r
            else
                log_error "Please install Homebrew first: https://brew.sh"
                return 1
            fi
            ;;
        linux)
            if command -v apt &>/dev/null; then
                sudo apt update
                sudo apt install -y r-base
            elif command -v yum &>/dev/null; then
                sudo yum install -y R
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y R
            else
                log_error "Package manager not found. Please install R manually."
                return 1
            fi
            ;;
    esac
}

verify_r() {
    if [[ -z "$R_CMD" ]]; then
        return 1
    fi

    if "$R_CMD" -e "print('R is connected to WorkBuddy successfully')" &>/dev/null; then
        log_success "R verification passed"
        return 0
    fi

    return 1
}

scan_packages() {
    if [[ -z "$R_CMD" ]]; then
        return 1
    fi

    log_info "Scanning installed R packages..."
    local packages
    packages="$("$R_CMD" -e "cat(installed.packages()[,'Package'], sep='\n')" 2>/dev/null)"

    echo "$packages"
}

save_config() {
    local config_file="${1:-$ROOT_DIR/../config.json}"
    local r_path="${R_CMD:-not installed}"

    # Create or update config
    if [[ -f "$config_file" ]]; then
        # Update existing config (simple JSON manipulation)
        log_info "Updating existing config: $config_file"
    else
        # Create new config
        cat > "$config_file" << EOF
{
  "R": {
    "installed": true,
    "path": "$r_path",
    "version": "$R_VERSION",
    "platform": "$WB_OS",
    "mode": "simple"
  }
}
EOF
        log_success "Created config: $config_file"
    fi
}

detect_anaconda() {
    # Check for conda
    if command -v conda &>/dev/null; then
        local conda_path="$(command -v conda)"
        log_success "Detected Conda: $conda_path"
        return 0
    fi

    # Check common Anaconda/Miniconda paths
    local conda_paths=()
    case "$WB_OS" in
        windows)
            conda_paths=(
                "$HOME/anaconda3/Scripts/conda.exe"
                "$HOME/miniconda3/Scripts/conda.exe"
                "C:/ProgramData/anaconda3/Scripts/conda.exe"
                "C:/ProgramData/miniconda3/Scripts/conda.exe"
            )
            ;;
        mac)
            conda_paths=(
                "$HOME/anaconda3/bin/conda"
                "$HOME/miniconda3/bin/conda"
                "/opt/anaconda3/bin/conda"
                "/opt/miniconda3/bin/conda"
            )
            ;;
        linux)
            conda_paths=(
                "$HOME/anaconda3/bin/conda"
                "$HOME/miniconda3/bin/conda"
                "/opt/anaconda3/bin/conda"
                "/opt/miniconda3/bin/conda"
            )
            ;;
    esac

    for cp in "${conda_paths[@]}"; do
        if [[ -x "$cp" ]]; then
            log_success "Detected Conda: $cp"
            return 0
        fi
    done

    return 1
}

suggest_anaconda() {
    echo ""
    echo "============================================"
    echo "  ALTERNATIVE: Use Anaconda Python Environment"
    echo "  替代方案：使用 Anaconda Python 环境"
    echo "============================================"
    echo ""
    echo "R is not installed and you declined to install it."
    echo "R 未安装，且您选择不安装 R。"
    echo ""
    echo "As an alternative, Anaconda Python provides statistical analysis capabilities:"
    echo "作为替代方案，Anaconda Python 提供统计分析能力："
    echo ""
    echo "  · scipy, statsmodels — statistical tests & modeling"
    echo "  · pandas — data manipulation (like dplyr/tidyr)"
    echo "  · scikit-learn — machine learning (like caret/xgboost)"
    echo "  · matplotlib, seaborn — visualization (like ggplot2)"
    echo "  · lifelines — survival analysis (like survival)"
    echo "  · PyMC — Bayesian modeling"
    echo ""
    echo "Download Anaconda / 下载 Anaconda:"
    echo "  https://www.anaconda.com/download"
    echo ""
    echo "Or install Miniconda (lighter) / 或安装 Miniconda (更轻量):"
    echo "  https://docs.conda.io/en/latest/miniconda.html"
    echo ""
    echo "After install, activate with / 安装后激活:"
    echo "  conda activate base"
    echo ""
    echo "Install stats packages / 安装统计包:"
    echo "  conda install scipy statsmodels pandas scikit-learn matplotlib seaborn"
    echo ""
}

install_anaconda() {
    case "$WB_OS" in
        windows)
            log_info "Downloading Anaconda installer for Windows..."
            local url="https://repo.anaconda.com/archive/Anaconda3-2024.02-1-Windows-x86_64.exe"
            local installer="${TEMP:-/tmp}/Anaconda3-installer.exe"
            if command -v curl &>/dev/null; then
                curl -fsSL -o "$installer" "$url"
            elif command -v wget &>/dev/null; then
                wget -q -O "$installer" "$url"
            else
                log_error "Neither curl nor wget found. Please install Anaconda manually from https://www.anaconda.com/download"
                return 1
            fi
            if [[ -f "$installer" ]]; then
                log_info "Download complete. Running installer silently..."
                "$installer" /S /D="$HOME/anaconda3"
                log_info "Anaconda installed. Please restart your terminal and run 'conda activate base'."
            fi
            ;;
        mac)
            log_info "Downloading Anaconda installer for macOS..."
            local url="https://repo.anaconda.com/archive/Anaconda3-2024.02-1-MacOSX-x86_64.sh"
            local installer="/tmp/Anaconda3-installer.sh"
            if command -v curl &>/dev/null; then
                curl -fsSL -o "$installer" "$url"
            elif command -v wget &>/dev/null; then
                wget -q -O "$installer" "$url"
            else
                log_error "Neither curl nor wget found. Please install Anaconda manually from https://www.anaconda.com/download"
                return 1
            fi
            if [[ -f "$installer" ]]; then
                log_info "Download complete. Running installer..."
                bash "$installer" -b -p "$HOME/anaconda3"
                log_info "Anaconda installed. Please restart your terminal and run 'conda activate base'."
            fi
            ;;
        linux)
            log_info "Downloading Anaconda installer for Linux..."
            local url="https://repo.anaconda.com/archive/Anaconda3-2024.02-1-Linux-x86_64.sh"
            local installer="/tmp/Anaconda3-installer.sh"
            if command -v curl &>/dev/null; then
                curl -fsSL -o "$installer" "$url"
            elif command -v wget &>/dev/null; then
                wget -q -O "$installer" "$url"
            else
                log_error "Neither curl nor wget found. Please install Anaconda manually from https://www.anaconda.com/download"
                return 1
            fi
            if [[ -f "$installer" ]]; then
                log_info "Download complete. Running installer..."
                bash "$installer" -b -p "$HOME/anaconda3"
                log_info "Anaconda installed. Please restart your terminal and run 'conda activate base'."
            fi
            ;;
    esac
}

Main() {
    echo "=== R Setup (Cross-Platform) ==="
    echo "Platform: $WB_OS ($WB_ARCH)"
    echo ""

    if detect_r; then
        verify_r
        save_config
        return 0
    fi

    echo ""
    read -p "R not detected. Install now? (y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        read -p "Custom install path (leave empty for default): " custom_path
        install_r "$custom_path"
        detect_r && verify_r && save_config
        return $?
    fi

    # R not found and user declined — check for Anaconda
    echo ""
    log_info "Checking for Anaconda Python as alternative..."
    if detect_anaconda; then
        log_success "Anaconda/Conda already installed — you can use Python for statistical analysis"
        log_success "已安装 Anaconda/Conda — 可使用 Python 进行统计分析"
        return 2  # Special code: R not found but Anaconda available
    fi

    # Neither R nor Anaconda — suggest Anaconda
    suggest_anaconda

    echo ""
    read -p "Install Anaconda now? (y/N): " anaconda_answer
    if [[ "$anaconda_answer" =~ ^[Yy]$ ]]; then
        install_anaconda
        return $?
    fi

    log_error "Neither R nor Anaconda available. Statistical analysis capabilities will be limited."
    return 1
}

main "$@"
