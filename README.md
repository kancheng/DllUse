# 三種語言 DLL 封裝範例

本項目包含三種不同語言的 DLL 封裝範例，展示如何在 C++、C# 和 Python 之間進行互操作。

> 該計畫是驗證 C++、 C#、Python 、LabView 之間利用 動態連結庫的可行性。

## 項目結構

```
.
├── cpp_dll/              # C++ DLL 範例
│   ├── MyMath.h          # C++ DLL 頭文件
│   ├── MyMath.cpp        # C++ DLL 實現
│   ├── MyMath.def        # 導出定義文件
│   ├── csharp_caller/    # C# 調用範例
│   ├── python_caller/    # Python 調用範例
│   └── README.md         # C++ DLL 說明文檔
│
├── csharp_dll/           # C# DLL 範例
│   ├── Calculator.cs     # C# DLL 實現
│   ├── AssemblyInfo.cs   # 程序集信息
│   ├── CSharpDLL.csproj  # 項目文件
│   ├── cpp_caller/       # C++ 調用範例
│   ├── python_caller/    # Python 調用範例
│   └── README.md         # C# DLL 說明文檔
│
└── python_wrapper/       # Python 封裝範例
    ├── math_module.py    # Python 模組
    ├── cpp_binding/      # C++ 橋接層
    ├── cpp_caller/       # C++ 調用範例
    ├── csharp_caller/    # C# 調用範例
    └── README.md         # Python 封裝說明文檔
```

## 快速開始

### 1. C++ DLL 範例

**目標**：將 C++ 代碼編譯成 DLL，供 C# 和 Python 調用

- **C++ 源碼**：`cpp_dll/MyMath.cpp` - 使用 `extern "C"` 確保 C 語言兼容性
- **C# 調用**：`cpp_dll/csharp_caller/Program.cs` - 使用 `DllImport` 特性
- **Python 調用**：`cpp_dll/python_caller/test_cpp_dll.py` - 使用 `ctypes` 庫

詳細說明請參考：`cpp_dll/README.md`

### 2. C# DLL 範例

**目標**：將 C# 代碼編譯成 .NET 程序集，供 C++ 和 Python 調用

- **C# 源碼**：`csharp_dll/Calculator.cs` - 使用 `ComVisible` 屬性支持 COM 互操作
- **C++ 調用**：`csharp_dll/cpp_caller/` - 提供多種調用方式（COM、C++/CLI、CLR）
- **Python 調用**：`csharp_dll/python_caller/test_csharp_dll.py` - 使用 `pythonnet` (clr)

詳細說明請參考：`csharp_dll/README.md`

### 3. Python 封裝範例

**目標**：將 Python 代碼封裝成 DLL，供 C++ 和 C# 調用

- **Python 源碼**：`python_wrapper/math_module.py` - 原始 Python 模組
- **C++ 橋接層**：`python_wrapper/cpp_binding/python_bridge.cpp` - 使用 `pybind11` 創建 C++ 接口
- **C++ 調用**：`python_wrapper/cpp_caller/test_python_dll.cpp`
- **C# 調用**：`python_wrapper/csharp_caller/Program.cs`

詳細說明請參考：`python_wrapper/README.md`

## 技術要點總結

### C++ DLL
- ✅ 使用 `extern "C"` 防止名字修飾
- ✅ 使用 `__declspec(dllexport)` 導出函數
- ✅ C# 使用 `DllImport` 特性
- ✅ Python 使用 `ctypes.CDLL` 加載

### C# DLL
- ✅ 使用 `ComVisible` 屬性支持 COM
- ✅ 使用 `Guid` 標識接口和類
- ✅ C++ 可通過 COM、C++/CLI 或 CLR 調用
- ✅ Python 使用 `pythonnet` (clr) 直接加載 .NET 程序集

### Python 封裝
- ✅ 使用 `pybind11` 創建 C++ 橋接層
- ✅ 橋接層提供 C 風格接口
- ✅ C++ 和 C# 通過橋接 DLL 調用 Python 函數
- ✅ 需要管理 Python 解釋器生命週期

## 注意事項

1. **位數匹配**：確保 DLL 的位數（32/64位）與調用程序匹配
2. **路徑設置**：確保 DLL 文件在可訪問路徑中
3. **依賴庫**：確保所有依賴庫（如 Python 運行時、.NET 運行時）已正確安裝
4. **編譯環境**：不同範例需要不同的編譯工具和環境

## 相關工具

- **Visual Studio**：編譯 C++ 和 C# 項目
- **.NET SDK**：編譯 C# 項目
- **Python**：運行 Python 代碼和調用 DLL
- **pybind11**：Python 與 C++ 綁定
- **pythonnet**：Python 與 .NET 互操作
- **CMake**：構建 C++ 橋接層（可選）

