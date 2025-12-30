using System;
using System.Runtime.InteropServices;

namespace CSharpCallPythonDLL
{
    class Program
    {
        // 導入 Python 橋接 DLL 的函數
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int InitializePython();
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void FinalizePython();
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int PythonAdd(int a, int b);
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int PythonSubtract(int a, int b);
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern int PythonMultiply(int a, int b);
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr PythonGetVersion();
        
        static void Main(string[] args)
        {
            Console.WriteLine("=== C# 調用 Python 封裝 DLL 範例 ===\n");
            
            // 初始化 Python 解釋器
            int initResult = InitializePython();
            if (initResult < 0)
            {
                Console.WriteLine("錯誤：無法初始化 Python 解釋器");
                return;
            }
            
            try
            {
                // 調用 Python 函數
                int result = PythonAdd(10, 20);
                Console.WriteLine($"PythonAdd(10, 20) = {result}");
                
                result = PythonSubtract(30, 15);
                Console.WriteLine($"PythonSubtract(30, 15) = {result}");
                
                result = PythonMultiply(5, 6);
                Console.WriteLine($"PythonMultiply(5, 6) = {result}");
                
                IntPtr versionPtr = PythonGetVersion();
                string version = Marshal.PtrToStringAnsi(versionPtr);
                Console.WriteLine($"Version: {version}");
            }
            finally
            {
                // 清理 Python 解釋器
                FinalizePython();
            }
            
            Console.WriteLine("\n測試完成！");
            Console.WriteLine("按任意鍵退出...");
            Console.ReadKey();
        }
    }
}

