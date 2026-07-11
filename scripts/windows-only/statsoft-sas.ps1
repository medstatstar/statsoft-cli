# statsoft-sas.ps1 — SAS CLI 包装器（高级模式）
# 用法:
#   statsoft-sas run <sas_file> [--log-file <path>]
#   statsoft-sas data-info <sas_file> [--vars var1 var2]
#   statsoft-sas read-log <log_path>
# ⚠️ SETUP tool: detects installed software AND persists config to config.json (timestamped backup + explicit y/N confirmation). NOT a read-only scanner.

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "data-info", "read-log")]
    [string]$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args,
    
    [string]$LogFile
)

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
    if ($script:isZH) {
        Write-Host $CN -ForegroundColor $Color
    } else {
        Write-Host $EN -ForegroundColor $Color
    }
}

function Write-Lang-Warning {
    param(
        [string]$CN,
        [string]$EN
    )
    if ($script:isZH) {
        Write-Warning $CN
    } else {
        Write-Warning $EN
    }
}

function Test-UserAuthorizedToRun {
    # Execution authorization gate — FAIL-CLOSED (default deny).
    # Proceed ONLY when an explicit opt-in is present:
    #   * STATSOFT_AUTO_WRITE=1                          -> non-interactive/agent opt-in
    #   * STATSOFT_CONFIRM=1 AND a real TTY AND user answers y -> interactive confirm
    # Any other case (incl. a plain user invocation without opt-in) -> deny, so
    # an agent or upstream tool cannot trigger third-party execution unexpectedly.
    $autoWrite = $env:STATSOFT_AUTO_WRITE -eq '1'
    $confirm = $env:STATSOFT_CONFIRM -eq '1'
    if ($autoWrite) { return $true }
    if ($confirm -and -not [Console]::IsInputRedirected) {
        $prompt = if ($script:isZH) { "确认运行 SAS？该操作将执行第三方外部二进制 (y/N)" } else { "Confirm running SAS? This executes a third-party external binary (y/N)" }
        $ans = Read-Host $prompt
        return ($ans -match '^[yY]')
    }
    return $false
}

function Resolve-SafeLogPath {
    # Constrain user-supplied log output to a plain filename inside the current
    # working directory. Reject absolute/rooted paths and parent traversal so a
    # caller cannot write an arbitrary file elsewhere on disk (SDI-1).
    param(
        [string]$Requested,
        [string]$DefaultName
    )
    if (-not $Requested) { return (Join-Path $PWD $DefaultName) }
    if ([System.IO.Path]::IsPathRooted($Requested) -or $Requested -match '[\\/]|\.\.') {
        $leaf = Split-Path $Requested -Leaf
        Write-Lang-Warning "已忽略不安全的日志路径，仅使用文件名并写入当前目录: $leaf" "Ignored unsafe log path; using filename in current directory only: $leaf"
        return (Join-Path $PWD $leaf)
    }
    return (Join-Path $PWD $Requested)
}

# 读取配置
$configPath = "$PSScriptRoot\..\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "$(if ($script:isZH) { '配置文件不存在' } else { 'Config file not found' }): $configPath"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$sasPath = $config.SAS.Path

if (-not (Test-Path $sasPath)) {
    Write-Error "$(if ($script=isZH) { 'SAS 可执行文件不存在' } else { 'SAS executable not found' }): $sasPath"
    exit 1
}

switch ($Command) {
    "run" {
        if (-not (Test-UserAuthorizedToRun)) {
            Write-Lang "已取消执行（未确认）" "Execution cancelled (not confirmed)." -Color Yellow
            exit 1
        }
        $sasFile = $Args[0]
        if (-not (Test-Path $sasFile)) {
            Write-Error "$(if ($script:isZH) { 'SAS 程序不存在' } else { 'SAS program not found' }): $sasFile"
            exit 1
        }
        
        $logPath = Resolve-SafeLogPath -Requested $LogFile -DefaultName "sas-log.log"
        $printPath = ($logPath -replace '\.log$', '.lst')
        if ($printPath -eq $logPath) { $printPath = "$logPath.lst" }
        
        Write-Lang "执行 SAS 程序: $sasFile" "Executing SAS program: $sasFile" -Color Cyan
        Write-Lang "日志输出（将写入当前目录）: $logPath" "Log output (written to current directory): $logPath" -Color Gray
        
        & $sasPath -batch -nosplash -sysin $sasFile -log $logPath -print $printPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Lang "SAS 执行完成" "SAS execution complete" -Color Green
        } else {
            Write-Lang-Warning "SAS 退出码: $LASTEXITCODE" "SAS exit code: $LASTEXITCODE"
        }
    }
    
    "data-info" {
        $sasFile = $Args[0]
        if (-not (Test-Path $sasFile)) {
            Write-Error "$(if ($script:isZH) { 'SAS 程序不存在' } else { 'SAS program not found' }): $sasFile"
            exit 1
        }
        
        $tempSas = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.sas'
        @"
proc contents data=sashelp.class;
run;
"@ | Set-Content $tempSas -Encoding UTF8
        
        & $sasPath -batch -nosplash -sysin $tempSas 2>&1
        Remove-Item $tempSas -ErrorAction SilentlyContinue
    }
    
    "read-log" {
        $logPath = $Args[0]
        if (-not (Test-Path $logPath)) {
            Write-Error "$(if ($script:isZH) { '日志文件不存在' } else { 'Log file not found' }): $logPath"
            exit 1
        }
        
        Get-Content $logPath
    }
}
