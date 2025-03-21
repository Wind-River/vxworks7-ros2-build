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

TARGET = libunixextra
SOURCES := $(wildcard *.c)
OBJECTS := $(SOURCES:.c=.o)
SHOBJECTS := $(SOURCES:.c=.sho)
TESTS := $(patsubst %.c,%,$(wildcard tests/*.c))

PREFIX ?= /usr/local
INCLUDE_PATH ?= include
LIBRARY_PATH ?= lib
LIBRARY_VER ?= 1

CC_FLAGS ?= -g

all: $(TARGET).a $(TARGET).so.${LIBRARY_VER} $(TESTS)

$(TARGET).so.${LIBRARY_VER}: $(SHOBJECTS)
	$(CC) -shared -Wl,-soname,$@ $^ -o $@ $(CC_FLAGS)
	ln -s $@ $(TARGET).so

%.sho: %.c
	$(CC) -fpic -c $< -o $@ -I. $(CC_FLAGS)

$(TARGET).a: $(OBJECTS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -static -c $< -o $@ -I. $(CC_FLAGS)

$(TESTS): %: %.c $(TARGET).a
	$(CC) -static -o $@ $< $(CC_FLAGS) $(TARGET).a

clean:
	@rm -rf *.o *.sho $(TARGET).* $(TESTS)

install: $(TARGET).a $(TARGET).so
ifneq (,$(findstring fnmatch.c,$(SOURCES)))
	install -d $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
	install -m 644 fnmatch.h $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
endif
ifneq (,$(findstring memccpy.c,$(SOURCES)))
	install -d $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
	install -m 644 string.h $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
endif
ifneq (,$(findstring termios.c,$(SOURCES)))
	install -d $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)/sys
	install -m 644 termios.h $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
	install -m 644 sys/ttycom.h $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)/sys
endif
ifneq (,$(findstring flock.c,$(SOURCES)))
	install -d $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)/sys
	install -m 644 sys/file.h $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)/sys
endif
ifneq (,$(findstring pthread_getname.c,$(SOURCES)))
	install -d $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
	install -m 644 pthread.h $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
endif
ifneq (,$(findstring posix_fallocate.c,$(SOURCES)))
	install -d $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
	install -m 644 fcntl.h $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
endif
	install -d $(DESTDIR)$(PREFIX)/$(LIBRARY_PATH)
	install -m 755 $(TARGET).a $(DESTDIR)$(PREFIX)/$(LIBRARY_PATH)
	install -m 755 $(TARGET).so* $(DESTDIR)$(PREFIX)/$(LIBRARY_PATH)
