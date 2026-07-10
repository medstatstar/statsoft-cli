# setup_mplus.ps1 — Detect and configure Mplus (Windows/Mac)

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

# Search for Mplus
$searchPaths = @(
    "C:\Program Files\Mplus",
    "C:\Program Files (x86)\Mplus",
    "C:\Mplus",
    "$env:ProgramFiles\Mplus",
    "${env:ProgramFiles(x86)}\Mplus"
)

$mplusExe = $null
$installPath = $null

foreach ($p in $searchPaths) {
    $candidate = Join-Path $p "mplus.exe"
    if (Test-Path $candidate) {
        $mplusExe = $candidate
        $installPath = $p
        break
    }
    # Also check subdirectories
    if (Test-Path $p) {
        $subdirs = Get-ChildItem $p -Directory -ErrorAction SilentlyContinue
        foreach ($d in $subdirs) {
            $candidate = Join-Path $d.FullName "mplus.exe"
            if (Test-Path $candidate) {
                $mplusExe = $candidate
                $installPath = $d.FullName
                break
            }
        }
    }
    if ($mplusExe) { break }
}

if (-not $mplusExe) {
    Write-Lang "ERROR: Mplus not found." "ERROR: Mplus not found." -ForegroundColor Red
    exit 1
}

# Get version
$ver = $null
$fi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($mplusExe)
$ver = $fi.FileVersion

Write-Lang "Mplus: $mplusExe" "Mplus: $mplusExe" -ForegroundColor Green
Write-Lang "Version: $ver" "Version: $ver"

# Update config
$config["Mplus"] = [ordered]@{
    "installed" = $true
    "path"      = (Split-Path $mplusExe -Parent)
    "exe"       = $mplusExe
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
