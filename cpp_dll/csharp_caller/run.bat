@echo off
REM 編譯並運行 C# 調用程序

echo === 編譯 C# 程序 ===
echo.

cd /d "%~dp0"

REM 複製 DLL
copy /Y ..\MyMath.dll . >nul

REM 嘗試使用 dotnet 編譯（如果可用）
where dotnet >nul 2>&1
if %errorlevel% equ 0 (
    echo 使用 dotnet 編譯...
    dotnet build --no-restore 2>nul
    if %errorlevel% equ 0 (
        echo 編譯成功！
        echo.
        echo === 運行程序 ===
        dotnet run --no-build
        goto :end
    )
)

REM 如果 dotnet 不可用，提示用戶
echo 請使用以下方法之一：
echo 1. 在 Visual Studio 中打開並編譯
echo 2. 使用 Developer Command Prompt: csc Program.cs
echo 3. 使用 dotnet: dotnet build
echo.
pause

:end

