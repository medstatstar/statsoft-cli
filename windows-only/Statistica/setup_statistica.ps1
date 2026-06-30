# Statistica 检测与配置脚本
# 支持平台: Windows-only

# 颜色函数
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# 检测 Statistica
function Detect-Statistica {
    Write-Info "检测 Statistica..."
    
    # 检查常见安装路径
    $possiblePaths = @(
        "C:\Program Files\Statistica\Statistica.exe",
        "C:\Program Files (x86)\Statistica\Statistica.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-Info "找到 Statistica: $path"
            return $path
        }
    }
    
    # 检查 PATH
    $statisticaInPath = Get-Command "Statistica.exe" -ErrorAction SilentlyContinue
    if ($statisticaInPath) {
        Write-Info "在 PATH 中找到 Statistica: $($statisticaInPath.Source)"
        return $statisticaInPath.Source
    }
    
    Write-Warn "未找到 Statistica"
    return $null
}

# 验证 Statistica
function Verify-Statistica {
    param([string]$StatisticaPath)
    
    Write-Info "验证 Statistica..."
    
    if (-not (Test-Path $StatisticaPath)) {
        Write-Error "Statistica 可执行文件不存在: $StatisticaPath"
        return $false
    }
    
    # 尝试运行 Statistica 获取版本信息
    try {
        $versionInfo = (Get-Item $StatisticaPath).VersionInfo
        Write-Info "Statistica 版本: $($versionInfo.ProductVersion)"
        Write-Info "Statistica 验证成功"
        return $true
    }
    catch {
        Write-Warn "无法获取 Statistica 版本信息: $_"
        return $false
    }
}

# 配置 Statistica
function Configure-Statistica {
    param([string]$StatisticaPath)
    
    Write-Info "配置 Statistica..."
    
    $configFile = "$HOME\.workbuddy\skills\statsoft-cli\config.json"
    
    # 创建配置目录
    $configDir = Split-Path $configFile -Parent
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    # 读取现有配置
    $config = @{}
    if (Test-Path $configFile) {
        $config = Get-Content $configFile | ConvertFrom-Json
    }
    
    # 更新配置
    $config.Statistica = @{
        installed = $true
        path = $StatisticaPath
        platform = "windows"
        version = "Unknown"
    }
    
    # 保存配置
    $config | ConvertTo-Json -Depth 10 | Set-Content $configFile
    
    Write-Info "Statistica 配置已保存到: $configFile"
    return $true
}

# 主函数
function Main {
    Write-Info "开始 Statistica 检测与配置..."
    
    # 检测 Statistica
    $statisticaPath = Detect-Statistica
    
    if (-not $statisticaPath) {
        Write-Warn "未找到 Statistica，请手动指定路径"
        
        # 提示用户输入路径
        $userPath = Read-Host "请输入 Statistica 安装路径（按 Enter 跳过）"
        
        if ($userPath) {
            $statisticaPath = $userPath
        }
        else {
            Write-Error "未配置 Statistica"
            exit 1
        }
    }
    
    # 验证 Statistica
    if (-not (Verify-Statistica $statisticaPath)) {
        Write-Error "Statistica 验证失败"
        exit 1
    }
    
    # 配置 Statistica
    if (-not (Configure-Statistica $statisticaPath)) {
        Write-Error "Statistica 配置失败"
        exit 1
    }
    
    Write-Info "✅ Statistica 配置完成！"
    Write-Info ""
    Write-Info "⚠️ 配置完成提示:"
    Write-Info "  - ⚠️ Statistica 批处理模式可能有闪屏"
    Write-Info "  - ⚠️ Windows-only，不支持 macOS 和 Linux"
    Write-Info "  - 💡 适合数据挖掘、机器学习和统计分析"
    Write-Info ""
    Write-Info "📋 推荐使用方式:"
    Write-Info "  # 运行 SVB 脚本"
    Write-Info "  `"$statisticaPath`" /run `"script.svb`""
    
    return 0
}

# 运行主函数
Main
