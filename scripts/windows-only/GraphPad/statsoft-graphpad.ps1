# statsoft-graphpad.ps1 — GraphPad Prism GUI 辅助工具（仅检测与读取，无 CLI / 无批处理自动化）
# GraphPad Prism 没有 CLI 模式，无法静默批处理。本脚本仅用于：
#   1) 手动启动 GraphPad Prism GUI 打开指定文件（不等待、不驱动分析）
#   2) 只读读取/校验 .pzfx 文件结构（通过 prismwriter Python 库，不启动 GUI）
#   3) 读取用户提供的日志文件
# 用法 / Usage:
#   statsoft-graphpad open <pzfx_file>                    # 手动启动 GUI 打开文件（不自动化）
#   statsoft-graphpad data-info <pzfx_file> [--vars ...]   # 只读读取结构
#   statsoft-graphpad read-log <log_path>                 # 读取日志

param(
    [Parameter(Position=0)]
    [ValidateSet("open", "data-info", "read-log")]
    [string]$Command,

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args,

    [string]$LogFile
)

# 读取配置 / Read config
$configPath = "$PSScriptRoot\..\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "[CN] 配置文件不存在: $configPath。请先运行 setup_graphpad.ps1 / [EN] Config file not found: $configPath. Please run setup_graphpad.ps1 first."
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$graphPadPath = $config.GraphPad.Path

if (-not (Test-Path $graphPadPath)) {
    Write-Error "[CN] GraphPad Prism 可执行文件不存在: $graphPadPath / [EN] GraphPad Prism executable not found: $graphPadPath"
    exit 1
}

switch ($Command) {
    "open" {
        $pzfxFile = $Args[0]
        if ($pzfxFile -and -not (Test-Path $pzfxFile)) {
            Write-Error "[CN] PZFX 文件不存在: $pzfxFile / [EN] PZFX file not found: $pzfxFile"
            exit 1
        }
        Write-Host "[CN] GraphPad Prism 无 CLI 模式，正在手动启动 GUI（不自动化分析）..." -ForegroundColor Cyan
        Write-Host "[EN] GraphPad Prism has no CLI mode; launching GUI manually (no automation)..." -ForegroundColor Cyan
        if ($pzfxFile) {
            Start-Process -FilePath $graphPadPath -ArgumentList $pzfxFile
        } else {
            Start-Process -FilePath $graphPadPath
        }
        Write-Host "[CN] 已打开 GraphPad Prism，请手动操作。/ [EN] GraphPad Prism opened; please operate manually."
    }

    "data-info" {
        $pzfxFile = $Args[0]
        if (-not (Test-Path $pzfxFile)) {
            Write-Error "[CN] PZFX 文件不存在: $pzfxFile / [EN] PZFX file not found: $pzfxFile"
            exit 1
        }

        # Pass the PZFX path as a command-line ARGUMENT to Python (NEVER
        # interpolate it into source) -> no Python code injection via a crafted
        # file path. The temp script is disclosed and removed in a finally block.
        Write-Host "[CN] 创建临时 Python 脚本（仅本次运行，结束后删除）:" -ForegroundColor Gray
        $tempPy = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.py'
        Write-Host "  $tempPy" -ForegroundColor Gray
        $pythonScript = @"
import sys, json
from prismwriter import PrismFile
path = sys.argv[1]
pf = PrismFile(path)
info = {'tables': list(pf.tables.keys()), 'metadata': pf.metadata}
print(json.dumps(info, indent=2))
"@
        try {
            $pythonScript | Set-Content $tempPy -Encoding UTF8
            python $tempPy "$pzfxFile" 2>&1
        } finally {
            Remove-Item $tempPy -ErrorAction SilentlyContinue
        }
    }

    "read-log" {
        $logPath = $Args[0]
        if (-not (Test-Path $logPath)) {
            Write-Error "[CN] 日志文件不存在: $logPath / [EN] Log file not found: $logPath"
            exit 1
        }

        Get-Content $logPath
    }
}
