@echo off
REM 使用 Visual Studio 編譯器編譯 Python Bridge DLL（僅支援 64 位）
REM 需要先安裝 pybind11: pip install pybind11

echo === 編譯 Python Bridge DLL (64位) ===
echo.

REM 設置腳本目錄
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM 檢查 Python 是否可用
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo 錯誤: 找不到 python 命令
    echo 請確保已安裝 Python
    pause
    exit /b 1
)

REM 獲取 Python 路徑
for /f "tokens=*" %%i in ('python -c "import sys; print(sys.prefix)"') do set PYTHON_PREFIX=%%i
python get_python_paths.py > python_paths.tmp
for /f "tokens=2 delims==" %%i in ('findstr PYTHON_INCLUDE python_paths.tmp') do set PYTHON_INCLUDE=%%i
for /f "tokens=2 delims==" %%i in ('findstr PYTHON_LIBS_DIR python_paths.tmp') do set PYTHON_LIBS_DIR=%%i
del python_paths.tmp

echo Python 路徑: %PYTHON_PREFIX%
echo Python Include: %PYTHON_INCLUDE%
echo Python Libs: %PYTHON_LIBS_DIR%
echo.

REM 獲取 pybind11 路徑
for /f "tokens=*" %%i in ('python -c "import pybind11; import os; print(os.path.dirname(pybind11.__file__))"') do set PYBIND11_DIR=%%i

if not exist "%PYBIND11_DIR%" (
    echo 錯誤: 找不到 pybind11
    echo 請執行: pip install pybind11
    pause
    exit /b 1
)

echo pybind11 路徑: %PYBIND11_DIR%
echo.

REM 查找 Visual Studio
set "VS_PATH="
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"
) else (
    echo 錯誤: 找不到 Visual Studio
    pause
    exit /b 1
)

echo Visual Studio 路徑: %VS_PATH%
echo.

REM 創建輸出目錄
if not exist "x64" mkdir x64

REM 編譯 64 位版本
echo.
echo ========================================
echo 編譯 64 位版本...
echo ========================================
echo.

call "%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1

REM 查找 Python 庫文件（64位）
set PYTHON_LIB_FILE=
if exist "%PYTHON_LIBS_DIR%\python3.lib" (
    set PYTHON_LIB_FILE=%PYTHON_LIBS_DIR%\python3.lib
) else (
    for %%f in ("%PYTHON_LIBS_DIR%\python*.lib") do (
        set PYTHON_LIB_FILE=%%f
        goto :found_lib
    )
)

:found_lib
if not exist "%PYTHON_LIB_FILE%" (
    echo 錯誤: 找不到 Python 64位庫文件
    echo 請檢查: %PYTHON_LIBS_DIR%
    pause
    exit /b 1
)

REM 獲取庫文件名（不含路徑）
for %%f in ("%PYTHON_LIB_FILE%") do set PYTHON_LIB_NAME=%%~nxf

echo 使用 Python 庫: %PYTHON_LIB_FILE%
echo 編譯 64 位 DLL...
cl /LD /MD /O2 /EHsc /I"%PYTHON_INCLUDE%" /I"%PYBIND11_DIR%\include" python_bridge.cpp /Fe:x64\PythonBridge.dll /link /LIBPATH:"%PYTHON_LIBS_DIR%" "%PYTHON_LIB_NAME%" /OUT:x64\PythonBridge.dll

if errorlevel 1 (
    echo.
    echo 64 位編譯失敗！
    pause
    exit /b 1
)

echo.
echo 64 位編譯成功！
echo DLL 文件: %SCRIPT_DIR%x64\PythonBridge.dll
echo.
echo 注意: 確保 Python DLL 在系統 PATH 中，或將 Python 目錄添加到 PATH
echo.

pause
