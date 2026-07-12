# setup_amos.ps1 — AMOS detection and configuration (Windows)
# Detection performs common path and registry searches
# ⚠️ SETUP tool: detects installed software AND persists config to config.json (timestamped backup + explicit y/N confirmation). NOT a read-only scanner. GUI-only software: detection/launch only, no CLI batch.

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



param(
    [string]$AmosPath = ""
)

$ErrorActionPreference = "SilentlyContinue"

$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$configPath = Join-Path $PSScriptRoot "..\config.json"

# Load existing config (ordered)
$config = [ordered]@{}
if (Test-Path $configPath) {
    $existing = Get-Content $configPath -Raw | ConvertFrom-Json
    foreach ($prop in $existing.PSObject.Properties) {
        $config[$prop.Name] = $prop.Value
    }
}

# If user provided path, use it directly
if ($AmosPath -and (Test-Path (Join-Path $AmosPath "amos.exe"))) {
    $amosExe = Join-Path $AmosPath "amos.exe"
    $installPath = $AmosPath
    Write-Lang "[OK] Using provided path: $installPath" "[OK] Using provided path: $installPath" -ForegroundColor Green
} else {
    # Search for AMOS
    $searchPaths = @(
        "C:\Program Files\IBM\SPSS\Amos",
        "C:\Program Files (x86)\IBM\SPSS\Amos",
        "C:\Program Files\IBM\SPSS Statistics\Amos",
        "C:\Program Files (x86)\IBM\SPSS Statistics\Amos",
        "D:\Program Files\IBM\SPSS\Amos",
        "D:\Program Files (x86)\IBP\SPSS\Amos",
        "${env:ProgramFiles}\IBM\SPSS\Amos",
        "${env:ProgramFiles(x86)}\IBM\SPSS\Amos"
    )

    $amosExe = $null
    $installPath = $null

    foreach ($p in $searchPaths) {
        $candidate = Join-Path $p "amos.exe"
        if (Test-Path $candidate) {
            $amosExe = $candidate
            $installPath = $p
            break
        }
        # Also check subdirectories
        if (Test-Path $p) {
            $subdirs = Get-ChildItem $p -Directory -ErrorAction SilentlyContinue
            foreach ($d in $subdirs) {
                $candidate = Join-Path $d.FullName "amos.exe"
                if (Test-Path $candidate) {
                    $amosExe = $candidate
                    $installPath = $d.FullName
                    break
                }
            }
        }
        if ($amosExe) { break }
    }

    # If still not found, try registry
    if (-not $amosExe) {
        Write-Lang "[!] AMOS not found in common paths. Trying registry..." "[!] AMOS not found in common paths. Trying registry..." -ForegroundColor Yellow
        $regPaths = @(
            "HKLM:\SOFTWARE\IBM\SPSS Statistics",
            "HKLM:\SOFTWARE\Wow6432Node\IBM\SPSS Statistics"
        )
        foreach ($rp in $regPaths) {
            if (Test-Path $rp) {
                try {
                    $id = (Get-ItemProperty $rp -ErrorAction SilentlyContinue).InstallDirectory
                    if ($id -and (Test-Path $id)) {
                        $subdirs = Get-ChildItem $id -Directory -ErrorAction SilentlyContinue
                        foreach ($d in $subdirs) {
                            $candidate = Join-Path $d.FullName "amos.exe"
                            if (Test-Path $candidate) {
                                $amosExe = $candidate
                                $installPath = $d.FullName
                                break
                            }
                        }
                    }
                } catch {}
            }
            if ($amosExe) { break }
        }
    }
}

# If still not found, run Python helper script
if (-not $amosExe) {
    $pyScript = Join-Path $scriptDir "setup_amos.py"
    if (Test-Path $pyScript) {
        Write-Lang "[!] Running Python helper to search for AMOS..." "[!] Running Python helper to search for AMOS..." -ForegroundColor Yellow
        & python $pyScript 2>&1
        if ($LASTEXITCODE -eq 0) {
            # Python script succeeded, reload config
            if (Test-Path $configPath) {
                $config = Get-Content $configPath -Raw | ConvertFrom-Json
            }
            Write-Lang "Done." "Done." -ForegroundColor Green
            exit 0
        }
    }

  Write-Lang "[!] [CN] 未检测到 AMOS 安装" "[EN] AMOS installation not detected." -Color Yellow
    Write-Lang "请使用 -AmosPath 参数指定 AMOS 安装路径" "Please use -AmosPath to specify the AMOS installation path" -Color White
    Write-Host '示例 / Example: .\setup_amos.ps1 -AmosPath "C:\Program Files\IBM\SPSS\Amos\26"'
    exit 0
}

# Get version (with fallback)
$ver = $null
try {
    $fi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($amosExe)
    $ver = $fi.FileVersion
} catch {
    $ver = "unknown"
}

Write-Lang "AMOS: $amosExe" "AMOS: $amosExe" -ForegroundColor Green
Write-Lang "Version: $ver" "Version: $ver"

# Update config
$config["AMOS"] = [ordered]@{
    "installed" = $true
    "path"      = (Split-Path $amosExe -Parent)
    "exe"       = $amosExe
    "version"   = $ver
    "platform"  = "win"
}

Save-StatSoftConfig -ConfigPath $configPath -Config $config
