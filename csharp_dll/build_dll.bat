@echo off
REM 編譯 C# DLL 的批處理腳本（支持 32 位和 64 位，net8.0 和 net48）

echo === 編譯 C# DLL (Multi-target: net8.0 + net48, 32位和64位) ===
echo.

REM 設置腳本目錄
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM 檢查 dotnet 是否可用
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo 錯誤: 找不到 dotnet 命令
    echo 請確保已安裝 .NET SDK
    pause
    exit /b 1
)

REM 創建輸出目錄
if not exist "x64" mkdir x64
if not exist "x86" mkdir x86
if not exist "x64\net48" mkdir x64\net48
if not exist "x64\net8.0" mkdir x64\net8.0
if not exist "x86\net48" mkdir x86\net48
if not exist "x86\net8.0" mkdir x86\net8.0

echo.
echo ========================================
echo 編譯 64 位版本 (net8.0 + net48)...
echo ========================================
echo.

dotnet build CSharpDLL.csproj -c Release -p:Platform=x64

if errorlevel 1 (
    echo.
    echo 64 位編譯失敗！
    pause
    exit /b 1
)

echo.
echo 64 位編譯成功！
echo.

echo.
echo ========================================
echo 編譯 32 位版本 (net8.0 + net48)...
echo ========================================
echo.

dotnet build CSharpDLL.csproj -c Release -p:Platform=x86

if errorlevel 1 (
    echo.
    echo 32 位編譯失敗！
    pause
    exit /b 1
)

echo.
echo 32 位編譯成功！
echo.

echo.
echo ========================================
echo === 複製文件到統一目錄 ===
echo ========================================
echo.

REM 複製 x64 net8.0 文件（用於 COM/LabVIEW）
if exist "bin\x64\Release\net8.0\CSharpDLL.dll" (
    copy /Y "bin\x64\Release\net8.0\CSharpDLL.dll" "x64\net8.0\" >nul 2>&1
    copy /Y "bin\x64\Release\net8.0\CSharpDLL.runtimeconfig.json" "x64\net8.0\" >nul 2>&1
    copy /Y "bin\x64\Release\net8.0\CSharpDLL.deps.json" "x64\net8.0\" >nul 2>&1
    if exist "bin\x64\Release\net8.0\CSharpDLL.comhost.dll" copy /Y "bin\x64\Release\net8.0\CSharpDLL.comhost.dll" "x64\net8.0\" >nul 2>&1
    echo 已複製 x64 net8.0 DLL 文件
)

REM 複製 x64 net48 文件（用於 Python/C++）
if exist "bin\x64\Release\net48\CSharpDLL.dll" (
    copy /Y "bin\x64\Release\net48\CSharpDLL.dll" "x64\net48\" >nul 2>&1
    copy /Y "bin\x64\Release\net48\CSharpDLL.dll" "x64\" >nul 2>&1
    echo 已複製 x64 net48 DLL 文件（Python/C++ 使用）
)

REM 複製 x86 net8.0 文件
if exist "bin\x86\Release\net8.0\CSharpDLL.dll" (
    copy /Y "bin\x86\Release\net8.0\CSharpDLL.dll" "x86\net8.0\" >nul 2>&1
    copy /Y "bin\x86\Release\net8.0\CSharpDLL.runtimeconfig.json" "x86\net8.0\" >nul 2>&1
    copy /Y "bin\x86\Release\net8.0\CSharpDLL.deps.json" "x86\net8.0\" >nul 2>&1
    echo 已複製 x86 net8.0 DLL 文件
)

REM 複製 x86 net48 文件（用於 Python/C++）
if exist "bin\x86\Release\net48\CSharpDLL.dll" (
    copy /Y "bin\x86\Release\net48\CSharpDLL.dll" "x86\net48\" >nul 2>&1
    copy /Y "bin\x86\Release\net48\CSharpDLL.dll" "x86\" >nul 2>&1
    echo 已複製 x86 net48 DLL 文件（Python/C++ 使用）
)

echo.
echo ========================================
echo === 編譯完成 ===
echo ========================================
echo.
echo 64 位 net8.0 DLL: x64\net8.0\CSharpDLL.dll (COM/LabVIEW)
echo 64 位 net48 DLL: x64\net48\CSharpDLL.dll (Python/C++)
echo 32 位 net8.0 DLL: x86\net8.0\CSharpDLL.dll
echo 32 位 net48 DLL: x86\net48\CSharpDLL.dll (Python/C++)
echo.
echo 注意: x64\CSharpDLL.dll 和 x86\CSharpDLL.dll 指向 net48 版本（供 Python/C++ 使用）
echo.

pause
