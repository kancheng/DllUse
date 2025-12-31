# 編譯並運行 C# 調用程序

Write-Host "=== 編譯並運行 C# 調用程序 ===" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# 注意：不再需要複製 DLL，因為 Program.cs 會自動根據運行時架構選擇 x64 或 x86 目錄中的 DLL
Write-Host "提示: DLL 會根據運行時架構自動從 x64 或 x86 目錄加載" -ForegroundColor Yellow

# 嘗試使用 Visual Studio 的 csc
$cscPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\Roslyn\csc.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\Roslyn\csc.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn\csc.exe"
)

$cscPath = $null
foreach ($path in $cscPaths) {
    if (Test-Path $path) {
        $cscPath = $path
        break
    }
}

if ($cscPath) {
    Write-Host "找到 C# 編譯器: $cscPath" -ForegroundColor Green
    Write-Host "編譯 Program.cs..." -ForegroundColor Yellow
    
    & $cscPath Program.cs /out:Program.exe /platform:x64
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "編譯成功！" -ForegroundColor Green
        Write-Host ""
        Write-Host "=== 運行程序 ===" -ForegroundColor Cyan
        & .\Program.exe
    } else {
        Write-Host "編譯失敗！" -ForegroundColor Red
    }
} else {
    Write-Host "找不到 C# 編譯器" -ForegroundColor Yellow
    Write-Host "請使用以下方法之一：" -ForegroundColor Yellow
    Write-Host "1. 在 Visual Studio Developer Command Prompt 中運行: csc Program.cs" -ForegroundColor Yellow
    Write-Host "2. 使用 dotnet: dotnet build" -ForegroundColor Yellow
}

