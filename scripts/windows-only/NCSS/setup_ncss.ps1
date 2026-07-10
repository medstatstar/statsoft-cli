# Setup script for NCSS
# NCSS Statistical Software
# Reference: https://www.ncss.com/

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



Write-Host "=== NCSS Setup ===" -ForegroundColor Cyan

$installPaths = @(
    "C:\Program Files\NCSS\NCSS 2024",
    "C:\Program Files\NCSS",
    "C:\Program Files (x86)\NCSS\NCSS 2024",
    "C:\Program Files (x86)\NCSS",
    "D:\Program Files\NCSS\NCSS 2024",
    "D:\Program Files\NCSS"
)

$ncssExe = $null
foreach ($p in $installPaths) {
    $exe = Join-Path $p "NCSS.exe"
    if (Test-Path $exe) {
        $ncssExe = $exe
        break
    }
}

if ($ncssExe) {
    Write-Lang "Found NCSS: $ncssExe" "Found NCSS: $ncssExe" -ForegroundColor Green
} else {
  Write-Lang "NCSS not found. Please install from https:" "/www.ncss.com/" -Color Yellow
}

$configPath = Join-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) "config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($ncssExe) {
        $config | Add-Member -NotePropertyName "NCSS" -NotePropertyValue @{
            installed = $true
            version = "2024"
            path = $ncssExe
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
    }
} else {
    Write-Lang "config.json not found, skipping update." "config.json not found, skipping update." -ForegroundColor Gray
}

Write-Lang "" ""
Write-Lang "NCSS CLI Usage:" "NCSS CLI Usage:" -ForegroundColor Cyan
  Write-Lang "'NCSS.exe'" "B 'analysis.ncss'    # Run NCSS batch analysis" -Color White
  Write-Lang "'NCSS.exe'" "B 'report.ncss'      # Generate NCSS report" -Color White
Write-Lang "" ""
Write-Lang "Supported: Statistical Analysis, Sample Size Calculation, Medical Statistics, Clinical Trials" "Supported: Statistical Analysis, Sample Size Calculation, Medical Statistics, Clinical Trials"
