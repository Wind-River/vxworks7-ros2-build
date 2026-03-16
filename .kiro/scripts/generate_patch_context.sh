#!/bin/bash
# Ensure context folder exists
mkdir -p .kiro/context

# Remove old context file
rm -f .kiro/context/patches_content.txt

# Iterate all packages and patches under output/build/ros2/patches
for pkg in ./output/build/ros2/patches/*; do
  for f in "$pkg"/usr_src/*.patch "$pkg"/user_src/*.patch; do
    [ -f "$f" ] || continue
    echo "===== $pkg/$(basename $f) =====" >> .kiro/context/patches_content.txt
    cat "$f" >> .kiro/context/patches_content.txt
    echo "" >> .kiro/context/patches_content.txt
  done
done

echo "Patch context file generated at .kiro/context/patches_content.txt"
