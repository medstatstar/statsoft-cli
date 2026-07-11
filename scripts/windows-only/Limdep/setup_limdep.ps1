# Setup script for LIMDEP
# Econometric software for limited and qualitative dependent variable models
# Reference: https://limdep.com/

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
    $env:STATSOFT_AUTO_WRITE = "1"
    & python3 "$gate" "$ConfigPath" "$tmp"
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}



Write-Host "=== LIMDEP Setup ===" -ForegroundColor Cyan

$installPaths = @(
    "C:\Program Files\Limdep",
    "C:\Program Files (x86)\Limdep",
    "D:\Program Files\Limdep",
    "D:\Program Files (x86)\Limdep"
)

$limdepExe = $null
foreach ($p in $installPaths) {
    $exe = Join-Path $p "limdep.exe"
    if (Test-Path $exe) {
        $limdepExe = $exe
        break
    }
}

if ($limdepExe) {
    Write-Lang "Found LIMDEP: $limdepExe" "Found LIMDEP: $limdepExe" -ForegroundColor Green
} else {
  Write-Lang "LIMDEP not found. Please install from https:" "/limdep.com/" -Color Yellow
}

$configPath = Join-Path $PSScriptRoot "..\config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json
if ($limdepExe) {
    $config | Add-Member -NotePropertyName "LIMDEP" -NotePropertyValue @{
        installed = $true
        version = "11.0"
        path = $limdepExe
        platform = "windows"
        mode = "simple"
    } -Force
    Save-StatSoftConfig -ConfigPath $configPath -Config $config
} else {
    Write-Lang "Skipped config.json update." "Skipped config.json update." -ForegroundColor Gray
}

Write-Lang "" ""
Write-Lang "LIMDEP CLI Usage:" "LIMDEP CLI Usage:" -ForegroundColor Cyan
Write-Host "  limdep commands.txt      # Run LIMDEP command file"
Write-Host "  limdep --help            # Show CLI options"
Write-Lang "" ""
Write-Lang "Supported: Logit, Probit, Tobit, Sample Selection, Count Models, Frontier Analysis" "Supported: Logit, Probit, Tobit, Sample Selection, Count Models, Frontier Analysis"
