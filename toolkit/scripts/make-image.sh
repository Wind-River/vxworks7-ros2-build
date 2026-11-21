#!/usr/bin/env bash
# make-image.sh - (re)build a bootable ros2.img FAT32 disk from a deploy tree
# (e.g. one produced by extract-deploy.sh and then customized). Uses mtools -
# no sudo/mount needed.
#
#   make-image.sh <deploy-dir> [<out.img>] [<size-MB>]
#     <deploy-dir>  the target rootfs (must contain bin/ lib/ share/ vxscript)
#     <out.img>     default: ./ros2.img
#     <size-MB>     default: 2048
set -euo pipefail

DEPLOY="${1:?usage: make-image.sh <deploy-dir> [out.img] [size-MB]}"
OUT="${2:-./ros2.img}"
SIZE_MB="${3:-2048}"

[ -d "$DEPLOY" ] || { echo "deploy dir not found: $DEPLOY"; exit 1; }
command -v mkfs.vfat >/dev/null || { echo "dosfstools (mkfs.vfat) not installed"; exit 1; }
command -v mcopy      >/dev/null || { echo "mtools (mcopy) not installed"; exit 1; }
[ -f "$DEPLOY/vxscript" ] || echo "WARN: $DEPLOY has no vxscript (target env won't be set up at boot)"

echo "Creating $OUT (${SIZE_MB} MB FAT32) from $DEPLOY"
dd if=/dev/zero of="$OUT" bs=1M count="$SIZE_MB" status=none
mkfs.vfat -F 32 "$OUT" >/dev/null
# copy every top-level entry of the deploy tree into the image root
for entry in "$DEPLOY"/*; do
  mcopy -i "$OUT" -s "$entry" "::/"
done
echo "Done: $OUT"
mdir -i "$OUT" :: 2>/dev/null | grep -iE 'bin|lib|share|vxscript' || true
