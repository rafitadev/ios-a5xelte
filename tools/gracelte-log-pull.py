#!/usr/bin/env python3
"""Galaxy Note7 (SM-N930F, gracelte) front end for herolte-log-pull.py.

The Exynos 8890 BOOT/USERDATA layout is shared with the S7, so this runs the
herolte tool unchanged (same by-name paths on 155a0000.ufs). Check
--partition-size against the Note7's own BOOT, not the S7 value.
"""
import runpy
import sys
from pathlib import Path

if __name__ == '__main__':
    sys.argv[0] = str(Path(__file__).with_name('herolte-log-pull.py'))

    runpy.run_path(sys.argv[0], run_name='__main__')
