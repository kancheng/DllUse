# CPP_DLL 封裝驗證腳本
# 使用 dumpbin 或 PowerShell 檢查 DLL 導出函數（支持 x64 和 x86）

Write-Host "=== CPP_DLL 封裝驗證 ===" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$x64Dll = Join-Path $scriptDir "x64\MyMath.dll"
$x86Dll = Join-Path $scriptDir "x86\MyMath.dll"

# 檢查 DLL 是否存在
$dllsToCheck = @()
if (Test-Path $x64Dll) {
    $dllsToCheck += @{Path = $x64Dll; Arch = "64位"}
    Write-Host "✓ 找到 64 位 DLL: $x64Dll" -ForegroundColor Green
}
if (Test-Path $x86Dll) {
    $dllsToCheck += @{Path = $x86Dll; Arch = "32位"}
    Write-Host "✓ 找到 32 位 DLL: $x86Dll" -ForegroundColor Green
}

if ($dllsToCheck.Count -eq 0) {
    Write-Host "錯誤: 找不到 MyMath.dll" -ForegroundColor Red
    Write-Host "請先編譯 DLL 項目（運行 build_dll.bat 或 build_dll.ps1）" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 預期的導出函數列表
$expectedExports = @("Add", "Subtract", "Multiply", "GetVersion")

Write-Host "預期的導出函數:" -ForegroundColor Yellow
foreach ($func in $expectedExports) {
    Write-Host "  - $func"
}
Write-Host ""

# 嘗試使用 dumpbin 檢查導出函數
$dumpbinPath = ""
$vcToolsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe"
)

foreach ($path in $vcToolsPaths) {
    $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $dumpbinPath = $found.FullName
        break
    }
}

if ($dumpbinPath -and (Test-Path $dumpbinPath)) {
    foreach ($dllInfo in $dllsToCheck) {
        Write-Host "檢查 $($dllInfo.Arch) DLL ($($dllInfo.Path))..." -ForegroundColor Yellow
        $output = & $dumpbinPath /EXPORTS $dllInfo.Path 2>&1
        
        $foundExports = @()
        foreach ($line in $output) {
            if ($line -match '^\s+\d+\s+[0-9A-F]+\s+[0-9A-F]+\s+(\w+)') {
                $funcName = $matches[1]
                if ($expectedExports -contains $funcName) {
                    $foundExports += $funcName
                    Write-Host "  ✓ 找到: $funcName" -ForegroundColor Green
                }
            }
        }
        
        Write-Host ""
        if ($foundExports.Count -eq $expectedExports.Count) {
            Write-Host "✓ $($dllInfo.Arch) DLL: 所有預期的函數都已導出" -ForegroundColor Green
        } else {
            Write-Host "✗ $($dllInfo.Arch) DLL: 缺少以下導出函數:" -ForegroundColor Red
            $missing = $expectedExports | Where-Object { $foundExports -notcontains $_ }
            foreach ($func in $missing) {
                Write-Host "  - $func" -ForegroundColor Red
            }
        }
        Write-Host ""
    }
} else {
    Write-Host "警告: 找不到 dumpbin.exe，跳過導出函數檢查" -ForegroundColor Yellow
    Write-Host "提示: 可以手動使用 dumpbin /EXPORTS x64\MyMath.dll 或 dumpbin /EXPORTS x86\MyMath.dll 檢查" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== 驗證完成 ===" -ForegroundColor Cyan
