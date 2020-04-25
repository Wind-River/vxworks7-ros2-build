# CMake Toolchain file for RTPs - rtp.mcmake
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
# Toolchain file for building RTP applications against this VSB.
# Copyright (c) 2016-2018 Wind River Systems, Inc. All Rights Reserved.
#
#
# Must be used from a Wind River VxWorks SDK environment, i.e. WIND_SDK_TOOLKIT and
# related environment variables must be set for the build to succeed.
# This file is designed to reside in (TOP_BUILDDIR)/buildspecs/cmake
#
# Usage:
# WIND_HOME/wrenv.linux -p <product>
# . ./vxworks_env.sh && cmake -DCMAKE_TOOLCHAIN_FILE=${TOP_BUILDDIR}/buildspecs/cmake/rtp.cmake
# make
#
# modification history
# --------------------
# 03aug18,akh  rewritten
# 18oct16,mob  written

# The syntax of this file has been validated to work with cmake-3.10
# - cmake-3.3.0 or later is required for CROSSCOMPILING_EMULATOR to work
cmake_minimum_required(VERSION 2.8.7)

set(CMAKE_SYSTEM_NAME VxWorks)
set(CMAKE_SYSTEM_VERSION 7)
set(CMAKE_CROSSCOMPILING ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
