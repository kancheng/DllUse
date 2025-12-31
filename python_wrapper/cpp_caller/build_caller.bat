@echo off
REM 編譯 C++ 調用 Python DLL 的程序（支持 32 位和 64 位）

echo === 編譯 C++ 調用 Python DLL 程序 (32位和64位) ===
echo.

REM 設置腳本目錄
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM 創建輸出目錄
if not exist "x64" mkdir x64
if not exist "x86" mkdir x86

REM 編譯 64 位版本
echo.
echo ========================================
echo 編譯 64 位版本...
echo ========================================
echo.

REM 檢查 Visual Studio 環境
if "%VCINSTALLDIR%"=="" (
    echo 正在查找 Visual Studio...
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    ) else (
        echo 錯誤: 找不到 Visual Studio 編譯器
        echo 請在 Visual Studio Developer Command Prompt 中運行此腳本
        pause
        exit /b 1
    )
)

echo 使用編譯器: %VCINSTALLDIR%
echo.

REM 清理舊文件 (64位)
if exist "x64\test_python_dll.exe" del "x64\test_python_dll.exe"
if exist "x64\test_python_dll.obj" del "x64\test_python_dll.obj"

echo 編譯 64 位 test_python_dll.cpp...
cl /EHsc /MD test_python_dll.cpp /Fe:x64\test_python_dll.exe /link /SUBSYSTEM:CONSOLE

if errorlevel 1 (
    echo.
    echo 64 位編譯失敗！
    pause
    exit /b 1
)

echo.
echo 64 位編譯成功！
echo 可執行文件: %SCRIPT_DIR%x64\test_python_dll.exe
echo.

REM 編譯 32 位版本
echo.
echo ========================================
echo 編譯 32 位版本...
echo ========================================
echo.

REM 切換到 32 位環境
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars32.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars32.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars32.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars32.bat"
) else (
    echo 警告: 找不到 32 位編譯環境，跳過 32 位編譯
    goto :end
)

REM 清理舊文件 (32位)
if exist "x86\test_python_dll.exe" del "x86\test_python_dll.exe"
if exist "x86\test_python_dll.obj" del "x86\test_python_dll.obj"

echo 編譯 32 位 test_python_dll.cpp...
cl /EHsc /MD test_python_dll.cpp /Fe:x86\test_python_dll.exe /link /SUBSYSTEM:CONSOLE

if errorlevel 1 (
    echo.
    echo 32 位編譯失敗！
    pause
    exit /b 1
)

echo.
echo 32 位編譯成功！
echo 可執行文件: %SCRIPT_DIR%x86\test_python_dll.exe
echo.

:end
echo.
echo ========================================
echo === 編譯完成 ===
echo ========================================
echo.
echo 64 位程序: x64\test_python_dll.exe
echo 32 位程序: x86\test_python_dll.exe
echo.
echo 注意: 運行前請確保 Python Bridge DLL 已編譯並位於正確位置
echo.

pause

