// C++ 調用 C# DLL 範例（支持 32 位和 64 位）
// 使用 CLR 混合編譯（/clr）

#include <windows.h>
#include <iostream>
#include <string>

// 使用 CLR 支持
#using <System.dll>
#using <mscorlib.dll>

using namespace System;
using namespace System::Reflection;
using namespace System::IO;

// 根據運行時架構選擇 DLL
std::string GetDllPath()
{
    // 獲取當前可執行文件目錄
    char path[MAX_PATH];
    GetModuleFileNameA(NULL, path, MAX_PATH);
    std::string exePath(path);
    size_t pos = exePath.find_last_of("\\/");
    std::string exeDir = exePath.substr(0, pos);
    
    // 回到 csharp_dll 目錄
    pos = exeDir.find_last_of("\\/");
    std::string baseDir = exeDir.substr(0, pos);
    
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
    
    std::string dllPath = dllDir + "\\CSharpDLL.dll";
    
    // 如果架構目錄中沒有，嘗試 Release 目錄
    if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
    {
        if (is64Bit)
        {
            dllPath = baseDir + "\\bin\\Release\\x64\\net8.0\\CSharpDLL.dll";
        }
        else
        {
            dllPath = baseDir + "\\bin\\Release\\x86\\net8.0\\CSharpDLL.dll";
        }
    }
    
    std::cout << "運行時架構: " << (is64Bit ? "64位" : "32位") << std::endl;
    std::cout << "使用 DLL: " << dllPath << " (" << arch << ")" << std::endl;
    std::cout << std::endl;
    
    return dllPath;
}

int main()
{
    std::cout << "=== C++ 調用 C# DLL 範例 ===" << std::endl << std::endl;
    
    try
    {
        // 獲取 DLL 路徑
        std::string dllPath = GetDllPath();
        
        // 檢查文件是否存在
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
        {
            std::cout << "錯誤: 找不到 DLL: " << dllPath << std::endl;
            std::cout << "請確保已編譯 C# DLL（運行 build_dll.bat）" << std::endl;
            return 1;
        }
        
        // 加載程序集
        Assembly^ assembly = Assembly::LoadFrom(gcnew String(dllPath.c_str()));
        
        // 獲取 Calculator 類型
        Type^ calcType = assembly->GetType("CSharpDLL.Calculator");
        
        // 創建實例
        Object^ calcObj = Activator::CreateInstance(calcType);
        
        // 獲取方法
        MethodInfo^ addMethod = calcType->GetMethod("Add");
        MethodInfo^ subtractMethod = calcType->GetMethod("Subtract");
        MethodInfo^ multiplyMethod = calcType->GetMethod("Multiply");
        MethodInfo^ getVersionMethod = calcType->GetMethod("GetVersion");
        
        // 調用 Add 方法
        array<Object^>^ addArgs = gcnew array<Object^>(2);
        addArgs[0] = 10;
        addArgs[1] = 20;
        Object^ addResult = addMethod->Invoke(calcObj, addArgs);
        std::cout << "Add(10, 20) = " << safe_cast<int>(addResult) << std::endl;
        
        // 調用 Subtract 方法
        array<Object^>^ subArgs = gcnew array<Object^>(2);
        subArgs[0] = 30;
        subArgs[1] = 15;
        Object^ subResult = subtractMethod->Invoke(calcObj, subArgs);
        std::cout << "Subtract(30, 15) = " << safe_cast<int>(subResult) << std::endl;
        
        // 調用 Multiply 方法
        array<Object^>^ mulArgs = gcnew array<Object^>(2);
        mulArgs[0] = 5;
        mulArgs[1] = 6;
        Object^ mulResult = multiplyMethod->Invoke(calcObj, mulArgs);
        std::cout << "Multiply(5, 6) = " << safe_cast<int>(mulResult) << std::endl;
        
        // 調用 GetVersion 方法
        Object^ versionResult = getVersionMethod->Invoke(calcObj, nullptr);
        String^ version = safe_cast<String^>(versionResult);
        std::cout << "Version: " << std::endl;
        pin_ptr<const char> versionPtr = PtrToStringChars(version);
        std::cout << versionPtr << std::endl;
        
        std::cout << std::endl << "測試完成！" << std::endl;
    }
    catch (Exception^ ex)
    {
        std::cout << "錯誤: " << std::endl;
        pin_ptr<const char> errorMsg = PtrToStringChars(ex->Message);
        std::cout << errorMsg << std::endl;
        return 1;
    }
    
    return 0;
}
