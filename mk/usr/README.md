# `rules.packages.mk` - Package Build Rules for VxWorks Build System

This `Makefile` fragment provides a common set of rules for downloading, unpacking, patching, building, and installing source packages in a VxWorks-based build system. It is part of Wind River’s modular packaging infrastructure and supports building third-party and open-source software as part of a custom runtime image or SDK.

# Design Overview

The design of rules.packages.mk centers around extensible, source-driven builds using make. Key features include:

### 1.  **Source Package Support**
The Makefile supports multiple types of source repositories:

* `git`
* `hg` (Mercurial)
* Web/FTP archives (`.tar.gz`, `.tar.bz2`, `.zip`, etc.)
* (Stub entries exist for `svn` and `cvs` but are not implemented.)

Each source type has corresponding fetch_ and clone_ functions that download and prepare the source code.

### 2. **Patch System**

Each package may have an associated patches/series file listing patches to apply. The `pkg_patch` macro applies these patches using the patch utility.

### 3. **Build Lifecycle Phases**

### Standard build phases are supported:

* `%.download` → pkg_download
* `%.unpack` → pkg_unpack
* `%.patch` → pkg_patch
* `%.configure` → pkg_configure
* `%.buildv → pkg_build
* `%.install` → pkg_install
* `%.deploy` → Optional deploy step
* `%.clean / %.distclean` → Clean up build artifacts

Each phase is defined via `pkg_*` macros to allow easy customization.

### 4. **Checksum Verification**

The `pkg_checksum` macro can verify the MD5 hash of a downloaded archive if `PKG_MD5_CHECKSUM` is defined. This helps ensure download integrity.

### 5. **Download Caching**

Fetched sources are cached in `$(DOWNLOADS_DIR)`. Git and Mercurial repositories are mirrored locally to improve performance and support offline builds.

### 6. **Error Checking and Logging**

Each phase includes basic error checking and informative log messages to help with debugging and CI traceability.

### 7. **Customizability**

Developers can override macros like `OTHER_CHECKOUT`, `OTHER_UNPACK`, or `pkg_configure` to handle non-standard sources or configurations.

## File Overview

This repository contains a collection of Makefile fragments that modularize and standardize the build logic for various types of packages and configurations. Each file is designed to be included as needed in a package-specific Makefile.


```text
.
├── defs.autotools.mk     # Support for GNU Autotools-based packages (configure/make)
├── defs.cmake.mk         # Rules for building packages using CMake
├── defs.common.mk        # Common utilities, macros, and default settings shared by all packages
├── defs.crossbuild.mk    # Cross-compilation helpers for multi-arch builds (e.g., target vs host tools)
├── defs.hosttool.mk      # Definitions for building host tools required during the build process
├── defs.make.mk          # Rules for packages using raw Makefile-based builds (no configure step)
├── defs.packages.mk      # Metadata definitions for packages: name, version, URLs, checksums, etc.
├── defs.python.mk        # Support for building and installing Python packages
├── defs.ros2.mk          # Specialized rules for building ROS 2 packages and dependencies
├── defs.vxworks.mk       # VxWorks-specific environment setup and toolchain integration
└── rules.packages.mk     # Core infrastructure: lifecycle rules for fetch, unpack, build, install, etc.
```

## Supported Build Systems

This Makefile is designed to integrate with a wide variety of build systems. It can handle:

- **`GNU Autotools / Make`**
   Supports `./configure && make && make install` sequences.
- **`CMake`**
   Supports CMake-based projects via `cmake`, `ninja`, or `make` backends. Toolchain and sysroot support are expected.
- **`Python`**
   Supports Python packages using `setup.py` or `pyproject.toml` via pip or direct commands.
- **`Meson`**
   Supports Meson/Ninja-based builds with cross-file support.
- **Custom**
   Fully customizable via overrides for unusual or proprietary build systems.

You can define `pkg_configure`, `pkg_build`, and `pkg_install` for each package to invoke the appropriate tools, pass the correct flags, and use the cross-compilation environment provided by the VxWorks SDK.

## Directory Structure

```bash
project/
├── pkg/
│   └── <pkg-name>/
│       ├── patches/
│       │   └── series
│       └── <pkg files>
├── build/
│   └── <pkg-name>/
│       └── build and src dirs
├── downloads/
│   └── fetched archives and repos
├── mk/usr/
│   └── rules.packages.mk
```

## License

This file is licensed under the Apache License 2.0.