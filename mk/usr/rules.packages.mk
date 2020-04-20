# Makefile fragment for rules.packages.mk
#
# Copyright (c) 2019 Wind River Systems, Inc.
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

.PHONY: all

ifndef __packages_defs
include $(WIND_USR_MK)/defs.packages.mk
endif

define echo_action
	@$(ECHO) "--------------------------------------------------------------------------------"; \
	$(ECHO) "$1"; \
	$(ECHO) "--------------------------------------------------------------------------------";
endef

define pkg_install
	cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	$(PKG_MAKE_INSTALL_VAR) $(MAKE) -C $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) -f Makefile $(PKG_MAKE_INSTALL_OPT)
endef

define pkg_distclean
	if [ -n "$(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR)" ] && \
	   [ -d $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ]; then \
		echo "Deleting $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR)"; \
		rm -rf $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR); \
        fi; \
	if [ -n "$(BUILD_DIR)/$(1)/$(PKG_SRC_DIR)" ] && \
	   [ -d $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) ]; then \
		echo "Deleting $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR)"; \
		rm -rf $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR); \
        fi; \
	if [ -d $(BUILD_DIR)/$(1) ]; then \
		rmdir $(BUILD_DIR)/$(1); \
	fi
endef

define pkg_clean
	if [ -n "$(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR)" ] && \
	   [ -d $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ]; then \
		$(MAKE) -C $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) -f Makefile clean; \
	fi
endef

define pkg_build
	cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) && \
	export MAKEFLAGS='$(FILTERED_MAKEFLAGS)' &&  \
	echo "MAKE_OPT: $(PKG_MAKE_OPT)" && \
	$(MAKE) -j$(nproc) -C $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) -f Makefile $(PKG_MAKE_OPT)
endef

define pkg_configure
	mkdir -p $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ; \
	if [ -n "$(VXWORKS_ENV_SH)" ] && \
	   [ -f $(VXWORKS_ENV_SH) ]; then \
		. ./$(VXWORKS_ENV_SH); \
	fi ; \
	cd $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) && \
	if [ -f $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR)/CMakeLists.txt ]; then \
		cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ; \
		cmake $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) \
		    -DCMAKE_TOOLCHAIN_FILE=$(TGT_CMAKE_TOOLCHAIN_FILE) \
		    -DCMAKE_INSTALL_PREFIX=$(CMAKE_INSTALL_PREFIX) \
		    -DCMAKE_PREFIX_PATH=$(ROOT_DIR) \
		    -DCMAKE_MODULE_PATH=$(CMAKE_MODULE_DIR) \
		    $(CMAKE_OPT) ; \
	else \
		if [ -f configure.in -o -f configure.ac ] ; then \
			autoreconf --verbose --install --force || exit 1 ; \
		fi ; \
		if [ -f ./configure ]; then \
			cd $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ; \
			$(PKG_CONFIGURE_VAR) $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR)/configure \
				$(PKG_CONFIGURE_OPT) ; \
		fi ; \
	fi
endef

define pkg_patch
	if [ -f $(PACKAGE_DIR)/$(1)/$(PKG_PATCH_DIR)/series ]; then \
		PATCHES=$$(cat $(PACKAGE_DIR)/$(1)/$(PKG_PATCH_DIR)/series | grep -v '^ *#'); \
		for PATCH in $$PATCHES; do \
			if [ -f "$(PACKAGE_DIR)/$(1)/$(PKG_PATCH_DIR)/$$PATCH" ]; then \
			$(PATCH) -p1 -N -d $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) -p1 < $(PACKAGE_DIR)/$(1)/$(PKG_PATCH_DIR)/$$PATCH ; \
			fi; \
		done; \
	fi
endef

define pkg_buildsys
	mkdir -p $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) && \
	for FILE in $(BUILD_SYS_FILES) $(PKG_EXTRA_SRC); do \
		if [ -f $$FILE ] ; then \
			cp $$FILE $(BUILD_DIR)/$(1)/$(PKG_BUILD_DIR) ; \
		fi  ; \
	done
endef

define fetch_svn
	$(ECHO) "fetch_svn - not yet implemented" ; \
	exit 1
endef

stringify_url=$(subst *,.,$(subst /,.,$(subst :,.,$1)))

define clone_git
	$(ECHO) "clone_git $1" ; \
	GIT_DIR_NAME=$(call stringify_url,$(PKG_URL)) ; \
	mkdir -p $(BUILD_DIR)/$(1); \
	if [ ! -d $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) ] ; then \
		cd $(BUILD_DIR)/$(1) && \
		LANG=C git clone $(DOWNLOADS_DIR)/$$GIT_DIR_NAME $(PKG_SRC_DIR) --progress ; \
		if [ -n "$(PKG_COMMIT_ID)" ]; then \
			cd $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) && \
			LANG=C git checkout $(PKG_COMMIT_ID); \
		fi ; \
	else \
		$(ECHO) "$(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) already exists." ; \
		exit 1 ; \
	fi
endef

define fetch_git
	$(ECHO) "fetch_git $1" ; \
	GIT_DIR_NAME=$(call stringify_url,$(PKG_URL)) ; \
	mkdir -p $(BUILD_DIR)/$(1); \
	if [ ! -d $(DOWNLOADS_DIR)/$$GIT_DIR_NAME ] ; then \
		cd $(DOWNLOADS_DIR) &&  \
		echo LANG=C git clone --bare --mirror $(PKG_URL) $(DOWNLOADS_DIR)/$$GIT_DIR_NAME --progress ; \
		LANG=C git clone --bare --mirror $(PKG_URL) $(DOWNLOADS_DIR)/$$GIT_DIR_NAME --progress ; \
	else \
		cd $(DOWNLOADS_DIR)/$$GIT_DIR_NAME &&  \
	        LANG=C git fetch -f --prune --progress $(PKG_URL) refs/*:refs/* ; \
	fi
endef

define fetch_hg
        $(ECHO) "fetch_hg $1" ; \
	HG_DIR_NAME=$(call stringify_url,$(PKG_URL)) ; \
	mkdir -p $(BUILD_DIR)/$(1); \
        if [ ! -d $(DOWNLOADS_DIR)/$$HG_DIR_NAME ] ; then \
                cd $(DOWNLOADS_DIR) &&  \
                echo LANG=C hg clone $(PKG_URL) $(DOWNLOADS_DIR)/$$HG_DIR_NAME ; \
                LANG=C hg clone $(PKG_URL) $(DOWNLOADS_DIR)/$$HG_DIR_NAME ; \
        else \
                cd $(DOWNLOADS_DIR)/$$HG_DIR_NAME &&  \
                LANG=C hg fetch $(PKG_URL) ; \
        fi
endef

define clone_hg
        $(ECHO) "clone_hg " ; \
	HG_DIR_NAME=$(call stringify_url,$($(1)_URL)) ; \
	mkdir -p $(BUILD_DIR)/$(1); \
        if [ ! -d $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) ] ; then \
                cd $(BUILD_DIR)/$(1) && \
                LANG=C hg clone $(DOWNLOADS_DIR)/$$HG_DIR_NAME $(PKG_SRC_DIR) ; \
                if [ -n "$($(1)_COMMIT_ID)" ]; then \
                        cd $(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) && \
                        LANG=C hg update $(PKG_COMMIT_ID); \
                fi ; \
        else \
                $(ECHO) "$(BUILD_DIR)/$(1)/$(PKG_SRC_DIR) already exists." ; \
                exit 1 ; \
        fi
endef


define fetch_cvs
	$(ECHO) "fetch_cvs - not yet implemented" ; \
	exit 1
endef

define fetch_web
	$(ECHO) "fetch_web $1 $2 $3 $4"; \
	if [ -f $$(which $(CURL)) ]; then  \
		$(CURL) $(CURL_OPT) $(PKG_FILE_NAME) $(PKG_URL) ; \
	elif [ -f $$(which $(WGET)) ]; then \
		$(WGET) $(WGET_OPT) $(PKG_FILE_NAME) $(PKG_URL) ; \
	fi
endef

define fetch_ftp
	$(ECHO) "fetch_ftp $1 $2 $3 $4"; \
	if [ -f $$(which $(CURL)) ]; then  \
		$(CURL) $(CURL_OPT) $(PKG_FILE_NAME) $(PKG_URL) ; \
	elif [ -f $$(which $(WGET)) ]; then \
		$(WGET) $(WGET_OPT) $(PKG_FILE_NAME) $(PKG_URL) ; \
	fi
endef

# XXX
define unpack_archive
	$(ECHO) "Unpacking archive $1" ; \
	mkdir -p $(BUILD_DIR)/$(1); \
	case "$(PKG_FILE_NAME)" in \
	  *.tar.bz2) \
	    $(BZIP2) -dc $(DOWNLOADS_DIR)/$(PKG_FILE_NAME) \
	    | $(TAR) -xf - -C $(BUILD_DIR)/$1 ;; \
	  *.tgz|*.tar.gz) \
	    $(GZIP) -dc $(DOWNLOADS_DIR)/$(PKG_FILE_NAME) \
	    | $(TAR) -xf - -C $(BUILD_DIR)/$1 ;; \
	  *.tar) \
	    $(TAR) -xf $(DOWNLOADS_DIR)/$(PKG_FILE_NAME) \
	    -C $(BUILD_DIR)/$1 ;; \
	  *.zip) \
	    $(UNZIP) $(DOWNLOADS_DIR)/$(PKG_FILE_NAME) \
	    -d $(BUILD_DIR)/$1 ;; \
	esac
endef

define pkg_unpack
	case "$(PKG_TYPE)" in \
		git) $(call clone_git,$(1)) ;; \
		hg) $(call clone_hg,$(1)) ;; \
		cvs) $(call copy_cvs,$(1)) ;; \
		svn) $(call copy_svn,$(1)) ;; \
		unpack) $(call unpack_archive,$(1)) ;; \
		*) $(OTHER_UNPACK) ;; \
	esac
endef

# XXX
define fetch_archive
	$(ECHO) "Fetching archive $(PKG_FILE_NAME)" ; \
	if [ -n "$(PKG_FILE_NAME)" ] && [ ! -f $(DOWNLOADS_DIR)/$(PKG_FILE_NAME) ] ; then \
		case "$(PKG_URL)" in \
			http://*) $(call fetch_web,$(PKG_NAME),$(PKG_URL), \
			            $(PKG_FILE_NAME)) ;; \
			https://*) $(call fetch_web,$(PKG_NAME),$(PKG_URL), \
			            $(PKG_FILE_NAME)) ;; \
			ftp://*) $(call fetch_ftp,$(PKG_NAME),$(PKG_URL), \
			            $(PKG_FILE_NAME)) ;; \
			*) $(OTHER_CHECKOUT) ;; \
		esac ; \
	fi ; \
	sleep 1 ; \
	if [  -f $@ ] ; then \
		if [ `du -k $@ | cut -f 1` -le 2 ] ; then \
			$(ECHO) "Download failed, file too small" >&2 ; \
			exit 1 ; \
		fi ; \
	fi
endef

define pkg_checksum
	if [ "$($(1)_FILE_TYPE)" == "unpack" ] ; then \
		if [ ! -f "$(DOWNLOADS_DIR)/$(PKG_FILE_NAME)" ] ; then \
			echo "Could not find $(PKG_FILE_NAME) in downloads" ; \
			exit 1 ; \
		fi ; \
		if [ -n "$(PKG_MD5_CHECKSUM)" ]; then \
			echo "$(PKG_MD5_CHECKSUM)  $(DOWNLOADS_DIR)/$(PKG_FILE_NAME)" | md5sum --check || \
			exit 1 ; \
		fi ; \
	fi
endef

define pkg_download
	cd $(DOWNLOADS_DIR); \
	case "$(PKG_TYPE)" in \
		svn) $(call fetch_svn,$(1)) ;; \
		git) $(call fetch_git,$(1)) ;; \
		hg) $(call fetch_hg,$(1)) ;; \
		cvs) $(call fetch_cvs,$(1)) ;; \
		unpack) $(call fetch_archive,$(1)) ;; \
		*) $(OTHER_CHECKOUT) ;; \
	esac
endef

%.clean:
	@$(call echo_action,Cleaning,$*)
	$(call pkg_clean,$*)
	@$(CLEAN_STAMP)

%.distclean:
	@$(call echo_action,Distcleaning,$*)
	$(call pkg_distclean,$*)
	@$(CLEAN_STAMP)
	@$(DISTCLEAN_STAMP)

%.install : %.build
	@$(call echo_action,Installing,$*)
	$(call pkg_install,$*)
	@$(MAKE_STAMP)

%.build : %.configure
	@$(call echo_action,Building,$*)
	$(call pkg_build,$*)
	@$(MAKE_STAMP)

%.configure : $(CONFIGURE_DEPENDS) %.patch
	@$(call echo_action,Configuring,$*)
	$(call pkg_configure,$*)
	@$(MAKE_STAMP)

%.patch : %.buildsys
	@$(call echo_action,Patching,$*)
	$(call pkg_patch,$*)
	@$(MAKE_STAMP)

%.buildsys: %.unpack
	@$(call echo_action,Adding build system files,$*)
	$(call pkg_buildsys,$*)
	@$(MAKE_STAMP)

%.unpack : %.check
	@$(call echo_action,Unpacking,$*)
	$(call pkg_unpack,$*)
	@$(MAKE_STAMP)

%.check : %.download
	@$(call echo_action,Checksum,$*)
	$(call pkg_checksum,$*)
	@$(MAKE_STAMP)

%.download: | $(TPP_DIRS)
	@$(call echo_action,Downloading,$*)
	$(call pkg_download,$*)
	@$(MAKE_STAMP)
