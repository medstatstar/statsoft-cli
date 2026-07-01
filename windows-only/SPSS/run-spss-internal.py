#!/usr/bin/env python3
# run-spss-internal.py — Run SPSS syntax via SPSS built-in Python (no GUI)
# Usage: "C:\Program Files\IBM\SPSS\Statistics\XX\Python3\python.exe" run-spss-internal.py <sps_file>
# Note: Auto-detects SPSS installation directory; later paths may include specific version directories

import sys
import os

# Output bilingual helper
def log(msg_cn, msg_en=None):
    if msg_en is None:
        msg_en = msg_cn
    print("[CN] " + msg_cn + "\n[EN] " + msg_en)

def _find_spss_home():
    """Auto-detect SPSS installation directory"""
    candidates = [
        r"C:\Program Files\IBM\SPSS\Statistics\31",
        r"C:\Program Files\IBM\SPSS\Statistics\30",
        r"C:\Program Files\IBM\SPSS\Statistics\29",
        r"C:\Program Files\IBM\SPSS\Statistics\28",
        r"C:\Program Files\IBM\SPSS\Statistics\27",
        r"C:\Program Files\IBM\SPSS\Statistics\26",
        r"C:\Program Files (x86)\IBM\SPSS\Statistics\26",
    ]
    for c in candidates:
        if os.path.isdir(c):
            python_exe = os.path.join(c, "Python3", "python.exe")
            if os.path.isfile(python_exe):
                return c, python_exe
    return None, None

# Auto-detect SPSS home
spss_home, stats_python_path = _find_spss_home()
if spss_home is None:
    log("未检测到 SPSS Statistics 安装", "SPSS Statistics installation not detected")
    log("请确认 SPSS 已正确安装", "Please verify SPSS is correctly installed")
    sys.exit(1)

# Validate path security
allowed_parents = [
    r"C:\Program Files\IBM\SPSS",
    r"C:\Program Files (x86)\IBM\SPSS",
    r"C:\Program Files\IBM\SPSS30",
]
if not any(os.path.realpath(spss_home).lower().startswith(os.path.realpath(p).lower()) for p in allowed_parents):
    log("SPSS 路径不在预期的安装目录内", "SPSS path is not within the expected installation directory")
    sys.exit(1)

# Add SPSS Python package path
spss_pkg = os.path.join(spss_home, "Python3", "Lib", "site-packages")
if spss_pkg not in sys.path:
    sys.path.insert(0, spss_pkg)

# Add SPSS bin path (DLL dependencies)
os.environ["PATH"] = spss_home + ";" + os.environ.get("PATH", "")

log("SPSS 安装目录: " + spss_home, "SPSS install dir: " + spss_home)
log("内置 Python:   " + stats_python_path, "Built-in Python: " + stats_python_path)

try:
    import spss
    log("SPSS Python 模块加载成功", "SPSS Python module loaded successfully")
except Exception as e:
    log("无法加载 SPSS 模块: " + str(e), "Failed to load SPSS module: " + str(e))
    sys.exit(1)

def run_syntax(sps_file):
    """Run syntax file via spss.Submit() (no GUI)"""
    if not os.path.exists(sps_file):
        log("语法文件不存在: " + sps_file, "Syntax file not found: " + sps_file)
        return 1
    
    with open(sps_file, "r", encoding="utf-8", errors="replace") as f:
        syntax = f.read()
    
    log("正在运行语法文件: " + sps_file, "Running syntax file: " + sps_file)
    log("语法行数: " + str(len(syntax.splitlines())), "Syntax lines: " + str(len(syntax.splitlines())))
    
    try:
        spss.StartSPSS()
        log("SPSS 处理器已启动（无 GUI，无闪屏）", "SPSS processor started (no GUI, no splash)")
        
        spss.Submit(syntax)
        log("语法执行完成", "Syntax execution complete")
        
        spss.StopSPSS()
        log("SPSS 处理器已停止", "SPSS processor stopped")
        return 0
        
    except Exception as e:
        log("语法执行失败: " + str(e), "Syntax execution failed: " + str(e))
        import traceback
        traceback.print_exc()
        try:
            spss.StopSPSS()
        except:
            pass
        return 1

if __name__ == "__main__":
    if len(sys.argv) < 2:
        log("用法: python.exe run-spss-internal.py <sps_file>", "Usage: python.exe run-spss-internal.py <sps_file>")
        sys.exit(1)
    
    sps_file = sys.argv[1]
    rc = run_syntax(sps_file)
    sys.exit(rc)
