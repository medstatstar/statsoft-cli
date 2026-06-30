# setup_graphpad.ps1 — GraphPad Prism 检测与配置脚本
# 用法: powershell -ExecutionPolicy Bypass -File setup_graphpad.ps1

Write-Host "=== GraphPad Prism 检测与配置 ===" -ForegroundColor Cyan

# 1. 检测 GraphPad 安装
$graphPadInstalled = $false
$graphPadPath = ""
$graphPadVersion = ""

# 典型安装路径
$commonPaths = @(
    "C:\Program Files\GraphPad\Prism 9",
    "C:\Program Files\GraphPad\Prism 10",
    "C:\Program Files\GraphPad\Prism 8",
    "C:\Program Files\GraphPad\Prism 7",
    "C:\Program Files (x86)\GraphPad\Prism 9",
    "C:\Program Files (x86)\GraphPad\Prism 8",
    "D:\GraphPad\Prism 9",
    "D:\GraphPad\Prism 8"
)

foreach ($dir in $commonPaths) {
    $exe = Join-Path $dir "prism.exe"
    if (Test-Path $exe) {
        $graphPadInstalled = $true
        $graphPadPath = $exe
        $graphPadVersion = ($dir -split 'Prism ')[-1].Trim()
        Write-Host "[OK] 检测到 GraphPad Prism $graphPadVersion : $graphPadPath" -ForegroundColor Green
        break
    }
}

# 2. 如果未找到，尝试注册表
if (-not $graphPadInstalled) {
    Write-Host "[!] 在常见路径未找到 GraphPad，尝试注册表..." -ForegroundColor Yellow
    
    $regPaths = @(
        "HKLM:\SOFTWARE\GraphPad",
        "HKLM:\SOFTWARE\Wow6432Node\GraphPad"
    )
    
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            $graphPadKey = Get-ChildItem $regPath -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($graphPadKey) {
                $installDir = (Get-ItemProperty $graphPadKey.PSPath -ErrorAction SilentlyContinue).InstallLocation
                if ($installDir -and (Test-Path $installDir)) {
                    $exe = Join-Path $installDir "prism.exe"
                    if (Test-Path $exe) {
                        $graphPadInstalled = $true
                        $graphPadPath = $exe
                        $graphPadVersion = ($installDir -split 'Prism ')[-1].Trim()
                        Write-Host "[OK] 从注册表找到 GraphPad : $graphPadPath" -ForegroundColor Green
                        break
                    }
                }
            }
        }
    }
}

# 3. 如果仍未找到，提示用户
if (-not $graphPadInstalled) {
    Write-Host "[!] 未检测到 GraphPad Prism" -ForegroundColor Yellow
    Write-Host "请确认以下信息:" -ForegroundColor Yellow
    Write-Host "  1. GraphPad Prism 是否已安装？"
    Write-Host "  2. 安装路径是什么？"
    
    $manualPath = Read-Host "`n请输入 GraphPad Prism 安装路径（例如 C:\Program Files\GraphPad\Prism\9）"
    
    if ($manualPath -and (Test-Path $manualPath)) {
        $exe = Join-Path $manualPath "prism.exe"
        if (Test-Path $exe) {
            $graphPadInstalled = $true
            $graphPadPath = $exe
            $graphPadVersion = ($manualPath -split 'Prism ')[-1].Trim()
            Write-Host "[OK] 已确认 GraphPad Prism 路径: $graphPadPath" -ForegroundColor Green
        }
    }
}

# 4. 输出配置结果
if ($graphPadInstalled) {
    Write-Host "`n=== 配置结果 ===" -ForegroundColor Cyan
    Write-Host "GraphPad Prism 路径: $graphPadPath"
    Write-Host "版本: $graphPadVersion"
    Write-Host "环境变量: STATSOFT_GRAPHPAD_PATH=$graphPadPath"
    
    # 设置环境变量
    [System.Environment]::SetEnvironmentVariable("STATSOFT_GRAPHPAD_PATH", $graphPadPath, "User")
    
    # 显示调用示例
    Write-Host "`n=== 调用示例 ===" -ForegroundColor Cyan
    Write-Host "打开 .pzfx 文件:"
    Write-Host "  `"$graphPadPath`" `"C:\path\to\file.pzfx`""
    Write-Host ""
    Write-Host "Python 自动化 (prismWriter):"
    Write-Host "  pip install prismwriter"
    Write-Host "  from prismwriter import PrismFile"
    Write-Host "  pf = PrismFile('template.pzfx')"
    Write-Host "  pf.save('output.pzfx')"
}
