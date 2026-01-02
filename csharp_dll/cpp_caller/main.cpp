// C++ 調用 C# DLL 範例（支持 32 位和 64 位）
// 使用 CLR 混合編譯（/clr）

#include <windows.h>
#include <iostream>
#include <string>

// 使用 CLR 支持
#using <System.dll>
#using <mscorlib.dll>
#include <vcclr.h>

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
    
    // 回到 csharp_dll 目錄（從 cpp_caller/x64 或 cpp_caller/x86）
    pos = exeDir.find_last_of("\\/");
    std::string callerDir = exeDir.substr(0, pos);
    pos = callerDir.find_last_of("\\/");
    std::string baseDir = callerDir.substr(0, pos);
    
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
        arch = "64bit";
    }
    else
    {
        dllDir = baseDir + "\\x86";
        arch = "32bit";
    }
    
    // 優先使用 net48 版本（與 .NET Framework CLR 兼容）
    std::string dllPath;
    if (is64Bit)
    {
        dllPath = baseDir + "\\x64\\net48\\CSharpDLL.dll";
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
        {
            dllPath = baseDir + "\\bin\\Release\\x64\\net48\\CSharpDLL.dll";
        }
    }
    else
    {
        dllPath = baseDir + "\\x86\\net48\\CSharpDLL.dll";
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
        {
            dllPath = baseDir + "\\bin\\Release\\x86\\net48\\CSharpDLL.dll";
        }
    }
    
    std::cout << "Runtime Architecture: " << (is64Bit ? "64-bit" : "32-bit") << std::endl;
    std::cout << "Using DLL: " << dllPath << " (" << arch << ")" << std::endl;
    std::cout << std::endl;
    
    return dllPath;
}

int main()
{
    std::cout << "=== C++ Calling C# DLL Example ===" << std::endl << std::endl;
    
    try
    {
        // 獲取 DLL 路徑
        std::string dllPath = GetDllPath();
        
        // 檢查文件是否存在
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES)
        {
            std::cout << "Error: Cannot find DLL: " << dllPath << std::endl;
            std::cout << "Please ensure C# DLL is compiled (run build_dll.bat)" << std::endl;
            return 1;
        }
        
        // 加載程序集
        String^ dllPathStr = gcnew String(dllPath.c_str());
        std::cout << "Loading assembly from: " << dllPath << std::endl;
        
        Assembly^ assembly = nullptr;
        try {
            assembly = Assembly::LoadFrom(dllPathStr);
            std::cout << "Assembly loaded successfully" << std::endl;
        }
        catch (Exception^ ex) {
            std::wcout << L"Failed to load assembly: ";
            pin_ptr<const wchar_t> errorMsg = PtrToStringChars(ex->Message);
            std::wcout << errorMsg << std::endl;
            return 1;
        }
        
        // 獲取 Calculator 類型
        // 使用反射查找類型，避免 GetType 的問題
        Type^ calcType = nullptr;
        try {
            // 方法1: 直接使用 GetType
            calcType = assembly->GetType("CSharpDLL.Calculator");
        }
        catch (...) {
            // 如果失敗，嘗試方法2: 遍歷所有類型
            try {
                array<Type^>^ types = assembly->GetExportedTypes();
                for (int i = 0; i < types->Length; i++) {
                    String^ fullName = types[i]->FullName;
                    if (fullName != nullptr && fullName->Contains("Calculator")) {
                        calcType = types[i];
                        std::cout << "Found type: ";
                        pin_ptr<const wchar_t> typeName = PtrToStringChars(fullName);
                        std::wcout << typeName << std::endl;
                        break;
                    }
                }
            }
            catch (Exception^ ex) {
                std::wcout << L"Error enumerating types: ";
                try {
                    pin_ptr<const wchar_t> errorMsg = PtrToStringChars(ex->Message);
                    std::wcout << errorMsg << std::endl;
                }
                catch (...) {
                    std::cout << "Cannot get error message" << std::endl;
                }
            }
        }
        
        if (calcType == nullptr) {
            std::cout << "Error: Cannot find Calculator type" << std::endl;
            return 1;
        }
        
        // 創建實例
        Object^ calcObj = Activator::CreateInstance(calcType);
        if (calcObj == nullptr) {
            std::cout << "Error: Cannot create Calculator instance" << std::endl;
            return 1;
        }
        
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
        pin_ptr<const wchar_t> versionPtr = PtrToStringChars(version);
        std::wcout << L"Version: " << versionPtr << std::endl;
        
        std::cout << std::endl << "Test completed!" << std::endl;
    }
    catch (Exception^ ex)
    {
        std::wcout << L"Error: ";
        if (ex != nullptr)
        {
            try {
                pin_ptr<const wchar_t> errorMsg = PtrToStringChars(ex->Message);
                std::wcout << errorMsg << std::endl;
            }
            catch (...) {
                std::wcout << L"Error getting message" << std::endl;
            }
        }
        else
        {
            std::wcout << L"Unknown error" << std::endl;
        }
        return 1;
    }
    catch (const std::exception& e)
    {
        std::cout << "C++ Exception: " << e.what() << std::endl;
        return 1;
    }
    catch (...)
    {
        std::cout << "Unknown exception occurred" << std::endl;
        return 1;
    }
    
    return 0;
}
