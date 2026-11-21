#!/usr/bin/env bash
# extract-deploy.sh - extract the target rootfs (deploy tree) from the toolkit's
# ros2.img into a directory, so you can inspect or customize it and then repack
# with make-image.sh. Uses mtools (mcopy) - no sudo/mount needed.
#
#   extract-deploy.sh [<dest-dir>]      # default: ./deploy
set -euo pipefail

TOOLKIT_DIR="${TOOLKIT:-${KIT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}}"
IMG="${VX_IMG:-$TOOLKIT_DIR/ros2.img}"
DEST="${1:-./deploy}"

[ -f "$IMG" ] || { echo "no ros2.img at $IMG"; exit 1; }
command -v mcopy >/dev/null || { echo "mtools (mcopy) not installed"; exit 1; }

rm -rf "$DEST"; mkdir -p "$DEST"
echo "Extracting $IMG -> $DEST"
mcopy -i "$IMG" -s -n "::/*" "$DEST"/
echo "Done. Top-level:"
ls -1 "$DEST"
