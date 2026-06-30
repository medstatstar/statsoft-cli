# statsoft-graphpad.ps1 — GraphPad Prism CLI 包装器（高级模式）
# 用法:
#   statsoft-graphpad run <pzfx_file> [--log-file <path>]
#   statsoft-graphpad data-info <pzfx_file> [--vars var1 var2]
#   statsoft-graphpad read-log <log_path>

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "data-info", "read-log")]
    [string]$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args,
    
    [string]$LogFile
)

# 读取配置
$configPath = "$PSScriptRoot\..\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "配置文件不存在: $configPath。请先运行 setup_graphpad.ps1"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$graphPadPath = $config.GraphPad.Path

if (-not (Test-Path $graphPadPath)) {
    Write-Error "GraphPad Prism 可执行文件不存在: $graphPadPath"
    exit 1
}

switch ($Command) {
    "run" {
        $pzfxFile = $Args[0]
        if (-not (Test-Path $pzfxFile)) {
            Write-Error "PZFX 文件不存在: $pzfxFile"
            exit 1
        }
        
        $logPath = if ($LogFile) { $LogFile } else { Join-Path $PWD "graphpad-log.txt" }
        Write-Host "执行 GraphPad Prism 文件: $pzfxFile" -ForegroundColor Cyan
        Write-Host "日志输出: $logPath" -ForegroundColor Cyan
        
        # 执行 GraphPad Prism
        & $graphPadPath $pzfxFile 2>&1 | Tee-Object -FilePath $logPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "GraphPad Prism 执行完成" -ForegroundColor Green
        } else {
            Write-Warning "GraphPad Prism 退出码: $LASTEXITCODE"
        }
    }
    
    "data-info" {
        $pzfxFile = $Args[0]
        if (-not (Test-Path $pzfxFile)) {
            Write-Error "PZFX 文件不存在: $pzfxFile"
            exit 1
        }
        
        # 使用 Python prismWriter 获取数据结构
        $pythonScript = @"
from prismwriter import PrismFile
import json
pf = PrismFile('$pzfxFile')
info = {
    'tables': list(pf.tables.keys()),
    'metadata': pf.metadata
}
print(json.dumps(info, indent=2))
"@
        
        $tempPy = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.py'
        $pythonScript | Set-Content $tempPy -Encoding UTF8
        
        python $tempPy 2>&1
        Remove-Item $tempPy -ErrorAction SilentlyContinue
    }
    
    "read-log" {
        $logPath = $Args[0]
        if (-not (Test-Path $logPath)) {
            Write-Error "日志文件不存在: $logPath"
            exit 1
        }
        
        Get-Content $logPath
    }
}
