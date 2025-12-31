"""
Python 使用 ctypes 調用 C++ DLL 範例（支持 32 位和 64 位）
"""

import ctypes
import os
import sys
import platform

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
    
    dll_path = os.path.join(dll_dir, "MyMath.dll")
    
    # 如果架構目錄中沒有，嘗試根目錄
    if not os.path.exists(dll_path):
        dll_path = os.path.join(base_dir, "MyMath.dll")
    
    # 最後嘗試系統路徑
    if not os.path.exists(dll_path):
        dll_path = "MyMath.dll"
    
    return dll_path, arch

# 獲取 DLL 路徑
dll_path, arch = get_dll_path()

print(f"Python 架構: {platform.architecture()[0]}")
print(f"使用 DLL: {dll_path} ({arch})")
print()

if not os.path.exists(dll_path):
    print(f"錯誤：找不到 DLL: {dll_path}")
    print("請確保已編譯 DLL（運行 build_dll.bat）")
    sys.exit(1)

try:
    mymath = ctypes.CDLL(dll_path)
except OSError as e:
    print(f"無法加載 DLL: {e}")
    print(f"請確保 {dll_path} 存在且架構匹配")
    sys.exit(1)

# 定義函數簽名
# c_int 對應 C 語言的 int 類型
mymath.Add.argtypes = [ctypes.c_int, ctypes.c_int]
mymath.Add.restype = ctypes.c_int

mymath.Subtract.argtypes = [ctypes.c_int, ctypes.c_int]
mymath.Subtract.restype = ctypes.c_int

mymath.Multiply.argtypes = [ctypes.c_int, ctypes.c_int]
mymath.Multiply.restype = ctypes.c_int

mymath.GetVersion.argtypes = []
mymath.GetVersion.restype = ctypes.c_char_p

if __name__ == "__main__":
    print("=== Python 調用 C++ DLL 範例 ===\n")
    
    # 調用加法函數
    result = mymath.Add(10, 20)
    print(f"Add(10, 20) = {result}")
    
    # 調用減法函數
    result = mymath.Subtract(30, 15)
    print(f"Subtract(30, 15) = {result}")
    
    # 調用乘法函數
    result = mymath.Multiply(5, 6)
    print(f"Multiply(5, 6) = {result}")
    
    # 獲取版本信息
    version = mymath.GetVersion()
    print(f"Version: {version.decode('utf-8')}")
    
    print("\n測試完成！")
