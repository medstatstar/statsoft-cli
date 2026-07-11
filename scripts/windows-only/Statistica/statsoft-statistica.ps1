# statsoft-statistica.ps1 — Statistica CLI 包装器
# 用法:
#   statsoft-statistica run <svb_file>
#   statsoft-statistica version

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "version")]
    [string]$Command,

    [Parameter(Position=1)]
    [string]$FilePath
)

# ============================================================
# Execution authorization gate (SDI-1 / mirrors SPSS & R runners)
# Default: proceed only on an explicit user invocation. STATSOFT_AUTO_WRITE=1
# proceeds non-interactively (agent/CI); STATSOFT_CONFIRM=1 + a real TTY prompts
# y/N and never blocks an automated run unexpectedly.
# ============================================================
function Test-UserAuthorizedToRun {
    # Execution authorization gate — FAIL-CLOSED (default deny).
    # Proceed ONLY when an explicit opt-in is present:
    #   * STATSOFT_AUTO_WRITE=1                          -> non-interactive/agent opt-in
    #   * STATSOFT_CONFIRM=1 AND a real TTY AND user answers y -> interactive confirm
    if ($env:STATSOFT_AUTO_WRITE -eq '1') { return $true }
    if ($env:STATSOFT_CONFIRM -eq '1' -and -not [Console]::IsInputRedirected) {
        $ans = Read-Host "[CN] 即将执行 Statistica 外部二进制（运行用户提供的 SVB 脚本），是否继续？(y/N) / [EN] About to run the Statistica external binary (user-supplied SVB script). Continue? (y/N)"
        return ($ans -match '^[yY]')
    }
    return $false
}

# 初始化 / Init
$configPath = "$PSScriptRoot\..\config.json"
$config = $null
$statisticaExe = $null

if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    if ($config.Statistica -and $config.Statistica.Path) {
        $statisticaExe = $config.Statistica.Path
    }
}

if (-not $statisticaExe) {
    foreach ($p in @(
        "C:\Program Files\StatSoft\Statistica 13\Statistica.exe",
        "C:\Program Files\StatSoft\Statistica 12\Statistica.exe",
        "C:\Program Files (x86)\StatSoft\Statistica 13\Statistica.exe"
    )) { if (Test-Path $p) { $statisticaExe = $p; break } }
}

if (-not $statisticaExe) {
    Write-Error "[CN] Statistica not found. Run setup_statistica.ps1 first. / [EN] 未找到 Statistica，请先运行 setup_statistica.ps1"
    exit 1
}

switch ($Command) {
    "run" {
        if (-not $FilePath -or -not (Test-Path $FilePath)) {
            Write-Error "[CN] Script file not found: $FilePath / [EN] 脚本文件不存在: $FilePath"
            exit 1
        }
        if (-not (Test-UserAuthorizedToRun)) {
            Write-Error "[CN] 已取消执行（未确认）/ [EN] Execution cancelled (not confirmed)"
            exit 1
        }
        Write-Host "[CN] Running Statistica script: $FilePath" -ForegroundColor Cyan
        Write-Host "[EN] 运行 Statistica 脚本: $FilePath" -ForegroundColor Cyan
        & $statisticaExe /run $FilePath
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[CN] Statistica execution complete" -ForegroundColor Green
            Write-Host "[EN] Statistica 执行完成" -ForegroundColor Green
        } else {
            Write-Warning "[CN] Statistica exit code: $LASTEXITCODE"
            Write-Warning "[EN] Statistica 退出码: $LASTEXITCODE"
        }
    }
    "version" {
        Write-Host "[CN] Statistica executable: $statisticaExe" -ForegroundColor White
        Write-Host "[EN] Statistica 可执行文件: $statisticaExe" -ForegroundColor White
    }
}
