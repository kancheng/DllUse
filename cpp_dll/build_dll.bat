@echo off
REM 編譯 MyMath DLL 的批處理腳本

echo === 編譯 MyMath DLL ===
echo.

REM 設置腳本目錄
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM 檢查 Visual Studio 開發者命令提示符環境
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

REM 清理舊文件
if exist "MyMath.dll" del "MyMath.dll"
if exist "MyMath.lib" del "MyMath.lib"
if exist "MyMath.obj" del "MyMath.obj"
if exist "MyMath.exp" del "MyMath.exp"

echo 編譯 MyMath.cpp...
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:MyMath.dll

if errorlevel 1 (
    echo.
    echo 編譯失敗！
    pause
    exit /b 1
)

echo.
echo === 編譯成功 ===
echo DLL 文件: %SCRIPT_DIR%MyMath.dll
if exist "MyMath.lib" echo LIB 文件: %SCRIPT_DIR%MyMath.lib
echo.

pause

