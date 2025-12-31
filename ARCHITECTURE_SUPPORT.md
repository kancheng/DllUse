# 多架構支持說明

本項目現在支持 32 位和 64 位架構的 DLL 編譯和調用。

## 架構支持總覽

### CPP DLL
- ✅ 支持編譯 32 位和 64 位版本
- ✅ Python 可自動選擇對應架構的 DLL
- ✅ C# 可自動選擇對應架構的 DLL

### C# DLL
- ✅ 支持編譯 32 位和 64 位版本
- ✅ Python 可自動選擇對應架構的 DLL
- ✅ C++ 可自動選擇對應架構的 DLL

### Python DLL (通過 C++ 橋接)
- ✅ 支持編譯 32 位和 64 位版本
- ✅ C# 可自動選擇對應架構的 DLL
- ✅ C++ 可自動選擇對應架構的 DLL

## 編譯說明

### CPP DLL

```batch
cd cpp_dll
build_dll.bat
```

編譯後會生成：
- `x64\MyMath.dll` - 64 位版本
- `x86\MyMath.dll` - 32 位版本

### C# DLL

```batch
cd csharp_dll
build_dll.bat
```

編譯後會生成：
- `x64\CSharpDLL.dll` - 64 位版本
- `x86\CSharpDLL.dll` - 32 位版本

### Python DLL (橋接層)

```batch
cd python_wrapper\cpp_binding
build_dll.bat
```

編譯後會生成：
- `x64\PythonBridge.dll` - 64 位版本
- `x86\PythonBridge.dll` - 32 位版本

## 調用說明

### Python 調用

所有 Python 調用代碼都會自動檢測 Python 運行時架構，並選擇對應的 DLL：

```python
# 自動檢測架構
is_64bit = sys.maxsize > 2**32
if is_64bit:
    dll_path = "x64/MyMath.dll"
else:
    dll_path = "x86/MyMath.dll"
```

### C# 調用

所有 C# 調用代碼都會自動檢測運行時架構，並選擇對應的 DLL：

```csharp
bool is64Bit = Environment.Is64BitProcess;
string dllPath = is64Bit ? "x64/MyMath.dll" : "x86/MyMath.dll";
```

### C++ 調用

C++ 調用代碼會根據編譯時架構選擇對應的 DLL：

```cpp
#ifdef _WIN64
    bool is64Bit = true;
#else
    bool is64Bit = false;
#endif
```

## 目錄結構

```
cpp_dll/
├── x64/
│   └── MyMath.dll
├── x86/
│   └── MyMath.dll
├── python_caller/
│   └── test_cpp_dll.py  (自動選擇架構)
└── csharp_caller/
    └── Program.cs  (自動選擇架構)

csharp_dll/
├── x64/
│   └── CSharpDLL.dll
├── x86/
│   └── CSharpDLL.dll
├── python_caller/
│   └── test_csharp_dll.py  (自動選擇架構)
└── cpp_caller/
    └── main.cpp  (自動選擇架構)

python_wrapper/
└── cpp_binding/
    ├── x64/
    │   └── PythonBridge.dll
    ├── x86/
    │   └── PythonBridge.dll
    ├── cpp_caller/
    │   └── test_python_dll.cpp  (自動選擇架構)
    └── csharp_caller/
        └── Program.cs  (自動選擇架構)
```

## 注意事項

1. **架構匹配**：調用程序的架構必須與 DLL 的架構匹配
   - 64 位 Python 只能調用 64 位 DLL
   - 32 位 Python 只能調用 32 位 DLL
   - 同樣適用於 C# 和 C++

2. **自動選擇**：所有調用代碼都已實現自動架構檢測和 DLL 選擇

3. **編譯順序**：建議先編譯所有 DLL，確保 32 位和 64 位版本都已生成

4. **測試**：使用對應架構的運行時測試對應架構的 DLL

## 測試建議

1. 使用 64 位 Python 測試 64 位 DLL
2. 使用 32 位 Python 測試 32 位 DLL（如果可用）
3. 使用 64 位 C# 運行時測試 64 位 DLL
4. 使用 32 位 C# 運行時測試 32 位 DLL
5. 編譯 64 位 C++ 程序測試 64 位 DLL
6. 編譯 32 位 C++ 程序測試 32 位 DLL

