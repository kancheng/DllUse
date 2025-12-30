// 使用 pybind11 創建 C++ 接口，供 C++ 和 C# 調用
// 需要安裝 pybind11: pip install pybind11

#include <pybind11/pybind11.h>
#include <pybind11/embed.h>
#include <string>
#include <iostream>

namespace py = pybind11;

// 導出 C 風格的函數接口
extern "C" {
    // 初始化 Python 解釋器
    __declspec(dllexport) int InitializePython()
    {
        try {
            if (!Py_IsInitialized()) {
                py::initialize_interpreter();
                return 0; // 成功
            }
            return 1; // 已初始化
        } catch (...) {
            return -1; // 失敗
        }
    }
    
    // 清理 Python 解釋器
    __declspec(dllexport) void FinalizePython()
    {
        if (Py_IsInitialized()) {
            py::finalize_interpreter();
        }
    }
    
    // 調用 Python 的 add 函數
    __declspec(dllexport) int PythonAdd(int a, int b)
    {
        try {
            py::scoped_interpreter guard{};
            py::module_ math_module = py::module_::import("math_module");
            py::object result = math_module.attr("add")(a, b);
            return result.cast<int>();
        } catch (const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return 0;
        }
    }
    
    // 調用 Python 的 subtract 函數
    __declspec(dllexport) int PythonSubtract(int a, int b)
    {
        try {
            py::scoped_interpreter guard{};
            py::module_ math_module = py::module_::import("math_module");
            py::object result = math_module.attr("subtract")(a, b);
            return result.cast<int>();
        } catch (const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return 0;
        }
    }
    
    // 調用 Python 的 multiply 函數
    __declspec(dllexport) int PythonMultiply(int a, int b)
    {
        try {
            py::scoped_interpreter guard{};
            py::module_ math_module = py::module_::import("math_module");
            py::object result = math_module.attr("multiply")(a, b);
            return result.cast<int>();
        } catch (const std::exception& e) {
            std::cerr << "Error: " << e.what() << std::endl;
            return 0;
        }
    }
    
    // 獲取版本信息
    __declspec(dllexport) const char* PythonGetVersion()
    {
        try {
            py::scoped_interpreter guard{};
            py::module_ math_module = py::module_::import("math_module");
            py::object result = math_module.attr("get_version")();
            std::string version = result.cast<std::string>();
            // 注意：這裡返回的字符串需要確保生命週期
            static std::string cached_version;
            cached_version = version;
            return cached_version.c_str();
        } catch (const std::exception& e) {
            return "Error getting version";
        }
    }
}

