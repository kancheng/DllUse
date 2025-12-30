#include <windows.h>
#include <iostream>
#include <comdef.h>
#include <comutil.h>

// 導入 C# DLL 的 COM 接口
// 注意：需要先使用 regasm 或 regsvr32 註冊 DLL，或使用 TlbImp 生成類型庫
// 這裡使用簡化的 COM 調用方式

// 如果使用 TlbImp 生成的類型庫，可以這樣導入：
// #import "CSharpDLL.tlb" no_namespace

// 或者使用 COM 直接調用（需要先註冊）
// 這裡提供一個使用 CLR 託管代碼的替代方案

int main()
{
    std::cout << "=== C++ 調用 C# DLL 範例 ===" << std::endl << std::endl;
    
    // 方法 1: 使用 CLR 混合編程（需要啟用 /clr）
    // 這需要在 Visual Studio 項目設置中啟用公共語言運行時支持
    
    // 方法 2: 使用 COM 互操作性（需要註冊 DLL）
    // 1. 使用 regasm 註冊：regasm CSharpDLL.dll /codebase
    // 2. 使用 TlbImp 生成類型庫：tlbimp CSharpDLL.dll
    
    // 方法 3: 使用 C++/CLI 包裝器（推薦）
    // 創建一個 C++/CLI 包裝器 DLL，然後從原生 C++ 調用
    
    std::cout << "C++ 調用 C# DLL 需要以下步驟之一：" << std::endl;
    std::cout << "1. 使用 regasm 註冊 DLL 後通過 COM 調用" << std::endl;
    std::cout << "2. 使用 C++/CLI 創建包裝器" << std::endl;
    std::cout << "3. 使用 CLR 混合編譯（/clr）" << std::endl;
    
    // 示例：如果已註冊 COM，可以使用以下代碼（需要正確的 GUID）
    /*
    HRESULT hr;
    ICalculator* pCalc = nullptr;
    
    hr = CoCreateInstance(
        CLSID_Calculator,  // 需要從類型庫獲取
        NULL,
        CLSCTX_INPROC_SERVER,
        IID_ICalculator,    // 需要從類型庫獲取
        (void**)&pCalc
    );
    
    if (SUCCEEDED(hr)) {
        int result = pCalc->Add(10, 20);
        std::cout << "Add(10, 20) = " << result << std::endl;
        pCalc->Release();
    }
    */
    
    std::cout << std::endl << "請參考 README.md 了解詳細步驟" << std::endl;
    
    return 0;
}

