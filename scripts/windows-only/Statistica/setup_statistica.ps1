# Statistica 检测与配置脚本
# 支持平台: Windows-only

# ============================================================
# Language Detection
# ============================================================
$systemLang = [System.Globalization.CultureInfo]::CurrentUICulture.Name
$script:isZH = $systemLang.StartsWith("zh")

function Write-Lang {
    param(
        [string]$CN,
        [string]$EN,
        [System.ConsoleColor]$Color = "White"
    )
    if ($script:isZH) { Write-Host $CN -ForegroundColor $Color }
    else { Write-Host $EN -ForegroundColor $Color }
}

function Save-StatSoftConfig {
    param(
        [string]$ConfigPath,
        [object]$Config
    )
    # Fail-closed by default - persist ONLY when explicitly opted in.
    $autoWrite = $env:STATSOFT_AUTO_WRITE -eq '1'
    $confirm = $env:STATSOFT_CONFIRM -eq '1'
    $persist = $false
    if ($autoWrite) {
        $persist = $true
    } elseif ($confirm -and -not [Console]::IsInputRedirected) {
        $ans = Read-Host (if ($script:isZH) { "Persist detected config to config.json? (y/N)" } else { "Persist detected config to config.json? (y/N)" })
        if ($ans -match '^[yY]') { $persist = $true }
    }
    if (-not $persist) {
        Write-Lang "Detection-only: config.json NOT modified. Set STATSOFT_AUTO_WRITE=1 to persist, or STATSOFT_CONFIRM=1 for an interactive prompt." "Detection-only: config.json NOT modified. Set STATSOFT_AUTO_WRITE=1 to persist, or STATSOFT_CONFIRM=1 for an interactive prompt." -Color Yellow
        return
    }
    $gate = Join-Path $PSScriptRoot "..\..\common\write_config.py"
    if (-not (Test-Path $gate)) {
        Write-Lang "write_config.py gate not found; skipping persist." "write_config.py gate not found; skipping persist." -Color Red
        return
    }
    $tmp = [System.IO.Path]::GetTempFileName()
    $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $tmp -Encoding UTF8
    $env:STATSOFT_AUTO_WRITE = "1"
    & python3 "$gate" "$ConfigPath" "$tmp"
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

}



# 颜色函数
function Write-Info {
    param([string]$Message)
    Write-Lang "[INFO] [CN] $Message" "[INFO] [CN] $Message" -ForegroundColor Green
    Write-Lang "[INFO] [EN] $Message" "[INFO] [EN] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Lang "[WARN] [CN] $Message" "[WARN] [CN] $Message" -ForegroundColor Yellow
    Write-Lang "[WARN] [EN] $Message" "[WARN] [EN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Lang "[ERROR] [CN] $Message" "[ERROR] [CN] $Message" -ForegroundColor Red
    Write-Lang "[ERROR] [EN] $Message" "[ERROR] [EN] $Message" -ForegroundColor Red
}

# 检测 Statistica
function Detect-Statistica {
    Write-Info "检测 Statistica... / Detecting Statistica..."
    
    # 检查常见安装路径
    $possiblePaths = @(
        "C:\Program Files\Statistica\Statistica.exe",
        "C:\Program Files (x86)\Statistica\Statistica.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-Info "找到 Statistica: $path / Found Statistica: $path"
            return $path
        }
    }
    
    # 检查 PATH
    $statisticaInPath = Get-Command "Statistica.exe" -ErrorAction SilentlyContinue
    if ($statisticaInPath) {
        Write-Info "在 PATH 中找到 Statistica: $($statisticaInPath.Source) / Found Statistica in PATH: $($statisticaInPath.Source)"
        return $statisticaInPath.Source
    }
    
    Write-Warn "未找到 Statistica / Statistica not found"
    return $null
}

# 验证 Statistica
function Verify-Statistica {
    param([string]$StatisticaPath)
    
    Write-Info "验证 Statistica... / Verifying Statistica..."
    
    if (-not (Test-Path $StatisticaPath)) {
        Write-Error "Statistica 可执行文件不存在: $StatisticaPath / Statistica executable not found: $StatisticaPath"
        return $false
    }
    
    # 尝试运行 Statistica 获取版本信息
    try {
        $versionInfo = (Get-Item $StatisticaPath).VersionInfo
        Write-Info "Statistica 版本: $($versionInfo.ProductVersion) / Statistica version: $($versionInfo.ProductVersion)"
        Write-Info "Statistica 验证成功 / Statistica verification successful"
        return $true
    }
    catch {
        Write-Warn "无法获取 Statistica 版本信息: $_ / Unable to get Statistica version info: $_"
        return $false
    }
}

# 配置 Statistica
function Configure-Statistica {
    param([string]$StatisticaPath)
    
    Write-Info "配置 Statistica... / Configuring Statistica..."
    
    $configFile = Join-Path $PSScriptRoot "..\config.json"
    
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
    
    Save-StatSoftConfig -ConfigPath $configFile -Config $config
    return $true
}

# 主函数
function Main {
    Write-Info "开始 Statistica 检测与配置... / Starting Statistica detection & configuration..."
    
    # 检测 Statistica
    $statisticaPath = Detect-Statistica
    
    if (-not $statisticaPath) {
        Write-Warn "未找到 Statistica，请手动指定路径 / Statistica not found, please specify path manually"
        
        # L-5: 非交互回退 — Read-Host 带超时
        $userPath = $null
        try {
            $userPath = Read-Host "[CN] 请输入 Statistica 安装路径（按 Enter 跳过）/ [EN] Enter Statistica installation path (press Enter to skip)"
        } catch {
  Write-Lang "[!] [CN] 非交互模式，跳过手动输入" "[EN] Non-interactive mode, skipping manual input" -Color Yellow
        }
        
        if ($userPath) {
            $statisticaPath = $userPath
        }
        else {
            Write-Error "未配置 Statistica / Statistica not configured"
            exit 1
        }
    }
    
    # 验证 Statistica
    if (-not (Verify-Statistica $statisticaPath)) {
        Write-Error "Statistica 验证失败 / Statistica verification failed"
        exit 1
    }
    
    # 配置 Statistica
    if (-not (Configure-Statistica $statisticaPath)) {
        Write-Error "Statistica 配置失败 / Statistica configuration failed"
        exit 1
    }
    
    Write-Info "✅ Statistica 配置完成！/ ✅ Statistica configuration complete!"
    Write-Info ""
    Write-Info "⚠️ 配置完成提示 / Configuration notes:"
    Write-Info "  - ⚠️ Statistica 批处理模式可能有闪屏 / Statistica batch mode may flash screen"
    Write-Info "  - ⚠️ Windows-only，不支持 macOS 和 Linux / Windows-only, not supporting macOS and Linux"
    Write-Info "  - 💡 适合数据挖掘、机器学习和统计分析 / Suitable for data mining, machine learning, and statistical analysis"
    Write-Info ""
    Write-Info "📋 推荐使用方式 / Recommended usage:"
    Write-Info "  # 运行 SVB 脚本 / Run SVB script"
    Write-Info "  `"$statisticaPath`" /run `"script.svb`""
    
    return 0
}

# 运行主函数
Main
