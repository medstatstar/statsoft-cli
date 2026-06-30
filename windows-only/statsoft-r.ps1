# statsoft-r.ps1 — R CLI 包装器（高级模式）
# 用法:
#   statsoft-r run <r_file> [--log-file <path>]
#   statsoft-r install <package> [--repo <url>]
#   statsoft-r data-info <data_file> [--vars var1 var2]
#   statsoft-r read-log <log_path>

param(
    [Parameter(Position=0)]
    [ValidateSet("run", "install", "data-info", "read-log")]
    [string]$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Args,
    
    [string]$LogFile,
    [string]$Repo = "https://cran.r-project.org"
)

# 读取配置
$configPath = "$PSScriptRoot\..\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "配置文件不存在: $configPath。请先运行 setup_r.ps1"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$rPath = $config.R.Path

if (-not (Test-Path $rPath)) {
    Write-Error "Rscript.exe 不存在: $rPath"
    exit 1
}

switch ($Command) {
    "run" {
        $rFile = $Args[0]
        if (-not (Test-Path $rFile)) {
            Write-Error "R 脚本不存在: $rFile"
            exit 1
        }
        
        $logPath = if ($LogFile) { $LogFile } else { Join-Path $PWD "r-log.txt" }
        Write-Host "执行 R 脚本: $rFile" -ForegroundColor Cyan
        Write-Host "日志输出: $logPath" -ForegroundColor Cyan
        
        & $rPath $rFile 2>&1 | Tee-Object -FilePath $logPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "R 执行完成" -ForegroundColor Green
        } else {
            Write-Warning "R 退出码: $LASTEXITCODE"
        }
    }
    
    "install" {
        $package = $Args[0]
        Write-Host "静默安装 R 包: $package" -ForegroundColor Cyan
        
        # 静默安装，无需确认
        & $rPath -e "install.packages('$package', repos='$Repo', quiet=TRUE)" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "包 $package 安装完成" -ForegroundColor Green
        } else {
            Write-Warning "CRAN 安装失败，尝试 Bioconductor..."
            & $rPath -e "if (!require('BiocManager', quietly=TRUE)) install.packages('BiocManager', quiet=TRUE); BiocManager::install('$package', ask=FALSE, update=FALSE)" 2>&1
        }
    }
    
    "data-info" {
        $dataFile = $Args[0]
        if (-not (Test-Path $dataFile)) {
            Write-Error "数据文件不存在: $dataFile"
            exit 1
        }
        
        $ext = [System.IO.Path]::GetExtension($dataFile).ToLower()
        
        switch ($ext) {
            ".csv" {
                & $rPath -e "df <- read.csv('$dataFile', nrows=10); cat('Rows:', nrow(df), '\nCols:', ncol(df), '\n'); print(names(df)); print(summary(df))" 2>&1
            }
            ".rds" {
                & $rPath -e "df <- readRDS('$dataFile'); cat('Dimensions:', dim(df), '\n'); print(names(df)); print(head(df))" 2>&1
            }
            ".dta" {
                & $rPath -e "if (!require('haven', quietly=TRUE)) install.packages('haven'); df <- haven::read_dta('$dataFile'); cat('Rows:', nrow(df), '\nCols:', ncol(df), '\n'); print(names(df)); print(summary(df))" 2>&1
            }
            ".sav" {
                & $rPath -e "if (!require('haven', quietly=TRUE)) install.packages('haven'); df <- haven::read_sav('$dataFile'); cat('Rows:', nrow(df), '\nCols:', ncol(df), '\n'); print(names(df)); print(summary(df))" 2>&1
            }
            default {
                Write-Warning "不支持的文件格式: $ext"
            }
        }
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
