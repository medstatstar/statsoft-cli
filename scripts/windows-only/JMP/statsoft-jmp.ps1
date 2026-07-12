# statsoft-jmp.ps1 — JMP CLI wrapper (advanced mode)
# Usage:
#   statsoft-jmp run <jsl_file> [--log-file <path>] [--silent]
#   statsoft-jmp data-info <jmp_file> [--vars var1 var2]
#   statsoft-jmp read-log <log_path>

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "data-info", "read-log")]
    [string]$Command,

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args,

    [string]$LogFile,
    [switch]$Silent
)

# ============================================================
# Execution authorization gate — FAIL-CLOSED (default deny).
# Proceed ONLY when an explicit opt-in is present:
#   * STATSOFT_AUTO_WRITE=1                          -> non-interactive/agent opt-in
#   * STATSOFT_CONFIRM=1 AND a real TTY AND user answers y -> interactive confirm
# Any other case (incl. a plain user invocation without opt-in) -> deny.
# ============================================================
function Test-UserAuthorizedToRun {
    $autoWrite = $env:STATSOFT_AUTO_WRITE -eq '1'
    $confirm = $env:STATSOFT_CONFIRM -eq '1'
    if ($autoWrite) { return $true }
    if ($confirm -and -not [Console]::IsInputRedirected) {
        $ans = Read-Host "[CN] 确认运行 JMP？将执行第三方外部二进制 (y/N) / [EN] Confirm running JMP? Executes a third-party external binary (y/N)"
        return ($ans -match '^[yY]')
    }
    return $false
}

# Reject paths that could break command-line / script argument parsing.
function Test-SafePath {
    param([string]$Path)
    if (-not $Path) { return $false }
    if ($Path -match '["`\n\r]') { return $false }
    return $true
}

# Read config
$configPath = "$PSScriptRoot\..\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "[CN] 配置文件不存在: $configPath。请先运行 setup_jmp.ps1 / [EN] Config file not found: $configPath. Please run setup_jmp.ps1 first."
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$jmpPath = $config.JMP.Path

if (-not (Test-Path $jmpPath)) {
    Write-Error "[CN] JMP 可执行文件不存在: $jmpPath / [EN] JMP executable not found: $jmpPath"
    exit 1
}

switch ($Command) {
    "run" {
        $jslFile = $Args[0]
        if (-not (Test-Path $jslFile)) {
            Write-Error "[CN] JSL 脚本不存在: $jslFile / [EN] JSL script not found: $jslFile"
            exit 1
        }
        if (-not (Test-SafePath $jslFile)) {
            Write-Error "[CN] 脚本路径含非法字符 / [EN] Script path contains illegal characters"
            exit 1
        }
        if (-not (Test-UserAuthorizedToRun)) {
            Write-Error "[CN] 已取消执行（未确认）/ [EN] Execution cancelled (not confirmed)"
            exit 1
        }

        $logPath = if ($LogFile) { $LogFile } else { Join-Path $PWD "jmp-log.txt" }
        Write-Host "[CN] 执行 JMP 脚本: $jslFile" -ForegroundColor Cyan
        Write-Host "[EN] Executing JMP script: $jslFile" -ForegroundColor Cyan
        Write-Host "[CN] 日志输出: $logPath" -ForegroundColor Gray
        Write-Host "[EN] Log output: $logPath" -ForegroundColor Gray

        $jmpArgs = @("/R", "`"$jslFile`"")
        if ($Silent) {
            $jmpArgs = @("/S") + $jmpArgs
        }

        & $jmpPath $jmpArgs 2>&1 | Tee-Object -FilePath $logPath

        if ($LASTEXITCODE -eq 0) {
            Write-Host "[CN] JMP 执行完成" -ForegroundColor Green
            Write-Host "[EN] JMP execution complete" -ForegroundColor Green
        } else {
            Write-Warning "[CN] JMP 退出码: $LASTEXITCODE"
            Write-Warning "[EN] JMP exit code: $LASTEXITCODE"
        }
    }

    "data-info" {
        $jmpFile = $Args[0]
        if (-not (Test-Path $jmpFile)) {
            Write-Error "[CN] JMP 数据文件不存在: $jmpFile / [EN] JMP data file not found: $jmpFile"
            exit 1
        }
        if (-not (Test-SafePath $jmpFile)) {
            Write-Error "[CN] 数据文件路径含非法字符 / [EN] Data file path contains illegal characters"
            exit 1
        }
        if (-not (Test-UserAuthorizedToRun)) {
            Write-Error "[CN] 已取消（未确认）/ [EN] Cancelled (not confirmed)"
            exit 1
        }

        # Generate a temporary JSL script to read the data structure. The data
        # file path is embedded ONLY after a safe-path check (no quotes/backticks),
        # and the temp file is disclosed and removed in a finally block.
        Write-Host "[CN] 创建临时 JSL 脚本（仅本次运行，结束后删除）以获取数据结构:" -ForegroundColor Gray
        $tempJsl = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.jsl'
        Write-Host "  $tempJsl" -ForegroundColor Gray
        try {
            $jslBody = 'dt = Open("' + $jmpFile + '");' + "`r`n" + 'dt << Show Properties();' + "`r`n"
            Set-Content $tempJsl -Value $jslBody -Encoding UTF8
            & $jmpPath /R $tempJsl 2>&1
        } finally {
            Remove-Item $tempJsl -ErrorAction SilentlyContinue
        }
    }

    "read-log" {
        $logPath = $Args[0]
        if (-not $logPath) {
            Write-Error "[CN] 未提供日志路径 / [EN] No log path provided"
            exit 1
        }
        # Authorization gate (same as run/data-info) before any file read.
        if (-not (Test-UserAuthorizedToRun)) {
            Write-Error "[CN] 已取消（未确认）/ [EN] Cancelled (not confirmed)"
            exit 1
        }
        # Canonicalize and restrict to the current working directory plus an
        # approved extension allowlist, so this wrapper cannot be abused as an
        # arbitrary local file reader (SDI-3).
        $resolved = Resolve-Path -Path $logPath -ErrorAction SilentlyContinue
        if (-not $resolved) {
            Write-Error "[CN] 日志文件不存在: $logPath / [EN] Log file not found: $logPath"
            exit 1
        }
        $full = $resolved.Path
        $allowedDir = (Resolve-Path -Path $PWD).Path
        if (-not ($full.StartsWith($allowedDir, [System.StringComparison]::OrdinalIgnoreCase) -and
                  ($full -match '\.(log|txt|csv)$'))) {
            Write-Error "[CN] 拒绝读取：仅允许读取当前工作目录下的 .log/.txt/.csv 日志文件 / [EN] Refused: only .log/.txt/.csv log files under the current directory may be read"
            exit 1
        }
        Get-Content $full
    }
}
