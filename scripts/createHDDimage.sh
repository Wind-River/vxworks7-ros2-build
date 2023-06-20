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
disk_size=${1:-800}
disk_path=${2:-./ros2.img}
mount_path=${3:-~/tmp/mount}
source_path=${4:-./export/deploy/*}

# create a disk
echo "Creating a disk..."
sudo dd if=/dev/zero of=$disk_path count=$disk_size bs=1M
if [ $? -eq 0 ]; then
    echo "Disk created successfully."
else
    echo "Failed to create disk."
    exit 1
fi

# format it as a FAT32
echo "Formatting the disk as FAT32..."
sudo mkfs.vfat -F 32 $disk_path
if [ $? -eq 0 ]; then
    echo "Disk formatted successfully."
else
    echo "Failed to format the disk."
    exit 1
fi

# create mount directory if not already exist
echo "Creating mount directory..."
mkdir -p $mount_path
if [ $? -eq 0 ]; then
    echo "Mount directory created successfully."
else
    echo "Failed to create mount directory."
    exit 1
fi

# mount, copy, unmount
echo "Mounting the disk..."
sudo mount -o loop -t vfat $disk_path $mount_path
if [ $? -eq 0 ]; then
    echo "Disk mounted successfully."
else
    echo "Failed to mount the disk."
    exit 1
fi

echo "Copying files..."
sudo cp -r -L $source_path $mount_path/.
if [ $? -eq 0 ]; then
    echo "Files copied successfully."
else
    echo "Failed to copy files."
    exit 1
fi

echo "Unmounting the disk..."
sudo umount $mount_path
if [ $? -eq 0 ]; then
    echo "Disk unmounted successfully."
else
    echo "Failed to unmount the disk."
    exit 1
fi
