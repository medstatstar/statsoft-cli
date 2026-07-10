# Setup script for NLOGIT
# Discrete choice and multinomial logit modeling
# Reference: https://limdep.com/nlogit.html

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



Write-Host "=== NLOGIT Setup ===" -ForegroundColor Cyan

$installPaths = @(
    "C:\Program Files\Limdep",
    "C:\Program Files (x86)\Limdep",
    "D:\Program Files\Limdep",
    "D:\Program Files (x86)\Limdep"
)

$nlogitExe = $null
foreach ($p in $installPaths) {
    $exe = Join-Path $p "nlogit.exe"
    if (Test-Path $exe) {
        $nlogitExe = $exe
        break
    }
}

if ($nlogitExe) {
    Write-Lang "Found NLOGIT: $nlogitExe" "Found NLOGIT: $nlogitExe" -ForegroundColor Green
} else {
  Write-Lang "NLOGIT not found. Please install from https:" "/limdep.com/" -Color Yellow
}

$configPath = "C:\Users\WintoneFileSrv\.workbuddy\skills\statsoft-cli\config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json
if ($nlogitExe) {
    # ── Backup & Confirm ──
    $configDir = Split-Path $configPath -Parent
    if (Test-Path $configPath) {
        $backupPath = Join-Path $configDir "config.json.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $configPath $backupPath
        Write-Lang "Config backed up to: $backupPath" "配置已备份至: $backupPath" -Color Gray
    }
    $writeConfirm = Read-Host (if ($script:isZH) { "确认写入 NLOGIT 配置? (y/N)" } else { "Confirm write NLOGIT config? (y/N)" })
    if ($writeConfirm -ne 'y' -and $writeConfirm -ne 'Y') {
        Write-Lang "Skipped config write." "已跳过配置写入。" -Color Yellow
        return
    }
    $config | Add-Member -NotePropertyName "NLOGIT" -NotePropertyValue @{
        installed = $true
        version = "6.0"
        path = $nlogitExe
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
Write-Lang "NLOGIT CLI Usage:" "NLOGIT CLI Usage:" -ForegroundColor Cyan
Write-Host "  nlogit commands.txt      # Run NLOGIT command file"
Write-Host "  nlogit --help            # Show CLI options"
Write-Lang "" ""
Write-Lang "Supported: Multinomial Logit, Nested Logit, Mixed Logit, Probit Models" "Supported: Multinomial Logit, Nested Logit, Mixed Logit, Probit Models"
