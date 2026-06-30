# setup_jmp.ps1 — JMP 检测与配置脚本
# 用法: powershell -ExecutionPolicy Bypass -File setup_jmp.ps1

Write-Host "=== JMP 检测与配置 ===" -ForegroundColor Cyan

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
        Write-Host "[OK] 检测到 JMP $jmpVersion : $jmpPath" -ForegroundColor Green
        break
    }
}

# 2. 如果未找到，尝试注册表
if (-not $jmpInstalled) {
    Write-Host "[!] 在常见路径未找到 JMP，尝试注册表..." -ForegroundColor Yellow
    
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
                        Write-Host "[OK] 从注册表找到 JMP : $jmpPath" -ForegroundColor Green
                        break
                    }
                }
            }
        }
    }
}

# 3. 如果仍未找到，提示用户
if (-not $jmpInstalled) {
    Write-Host "[!] 未检测到 JMP" -ForegroundColor Yellow
    Write-Host "请确认以下信息:" -ForegroundColor Yellow
    Write-Host "  1. JMP 是否已安装？"
    Write-Host "  2. 安装路径是什么？"
    
    $manualPath = Read-Host "`n请输入 JMP 安装路径（例如 C:\Program Files\JMP\16）"
    
    if ($manualPath -and (Test-Path $manualPath)) {
        $exe = Join-Path $manualPath "JMP.exe"
        if (Test-Path $exe) {
            $jmpInstalled = $true
            $jmpPath = $exe
            $jmpVersion = $manualPath -replace ".*JMP\\", ''
            Write-Host "[OK] 已确认 JMP 路径: $jmpPath" -ForegroundColor Green
        }
    }
}

# 4. 输出配置结果
if ($jmpInstalled) {
    Write-Host "`n=== 配置结果 ===" -ForegroundColor Cyan
    Write-Host "JMP 路径: $jmpPath"
    Write-Host "版本: $jmpVersion"
    Write-Host "环境变量: STATSOFT_JMP_PATH=$jmpPath"
    
    # 设置环境变量
    [System.Environment]::SetEnvironmentVariable("STATSOFT_JMP_PATH", $jmpPath, "User")
    
    # 显示调用示例
    Write-Host "`n=== 调用示例 ===" -ForegroundColor Cyan
    Write-Host "运行 JSL 脚本:"
    Write-Host "  `"$jmpPath`" /R `"C:\path\to\script.jsl`""
    Write-Host ""
    Write-Host "静默模式:"
    Write-Host "  `"$jmpPath`" /S /R `"C:\path\to\script.jsl`""
    Write-Host ""
    Write-Host "COM 自动化 (PowerShell):"
    Write-Host '  $jmp = New-Object -ComObject JMP.Application'
    Write-Host '  $jmp.RunScriptFile("C:\path\to\script.jsl")'
    Write-Host '  $jmp.Quit()'
}
