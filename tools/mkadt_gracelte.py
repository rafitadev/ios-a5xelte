#!/usr/bin/env python3
"""Build the Galaxy Note7 (SM-N930F, gracelte) ADT: mkadt_herolte.py --board gracelte."""
import runpy
import sys
from pathlib import Path

if __name__ == '__main__':
    target = Path(__file__).with_name('mkadt_herolte.py')
    sys.argv = [str(target)] + sys.argv[1:] + ['--board', 'gracelte']
    runpy.run_path(str(target), run_name='__main__')
