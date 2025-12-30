"""
CPP_DLL 接口驗證腳本
檢查頭文件、實現文件和調用代碼的一致性
"""

import os
import re
from pathlib import Path

def read_file_content(filepath):
    """讀取文件內容"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"錯誤: 無法讀取 {filepath}: {e}")
        return None

def extract_functions_from_header(header_content):
    """從頭文件中提取函數聲明"""
    functions = []
    # 匹配 MYMATH_API 函數聲明，支持複雜的返回類型如 const char*
    pattern = r'MYMATH_API\s+([\w\s\*]+?)\s+(\w+)\s*\(([^)]*)\);'
    matches = re.finditer(pattern, header_content)
    
    for match in matches:
        return_type = match.group(1).strip()
        func_name = match.group(2)
        params = match.group(3).strip()
        functions.append({
            'name': func_name,
            'return_type': return_type,
            'params': params
        })
    
    return functions

def extract_functions_from_impl(impl_content):
    """從實現文件中提取函數定義"""
    functions = []
    # 匹配 MYMATH_API 函數定義，支持複雜的返回類型如 const char*
    pattern = r'MYMATH_API\s+([\w\s\*]+?)\s+(\w+)\s*\(([^)]*)\)\s*\{'
    matches = re.finditer(pattern, impl_content)
    
    for match in matches:
        return_type = match.group(1).strip()
        func_name = match.group(2)
        params = match.group(3).strip()
        functions.append({
            'name': func_name,
            'return_type': return_type,
            'params': params
        })
    
    return functions

def extract_exports_from_def(def_content):
    """從 .def 文件中提取導出函數名"""
    exports = []
    lines = def_content.split('\n')
    in_exports = False
    
    for line in lines:
        line = line.strip()
        if line == 'EXPORTS':
            in_exports = True
            continue
        if in_exports and line and not line.startswith(';'):
            # 提取函數名（可能包含序號）
            func_name = line.split()[0]
            exports.append(func_name)
    
    return exports

def verify_consistency():
    """驗證所有文件的一致性"""
    base_dir = Path(__file__).parent
    
    print("=== CPP_DLL 接口驗證 ===\n")
    
    # 讀取文件
    header_file = base_dir / "MyMath.h"
    impl_file = base_dir / "MyMath.cpp"
    def_file = base_dir / "MyMath.def"
    
    header_content = read_file_content(header_file)
    impl_content = read_file_content(impl_file)
    def_content = read_file_content(def_file)
    
    if not all([header_content, impl_content, def_content]):
        print("錯誤: 無法讀取所有必需的文件")
        return False
    
    # 提取函數信息
    header_funcs = extract_functions_from_header(header_content)
    impl_funcs = extract_functions_from_impl(impl_content)
    def_exports = extract_exports_from_def(def_content)
    
    print(f"頭文件中的函數聲明: {len(header_funcs)}")
    print(f"實現文件中的函數定義: {len(impl_funcs)}")
    print(f".def 文件中的導出: {len(def_exports)}")
    print()
    
    # 驗證頭文件和實現文件的一致性
    print("1. 驗證頭文件與實現文件的一致性...")
    header_names = {f['name'] for f in header_funcs}
    impl_names = {f['name'] for f in impl_funcs}
    
    if header_names == impl_names:
        print("   [OK] 函數名稱一致")
    else:
        print("   [ERROR] 函數名稱不一致:")
        missing_in_impl = header_names - impl_names
        missing_in_header = impl_names - header_names
        if missing_in_impl:
            print(f"     實現文件中缺少: {missing_in_impl}")
        if missing_in_header:
            print(f"     頭文件中缺少: {missing_in_header}")
    
    # 驗證 .def 文件
    print("\n2. 驗證 .def 文件導出...")
    def_set = set(def_exports)
    if def_set == header_names:
        print("   [OK] .def 文件包含所有函數")
    else:
        print("   [ERROR] .def 文件不一致:")
        missing_in_def = header_names - def_set
        extra_in_def = def_set - header_names
        if missing_in_def:
            print(f"     .def 中缺少: {missing_in_def}")
        if extra_in_def:
            print(f"     .def 中多餘: {extra_in_def}")
    
    # 顯示所有函數詳情
    print("\n3. 函數詳情:")
    for func in header_funcs:
        print(f"   - {func['return_type']} {func['name']}({func['params']})")
    
    # 檢查是否使用 MYMATH_API
    print("\n4. 檢查 MYMATH_API 使用...")
    if 'MYMATH_API' in impl_content:
        print("   [OK] 實現文件中使用了 MYMATH_API")
    else:
        print("   [WARNING] 實現文件中未使用 MYMATH_API")
    
    if 'extern "C"' in impl_content:
        print("   [OK] 使用了 extern \"C\" 確保 C 兼容性")
    else:
        print("   [WARNING] 未使用 extern \"C\"")
    
    print("\n=== 驗證完成 ===")
    return True

if __name__ == "__main__":
    verify_consistency()

