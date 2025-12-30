# C++ DLL 範例

## 編譯說明

### Visual Studio 編譯步驟：

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

### C# 調用：
1. 將 `MyMath.dll` 複製到 C# 項目輸出目錄
2. 編譯並運行 `csharp_caller/Program.cs`

### Python 調用：
1. 確保 `MyMath.dll` 在 Python 可訪問的路徑中
2. 運行 `python_caller/test_cpp_dll.py`

## 注意事項

- 確保 DLL 的位數（32/64位）與調用程序匹配
- 使用 `extern "C"` 確保函數名不被 C++ 名字修飾
- C# 調用時使用 `CallingConvention.Cdecl` 指定調用約定

