@echo off
chcp 65001 >nul
echo ========================================
echo 編譯 C# 調用 Python DLL 程序
echo ========================================
echo.

set SCRIPT_DIR=%~dp0
set OUTPUT_DIR=%SCRIPT_DIR%x64
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: 查找 csc.exe (C# 編譯器)
set CSC_PATH=
set "VS2022_COMMUNITY=%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\Roslyn\csc.exe"
set "VS2022_PRO=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\Roslyn\csc.exe"
set "VS2022_ENT=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\Roslyn\csc.exe"
set "VS2019_COMMUNITY=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn\csc.exe"
set "VS2019_PRO=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\Roslyn\csc.exe"
set "VS2019_ENT=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\Roslyn\csc.exe"

if exist "%VS2022_COMMUNITY%" (
    set "CSC_PATH=%VS2022_COMMUNITY%"
) else if exist "%VS2022_PRO%" (
    set "CSC_PATH=%VS2022_PRO%"
) else if exist "%VS2022_ENT%" (
    set "CSC_PATH=%VS2022_ENT%"
) else if exist "%VS2019_COMMUNITY%" (
    set "CSC_PATH=%VS2019_COMMUNITY%"
) else if exist "%VS2019_PRO%" (
    set "CSC_PATH=%VS2019_PRO%"
) else if exist "%VS2019_ENT%" (
    set "CSC_PATH=%VS2019_ENT%"
)

if "%CSC_PATH%"=="" (
    echo 錯誤：找不到 csc.exe 編譯器
    echo 請確保已安裝 Visual Studio 或 .NET Framework SDK
    pause
    exit /b 1
)

echo 使用編譯器: %CSC_PATH%
echo.

:: 編譯 C# 程序
echo 編譯 Program.cs...
"%CSC_PATH%" /target:exe /out:"%OUTPUT_DIR%\CSharpCallPythonDLL.exe" /platform:x64 /nologo "%SCRIPT_DIR%Program.cs"

if errorlevel 1 (
    echo.
    echo 編譯失敗！
    pause
    exit /b 1
)

echo.
echo ========================================
echo 編譯成功！
echo 輸出文件: %OUTPUT_DIR%\CSharpCallPythonDLL.exe
echo ========================================
echo.

pause

