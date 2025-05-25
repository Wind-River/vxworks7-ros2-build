# Setup WRSDK

Download, extract, and source a VxWorks SDK for cross-compiling applications using Wind River's toolchain.

## 📋 Description

This action sets up a VxWorks SDK environment based on a specified target and release version. It automatically handles download, caching, extraction, and sourcing the build environment.

The SDK configuration is resolved using a bundled `wrsdks.json` metadata file validated against a JSON Schema.

---

## 🔧 Inputs

| Name        | Description                                                  | Default       | Required |
|-------------|--------------------------------------------------------------|----------------|----------|
| `sdks_list` | Path to the JSON file describing SDK mappings                | `wrsdks.json`  | No       |
| `sdk`       | SDK target name (e.g. `qemu`, `raspberrypi4b`)               | `qemu`         | No       |
| `vxworks`   | VxWorks release version (e.g. `24.03`)                       | `24.03`        | No       |
| `directory` | Directory to download and extract the SDK                    | `/tmp`         | No       |
| `sdkenv`    | Whether to source the SDK environment after extraction       | `true`         | No       |

---

## 🚀 Usage

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup WRSDK
        uses: Wind-River/setup-wrsdk@v1
        with:
          sdk: qemu
          vxworks: 24.03
```

---

## 📤 Outputs

This action sets the following environment variables (if `sdkenv: true`):

- `WIND_SDK_HOME`
- `WIND_SDK_CCBASE_PATH`
- `WIND_SDK_CC_SYSROOT`
- `WIND_CC_SYSROOT`
- Updates to `PATH` and `LD_LIBRARY_PATH`

---

## 📁 Bundled Files

These files are bundled inside the action and **do not need to be provided by users**:

- `wrsdks.json` — SDK download metadata
- `parse_wrsdks.py` — Resolves download URLs from JSON
- `schemas/wrsdk-schema.json` — JSON Schema for validation
- `act-e.json` — Configuration used for local testing with [`act`](https://github.com/nektos/act)

---

## ▶️ Running Locally

To test your action locally:

```bash
act -j setup-sdk -e act-e.json
```
