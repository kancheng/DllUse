// C++ 調用 Python 封裝 DLL 範例（支持 32 位和 64 位）

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

// 根據運行時架構選擇 DLL
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
    std::string baseDir = exeDir.substr(0, pos);
    pos = baseDir.find_last_of("\\/");
    baseDir = baseDir.substr(0, pos);
    baseDir = baseDir + "\\cpp_binding";
    
    // 檢測運行時架構
    #ifdef _WIN64
        bool is64Bit = true;
    #else
        bool is64Bit = false;
    #endif
    
    std::string dllDir;
    std::string arch;
    
    if (is64Bit)
    {
        dllDir = baseDir + "\\x64";
        arch = "64位";
    }
    else
    {
        dllDir = baseDir + "\\x86";
        arch = "32位";
    }
    
    std::string dllPath = dllDir + "\\PythonBridge.dll";
    
    // 如果架構目錄中沒有，嘗試 build 目錄
    if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
    {
        if (is64Bit)
        {
            dllPath = baseDir + "\\build_x64\\Release\\PythonBridge.dll";
        }
        else
        {
            dllPath = baseDir + "\\build_x86\\Release\\PythonBridge.dll";
        }
    }
    
    std::cout << "運行時架構: " << (is64Bit ? "64位" : "32位") << std::endl;
    std::cout << "使用 DLL: " << dllPath << " (" << arch << ")" << std::endl;
    std::cout << std::endl;
    
    return dllPath;
}

int main()
{
    std::cout << "=== C++ 調用 Python 封裝 DLL 範例 ===" << std::endl << std::endl;
    
    // 獲取 DLL 路徑
    std::string dllPath = GetDllPath();
    
    // 檢查文件是否存在
    if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
    {
        std::cout << "錯誤: 找不到 DLL: " << dllPath << std::endl;
        std::cout << "請確保已編譯 Python Bridge DLL（運行 build_dll.bat）" << std::endl;
        return 1;
    }
    
    // 加載 DLL
    HMODULE hModule = LoadLibraryA(dllPath.c_str());
    if (hModule == NULL)
    {
        std::cout << "錯誤: 無法加載 DLL: " << dllPath << std::endl;
        std::cout << "錯誤代碼: " << GetLastError() << std::endl;
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
        std::cout << "錯誤: 無法獲取 DLL 函數地址" << std::endl;
        FreeLibrary(hModule);
        return 1;
    }
    
    // 初始化 Python 解釋器
    int init_result = InitializePython();
    if (init_result < 0) {
        std::cerr << "錯誤：無法初始化 Python 解釋器" << std::endl;
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
        std::cerr << "錯誤：調用 Python 函數時發生異常" << std::endl;
    }
    
    // 清理 Python 解釋器
    FinalizePython();
    
    // 釋放 DLL
    FreeLibrary(hModule);
    
    std::cout << std::endl << "測試完成！" << std::endl;
    
    return 0;
}
