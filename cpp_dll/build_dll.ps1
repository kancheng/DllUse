# 編譯 MyMath DLL 的 PowerShell 腳本

Write-Host "=== 編譯 MyMath DLL ===" -ForegroundColor Cyan
Write-Host ""

# 查找 Visual Studio 編譯器
$vcPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
)

$vcvarsPath = $null
foreach ($path in $vcPaths) {
    if (Test-Path $path) {
        $vcvarsPath = $path
        break
    }
}

if (-not $vcvarsPath) {
    Write-Host "錯誤: 找不到 Visual Studio 編譯器" -ForegroundColor Red
    Write-Host "請在 Visual Studio Developer Command Prompt 中運行此腳本" -ForegroundColor Yellow
    exit 1
}

Write-Host "找到 Visual Studio: $vcvarsPath" -ForegroundColor Green
Write-Host ""

# 設置路徑
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$cppFile = Join-Path $scriptDir "MyMath.cpp"
$defFile = Join-Path $scriptDir "MyMath.def"
$dllFile = Join-Path $scriptDir "MyMath.dll"
$libFile = Join-Path $scriptDir "MyMath.lib"
$objFile = Join-Path $scriptDir "MyMath.obj"

# 清理舊文件
if (Test-Path $dllFile) { Remove-Item $dllFile -Force }
if (Test-Path $libFile) { Remove-Item $libFile -Force }
if (Test-Path $objFile) { Remove-Item $objFile -Force }

# 初始化 Visual Studio 環境
Write-Host "初始化編譯環境..." -ForegroundColor Yellow
$tempFile = [System.IO.Path]::GetTempFileName()
cmd /c "`"$vcvarsPath`" && set" | ForEach-Object {
    if ($_ -match "^(.+?)=(.*)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}
Remove-Item $tempFile -ErrorAction SilentlyContinue

# 編譯 DLL
Write-Host "編譯 MyMath.cpp..." -ForegroundColor Yellow
$clPath = "${env:VCINSTALLDIR}bin\Hostx64\x64\cl.exe"

if (-not (Test-Path $clPath)) {
    Write-Host "錯誤: 找不到 cl.exe" -ForegroundColor Red
    exit 1
}

$compileArgs = @(
    "/LD",           # 創建 DLL
    "/MD",           # 使用多線程 DLL 運行時
    "/O2",           # 優化
    "/EHsc",         # 異常處理
    "/DMYMATH_EXPORTS",
    "`"$cppFile`"",
    "/DEF:`"$defFile`"",
    "/Fe:`"$dllFile`""
)

$process = Start-Process -FilePath $clPath -ArgumentList $compileArgs -NoNewWindow -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Host ""
    Write-Host "編譯失敗！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== 編譯成功 ===" -ForegroundColor Green
Write-Host "DLL 文件: $dllFile" -ForegroundColor Green
if (Test-Path $libFile) {
    Write-Host "LIB 文件: $libFile" -ForegroundColor Green
}
Write-Host ""

