#!/bin/sh
# tests/forge/tally.sh: the gate of tools/tally.om, the forge's pull counter.
#
#   sh tests/forge/tally.sh RUN
#
# RUN is an executable that runs the tally built from tools/tally.om (for an AArch64 build on an
# x86-64 host, a wrapper that execs it under qemu-aarch64). Needs POSIX sh, awk, sort, cmp, head,
# tr and grep. Each check prints PASS or FAIL; the last line is RC=0 when every check passed, and
# the first FAIL stops the gate with exit 1.
#
# The expected ledger tests/forge/tally/expected.tsv was counted by hand from log.txt and
# ledger.tsv, and oracle.awk, an independent model written from tally.om's contract, must agree
# with it before tally itself is compared, so neither can drift alone.
set -eu
[ $# -eq 1 ] || { echo 'usage: sh tests/forge/tally.sh RUN' >&2; exit 2; }
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
case $1 in /*) run=$1 ;; *) run=$(pwd)/$1 ;; esac
cd "$R"
F=tests/forge/tally
fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
HDR=$(printf 'rid\tday\thttps\thosts\trad\tpeers')
oracle() { # oracle LEDGER < LOG: the oracle's ledger, sorted, with the header
  printf '%s\n' "$HDR"
  awk -f $F/oracle.awk "$1" - | grep -v '^#sum' | LC_ALL=C sort
}
osum() { # osum LEDGER < LOG: the oracle's summary line, as tally prints it
  awk -f $F/oracle.awk "$1" - | sed -n 's/^#sum /tally: /p'
}
# refuses NAME LEDGER WHY [ARGS...]: tally LEDGER OUT < /dev/null exits 1 with one "tally:" line
# holding WHY, and does not create OUT
refuses() {
  n=$1 l=$2 why=$3
  rc=0; "$run" "$l" $T/r.out < "${4:-/dev/null}" 2> $T/r.err || rc=$?
  [ $rc -eq 1 ] || fail "tally exited $rc, not 1, for $n"
  [ ! -e $T/r.out ] || fail "tally wrote OUT for $n"
  [ "$(wc -l < $T/r.err)" -eq 1 ] && grep -q '^tally: ' $T/r.err || fail "tally refused $n without one tally: line"
  grep -qF -- "$why" $T/r.err || fail "tally refused $n for another reason: $(cat $T/r.err)"
}

# 1. The fixture, against the hand count, the oracle and tally.
oracle $F/ledger.tsv < $F/log.txt > $T/oracle.tsv
cmp -s $T/oracle.tsv $F/expected.tsv || fail "oracle.awk disagrees with the hand-counted expected.tsv"
[ "$(osum $F/ledger.tsv < $F/log.txt)" = "$(cat $F/expected.err)" ] || fail "oracle.awk disagrees with expected.err"
pass "oracle.awk agrees with the hand count: expected.tsv and expected.err"
"$run" $F/ledger.tsv $T/out.tsv < $F/log.txt 2> $T/out.err || fail "tally refused the fixture: $(cat $T/out.err)"
cmp -s $T/out.tsv $F/expected.tsv || fail "tally's ledger differs from expected.tsv"
cmp -s $T/out.err $F/expected.err || fail "tally's summary differs from expected.err: $(cat $T/out.err)"
pass "tally prints expected.tsv and its summary line for the fixture ($(wc -l < $F/log.txt | tr -d ' ') log lines, $(($(wc -l < $F/ledger.tsv) - 1)) ledger rows)"

# 2. Negative control: one changed count in the expected ledger must be caught.
sed '3s/	5	4	4	3$/	5	4	4	2/' $F/expected.tsv > $T/wrong.tsv
! cmp -s $T/wrong.tsv $F/expected.tsv || fail "control: the wrong expected file is not different"
if cmp -s $T/out.tsv $T/wrong.tsv; then fail "control: a wrong expected ledger was accepted"; fi
pass "control: a ledger with one wrong count is caught"

# 3. Idempotent, and in place: the same log over its own output gives the same ledger, also when
# OUT names LEDGER.
"$run" $T/out.tsv $T/again.tsv < $F/log.txt 2> /dev/null || fail "tally refused its own output"
cmp -s $T/again.tsv $F/expected.tsv || fail "the same log over tally's own output changed the ledger"
cp $F/ledger.tsv $T/inplace.tsv
"$run" $T/inplace.tsv $T/inplace.tsv < $F/log.txt 2> /dev/null || fail "tally refused LEDGER = OUT"
cmp -s $T/inplace.tsv $F/expected.tsv || fail "tally with LEDGER = OUT differs from expected.tsv"
pass "idempotent: the same log again leaves the ledger unchanged, also written in place"

# 4. Nothing of a log line but counts reaches OUT: no host and no node id.
awk '{ print $1 }' $F/log.txt | grep '[.:]' | sort -u > $T/hosts
grep -o 'Peer z[1-9A-HJ-NP-Za-km-z]*' $F/log.txt | cut -c6- | sort -u > $T/nids
[ -s $T/hosts ] && [ -s $T/nids ] || fail "found no hosts or node ids in log.txt"
if grep -qF -f $T/hosts $T/out.tsv; then fail "OUT holds a host"; fi
if grep -qF -f $T/nids $T/out.tsv; then fail "OUT holds a node id"; fi
pass "OUT holds none of the $(wc -l < $T/hosts | tr -d ' ') hosts and $(wc -l < $T/nids | tr -d ' ') node ids of the log"

# 5. Edges of the stream: no input; a last line without its newline; a line over the 4 MiB read
# window, which is ignored, then a pull that still counts.
printf '%s\n' "$HDR" > $T/h.tsv
"$run" $T/h.tsv $T/e.tsv < /dev/null 2> $T/e.err || fail "tally refused a header-only ledger and no input"
cmp -s $T/e.tsv $T/h.tsv || fail "no input over a header-only ledger did not give the header"
[ "$(cat $T/e.err)" = 'tally: lines 0 https 0 rad 0 ignored 0 days 0 rows 0' ] || fail "summary for no input: $(cat $T/e.err)"
l=$(sed -n 1p $F/log.txt)
printf '%s' "$l" > $T/nonl.log
"$run" $T/h.tsv $T/n.tsv < $T/nonl.log 2> $T/n.err || fail "tally refused a log without its last newline"
oracle $T/h.tsv < $T/nonl.log > $T/n.exp
cmp -s $T/n.tsv $T/n.exp || fail "a last line without its newline was not counted"
{ printf '%s' "$(printf '%s' "$l" | cut -c1-150)"; head -c 5000000 /dev/zero | tr '\0' 'a'; printf '\n%s\n' "$l"; } > $T/long.log
"$run" $T/h.tsv $T/g.tsv < $T/long.log 2> $T/g.err || fail "tally refused a 5 MB line"
oracle $T/h.tsv < $T/long.log > $T/g.exp
cmp -s $T/g.tsv $T/g.exp || fail "a 5 MB line was not ignored, or the pull after it not counted"
grep -q '^tally: lines 2 https 1 rad 0 ignored 1 ' $T/g.err || fail "summary after a 5 MB line: $(cat $T/g.err)"
pass "stream edges: no input, a last line without its newline, a 5 MB line across read windows"

# 6. Every malformed ledger is refused for its own reason.
nb=0
for b in $F/bad/*.tsv; do
  refuses "$b" "$b" "$(cat "${b%.tsv}.why")"
  nb=$((nb + 1))
done
pass "refuses all $nb malformed ledgers in $F/bad, each for its reason, with one tally: line and no OUT"

# 7. Bounds, generated: 262145 rows; a ledger over 16 MiB; 4097 (rid, day) pairs in the logs;
# 262145 distinct hosts; an OUT over 262144 rows.
# base58 strings of 20 characters in the order of i: decimal digits 0..9 written as 1..9 and A
awk -v h="$HDR" 'BEGIN { print h; for (i = 0; i < 262145; i++) { d = sprintf("%020d", i); s = ""; for (j = 1; j <= 20; j++) s = s substr("123456789A", substr(d, j, 1) + 1, 1); printf "rad:z%s\t2026-01-01\t0\t0\t0\t0\n", s } }' > $T/big.tsv
tail -n +2 $T/big.tsv | LC_ALL=C sort -c -u || fail "generator: the rows of big.tsv are not strictly ascending"
refuses "a ledger of 262145 rows" $T/big.tsv 'line 262146: more than 262144 rows'
head -n 262145 $T/big.tsv > $T/max.tsv
"$run" $T/max.tsv $T/max.out < /dev/null 2> /dev/null || fail "tally refused a ledger of 262144 rows"
cmp -s $T/max.tsv $T/max.out || fail "a ledger of 262144 rows did not pass through unchanged"
printf '2026-11-08T15:02:56.075Z INFO  wire     Peer z6MktVgWEu2hu3FpE9PfC5JCaDvLX3anQEBcznYk4u2thziQ fetched rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj from us successfully\n' > $T/one.log
refuses "an OUT of 262145 rows" $T/max.tsv 'OUT over 262144 rows' $T/one.log
{ printf '%s\n' "$HDR"; head -c 16777216 /dev/zero | tr '\0' 'a'; } > $T/huge.tsv
refuses "a ledger over 16 MiB" $T/huge.tsv 'file over 16 MiB'
awk 'BEGIN { for (i = 0; i < 4097; i++) { d = sprintf("%020d", i); s = ""; for (j = 1; j <= 20; j++) s = s substr("123456789A", substr(d, j, 1) + 1, 1); printf "2026-11-08T15:02:56Z INFO  wire     Peer z6MktVgWEu2hu3FpE9PfC5JCaDvLX3anQEBcznYk4u2thziQ fetched rad:z%s from us successfully\n", s } }' > $T/cells.log
refuses "4097 (rid, day) pairs" $T/h.tsv 'more than 4096 (rid, day) pairs' $T/cells.log
head -n 4096 $T/cells.log > $T/cells4096.log
"$run" $T/h.tsv $T/c.out < $T/cells4096.log 2> /dev/null || fail "tally refused 4096 (rid, day) pairs"
[ "$(wc -l < $T/c.out)" -eq 4097 ] || fail "4096 (rid, day) pairs did not give 4096 rows"
oracle $T/h.tsv < $T/cells4096.log > $T/c.exp
cmp -s $T/c.out $T/c.exp || fail "4096 (rid, day) pairs: tally differs from the oracle"
awk 'BEGIN { for (i = 0; i < 262145; i++) printf "h%d - - [08/Nov/2026:12:00:00 +0000] \"GET /rad/z2JJz4RDfZZxKGBLn6UhmW5p9VJQj.git/info/refs?service=git-upload-pack HTTP/1.1\" 200 1 \"-\" \"git\"\n", i }' > $T/keys.log
refuses "262145 distinct hosts" $T/h.tsv 'more than 262144 distinct hosts and peers' $T/keys.log
head -n 262144 $T/keys.log > $T/keys262144.log
"$run" $T/h.tsv $T/k.out < $T/keys262144.log 2> /dev/null || fail "tally refused 262144 distinct hosts"
[ "$(sed -n 2p $T/k.out)" = "$(printf 'rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj\t2026-11-08\t262144\t262144\t0\t0')" ] || fail "262144 distinct hosts: $(sed -n 2p $T/k.out)"
pass "bounds: 262144 rows, 4096 (rid, day) pairs and 262144 distinct hosts pass; one more of each, a 16 MiB ledger and an OUT of 262145 rows are refused"

# 8. Arguments and files.
for a in '' 'x' 'x y z'; do
  rc=0; "$run" $a < /dev/null > $T/u.out 2> $T/u.err || rc=$?
  [ $rc -eq 2 ] || fail "tally exited $rc, not 2, for the arguments '$a'"
  [ "$(cat $T/u.err)" = 'usage: tally LEDGER OUT < LOGS' ] || fail "usage line for '$a': $(cat $T/u.err)"
done
[ ! -e x ] && [ ! -e y ] && [ ! -e z ] || fail "a usage refusal created a file"
refuses "a missing LEDGER" $T/no-such-ledger 'cannot open '
rc=0; "$run" $F/ledger.tsv $T/no-such-dir/out.tsv < $F/log.txt 2> $T/w.err || rc=$?
[ $rc -eq 1 ] && [ "$(wc -l < $T/w.err)" -eq 1 ] && grep -q '^tally: cannot open ' $T/w.err || fail "an unwritable OUT: rc $rc, $(cat $T/w.err)"
pass "arguments: 0, 1 and 3 give the usage line and exit 2; a missing LEDGER and an unwritable OUT are refused"
echo RC=0
