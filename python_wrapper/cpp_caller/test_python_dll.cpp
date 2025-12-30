#include <windows.h>
#include <iostream>

// 導入 Python 橋接 DLL 的函數
extern "C" {
    __declspec(dllimport) int InitializePython();
    __declspec(dllimport) void FinalizePython();
    __declspec(dllimport) int PythonAdd(int a, int b);
    __declspec(dllimport) int PythonSubtract(int a, int b);
    __declspec(dllimport) int PythonMultiply(int a, int b);
    __declspec(dllimport) const char* PythonGetVersion();
}

int main()
{
    std::cout << "=== C++ 調用 Python 封裝 DLL 範例 ===" << std::endl << std::endl;
    
    // 初始化 Python 解釋器
    int init_result = InitializePython();
    if (init_result < 0) {
        std::cerr << "錯誤：無法初始化 Python 解釋器" << std::endl;
        return 1;
    }
    
    // 調用 Python 函數
    int result = PythonAdd(10, 20);
    std::cout << "PythonAdd(10, 20) = " << result << std::endl;
    
    result = PythonSubtract(30, 15);
    std::cout << "PythonSubtract(30, 15) = " << result << std::endl;
    
    result = PythonMultiply(5, 6);
    std::cout << "PythonMultiply(5, 6) = " << result << std::endl;
    
    const char* version = PythonGetVersion();
    std::cout << "Version: " << version << std::endl;
    
    // 清理 Python 解釋器
    FinalizePython();
    
    std::cout << std::endl << "測試完成！" << std::endl;
    
    return 0;
}

