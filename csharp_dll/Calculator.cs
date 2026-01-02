using System;
using System.Runtime.InteropServices;

namespace CSharpDLL
{
    // 接口：所有版本都需要
    public interface ICalculator
    {
        int Add(int a, int b);
        int Subtract(int a, int b);
        int Multiply(int a, int b);
        string GetVersion();
    }

    // COM 接口（僅 net8.0 版本）
#if COM_EXPORT
    [ComVisible(true)]
    [Guid("12345678-1234-1234-1234-123456789ABC")]
    public interface ICalculatorCOM : ICalculator
    {
    }
#endif

    // 實現類（非 COM 版本，給 Python/C++ 使用）
#if COM_EXPORT
    [ComVisible(false)]  // 明確標記為不可見
#endif
    public class Calculator : ICalculator
    {
        public int Add(int a, int b)
        {
            return a + b;
        }

        public int Subtract(int a, int b)
        {
            return a - b;
        }

        public int Multiply(int a, int b)
        {
            return a * b;
        }

        public string GetVersion()
        {
#if NET8_0
            return "C# Calculator DLL v1.0.0 (net8.0)";
#elif NET48
            return "C# Calculator DLL v1.0.0 (net48)";
#else
            return "C# Calculator DLL v1.0.0";
#endif
        }
    }

    // COM 可見的 Calculator（僅 net8.0 版本，用於 COM/LabVIEW）
#if COM_EXPORT
    [ComVisible(true)]
    [Guid("87654321-4321-4321-4321-CBA987654321")]
    [ClassInterface(ClassInterfaceType.None)]
    [ProgId("CSharpDLL.Calculator")]
    public class CalculatorCOM : ICalculatorCOM
    {
        private Calculator _calc = new Calculator();
        
        public int Add(int a, int b) => _calc.Add(a, b);
        public int Subtract(int a, int b) => _calc.Subtract(a, b);
        public int Multiply(int a, int b) => _calc.Multiply(a, b);
        public string GetVersion() => _calc.GetVersion();
    }
#endif
}

