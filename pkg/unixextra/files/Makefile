# Makefile - makefile for extra_unix layer
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
# 27oct18,akh  Created
#
# DESCRIPTION
# This file contains the makefile rules for building the extra functions
# UNIX library
#
#
include $(WIND_USR_MK)/defs.common.mk

SOURCES := $(wildcard $(srcdir)/*.c)
OBJECTS := $(SOURCES:.c=.o)
SHOBJECTS := $(SOURCES:.c=.sho)

CC_FLAGS = -g

all: cp_headers libunixextra.a libunixextra.so

cp_headers:
	install -m 644 $(srcdir)/termios.h $(WIND_CC_SYSROOT)/usr/h/published/UTILS_UNIX
	install -m 644 $(srcdir)/ttycom.h $(WIND_CC_SYSROOT)/usr/h/published/UTILS_UNIX/sys
	sed -i 's/_WRS_INLINE/inline/g'  $(WIND_CC_SYSROOT)/usr/h/public/endian.h
	sed -i 's/STATUS/int/g' `find $(WIND_CC_SYSROOT)/usr/h -name stat.h`

libunixextra.so: $(SHOBJECTS)
	$(CC) -shared $^ -o $@ $(CC_FLAGS)

%.sho: %.c
	$(CC) -fpic -c $< -o $@ $(CC_FLAGS)

libunixextra.a: $(OBJECTS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -static -c $< -o $@ $(CC_FLAGS)

clean:
	@rm -rf *.o $(TARGET)

install:
	install -m 644 $(srcdir)/fnmatch.h $(WIND_CC_SYSROOT)/usr/h/published/UTILS_UNIX
	install -m 644 $(srcdir)/string.h $(WIND_CC_SYSROOT)/usr/h/published/UTILS_UNIX
	install -m 755 libunixextra.a $(WIND_CC_SYSROOT)/usr/lib/common
	install -m 755 libunixextra.so $(WIND_CC_SYSROOT)/usr/lib/common
	install -m 755 libunixextra.so $(ROOT_DIR)/lib/.
	sed -i 's/-lregex -T/-lregex $$(LibToolCplus) -T/g' $(WIND_CC_SYSROOT)/cc-conf/default.conf
	sed -i 's/-lunix -lregex/-lunix -lunixextra -lregex/g' $(WIND_CC_SYSROOT)/cc-conf/default.conf

