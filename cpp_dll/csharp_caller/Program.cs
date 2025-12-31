using System;
using System.Runtime.InteropServices;
using System.IO;

namespace CSharpCaller
{
    class Program
    {
        // 根據運行時架構選擇 DLL
        private static string GetDllPath()
        {
            string baseDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            if (string.IsNullOrEmpty(baseDir))
            {
                baseDir = AppDomain.CurrentDomain.BaseDirectory;
            }
            
            // 回到 cpp_dll 目錄（從 bin/x64/Release/net8.0 或 bin/x86/Release/net8.0）
            baseDir = Path.GetFullPath(Path.Combine(baseDir, "..", "..", "..", ".."));
            
            // 檢測運行時架構
            bool is64Bit = Environment.Is64BitProcess;
            
            string dllDir;
            string arch;
            
            if (is64Bit)
            {
                dllDir = Path.Combine(baseDir, "x64");
                arch = "64位";
            }
            else
            {
                dllDir = Path.Combine(baseDir, "x86");
                arch = "32位";
            }
            
            string dllPath = Path.Combine(dllDir, "MyMath.dll");
            
            // 如果架構目錄中沒有，嘗試根目錄
            if (!File.Exists(dllPath))
            {
                dllPath = Path.Combine(baseDir, "MyMath.dll");
            }
            
            // 最後嘗試當前目錄
            if (!File.Exists(dllPath))
            {
                dllPath = Path.Combine(Directory.GetCurrentDirectory(), "MyMath.dll");
            }
            
            Console.WriteLine($"運行時架構: {(is64Bit ? "64位" : "32位")}");
            Console.WriteLine($"使用 DLL: {dllPath} ({arch})");
            Console.WriteLine($"DLL 存在: {File.Exists(dllPath)}");
            Console.WriteLine();
            
            return dllPath;
        }
        
        // 使用 DllImport 特性導入 C++ DLL 中的函數
        // 使用動態加載以支持不同架構
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern IntPtr LoadLibrary(string lpFileName);
        
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
        
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool FreeLibrary(IntPtr hModule);
        
        // 函數委託
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        private delegate int AddDelegate(int a, int b);
        
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        private delegate int SubtractDelegate(int a, int b);
        
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        private delegate int MultiplyDelegate(int a, int b);
        
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        private delegate IntPtr GetVersionDelegate();
        
        static void Main(string[] args)
        {
            Console.WriteLine("=== C# 調用 C++ DLL 範例 ===\n");
            
            // 獲取 DLL 路徑
            string dllPath = GetDllPath();
            
            if (!File.Exists(dllPath))
            {
                Console.WriteLine($"錯誤: 找不到 DLL: {dllPath}");
                Console.WriteLine("請確保已編譯 DLL（運行 build_dll.bat）");
                return;
            }
            
            // 加載 DLL
            IntPtr hModule = LoadLibrary(dllPath);
            if (hModule == IntPtr.Zero)
            {
                int error = Marshal.GetLastWin32Error();
                Console.WriteLine($"錯誤: 無法加載 DLL: {dllPath}");
                Console.WriteLine($"錯誤代碼: {error}");
                return;
            }
            
            try
            {
                // 獲取函數地址
                IntPtr addPtr = GetProcAddress(hModule, "Add");
                IntPtr subtractPtr = GetProcAddress(hModule, "Subtract");
                IntPtr multiplyPtr = GetProcAddress(hModule, "Multiply");
                IntPtr getVersionPtr = GetProcAddress(hModule, "GetVersion");
                
                if (addPtr == IntPtr.Zero || subtractPtr == IntPtr.Zero || 
                    multiplyPtr == IntPtr.Zero || getVersionPtr == IntPtr.Zero)
                {
                    Console.WriteLine("錯誤: 無法獲取 DLL 函數地址");
                    return;
                }
                
                // 創建委託
                AddDelegate addFunc = Marshal.GetDelegateForFunctionPointer<AddDelegate>(addPtr);
                SubtractDelegate subtractFunc = Marshal.GetDelegateForFunctionPointer<SubtractDelegate>(subtractPtr);
                MultiplyDelegate multiplyFunc = Marshal.GetDelegateForFunctionPointer<MultiplyDelegate>(multiplyPtr);
                GetVersionDelegate getVersionFunc = Marshal.GetDelegateForFunctionPointer<GetVersionDelegate>(getVersionPtr);
                
                // 調用函數
                int sum = addFunc(10, 20);
                Console.WriteLine($"Add(10, 20) = {sum}");
                
                int diff = subtractFunc(30, 15);
                Console.WriteLine($"Subtract(30, 15) = {diff}");
                
                int product = multiplyFunc(5, 6);
                Console.WriteLine($"Multiply(5, 6) = {product}");
                
                IntPtr versionPtr = getVersionFunc();
                string version = Marshal.PtrToStringAnsi(versionPtr);
                Console.WriteLine($"Version: {version}");
            }
            finally
            {
                // 釋放 DLL
                FreeLibrary(hModule);
            }
            
            Console.WriteLine("\n測試完成！");
        }
    }
}
