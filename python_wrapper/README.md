# Python 封裝成 DLL 範例

## 概述

本範例展示如何將 Python 代碼封裝成 DLL，供 C++ 和 C# 調用。使用 pybind11 創建 C++ 橋接層。

## 環境要求

1. Python 3.x（已安裝）
2. pybind11：`pip install pybind11`
3. CMake（用於編譯 C++ 橋接層）
4. Visual Studio 或 MinGW（C++ 編譯器）

## 編譯步驟

### 1. 安裝依賴

```bash
pip install pybind11
```

### 2. 編譯 C++ 橋接層

#### 使用 CMake：

```bash
cd cpp_binding
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

#### 使用 Visual Studio：

1. 創建新的動態連結庫項目
2. 添加 `python_bridge.cpp`
3. 配置項目：
   - 包含 pybind11 頭文件目錄
   - 鏈接 Python 庫
   - 設置 Python 路徑
4. 編譯生成 `PythonBridge.dll`

### 3. 確保 Python 模組可訪問

將 `math_module.py` 放在 Python 可訪問的路徑中，或設置 `PYTHONPATH` 環境變量。

## 使用說明

### C++ 調用：

1. 將 `PythonBridge.dll` 和 Python 運行時庫放在可訪問路徑
2. 編譯並運行 `cpp_caller/test_python_dll.cpp`

### C# 調用：

1. 將 `PythonBridge.dll` 複製到 C# 項目輸出目錄
2. 確保 Python 運行時可訪問
3. 編譯並運行 `csharp_caller/Program.cs`

## 注意事項

- 確保 Python 版本與編譯時使用的版本一致
- 需要將 Python DLL 路徑添加到系統 PATH 或應用程序目錄
- pybind11 會自動處理 Python 解釋器的初始化和清理
- 字符串返回值需要注意生命週期管理

## 替代方案

### 使用 ctypes/cffi：
- 直接從 C/C++ 調用 Python C API
- 需要手動管理 Python 解釋器生命週期

### 使用 SWIG：
- 自動生成多語言綁定
- 適合大型項目

### 使用 PyInstaller：
- 主要用於打包完整應用
- 可以生成包含 Python 運行時的單文件

