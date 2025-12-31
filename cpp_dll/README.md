# C++ DLL 範例

這是一個跨語言調用的 C++ DLL 範例，支持從 Python 和 C# 調用。DLL 提供基本的數學運算函數，並支持 32 位和 64 位架構。

## 項目結構

```
cpp_dll/
├── MyMath.h          # 頭文件
├── MyMath.cpp        # 實現文件
├── MyMath.def        # 模塊定義文件
├── build_dll.bat     # 自動編譯腳本（推薦）
├── build_dll.ps1     # PowerShell 編譯腳本
├── build_simple.bat  # 簡單編譯腳本
├── x64/              # 64 位 DLL 輸出目錄
│   ├── MyMath.dll
│   └── MyMath.lib
├── x86/              # 32 位 DLL 輸出目錄
│   ├── MyMath.dll
│   └── MyMath.lib
├── python_caller/    # Python 調用範例
│   └── test_cpp_dll.py
└── csharp_caller/    # C# 調用範例
    ├── Program.cs
    └── CSharpCaller.csproj
```

## 編譯說明

### 方法一：使用自動編譯腳本（推薦）

**Windows 批處理：**
```batch
build_dll.bat
```

**PowerShell：**
```powershell
.\build_dll.ps1
```

這些腳本會：
- 自動查找 Visual Studio 編譯器
- 自動編譯 32 位和 64 位版本
- 將 DLL 輸出到 `x64/` 和 `x86/` 目錄

### 方法二：手動編譯

**64 位版本：**
```batch
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:x64\MyMath.dll
```

**32 位版本：**
```batch
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:x86\MyMath.dll
```

### 方法三：使用 Visual Studio 項目

1. 創建新的 Visual Studio 項目：
   - 選擇「動態連結庫 (DLL)」項目類型
   - 項目名稱：MyMath

2. 添加文件：
   - 將 `MyMath.h` 和 `MyMath.cpp` 添加到項目
   - 將 `MyMath.def` 添加到項目（在項目屬性中設置為模塊定義文件）

3. 設置導出：
   - 在項目屬性中，C/C++ -> 預處理器 -> 預處理器定義，添加 `MYMATH_EXPORTS`

4. 編譯：
   - 生成配置選擇 Release 或 Debug
   - 編譯後會生成 `MyMath.dll` 和 `MyMath.lib`

## 使用說明

### Python 調用

Python 調用程序會自動檢測 Python 架構並選擇對應的 DLL：

```bash
python python_caller/test_cpp_dll.py
```

**特點：**
- 自動檢測 32/64 位架構
- 自動查找對應的 DLL（優先使用 `x64/` 或 `x86/` 目錄）
- 使用 `ctypes.CDLL` 加載 DLL（默認 cdecl 調用約定）

### C# 調用

C# 調用程序使用動態加載方式，支持自動架構檢測：

**使用 .NET SDK：**
```bash
cd csharp_caller
dotnet build --configuration Release
dotnet run
```

**或使用 PowerShell 腳本：**
```powershell
cd csharp_caller
.\compile_and_run.ps1
```

**特點：**
- 使用動態加載（`LoadLibrary`/`GetProcAddress`）而非靜態 `DllImport`
- 自動檢測運行時架構（32/64 位）
- 使用 `UnmanagedFunctionPointer` 委託，指定 `CallingConvention.Cdecl`
- 正確處理字符串返回值（使用 `Marshal.PtrToStringAnsi`）

## 導出的函數

- `int Add(int a, int b)` - 加法
- `int Subtract(int a, int b)` - 減法
- `int Multiply(int a, int b)` - 乘法
- `const char* GetVersion()` - 獲取版本信息

## 驗證和測試

### 驗證 DLL 接口
```powershell
.\verify_dll.ps1
```

或使用 Python：
```bash
python verify_interface.py
```

### 查看測試結果
- `TEST_RESULTS.md` - 詳細的測試結果
- `VERIFICATION_REPORT.md` - 封裝驗證報告

## 技術要點

1. **extern "C"** - 確保 C 語言兼容性，防止 C++ 名字修飾
2. **MYMATH_API** - 使用 `__declspec(dllexport)` 明確導出函數
3. **MyMath.def** - 模塊定義文件，確保函數名稱正確導出
4. **CallingConvention.Cdecl** - C# 中正確指定調用約定
5. **ctypes.CDLL** - Python 使用默認的 cdecl 調用約定
6. **字符串處理** - Python 使用 `c_char_p`，C# 使用 `IntPtr` + `Marshal.PtrToStringAnsi`

## 注意事項

- ✅ DLL 的位數（32/64位）必須與調用程序匹配
- ✅ Python 和 C# 調用程序都支持自動架構檢測
- ✅ 使用 `extern "C"` 確保函數名不被 C++ 名字修飾
- ✅ C# 調用時使用 `CallingConvention.Cdecl` 指定調用約定
- ✅ 字符串返回值使用靜態字符串，避免內存管理問題

