# Makefile fragment for defs.sdk.mk
#
# Copyright (c) 2022 Wind River Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# modification history
# --------------------
# 12sep22,akh created
#

ifeq ($(__sdk_defs),)
__sdk_defs = TRUE

include $(WIND_USR_MK)/defs.packages.mk
include $(WIND_USR_MK)/defs.python.mk
include $(WIND_USR_MK)/defs.vxworks.mk

define sdk_fix
	if [ ! -f $(WIND_CC_SYSROOT)/mk/defs.autotools.mk ]; then \
		echo "copying 'defs.autotools.mk'."; \
		cp files/defs.autotools.mk $(WIND_CC_SYSROOT)/mk/.; \
	else \
		echo "'defs.autotools.mk' already exists, do not copy."; \
	fi

	# SDK 26.03 defects: libsqlite3.so* ship with NO DT_SONAME and libyaml.so with the
	# unversioned SONAME "libyaml.so" (libyaml's CMake sets no SOVERSION). Neither can
	# be fixed in place: patchelf appends a 3rd PT_LOAD and the VxWorks ldso accepts
	# exactly 2 ("wrong number of segments (3 != 2)", ldso_7x/libdl/map_object.c).
	# ROS 2 builds both from source instead (sqlite_vendor, libyaml_vendor; patches in
	# vxworks7-layer-for-ros2), so move the SDK copies, plus libcyaml which links the
	# SDK libyaml, out of both 3pp trees into 3pp/.removed/<tree>/, where
	# find_package/pkg-config/-l cannot see them. Reversible; idempotent.
	for T in develop deploy; do \
		S=$(3PP_DIR)/$$T/usr; R=$(3PP_DIR)/.removed/$$T/usr; \
		for p in lib/libsqlite3.* include/sqlite3.h include/sqlite3ext.h lib/pkgconfig/sqlite3.pc \
		         lib/libyaml.* include/yaml.h cmake/yamlConfig.cmake cmake/yamlConfigVersion.cmake \
		         cmake/yamlTargets.cmake cmake/yamlTargets-*.cmake \
		         lib/libcyaml.* include/cyaml lib/pkgconfig/libcyaml.pc; do \
			for f in $$S/$$p; do \
				[ -e "$$f" ] || [ -L "$$f" ] || continue; \
				d=$$R/$${f#$$S/}; mkdir -p "$$(dirname "$$d")"; rm -rf "$$d"; mv "$$f" "$$d"; \
				echo "moved $$f -> $$d"; \
			done; \
		done; \
	done

	# SDK file edits, as patches (files/<rel>/sdk-patches/*.patch, paths relative to
	# the SDK root), applied by the same script the SDK overlay's sdk_fix_install
	# runs. 26.03: functional-bind-lvalue.patch (std::bind moved its bound arguments
	# out on every call). Idempotent.
	$(CURDIR)/files/apply-sdk-patches.sh $(CURDIR)/files/$(WIND_RELEASE_ID)/sdk-patches $(WIND_SDK_HOME)
endef

define vxworks_fix
        if grep -q 'STATUS' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`; then \
                echo "'STATUS' found, replacing it with 'int'"; \
                sed -i 's/STATUS/int/g' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`; \
        else \
                echo "'STATUS' not found, no changes needed."; \
        fi

        if grep -q 'u_int' $(WIND_CC_SYSROOT)/usr/h/public/net/ifaddrs.h; then \
                echo "'u_int' found, replacing it with unsigned 'int'";  \
                sed -i 's/u_int/unsigned int/g' $(WIND_CC_SYSROOT)/usr/h/public/net/ifaddrs.h; \
        else \
                echo "'u_int' not found, no changes needed."; \
        fi

        # Patch getpagesize cast, idempotent
        if ! grep -q 'static_cast<int>(sysconf(_SC_PAGESIZE))' $(WIND_CC_SYSROOT)/usr/h/published/UTILS_UNIX/unistd.h; then \
            sed -i '/return (int)sysconf(_SC_PAGESIZE);/c\
#ifdef __cplusplus\
    return static_cast<int>(sysconf(_SC_PAGESIZE));\
#else\
    return (int)sysconf(_SC_PAGESIZE);\
#endif' $(WIND_CC_SYSROOT)/usr/h/published/UTILS_UNIX/unistd.h; \
            echo "Patched getpagesize() cast to C++ safe version"; \
        else \
            echo "getpagesize() cast already patched, skipping"; \
        fi
endef

# pip bootstrap used by python_fix (also read by mk/usr/make-sdk-overlay.sh via
# `make -C pkg/sdk sdk.get-pip-url`, so the overlay installs pip the same way)
GET_PIP_URL ?= https://bootstrap.pypa.io/pip/3.$(TGT_PYTHON_MINOR)/get-pip.py

define python_fix
	if [ ! -L $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 ]; then \
		ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3; \
		echo "'python3' symbolic link created."; \
	else \
		echo "'python3' symbolic link already exists."; \
	fi

	if [ ! -L $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python ]; then \
		ln -f -r -s $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3.$(TGT_PYTHON_MINOR) $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python; \
		echo "'python' symbolic link created."; \
	else \
		echo "'python' symbolic link already exists."; \
	fi

	if [ ! -f $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3 ]; then \
		cd $(DOWNLOADS_DIR) && $(call fetch_web,$(PKG_NAME),$(GET_PIP_URL),get-pip.py) ; \
		$(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 $(DOWNLOADS_DIR)/get-pip.py ; \
		sed -i '1s|^#!.*|#!/usr/bin/env python3|' \
			$(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip \
			$(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3 \
			$(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3.9 ; \
		echo "'pip3' was not found and has been installed." ; \
	else \
		echo "'pip3' already exists, no installation needed." ; \
	fi
endef

define sdk_patch
	$(call echo_action,Fixing SDK,$*)
	$(call sdk_fix,$*)
	$(call echo_action,Applying Host Python patches,$*)
	$(call python_fix,$*)
endef

define sdk_install
        $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/pip3 install -r files/$(WIND_RELEASE_ID)/requirements.txt ; \
        find $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/ -type f -exec grep -Iq . {} \; -exec sed -i \
                '1s|^#!.*python[^ ]*|#!/usr/bin/env python3|' {} \; ; \
        echo "✔ Python shebangs converted to /usr/bin/env python3" ; \
        export SSL_CERT_FILE="$$( $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/python3 -m certifi )" ; \
        if [ ! -f "$(VIRTUAL_ENV)/bin/activate" ]; then \
                echo "setup 'crossenv'."; \
                python3.$(TGT_PYTHON_MINOR) -m crossenv $(WIND_CC_SYSROOT)/usr/3pp/develop/usr/bin/python3 $(VIRTUAL_ENV); \
        else \
                echo "'crossenv' already exists."; \
        fi ; \
        install -D -m0755 files/optimize-python-startup.py $(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/optimize-python-startup ; \
        echo "✔ optimize-python-startup installed" ; \
        $(call rust_fix)
endef

# VxWorks Rust toolchain gap the SDK ships but does not fix: libloading has no
# VxWorks arm for the dlopen RTLD_* flags. This is a generic Rust-on-VxWorks issue
# (not ROS 2 specific), so it lives with the SDK: patch upstream 0.8.9 into
# $(WIND_CC_SYSROOT)/usr/rust/vxworks-crates/libloading, which Rust consumers point
# [patch.crates-io] at.
define rust_fix
        RP=$(CURDIR)/files/$(WIND_RELEASE_ID)/rust-patches ; \
        CRATES=$(WIND_CC_SYSROOT)/usr/rust/vxworks-crates ; \
        LL="$$CRATES/libloading/src/os/unix/consts.rs" ; \
        if [ ! -f "$$LL" ] || ! grep -q 'target_os = "vxworks"' "$$LL"; then \
                rm -rf "$$CRATES/libloading" ; \
                mkdir -p "$$CRATES" ; cd "$$CRATES" ; \
                curl -sL "https://crates.io/api/v1/crates/libloading/0.8.9/download" | tar xz ; \
                mv libloading-0.8.9 libloading ; cd libloading ; \
                patch -p1 < "$$RP/libloading-vxworks.patch" ; \
        fi ; \
        SDKCARGO="$(WIND_CC_SYSROOT)/usr/rust/.cargo/config.toml" ; \
        if ! grep -q 'target-feature=-crt-static' "$$SDKCARGO" 2>/dev/null; then \
                sed -e "s#@WIND_CC_SYSROOT@#$(WIND_CC_SYSROOT)#g" \
                        -e "s#@TGT_TRIPLE@#$(TGT_ARCH)-wrs-vxworks#g" \
                        "$$RP/sdk-cargo-config-vxworks.toml.template" > "$$SDKCARGO" ; \
        fi ; \
        CAB=$(WIND_SDK_HOST_TOOLS)/x86_64-linux/bin/cargo-ament-build ; \
        if [ -f "$$CAB" ] && ! grep -q "vxe" "$$CAB"; then \
                D=$(WIND_CC_SYSROOT)/usr/rust/cargo-ament-build-src ; \
                rm -rf "$$D" ; mkdir -p "$$D" ; cd "$$D" ; \
                curl -sL "https://crates.io/api/v1/crates/cargo-ament-build/0.1.11/download" | tar xz ; \
                cd cargo-ament-build-0.1.11 ; \
                patch -p1 < "$$RP/cargo-ament-build-vxe.patch" ; \
                CARGO_HOME="$$D/.cargo" cargo build --release --target x86_64-unknown-linux-gnu ; \
                cp target/x86_64-unknown-linux-gnu/release/cargo-ament-build "$$CAB" ; \
        fi
endef

# Target runtime from the SDK 3pp DEPLOY tree (the set Wind River intends for the
# target; develop adds only Boost, which nothing in the ROS 2 image links).
# From deploy/usr/bin only the Python interpreter is needed on the target: the
# other entries are host/dev tools or scripts VxWorks cannot exec by shebang.
define sdk_deploy
	cp $(WIND_CC_SYSROOT)/usr/lib/common/lib*.so.[0-9] $(DEPLOY_DIR)/lib/. ; \
	cp $(3PP_DEPLOY_DIR)/usr/bin/python3 $(3PP_DEPLOY_DIR)/usr/bin/python3.$(TGT_PYTHON_MINOR) $(DEPLOY_DIR)/bin/. ; \
	cp $(3PP_DEPLOY_DIR)/usr/lib/lib*.so* $(DEPLOY_DIR)/lib/. ; \
	cp -r $(3PP_DEPLOY_DIR)/usr/lib/python3.* $(DEPLOY_DIR)/lib/.
endef

endif
