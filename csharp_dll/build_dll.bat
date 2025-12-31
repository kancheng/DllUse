@echo off
REM 編譯 C# DLL 的批處理腳本（支持 32 位和 64 位）

echo === 編譯 C# DLL (32位和64位) ===
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

echo.
echo ========================================
echo 編譯 64 位版本...
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
echo 編譯 32 位版本...
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
echo === 編譯完成 ===
echo ========================================
echo.
echo 64 位 DLL: bin\Release\x64\net8.0\CSharpDLL.dll
echo 32 位 DLL: bin\Release\x86\net8.0\CSharpDLL.dll
echo.

REM 創建符號連結或複製到統一目錄
if not exist "x64" mkdir x64
if not exist "x86" mkdir x86

copy /Y "bin\Release\x64\net8.0\CSharpDLL.dll" "x64\" >nul 2>&1
copy /Y "bin\Release\x64\net8.0\CSharpDLL.runtimeconfig.json" "x64\" >nul 2>&1
copy /Y "bin\Release\x64\net8.0\CSharpDLL.deps.json" "x64\" >nul 2>&1
if exist "bin\Release\x64\net8.0\CSharpDLL.comhost.dll" copy /Y "bin\Release\x64\net8.0\CSharpDLL.comhost.dll" "x64\" >nul 2>&1

copy /Y "bin\Release\x86\net8.0\CSharpDLL.dll" "x86\" >nul 2>&1
copy /Y "bin\Release\x86\net8.0\CSharpDLL.runtimeconfig.json" "x86\" >nul 2>&1
copy /Y "bin\Release\x86\net8.0\CSharpDLL.deps.json" "x86\" >nul 2>&1
if exist "bin\Release\x86\net8.0\CSharpDLL.comhost.dll" copy /Y "bin\Release\x86\net8.0\CSharpDLL.comhost.dll" "x86\" >nul 2>&1

echo 已複製 DLL 到 x64 和 x86 目錄
echo.

pause

