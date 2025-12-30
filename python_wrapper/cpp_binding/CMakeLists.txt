cmake_minimum_required(VERSION 3.12)
project(PythonBridge)

# 查找 Python 和 pybind11
find_package(pybind11 REQUIRED)
find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

# 添加源文件
add_library(PythonBridge SHARED python_bridge.cpp)

# 設置包含目錄
target_include_directories(PythonBridge PRIVATE
    ${PYTHON3_INCLUDE_DIRS}
    ${pybind11_INCLUDE_DIRS}
)

# 鏈接庫
target_link_libraries(PythonBridge PRIVATE
    ${PYTHON3_LIBRARIES}
    pybind11::module
    pybind11::embed
)

# 設置輸出目錄
set_target_properties(PythonBridge PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)

