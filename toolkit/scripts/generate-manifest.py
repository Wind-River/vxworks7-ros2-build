#!/usr/bin/env python3
"""generate-manifest.py - build the ROS 2 SDK toolkit manifest from packages.mk.

The JSON keys mirror the Makefile variable names 1:1 (ROS2_PATCH_DIRS,
ROS_IGNORE_*, ROS2_BASE, ROS2_EXAMPLES, ROS2_RUST, ROS2_MIXINS, ROS2_VENDORS),
so the manifest is a faithful record of what the SDK build patched / ignored /
built. Also pins the layer (url + branch + resolved commit) and the SDK/distro/arch.

Usage:
  generate-manifest.py <packages.mk> <ros_distro> <vxworks_release> \
      <vxworks_sdk> <arch> <layer_url> <layer_branch> <layer_commit> \
      [rust_target] [build_commit] [build_describe]
"""
import re, json, sys, datetime


def var(lines, name):
    out, collecting = [], False
    for ln in lines:
        if not collecting:
            m = re.match(rf'\s*{re.escape(name)}\s*\+?=\s*(.*)$', ln)
            if not m:
                continue
            collecting = True
            rest = m.group(1)
        else:
            rest = ln
        cont = rest.rstrip().endswith('\\')
        rest = rest.rstrip()
        if cont:
            rest = rest[:-1]
        rest = re.sub(r'#.*', '', rest)
        out.append(rest)
        if not cont:
            break
    if not collecting:
        return None
    body = ' '.join(out)
    body = re.sub(r'\$\([^)]*\)', ' ', body)   # drop $(VAR) references
    return [t for t in body.split() if t and t != '\\']


def main():
    (mk, ros_distro, vx_rel, vx_sdk, arch,
     layer_url, layer_branch, layer_commit) = sys.argv[1:9]
    rust_target    = sys.argv[9]  if len(sys.argv) > 9  else f"{arch}-wrs-vxworks"
    build_commit   = sys.argv[10] if len(sys.argv) > 10 else ""
    build_describe = sys.argv[11] if len(sys.argv) > 11 else ""
    lines = open(mk).read().splitlines()
    v = lambda n: var(lines, n)

    manifest = {
        "ros_distro": ros_distro,
        "vxworks_release": vx_rel,
        "vxworks_sdk": vx_sdk,
        "arch": arch,
        # the build repo (vxworks7-ros2-build) that produced this toolkit -- check it
        # out at `build.commit` and re-run `make toolkit` to reproduce.
        "build": {
            "repo": "vxworks7-ros2-build",
            "commit": build_commit,
            "describe": build_describe,
        },
        "layer": {
            "PKG_LAYER_URL": layer_url,
            "PKG_LAYER_COMMIT_ID": layer_branch,
            "commit": layer_commit,
        },
        "ROS2_MIXINS": v("ROS2_MIXINS"),
        "ROS2_VENDORS": (v("ROS2_VENDORS") or [None])[0],
        "ROS2_PATCH_DIRS": v("ROS2_PATCH_DIRS"),
        "ROS_IGNORE_DIRS": v("ROS_IGNORE_DIRS"),
        "ROS_IGNORE_TESTING_DIRS": v("ROS_IGNORE_TESTING_DIRS"),
        "ROS_IGNORE_PYTHON_DIRS": v("ROS_IGNORE_PYTHON_DIRS"),
        "ROS2_BASE": v("ROS2_BASE"),
        "ROS2_EXAMPLES": v("ROS2_EXAMPLES"),
        "ROS2_RUST": v("ROS2_RUST"),
        "ROS2_RUST_TARGET": rust_target,
        "built_on": datetime.datetime.now().astimezone().isoformat(timespec="seconds"),
    }
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
