// 使用 pybind11 創建 C++ 接口，供 C++ 和 C# 調用
// 需要安裝 pybind11: pip install pybind11

#include <pybind11/pybind11.h>
#include <pybind11/embed.h>
#include <pybind11/stl.h>
#include <string>
#include <iostream>
#include <mutex>
#include <windows.h>

namespace py = pybind11;

// 全局 Python 解釋器狀態
static std::mutex python_mutex;
static bool python_initialized = false;
static py::module_ cached_math_module;

// 初始化 Python 解釋器（線程安全）
static bool EnsurePythonInitialized()
{
    std::lock_guard<std::mutex> lock(python_mutex);
    
    if (python_initialized && Py_IsInitialized()) {
        return true;
    }
    
    try {
        if (!Py_IsInitialized()) {
            // 設置 Python 模組搜索路徑
            // 獲取當前 DLL 所在目錄
            char dllPath[MAX_PATH];
            HMODULE hModule = NULL;
            if (GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                                   (LPSTR)&EnsurePythonInitialized, &hModule)) {
                GetModuleFileNameA(hModule, dllPath, MAX_PATH);
                std::string dllDir = dllPath;
                size_t pos = dllDir.find_last_of("\\/");
                if (pos != std::string::npos) {
                    dllDir = dllDir.substr(0, pos);
                    // 回到 python_wrapper 目錄
                    pos = dllDir.find_last_of("\\/");
                    if (pos != std::string::npos) {
                        dllDir = dllDir.substr(0, pos);
                        // 將 python_wrapper 目錄添加到 Python 路徑
                        py::module_ sys = py::module_::import("sys");
                        sys.attr("path").attr("append")(dllDir);
                    }
                }
            }
            
            py::initialize_interpreter();
            python_initialized = true;
            
            // 預加載 math_module
            try {
                cached_math_module = py::module_::import("math_module");
            } catch (...) {
                // 如果無法加載，稍後再試
            }
            
            return true;
        }
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Error initializing Python: " << e.what() << std::endl;
        return false;
    } catch (...) {
        std::cerr << "Unknown error initializing Python" << std::endl;
        return false;
    }
}

// 導出 C 風格的函數接口
extern "C" {
    // 初始化 Python 解釋器
    __declspec(dllexport) int InitializePython()
    {
        if (EnsurePythonInitialized()) {
            return 0; // 成功
        }
        return -1; // 失敗
    }
    
    // 清理 Python 解釋器
    __declspec(dllexport) void FinalizePython()
    {
        std::lock_guard<std::mutex> lock(python_mutex);
        if (Py_IsInitialized()) {
            try {
                cached_math_module = py::module_();
                py::finalize_interpreter();
                python_initialized = false;
            } catch (...) {
                // 忽略清理錯誤
            }
        }
    }
    
    // 調用 Python 的 add 函數
    __declspec(dllexport) int PythonAdd(int a, int b)
    {
        if (!EnsurePythonInitialized()) {
            return 0;
        }
        
        try {
            std::lock_guard<std::mutex> lock(python_mutex);
            
            // 如果模組未加載，嘗試加載
            if (cached_math_module.is_none()) {
                cached_math_module = py::module_::import("math_module");
            }
            
            py::object result = cached_math_module.attr("add")(a, b);
            return result.cast<int>();
        } catch (const std::exception& e) {
            std::cerr << "Error in PythonAdd: " << e.what() << std::endl;
            return 0;
        } catch (...) {
            std::cerr << "Unknown error in PythonAdd" << std::endl;
            return 0;
        }
    }
    
    // 調用 Python 的 subtract 函數
    __declspec(dllexport) int PythonSubtract(int a, int b)
    {
        if (!EnsurePythonInitialized()) {
            return 0;
        }
        
        try {
            std::lock_guard<std::mutex> lock(python_mutex);
            
            if (cached_math_module.is_none()) {
                cached_math_module = py::module_::import("math_module");
            }
            
            py::object result = cached_math_module.attr("subtract")(a, b);
            return result.cast<int>();
        } catch (const std::exception& e) {
            std::cerr << "Error in PythonSubtract: " << e.what() << std::endl;
            return 0;
        } catch (...) {
            std::cerr << "Unknown error in PythonSubtract" << std::endl;
            return 0;
        }
    }
    
    // 調用 Python 的 multiply 函數
    __declspec(dllexport) int PythonMultiply(int a, int b)
    {
        if (!EnsurePythonInitialized()) {
            return 0;
        }
        
        try {
            std::lock_guard<std::mutex> lock(python_mutex);
            
            if (cached_math_module.is_none()) {
                cached_math_module = py::module_::import("math_module");
            }
            
            py::object result = cached_math_module.attr("multiply")(a, b);
            return result.cast<int>();
        } catch (const std::exception& e) {
            std::cerr << "Error in PythonMultiply: " << e.what() << std::endl;
            return 0;
        } catch (...) {
            std::cerr << "Unknown error in PythonMultiply" << std::endl;
            return 0;
        }
    }
    
    // 獲取版本信息
    __declspec(dllexport) const char* PythonGetVersion()
    {
        static std::string cached_version;
        
        if (!EnsurePythonInitialized()) {
            return "Error: Python not initialized";
        }
        
        try {
            std::lock_guard<std::mutex> lock(python_mutex);
            
            if (cached_math_module.is_none()) {
                cached_math_module = py::module_::import("math_module");
            }
            
            py::object result = cached_math_module.attr("get_version")();
            cached_version = result.cast<std::string>();
            return cached_version.c_str();
        } catch (const std::exception& e) {
            cached_version = std::string("Error: ") + e.what();
            return cached_version.c_str();
        } catch (...) {
            return "Error getting version";
        }
    }
}

