# Setup script for Microfit
# Time series and econometric software
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



Write-Host "=== Microfit Setup ===" -ForegroundColor Cyan

$installPaths = @(
    "C:\Program Files\Microfit",
    "C:\Program Files (x86)\Microfit",
    "D:\Program Files\Microfit",
    "D:\Program Files (x86)\Microfit"
)

$microfitExe = $null
foreach ($p in $installPaths) {
    $exe = Join-Path $p "microfit.exe"
    if (Test-Path $exe) {
        $microfitExe = $exe
        break
    }
}

if ($microfitExe) {
    Write-Lang "Found Microfit: $microfitExe" "Found Microfit: $microfitExe" -ForegroundColor Green
} else {
  Write-Lang "Microfit not found. Please install from https:" "/www.econometrics.com/" -Color Yellow
}

$configPath = "C:\Users\WintoneFileSrv\.workbuddy\skills\statsoft-cli\config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json
if ($microfitExe) {
    $config | Add-Member -NotePropertyName "Microfit" -NotePropertyValue @{
        installed = $true
        version = "5.0"
        path = $microfitExe
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
Write-Lang "Microfit CLI Usage:" "Microfit CLI Usage:" -ForegroundColor Cyan
Write-Host "  microfit commands.txt     # Run Microfit command file"
Write-Host "  microfit --help          # Show CLI options"
Write-Lang "" ""
Write-Lang "Supported: Time Series, Econometrics, Unit Root Tests, ARDL, Panel Data" "Supported: Time Series, Econometrics, Unit Root Tests, ARDL, Panel Data"
