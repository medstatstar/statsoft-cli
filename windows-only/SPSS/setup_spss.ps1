# setup_spss.ps1 — SPSS 检测与配置验证脚本（后台静默运行）
# 用法: powershell -ExecutionPolicy Bypass -File setup_spss.ps1 [-Version "26"]

param(
    [string]$Version = "26"
)

Write-Host "[CN] === SPSS Statistics 检测与配置 ===" -ForegroundColor Cyan
Write-Host "[EN] === SPSS Statistics Detection & Configuration ===" -ForegroundColor Cyan

# 1. 检测 SPSS 安装
$spssInstalled = $false
$spssPath = ""      # spss.exe / stats.exe 路径（推荐，后台静默）
$spsswinPath = ""   # spsswin.exe 路径（GUI 模式，不推荐）

# 典型安装路径
$commonPaths = @(
    "C:\Program Files\IBM\SPSS\Statistics\$Version",
    "C:\Program Files (x86)\IBM\SPSS\Statistics\$Version",
    "C:\Program Files\IBM\SPSS\Statistics",
    "D:\IBM\SPSS\Statistics\$Version"
)

foreach ($dir in $commonPaths) {
    $statsExe = Join-Path $dir "stats.exe"
    $spssExe = Join-Path $dir "spss.exe"
    $spsswinExe = Join-Path $dir "spsswin.exe"
    
    if (Test-Path $statsExe -or Test-Path $spssExe -or Test-Path $spsswinExe) {
        $spssInstalled = $true
        # 优先使用 stats.exe（26/29/30 版主程序），其次 spss.exe
        $spssPath = if (Test-Path $statsExe) { $statsExe } elseif (Test-Path $spssExe) { $spssExe } else { "N/A" }
        $spsswinPath = if (Test-Path $spsswinExe) { $spsswinExe } else { "N/A" }
        Write-Host "[OK] [CN] 检测到 SPSS Statistics $Version : $dir" -ForegroundColor Green
        Write-Host "[OK] [EN] SPSS Statistics $Version detected: $dir" -ForegroundColor Green
        break
    }
}

# 2. 如果未找到，尝试从注册表查找
if (-not $spssInstalled) {
    Write-Host "[!] [CN] 在常见路径未找到 SPSS，尝试注册表..." -ForegroundColor Yellow
    Write-Host "[!] [EN] SPSS not found in common paths, trying registry..." -ForegroundColor Yellow
    
    $regPaths = @(
        "HKLM:\SOFTWARE\IBM\SPSS Statistics",
        "HKLM:\SOFTWARE\Wow6432Node\IBM\SPSS Statistics"
    )
    
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            $installDir = (Get-ItemProperty $regPath -ErrorAction SilentlyContinue).InstallDirectory
            if ($installDir -and (Test-Path $installDir)) {
                $spssInstalled = $true
                $statsExe = Join-Path $installDir "stats.exe"
                $spssExe = Join-Path $installDir "spss.exe"
                $spsswinExe = Join-Path $installDir "spsswin.exe"
                $spssPath = if (Test-Path $statsExe) { $statsExe } elseif (Test-Path $spssExe) { $spssExe } else { "N/A" }
                $spsswinPath = if (Test-Path $spsswinExe) { $spsswinExe } else { "N/A" }
                Write-Host "[OK] [CN] 从注册表找到 SPSS : $installDir" -ForegroundColor Green
                Write-Host "[OK] [EN] Found SPSS from registry: $installDir" -ForegroundColor Green
                break
            }
        }
    }
}

# 3. 如果仍未找到，提示用户（支持非交互回退）
if (-not $spssInstalled) {
    Write-Host "[!] [CN] 未检测到 SPSS Statistics" -ForegroundColor Yellow
    Write-Host "[!] [EN] SPSS Statistics not found" -ForegroundColor Yellow
    Write-Host "[CN] 请确认以下信息:" -ForegroundColor Yellow
    Write-Host "[EN] Please confirm:" -ForegroundColor Yellow
    Write-Host "  1. [CN] SPSS Statistics 是否已安装？/ [EN] Is SPSS installed?"
    Write-Host "  2. [CN] 安装路径是什么？/ [EN] What is the installation path?"
    Write-Host "  3. [CN] 版本号是多少？（默认参考 26）/ [EN] Version number? (default 26)"
    Write-Host ""
    Write-Host "[CN] 参考文档:" -ForegroundColor Cyan
    Write-Host "[EN] Reference docs:" -ForegroundColor Cyan
    Write-Host "  - Python 编程接口: https://www.ibm.com/docs/zh/spss-statistics/26.0.0?topic=facility-scripting-python-programming-language"
    Write-Host "  - Production Facility: https://www.ibm.com/docs/zh/spss-statistics/26.0.0?topic=system-production-jobs"
    
    # L-5: 非交互回退 — Read-Host 带超时
    $manualPath = $null
    try {
        $manualPath = Read-Host -Prompt "`n[CN] 请输入 SPSS 安装路径 / [EN] Enter SPSS installation path"
    } catch {
        Write-Host "[!] [CN] 非交互模式，跳过手动输入 / [EN] Non-interactive mode, skipping manual input" -ForegroundColor Yellow
    }
    
    if ($manualPath -and (Test-Path $manualPath)) {
        $statsExe = Join-Path $manualPath "stats.exe"
        $spssExe = Join-Path $manualPath "spss.exe"
        $spsswinExe = Join-Path $manualPath "spsswin.exe"
        $spssPath = if (Test-Path $statsExe) { $statsExe } elseif (Test-Path $spssExe) { $spssExe } else { "N/A" }
        $spsswinPath = if (Test-Path $spsswinExe) { $spsswinExe } else { "N/A" }
        $spssInstalled = $true
        Write-Host "[OK] [CN] 已确认 SPSS 路径: $manualPath" -ForegroundColor Green
        Write-Host "[OK] [EN] SPSS path confirmed: $manualPath" -ForegroundColor Green
    }
}

# 4. 检测 SPSS 内置 Python 路径
$pythonPath = "N/A"
$pythonVersion = "Unknown"
$useFString = $false  # SPSS 26 不支持 f-string

if ($spssInstalled) {
    $spssHome = Split-Path $spssPath -Parent
    
    # 从安装路径提取版本号
    $detectedVersion = "26"  # 默认
    if ($spssHome -match "Statistics\\(\d+)") {
        $detectedVersion = $matches[1]
    }
    
    # 检测 Python 路径（典型路径：C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe）
    $pythonPaths = @(
        (Join-Path $spssHome "Python3\python.exe"),
        (Join-Path $spssHome "Python\python.exe"),
        (Join-Path $spssHome "Python3\python3.exe")
    )
    
    foreach ($pyPath in $pythonPaths) {
        if (Test-Path $pyPath) {
            $pythonPath = $pyPath
            Write-Host "[OK] [CN] 检测到 SPSS 内置 Python: $pythonPath" -ForegroundColor Green
            Write-Host "[OK] [EN] SPSS embedded Python detected: $pythonPath" -ForegroundColor Green
            
            # 获取 Python 版本
            try {
                $versionOutput = & $pyPath --version 2>&1
                $pythonVersion = $versionOutput.ToString().Trim()
                
                # 根据版本设置 f-string 支持标志
                if ($pythonVersion -match "3\.(\d+)") {
                    $majorVersion = [int]$matches[1]
                    if ($majorVersion -ge 8) {
                        $useFString = $true
                    }
                }
                
                Write-Host "    [CN] Python 版本: $pythonVersion / [EN] Python version: $pythonVersion" -ForegroundColor Cyan
                Write-Host "    [CN] f-string 支持: $(if ($useFString) { '✅ 支持' } else { '❌ 不支持 (需用 %s 或 .format())' })" -ForegroundColor Cyan
                Write-Host "    [EN] f-string support: $(if ($useFString) { '✅ supported' } else { '❌ not supported (use %s or .format())' })" -ForegroundColor Cyan
            } catch {
                Write-Host "    [!] [CN] 无法获取 Python 版本 / [EN] Unable to get Python version" -ForegroundColor Yellow
            }
            break
        }
    }
    
    if ($pythonPath -eq "N/A") {
        Write-Host "[!] [CN] 未找到 SPSS 内置 Python" -ForegroundColor Yellow
        Write-Host "[!] [EN] SPSS embedded Python not found" -ForegroundColor Yellow
        Write-Host "    [CN] 请确认 SPSS 安装时是否包含了 Python 插件 / [EN] Please confirm Python plugin was installed with SPSS" -ForegroundColor Yellow
    }
}

# 5. 检查 Python 插件
if ($spssInstalled) {
    Write-Host "`n[CN] === 检查 Python 插件 ===" -ForegroundColor Cyan
    Write-Host "[EN] === Checking Python Plugin ===" -ForegroundColor Cyan
    
    # 检查 Python 插件目录
    $pluginDir = Split-Path $spssPath -Parent
    $pythonPlugin = Join-Path $pluginDir "python"
    
    if (Test-Path $pythonPlugin) {
        Write-Host "[OK] [CN] Python 插件目录存在: $pythonPlugin" -ForegroundColor Green
        Write-Host "[OK] [EN] Python plugin directory exists: $pythonPlugin" -ForegroundColor Green
    } else {
        Write-Host "[!] [CN] Python 插件可能未安装" -ForegroundColor Yellow
        Write-Host "[!] [EN] Python plugin may not be installed" -ForegroundColor Yellow
        Write-Host "  [CN] 请通过 SPSS 安装包添加 'Integration Plug-in for Python'/ [EN] Add 'Integration Plug-in for Python' via SPSS installation package" -ForegroundColor Yellow
    }
}

# 6. 输出配置结果
if ($spssInstalled) {
    Write-Host "`n[CN] === 配置结果 ===" -ForegroundColor Cyan
    Write-Host "[EN] === Configuration Result ===" -ForegroundColor Cyan
    Write-Host "[CN] SPSS 主程序路径: $spssPath" -ForegroundColor White
    Write-Host "[EN] SPSS main program path: $spssPath" -ForegroundColor White
    Write-Host "[CN] SPSS GUI 路径 (避免使用): $spsswinPath" -ForegroundColor White
    Write-Host "[EN] SPSS GUI path (avoid): $spsswinPath" -ForegroundColor White
    Write-Host "[CN] SPSS 安装目录: $spssHome" -ForegroundColor White
    Write-Host "[EN] SPSS installation directory: $spssHome" -ForegroundColor White
    Write-Host "[CN] 内置 Python 路径: $pythonPath" -ForegroundColor White
    Write-Host "[EN] Embedded Python path: $pythonPath" -ForegroundColor White
    Write-Host "[CN] Python 版本: $pythonVersion" -ForegroundColor White
    Write-Host "[EN] Python version: $pythonVersion" -ForegroundColor White
    Write-Host "[CN] f-string 支持: $(if ($useFString) { '✅ 支持' } else { '❌ 不支持 (需用 %s 或 .format())' })" -ForegroundColor White
    Write-Host "[EN] f-string support: $(if ($useFString) { '✅ supported' } else { '❌ not supported (use %s or .format())' })" -ForegroundColor White
    Write-Host ""
    
    # 请求用户确认后再修改环境变量
    Write-Host "[CN] 即将设置用户环境变量:" -ForegroundColor Yellow
    Write-Host "[EN] About to set user environment variables:" -ForegroundColor Yellow
    Write-Host "  STATSOFT_SPSS_PATH=$spssHome" -ForegroundColor Gray
    Write-Host "  STATSOFT_SPSS_PYTHON=$pythonPath" -ForegroundColor Gray
    Write-Host "  STATSOFT_SPSS_FSTRING=$useFString" -ForegroundColor Gray

    # L-5: 非交互回退
    $confirm = "Y"
    try {
        $confirm = Read-Host "[CN] 确认设置环境变量? (y/N) / [EN] Confirm setting env vars? (y/N)"
    } catch {
        Write-Host "[!] [CN] 非交互模式，自动应用 / [EN] Non-interactive mode, auto-applying" -ForegroundColor Yellow
    }

    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        [System.Environment]::SetEnvironmentVariable("STATSOFT_SPSS_PATH", $spssHome, "User")
        [System.Environment]::SetEnvironmentVariable("STATSOFT_SPSS_PYTHON", $pythonPath, "User")
        [System.Environment]::SetEnvironmentVariable("STATSOFT_SPSS_FSTRING", $useFString.ToString(), "User")
        Write-Host "[OK] [CN] 环境变量已设置 / [EN] Environment variables set" -ForegroundColor Green
    } else {
        Write-Host "[!] [CN] 跳过环境变量设置 / [EN] Skipping env var setup" -ForegroundColor Yellow
    }
    
    # 显示调用示例
    Write-Host "`n[CN] === 调用示例 ===" -ForegroundColor Cyan
    Write-Host "[EN] === Usage Examples ===" -ForegroundColor Cyan
    Write-Host "[CN] 1. Production Facility 批处理模式 (推荐):" -ForegroundColor White
    Write-Host "[EN] 1. Production Facility batch mode (recommended):" -ForegroundColor White
    Write-Host "   `"$spssPath`" --production `"作业文件.spj`" silent -nologo"
    Write-Host ""
    Write-Host "[CN] 2. SPSS 内部 Python 调用 (完全无闪屏):" -ForegroundColor White
    Write-Host "[EN] 2. SPSS internal Python call (no flash screen):" -ForegroundColor White
    Write-Host "   `"$pythonPath`" spss_helper.py"
    Write-Host ""
    Write-Host "[CN] 注意: 使用 stats.exe 而非 spsswin.exe，避免 GUI 窗口弹出" -ForegroundColor Yellow
    Write-Host "[EN] Note: Use stats.exe, not spsswin.exe, to avoid GUI window popup" -ForegroundColor Yellow
}
