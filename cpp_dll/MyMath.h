#pragma once

#ifdef MYMATH_EXPORTS
#define MYMATH_API __declspec(dllexport)
#else
#define MYMATH_API __declspec(dllimport)
#endif

// 使用 extern "C" 防止 C++ 名字修飾，確保 C 語言兼容性
extern "C" {
    // 加法函數
    MYMATH_API int Add(int a, int b);
    
    // 減法函數
    MYMATH_API int Subtract(int a, int b);
    
    // 乘法函數
    MYMATH_API int Multiply(int a, int b);
    
    // 獲取版本信息
    MYMATH_API const char* GetVersion();
}

