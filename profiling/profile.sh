#!/bin/bash
# Quick and dirty script to profile pwndbg using cProfile.
make test > /dev/null
git log --abbrev-commit --pretty=oneline HEAD^..HEAD
# To profile first run, remove -ex "context".
gdb ./test \
  -ex "source ../gdbinit.py" \
  -ex "b main" -ex "r" \
  -ex "context" \
  -ex "python import cProfile; cProfile.run('pwndbg.commands.context.context()', 'stats')" \
  -ex "quit"

python3 -c "
import pstats
p = pstats.Stats('stats')
p.strip_dirs().sort_stats('tottime').print_stats(20)
"

if command -v pyprof2calltree >/dev/null 2>&1 && command -v kcachegrind >/dev/null 2>&1; then
	pyprof2calltree -k -i stats
fi
