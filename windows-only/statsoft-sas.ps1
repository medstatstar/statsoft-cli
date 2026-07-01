# statsoft-sas.ps1 — SAS CLI 包装器（高级模式）
# 用法:
#   statsoft-sas run <sas_file> [--log-file <path>]
#   statsoft-sas data-info <sas_file> [--vars var1 var2]
#   statsoft-sas read-log <log_path>

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
    Write-Error "[CN] 配置文件不存在: $configPath。请先运行 setup_sas.ps1 / [EN] Config file not found: $configPath. Please run setup_sas.ps1 first."
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$sasPath = $config.SAS.Path

if (-not (Test-Path $sasPath)) {
    Write-Error "[CN] SAS 可执行文件不存在: $sasPath / [EN] SAS executable not found: $sasPath"
    exit 1
}

switch ($Command) {
    "run" {
        $sasFile = $Args[0]
        if (-not (Test-Path $sasFile)) {
            Write-Error "[CN] SAS 程序不存在: $sasFile / [EN] SAS program not found: $sasFile"
            exit 1
        }
        
        $logPath = if ($LogFile) { $LogFile } else { Join-Path $PWD "sas-log.log" }
        $printPath = if ($LogFile) { $LogFile -replace '\.log$', '.lst' } else { Join-Path $PWD "sas-output.lst" }
        
        Write-Host "[CN] 执行 SAS 程序: $sasFile" -ForegroundColor Cyan
        Write-Host "[EN] Executing SAS program: $sasFile" -ForegroundColor Cyan
        Write-Host "[CN] 日志输出: $logPath" -ForegroundColor Gray
        Write-Host "[EN] Log output: $logPath" -ForegroundColor Gray
        
        # 执行 SAS 批处理
        & $sasPath -batch -nosplash -sysin $sasFile -log $logPath -print $printPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[CN] SAS 执行完成" -ForegroundColor Green
            Write-Host "[EN] SAS execution complete" -ForegroundColor Green
        } else {
            Write-Warning "[CN] SAS 退出码: $LASTEXITCODE"
            Write-Warning "[EN] SAS exit code: $LASTEXITCODE"
        }
    }
    
    "data-info" {
        $sasFile = $Args[0]
        if (-not (Test-Path $sasFile)) {
            Write-Error "[CN] SAS 程序不存在: $sasFile / [EN] SAS program not found: $sasFile"
            exit 1
        }
        
        # 生成临时 SAS 代码获取数据结构
        $tempSas = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.sas'
        @"
proc contents data=sashelp.class;
run;
"@ | Set-Content $tempSas -Encoding UTF8
        
        & $sasPath -batch -nosplash -sysin $tempSas 2>&1
        Remove-Item $tempSas -ErrorAction SilentlyContinue
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
