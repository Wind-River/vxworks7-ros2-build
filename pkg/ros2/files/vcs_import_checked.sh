#!/usr/bin/env bash
# vcs_import_checked.sh — fetch (optional) + vcs import a .repos and VERIFY it fully succeeded.
#
# vcs import exits 0 even when individual repos fail to clone, so a dropped repo
# silently leaves an empty src/<path>/ dir — surfacing much later as a confusing
# "package not found" / colcon regex error. This wrapper makes failures loud and
# immediate by (1) checking the import exit code and (2) asserting every repo listed
# in the manifest actually materialized a non-empty working copy.
#
# Usage:
#   vcs_import_checked.sh --url  <URL>  <dst_src_dir>      # curl -f the manifest, then import+verify
#   vcs_import_checked.sh --file <path> <dst_src_dir>      # import+verify an existing manifest file
#
# Exits nonzero (and lists the offending repos) on any curl / import / materialization failure.
set -euo pipefail

mode=$1; src_arg=$2; dst=$3
save_to=${4:-}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if [ "$mode" = "--url" ]; then
  repos="$work/manifest.repos"
  # -f: fail (nonzero) on HTTP >=400 instead of saving the error page; -S show errors; -L follow.
  if ! curl -fSL -o "$repos" "$src_arg"; then
    echo "ERROR: failed to download manifest: $src_arg" >&2
    exit 1
  fi
elif [ "$mode" = "--file" ]; then
  repos="$src_arg"
  [ -f "$repos" ] || { echo "ERROR: manifest not found: $repos" >&2; exit 1; }
else
  echo "usage: $0 --url <URL>|--file <path> <dst_src_dir> [save_copy_path]" >&2; exit 2
fi

# Guard against an HTML/error body masquerading as a manifest.
if ! grep -qE '^\s*repositories\s*:' "$repos"; then
  echo "ERROR: '$repos' does not look like a vcs .repos file (no 'repositories:' key)." >&2
  echo "       First lines:" >&2; sed -n '1,5p' "$repos" | sed 's/^/         /' >&2
  exit 1
fi

# Optionally keep a copy of the validated manifest (e.g. the recipe wants ros2.repos locally).
if [ -n "$save_to" ]; then
  cp "$repos" "$save_to"
fi

mkdir -p "$dst"
echo "vcs import ($(basename "$repos")) -> $dst"
# --force : delete a pre-existing dir that is NOT the expected repo (fixes stray/partial
#           dirs that otherwise block the clone with 'destination path already exists').
# --retry : retry on transient network failures (the usual cause of a dropped clone).
VCS_RETRY=${VCS_RETRY:-3}
if ! vcs import --force --retry "$VCS_RETRY" "$dst" < "$repos"; then
  echo "ERROR: 'vcs import' returned nonzero for $(basename "$repos")." >&2
  exit 1
fi

# Verify every repo path in the manifest materialized a non-empty working copy.
# Parse the top-level keys under 'repositories:' (two-space-indented '<path>:' lines).
missing=()
empty=()
notgit=()
while IFS= read -r path; do
  [ -n "$path" ] || continue
  d="$dst/$path"
  if [ ! -d "$d" ]; then
    missing+=("$path"); continue
  fi
  # A genuine vcs checkout has its own .git (dir or file). A stray/partial dir with
  # some files but no .git (e.g. a leftover include/) is NOT a materialized repo and
  # will both block a re-clone and be invisible to colcon.
  if [ ! -e "$d/.git" ]; then
    notgit+=("$path"); continue
  fi
  # non-empty = has at least one tracked file
  if [ -z "$(find "$d" -mindepth 1 -maxdepth 3 -type f -print -quit 2>/dev/null)" ]; then
    empty+=("$path")
  fi
done < <(awk '
  /^repositories:/ {inrepos=1; next}
  inrepos && /^[^[:space:]]/ {inrepos=0}        # dedent out of repositories:
  inrepos && /^  [^[:space:]][^:]*:[[:space:]]*$/ {
      line=$0; sub(/^  /,"",line); sub(/:[[:space:]]*$/,"",line); print line
  }
' "$repos")

if [ ${#missing[@]} -gt 0 ] || [ ${#empty[@]} -gt 0 ] || [ ${#notgit[@]} -gt 0 ]; then
  echo "ERROR: vcs import did NOT fully materialize $(basename "$repos"):" >&2
  for p in "${missing[@]:-}"; do [ -n "$p" ] && echo "  missing dir : $p" >&2; done
  for p in "${empty[@]:-}";   do [ -n "$p" ] && echo "  empty clone : $p (dir exists but no files — clone/fetch failed)" >&2; done
  for p in "${notgit[@]:-}";  do [ -n "$p" ] && echo "  not a repo  : $p (dir exists with stray files but no .git — partial/blocked clone)" >&2; done
  echo "  (vcs import exits 0 even when a repo fails to clone — hence this check.)" >&2
  exit 1
fi

n=$(awk '/^repositories:/{f=1;next} f&&/^[^[:space:]]/{f=0} f&&/^  [^[:space:]][^:]*:[[:space:]]*$/{c++} END{print c+0}' "$repos")
echo "OK: all $n repos in $(basename "$repos") materialized."
