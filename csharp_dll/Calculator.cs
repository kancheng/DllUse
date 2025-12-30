using System;
using System.Runtime.InteropServices;

namespace CSharpDLL
{
    // 標記為 COM 可見，允許非託管代碼調用
    [ComVisible(true)]
    [Guid("12345678-1234-1234-1234-123456789ABC")]
    public interface ICalculator
    {
        int Add(int a, int b);
        int Subtract(int a, int b);
        int Multiply(int a, int b);
        string GetVersion();
    }

    // 實現類
    [ComVisible(true)]
    [Guid("87654321-4321-4321-4321-CBA987654321")]
    [ClassInterface(ClassInterfaceType.None)]
    [ProgId("CSharpDLL.Calculator")]
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
            return "C# Calculator DLL v1.0.0";
        }
    }
}

