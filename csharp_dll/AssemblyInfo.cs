using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyTitle("CSharpDLL")]
[assembly: AssemblyDescription("C# DLL 範例")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("")]
[assembly: AssemblyProduct("CSharpDLL")]
[assembly: AssemblyCopyright("Copyright © 2024")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

// COM 可見性：僅 net8.0 版本啟用（用於 COM/LabVIEW）
#if COM_EXPORT
[assembly: ComVisible(true)]
[assembly: Guid("11111111-1111-1111-1111-111111111111")]
#else
[assembly: ComVisible(false)]
#endif

[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
