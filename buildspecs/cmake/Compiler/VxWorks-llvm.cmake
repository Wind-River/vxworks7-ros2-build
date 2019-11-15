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
# Toolchain file for building RTP applications against this VSB.
# Copyright (c) 2016-2018 Wind River Systems, Inc. All Rights Reserved.

# why -m elf_i386 flag is defined here
# set(CMAKE_LINKER "$ENV{LD}")

# setup ldpentium linker, cmake uses compiler as a linker by default, see next line
# set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER>  <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")
# set(CMAKE_CXX_CREATE_SHARED_LIBRARY "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

# get rid of --start-group --end-group in LIBS
# string(REGEX REPLACE "--start-group(.*)--end-group" "\\1" LIBS "$ENV{LIBS}")
# string(REGEX REPLACE "-ldl" "" SHLIBS "${LIBS}")
# string(REGEX REPLACE "-lsyscall" "" SHLIBS "${SHLIBS}")
