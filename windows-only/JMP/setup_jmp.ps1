# setup_jmp.ps1 — JMP 检测与配置脚本
# 用法: powershell -ExecutionPolicy Bypass -File setup_jmp.ps1

Write-Host "[CN] === JMP 检测与配置 ===" -ForegroundColor Cyan
Write-Host "[EN] === JMP Detection & Configuration ===" -ForegroundColor Cyan

# 1. 检测 JMP 安装
$jmpInstalled = $false
$jmpPath = ""
$jmpVersion = ""

# 典型安装路径
$commonPaths = @(
    "C:\Program Files\JMP\16",
    "C:\Program Files\JMP\15",
    "C:\Program Files\JMP\14",
    "C:\Program Files (x86)\JMP\16",
    "D:\JMP\16"
)

foreach ($dir in $commonPaths) {
    $exe = Join-Path $dir "JMP.exe"
    if (Test-Path $exe) {
        $jmpInstalled = $true
        $jmpPath = $exe
        $jmpVersion = $dir -replace ".*JMP\\", ''
        Write-Host "[OK] [CN] 检测到 JMP $jmpVersion : $jmpPath" -ForegroundColor Green
        Write-Host "[OK] [EN] JMP $jmpVersion detected: $jmpPath" -ForegroundColor Green
        break
    }
}

# 2. 如果未找到，尝试注册表
if (-not $jmpInstalled) {
    Write-Host "[!] [CN] 在常见路径未找到 JMP，尝试注册表..." -ForegroundColor Yellow
    Write-Host "[!] [EN] JMP not found in common paths, trying registry..." -ForegroundColor Yellow
    
    $regPaths = @(
        "HKLM:\SOFTWARE\JMP",
        "HKLM:\SOFTWARE\Wow6432Node\JMP"
    )
    
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            $jmpKey = Get-ChildItem $regPath -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($jmpKey) {
                $installDir = (Get-ItemProperty $jmpKey.PSPath -ErrorAction SilentlyContinue).InstallLocation
                if ($installDir -and (Test-Path $installDir)) {
                    $exe = Join-Path $installDir "JMP.exe"
                    if (Test-Path $exe) {
                        $jmpInstalled = $true
                        $jmpPath = $exe
                        $jmpVersion = $installDir -replace ".*JMP\\", ''
                        Write-Host "[OK] [CN] 从注册表找到 JMP : $jmpPath" -ForegroundColor Green
                        Write-Host "[OK] [EN] Found JMP from registry: $jmpPath" -ForegroundColor Green
                        break
                    }
                }
            }
        }
    }
}

# 3. 如果仍未找到，提示用户（支持非交互回退）
if (-not $jmpInstalled) {
    Write-Host "[!] [CN] 未检测到 JMP" -ForegroundColor Yellow
    Write-Host "[!] [EN] JMP not detected" -ForegroundColor Yellow
    Write-Host "[CN] 请确认以下信息:" -ForegroundColor Yellow
    Write-Host "[EN] Please confirm the following:" -ForegroundColor Yellow
    Write-Host "  1. [CN] JMP 是否已安装？/ [EN] Is JMP installed?"
    Write-Host "  2. [CN] 安装路径是什么？/ [EN] What is the installation path?"

    # L-5: 非交互回退 — Read-Host 带超时
    $manualPath = $null
    try {
        $manualPath = Read-Host -Prompt "`n[CN] 请输入 JMP 安装路径（例如 C:\Program Files\JMP\16）/ [EN] Enter JMP installation path (e.g. C:\Program Files\JMP\16)"
    } catch {
        Write-Host "[!] [CN] 非交互模式，跳过手动输入 / [EN] Non-interactive mode, skipping manual input" -ForegroundColor Yellow
    }

    if ($manualPath -and (Test-Path $manualPath)) {
        $exe = Join-Path $manualPath "JMP.exe"
        if (Test-Path $exe) {
            $jmpInstalled = $true
            $jmpPath = $exe
            $jmpVersion = $manualPath -replace ".*JMP\\", ''
            Write-Host "[OK] [CN] 已确认 JMP 路径: $jmpPath" -ForegroundColor Green
            Write-Host "[OK] [EN] JMP path confirmed: $jmpPath" -ForegroundColor Green
        }
    }
}

# 4. 输出配置结果
if ($jmpInstalled) {
    Write-Host "`n[CN] === 配置结果 ===" -ForegroundColor Cyan
    Write-Host "[EN] === Configuration Result ===" -ForegroundColor Cyan
    Write-Host "[CN] JMP 路径: $jmpPath" -ForegroundColor White
    Write-Host "[EN] JMP path: $jmpPath" -ForegroundColor White
    Write-Host "[CN] 版本: $jmpVersion" -ForegroundColor White
    Write-Host "[EN] Version: $jmpVersion" -ForegroundColor White
    
    # 请求用户确认后再修改环境变量
    Write-Host "`n[CN] 即将设置用户环境变量:" -ForegroundColor Yellow
    Write-Host "[EN] About to set environment variables:" -ForegroundColor Yellow
    Write-Host "  STATSOFT_JMP_PATH=$jmpPath" -ForegroundColor Gray

    # L-5: 非交互回退
    $confirm = "Y"
    try {
        $confirm = Read-Host "[CN] 确认设置环境变量? (y/N) / [EN] Confirm setting env vars? (y/N)"
    } catch {
        Write-Host "[!] [CN] 非交互模式，自动应用 / [EN] Non-interactive mode, auto-applying" -ForegroundColor Yellow
    }

    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        [System.Environment]::SetEnvironmentVariable("STATSOFT_JMP_PATH", $jmpPath, "User")
        Write-Host "[OK] [CN] 环境变量已设置 / [EN] Environment variable set" -ForegroundColor Green
    } else {
        Write-Host "[!] [CN] 跳过环境变量设置 / [EN] Skipping env var setup" -ForegroundColor Yellow
    }
    
    # 显示调用示例
    Write-Host "`n[CN] === 调用示例 ===" -ForegroundColor Cyan
    Write-Host "[EN] === Usage Examples ===" -ForegroundColor Cyan
    Write-Host "[CN] 运行 JSL 脚本:" -ForegroundColor White
    Write-Host "[EN] Run JSL script:" -ForegroundColor White
    Write-Host "  `"$jmpPath`" /R `"C:\path\to\script.jsl`""
    Write-Host ""
    Write-Host "[CN] 静默模式:" -ForegroundColor White
    Write-Host "[EN] Silent mode:" -ForegroundColor White
    Write-Host "  `"$jmpPath`" /S /R `"C:\path\to\script.jsl`""
    Write-Host ""
    Write-Host "[CN] COM 自动化 (PowerShell):" -ForegroundColor White
    Write-Host "[EN] COM automation (PowerShell):" -ForegroundColor White
    Write-Host '  $jmp = New-Object -ComObject JMP.Application'
    Write-Host '  $jmp.RunScriptFile("C:\path\to\script.jsl")'
    Write-Host '  $jmp.Quit()'
}
