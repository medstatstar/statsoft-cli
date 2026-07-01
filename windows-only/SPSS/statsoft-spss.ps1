# statsoft-spss.ps1 — SPSS CLI 包装器（高级模式）
# 首选方式：通过 SPSS 内置 Python 的 spss 模块调用（完全无 GUI）
# 备用方式：通过 stats.exe --production 调用（可能有闪屏）
# 用法:
#   statsoft-spss run <sps_file> [--stats-python <path>]
#   statsoft-spss run-batch <sps1> <sps2> ...
#   statsoft-spss data-info <sav_file>
#   statsoft-spss read-log <log_path>

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "run-batch", "data-info", "install-plugin", "read-log")]
    [string]$Command,

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

# ============================================================
# 初始化：定位 Python、stats.exe、辅助脚本
# ============================================================
$scriptDir  = Split-Path $MyInvocation.MyCommand.Path -Parent
$helperPy   = Join-Path $scriptDir "spss_helper.py"

# 读取配置
$configPath = "$scriptDir\..\config.json"
$config    = $null
$statsPython = $null
$statsExe  = $null
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    if ($config.SPSS -and $config.SPSS.Path) {
        $p = $config.SPSS.Path
        # 查找内置 Python
        $baseDir = Split-Path $p -Parent
        $pythonCand = Join-Path $baseDir "Python3\python.exe"
        if (Test-Path $pythonCand) {
            $statsPython = $pythonCand
        }
        # 查找 stats.exe
        if ($p -match 'spsswin\.exe$') {
            $base = $p -replace 'spsswin\.exe$', ''
            if (Test-Path "${base}stats.exe")  { $statsExe = "${base}stats.exe"  }
            elseif (Test-Path "${base}spss.exe") { $statsExe = "${base}spss.exe" }
        } else {
            $statsExe = $p
        }
    }
}

# 默认路径
if (-not $statsPython) {
    foreach ($p in @(
        "C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe",
        "C:\Program Files\IBM\SPSS30\Python3\python.exe",
        "C:\Program Files\IBM\SPSS\Statistics\29\Python3\python.exe"
    )) { if (Test-Path $p) { $statsPython = $p; break } }
}
if (-not $statsExe) {
    foreach ($p in @(
        "C:\Program Files\IBM\SPSS\Statistics\26\stats.exe",
        "C:\Program Files\IBM\SPSS30\stats.exe",
        "C:\Program Files\IBM\SPSS\Statistics\29\stats.exe"
    )) { if (Test-Path $p) { $statsExe = $p; break } }
}

if (-not $statsPython -and -not $statsExe) {
    Write-Error "[CN] 找不到 SPSS。请先运行 setup_spss.ps1 配置 SPSS。"
    Write-Error "[EN] SPSS not found. Please run setup_spss.ps1 to configure SPSS first."
    exit 1
}

Write-Host "[CN] SPSS 内置 Python : $statsPython" -ForegroundColor Cyan
Write-Host "[EN] SPSS Built-in Python : $statsPython" -ForegroundColor Cyan
Write-Host "[CN] SPSS stats.exe   : $statsExe" -ForegroundColor Cyan
Write-Host "[EN] SPSS stats.exe   : $statsExe" -ForegroundColor Cyan

# ============================================================
# 首选调用方式：通过内置 Python 的 spss 模块（完全无 GUI）
# ============================================================
function Invoke-SPSSInternal {
    param( [string]$SpsFile )
    Write-Host "`n[CN] 调用 SPSS（首选方式：内置 Python，完全无 GUI）..." -ForegroundColor Yellow
    Write-Host "[EN] Calling SPSS (preferred method: built-in Python, no GUI)..." -ForegroundColor Yellow
    
    $pythonExe = $statsPython
    if (-not $pythonExe -or -not (Test-Path $pythonExe)) {
        Write-Warning "[CN] 未找到 SPSS 内置 Python，改用 Production Facility 方式 / [EN] SPSS built-in Python not found, switching to Production Facility"
        return (Invoke-SPSSProduction $SpsFile)
    }
    
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $p.StartInfo.FileName = $pythonExe
    $p.StartInfo.Arguments = "`"$helperPy`" run-internal `"$SpsFile`""
    $p.StartInfo.UseShellExecute = $false
    $p.StartInfo.RedirectStandardOutput = $true
    $p.StartInfo.RedirectStandardError = $true
    $p.StartInfo.CreateNoWindow = $true
    
    Write-Host "[CN] 启动 SPSS 处理器（无 GUI）..." -ForegroundColor Gray
    Write-Host "[EN] Starting SPSS processor (no GUI)..." -ForegroundColor Gray
    $started = $p.Start()
    if ($started) {
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        $p.WaitForExit(300000)  # 等待最多 5 分钟
        Write-Host "[CN] SPSS 执行完成，退出码: $($p.ExitCode)" -ForegroundColor Green
        Write-Host "[EN] SPSS execution complete, exit code: $($p.ExitCode)" -ForegroundColor Green
        if ($stdout) { Write-Host $stdout }
        if ($stderr) { Write-Warning $stderr }
        return $p.ExitCode
    } else {
        Write-Error "[CN] 无法启动 SPSS Python 进程 / [EN] Failed to start SPSS Python process"
        return 1
    }
}

# ============================================================
# 备用调用方式：通过 Production Facility（可能有闪屏）
# ============================================================
function Invoke-SPSSProduction {
    param( [string]$SpjFile )
    Write-Host "`n[CN] 调用 SPSS Production Facility（备用方式，可能有闪屏）..." -ForegroundColor Yellow
    Write-Host "[EN] Calling SPSS Production Facility (alternative method, may show flash screen)..." -ForegroundColor Yellow
    Write-Warning "[CN] 此方式可能显示闪屏。建议使用首选方式（内置 Python）。"
    
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $p.StartInfo.FileName = $statsExe
    $p.StartInfo.Arguments = "--production `"$SpjFile`""
    $p.StartInfo.UseShellExecute = $false
    $p.StartInfo.RedirectStandardOutput = $true
    $p.StartInfo.RedirectStandardError = $true
    $p.StartInfo.CreateNoWindow = $true
    
    Write-Host "[CN] 启动 SPSS Production Facility..." -ForegroundColor Gray
    Write-Host "[EN] Starting SPSS Production Facility..." -ForegroundColor Gray
    $started = $p.Start()
    if ($started) {
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        $p.WaitForExit(300000)
        Write-Host "[CN] SPSS 执行完成，退出码: $($p.ExitCode)" -ForegroundColor Green
        Write-Host "[EN] SPSS execution complete, exit code: $($p.ExitCode)" -ForegroundColor Green
        if ($stdout) { Write-Host $stdout }
        if ($stderr) { Write-Warning $stderr }
        return $p.ExitCode
    } else {
        Write-Error "[CN] 无法启动 SPSS 进程 / [EN] Failed to start SPSS process"
        return 1
    }
}

# ============================================================
# 生成 .spj 文件（从 .sps 语法文件）
# ============================================================
function New-SpssSpj {
    param( [string]$SpsFile, [string]$WorkDir )
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($SpsFile)
    $spjFile  = Join-Path $WorkDir "$baseName.spj"
    $spvFile  = Join-Path $WorkDir "$baseName.spv"
    $spsUrl  = ([System.IO.Path]::GetFullPath($SpsFile)) -replace '\\', '/'
    $spvUrl  = $spvFile -replace '\\', '/'
    @"
<?xml version="1.0" encoding="UTF-8"?>
<job xmlns="http://www.ibm.com/software/analytics/spss/xml/production"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     print="false"
     syntaxErrorHandling="continue"
     syntaxFormat="interactive"
     unicode="true"
     xsi:schemaLocation="http://www.ibm.com/software/analytics/spss/xml/production 
     http://www.ibm.com/software/analytics/spss/xml/production/production-1.4.xsd">
  <locale charset="UTF-8" country="CN" language="zh"/>
  <output outputFormat="viewer" outputPath="$spvUrl"/>
  <syntax syntaxPath="$spsUrl"/>
</job>
"@ | Set-Content $spjFile -Encoding UTF8
    return $spjFile
}

# ============================================================
# 主命令分发
# ============================================================
switch ($Command) {
    "run" {
        $spsFile = $Args[0]
        if (-not $spsFile -or -not (Test-Path $spsFile)) {
            Write-Error "[CN] 语法文件不存在: $spsFile"
            Write-Error "[EN] Syntax file not found: $spsFile"
            exit 1
        }
        $workDir = $PWD
        # 首选：通过内置 Python 调用（无 GUI）
        $rc = Invoke-SPSSInternal $spsFile
        exit $rc
    }

    "run-batch" {
        if ($Args.Count -eq 0) {
            Write-Error "[CN] 请提供至少一个语法文件路径 / [EN] Please provide at least one syntax file path"
            exit 1
        }
        $workDir   = $PWD
        $masterSps = Join-Path $workDir "batch-master.sps"
        $content = @(
            "* SPSS Batch Run - Generated by statsoft-spss",
            "SET PRINTBACK=ON.",
            ""
        )
        foreach ($f in $Args) {
            if (-not (Test-Path $f)) { Write-Warning "跳过: $f"; continue }
            $content += @(
                "* ===========================================",
                "* File: $f",
                "* ===========================================",
                "INSERT FILE=`"$f`".",
                ""
            )
        }
        $content | Set-Content $masterSps -Encoding UTF8
        $rc = Invoke-SPSSInternal $masterSps
        Remove-Item $masterSps -ErrorAction SilentlyContinue
        exit $rc
    }

    "data-info" {
        $savFile = $Args[0]
        if (-not $savFile -or -not (Test-Path $savFile)) {
            Write-Error "[CN] 数据文件不存在: $savFile"
            Write-Error "[EN] Data file not found: $savFile"
            exit 1
        }
        Write-Host "[CN] 读取 .sav 文件: $savFile" -ForegroundColor Cyan
        Write-Host "[EN] Reading .sav file: $savFile" -ForegroundColor Cyan
        Write-Host "[CN] ⚠️  将临时创建 Python 脚本调用 pyreadstat 解析文件" -ForegroundColor Yellow
        Write-Host "[EN] ⚠️  A temporary Python script will use pyreadstat to parse the file" -ForegroundColor Yellow
        Write-Host "    临时脚本路径 / Temp script path: $env:TEMP\statsoft_tmp_*.py" -ForegroundColor Gray
        $pyCode = @"
import sys
try:
    import pyreadstat
    df, meta = pyreadstat.read_sav(r'$($savFile -replace "'","\\'")')
    print('变量数: ' + str(len(df.columns)))
    print('行数:   ' + str(len(df)))
    print('变量名: ' + str(list(df.columns)))
    print()
    print(df.head(20).to_string())
except ImportError:
    print('ERROR: 未安装 pyreadstat 包，请运行: pip install pyreadstat')
except Exception as e:
    print('ERROR: ' + str(e))
    sys.exit(1)
"@
        $tmpPy = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.py'
        $pyCode | Set-Content $tmpPy -Encoding UTF8
        & python.exe $tmpPy
        Remove-Item $tmpPy -ErrorAction SilentlyContinue
    }

    "read-log" {
        $logPath = $Args[0]
        if (-not (Test-Path $logPath)) {
            Write-Error "[CN] 日志文件不存在: $logPath"
            Write-Error "[EN] Log file not found: $logPath"
            exit 1
        }
        Get-Content $logPath
    }

    "install-plugin" {
        Write-Host "[CN] 请通过 SPSS 安装包添加 Python 插件 / [EN] Please install Python plugin via SPSS installer" -ForegroundColor Yellow
        Write-Host "stats.exe 路径: $statsExe" -ForegroundColor Cyan
    }
}
