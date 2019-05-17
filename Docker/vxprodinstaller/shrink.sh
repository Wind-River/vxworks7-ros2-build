#!/bin/bash

# Copyright (c) 2018-2019 Wind River Systems, Inc.
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

. ./config.sh

apt -y install fdupes

cd "$install_dir"

echo "At the start, before removing extra files... "
du -sh "${install_dir}"

# Remove any apt deps


# Remove Windows parts of Workbench
rm -rf ${install_dir}/workbench-4/eclipse/*win*

rm -rf ${download_dir}

# Remove Windows compilers
rm -rf "$install_dir/compilers/llvm-6.0.0.2/WIN32"
rm -rf "$install_dir/compilers/gnu-8.1.0.0/x86-win32/"

# Look for duplicates in /opt/windriver/compilers/llvm-6.0.0.2/LINUX386/bin
echo "Before removing duplicates: "
du -sh "${install_dir}"

tmpfile=$(mktemp)
fdupes -r --quiet --sameline "$install_dir/compilers/" > "$tmpfile"

echo results in $tmpfile

while read -r line ; do
	firstfile=""
	for f in $line ; do 
		if [ -z "$firstfile" ] ; then
			firstfile=$f
			echo "Finding duplicates of $firstfile"
		else
			rm "$f"
			ln -s "$firstfile" "$f"
		fi
	done


done < "$tmpfile"
rm -f ${tmpfile}
echo "After: "
du -sh "${install_dir}"

apt autoremove -y fdupes

exit 0
