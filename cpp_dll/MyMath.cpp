#include "MyMath.h"

// 定義導出函數
extern "C" {
    MYMATH_API int Add(int a, int b) {
        return a + b;
    }
    
    MYMATH_API int Subtract(int a, int b) {
        return a - b;
    }
    
    MYMATH_API int Multiply(int a, int b) {
        return a * b;
    }
    
    MYMATH_API const char* GetVersion() {
        return "MyMath DLL v1.0.0";
    }
}

