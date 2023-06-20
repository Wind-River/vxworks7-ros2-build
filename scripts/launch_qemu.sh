#!/bin/bash

# Copyright (c) 2023 Wind River Systems, Inc.
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

#!/bin/bash

# define default parameters
memory=512M
kernel_path=~/Downloads/wrsdk/vxsdk/bsps/*/vxWorks
image_path=./ros2.img
bootline="bootline:fs(0,0)host:/vxWorks h=192.168.200.254 e=192.168.200.1 u=ftp pw=ftp123 o=gei0 s=/ata4/vxscript"

# process flags
while getopts m:k:i:b: flag
do
    case "${flag}" in
        m) memory=${OPTARG};;
        k) kernel_path=${OPTARG};;
        i) image_path=${OPTARG};;
        b) bootline=${OPTARG};;
    esac
done

# install uml-utilities if not already installed
echo "Checking and installing uml-utilities if not already installed..."
if ! dpkg -l | grep uml-utilities; then
  sudo apt-get install uml-utilities
  if [ $? -eq 0 ]; then
    echo "uml-utilities installed successfully."
  else
    echo "Failed to install uml-utilities."
    exit 1
  fi
fi

# setup tap0
echo "Setting up tap0..."
sudo tunctl -u $USER -t tap0
sudo ifconfig tap0 192.168.200.254 up
if [ $? -eq 0 ]; then
    echo "tap0 setup successfully."
else
    echo "Failed to setup tap0."
    exit 1
fi

# start qemu
echo "Starting qemu..."
sudo qemu-system-x86_64 -m $memory -kernel $kernel_path -net nic -net tap,ifname=tap0,script=no,downscript=no -display none -serial stdio -append "$bootline" -device ich9-ahci,id=ahci -drive file=$image_path,if=none,id=ros2disk,format=raw -device ide-hd,drive=ros2disk,bus=ahci.0
if [ $? -eq 0 ]; then
    echo "qemu started successfully."
else
    echo "Failed to start qemu."
    exit 1
fi
