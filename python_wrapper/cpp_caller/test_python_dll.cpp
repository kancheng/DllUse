// C++ Calling Python Bridge DLL Example (64-bit only)

#include <windows.h>
#include <iostream>
#include <string>

// 導入 Python 橋接 DLL 的函數
extern "C" {
    __declspec(dllimport) int InitializePython();
    __declspec(dllimport) void FinalizePython();
    __declspec(dllimport) int PythonAdd(int a, int b);
    __declspec(dllimport) int PythonSubtract(int a, int b);
    __declspec(dllimport) int PythonMultiply(int a, int b);
    __declspec(dllimport) const char* PythonGetVersion();
}

// 獲取 DLL 路徑（僅支援 64 位）
std::string GetDllPath()
{
    // 獲取當前可執行文件目錄
    char path[MAX_PATH];
    GetModuleFileNameA(NULL, path, MAX_PATH);
    std::string exePath(path);
    size_t pos = exePath.find_last_of("\\/");
    std::string exeDir = exePath.substr(0, pos);
    
    // 回到 python_wrapper/cpp_binding 目錄
    pos = exeDir.find_last_of("\\/");
    std::string callerDir = exeDir.substr(0, pos);
    pos = callerDir.find_last_of("\\/");
    std::string baseDir = callerDir.substr(0, pos);
    baseDir = baseDir + "\\cpp_binding";
    
    std::string dllPath = baseDir + "\\x64\\PythonBridge.dll";
    
    std::cout << "Runtime Architecture: 64-bit" << std::endl;
    std::cout << "Using DLL: " << dllPath << std::endl;
    std::cout << std::endl;
    
    return dllPath;
}

int main()
{
    std::cout << "=== C++ Calling Python Bridge DLL Example ===" << std::endl << std::endl;
    
    // 獲取 DLL 路徑
    std::string dllPath = GetDllPath();
    
    // 檢查文件是否存在
    if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
    {
        std::cout << "Error: Cannot find DLL: " << dllPath << std::endl;
        std::cout << "Please ensure Python Bridge DLL is compiled (run build_dll.bat)" << std::endl;
        return 1;
    }
    
    // 加載 DLL
    HMODULE hModule = LoadLibraryA(dllPath.c_str());
    if (hModule == NULL)
    {
        std::cout << "Error: Cannot load DLL: " << dllPath << std::endl;
        std::cout << "Error code: " << GetLastError() << std::endl;
        return 1;
    }
    
    // 獲取函數指針
    typedef int (*InitFunc)();
    typedef void (*FinalizeFunc)();
    typedef int (*AddFunc)(int, int);
    typedef int (*SubtractFunc)(int, int);
    typedef int (*MultiplyFunc)(int, int);
    typedef const char* (*GetVersionFunc)();
    
    InitFunc InitializePython = (InitFunc)GetProcAddress(hModule, "InitializePython");
    FinalizeFunc FinalizePython = (FinalizeFunc)GetProcAddress(hModule, "FinalizePython");
    AddFunc PythonAdd = (AddFunc)GetProcAddress(hModule, "PythonAdd");
    SubtractFunc PythonSubtract = (SubtractFunc)GetProcAddress(hModule, "PythonSubtract");
    MultiplyFunc PythonMultiply = (MultiplyFunc)GetProcAddress(hModule, "PythonMultiply");
    GetVersionFunc PythonGetVersion = (GetVersionFunc)GetProcAddress(hModule, "PythonGetVersion");
    
    if (!InitializePython || !FinalizePython || !PythonAdd || !PythonSubtract || !PythonMultiply || !PythonGetVersion)
    {
        std::cout << "Error: Cannot get DLL function addresses" << std::endl;
        FreeLibrary(hModule);
        return 1;
    }
    
    // 初始化 Python 解釋器
    int init_result = InitializePython();
    if (init_result < 0) {
        std::cerr << "Error: Cannot initialize Python interpreter" << std::endl;
        FreeLibrary(hModule);
        return 1;
    }
    
    try
    {
        // 調用 Python 函數
        int result = PythonAdd(10, 20);
        std::cout << "PythonAdd(10, 20) = " << result << std::endl;
        
        result = PythonSubtract(30, 15);
        std::cout << "PythonSubtract(30, 15) = " << result << std::endl;
        
        result = PythonMultiply(5, 6);
        std::cout << "PythonMultiply(5, 6) = " << result << std::endl;
        
        const char* version = PythonGetVersion();
        std::cout << "Version: " << version << std::endl;
    }
    catch (...)
    {
        std::cerr << "Error: Exception occurred while calling Python functions" << std::endl;
    }
    
    // 清理 Python 解釋器
    FinalizePython();
    
    // 釋放 DLL
    FreeLibrary(hModule);
    
    std::cout << std::endl << "Test completed!" << std::endl;
    
    return 0;
}
