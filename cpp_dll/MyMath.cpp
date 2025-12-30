#include "MyMath.h"
#include <string>

// 定義導出函數
extern "C" {
    int Add(int a, int b) {
        return a + b;
    }
    
    int Subtract(int a, int b) {
        return a - b;
    }
    
    int Multiply(int a, int b) {
        return a * b;
    }
    
    const char* GetVersion() {
        return "MyMath DLL v1.0.0";
    }
}

