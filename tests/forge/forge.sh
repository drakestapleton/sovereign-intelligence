#!/bin/sh
# tests/forge/forge.sh: the gate of tools/forge.om, the Omega forge's page generator.
#
#   sh tests/forge/forge.sh RUN
#
# RUN runs the built generator (a wrapper that execs it, under qemu for another architecture).
# Checks, each printing PASS or FAIL (a FAIL exits 1); last line RC=0:
#   - the fixture (tests/forge/forge/facts.tsv: a real Radicle repository's facts as
#     tools/forge-cycle.sh collected them, plus edge cases: \u escapes, surrogate pairs, a lone
#     surrogate, control bytes, HTML, a project without a name, leap days, the year 2100; and
#     ledger.tsv: rows inside, before and after the 14-day window and for an unknown RID) gives
#     exactly the tree in tests/forge/forge/expected
#   - the independent oracle (tests/forge/oracle.py, Python's JSON and HTML parsers) accepts that
#     tree, when python3 is installed (else NOT_RUN), and refuses a copy with a <script> planted in
#     a title and a copy with one pull count changed (negative controls)
#   - the same facts in reverse line order give the same tree (the output depends on what the
#     facts say, not on their order)
#   - every tests/forge/forge/bad/*.tsv is refused with exactly the stderr line in
#     bad/expected.txt, exit 1 and nothing written; f-* are bad FACTS, l-* bad LEDGERs
#   - wrong arguments: 3 arguments exit 2; an impossible DAY, a DAY too early for a 14-day window
#     and a missing OUT exit 1; a non-empty OUT is refused (files are created new)
#   - a changed byte in a copy of the expected tree is caught by the comparison (control)
set -eu
[ $# -eq 1 ] || { echo 'usage: sh tests/forge/forge.sh RUN' >&2; exit 2; }
case $1 in /*) run=$1 ;; *) run=$(pwd)/$1 ;; esac
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
cd "$R"
F=tests/forge/forge
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
gen() { # gen FACTS LEDGER DAY DIR: a fresh DIR, then the generator
  rm -rf "$4"; mkdir "$4"
  "$run" "$1" "$2" "$3" "$4"
}

gen $F/facts.tsv $F/ledger.tsv 2026-11-08 "$T/out" 2> "$T/err" || fail "forge refused the fixture: $(cat "$T/err")"
[ ! -s "$T/err" ] || fail "forge wrote to stderr: $(cat "$T/err")"
diff -r "$T/out" $F/expected > "$T/diff" || fail "forge's tree differs from $F/expected: $(head -5 "$T/diff")"
n=$(find "$T/out" -type f | wc -l | tr -d ' ')
pass "forge writes exactly $F/expected ($n files)"

if command -v python3 > /dev/null 2>&1; then
  o=$(python3 -I tests/forge/oracle.py $F/facts.tsv $F/ledger.tsv 2026-11-08 "$T/out") || fail "oracle: $o"
  cp -r "$T/out" "$T/bad1"
  f=$(grep -l '&lt;script&gt;' "$T"/bad1/*/issue-*.html | head -1)
  sed 's/&lt;script&gt;/<script>/' "$f" > "$T/x" && mv "$T/x" "$f"
  if python3 -I tests/forge/oracle.py $F/facts.tsv $F/ledger.tsv 2026-11-08 "$T/bad1" > /dev/null; then fail "oracle accepted a planted <script>"; fi
  cp -r "$T/out" "$T/bad2"
  f=$(find "$T/bad2" -name index.html -path '*/z*' | sort | head -1)
  sed '0,/<td class="n">[0-9]/s/<td class="n">\([0-9]\)/<td class="n">9\1/' "$f" > "$T/x" && mv "$T/x" "$f"
  cmp -s "$f" "$T/out/${f#"$T/bad2/"}" && fail "control setup: the count was not changed"
  if python3 -I tests/forge/oracle.py $F/facts.tsv $F/ledger.tsv 2026-11-08 "$T/bad2" > /dev/null; then fail "oracle accepted a changed pull count"; fi
  pass "independent oracle: $o; it refuses a planted <script> and a changed count"
else
  echo "NOTE NOT_RUN forge oracle: no python3"
fi

{ head -n 1 $F/facts.tsv; tail -n +2 $F/facts.tsv | awk '{ l[NR] = $0 } END { for (i = NR; i > 0; i--) print l[i] }'; } > "$T/rev.tsv"
cmp -s "$T/rev.tsv" $F/facts.tsv && fail "control setup: the reversed facts are the same file"
gen "$T/rev.tsv" $F/ledger.tsv 2026-11-08 "$T/rev" 2> "$T/err" || fail "forge refused the reversed facts: $(cat "$T/err")"
diff -r "$T/out" "$T/rev" > /dev/null || fail "the reversed facts give another tree"
pass "the facts in reverse order give the same tree"

nb=0
for b in $F/bad/*.tsv; do
  k=${b##*/}
  case $k in
    f-*) fa=$b le=$F/ledger.tsv ;;
    l-*) fa=$F/good-min.tsv le=$b ;;
    *) fail "$b is neither f-* nor l-*" ;;
  esac
  want=$(awk -F'\t' -v k="$k" '$1 == k { print $2 }' $F/bad/expected.txt)
  [ -n "$want" ] || fail "$F/bad/expected.txt has no line for $k"
  rc=0; gen "$fa" "$le" 2026-11-08 "$T/b" 2> "$T/err" || rc=$?
  [ $rc -eq 1 ] || fail "forge exited $rc, not 1, for $b"
  [ "$(cat "$T/err")" = "$want" ] || fail "forge refused $b with '$(cat "$T/err")', not '$want'"
  [ -z "$(ls -A "$T/b")" ] || fail "forge wrote into OUT for $b"
  nb=$((nb + 1))
done
[ "$nb" -eq "$(wc -l < $F/bad/expected.txt | tr -d ' ')" ] || fail "$F/bad/expected.txt names files that are not there"
pass "refuses all $nb malformed inputs, each with its own forge: line, writing nothing"

rc=0; "$run" $F/facts.tsv $F/ledger.tsv 2026-11-08 > /dev/null 2>&1 || rc=$?
[ $rc -eq 2 ] || fail "forge exited $rc, not 2, for three arguments"
for d in 2026-02-30 2026-13-01 1970-01-10 26-11-08 2026-11-08x; do
  rc=0; gen $F/facts.tsv $F/ledger.tsv "$d" "$T/b" 2> /dev/null || rc=$?
  [ $rc -eq 1 ] || fail "forge exited $rc, not 1, for DAY $d"
done
rc=0; "$run" $F/facts.tsv $F/ledger.tsv 2026-11-08 "$T/missing" 2> /dev/null || rc=$?
[ $rc -eq 1 ] || fail "forge exited $rc, not 1, for a missing OUT"
rc=0; "$run" $F/facts.tsv $F/ledger.tsv 2026-11-08 "$T/out" 2> /dev/null || rc=$?
[ $rc -eq 1 ] || fail "forge exited $rc, not 1, over an earlier tree"
pass "arguments: 3 exit 2; 5 bad DAYs, a missing OUT and an OUT with pages exit 1"

cp -r $F/expected "$T/exp"
f=$(find "$T/exp" -name 'patch-*.html' | sort | head -1)
sed 's/pass</pasS</' "$f" > "$T/x" && mv "$T/x" "$f"
if diff -r "$T/out" "$T/exp" > /dev/null; then fail "control: a changed expected tree still compared equal"; fi
pass "control: one changed byte in the expected tree is caught"
echo RC=0
