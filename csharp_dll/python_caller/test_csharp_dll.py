"""
Python 使用 pythonnet (clr) 調用 C# DLL 範例（支持 32 位和 64 位）

安裝 pythonnet:
    pip install pythonnet
"""

import sys
import os
import platform

try:
    import clr
except ImportError:
    print("錯誤：未安裝 pythonnet")
    print("請運行: pip install pythonnet")
    sys.exit(1)

def get_dll_path():
    """根據 Python 架構自動選擇對應的 DLL"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.dirname(script_dir)
    
    # 檢測 Python 架構
    is_64bit = sys.maxsize > 2**32
    
    if is_64bit:
        dll_dir = os.path.join(base_dir, "x64")
        arch = "64位"
    else:
        dll_dir = os.path.join(base_dir, "x86")
        arch = "32位"
    
    dll_path = os.path.join(dll_dir, "CSharpDLL.dll")
    
    # 如果架構目錄中沒有，嘗試 Release 目錄
    if not os.path.exists(dll_path):
        if is_64bit:
            dll_path = os.path.join(base_dir, "bin", "Release", "x64", "net8.0", "CSharpDLL.dll")
        else:
            dll_path = os.path.join(base_dir, "bin", "Release", "x86", "net8.0", "CSharpDLL.dll")
    
    # 最後嘗試根目錄
    if not os.path.exists(dll_path):
        dll_path = os.path.join(base_dir, "CSharpDLL.dll")
    
    return dll_path, arch

# 獲取 DLL 路徑
dll_path, arch = get_dll_path()

print(f"Python 架構: {platform.architecture()[0]}")
print(f"使用 DLL: {dll_path} ({arch})")
print()

if not os.path.exists(dll_path):
    print(f"錯誤：找不到 CSharpDLL.dll")
    print(f"請確保 DLL 已編譯並位於: {dll_path}")
    print("運行 build_dll.bat 編譯 DLL")
    sys.exit(1)

# 加載 .NET 程序集
# pythonnet 需要使用完整路徑
dll_path_abs = os.path.abspath(dll_path)

try:
    # 使用完整路徑加載程序集
    clr.AddReference(dll_path_abs)
    from CSharpDLL import Calculator
    
    # 創建實例
    calc = Calculator()
    
except Exception as e:
    # 如果直接導入失敗，使用 System.Reflection
    try:
        import System
        from System.Reflection import Assembly
        from System import Activator
        
        # 加載程序集
        assembly = Assembly.LoadFrom(dll_path_abs)
        
        # 獲取 Calculator 類型
        calc_type = assembly.GetType("CSharpDLL.Calculator")
        
        # 創建實例
        calc = Activator.CreateInstance(calc_type)
        
    except Exception as e2:
        print(f"錯誤：無法加載 C# DLL")
        print(f"錯誤信息: {e2}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    print("=== Python 調用 C# DLL 範例 ===\n")
    
    try:
        # 調用 C# 方法
        result = calc.Add(10, 20)
        print(f"Add(10, 20) = {result}")
        
        result = calc.Subtract(30, 15)
        print(f"Subtract(30, 15) = {result}")
        
        result = calc.Multiply(5, 6)
        print(f"Multiply(5, 6) = {result}")
        
        version = calc.GetVersion()
        print(f"Version: {version}")
        
        print("\n測試完成！")
    except Exception as e:
        print(f"錯誤：調用 C# DLL 時發生異常: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
