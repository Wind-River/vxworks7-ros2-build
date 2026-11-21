#!/usr/bin/env python3
"""gen-release-notes.py - render a toolkit's RELEASE_NOTES.md.

Combines the auto-generated identity (from manifest.json) with a curated
fragment (RELEASE_NOTES.in.md: Use / Features / Known limitations).

Usage:
  gen-release-notes.py <manifest.json> <kit_name> <notes.in.md> > RELEASE_NOTES.md
"""
import json, re, sys


def main():
    manifest, name, notes_in = sys.argv[1], sys.argv[2], sys.argv[3]
    m = json.load(open(manifest))
    b = m.get("build", {}); l = m.get("layer", {})
    base = m.get("ROS2_BASE") or []

    out = [
        f"# {name}\n",
        "ROS 2 VxWorks SDK toolkit — a prebuilt ROS 2 SDK + overlay + image + scripts",
        "for cross-building ROS 2 apps for VxWorks and running them on QEMU.\n",
        "## This build\n",
        f"- ROS 2 distro:     **{m.get('ros_distro','?')}**",
        f"- VxWorks release:  **{m.get('vxworks_release','?')}**",
        f"- VxWorks SDK:      `{m.get('vxworks_sdk','?')}`",
        f"- Arch:             `{m.get('arch','?')}`",
        f"- Built:            {m.get('built_on','?')}",
        f"- Build repo:       `{b.get('repo','?')}` @ `{b.get('describe') or b.get('commit','?')}`",
        f"    - commit:       `{b.get('commit','?')}`",
        f"- ROS 2 layer:      {l.get('PKG_LAYER_URL','?')}",
        f"    - branch:       `{l.get('PKG_LAYER_COMMIT_ID','?')}`  commit: `{l.get('commit') or 'unpinned'}`",
        f"- Packages:         {len(base)} base + vendors/examples (see `manifest.json`)\n",
        "> Reproduce: check out the build repo at the commit above and run `make toolkit`.",
    ]
    text = "\n".join(out) + "\n"

    # append the curated fragment (strip the leading <!-- ... --> comment)
    try:
        frag = open(notes_in).read()
        frag = re.sub(r"<!--.*?-->\s*", "", frag, count=1, flags=re.S)
        text += "\n" + frag.lstrip()
    except FileNotFoundError:
        pass

    sys.stdout.write(text)


if __name__ == "__main__":
    main()
