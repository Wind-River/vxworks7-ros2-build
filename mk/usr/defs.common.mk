# Makefile fragment for defs.common.mk
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
#
# modification history
# --------------------
# 19may16,brk HLD review changes
# 21mar14,brk created
#
PACKAGE_DIR=$(TOP_BUILDDIR)/pkg
BUILD_DIR=$(TOP_BUILDDIR)/build
DOWNLOADS_DIR=$(TOP_BUILDDIR)/downloads
EXPORT_DIR=$(TOP_BUILDDIR)/export
ROOT_DIR=$(EXPORT_DIR)/root

TPP_DIRS = $(DOWNLOADS_DIR) $(STAMP_DIR) $(EXPORT_DIR)

ECHO  ?= echo
RM    ?= rm
PATCH ?= patch

UNZIP ?= unzip
BZIP2 ?= bzip2
GZIP  ?= gzip

TAR ?= tar

CURL ?= curl
CURL_OPT  ?= -L --output
WGET ?= wget
WGET_OPT  ?= -O

CHMOD ?= chmod
TOUCH = touch
