# Makefile fragment for defs.hosttool.mk
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

# --host and --build intentionally left to autodetct
CONFIGURE_OPT = \
	--prefix=/usr\
	--infodir=/usr/share/info \
	--mandir=/usr/share/man \
	--sysconfdir=/usr/etc \
	--includedir=/usr/include \
	--libdir=/usr/lib \
	--libexecdir=/usr/libexec \
	--localstatedir=/usr/var

MAKE_INSTALL_OPT = install DESTDIR=$(TPP_HOST_DIR)
