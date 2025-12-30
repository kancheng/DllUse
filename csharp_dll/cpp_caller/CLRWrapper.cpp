// C++/CLI 包裝器範例
// 此文件需要在 Visual Studio 中設置為 C++/CLI 編譯（/clr）

#using <System.dll>
#using "CSharpDLL.dll"

using namespace System;
using namespace CSharpDLL;

// 導出 C 風格的函數供原生 C++ 調用
extern "C" {
    __declspec(dllexport) int AddNumbers(int a, int b)
    {
        Calculator^ calc = gcnew Calculator();
        return calc->Add(a, b);
    }
    
    __declspec(dllexport) int SubtractNumbers(int a, int b)
    {
        Calculator^ calc = gcnew Calculator();
        return calc->Subtract(a, b);
    }
    
    __declspec(dllexport) int MultiplyNumbers(int a, int b)
    {
        Calculator^ calc = gcnew Calculator();
        return calc->Multiply(a, b);
    }
}

