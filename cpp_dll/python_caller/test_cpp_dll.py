"""
Python 使用 ctypes 調用 C++ DLL 範例
"""

import ctypes
import os

# 加載 DLL
# 確保 MyMath.dll 在當前目錄或系統路徑中
dll_path = os.path.join(os.path.dirname(__file__), "..", "MyMath.dll")
if not os.path.exists(dll_path):
    dll_path = "MyMath.dll"  # 嘗試從系統路徑加載

try:
    mymath = ctypes.CDLL(dll_path)
except OSError as e:
    print(f"無法加載 DLL: {e}")
    print("請確保 MyMath.dll 在當前目錄或系統路徑中")
    exit(1)

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

