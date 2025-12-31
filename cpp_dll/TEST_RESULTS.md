# CPP_DLL 測試結果

## 測試日期
未指定（需手動更新）

## 1. DLL 編譯

### 編譯方法
使用 Visual Studio 2022 編譯器，通過以下命令編譯：

**64 位版本：**
```batch
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:x64\MyMath.dll
```

**32 位版本：**
```batch
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:x86\MyMath.dll
```

### 編譯結果
- ✅ **編譯成功**
- 生成文件（分別在 x64 和 x86 目錄中）：
  - `MyMath.dll` - 動態連結庫
  - `MyMath.lib` - 導入庫
  - `MyMath.exp` - 導出文件
  - `MyMath.obj` - 目標文件

### 編譯腳本
- `build_dll.bat` - 自動查找 Visual Studio 並編譯 32 位和 64 位版本（推薦）
- `build_dll.ps1` - PowerShell 版本，自動編譯 32 位和 64 位版本
- `build_simple.bat` - 簡單編譯腳本（已過時，僅編譯到根目錄，不推薦使用）

## 2. Python 調用測試

### 測試命令
```bash
python cpp_dll\python_caller\test_cpp_dll.py
```

### 測試結果
✅ **測試通過**

```
=== Python 調用 C++ DLL 範例 ===

Add(10, 20) = 30
Subtract(30, 15) = 15
Multiply(5, 6) = 30
Version: MyMath DLL v1.0.0

測試完成！
```

### 測試詳情
- ✅ DLL 加載成功
- ✅ 所有函數調用正常
- ✅ 整數運算結果正確
- ✅ 字符串返回值處理正確

## 3. C# 調用測試

### 編譯方法
使用 .NET SDK 或 Visual Studio 編譯器：

```batch
dotnet build --configuration Release
```

或使用 MSBuild：

```batch
msbuild CSharpCaller.csproj /p:Configuration=Release /p:Platform=x64
```

### 測試命令
```bash
.\Program.exe
```

### 測試結果
✅ **測試通過**

```
=== C# 調用 C++ DLL 範例 ===

Add(10, 20) = 30
Subtract(30, 15) = 15
Multiply(5, 6) = 30
Version: MyMath DLL v1.0.0

測試完成！
```

### 測試詳情
- ✅ DLL 加載成功（使用動態加載方式）
- ✅ 使用 `UnmanagedFunctionPointer` 委託，正確指定 `CallingConvention.Cdecl`
- ✅ 所有函數調用正常
- ✅ 整數運算結果正確
- ✅ 字符串指針轉換正確（使用 Marshal.PtrToStringAnsi）
- ✅ 支援根據運行時架構自動選擇對應的 DLL（32位/64位）

## 4. 函數驗證

### Add 函數
- Python: `Add(10, 20) = 30` ✅
- C#: `Add(10, 20) = 30` ✅

### Subtract 函數
- Python: `Subtract(30, 15) = 15` ✅
- C#: `Subtract(30, 15) = 15` ✅

### Multiply 函數
- Python: `Multiply(5, 6) = 30` ✅
- C#: `Multiply(5, 6) = 30` ✅

### GetVersion 函數
- Python: `Version: MyMath DLL v1.0.0` ✅
- C#: `Version: MyMath DLL v1.0.0` ✅

## 5. 總結

### 成功項目
- ✅ C++ DLL 編譯成功
- ✅ Python 調用成功
- ✅ C# 調用成功
- ✅ 所有函數功能正常
- ✅ 跨語言兼容性驗證通過

### 技術要點
1. **extern "C"** - 確保 C 語言兼容性，防止 C++ 名字修飾
2. **MYMATH_API** - 使用 `__declspec(dllexport)` 明確導出函數
3. **CallingConvention.Cdecl** - C# 中正確指定調用約定
4. **ctypes.CDLL** - Python 使用默認的 cdecl 調用約定
5. **字符串處理** - Python 使用 `c_char_p`，C# 使用 `IntPtr` + `Marshal.PtrToStringAnsi`

### 文件結構
```
cpp_dll/
├── MyMath.h          # 頭文件
├── MyMath.cpp        # 實現文件
├── MyMath.def        # 模塊定義文件
├── x64/              # 64 位 DLL 輸出目錄
│   ├── MyMath.dll
│   └── MyMath.lib
├── x86/              # 32 位 DLL 輸出目錄
│   ├── MyMath.dll
│   └── MyMath.lib
├── python_caller/
│   └── test_cpp_dll.py  # Python 測試程序
└── csharp_caller/
    ├── Program.cs       # C# 測試程序
    └── CSharpCaller.csproj
```

## 6. 結論

✅ **CPP_DLL 封裝、編譯和測試全部成功！**

DLL 可以在 Python 和 C# 中正常調用，所有函數功能驗證通過。

