"""
Python 使用 pythonnet (clr) 調用 C# DLL 範例

安裝 pythonnet:
    pip install pythonnet
"""

import sys
import os

try:
    import clr
except ImportError:
    print("錯誤：未安裝 pythonnet")
    print("請運行: pip install pythonnet")
    sys.exit(1)

# 添加 C# DLL 所在目錄到路徑
dll_path = os.path.join(os.path.dirname(__file__), "..", "bin", "Debug", "net6.0", "CSharpDLL.dll")
if not os.path.exists(dll_path):
    dll_path = os.path.join(os.path.dirname(__file__), "..", "CSharpDLL.dll")

if not os.path.exists(dll_path):
    print(f"錯誤：找不到 CSharpDLL.dll")
    print(f"請確保 DLL 已編譯並位於: {dll_path}")
    sys.exit(1)

# 加載 .NET 程序集
clr.AddReference(dll_path)

# 導入 C# 命名空間和類
from CSharpDLL import Calculator

if __name__ == "__main__":
    print("=== Python 調用 C# DLL 範例 ===\n")
    
    # 創建 C# 對象實例
    calc = Calculator()
    
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

