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

function Save-StatSoftConfig {
    param(
        [string]$ConfigPath,
        [object]$Config
    )
    # Fail-closed by default - persist ONLY when explicitly opted in.
    $autoWrite = $env:STATSOFT_AUTO_WRITE -eq '1'
    $confirm = $env:STATSOFT_CONFIRM -eq '1'
    $persist = $false
    if ($autoWrite) {
        $persist = $true
    } elseif ($confirm -and -not [Console]::IsInputRedirected) {
        $ans = Read-Host (if ($script:isZH) { "Persist detected config to config.json? (y/N)" } else { "Persist detected config to config.json? (y/N)" })
        if ($ans -match '^[yY]') { $persist = $true }
    }
    if (-not $persist) {
        Write-Lang "Detection-only: config.json NOT modified. Set STATSOFT_AUTO_WRITE=1 to persist, or STATSOFT_CONFIRM=1 for an interactive prompt." "Detection-only: config.json NOT modified. Set STATSOFT_AUTO_WRITE=1 to persist, or STATSOFT_CONFIRM=1 for an interactive prompt." -Color Yellow
        return
    }
    $gate = Join-Path $PSScriptRoot "..\..\common\write_config.py"
    if (-not (Test-Path $gate)) {
        Write-Lang "write_config.py gate not found; skipping persist." "write_config.py gate not found; skipping persist." -Color Red
        return
    }
    $tmp = [System.IO.Path]::GetTempFileName()
    $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $tmp -Encoding UTF8
    & python3 "$gate" "$ConfigPath" "$tmp" "--consent"
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}


$configPath = Join-Path $PSScriptRoot "..\config.json"

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

Save-StatSoftConfig -ConfigPath $configPath -Config $config
