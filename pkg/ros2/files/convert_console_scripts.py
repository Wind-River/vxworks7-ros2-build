#!/usr/bin/env python3
# convert_console_scripts.py - rewrite setuptools EASY-INSTALL console-script
# shims (which import pkg_resources and build the whole working set at startup)
# into importlib.metadata wrappers that resolve a single entry point.
#
# Why: on the target the pkg_resources working-set scan over the image's
# *.dist-info/*.egg-info metadata costs minutes (single-threaded os.listdir/stat
# over FAT/HRFS). importlib.metadata does a targeted lookup instead. Behaviour of
# each script is identical: same console_scripts entry point is resolved + called.
#
# Idempotent: already-converted scripts (no EASY-INSTALL marker) are skipped.
# Usage: convert_console_scripts.py <bin_dir>

import os
import re
import sys

TRIPLE = re.compile(
    r"load_entry_point\('([^']+)==([^']+)',\s*'([^']+)',\s*'([^']+)'\)")


def convert(bin_dir):
    converted = 0
    for name in sorted(os.listdir(bin_dir)):
        path = os.path.join(bin_dir, name)
        if not os.path.isfile(path) or name.endswith('.easyinstall.bak'):
            continue
        try:
            with open(path, encoding='utf-8') as fh:
                txt = fh.read()
        except (UnicodeDecodeError, IsADirectoryError, PermissionError):
            continue  # binary / non-text file in bin/
        if 'EASY-INSTALL-ENTRY-SCRIPT' not in txt or 'load_entry_point' not in txt:
            continue  # not a slow shim (already converted or not a shim)
        m = TRIPLE.search(txt)
        if not m:
            print('SKIP (no entry-point triple): %s' % name)
            continue
        dist, _ver, group, ep_name = m.groups()
        shebang = txt.splitlines()[0]
        if not shebang.startswith('#!'):
            shebang = '#!/usr/bin/env python3'
        new = '''%s
# importlib.metadata console-script wrapper (replaces the setuptools
# EASY-INSTALL shim, which imported the setuptools working-set machinery and
# scanned all *.dist-info at startup -- minutes on the target FS). Resolves
# exactly the %r entry point in group %r from distribution %r.
import sys
from importlib.metadata import entry_points


def _load():
    eps = entry_points()
    # Python 3.9: entry_points() returns a dict keyed by group.
    for ep in eps.get(%r, []):
        if ep.name == %r:
            return ep.load()
    raise RuntimeError("entry point %r in group %r not found")


if __name__ == '__main__':
    sys.exit(_load()())
''' % (shebang, ep_name, group, dist, group, ep_name, ep_name, group)
        with open(path, 'w') as fh:
            fh.write(new)
        os.chmod(path, 0o755)
        converted += 1
    print('convert_console_scripts: converted %d shim(s) in %s'
          % (converted, bin_dir))
    return 0


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('usage: %s <bin_dir>' % sys.argv[0], file=sys.stderr)
        sys.exit(2)
    sys.exit(convert(sys.argv[1]))
