@echo off
REM 簡單的編譯腳本 - 需要在 Visual Studio Developer Command Prompt 中運行

echo === 編譯 MyMath DLL ===
echo.

cd /d "%~dp0"

REM 清理舊文件
if exist "MyMath.dll" del "MyMath.dll"
if exist "MyMath.lib" del "MyMath.lib"
if exist "MyMath.obj" del "MyMath.obj"
if exist "MyMath.exp" del "MyMath.exp"

echo 編譯 MyMath.cpp...
cl /LD /MD /O2 /EHsc /DMYMATH_EXPORTS MyMath.cpp /DEF:MyMath.def /Fe:MyMath.dll

if errorlevel 1 (
    echo.
    echo 編譯失敗！請確保在 Visual Studio Developer Command Prompt 中運行
    pause
    exit /b 1
)

echo.
echo === 編譯成功 ===
if exist "MyMath.dll" (
    echo DLL 文件已生成: MyMath.dll
    dir MyMath.dll
)
if exist "MyMath.lib" echo LIB 文件已生成: MyMath.lib
echo.

pause

