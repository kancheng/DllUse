using System;
using System.Runtime.InteropServices;
using System.IO;

namespace CSharpCallPythonDLL
{
    class Program
    {
        // 獲取 DLL 路徑（僅支援 64 位）
        private static string GetDllPath()
        {
            string baseDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            if (string.IsNullOrEmpty(baseDir))
            {
                baseDir = AppDomain.CurrentDomain.BaseDirectory;
            }
            
            // 回到 python_wrapper/cpp_binding 目錄
            baseDir = Path.GetFullPath(Path.Combine(baseDir, "..", "..", "..", "cpp_binding"));
            
            string dllPath = Path.Combine(baseDir, "x64", "PythonBridge.dll");
            
            Console.WriteLine("運行時架構: 64位");
            Console.WriteLine($"使用 DLL: {dllPath}");
            Console.WriteLine();
            
            return dllPath;
        }
        
        // 導入 Python 橋接 DLL 的函數
        // 注意：DllImport 需要完整路徑或 DLL 在系統路徑中
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern int InitializePython();
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void FinalizePython();
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern int PythonAdd(int a, int b);
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern int PythonSubtract(int a, int b);
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern int PythonMultiply(int a, int b);
        
        [DllImport("PythonBridge.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern IntPtr PythonGetVersion();
        
        static void Main(string[] args)
        {
            Console.WriteLine("=== C# 調用 Python 封裝 DLL 範例 ===\n");
            
            // 獲取 DLL 路徑並設置 DLL 搜索路徑
            string dllPath = GetDllPath();
            string dllDir = Path.GetDirectoryName(dllPath);
            
            if (!string.IsNullOrEmpty(dllDir) && Directory.Exists(dllDir))
            {
                // 將 DLL 目錄添加到 PATH（僅對當前進程有效）
                string currentPath = Environment.GetEnvironmentVariable("PATH");
                if (!currentPath.Contains(dllDir))
                {
                    Environment.SetEnvironmentVariable("PATH", dllDir + Path.PathSeparator + currentPath);
                }
            }
            
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
        }
    }
}
