@echo off
REM 編譯 Python Bridge DLL 的批處理腳本（支持 32 位和 64 位）
REM 需要先安裝 pybind11: pip install pybind11

echo === 編譯 Python Bridge DLL (32位和64位) ===
echo.

REM 設置腳本目錄
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM 檢查 CMake 是否可用
where cmake >nul 2>&1
if %errorlevel% neq 0 (
    echo 錯誤: 找不到 cmake 命令
    echo 請確保已安裝 CMake
    pause
    exit /b 1
)

REM 檢查 Python 是否可用
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo 錯誤: 找不到 python 命令
    echo 請確保已安裝 Python
    pause
    exit /b 1
)

REM 創建輸出目錄
if not exist "x64" mkdir x64
if not exist "x86" mkdir x86

REM 編譯 64 位版本
echo.
echo ========================================
echo 編譯 64 位版本...
echo ========================================
echo.

if exist "build_x64" rmdir /s /q build_x64
mkdir build_x64
cd build_x64

cmake .. -A x64 -DCMAKE_BUILD_TYPE=Release

if errorlevel 1 (
    echo.
    echo 64 位 CMake 配置失敗！
    cd ..
    pause
    exit /b 1
)

cmake --build . --config Release

if errorlevel 1 (
    echo.
    echo 64 位編譯失敗！
    cd ..
    pause
    exit /b 1
)

cd ..
copy /Y build_x64\Release\PythonBridge.dll x64\ >nul 2>&1
if exist build_x64\Release\PythonBridge.lib copy /Y build_x64\Release\PythonBridge.lib x64\ >nul 2>&1

echo.
echo 64 位編譯成功！
echo DLL 文件: %SCRIPT_DIR%x64\PythonBridge.dll
echo.

REM 編譯 32 位版本
echo.
echo ========================================
echo 編譯 32 位版本...
echo ========================================
echo.

if exist "build_x86" rmdir /s /q build_x86
mkdir build_x86
cd build_x86

cmake .. -A Win32 -DCMAKE_BUILD_TYPE=Release

if errorlevel 1 (
    echo.
    echo 32 位 CMake 配置失敗！
    cd ..
    goto :end
)

cmake --build . --config Release

if errorlevel 1 (
    echo.
    echo 32 位編譯失敗！
    cd ..
    goto :end
)

cd ..
copy /Y build_x86\Release\PythonBridge.dll x86\ >nul 2>&1
if exist build_x86\Release\PythonBridge.lib copy /Y build_x86\Release\PythonBridge.lib x86\ >nul 2>&1

echo.
echo 32 位編譯成功！
echo DLL 文件: %SCRIPT_DIR%x86\PythonBridge.dll
echo.

:end
echo.
echo ========================================
echo === 編譯完成 ===
echo ========================================
echo.
echo 64 位 DLL: x64\PythonBridge.dll
echo 32 位 DLL: x86\PythonBridge.dll
echo.

pause

