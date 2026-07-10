# setup_modeler.ps1 — Detect and configure SPSS Modeler

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

$configPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "..\config.json"

# Load existing config (ordered)
$config = [ordered]@{}
if (Test-Path $configPath) {
    try {
        $existing = Get-Content $configPath -Raw | ConvertFrom-Json
        foreach ($prop in $existing.PSObject.Properties) {
            $config[$prop.Name] = $prop.Value
        }
    } catch { }
}

# Search for Modeler
$searchBases = @(
    "C:\Program Files\IBM\SPSS\Modeler",
    "C:\Program Files (x86)\IBM\SPSS\Modeler",
    "D:\Program Files\IBM\SPSS\Modeler",
    "D:\Program Files (x86)\IBM\SPSS\Modeler"
)

$clembExe = $null
$installPath = $null
$ver = $null

foreach ($base in $searchBases) {
    if (-not (Test-Path $base)) { continue }
    $dirs = Get-ChildItem $base -Directory -ErrorAction SilentlyContinue
    foreach ($d in $dirs) {
        $candidate = Join-Path $d.FullName "bin\clemb.exe"
        if (Test-Path $candidate) {
            $clembExe = $candidate
            $installPath = $d.FullName
            $mcExe = Join-Path $d.FullName "bin\modelerclient.exe"
            if (Test-Path $mcExe) {
                $fi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($mcExe)
                $ver = $fi.FileVersion
            }
            break
        }
    }
    if ($clembExe) { break }
}

if (-not $clembExe) {
    Write-Lang "ERROR: SPSS Modeler not found." "ERROR: SPSS Modeler not found." -ForegroundColor Red
    exit 1
}

Write-Lang "Found: $installPath" "Found: $installPath" -ForegroundColor Green
Write-Lang "clemb: $clembExe" "clemb: $clembExe"
Write-Lang "Version: $ver" "Version: $ver"

# Update config
$config["SPSS Modeler"] = [ordered]@{
    "installed" = $true
    "version"   = "$ver"
    "path"      = $clembExe
    "mode"      = "simple"
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

# Write
ConvertTo-Json $config -Depth 5 | Set-Content $configPath -Encoding UTF8

Write-Lang "Done. config.json updated." "Done. config.json updated." -ForegroundColor Green
