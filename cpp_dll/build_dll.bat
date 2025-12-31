@echo off
REM 編譯 MyMath DLL 的批處理腳本（支持 32 位和 64 位）

echo === 編譯 MyMath DLL (32位和64位) ===
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
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
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
if exist "x64\MyMath.dll" del "x64\MyMath.dll"
if exist "x64\MyMath.lib" del "x64\MyMath.lib"
if exist "x64\MyMath.obj" del "x64\MyMath.obj"
if exist "x64\MyMath.exp" del "x64\MyMath.exp"

echo 編譯 64 位 MyMath.cpp...
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:x64\MyMath.dll

if errorlevel 1 (
    echo.
    echo 64 位編譯失敗！
    pause
    exit /b 1
)

echo.
echo 64 位編譯成功！
echo DLL 文件: %SCRIPT_DIR%x64\MyMath.dll
if exist "x64\MyMath.lib" echo LIB 文件: %SCRIPT_DIR%x64\MyMath.lib
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
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"
) else (
    echo 警告: 找不到 32 位編譯環境，跳過 32 位編譯
    goto :end
)

REM 清理舊文件 (32位)
if exist "x86\MyMath.dll" del "x86\MyMath.dll"
if exist "x86\MyMath.lib" del "x86\MyMath.lib"
if exist "x86\MyMath.obj" del "x86\MyMath.obj"
if exist "x86\MyMath.exp" del "x86\MyMath.exp"

echo 編譯 32 位 MyMath.cpp...
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:x86\MyMath.dll

if errorlevel 1 (
    echo.
    echo 32 位編譯失敗！
    pause
    exit /b 1
)

echo.
echo 32 位編譯成功！
echo DLL 文件: %SCRIPT_DIR%x86\MyMath.dll
if exist "x86\MyMath.lib" echo LIB 文件: %SCRIPT_DIR%x86\MyMath.lib
echo.

:end
echo.
echo ========================================
echo === 編譯完成 ===
echo ========================================
echo.
echo 64 位 DLL: x64\MyMath.dll
echo 32 位 DLL: x86\MyMath.dll
echo.

pause
