// C++ 調用 C# DLL 範例（簡化版本，使用 #using）
// 使用 CLR 混合編譯（/clr）

#include <windows.h>
#include <iostream>
#include <string>

// 使用 CLR 支持並直接引用 DLL
#using <System.dll>
#using <mscorlib.dll>
#include <vcclr.h>

using namespace System;
using namespace System::Reflection;
using namespace System::IO;

// 根據運行時架構選擇 DLL 路徑
std::string GetDllPath()
{
    char path[MAX_PATH];
    GetModuleFileNameA(NULL, path, MAX_PATH);
    std::string exePath(path);
    size_t pos = exePath.find_last_of("\\/");
    std::string exeDir = exePath.substr(0, pos);
    
    // 回到 csharp_dll 目錄
    pos = exeDir.find_last_of("\\/");
    std::string callerDir = exeDir.substr(0, pos);
    pos = callerDir.find_last_of("\\/");
    std::string baseDir = callerDir.substr(0, pos);
    
    #ifdef _WIN64
        bool is64Bit = true;
    #else
        bool is64Bit = false;
    #endif
    
    std::string dllPath;
    if (is64Bit) {
        // 優先使用 net48 版本（與 .NET Framework CLR 兼容）
        dllPath = baseDir + "\\x64\\net48\\CSharpDLL.dll";
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            dllPath = baseDir + "\\x64\\CSharpDLL.dll";  // 應該指向 net48
        }
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            dllPath = baseDir + "\\bin\\Release\\x64\\net48\\CSharpDLL.dll";
        }
    } else {
        // 優先使用 net48 版本
        dllPath = baseDir + "\\x86\\net48\\CSharpDLL.dll";
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            dllPath = baseDir + "\\x86\\CSharpDLL.dll";  // 應該指向 net48
        }
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            dllPath = baseDir + "\\bin\\Release\\x86\\net48\\CSharpDLL.dll";
        }
    }
    
    return dllPath;
}

int main()
{
    std::cout << "=== C++ Calling C# DLL Example ===" << std::endl << std::endl;
    
    try
    {
        std::string dllPath = GetDllPath();
        std::cout << "Using DLL: " << dllPath << std::endl;
        
        // 檢查文件是否存在
        if (GetFileAttributesA(dllPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            std::cout << "Error: DLL file not found: " << dllPath << std::endl;
            return 1;
        }
        
        // 加載程序集 - 使用完整路徑
        String^ dllPathStr = gcnew String(dllPath.c_str());
        Assembly^ assembly = nullptr;
        try {
            assembly = Assembly::LoadFrom(dllPathStr);
            std::cout << "Assembly loaded successfully" << std::endl;
        }
        catch (Exception^ ex) {
            std::wcout << L"Failed to load assembly: ";
            try {
                pin_ptr<const wchar_t> errorMsg = PtrToStringChars(ex->Message);
                std::wcout << errorMsg << std::endl;
            }
            catch (...) {
                std::cout << "Cannot get error message" << std::endl;
            }
            return 1;
        }
        
        // 先宣告，避免作用域造成的未声明标识符错误
        array<Exception^>^ loaderExs = nullptr;

        // 使用反射獲取類型 - 使用完整類型名
        Type^ calcType = nullptr;
        try {
            // 使用完整類型名：CSharpDLL.Calculator
            calcType = assembly->GetType("CSharpDLL.Calculator", true);  // true = throwOnError
            std::cout << "Found type: CSharpDLL.Calculator" << std::endl;
        }
        catch (Exception^ ex) {
            std::wcout << L"Error getting type CSharpDLL.Calculator: ";
            try {
                pin_ptr<const wchar_t> errorMsg = PtrToStringChars(ex->Message);
                std::wcout << errorMsg << std::endl;
            }
            catch (...) {
                std::cout << "Cannot get error message" << std::endl;
            }
            
            // 嘗試使用 GetExportedTypes
            try {
                std::cout << "Trying GetExportedTypes..." << std::endl;
                array<Type^>^ types = assembly->GetExportedTypes();
                std::cout << "Found " << types->Length << " exported types" << std::endl;
                for (int i = 0; i < types->Length; i++) {
                    try {
                        String^ fullName = types[i]->FullName;
                        if (fullName != nullptr && fullName->Contains("Calculator")) {
                            calcType = types[i];
                            pin_ptr<const wchar_t> typeName = PtrToStringChars(fullName);
                            std::wcout << L"Found Calculator type: " << typeName << std::endl;
                            break;
                        }
                    }
                    catch (...) {
                        continue;
                    }
                }
            }
            catch (ReflectionTypeLoadException^ rtle) {
                std::wcout << L"ReflectionTypeLoadException caught!" << std::endl;
                std::wcout << L"Message: ";
                try {
                    pin_ptr<const wchar_t> errorMsg = PtrToStringChars(rtle->Message);
                    std::wcout << errorMsg << std::endl;
                }
                catch (...) {
                    std::cout << "Cannot get message" << std::endl;
                }
                
                // 打印 LoaderExceptions（關鍵！）
                loaderExs = rtle->LoaderExceptions;
                if (loaderExs != nullptr && loaderExs->Length > 0) {
                    std::wcout << L"LoaderExceptions (" << loaderExs->Length << L"):" << std::endl;
                    for (int i = 0; i < loaderExs->Length && i < 5; i++) {
                        if (loaderExs[i] != nullptr) {
                            try {
                                pin_ptr<const wchar_t> exMsg = PtrToStringChars(loaderExs[i]->Message);
                                std::wcout << L"  [" << i << L"] " << exMsg << std::endl;
                            }
                            catch (...) {
                                std::cout << "  [" << i << "] (cannot get message)" << std::endl;
                            }
                        }
                    }
                }
            }
            catch (Exception^ ex) {
                std::wcout << L"Error in GetExportedTypes: ";
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
        try {
            pin_ptr<const wchar_t> errorMsg = PtrToStringChars(ex->Message);
            std::wcout << errorMsg << std::endl;
        }
        catch (...) {
            std::cout << "Error occurred but cannot get message" << std::endl;
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
