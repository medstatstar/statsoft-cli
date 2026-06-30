# setup_spss.ps1 — SPSS 检测与配置验证脚本（后台静默运行）
# 用法: powershell -ExecutionPolicy Bypass -File setup_spss.ps1 [-Version "26"]

param(
    [string]$Version = "26"
)

Write-Host "=== SPSS Statistics 检测与配置 ===" -ForegroundColor Cyan

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
        Write-Host "[OK] 检测到 SPSS Statistics $Version : $dir" -ForegroundColor Green
        break
    }
}

# 2. 如果未找到，尝试从注册表查找
if (-not $spssInstalled) {
    Write-Host "[!] 在常见路径未找到 SPSS，尝试注册表..." -ForegroundColor Yellow
    
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
                Write-Host "[OK] 从注册表找到 SPSS : $installDir" -ForegroundColor Green
                break
            }
        }
    }
}

# 3. 如果仍未找到，提示用户
if (-not $spssInstalled) {
    Write-Host "[!] 未检测到 SPSS Statistics" -ForegroundColor Yellow
    Write-Host "请确认以下信息:" -ForegroundColor Yellow
    Write-Host "  1. SPSS Statistics 是否已安装？"
    Write-Host "  2. 安装路径是什么？"
    Write-Host "  3. 版本号是多少？（默认参考 26）"
    Write-Host ""
    Write-Host "参考文档:" -ForegroundColor Cyan
    Write-Host "  - Python 编程接口: https://www.ibm.com/docs/zh/spss-statistics/26.0.0?topic=facility-scripting-python-programming-language"
    Write-Host "  - Production Facility: https://www.ibm.com/docs/zh/spss-statistics/26.0.0?topic=system-production-jobs"
    
    $manualPath = Read-Host "`n请输入 SPSS 安装路径（例如 C:\Program Files\IBM\SPSS\Statistics\26）"
    
    if ($manualPath -and (Test-Path $manualPath)) {
        $statsExe = Join-Path $manualPath "stats.exe"
        $spssExe = Join-Path $manualPath "spss.exe"
        $spsswinExe = Join-Path $manualPath "spsswin.exe"
        $spssPath = if (Test-Path $statsExe) { $statsExe } elseif (Test-Path $spssExe) { $spssExe } else { "N/A" }
        $spsswinPath = if (Test-Path $spsswinExe) { $spsswinExe } else { "N/A" }
        $spssInstalled = $true
        Write-Host "[OK] 已确认 SPSS 路径: $manualPath" -ForegroundColor Green
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
            Write-Host "[OK] 检测到 SPSS 内置 Python: $pythonPath" -ForegroundColor Green
            
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
                
                Write-Host "    Python 版本: $pythonVersion" -ForegroundColor Cyan
                Write-Host "    f-string 支持: $(if ($useFString) { '✅ 支持' } else { '❌ 不支持 (需用 %s 或 .format())' })" -ForegroundColor Cyan
            } catch {
                Write-Host "    [!] 无法获取 Python 版本" -ForegroundColor Yellow
            }
            break
        }
    }
    
    if ($pythonPath -eq "N/A") {
        Write-Host "[!] 未找到 SPSS 内置 Python" -ForegroundColor Yellow
        Write-Host "   请确认 SPSS 安装时是否包含了 Python 插件" -ForegroundColor Yellow
    }
}

# 5. 检查 Python 插件
if ($spssInstalled) {
    Write-Host "`n=== 检查 Python 插件 ===" -ForegroundColor Cyan
    
    # 检查 Python 插件目录
    $pluginDir = Split-Path $spssPath -Parent
    $pythonPlugin = Join-Path $pluginDir "python"
    
    if (Test-Path $pythonPlugin) {
        Write-Host "[OK] Python 插件目录存在: $pythonPlugin" -ForegroundColor Green
    } else {
        Write-Host "[!] Python 插件可能未安装" -ForegroundColor Yellow
        Write-Host "  请通过 SPSS 安装包添加 'Integration Plug-in for Python'" -ForegroundColor Yellow
    }
}

# 6. 输出配置结果
if ($spssInstalled) {
    Write-Host "`n=== 配置结果 ===" -ForegroundColor Cyan
    Write-Host "SPSS 主程序路径 (后台): $spssPath"
    Write-Host "SPSS GUI 路径 (避免使用): $spsswinPath"
    Write-Host "SPSS 安装目录: $spssHome"
    Write-Host "内置 Python 路径: $pythonPath"
    Write-Host "Python 版本: $pythonVersion"
    Write-Host "f-string 支持: $(if ($useFString) { '✅ 支持' } else { '❌ 不支持 (需用 %s 或 .format())' })"
    Write-Host ""
    Write-Host "环境变量已设置:" -ForegroundColor Green
    Write-Host "  STATSOFT_SPSS_PATH=$spssHome"
    Write-Host "  STATSOFT_SPSS_PYTHON=$pythonPath"
    Write-Host "  STATSOFT_SPSS_FSTRING=$useFString"
    
    # 设置环境变量
    [System.Environment]::SetEnvironmentVariable("STATSOFT_SPSS_PATH", $spssHome, "User")
    [System.Environment]::SetEnvironmentVariable("STATSOFT_SPSS_PYTHON", $pythonPath, "User")
    [System.Environment]::SetEnvironmentVariable("STATSOFT_SPSS_FSTRING", $useFString.ToString(), "User")
    
    # 显示调用示例
    Write-Host "`n=== 调用示例 ===" -ForegroundColor Cyan
    Write-Host "1. Production Facility 批处理模式 (推荐):"
    Write-Host "   `"$spssPath`" --production `"作业文件.spj`" silent -nologo"
    Write-Host ""
    Write-Host "2. SPSS 内部 Python 调用 (完全无闪屏):"
    Write-Host "   `"$pythonPath`" spss_helper.py"
    if (-not $useFString) {
        Write-Host ""
        Write-Host "   ⚠️ 注意: 此版本不支持 f-string，脚本中请使用 %s 或 .format()" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "注意：使用 stats.exe 而非 spsswin.exe，避免 GUI 窗口弹出"
}
