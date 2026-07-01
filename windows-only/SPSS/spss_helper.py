#!/usr/bin/env python3
# spss_helper.py — SPSS silent execution helper / SPSS 无闪屏调用辅助脚本
# Preferred: Use SPSS built-in Python spss module (no GUI)
# Backup: Use stats.exe --production (may show splash)
# Usage:
#   spss_helper.py run-internal <sps_file> [stats_python_path]
#   spss_helper.py run-production <spj_file> [stats_exe_path]
#   spss_helper.py version <stats_python_path>
#   spss_helper.py check <sps_file>

import sys
import os
import re
import subprocess

# ============================================================
# Bilingual output / 双语输出
# ============================================================

def log(msg_cn, msg_en):
    """Output bilingual log message"""
    print("[CN] " + msg_cn)
    print("[EN] " + msg_en)

# ============================================================
# Security Validation / 安全验证
# ============================================================

def _validate_python_path(path):
    """Validate SPSS bundled Python path / 验证 SPSS 内置 Python 路径"""
    if not path:
        return None
    real = os.path.realpath(path)
    allowed_parents = [
        r"C:\Program Files\IBM\SPSS",
        r"C:\Program Files (x86)\IBM\SPSS",
    ]
    if not real.lower().endswith("python.exe"):
        return None
    for parent in allowed_parents:
        if real.lower().startswith(os.path.realpath(parent).lower()):
            return real
    return None


def _validate_spss_exe(path):
    """Validate SPSS executable path / 验证 SPSS 可执行文件路径"""
    if not path:
        return None
    real = os.path.realpath(path)
    allowed_names = ["stats.exe", "spss.exe"]
    basename = os.path.basename(real).lower()
    if basename not in allowed_names:
        return None
    allowed_parents = [
        r"C:\Program Files\IBM\SPSS",
        r"C:\Program Files (x86)\IBM\SPSS",
    ]
    for parent in allowed_parents:
        if real.lower().startswith(os.path.realpath(parent).lower()):
            return real
    return None


def _safe_wrapper_path(script_dir):
    """Generate safe wrapper script path (prevent traversal) / 生成安全包装脚本路径"""
    real_dir = os.path.realpath(script_dir)
    wrapper = os.path.join(real_dir, "_spss_runner.py")
    if not os.path.realpath(wrapper).startswith(real_dir):
        return None
    return wrapper


# ============================================================
# 原有功能
# ============================================================

def run_internal(sps_file, stats_python_path=None):
    """Preferred: Run syntax via SPSS built-in Python (no GUI) / 首选方式：内置 Python 无 GUI 运行"""
    if not os.path.exists(sps_file):
        log("语法文件不存在: " + sps_file, "Syntax file not found: " + sps_file)
        return 1
    
    # Auto-detect SPSS built-in Python
    if stats_python_path is None:
        candidates = [
            r"C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\27\Python3\python.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\28\Python3\python.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\29\Python3\python.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\30\Python3\python.exe",
        ]
        for c in candidates:
            if os.path.exists(c):
                stats_python_path = c
                break
        if stats_python_path is None:
            log("找不到 SPSS 内置 Python，请手动指定路径", "SPSS bundled Python not found, please specify path manually")
            return 1
    
    # Whitelist validation
    validated_python = _validate_python_path(stats_python_path)
    if validated_python is None:
        log("SPSS 内置 Python 路径未通过安全验证", "SPSS bundled Python path failed security validation")
        log("路径必须在 IBM SPSS 安装目录内，且文件名为 python.exe", "Path must be within IBM SPSS install dir with filename python.exe")
        return 1
    stats_python_path = validated_python
    
    if not os.path.exists(stats_python_path):
        log("SPSS 内置 Python 不存在: " + stats_python_path, "SPSS bundled Python not found: " + stats_python_path)
        return 1
    
    with open(sps_file, "r", encoding="utf-8", errors="replace") as f:
        syntax = f.read()
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    wrapper_script = _safe_wrapper_path(script_dir)
    if wrapper_script is None:
        log("无法创建安全的包装脚本路径", "Cannot create safe wrapper script path")
        return 1
    
    with open(wrapper_script, "w", encoding="utf-8") as f:
        f.write("# -*- coding: utf-8 -*-\n")
        f.write("import sys\n")
        f.write("import os\n")
        f.write("\n")
        f.write("# 添加 SPSS Python 包路径\n")
        f.write("spss_pkg = r\"" + os.path.dirname(stats_python_path).replace("\\", "\\\\") + "\\Lib\\site-packages\"\n")
        f.write("if spss_pkg not in sys.path:\n")
        f.write("    sys.path.insert(0, spss_pkg)\n")
        f.write("\n")
        f.write("# 添加 SPSS bin 路径（DLL 依赖）\n")
        f.write("spss_bin = r\"" + os.path.dirname(stats_python_path).replace("\\", "\\\\") + "\"\n")
        f.write("os.environ[\"PATH\"] = spss_bin + \";\" + os.environ.get(\"PATH\", \"\")\n")
        f.write("\n")
        f.write("try:\n")
        f.write("    import spss\n")
        f.write("    print(\"SPSS Python 模块加载成功\")\n")
        f.write("    # SPSS 26: GetSPSSVersion 不存在，使用 __version__\n")
        f.write("    _ver = getattr(spss, '__version__', None) or getattr(spss, 'GetSPSSVersion', '未知')\n")
        f.write("    if callable(_ver):\n")
        f.write("        print(\"SPSS 版本: \" + _ver())\n")
        f.write("    else:\n")
        f.write("        print(\"SPSS 版本: \" + _ver)\n")
        f.write("except Exception as e:\n")
        f.write("    print(\"ERROR: 无法加载 SPSS 模块: \" + str(e))\n")
        f.write("    sys.exit(1)\n")
        f.write("\n")
        f.write("try:\n")
        f.write("    spss.StartSPSS()\n")
        f.write("    print(\"SPSS 处理器已启动（无 GUI，无闪屏）\")\n")
        f.write("    \n")
        f.write("    # 提交语法\n")
        f.write("    syntax = r\"\"\"" + syntax.replace("\\", "\\\\").replace("\"\"\"", "\"\"\"") + "\"\"\"\n")
        f.write("    spss.Submit(syntax)\n")
        f.write("    print(\"语法执行完成\")\n")
        f.write("    \n")
        f.write("    spss.StopSPSS()\n")
        f.write("    print(\"SPSS 处理器已停止\")\n")
        f.write("    sys.exit(0)\n")
        f.write("    \n")
        f.write("except Exception as e:\n")
        f.write("    print(\"ERROR: 语法执行失败: \" + str(e))\n")
        f.write("    import traceback\n")
        f.write("    traceback.print_exc()\n")
        f.write("    try:\n")
        f.write("        spss.StopSPSS()\n")
        f.write("    except:\n")
        f.write("        pass\n")
        f.write("    sys.exit(1)\n")
    
    log("正在通过 SPSS 内置 Python 运行语法（完全无 GUI）...", "Running syntax via SPSS bundled Python (no GUI)...")
    log("语法文件: " + sps_file, "Syntax file: " + sps_file)
    
    try:
        # 使用 CREATE_NO_WINDOW 调用内置 Python
        CREATE_NO_WINDOW = 0x08000000
        result = subprocess.run(
            [stats_python_path, wrapper_script],
            capture_output=True,
            creationflags=CREATE_NO_WINDOW,
            timeout=300
        )
        # 输出结果
        if result.stdout:
            print(result.stdout.decode("cp1252", errors="replace"))
        if result.stderr:
            print("ERROR OUTPUT:")
            print(result.stderr.decode("cp1252", errors="replace"))
        
        # 清理临时脚本
        try:
            os.remove(wrapper_script)
        except:
            pass
            
        return result.returncode
    except Exception as e:
        print("ERROR: " + str(e))
        return 1

def run_production(spj_file, stats_exe=None):
    """Backup: Run .spj via Production Facility (may show splash) / 备用方式：Production Facility 运行"""
    if not os.path.exists(spj_file):
        log(".spj 文件不存在: " + spj_file, ".spj file not found: " + spj_file)
        return 1
    if stats_exe is None:
        candidates = [
            r"C:\Program Files\IBM\SPSS\Statistics\26\stats.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\27\stats.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\28\stats.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\29\stats.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\30\stats.exe",
        ]
        for c in candidates:
            if os.path.exists(c):
                stats_exe = c
                break
        if stats_exe is None:
            log("找不到 stats.exe，请手动指定路径", "stats.exe not found, please specify path")
            return 1
    validated_exe = _validate_spss_exe(stats_exe)
    if validated_exe is None:
        log("stats.exe 路径未通过安全验证", "stats.exe path failed security validation")
        return 1
    stats_exe = validated_exe
    if not os.path.exists(stats_exe):
        log("stats.exe 不存在: " + stats_exe, "stats.exe not found: " + stats_exe)
        return 1
    cmd = [stats_exe, "--production", spj_file]
    log("Stats.exe: " + stats_exe, "Stats.exe: " + stats_exe)
    log(".spj file: " + spj_file, ".spj file: " + spj_file)
    log("调用 SPSS Production Facility...", "Invoking SPSS Production Facility...")
    log("WARNING: 此方式可能有闪屏", "WARNING: This method may show splash screen")
    try:
        CREATE_NO_WINDOW = 0x08000000
        result = subprocess.run(cmd, capture_output=True, creationflags=CREATE_NO_WINDOW, timeout=300)
        stdout = result.stdout.decode("cp1252", errors="replace") if result.stdout else ""
        stderr = result.stderr.decode("cp1252", errors="replace") if result.stderr else ""
        if stdout:
            log("--- SPSS 标准输出 ---", "--- SPSS Standard Output ---")
            print(stdout)
        if stderr:
            log("--- SPSS 错误输出 ---", "--- SPSS Error Output ---")
            print(stderr)
        log("退出码: " + str(result.returncode), "Exit code: " + str(result.returncode))
        return result.returncode
    except Exception as e:
        log("执行失败: " + str(e), "Execution failed: " + str(e))
        return 1

def check_sps(sps_file):
    """Check .sps file existence and preview / 检查 .sps 文件存在及预览"""
    if not os.path.exists(sps_file):
        log(".sps 文件不存在: " + sps_file, ".sps file not found: " + sps_file)
        return 1
    with open(sps_file, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()
    log(".sps 文件: " + sps_file, ".sps file: " + sps_file)
    log("行数: " + str(len(content.splitlines())), "Lines: " + str(len(content.splitlines())))
    log("--- 前 10 行预览 ---", "--- First 10 lines preview ---")
    for i, line in enumerate(content.splitlines()[:10], 1):
        print("  " + str(i) + ": " + line)
    return 0

def show_version(stats_python_path):
    """Show SPSS version / 显示 SPSS 版本"""
    validated = _validate_python_path(stats_python_path)
    if validated is None:
        log("Python 路径未通过安全验证", "Python path failed security validation")
        return 1
    stats_python_path = validated
    if not os.path.exists(stats_python_path):
        log("SPSS 内置 Python 不存在: " + stats_python_path, "SPSS bundled Python not found: " + stats_python_path)
        return 1
    try:
        CREATE_NO_WINDOW = 0x08000000
        # SPSS 26: GetSPSSVersion 不存在，使用 __version__ 常量
        result = subprocess.run(
            [stats_python_path, "-c", "import spss; print(getattr(spss,'__version__','unknown'))"],
            capture_output=True, creationflags=CREATE_NO_WINDOW, timeout=30
        )
        stdout = result.stdout.decode("cp1252", errors="replace") if result.stdout else ""
        print(stdout)
        return 0
    except Exception as e:
        log("版本获取失败: " + str(e), "Version retrieval failed: " + str(e))
        return 1

def main():
    if len(sys.argv) < 2:
        log("用法:", "Usage:")
        log("  run-internal <sps_file>  # 首选：无 GUI", "  run-internal <sps_file>  # Preferred: no GUI")
        log("  run-production <spj_file>  # 备用：可能有闪屏", "  run-production <spj_file>  # Backup: may show splash")
        log("  check <sps_file>", "  check <sps_file>")
        log("  version [stats_python_path]", "  version [stats_python_path]")
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "run-internal":
        sps_file = sys.argv[2] if len(sys.argv) > 2 else None
        stats_python_path = sys.argv[3] if len(sys.argv) > 3 else None
        if sps_file is None:
            log("请提供 .sps 文件路径", "Please provide .sps file path")
            sys.exit(1)
        sys.exit(run_internal(sps_file, stats_python_path))
    elif cmd == "run-production":
        spj_file = sys.argv[2] if len(sys.argv) > 2 else None
        stats_exe = sys.argv[3] if len(sys.argv) > 3 else None
        if spj_file is None:
            log("请提供 .spj 文件路径", "Please provide .spj file path")
            sys.exit(1)
        sys.exit(run_production(spj_file, stats_exe))
    elif cmd == "check":
        sps_file = sys.argv[2] if len(sys.argv) > 2 else None
        if sps_file is None:
            log("请提供 .sps 文件路径", "Please provide .sps file path")
            sys.exit(1)
        sys.exit(check_sps(sps_file))
    elif cmd == "version":
        stats_python_path = sys.argv[2] if len(sys.argv) > 2 else None
        sys.exit(show_version(stats_python_path))
    else:
        log("未知命令: " + cmd, "Unknown command: " + cmd)
        sys.exit(1)

if __name__ == "__main__":
    main()
