# Makefile - for ASIO
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
# 26jun18,rcw updated
# 12mar18,akh  created
#

PACKAGES += asio

asio_NAME = asio
asio_VER = 1.12.0
asio_TYPE = unpack

ifeq  "$(WIND_SDK_HOST_TYPE)" "x86-win32"
asio_URL = https://github.com/chriskohlhoff/asio/archive/asio-1-12-0.zip
asio_FILE_NAME = asio-1-12-0.zip
asio_TYPE = unpack
asio_MD5_CHECKSUM = e7b27761818ba597886620c87f48a768
else
asio_URL = https://github.com/chriskohlhoff/asio/archive/asio-1-12-0.tar.gz
asio_FILE_NAME = asio-1-12-0.tar.gz
asio_TYPE = unpack
asio_MD5_CHECKSUM = 9bacab7c7c9a0e81410571f14e36cbe4
endif

asio_LICENSE = Boost

asio_BUILD_DIR = build
asio_SRC_DIR = asio-asio-1-12-0/asio
asio_PATCH_DIR = files

asio_LIBS := -lunix -lnet

asio_CONFIGURE_OPT = $(TGT_CONFIGURE_OPT) LIBS="$(asio_LIBS)"
asio_MAKE_INSTALL_OPT = $(TGT_MAKE_INSTALL_OPT)

_WRS_CONFIG_CFG_ASIO_WITHOUT_BOOST = 1
ifdef _WRS_CONFIG_CFG_ASIO_WITHOUT_BOOST
asio_CONFIGURE_OPT += --without-boost
endif
# PKG_EXTRA_SRC = acinclude.m4
