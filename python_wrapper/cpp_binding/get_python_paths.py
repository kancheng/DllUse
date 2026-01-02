import sys
import sysconfig
import os

print("PYTHON_PREFIX=" + sys.prefix)
print("PYTHON_EXEC_PREFIX=" + sys.exec_prefix)
print("PYTHON_INCLUDE=" + sysconfig.get_path('include'))
print("PYTHON_LIBS_DIR=" + os.path.join(sysconfig.get_config_var('prefix'), 'libs'))

