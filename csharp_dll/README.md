# C# DLL 範例

## 編譯說明

### 使用 .NET CLI 編譯：

```bash
dotnet build CSharpDLL.csproj
```

編譯後會在 `bin/Debug/net6.0/` 或 `bin/Release/net6.0/` 目錄生成 `CSharpDLL.dll`

## 使用說明

### Python 調用（推薦）：
1. 安裝 pythonnet：`pip install pythonnet`
2. 運行 `python_caller/test_csharp_dll.py`

### C++ 調用方法：

#### 方法 1: 使用 C++/CLI 包裝器（推薦）
1. 在 Visual Studio 中創建 C++/CLI 項目
2. 添加對 CSharpDLL.dll 的引用
3. 使用 `CLRWrapper.cpp` 作為參考創建包裝器
4. 編譯生成包裝器 DLL
5. 從原生 C++ 代碼調用包裝器 DLL

#### 方法 2: 使用 COM 互操作性
1. 註冊 DLL：
   ```bash
   regasm CSharpDLL.dll /codebase
   ```
2. 生成類型庫：
   ```bash
   tlbimp CSharpDLL.dll
   ```
3. 在 C++ 項目中使用生成的類型庫

#### 方法 3: 使用 CLR 混合編譯
1. 在 Visual Studio 項目屬性中啟用 `/clr`
2. 直接使用 `#using` 指令引用 C# DLL

## 注意事項

- 確保 .NET 運行時已安裝
- COM 互操作性需要管理員權限註冊
- C++/CLI 方法最靈活，但需要 Visual Studio 支持

