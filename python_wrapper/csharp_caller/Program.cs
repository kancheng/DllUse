using System;
using System.Runtime.InteropServices;
using System.IO;

namespace CSharpCallPythonDLL
{
    class Program
    {
        // 使用 NativeLibrary.Load 預先載入 DLL
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool SetDllDirectory(string lpPathName);
        
        // 獲取 DLL 路徑（僅支援 64 位）
        private static string GetDllPath()
        {
            string baseDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            if (string.IsNullOrEmpty(baseDir))
            {
                baseDir = AppDomain.CurrentDomain.BaseDirectory;
            }
            
            // 從 csharp_caller/x64 回到 python_wrapper/cpp_binding/x64
            // 路徑結構: .../python_wrapper/csharp_caller/x64 -> .../python_wrapper/cpp_binding/x64
            baseDir = Path.GetFullPath(Path.Combine(baseDir, "..", "..", "cpp_binding", "x64"));
            
            string dllPath = Path.Combine(baseDir, "PythonBridge.dll");
            
            Console.WriteLine("運行時架構: 64位");
            Console.WriteLine($"使用 DLL: {dllPath}");
            Console.WriteLine($"DLL 是否存在: {File.Exists(dllPath)}");
            Console.WriteLine();
            
            return dllPath;
        }
        
        // 導入 Python 橋接 DLL 的函數
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
            
            // 獲取 DLL 路徑
            string dllPath = GetDllPath();
            string dllDir = Path.GetDirectoryName(dllPath);
            
            if (!File.Exists(dllPath))
            {
                Console.WriteLine($"錯誤：找不到 DLL 文件: {dllPath}");
                return;
            }
            
            // 方法 1: 使用 SetDllDirectory 設置 DLL 搜索路徑
            if (!string.IsNullOrEmpty(dllDir) && Directory.Exists(dllDir))
            {
                SetDllDirectory(dllDir);
                Console.WriteLine($"已設置 DLL 搜索路徑: {dllDir}");
            }
            
            // 方法 2: 將 DLL 目錄添加到 PATH（確保依賴 DLL 也能找到）
            string currentPath = Environment.GetEnvironmentVariable("PATH");
            if (!string.IsNullOrEmpty(dllDir) && !currentPath.Contains(dllDir))
            {
                Environment.SetEnvironmentVariable("PATH", dllDir + Path.PathSeparator + currentPath);
                Console.WriteLine($"已將 DLL 目錄添加到 PATH");
            }
            
            Console.WriteLine();
            
            // 初始化 Python 解釋器
            int initResult = InitializePython();
            if (initResult != 1)
            {
                Console.WriteLine($"錯誤：無法初始化 Python 解釋器 (返回值: {initResult})");
                Console.WriteLine("提示：可能是找不到 Python DLL 依賴（如 python3*.dll）");
                Console.WriteLine("請確保 Python 環境在 PATH 中");
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
