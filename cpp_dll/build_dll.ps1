# 編譯 MyMath DLL 的 PowerShell 腳本（支持 32 位和 64 位）

Write-Host "=== 編譯 MyMath DLL (32位和64位) ===" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# 創建輸出目錄
$x64Dir = Join-Path $scriptDir "x64"
$x86Dir = Join-Path $scriptDir "x86"
if (-not (Test-Path $x64Dir)) { New-Item -ItemType Directory -Path $x64Dir | Out-Null }
if (-not (Test-Path $x86Dir)) { New-Item -ItemType Directory -Path $x86Dir | Out-Null }

# 查找 Visual Studio 編譯器
$vcPaths64 = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
)

$vcPaths32 = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars32.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars32.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"
)

$vcvars64Path = $null
foreach ($path in $vcPaths64) {
    if (Test-Path $path) {
        $vcvars64Path = $path
        break
    }
}

$vcvars32Path = $null
foreach ($path in $vcPaths32) {
    if (Test-Path $path) {
        $vcvars32Path = $path
        break
    }
}

if (-not $vcvars64Path) {
    Write-Host "錯誤: 找不到 Visual Studio 64 位編譯器" -ForegroundColor Red
    Write-Host "請在 Visual Studio Developer Command Prompt 中運行此腳本" -ForegroundColor Yellow
    exit 1
}

$cppFile = Join-Path $scriptDir "MyMath.cpp"
$defFile = Join-Path $scriptDir "MyMath.def"

# 編譯 64 位版本
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "編譯 64 位版本..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 清理舊文件 (64位)
$dll64 = Join-Path $x64Dir "MyMath.dll"
$lib64 = Join-Path $x64Dir "MyMath.lib"
$obj64 = Join-Path $x64Dir "MyMath.obj"
$exp64 = Join-Path $x64Dir "MyMath.exp"

if (Test-Path $dll64) { Remove-Item $dll64 -Force }
if (Test-Path $lib64) { Remove-Item $lib64 -Force }
if (Test-Path $obj64) { Remove-Item $obj64 -Force }
if (Test-Path $exp64) { Remove-Item $exp64 -Force }

# 初始化 Visual Studio 64 位環境
Write-Host "初始化 64 位編譯環境..." -ForegroundColor Yellow
$env:VCINSTALLDIR = ""
cmd /c "`"$vcvars64Path`" && set" | ForEach-Object {
    if ($_ -match "^(.+?)=(.*)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}

# 編譯 64 位 DLL
Write-Host "編譯 64 位 MyMath.cpp..." -ForegroundColor Yellow
$clPath = "${env:VCINSTALLDIR}bin\Hostx64\x64\cl.exe"

if (-not (Test-Path $clPath)) {
    Write-Host "錯誤: 找不到 cl.exe" -ForegroundColor Red
    exit 1
}

$compileArgs64 = @(
    "/LD",
    "/MD",
    "/O2",
    "/EHsc",
    "/DMYMATH_EXPORTS",
    "`"$cppFile`"",
    "/DEF:`"$defFile`"",
    "/Fe:`"$dll64`""
)

$process = Start-Process -FilePath $clPath -ArgumentList $compileArgs64 -NoNewWindow -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Host ""
    Write-Host "64 位編譯失敗！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "64 位編譯成功！" -ForegroundColor Green
Write-Host "DLL 文件: $dll64" -ForegroundColor Green
if (Test-Path $lib64) {
    Write-Host "LIB 文件: $lib64" -ForegroundColor Green
}
Write-Host ""

# 編譯 32 位版本
if ($vcvars32Path) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "編譯 32 位版本..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # 清理舊文件 (32位)
    $dll32 = Join-Path $x86Dir "MyMath.dll"
    $lib32 = Join-Path $x86Dir "MyMath.lib"
    $obj32 = Join-Path $x86Dir "MyMath.obj"
    $exp32 = Join-Path $x86Dir "MyMath.exp"

    if (Test-Path $dll32) { Remove-Item $dll32 -Force }
    if (Test-Path $lib32) { Remove-Item $lib32 -Force }
    if (Test-Path $obj32) { Remove-Item $obj32 -Force }
    if (Test-Path $exp32) { Remove-Item $exp32 -Force }

    # 初始化 Visual Studio 32 位環境
    Write-Host "初始化 32 位編譯環境..." -ForegroundColor Yellow
    $env:VCINSTALLDIR = ""
    cmd /c "`"$vcvars32Path`" && set" | ForEach-Object {
        if ($_ -match "^(.+?)=(.*)$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }

    # 編譯 32 位 DLL
    Write-Host "編譯 32 位 MyMath.cpp..." -ForegroundColor Yellow
    $clPath32 = "${env:VCINSTALLDIR}bin\Hostx86\x86\cl.exe"

    if (-not (Test-Path $clPath32)) {
        Write-Host "警告: 找不到 32 位 cl.exe，跳過 32 位編譯" -ForegroundColor Yellow
    } else {
        $compileArgs32 = @(
            "/LD",
            "/MD",
            "/O2",
            "/EHsc",
            "/DMYMATH_EXPORTS",
            "`"$cppFile`"",
            "/DEF:`"$defFile`"",
            "/Fe:`"$dll32`""
        )

        $process32 = Start-Process -FilePath $clPath32 -ArgumentList $compileArgs32 -NoNewWindow -Wait -PassThru

        if ($process32.ExitCode -ne 0) {
            Write-Host ""
            Write-Host "32 位編譯失敗！" -ForegroundColor Red
        } else {
            Write-Host ""
            Write-Host "32 位編譯成功！" -ForegroundColor Green
            Write-Host "DLL 文件: $dll32" -ForegroundColor Green
            if (Test-Path $lib32) {
                Write-Host "LIB 文件: $lib32" -ForegroundColor Green
            }
        }
    }
} else {
    Write-Host ""
    Write-Host "警告: 找不到 32 位編譯環境，跳過 32 位編譯" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "=== 編譯完成 ===" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "64 位 DLL: $dll64" -ForegroundColor Green
if ($vcvars32Path -and (Test-Path (Join-Path $x86Dir "MyMath.dll"))) {
    Write-Host "32 位 DLL: $(Join-Path $x86Dir 'MyMath.dll')" -ForegroundColor Green
}
Write-Host ""
