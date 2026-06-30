#!/usr/bin/env python3
# run-spss-internal.py — 使用 SPSS 内置 Python 直接运行语法（无 GUI）
# 用法: "C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe" run-spss-internal.py <sps_file>

import sys
import os

# 添加 SPSS Python 包路径
spss_pkg = r"C:\Program Files\IBM\SPSS\Statistics\26\Python3\Lib\site-packages"
if spss_pkg not in sys.path:
    sys.path.insert(0, spss_pkg)

# 添加 SPSS bin 路径（DLL 依赖）
spss_bin = r"C:\Program Files\IBM\SPSS\Statistics\26"
os.environ["PATH"] = spss_bin + ";" + os.environ.get("PATH", "")

try:
    import spss
    print("SPSS Python 模块加载成功")
except Exception as e:
    print("ERROR: 无法加载 SPSS 模块: " + str(e))
    sys.exit(1)

def run_syntax(sps_file):
    """通过 spss.Submit() 运行语法文件（无 GUI）"""
    if not os.path.exists(sps_file):
        print("ERROR: 语法文件不存在: " + sps_file)
        return 1
    
    with open(sps_file, "r", encoding="utf-8", errors="replace") as f:
        syntax = f.read()
    
    print("正在运行语法文件: " + sps_file)
    print("语法行数: " + str(len(syntax.splitlines())))
    
    try:
        # 启动 SPSS 处理器（不显示 GUI）
        spss.StartSPSS()
        print("SPSS 处理器已启动（无 GUI，无闪屏）")
        
        # 提交语法
        spss.Submit(syntax)
        print("语法执行完成")
        
        # 停止 SPSS 处理器
        spss.StopSPSS()
        print("SPSS 处理器已停止")
        return 0
        
    except Exception as e:
        print("ERROR: 语法执行失败: " + str(e))
        import traceback
        traceback.print_exc()
        try:
            spss.StopSPSS()
        except:
            pass
        return 1

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python.exe run-spss-internal.py <sps_file>")
        sys.exit(1)
    
    sps_file = sys.argv[1]
    rc = run_syntax(sps_file)
    sys.exit(rc)
