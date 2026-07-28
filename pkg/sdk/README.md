# VxWorks SDK Integration Guide

This directory contains SDK-specific patches, fixes, and configuration files necessary to build ROS 2 with different VxWorks SDK versions.

## Directory Structure

```
pkg/sdk/files/
├── README.md              # This file
├── defs.autotools.mk      # Common autotools definitions (shared across all SDKs)
├── 22.03/                 # SDK version 22.03
├── 22.09/                 # SDK version 22.09
├── 23.03/                 # SDK version 23.03
├── 23.09/                 # SDK version 23.09
├── 24.03/                 # SDK version 24.03
├── 24.09/                 # SDK version 24.09
└── 25.09/                 # SDK version 25.09 (Latest)
    ├── defs.sdk.mk
    └── requirements.txt
```

## How SDK Version Detection Works

The build system automatically detects the VxWorks SDK version from the SDK's configuration:

1. **Version Detection** (`mk/usr/defs.vxworks.mk`):
   ```makefile
   WIND_RELEASE_ID=$(shell grep _WRS_CONFIG_CORE_RELEASE $(WIND_CC_SYSROOT)/h/config/auto.conf | cut -d '=' -f 2)
   ```

2. **Python Version Assignment**:
   - `22.03` and later → Python 3.9

3. **SDK Makefile Selection** (`pkg/sdk/Makefile`):
   ```makefile
   include files/$(WIND_RELEASE_ID)/defs.sdk.mk
   ```

The `WIND_RELEASE_ID` variable is extracted from the SDK's `auto.conf` file and used to select the appropriate SDK-specific configuration.

---

## Adding Support for a New VxWorks SDK

Follow these steps to add support for a new VxWorks SDK version (e.g., `26.03`):

### Step 1: Create SDK Version Directory

```bash
cd pkg/sdk/files
mkdir 26.03
```

### Step 2: Create `defs.sdk.mk` File

Copy the most recent SDK definition as a template:

```bash
cp 25.09/defs.sdk.mk 26.03/defs.sdk.mk
```

### Step 3: Customize `defs.sdk.mk`

Edit `26.03/defs.sdk.mk` and customize the following functions based on your SDK requirements:

#### **Required Functions:**

1. **`sdk_fix`** - Copy common build files to SDK
   - Copies `defs.autotools.mk` to SDK's mk directory **only if it doesn't already exist**
   - Add any SDK-specific file copies if needed

2. **`vxworks_fix`** - Patch VxWorks headers for ROS 2 compatibility
   - Fix `STATUS` type conflicts (`STATUS` → `int`)
   - Fix `u_int` type conflicts (`u_int` → `unsigned int`)
   - Add C++ compatibility patches (e.g., `static_cast` for `getpagesize()`)
   - **Review your SDK headers** to determine if new patches are needed

3. **`python_fix`** - Setup host Python environment
   - Create symbolic links: `python3` and `python`
   - Install `pip3` if not present
   - Fix Python shebangs to use `/usr/bin/env python3`
   - Adjust Python version if your SDK uses different version

4. **`sdk_patch`** - Orchestrate all patches
   ```makefile
   define sdk_patch
       $(call echo_action,Fixing SDK,$*)
       $(call sdk_fix,$*)
       $(call echo_action,Applying Host Python patches,$*)
       $(call python_fix,$*)
   endef
   ```

5. **`sdk_install`** - Install Python dependencies
   - Install packages from `requirements.txt`
   - Setup SSL certificates via `certifi`
   - Create Python `crossenv` for cross-compilation

6. **`sdk_deploy`** - Copy SDK artifacts to deployment directory
   - Copy shared libraries from SDK
   - Copy Python binaries and libraries
   - Ensure all runtime dependencies are included

#### **Idempotency Requirements:**

All patches **MUST** be idempotent (safe to run multiple times). Use conditional checks:

```makefile
# Good - idempotent check
if [ ! -f $(WIND_CC_SYSROOT)/mk/defs.autotools.mk ]; then
    cp files/defs.autotools.mk $(WIND_CC_SYSROOT)/mk/.;
fi

# Good - idempotent grep check
if grep -q 'STATUS' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`; then
    sed -i 's/STATUS/int/g' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`;
fi

# Good - check if already patched
if ! grep -q 'static_cast<int>' $(WIND_CC_SYSROOT)/usr/h/published/UTILS_UNIX/unistd.h; then
    sed -i '/return (int)sysconf/c\...' unistd.h;
fi
```

### Step 4: Create `requirements.txt`

Copy `requirements.txt` from the most recent SDK version:

```bash
cp 25.09/requirements.txt 26.03/requirements.txt
```

Review the file and update if your SDK requires different Python package versions. Look inside the file to see the list of required packages and their pinned versions.

### Step 5: Test the New SDK Configuration

#### 5.1 Download and extract your new SDK:

```bash
cd ~/Downloads
wget https://d13321s3lxgewa.cloudfront.net/wrsdk-vxworks7-<target>-<version>.tar.bz2
mkdir -p ~/Downloads/wrsdk && cd ~/Downloads/wrsdk
tar -jxvf ~/Downloads/wrsdk-vxworks7-<target>-<version>.tar.bz2 --strip 1
```

#### 5.2 Build Docker image (if needed for new Ubuntu base):

```bash
cd vxworks7-ros2-build
docker build --no-cache -t vxbuild:24.04 Docker/24.04/vxbuild/.
docker build --no-cache -t vxros2build:jazzy Docker/24.04/vxros2build/.
```

#### 5.3 Run Docker and verify SDK detection:

```bash
docker run -ti -h vxros2 -v ~/Downloads/wrsdk:/wrsdk -v $PWD:/work vxros2build:jazzy
source /wrsdk/sdkenv.sh
make info
```

**Expected output:**
```
WIND RELEASE:       26.03
ROS DISTRO:         jazzy
TARGET ARCH:        x86_64
TARGET PYTHON:      Python3.9
```

#### 5.4 Test SDK patch application:

```bash
DEFAULT_BUILD=sdk make
```

Verify:
- No errors during SDK patching
- `crossenv` virtual environment created successfully
- Python packages installed correctly

#### 5.5 Full ROS 2 build test:

```bash
make distclean
make
```

### Step 6: Update Documentation

Update project documentation if the new SDK:
- Requires different hardware targets
- Changes Python version (3.8 → 3.9 → 3.10+)
- Introduces breaking changes

---

## Creating ROS 2 Layer Branch for New SDK

When adding a new SDK version, you **must** create a corresponding branch in the ROS 2 layer repository with VxWorks-specific patches.

### Branch Naming Convention

The branch name follows the pattern: `<ros_distro>-release-<sdk_version>`

For SDK version `26.03` with ROS 2 `jazzy`:
```
jazzy-release-26.03
```

### Steps to Create the Layer Branch

1. **Fork or clone the layer repository:**
   ```bash
   git clone https://github.com/Wind-River/vxworks7-layer-for-ros2.git
   cd vxworks7-layer-for-ros2
   ```

2. **Create the new branch from the latest release:**
   ```bash
   # Start from the most recent SDK branch for the same ROS distro
   git checkout jazzy-release-25.09
   git checkout -b jazzy-release-26.03
   ```

3. **Test patches with new SDK:**
   - Build ROS 2 with the new SDK
   - Verify all patches apply cleanly
   - Fix any conflicts or add new patches if needed

4. **Push the new branch:**
   ```bash
   git push origin jazzy-release-26.03
   ```

5. **Verify branch selection logic:**

   The build system automatically selects the branch based on `ROS_DISTRO` and `WIND_RELEASE_ID`:

   ```makefile
   # From pkg/ros2/Makefile
   PKG_LAYER_COMMIT_ID ?= $(ROS_DISTRO)-release-$(WIND_RELEASE_ID)
   ```

   For SDK 26.03 with ROS 2 jazzy, it will look for:
   ```
   https://github.com/Wind-River/vxworks7-layer-for-ros2/tree/jazzy-release-26.03
   ```

### Example Layer Branches

- `jazzy-release-25.09` - ROS 2 Jazzy with VxWorks SDK 25.09
- `jazzy-release-26.03` - ROS 2 Jazzy with VxWorks SDK 26.03 (your new branch)
- `humble-release-24.03` - ROS 2 Humble with VxWorks SDK 24.03

### What if the branch doesn't exist?

If the layer branch is missing, the ROS 2 build will fail with:
```
fatal: Remote branch jazzy-release-26.03 not found
```

**Important:** Create the layer branch **before** running a full ROS 2 build with the new SDK.

---

## SDK Evolution Timeline

### Early (22.03 - 23.03)
- **Python:** 3.9
- **Features:** Improved SDK structure, some binary dependencies
- **Patches:** VxWorks header fixes, library replacements

### Modern (23.09 - 25.09)
- **Python:** 3.9
- **Features:** Minimal binary dependencies, crossenv-based builds
- **Patches:** Idempotent header fixes, Python environment setup
- **Improvements:** Better C++ compatibility, SSL certificate handling

---

## Common Customization Scenarios

### Scenario 1: New Python Version (3.10+)

Update `mk/usr/defs.vxworks.mk`:

```makefile
ifeq ($(WIND_RELEASE_ID),26.03)
    TGT_PYTHON_MINOR=10
endif
```

Update `defs.sdk.mk` Python paths:
```makefile
python3.$(TGT_PYTHON_MINOR) -m crossenv ...
```

### Scenario 2: Additional Header Fixes

Add to `vxworks_fix` function:

```makefile
define vxworks_fix
    # Existing fixes...
    
    # New fix for SDK 26.03
    if grep -q 'OLD_TYPE' $(WIND_CC_SYSROOT)/usr/h/some/header.h; then
        sed -i 's/OLD_TYPE/NEW_TYPE/g' $(WIND_CC_SYSROOT)/usr/h/some/header.h;
        echo "Fixed OLD_TYPE in header.h";
    fi
endef
```

### Scenario 3: Additional Python Dependencies

Add to `requirements.txt`:
```
new-package==1.2.3
another-dependency
```

Or install dynamically in `sdk_install`:
```makefile
$(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3 install new-package==1.2.3
```

### Scenario 4: Different Architecture Support

If SDK targets ARM/AArch64 instead of x86_64:

1. Check `WIND_SDK_HOST_TOOLS` path structure
2. Update host tool paths in `defs.sdk.mk`
3. Verify cross-compilation toolchain detection

---

## Debugging Tips

### 1. Check SDK Version Detection

```bash
source /wrsdk/sdkenv.sh
grep _WRS_CONFIG_CORE_RELEASE $WIND_CC_SYSROOT/h/config/auto.conf
```

### 2. Test Individual SDK Functions

```bash
cd pkg/sdk
make sdk.patch    # Test patch application
make sdk.install  # Test Python package installation
make sdk.deploy   # Test artifact deployment
```

### 3. Verify Python Environment

```bash
ls -la $WIND_SDK_HOST_TOOLS/x86_64-linux/bin/python*
$WIND_SDK_HOST_TOOLS/x86_64-linux/bin/python3 --version
$WIND_SDK_HOST_TOOLS/x86_64-linux/bin/pip3 list
```

### 4. Check Header Patches

```bash
grep -n "STATUS\|u_int" $WIND_CC_SYSROOT/usr/h/public/net/ifaddrs.h
grep -n "static_cast" $WIND_CC_SYSROOT/usr/h/published/UTILS_UNIX/unistd.h
```

### 5. Verify Deployment Files

```bash
ls -la output/export/deploy/lib/
ls -la output/export/deploy/bin/
```

---

## FAQ

**Q: What if my SDK version is detected as something unexpected?**

A: Check `$WIND_CC_SYSROOT/h/config/auto.conf`. The `_WRS_CONFIG_CORE_RELEASE` value must match your directory name exactly.

**Q: Do I need to provide prebuilt binaries for newer SDKs?**

A: Generally no. SDKs from 24.03+ are self-contained. Only add binaries if specific libraries are missing or incompatible.

**Q: How do I know what header patches are needed?**

A: Run the build without patches first. Compilation errors will indicate which headers need fixes. Common issues:
- `STATUS` type conflicts
- `u_int` undefined
- C++ casting issues

**Q: Can I skip the `crossenv` setup?**

A: No. `crossenv` is essential for cross-compiling Python packages for VxWorks target architecture.

**Q: My SDK uses Python 3.11. What changes are needed?**

A: 
1. Update `TGT_PYTHON_MINOR=11` in `mk/usr/defs.vxworks.mk`
2. Adjust pip bootstrap URL: `https://bootstrap.pypa.io/pip/3.11/get-pip.py`
3. Update all `python3.9` references to `python3.11` in `defs.sdk.mk`

---

## References

- **Main Build System:** `../../Makefile`
- **SDK Makefile:** `../Makefile`
- **VxWorks Definitions:** `../../mk/usr/defs.vxworks.mk`
- **Python Definitions:** `../../mk/usr/defs.python.mk`
- **ROS 2 Layer Repository:** https://github.com/Wind-River/vxworks7-layer-for-ros2

---

## Contributing

When adding a new SDK version:

1. Test thoroughly with both QEMU and hardware targets
2. Ensure all patches are idempotent
3. Document any breaking changes or special requirements
4. Update main `README.md` with supported SDK version
5. Consider creating a GitHub workflow for CI/CD testing

## License

Copyright (c) 2022-2026 Wind River Systems, Inc.

Licensed under the Apache License, Version 2.0
