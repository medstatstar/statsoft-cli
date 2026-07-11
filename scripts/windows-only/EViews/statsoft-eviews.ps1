# statsoft-eviews.ps1 — EViews CLI 包装器
# 用法:
#   statsoft-eviews run <prg_file>
#   statsoft-eviews version

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "version")]
    [string]$Command,

    [Parameter(Position=1)]
    [string]$FilePath
)

$systemLang = [System.Globalization.CultureInfo]::CurrentUICulture.Name
$script:isZH = $systemLang.StartsWith("zh")

function Test-UserAuthorizedToRun {
    # Execution authorization gate — FAIL-CLOSED (default deny).
    # Proceed ONLY when an explicit opt-in is present:
    #   * STATSOFT_AUTO_WRITE=1                          -> non-interactive/agent opt-in
    #   * STATSOFT_CONFIRM=1 AND a real TTY AND user answers y -> interactive confirm
    # Any other case -> deny, so an agent/upstream tool cannot trigger third-party
    # code execution unexpectedly.
    $autoWrite = $env:STATSOFT_AUTO_WRITE -eq '1'
    $confirm = $env:STATSOFT_CONFIRM -eq '1'
    if ($autoWrite) { return $true }
    if ($confirm -and -not [Console]::IsInputRedirected) {
        $prompt = if ($script:isZH) { "确认运行 EViews 程序？.prg 是可执行代码，将由第三方 EViews 二进制执行 (y/N)" } else { "Confirm running EViews program? A .prg is executable code run by the third-party EViews binary (y/N)" }
        $ans = Read-Host $prompt
        return ($ans -match '^[yY]')
    }
    return $false
}

# 初始化
$configPath = "$PSScriptRoot\..\config.json"
$config = $null
$eviewsExe = $null

if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    if ($config.EViews -and $config.EViews.Path) {
        $eviewsExe = $config.EViews.Path
    }
}

# 默认路径
if (-not $eviewsExe) {
    foreach ($p in @(
        "C:\Program Files\QMS\EViews 12\EViews12_x64.exe",
        "C:\Program Files\QMS\EViews 11\EViews11_x64.exe",
        "C:\Program Files\QMS\EViews 10\EViews10_x64.exe"
    )) { if (Test-Path $p) { $eviewsExe = $p; break } }
}

if (-not $eviewsExe) {
    Write-Error "[CN] EViews 未找到，请先运行 setup_eviews.ps1 / [EN] EViews not found. Run setup_eviews.ps1 first."
    exit 1
}

switch ($Command) {
    "run" {
        if (-not $FilePath -or -not (Test-Path $FilePath)) {
            Write-Error "[CN] 程序文件不存在: $FilePath / [EN] Program file not found: $FilePath"
            exit 1
        }
        if (-not (Test-UserAuthorizedToRun)) {
            Write-Host "[CN] 已取消执行（未确认）/ [EN] Execution cancelled (not confirmed)." -ForegroundColor Yellow
            exit 1
        }
        Write-Host "[CN] 运行 EViews 程序（.prg 为可执行代码，将由 EViews 执行）: $FilePath" -ForegroundColor Cyan
        Write-Host "[EN] Running EViews program (.prg is executable code run by EViews): $FilePath" -ForegroundColor Cyan
        & $eviewsExe /b $FilePath
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[CN] EViews 执行完成" -ForegroundColor Green
            Write-Host "[EN] EViews execution complete" -ForegroundColor Green
        } else {
            Write-Warning "[CN] EViews 退出码: $LASTEXITCODE"
            Write-Warning "[EN] EViews exit code: $LASTEXITCODE"
        }
    }
    "version" {
        Write-Host "[CN] EViews 可执行文件: $eviewsExe" -ForegroundColor White
        Write-Host "[EN] EViews executable: $eviewsExe" -ForegroundColor White
    }
}
