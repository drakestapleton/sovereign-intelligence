#!/bin/sh
# ledger-refresh.sh CHECKOUTS LEDGER: print the stack ledger (stack/LEDGER.tsv) for every
# git checkout directly under CHECKOUTS, using LEDGER, the binary built from tools/ledger.om.
#
#   sh tools/ledger-refresh.sh /path/to/checkouts ./ledger > stack/LEDGER.tsv
#
# The file list: each directory under CHECKOUTS that holds a .git, in LC_ALL=C order; in each,
# the tracked regular files only (git ls-files -s modes 100644 and 100755; symlinks 120000 and
# submodules 160000 are left out), one "REPO TAB REPO/PATH" line per file. The ledger runs from
# CHECKOUTS, so the paths are relative to it. A path holding a TAB or a newline cannot be one
# line of the list: it is skipped, and the number skipped is printed on stderr. The counting
# itself is done by the Omega program; this script only lists the files.
set -eu
[ $# -eq 2 ] || { echo "usage: ledger-refresh.sh CHECKOUTS LEDGER" >&2; exit 2; }
case $2 in /*) L=$2 ;; *) L=$(pwd)/$2 ;; esac
cd "$1"
list=$(mktemp)
skip=$(mktemp)
trap 'rm -f "$list" "$skip"' EXIT
: > "$skip"
for d in $(LC_ALL=C ls -A | LC_ALL=C sort); do
  [ -d "$d/.git" ] || continue
  # NUL-separated records; a newline inside a path becomes \001, then NUL becomes the newline.
  git -C "$d" ls-files -s -z | tr '\n\000' '\001\n' | LC_ALL=C awk -v r="$d" -v s="$skip" '
    {
      t = index($0, "\t"); if (t == 0) next
      mode = substr($0, 1, 6); path = substr($0, t + 1)
      if (mode != "100644" && mode != "100755") next
      if (index(path, "\t") || index(path, "\001")) { print "x" >> s; next }
      print r "\t" r "/" path
    }'
done > "$list"
n=$(wc -l < "$skip" | tr -d ' ')
echo "ledger-refresh: $(wc -l < "$list" | tr -d ' ') files listed, $n paths with a TAB or newline skipped" >&2
"$L" < "$list"
