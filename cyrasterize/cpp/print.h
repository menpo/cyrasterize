#include <Python.h>


#define py_printf(...) PySys_WriteStdout(__VA_ARGS__);
#define py_printf_v(verbose, ...) if (verbose) PySys_WriteStdout(__VA_ARGS__);
