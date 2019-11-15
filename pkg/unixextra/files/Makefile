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

SOURCES := $(wildcard $(srcdir)/*.c)
OBJECTS := $(SOURCES:.c=.o)

CC_FLAGS = -g

all: libunixextra.a

libunixextra.so: $(OBJECTS)
	$(CC) -shared $* -o $@ $(CC_FLAGS)

libunixextra.a: $(OBJECTS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -static -c $< -o $@ $(CC_FLAGS)

clean:
	@rm -rf *.o $(TARGET)

install:
	install -d $(DESTDIR)/include
	install -m 644 $(srcdir)/fnmatch.h $(DESTDIR)/include
	install -m 644 $(srcdir)/string.h $(DESTDIR)/include
	install -d $(DESTDIR)/lib
	install -m 755 libunixextra.a $(DESTDIR)/lib
	# install -m 755 libunixextra.so $(DESTDIR)/lib

