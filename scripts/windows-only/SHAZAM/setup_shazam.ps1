# Setup script for SHAZAM Econometrics Software (Windows)
# Reference: https://www.econometrics.com/

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



Write-Host "=== SHAZAM Setup ===" -ForegroundColor Cyan

$installPaths = @(
    "C:\Program Files\Shazam",
    "C:\Program Files (x86)\Shazam",
    "D:\Program Files\Shazam",
    "D:\Program Files (x86)\Shazam"
)

$shazamExe = $null
foreach ($p in $installPaths) {
    $exe = Join-Path $p "shazam.exe"
    if (Test-Path $exe) {
        $shazamExe = $exe
        break
    }
}

if ($shazamExe) {
    Write-Lang "Found SHAZAM: $shazamExe" "Found SHAZAM: $shazamExe" -ForegroundColor Green
} else {
  Write-Lang "SHAZAM not found. Please install from https:" "/www.econometrics.com/" -Color Yellow
}

$configDir = Split-Path (Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent) -Parent
$configPath = Join-Path $configDir "config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json
if ($shazamExe) {
    $config | Add-Member -NotePropertyName "SHAZAM" -NotePropertyValue @{
        installed = $true
        version = "12.0"
        path = $shazamExe
        platform = "windows"
        mode = "simple"
       } -Force
    # ── Backup & Confirm ──
    $configDir = Split-Path $configPath -Parent
    if (Test-Path $configPath) {
        $backupPath = Join-Path $configDir "config.json.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $configPath $backupPath
        Write-Lang "Config backed up to: $backupPath" "配置已备份至: $backupPath" -Color Gray
    }
    $writeConfirm = Read-Host (if ($script:isZH) { "确认写入配置? (y/N)" } else { "Confirm write config? (y/N)" })
    if ($writeConfirm -ne 'y' -and $writeConfirm -ne 'Y') {
        Write-Lang "Skipped config write." "已跳过配置写入。" -Color Yellow
        return
    }
    $config | ConvertTo-Json -Depth 3 | Set-Content $configPath
    Write-Lang "config.json updated." "config.json updated." -ForegroundColor Green
} else {
    Write-Lang "Skipped config.json update." "Skipped config.json update." -ForegroundColor Gray
}

Write-Lang "" ""
Write-Lang "SHAZAM CLI Usage:" "SHAZAM CLI Usage:" -ForegroundColor Cyan
Write-Host "  shazam commands.txt      # Run SHAZAM command file"
Write-Host "  shazam --help            # Show CLI options"
Write-Lang "" ""
Write-Lang "Supported: Econometrics, Time Series, Hypothesis Testing, Regression" "Supported: Econometrics, Time Series, Hypothesis Testing, Regression"
