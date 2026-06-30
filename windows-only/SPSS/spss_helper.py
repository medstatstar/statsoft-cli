#!/usr/bin/env python3
# spss_helper.py — SPSS 无闪屏调用辅助脚本
# 首选方式：使用 SPSS 内置 Python 的 spss 模块（完全无 GUI）
# 备用方式：通过 stats.exe --production 调用（可能有闪屏）
# 用法:
#   spss_helper.py run-internal <sps_file> [stats_python_path]
#   spss_helper.py run-production <spj_file> [stats_exe_path]
#   spss_helper.py version <stats_python_path>
#   spss_helper.py check <sps_file>

import sys
import os

def run_internal(sps_file, stats_python_path=None):
    """首选方式：通过 SPSS 内置 Python 的 spss 模块运行语法（完全无 GUI）"""
    if not os.path.exists(sps_file):
        print("ERROR: 语法文件不存在: " + sps_file)
        return 1
    
    # 自动查找 SPSS 内置 Python
    if stats_python_path is None:
        candidates = [
            r"C:\Program Files\IBM\SPSS\Statistics\26\Python3\python.exe",
            r"C:\Program Files\IBM\SPSS30\Python3\python.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\29\Python3\python.exe",
        ]
        for c in candidates:
            if os.path.exists(c):
                stats_python_path = c
                break
        if stats_python_path is None:
            print("ERROR: 找不到 SPSS 内置 Python，请手动指定路径")
            return 1
    
    if not os.path.exists(stats_python_path):
        print("ERROR: SPSS 内置 Python 不存在: " + stats_python_path)
        return 1
    
    # 生成临时脚本（通过内置 Python 运行）
    with open(sps_file, "r", encoding="utf-8", errors="replace") as f:
        syntax = f.read()
    
    # 创建包装脚本
    script_dir = os.path.dirname(os.path.abspath(__file__))
    wrapper_script = os.path.join(script_dir, "_spss_runner.py")
    
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
        f.write("    print(\"SPSS 版本: \" + spss.GetSPSSVersion())\n")
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
    
    print("正在通过 SPSS 内置 Python 运行语法（完全无 GUI）...")
    print("语法文件: " + sps_file)
    
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
    """备用方式：通过 Production Facility 运行 .spj 作业文件（可能有闪屏）"""
    if not os.path.exists(spj_file):
        print("ERROR: .spj 文件不存在: " + spj_file)
        return 1
    
    if stats_exe is None:
        # 自动查找 stats.exe
        candidates = [
            r"C:\Program Files\IBM\SPSS\Statistics\26\stats.exe",
            r"C:\Program Files\IBM\SPSS30\stats.exe",
            r"C:\Program Files\IBM\SPSS\Statistics\29\stats.exe",
        ]
        for c in candidates:
            if os.path.exists(c):
                stats_exe = c
                break
        if stats_exe is None:
            print("ERROR: 找不到 stats.exe，请手动指定路径")
            return 1
    
    if not os.path.exists(stats_exe):
        print("ERROR: stats.exe 不存在: " + stats_exe)
        return 1
    
    cmd = [stats_exe, "--production", spj_file]
    print("Stats.exe: " + stats_exe)
    print(".spj file: " + spj_file)
    print("调用 SPSS Production Facility...")
    print("WARNING: 此方式可能有闪屏")
    
    try:
        CREATE_NO_WINDOW = 0x08000000
        result = subprocess.run(
            cmd,
            capture_output=True,
            creationflags=CREATE_NO_WINDOW,
            timeout=300
        )
        # SPSS 输出含非 UTF-8 字符，用 cp1252 或 replace 处理
        stdout = result.stdout.decode("cp1252", errors="replace") if result.stdout else ""
        stderr = result.stderr.decode("cp1252", errors="replace") if result.stderr else ""
        
        if stdout:
            print("--- SPSS 标准输出 ---")
            print(stdout)
        if stderr:
            print("--- SPSS 错误输出 ---")
            print(stderr)
        
        print("退出码: " + str(result.returncode))
        return result.returncode
    except Exception as e:
        print("ERROR: " + str(e))
        return 1

def check_sps(sps_file):
    """检查 .sps 语法文件是否存在及内容预览"""
    if not os.path.exists(sps_file):
        print("ERROR: .sps 文件不存在: " + sps_file)
        return 1
    with open(sps_file, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()
    print(".sps 文件: " + sps_file)
    print("行数: " + str(len(content.splitlines())))
    print("--- 前 10 行预览 ---")
    for i, line in enumerate(content.splitlines()[:10], 1):
        print("  " + str(i) + ": " + line)
    return 0

def show_version(stats_python_path):
    """显示 SPSS 版本信息"""
    if not os.path.exists(stats_python_path):
        print("ERROR: SPSS 内置 Python 不存在: " + stats_python_path)
        return 1
    try:
        CREATE_NO_WINDOW = 0x08000000
        result = subprocess.run(
            [stats_python_path, "-c", "import spss; print(spss.GetSPSSVersion())"],
            capture_output=True,
            creationflags=CREATE_NO_WINDOW,
            timeout=30
        )
        stdout = result.stdout.decode("cp1252", errors="replace") if result.stdout else ""
        print(stdout)
        return 0
    except Exception as e:
        print("ERROR: " + str(e))
        return 1

def main():
    if len(sys.argv) < 2:
        print("用法:")
        print("  spss_helper.py run-internal <sps_file> [stats_python_path]  # 首选：无 GUI")
        print("  spss_helper.py run-production <spj_file> [stats_exe_path]  # 备用：可能有闪屏")
        print("  spss_helper.py check <sps_file>")
        print("  spss_helper.py version [stats_python_path]")
        sys.exit(1)
    
    cmd = sys.argv[1]
    
    if cmd == "run-internal":
        sps_file = sys.argv[2] if len(sys.argv) > 2 else None
        stats_python_path = sys.argv[3] if len(sys.argv) > 3 else None
        if sps_file is None:
            print("ERROR: 请提供 .sps 文件路径")
            sys.exit(1)
        rc = run_internal(sps_file, stats_python_path)
        sys.exit(rc)
    
    elif cmd == "run-production":
        spj_file = sys.argv[2] if len(sys.argv) > 2 else None
        stats_exe = sys.argv[3] if len(sys.argv) > 3 else None
        if spj_file is None:
            print("ERROR: 请提供 .spj 文件路径")
            sys.exit(1)
        rc = run_production(spj_file, stats_exe)
        sys.exit(rc)
    
    elif cmd == "check":
        sps_file = sys.argv[2] if len(sys.argv) > 2 else None
        if sps_file is None:
            print("ERROR: 请提供 .sps 文件路径")
            sys.exit(1)
        rc = check_sps(sps_file)
        sys.exit(rc)
    
    elif cmd == "version":
        stats_python_path = sys.argv[2] if len(sys.argv) > 2 else None
        rc = show_version(stats_python_path)
        sys.exit(rc)
    
    else:
        print("ERROR: 未知命令: " + cmd)
        sys.exit(1)

if __name__ == "__main__":
    main()
