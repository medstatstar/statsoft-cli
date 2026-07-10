# setup_q.ps1 — Detect and configure Q Research (MRKS, Windows)

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


param()

$configPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\..\config.json"

# Load existing config (ordered)
$config = [ordered]@{}
if (Test-Path $configPath) {
    $existing = Get-Content $configPath -Raw | ConvertFrom-Json
    foreach ($prop in $existing.PSObject.Properties) {
        $config[$prop.Name] = $prop.Value
    }
}

# Search for Q (MRKS)
$searchPaths = @(
    "C:\Program Files\Q Research",
    "C:\Program Files\Q by RGB",
    "C:\Program Files\RGB\Q",
    "C:\Program Files\Askia\Q",
    "C:\Program Files (x86)\Q Research",
    "C:\Program Files (x86)\Q by RGB",
    "C:\Q Research",
    "C:\Q"
)

$qExe = $null
$installPath = $null

foreach ($p in $searchPaths) {
    # Look for Q.exe or Q.exe
    foreach ($name in @("Q.exe", "QResearch.exe", "q.exe")) {
        $candidate = Join-Path $p $name
        if (Test-Path $candidate) {
            $qExe = $candidate
            $installPath = $p
            break
        }
    }
    if ($qExe) { break }
}

if (-not $qExe) {
    Write-Lang "ERROR: Q (MRKS) not found." "ERROR: Q (MRKS) not found." -ForegroundColor Red
    exit 1
}

# Get version
$ver = $null
$fi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($qExe)
$ver = $fi.FileVersion

Write-Lang "Q (MRKS): $qExe" "Q (MRKS): $qExe" -ForegroundColor Green
Write-Lang "Version: $ver" "Version: $ver"

# Update config
$config["Q_MRKS"] = [ordered]@{
    "installed" = $true
    "path"      = (Split-Path $qExe -Parent)
    "exe"       = $qExe
    "version"   = $ver
    "platform"  = "win"
}

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

ConvertTo-Json $config -Depth 5 | Set-Content $configPath -Encoding UTF8
Write-Lang "Done." "Done." -ForegroundColor Green
