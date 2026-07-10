# statsoft-spss.ps1 — SPSS CLI 包装器
# 调用优先级：
#   1) stats.com 控制台版 → -production silent -nologo（首选，无闪屏）
#   2) SPSS 内置 Python → StartSPSS() + Submit() + StopSPSS（备用，无闪屏）
#   3) stats.exe → -production silent -nologo（最后备选，可能有闪屏）

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "run-batch", "data-info", "version", "check-syntax")]
    [string]$Command,

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"

# ============================================================
# 初始化
# ============================================================
$scriptDir  = Split-Path $MyInvocation.MyCommand.Path -Parent
$helperPy   = Join-Path $scriptDir "spss_helper.py"

# 读取配置
$configPath = Join-Path $scriptDir "..\..\config.json"
$statsPython = $null
$statsExe = $null
$statsCom = $null

if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        if ($config."SPSS Statistics" -and $config."SPSS Statistics".Path) {
            $p = $config."SPSS Statistics".Path  # 指向 stats.exe
            $baseDir = Split-Path $p -Parent
            # Python（与 stats.exe 同目录）
            $pythonCand = Join-Path $baseDir "Python3\python.exe"
            if (Test-Path $pythonCand) { $statsPython = $pythonCand }
            # stats.com（与 stats.exe 同目录）
            $comCand = Join-Path $baseDir "stats.com"
            if (Test-Path $comCand) { $statsCom = $comCand }
            $statsExe = $p
        }
    } catch { }
}

# 动态扫描
if (-not $statsPython -or -not $statsCom) {
    # Fixed system drives only (C:, D:) — no full host inventory of mounted volumes
    $drives = @("C", "D")
    $versions = @("26", "27", "28", "29", "30")
    $patterns = @(
        "{0}:\Program Files\IBM\SPSS\Statistics\{1}",
        "{0}:\Program Files (x86)\IBM\SPSS\Statistics\{1}",
        "{0}:\Program Files\IBM\SPSS30\Statistics\{1}",
        "{0}:\SPSS\Statistics\{1}",
        "{0}:\IBM\SPSS\Statistics\{1}"
    )
    foreach ($d in $drives) {
        if ($statsPython -and $statsCom -and $statsExe) { break }
        foreach ($v in $versions) {
            if ($statsPython -and $statsCom -and $statsExe) { break }
            foreach ($pat in $patterns) {
                $dir = $pat -f $d, $v
                if (Test-Path $dir) {
                    if (-not $statsPython) { $candPy = Join-Path $dir "Python3\python.exe"; if (Test-Path $candPy) { $statsPython = $candPy } }
                    if (-not $statsCom)  { $candCom  = Join-Path $dir "stats.com"; if (Test-Path $candCom) { $statsCom = $candCom } }
                    if (-not $statsExe)  { $candStat = Join-Path $dir "stats.exe"; if (Test-Path $candStat) { $statsExe = $candStat } }
                }
            }
        }
    }
}

if (-not $statsPython -and -not $statsCom) {
    Write-Warning "[CN] 未检测到 SPSS / [EN] SPSS not found"; exit 1
}

if ($statsCom)   { Write-Host "[CN] stats.com: $statsCom" -ForegroundColor Cyan }
if ($statsPython) { Write-Host "[CN] Python: $statsPython" -ForegroundColor Cyan }
if ($statsExe)    { Write-Host "[CN] stats.exe: $statsExe" -ForegroundColor Cyan }

# ============================================================
# 首选：stats.com 控制台版（无闪屏）
# ============================================================
function Invoke-SPSSConsole {
    param( [string]$SpjFile )
    Write-Host "`n[CN] 调用 SPSS (首选: stats.com, 无闪屏)..." -ForegroundColor Yellow
    Write-Host "[EN] Calling SPSS (preferred: stats.com, no splash)..." -ForegroundColor Yellow

    if (-not $statsCom -or -not (Test-Path $statsCom)) {
        Write-Warning "[CN] 未找到 stats.com / [EN] stats.com not found"; return $false
    }

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $statsCom
        $psi.Arguments = "'-production' 'silent' '-nologo' `"$SpjFile`""
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true

        $p = [System.Diagnostics.Process]::Start($psi)
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        $p.WaitForExit(300000)

        if ($stdout) { Write-Host $stdout }
        if ($stderr) { Write-Warning $stderr }

        $exitCode = $p.ExitCode
        Write-Host "[CN] 退出码: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) {"Green"} else {"Red"})
        return ($exitCode -eq 0)
    } catch {
        Write-Error "[CN] 执行出错 / [EN] Execution error: $($_.Exception.Message)"
        return $false
    }
}

# ============================================================
# 备用：内置 Python（无闪屏）
# ============================================================
function Invoke-SPSSBuiltinPython {
    param( [string]$SpsFile )
    Write-Host "`n[CN] 调用 SPSS (备用: 内置 Python, 无闪屏)..." -ForegroundColor Yellow
    Write-Host "[EN] Calling SPSS (backup: bundled Python, no splash)..." -ForegroundColor Yellow

    if (-not $statsPython -or -not (Test-Path $statsPython)) {
        Write-Warning "[CN] 未找到内置 Python / [EN] bundled Python not found"; return $false
    }

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $statsPython
        $psi.Arguments = "`"$helperPy`" run-internal `"$SpsFile`" `"$statsPython`""
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        $psi.EnvironmentVariables["PATH"] = (Split-Path $statsPython -Parent) + ";" + $psi.EnvironmentVariables["PATH"]

        $p = [System.Diagnostics.Process]::Start($psi)
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        if (-not $p.WaitForExit(300000)) { $p.Kill() }

        if ($stdout) { Write-Host $stdout }
        if ($stderr) { Write-Warning $stderr }

        $exitCode = $p.ExitCode
        Write-Host "[CN] 退出码: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) {"Green"} else {"Red"})
        return ($exitCode -eq 0)
    } catch {
        Write-Error "[CN] 执行出错 / [EN] Execution error: $($_.Exception.Message)"
        return $false
    }
}

# ============================================================
# 最后备选：stats.exe（可能有闪屏）
# ============================================================
function Invoke-SPSSExecutable {
    param( [string]$SpjFile )
    Write-Host "`n[CN] 调用 SPSS 最后备选: stats.exe (可能有闪屏)..." -ForegroundColor Yellow
    Write-Host "[EN] Calling SPSS (last resort: stats.exe, may show splash)..." -ForegroundColor Yellow

    if (-not $statsExe -or -not (Test-Path $statsExe)) {
        Write-Error "[CN] 未找到 stats.exe / [EN] stats.exe not found"
        return $false
    }

    $confirm = "N"
    try {
        $confirm = Read-Host "[CN] 此方式可能出现闪屏。是否继续? (y/N) / [EN] May show splash. Continue? (y/N)"
    } catch {
        Write-Host "[CN] 非交互模式，默认跳过 / [EN] Non-interactive mode, defaulting to skip" -ForegroundColor Yellow
    }
    if ($confirm -ne 'y' -and $confirm -ne 'Y') { exit 1 }

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $statsExe
        $psi.Arguments = "'-production' `"$SpjFile`" 'silent' '-nologo'"
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true

        $p = [System.Diagnostics.Process]::Start($psi)
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()
        $p.WaitForExit(300000)

        if ($stdout) { Write-Host $stdout }
        if ($stderr) { Write-Warning $stderr }

        $exitCode = $p.ExitCode
        Write-Host "[CN] 退出码: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) {"Green"} else {"Red"})
        return ($exitCode -eq 0)
    } catch {
        Write-Error "[CN] 执行出错 / [EN] Execution error: $($_.Exception.Message)"
        return $false
    }
}

# ============================================================
# 生成 .spj 文件（SPSS 26+ 新格式）
# ============================================================
function New-SpssSpj {
    param( [string]$SpsFile, [string]$WorkDir )

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($SpsFile)
    $spjFile  = Join-Path $WorkDir "$baseName.spj"
    $spvFile  = Join-Path $WorkDir "$baseName.spv"
    # ⚠️ 关键：必须使用正斜杠（SPSS Production Facility 要求）
    $spsUrl   = ([System.IO.Path]::GetFullPath($SpsFile)) -replace '\\', '/'
    $spvUrl   = $spvFile -replace '\\', '/'

    $xml = @"
<?xml version="1.0" encoding="UTF-8"?>
<job xmlns="http://www.ibm.com/software/analytics/spss/xml/production"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     print="false"
     syntaxErrorHandling="continue"
     syntaxFormat="interactive"
     unicode="true"
     xsi:schemaLocation="http://www.ibm.com/software/analytics/spss/xml/production http://www.ibm.com/software/analytics/spss/xml/production/production-1.4.xsd">
  <locale charset="UTF-8" country="CN" language="zh"/>
  <output outputFormat="viewer" outputPath="$spvUrl"/>
  <syntax syntaxPath="$spsUrl"/>
</job>
"@
    [System.IO.File]::WriteAllText($spjFile, $xml, [System.Text.Encoding]::UTF8)
    return $spjFile
}

# ============================================================
# Main dispatch
# ============================================================
function Test-UserAuthorizedToRun {
    # Execution authorization for running SPSS (external command / file writes).
    # The user's explicit `run`/`run-batch` invocation is the intent, so default = proceed;
    # STATSOFT_CONFIRM=1 + a real TTY prompts y/N; STATSOFT_AUTO_WRITE=1 auto-proceeds.
    # Never fires without a TTY, so it can never hang an automated run.
    $autoWrite = $env:STATSOFT_AUTO_WRITE -eq '1'
    $confirm = $env:STATSOFT_CONFIRM -eq '1'
    if ($autoWrite) { return $true }
    if ($confirm -and -not [Console]::IsInputRedirected) {
        $ans = Read-Host (if ($script:isZH) { "确认运行 SPSS? (y/N)" } else { "Confirm running SPSS? (y/N)" })
        return ($ans -match '^[yY]')
    }
    return $true
}

switch ($Command) {
    "run" {
        if (-not (Test-UserAuthorizedToRun)) { Write-Lang "已取消执行（未确认）" "Execution cancelled (not confirmed)." -Color Yellow; exit 1 }
        $spsFile = $Args[0]
        if (-not $spsFile -or -not (Test-Path $spsFile)) {
            Write-Error "[CN] 语法文件不存在: $spsFile / [EN] Syntax file not found"; exit 1
        }

        $workDir = $PWD
        $spjFile = New-SpssSpj -SpsFile $spsFile -WorkDir $workDir

        # 首选：stats.com
        $success = Invoke-SPSSConsole -SpjFile $spjFile
        if ($success) { Remove-Item $spjFile -ErrorAction SilentlyContinue; exit 0 }

        # 备用：内置 Python
        Write-Host "" -ForegroundColor Yellow
        Write-Warning "[CN] stats.com 失败，尝试内置 Python..."
        Write-Warning "[EN] stats.com failed. Trying Python fallback..."
        $success = Invoke-SPSSBuiltinPython $spsFile

        if ($success) { Remove-Item $spjFile -ErrorAction SilentlyContinue; exit 0 }

        # 最后备选：stats.exe
        Write-Host "" -ForegroundColor Yellow
        Write-Warning "[CN] Python 也失败，尝试 stats.exe..."
        Write-Warning "[EN] Python also failed. Trying stats.exe..."
        $success = Invoke-SPSSExecutable -SpjFile $spjFile

        Remove-Item $spjFile -ErrorAction SilentlyContinue
        exit [int](-not $success)
    }

    "run-batch" {
        if (-not (Test-UserAuthorizedToRun)) { Write-Lang "已取消执行（未确认）" "Execution cancelled (not confirmed)." -Color Yellow; exit 1 }
        if ($Args.Count -eq 0) { Write-Error "需提供语法文件路径 / Please provide syntax file path"; exit 1 }
        $workDir   = $PWD
        $masterSps = Join-Path $workDir "batch-master.sps"
        $lines     = @("* SPSS Batch Run", "SET PRINTBACK=ON.", "")
        foreach ($f in $Args) {
            if (-not (Test-Path $f)) { Write-Warning "跳过 / Skip: $f"; continue }
            $lines += @("* File: $f", "INSERT FILE=`"$f`"", "")
        }
        [System.IO.File]::WriteAllText($masterSps, ($lines -join "`r`n"), [System.Text.Encoding]::UTF8)

        $spjFile = New-SpssSpj -SpsFile $masterSps -WorkDir $workDir

        # 优先级链：stats.com → Python → stats.exe
        $success = Invoke-SPSSConsole -SpjFile $spjFile
        if (-not $success) { $success = Invoke-SPSSBuiltinPython $masterSps }
        if (-not $success) { $success = Invoke-SPSSExecutable -SpjFile $spjFile }

        Remove-Item $spjFile -ErrorAction SilentlyContinue
        Remove-Item $masterSps -ErrorAction SilentlyContinue
        exit [int](-not $success)
    }

    "data-info" {
        $savFile = $Args[0]
        if (-not $savFile -or -not (Test-Path $savFile)) { Write-Error "数据文件不存在 / Data file not found"; exit 1 }
        $helperPy = Join-Path $scriptDir "_data_info.py"
        if (-not (Test-Path $helperPy)) { Write-Error "缺少辅助脚本 _data_info.py / Missing helper _data_info.py"; exit 1 }
        # Resolve a concrete interpreter to an absolute path (SDI-2 fix):
        # avoid bare `python.exe` PATH resolution, which can pick up an unexpected
        # interpreter. The path is passed to the helper as a safe argv argument.
        $pyExe = $null
        $cmd = Get-Command python.exe -ErrorAction SilentlyContinue
        if ($cmd) { $pyExe = $cmd.Source }
        if (-not $pyExe) { Write-Error "未找到 Python / Python not found"; exit 1 }
        & $pyExe $helperPy $savFile
    }

    "version" {
        if (-not $statsPython) { Write-Error "未找到内置 Python / bundled Python not found"; exit 1 }
        & $statsPython -c "import spss; spss.StartSPSS(); print(getattr(spss,'__version__','unknown')); spss.StopSPSS()"
    }

    "check-syntax" {
        $spsFile = $Args[0]
        if (-not $spsFile -or -not (Test-Path $spsFile)) { Write-Error "语法文件不存在 / Syntax file not found"; exit 1 }
        Get-Content $spsFile -Head 10
    }
}
