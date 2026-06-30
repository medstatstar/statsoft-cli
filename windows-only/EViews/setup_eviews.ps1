# setup_eviews.ps1 - EViews 统计软件环境检测与配置脚本
# EViews: 计量经济学软件，Windows-only，有批处理模式

Write-Host "=== EViews 环境检测 / EViews Environment Detection ==="
Write-Host "平台 / Platform: Windows"
Write-Host ""

# 检测 EViews 是否安装
function Detect-EViews {
    $eviews_path = ""
    
    # 检查常见安装路径
    $paths = @(
        "C:\Program Files\EViews\EViews 13\EViews64.exe",
        "C:\Program Files\EViews\EViews 12\EViews64.exe",
        "C:\Program Files\EViews\EViews 11\EViews64.exe",
        "C:\Program Files (x86)\EViews\EViews 10\EViews.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $eviews_path = $path
            break
        }
    }
    
    # 检查 PATH
    if (-not $eviews_path) {
        $eviews_path = (Get-Command EViews64 -ErrorAction SilentlyContinue).Source
        if (-not $eviews_path) {
            $eviews_path = (Get-Command EViews -ErrorAction SilentlyContinue).Source
        }
    }
    
    return $eviews_path
}

# 主流程
$eviews_path = Detect-EViews

if ($eviews_path) {
    Write-Host "✅ 检测到 EViews 安装 / EViews installation detected:"
    Write-Host "  路径 / Path: $eviews_path"
    
    # 输出配置信息（供 AI Agent 读取）
    Write-Host ""
    Write-Host "=== 配置信息 / Configuration Info ==="
    Write-Host "EVIEWS_PATH=$eviews_path"
    Write-Host "EVIEWS_OS=windows"
    
    # 输出使用说明
    Write-Host ""
    Write-Host "=== 使用说明 / Usage Instructions ==="
    Write-Host "批处理命令 / Batch command:"
    Write-Host "  & '$eviews_path' /run script.prg"
    Write-Host ""
    Write-Host "脚本示例 / Script example:"
    Write-Host "  ' script.prg"
    Write-Host "  read(r) data.csv"
    Write-Host "  equation eq1.ls y c x1 x2"
    Write-Host "  eq1.output(table) results.csv"
    Write-Host ""
    Write-Host "⚠️ 注意事项 / Notes:"
    Write-Host "  - EViews 运行时可能有闪屏（GUI 程序）"
    Write-Host "  - 脚本末尾加 'exit' 命令可自动退出 EViews"
    
} else {
    Write-Host "❌ 未检测到 EViews 安装 / EViews installation not found"
    Write-Host ""
    Write-Host "=== 安装指南 / Installation Guide ==="
    Write-Host "Windows 安装步骤 / Windows installation steps:"
    Write-Host "  1. 访问 EViews 官网: https://www.eviews.com/"
    Write-Host "  2. 下载 EViews 试用版或输入许可证"
    Write-Host "  3. 运行安装程序，按默认设置安装"
    Write-Host "  4. 安装完成后，EViews64.exe 通常在 C:\Program Files\EViews\EViews XX\"
}
