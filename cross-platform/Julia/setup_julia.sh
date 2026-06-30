#!/bin/bash
# setup_julia.sh - Julia 统计计算环境检测与配置脚本
# Julia: 高性能统计计算语言，跨平台，纯 CLI，适合贝叶斯统计和机器学习

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_platform-detect.sh"

echo "=== Julia 环境检测 / Julia Environment Detection ==="
echo "平台 / Platform: $WB_OS ($WB_ARCH)"
echo ""

# 检测 Julia 是否安装
detect_julia() {
    local julia_cmd=""
    
    # 所有平台：检查 PATH
    julia_cmd=$(which julia 2>/dev/null)
    
    if [ -z "$julia_cmd" ]; then
        # Windows: 检查常见安装路径
        if [ "$WB_OS" = "windows" ]; then
            local win_paths=(
                "C:/Users/$USER/AppData/Local/Programs/Julia-1.9.4/bin/julia.exe"
                "C:/Users/$USER/AppData/Local/Programs/Julia-1.9.3/bin/julia.exe"
            )
            for path in "${win_paths[@]}"; do
                if [ -f "$path" ]; then
                    julia_cmd="$path"
                    break
                fi
            done
        fi
    fi
    
    echo "$julia_cmd"
}

# 主流程
main() {
    local julia_path=$(detect_julia)
    
    if [ -n "$julia_path" ]; then
        echo "✅ 检测到 Julia 安装 / Julia installation detected:"
        echo "  路径 / Path: $julia_path"
        
        # 获取版本信息
        local version=$($julia_path --version 2>&1 | head -1)
        echo "  版本 / Version: $version"
        
        # 输出配置信息（供 AI Agent 读取）
        echo ""
        echo "=== 配置信息 / Configuration Info ==="
        echo "JULIA_PATH=$julia_path"
        echo "JULIA_VERSION=$version"
        echo "JULIA_OS=$WB_OS"
        echo "JULIA_ARCH=$WB_ARCH"
        
        # 输出使用说明
        echo ""
        echo "=== 使用说明 / Usage Instructions ==="
        echo "批处理命令（完全无 GUI）/ Batch command (completely GUI-free):"
        echo "  $julia_path script.jl"
        echo ""
        echo "脚本示例 / Script example:"
        echo "  # script.jl"
        echo "  using Statistics, GLM, CSV"
        echo "  data = CSV.read(\"data.csv\", DataFrame)"
        echo "  model = lm(@formula(y ~ x1 + x2), data)"
        echo "  println(model)"
        echo "  CSV.write(\"results.csv\", DataFrame(coef=coef(model)))"
        echo ""
        echo "常用统计包 / Common statistical packages:"
        echo "  - Statistics: 基础统计（已内置）"
        echo "  - GLM: 广义线性模型"
        echo "  - CSV: 读写 CSV 文件"
        echo "  - DataFrames: 数据处理"
        echo "  - Turing: 贝叶斯统计"
        echo "  - MLJ: 机器学习"
        echo ""
        echo "⚠️ Linux/macOS 特殊说明 / Linux/macOS Special Notes:"
        echo "  - Linux: 可以使用包管理器安装: apt/yum/brew install julia"
        echo "  - macOS: 推荐使用 Homebrew: brew install julia"
        echo "  - 所有平台：首次使用包时需要下载，可能较慢"
        
    else
        echo "❌ 未检测到 Julia 安装 / Julia installation not found"
        echo ""
        echo "=== 安装指南 / Installation Guide ==="
        
        if [ "$WB_OS" = "windows" ]; then
            echo "Windows 安装步骤 / Windows installation steps:"
            echo "  1. 访问 Julia 官网: https://julialang.org/downloads/"
            echo "  2. 下载 Windows 安装包（.exe）"
            echo "  3. 运行安装程序，按默认设置安装"
            echo "  4. 安装完成后，julia.exe 通常在 C:\\Users\\[USER]\\AppData\\Local\\Programs\\Julia-XX.X.X\\bin\\"
        elif [ "$WB_OS" = "mac" ]; then
            echo "macOS 安装步骤 / macOS installation steps:"
            echo "  1. 使用 Homebrew: brew install julia"
            echo "  2. 或下载 .dmg 安装包: https://julialang.org/downloads/"
            echo "  3. 安装完成后，命令行工具在 /Applications/Julia-*.app/Contents/Resources/julia/bin/julia"
        else
            echo "Linux 安装步骤 / Linux installation steps:"
            echo "  Ubuntu/Debian: sudo apt install julia"
            echo "  Fedora/RHEL: sudo dnf install julia"
            echo "  Arch Linux: sudo pacman -S julia"
            echo "  或从官网下载 .tar.gz: https://julialang.org/downloads/"
        fi
        
        echo ""
        echo "⚠️ 重要 / Important:"
        echo "  - 安装后需要安装统计包: julia -e 'using Pkg; Pkg.add(\"GLM\")'"
        echo "  - 首次使用包时需要下载，可能较慢（耐心等待）"
        echo "  - Julia 是即时编译（JIT），首次运行可能较慢"
    fi
}

main "$@"
