# 🟦 VxWorks 7 CMake Cross-Compilation Guide

How to reliably cross-compile third-party CMake-based projects for VxWorks 7

# Overview

CMake is widely used for modern C and C++ projects. 
When targeting VxWorks 7, cross-compilation requires precise configuration of:

- the Wind River (wr-cc / wr-c++) toolchain,
- the VxWorks 7 SDK / VSB sysroot,
- correct mapping of host/target triples,
- disabling of run-time tests,
- adapting feature checks for a cross-compile environment.

This guide describes how to prepare a reliable and deterministic `CMake` cross-build environment for VxWorks 7, 
equivalent to the `Autotools` cross-compile workflow but using modern `CMake` concepts.

## CMake Cross-Compilation Concepts (VxWorks edition)

`CMake` handles cross-compilation through a single canonical mechanism:

### `Toolchain` File (`*.cmake`)

Defines:

- compiler paths (CC, CXX)
- sysroot
- include/lib directories
- target triple
- linker flags
- supported languages & standards

### Presets (CMakePresets.json)

Encodes repeatable configurations, options, cache defaults, and environment overrides.

### Cache Initialization (CMAKE_CACHE_ARGS)

Pre-defines compile-time results (e.g., "VxWorks does not support asprintf").

### `NO RUN TIME TESTS`

CMake tests like `check_c_source_runs()` must be disabled or overridden, because cross-compiling cannot run target binaries.

## VxWorks 7 Toolchain File Template

`toolchain-vxworks.cmake`

## CMake Presets for Repeatable Cross-Compilation

Create a `CMakePresets.json` file:

```json
{
  "version": 3,
  "cmakeMinimumRequired": { "major": 3, "minor": 21 },
  "configurePresets": [
    {
      "name": "vxworks7",
      "displayName": "VxWorks 7 Cross-Compile",
      "generator": "Ninja",
      "toolchainFile": "toolchain-vxworks.cmake",
      "binaryDir": "build-vxworks",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_POSITION_INDEPENDENT_CODE": "ON",
        "CMAKE_CXX_STANDARD": "14",
        "CMAKE_C_STANDARD": "99"
      }
    }
  ]
}
```

## Handling Feature Tests & Unsupported APIs on VxWorks

### Problem

CMake modules often attempt runtime checks:

```cmake
check_c_source_runs()
try_run()
```

These must never run during VxWorks cross-compile.

### Solution

Override them globally:

```cmake
set(CMAKE_TRY_RUN_RESULT_VAR "FAILED")
set(CMAKE_TRY_RUN_SKIP TRUE)
```

Or define expected results:

```cmake
set(HAVE_ASPRINTF OFF CACHE BOOL "VxWorks lacks asprintf" FORCE)
set(HAVE_FLOCK OFF CACHE BOOL "No flock()" FORCE)
set(HAVE_EXECINFO OFF CACHE BOOL "" FORCE)
```

## Finding Libraries in the VxWorks Sysroot

VxWorks ships a specific subset of libraries in its VSB sysroot (usr/lib, usr/include).
To ensure correct resolution:

```cmake
set(CMAKE_PREFIX_PATH "${CMAKE_SYSROOT}")
set(CMAKE_LIBRARY_PATH "${CMAKE_SYSROOT}/lib")
set(CMAKE_INCLUDE_PATH "${CMAKE_SYSROOT}/include")
```

For `pkg-config` based dependencies:

```cmake
export PKG_CONFIG_SYSROOT_DIR=$CMAKE_SYSROOT
export PKG_CONFIG_LIBDIR=$CMAKE_SYSROOT/lib/pkgconfig
```

## Python, Tests, and Examples

CMake projects often contain:

- Python bindings
- Unit tests
- Example executables
- Documentation generators (like Sphinx)

These are normally host tools and cannot be built for VxWorks.

Recommended presets:

```cmake
-DPYTHON_EXECUTABLE=python3
-DBUILD_TESTING=OFF
-DBUILD_EXAMPLES=OFF
-DBUILD_DOCS=OFF
```

Alternatively use presets:

```json
"cacheVariables": {
  "BUILD_TESTING": "OFF",
  "BUILD_EXAMPLES": "OFF",
  "BUILD_DOCS": "OFF"
}
```

## Static vs Shared Library Constraints

VxWorks supports:

- .a static libraries
- .so shared libraries (with restrictions)

Example preset overrides:

```cmake
# VxWorks prefers static libraries unless explicitly allowed
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
```

## Full VxWorks Cross-Compilation Workflow

### Native host build (optional but recommended)

Ensures:

- the CMake project is valid
- dependencies detected correctly

```bash
cmake -B build-native -DCMAKE_BUILD_TYPE=Release
cmake --build build-native
```

### Cross-compile with preset

```bash
cmake --preset vxworks7
cmake --build --preset vxworks7
```

### Install into sysroot image (optional)

```bash
cmake --install build-vxworks --prefix /export/vxworks/rootfs
```

## Troubleshooting Common VxWorks/CMake Failures

| Symptom                                 | Classification              | Fix                                                     |
|------------------------------------------|------------------------------|----------------------------------------------------------|
| `wr-cc: unrecognized option -std=c++20`  | Unsupported language level   | Use `C++14` or `C++17` depending on compiler version        |
| cannot run test program while cross compiling | Runtime test            | Force results with `try_run` overrides                  |
| Missing headers                          | Missing sysroot include path | Verify `CMAKE_SYSROOT` & include paths                  |
| Missing library                          | Sysroot mismatch            | Add libs to VSB or adjust find paths                    |
| Wrong compiler found                     | Toolchain file error        | Ensure no fallback to host `gcc`                        |


```
Components Required for Cross-Compilation

Cross-compiling with CMake requires:

Cross-Compiler Toolchain

Provided by VxWorks for each target architecture (x86_64, ARM, PowerPC, etc.).

Compiler driver: wr-cc / wr-c++, which wraps underlying tools and sets appropriate include paths, linker flags, and sysroot.

Default compiler configuration is stored in default.conf, generated by the VSB build.

Target Triplet

Specify the target platform using CMAKE_SYSTEM_NAME and CMAKE_SYSTEM_PROCESSOR.

Example: x86_64-wrs-vxworks.

Sysroot

The VxWorks sysroot contains headers, libraries, and runtime support.

Example: $WIND_PREBUILT_PATHS/vsb_itl_generic.

Toolchain File

Essential for cross-compilation with CMake.

A Toolchain.cmake file defines compilers, flags, sysroot, and paths for libraries and includes
```


```
VxWorks 7 CMake Cross-Compilation Porting Guide

This guide provides porting recommendations and guidelines to reduce the effort and complexity of adapting CMake-based packages to VxWorks 7.
It is intended for Linux hosts and user-space (RTP) builds only. It does not cover kernel modules (DKMs) or Windows hosts.

Porting Guideline

Porting a CMake-based project to VxWorks is an iterative process, which starts with verifying that your CMake toolchain setup works correctly using a simple test project such as amhello. After that, configure your own project and identify what may prevent it from building or linking correctly.

Compile the Project Natively First

Always start by building the project natively on a Linux host:

Helps understand how CMakeLists.txt resolves dependencies, headers, libraries, and features.

Provides a reference for expected behavior.

Identifies compiler flags, language standards, and optional components.

Common Issues During Porting
Problem	Description	Project Files Typically Affected
Missing dependencies	External libraries required by the project are not available or built for VxWorks	CMakeLists.txt, Find<lib>.cmake, toolchain file
Missing headers	Include paths incomplete or headers differ in VxWorks	CMakeLists.txt, target_include_directories, toolchain file
Missing functions	Certain POSIX or GNU-specific APIs (e.g., asprintf(), memccpy()) may not exist	CMake try_compile / CheckFunctionExists.cmake, config.h.in equivalents
Missing or incomplete feature detection	CMake may try to execute test binaries (e.g., try_run) which fails in cross-build	CMakeLists.txt, CMake/Modules
Incorrect compiler, linker, or sysroot	Toolchain file misconfigured or missing flags	Toolchain file, CMakeLists.txt
Unsupported or mismatched language standards	VxWorks compiler may not support requested standard	CMakeLists.txt, target_compile_features
Project Files Affected by Configuration Issues

CMakeLists.txt – main project definitions, targets, and dependencies.

Find<lib>.cmake – custom find scripts for third-party libraries.

Toolchain.cmake – cross-compilation setup: compiler, flags, sysroot.

CMake/Modules/ – optional modules containing feature detection.

config.h.in / config.h – header templates for feature macros.

Missing Dependencies

Description: External libraries may not exist in the VxWorks sysroot.

Triage Steps:

Check if the library is available in VxWorks layers

Enable VSB layers that provide Boost, TinyXML, or Python.

Update the toolchain file or CMAKE_PREFIX_PATH to include library paths.

Optional Dependencies

Disable optional components if the library is not required:

cmake -DENABLE_FOO=OFF ..


Mandatory Dependencies

Cross-compile the library for VxWorks.

Install into the sysroot and update toolchain paths.

Re-run CMake.

Example: Missing Boost Library

cmake .. -DCMAKE_TOOLCHAIN_FILE=Toolchain-vxworks.cmake \
         -DBoost_USE_STATIC_LIBS=ON \
         -DBOOST_ROOT=$WIND_CC_SYSROOT/usr/lib/boost

Missing Headers

Description: Include paths may be incomplete or headers differ in VxWorks.

Files Affected: CMakeLists.txt, toolchain file, config.h.in.

Triage Steps:

Identify missing headers from CMake logs (CMakeError.log).

Verify existence in the VxWorks sysroot:

find $WIND_CC_SYSROOT -name xyz.h


Fix include paths in the toolchain file:

include_directories($ENV{WIND_CC_SYSROOT}/usr/h)


Provide stub headers or disable features if unavailable:

add_definitions(-DHAVE_EXECINFO_H=0)

Missing Functions

Description: Certain POSIX or GNU-specific functions may not exist.

Files Affected: CMake CheckFunctionExists.cmake, config.h.in.

Triage Steps:

Identify missing function from CMake error logs.

Cache detection results to avoid try_run failures:

set(ASPRINTF_FOUND FALSE CACHE BOOL "asprintf unavailable on VxWorks")


Provide stub implementations:

#ifndef HAVE_ASPRINTF
int asprintf(char **strp, const char *fmt, ...) { return -1; }
#endif


Disable optional features relying on missing functions:

cmake -DENABLE_FANCY_IO=OFF ..

Missing or Incomplete Feature Detection

CMake may attempt to execute test binaries using try_run, which fails in cross-compilation.

Triage Steps:

Detect runtime checks in CMakeLists.txt and modules (try_run, CheckSymbolExists).

Cache or override results in the toolchain file:

set(HAVE_FORK FALSE CACHE BOOL "VxWorks does not support fork()")


Disable tests, examples, or tools if necessary:

cmake -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF ..

Incorrect Compiler, Linker, or Sysroot

Triage Steps:

Ensure wr-cc / wr-c++ is correctly referenced in the toolchain file:

set(CMAKE_C_COMPILER wr-cc)
set(CMAKE_CXX_COMPILER wr-c++)


Verify sysroot path:

set(CMAKE_SYSROOT $ENV{WIND_CC_SYSROOT})


Test with a minimal project to ensure compile-only checks succeed.

Unsupported or Mismatched Language Standards

Triage Steps:

Identify unsupported standard from CMake logs:

wr-c++ -std=c++17 -c test.cpp


Override flags in the toolchain file:

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_C_STANDARD 99)


Patch target_compile_features or custom macros in CMakeLists.txt if necessary.

```

