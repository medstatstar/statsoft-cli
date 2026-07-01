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
    Write-Error "[CN] 配置文件不存在: $configPath。请先运行 setup_r.ps1 / [EN] Config file not found: $configPath. Please run setup_r.ps1 first."
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$rPath = $config.R.Path

if (-not (Test-Path $rPath)) {
    Write-Error "[CN] Rscript.exe 不存在: $rPath / [EN] Rscript.exe not found: $rPath"
    exit 1
}

switch ($Command) {
    "run" {
        $rFile = $Args[0]
        if (-not (Test-Path $rFile)) {
            Write-Error "[CN] R 脚本不存在: $rFile / [EN] R script not found: $rFile"
            exit 1
        }
        
        $logPath = if ($LogFile) { $LogFile } else { Join-Path $PWD "r-log.txt" }
        Write-Host "[CN] 执行 R 脚本: $rFile" -ForegroundColor Cyan
        Write-Host "[EN] Executing R script: $rFile" -ForegroundColor Cyan
        Write-Host "[CN] 日志输出: $logPath" -ForegroundColor Gray
        Write-Host "[EN] Log output: $logPath" -ForegroundColor Gray
        
        & $rPath $rFile 2>&1 | Tee-Object -FilePath $logPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[CN] R 执行完成" -ForegroundColor Green
            Write-Host "[EN] R execution complete" -ForegroundColor Green
        } else {
            Write-Warning "[CN] R 退出码: $LASTEXITCODE"
            Write-Warning "[EN] R exit code: $LASTEXITCODE"
        }
    }
    
    "install" {
        $package = $Args[0]
        Write-Host "[CN] 准备安装 R 包: $package" -ForegroundColor Cyan
        Write-Host "[EN] Preparing to install R package: $package" -ForegroundColor Cyan
        Write-Host "[CN] 来源: $Repo" -ForegroundColor Gray
        Write-Host "[EN] Repository: $Repo" -ForegroundColor Gray

        # L-5: 非交互回退 — Read-Host 带超时
        $confirm = "N"
        try {
            $confirm = Read-Host "[CN] 确认从 $Repo 安装 R 包 '$package'? (y/N) / [EN] Confirm installing R package '$package' from $Repo? (y/N)"
        } catch {
            Write-Host "[!] [CN] 非交互模式，默认跳过安装 / [EN] Non-interactive mode, defaulting to skip" -ForegroundColor Yellow
        }

        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host "[!] [CN] 已取消安装 / [EN] Installation cancelled" -ForegroundColor Yellow
            return
        }

        # 静默安装，无需确认
        & $rPath -e "install.packages('$package', repos='$Repo', quiet=TRUE)" 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "[CN] 包 '$package' 安装完成" -ForegroundColor Green
            Write-Host "[EN] Package '$package' installed successfully" -ForegroundColor Green
        } else {
            Write-Warning "[CN] CRAN 安装失败，尝试 Bioconductor... / [EN] CRAN install failed, trying Bioconductor..."
            $biocConfirm = "Y"
            try {
                $biocConfirm = Read-Host "[CN] 是否尝试从 Bioconductor 安装? (y/N) / [EN] Try installing from Bioconductor? (y/N)"
            } catch {
                Write-Host "[!] [CN] 非交互模式，自动尝试 Bioconductor / [EN] Non-interactive mode, auto-trying Bioconductor" -ForegroundColor Yellow
            }

            if ($biocConfirm -eq 'y' -or $biocConfirm -eq 'Y') {
                & $rPath -e "if (!require('BiocManager', quietly=TRUE)) install.packages('BiocManager', quiet=TRUE); BiocManager::install('$package', ask=FALSE, update=FALSE)" 2>&1
            }
        }
    }
    
    "data-info" {
        $dataFile = $Args[0]
        if (-not (Test-Path $dataFile)) {
            Write-Error "[CN] 数据文件不存在: $dataFile / [EN] Data file not found: $dataFile"
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
                Write-Host "⚠️  [CN] Stata (.dta) 文件需要 haven 包 / [EN] Stata (.dta) file requires haven package" -ForegroundColor Yellow

                # L-5: 非交互回退
                $confirm = "Y"
                try {
                    $confirm = Read-Host "[CN] 确认继续? (y/N) / [EN] Continue? (y/N)"
                } catch {
                    Write-Host "[!] [CN] 非交互模式，自动继续 / [EN] Non-interactive mode, auto-continuing" -ForegroundColor Yellow
                }

                if ($confirm -ne 'y' -and $confirm -ne 'Y') { return }
                & $rPath -e "if (!require('haven', quietly=TRUE)) install.packages('haven'); df <- haven::read_dta('$dataFile'); cat('Rows:', nrow(df), '\nCols:', ncol(df), '\n'); print(names(df)); print(summary(df))" 2>&1
            }
            ".sav" {
                Write-Host "⚠️  [CN] SPSS (.sav) 文件需要 haven 包 / [EN] SPSS (.sav) file requires haven package" -ForegroundColor Yellow

                # L-5: 非交互回退
                $confirm = "Y"
                try {
                    $confirm = Read-Host "[CN] 确认继续? (y/N) / [EN] Continue? (y/N)"
                } catch {
                    Write-Host "[!] [CN] 非交互模式，自动继续 / [EN] Non-interactive mode, auto-continuing" -ForegroundColor Yellow
                }

                if ($confirm -ne 'y' -and $confirm -ne 'Y') { return }
                & $rPath -e "if (!require('haven', quietly=TRUE)) install.packages('haven'); df <- haven::read_sav('$dataFile'); cat('Rows:', nrow(df), '\nCols:', ncol(df), '\n'); print(names(df)); print(summary(df))" 2>&1
            }
            default {
                Write-Warning "[CN] 不支持的文件格式: $ext / [EN] Unsupported file format: $ext"
            }
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
