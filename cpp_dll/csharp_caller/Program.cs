using System;
using System.Runtime.InteropServices;

namespace CSharpCaller
{
    class Program
    {
        // 使用 DllImport 特性導入 C++ DLL 中的函數
        [DllImport("MyMath.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int Add(int a, int b);
        
        [DllImport("MyMath.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int Subtract(int a, int b);
        
        [DllImport("MyMath.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int Multiply(int a, int b);
        
        [DllImport("MyMath.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr GetVersion();
        
        static void Main(string[] args)
        {
            Console.WriteLine("=== C# 調用 C++ DLL 範例 ===\n");
            
            // 調用加法函數
            int sum = Add(10, 20);
            Console.WriteLine($"Add(10, 20) = {sum}");
            
            // 調用減法函數
            int diff = Subtract(30, 15);
            Console.WriteLine($"Subtract(30, 15) = {diff}");
            
            // 調用乘法函數
            int product = Multiply(5, 6);
            Console.WriteLine($"Multiply(5, 6) = {product}");
            
            // 獲取版本信息
            IntPtr versionPtr = GetVersion();
            string version = Marshal.PtrToStringAnsi(versionPtr);
            Console.WriteLine($"Version: {version}");
            
            Console.WriteLine("\n測試完成！");
        }
    }
}

