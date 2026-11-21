#!/usr/bin/env bash
# apply-sdk-patches.sh <patch-dir> <sdk-root> - apply pkg/sdk's SDK patches.
#
# The one place that applies them: pkg/sdk sdk_fix (files/<rel>/defs.sdk.mk) on the
# build's SDK, and the SDK overlay's sdk_fix_install (mk/usr/install-sdk-overlay.sh,
# which ships this script) on a toolkit user's SDK.
#
# Patch paths are relative to the SDK root (-p1). Idempotent: a patch that is
# already applied is skipped; one that neither applies nor is applied fails (the
# SDK differs from the one the patch was made for).
set -euo pipefail

[ $# -eq 2 ] || { echo "usage: apply-sdk-patches.sh <patch-dir> <sdk-root>" >&2; exit 2; }
dir="$1" sdk="$2"
command -v patch >/dev/null || { echo "apply-sdk-patches: 'patch' not found" >&2; exit 1; }
[ -d "$sdk" ] || { echo "apply-sdk-patches: no SDK at $sdk" >&2; exit 1; }

for p in "$dir"/*.patch; do
  [ -f "$p" ] || continue
  n="$(basename "$p")"
  if patch -d "$sdk" -p1 -R --dry-run -s -f < "$p" >/dev/null 2>&1; then
    echo "== $n: already applied"
  elif patch -d "$sdk" -p1 --dry-run -s -f < "$p" >/dev/null 2>&1; then
    patch -d "$sdk" -p1 -s -f --no-backup-if-mismatch < "$p"
    echo "== $n: applied"
  else
    echo "apply-sdk-patches: $n does not apply to $sdk" >&2
    exit 1
  fi
done
