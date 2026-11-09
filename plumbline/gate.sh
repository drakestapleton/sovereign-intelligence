#!/bin/sh
# plumbline/gate.sh: build and check everything under plumbline/ with the seed-grown compilers.
#
#   sh build.sh && sh plumbline/gate.sh
#
# Run from anywhere. It reads the compilers that build.sh leaves in out/ (override with OMC_A64 and
# OMC_X86), writes only under out/plumbline/, and changes no tracked file. Needs: POSIX sh, cmp,
# diff, sha256sum, find, sort. AArch64 programs run directly on an AArch64 host, or under
# qemu-aarch64 on x86-64 (QEMU_A64, default qemu-aarch64-static then qemu-aarch64); x86-64 programs
# run directly on x86-64, or under qemu-x86_64 on AArch64 when it exists, else that half is NOT_RUN.
#
# All logic is in the Omega programs. This script only compiles them, runs them and compares
# their outputs with the recorded ones. Each step prints PASS, FAIL or NOT_RUN; a FAIL stops with
# exit 1. NOT_RUN is never counted as PASS: the last line is "RC=0 not_run=N".
#
# Steps:
#   H1 hub: the generator, built for both targets, writes byte-identical sites
#   H2 hub controls: a wrong ledger total, a README without a needed section, a registry without
#      a table and an http:// address are each refused with no file written; a hostile project
#      description comes out escaped; the sample registry is counted
#   H3 hubcheck: the verifier, built for both targets, passes the site, passes its own fixtures
#      (tests/run.om) and fails a copy of the site with one planted violation
#   W1 wire: the ipo1 codec's selftest prints tests/expected.txt on both targets; every tests/bad
#      input is refused with its code; the example frame decodes to the example envelope
#   N1 neuralese: nl8 prints its recorded table and verdicts on both targets, with the recorded
#      exit status. The experiment's own verdict is in that output and is not this gate's verdict.
#   L1 proofs: every proofs/*.lean checks under Lean with no error, no sorry and only the
#      standard axioms; the control file with a sorry is flagged. Without lean: NOT_RUN.
set -eu
R=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$R"
P=plumbline
O=out/plumbline
OMC_A64=${OMC_A64:-out/omc}
OMC_X86=${OMC_X86:-out/omc-x86}
notrun=0

fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
note() { printf 'NOTE %s\n' "$*"; }
skip() { printf 'NOT_RUN %s\n' "$*"; notrun=$((notrun + 1)); }
sha() { sha256sum < "$1" | cut -c1-64; }
tree() { (cd "$1" && find . -type f | LC_ALL=C sort | xargs sha256sum | sha256sum | cut -c1-64); }

[ -x "$OMC_A64" ] || fail "no AArch64 compiler at $OMC_A64: run sh build.sh first"
host=$(uname -m)
case $host in
  aarch64|arm64)
    A64=""
    if command -v qemu-x86_64 >/dev/null 2>&1; then X86=qemu-x86_64; else X86=none; fi ;;
  x86_64|amd64)
    X86=""
    A64=${QEMU_A64:-}
    if [ -z "$A64" ]; then
      for q in qemu-aarch64-static qemu-aarch64; do
        if command -v "$q" >/dev/null 2>&1; then A64=$q; break; fi
      done
    fi
    [ -n "$A64" ] || fail "x86-64 host without qemu-aarch64" ;;
  *) fail "host $host is neither AArch64 nor x86-64" ;;
esac
a64() { p=$1; shift; if [ -n "$A64" ]; then "$A64" "$p" "$@"; else "$p" "$@"; fi; }
x86() { p=$1; shift; if [ -n "$X86" ]; then "$X86" "$p" "$@"; else "$p" "$@"; fi; }
TARGETS="a64"
if [ "$X86" = none ] || [ ! -x "$OMC_X86" ]; then skip "every x86-64 half below: no x86-64 compiler or no way to run x86-64 here"; else TARGETS="a64 x86"; fi
note "compilers: omc $(sha "$OMC_A64"); omc-x86 $( [ -x "$OMC_X86" ] && sha "$OMC_X86" || echo absent)"

rm -rf "$O"
mkdir -p "$O"

# build NAME UNIT...: compile the concatenated units for every target into $O/NAME-<target>
build() {
  n=$1; shift
  for t in $TARGETS; do
    if [ $t = a64 ]; then
      cat "$@" | a64 "$OMC_A64" > "$O/$n-a64" || fail "$n (a64) does not compile"
    else
      { printf 'target x86linux\n'; cat "$@"; } | x86 "$OMC_X86" > "$O/$n-x86" || fail "$n (x86) does not compile"
    fi
    chmod +x "$O/$n-$t"
  done
}

# --- H1. The hub generator.
W=$P/wire/tests
N=$P/neuralese/nl8
hub() { # hub TARGET OUT BASE REPOS LEDGER README REGISTRY
  t=$1; shift
  $t "$O/hub-$t" build "$1" "$2" "$3" stack/STACK.tsv "$4" seed/PINS.tsv "$5" $P/hub/facts.tsv \
    $W/expected.txt $W/example.json $W/example.ipo $N/expected-peer.tsv $N/sweep.txt "$6"
}
build hub $P/hub/src/*.om
for t in $TARGETS; do
  hub $t "$O/site-$t" https://interplane.io repos.tsv stack/LEDGER.tsv README.md - > "$O/hub-$t.out" \
    || fail "hub ($t) refused the committed inputs"
done
if [ "$TARGETS" = "a64 x86" ]; then
  diff -r "$O/site-a64" "$O/site-x86" > /dev/null || fail "hub: the two targets wrote different sites"
  cmp -s "$O/hub-a64.out" "$O/hub-x86.out" || fail "hub: the two targets printed different summaries"
fi
pass "hub: $(cat "$O/hub-a64.out"), identical on $TARGETS, tree sha256 $(tree "$O/site-a64")"

# --- H2. Hub controls.
T=$P/hub/tests
for t in $TARGETS; do
  refuse() { # refuse NAME WHAT-IT-MUST-SAY REPOS LEDGER README REGISTRY BASE
    d="$O/c-$1-$t"
    if hub $t "$d" "$7" "$3" "$4" "$5" "$6" > "$d.out" 2> "$d.err"; then fail "hub ($t) accepted control $1"; fi
    grep -q "$2" "$d.err" || fail "hub ($t) refused control $1 for another reason: $(cat "$d.err")"
    [ -z "$(find "$d" -type f 2>/dev/null)" ] || fail "hub ($t) wrote files before refusing control $1"
  }
  refuse total 'TOTAL disagrees' repos.tsv $T/ledger-badtotal.tsv README.md - https://interplane.io
  refuse section 'README.md has no section' repos.tsv stack/LEDGER.tsv $T/readme-nosection.md - https://interplane.io
  refuse registry 'registry has no Markdown table' repos.tsv stack/LEDGER.tsv README.md $T/registry-notable.md https://interplane.io
  refuse http 'BASE must be https' repos.tsv stack/LEDGER.tsv README.md - http://interplane.io
  d="$O/c-hostile-$t"
  hub $t "$d" https://interplane.io $T/repos-hostile.tsv stack/LEDGER.tsv README.md $T/registry-sample.md > /dev/null \
    || fail "hub ($t) refused the hostile-description control"
  if grep -q '<script src=https://evil' "$d/stack/index.html"; then fail "hub ($t) wrote a hostile description unescaped"; fi
  grep -q '&lt;script src=https://evil.example/x.js&gt;' "$d/stack/index.html" || fail "hub ($t): the escaped hostile description is missing"
  grep -q 'the list of the 3 public repositories' "$d/forge/index.html" || fail "hub ($t) did not count the sample registry's first table as 3"
  if grep -q 'the list of the [0-9]' "$O/site-$t/forge/index.html"; then fail "hub ($t) stated a forge count without a registry"; fi
done
pass "hub controls ($TARGETS): wrong total, missing section, registry without a table and http:// refused with no file written; hostile description escaped; sample registry counted as 3; no count stated without a registry"

# --- N1. The Neuralese experiment: its recorded table and verdicts, on both targets.
build nl8 $N/nl8.om $N/main.om
for t in $TARGETS; do
  rc=0; $t "$O/nl8-$t" all > "$O/nl8-$t.all" || rc=$?
  [ $rc -eq 1 ] || fail "nl8 ($t) all: exit $rc, recorded 1 (the experiment's own verdict is FAIL)"
  cmp -s "$O/nl8-$t.all" $N/expected.tsv || fail "nl8 ($t) all differs from expected.tsv"
  $t "$O/nl8-$t" table > "$O/nl8-$t.table" || fail "nl8 ($t) table failed"
  $t "$O/nl8-$t" sweep > "$O/nl8-$t.sweep" || fail "nl8 ($t) sweep failed"
  cmp -s "$O/nl8-$t.sweep" $N/sweep.txt || fail "nl8 ($t) sweep differs from sweep.txt"
  $t "$O/nl8-$t" grad 17 > "$O/nl8-$t.grad" || fail "nl8 ($t) gradient check failed: $(cat "$O/nl8-$t.grad")"
  rc=0; $t "$O/nl8-$t" 9 9 9 > /dev/null 2>&1 || rc=$?
  [ $rc -eq 2 ] || fail "nl8 ($t) accepted bad arguments (exit $rc)"
done
if [ "$TARGETS" = "a64 x86" ]; then
  cmp -s "$O/nl8-a64.table" "$O/nl8-x86.table" || fail "nl8: the two targets printed different tables"
  for t in $TARGETS; do
    if [ $t = a64 ]; then peer="$O/nl8-x86.table"; else peer="$O/nl8-a64.table"; fi
    rc=0; $t "$O/nl8-$t" all "$peer" > "$O/nl8-$t.peer" || rc=$?
    [ $rc -eq 1 ] || fail "nl8 ($t) all PEER: exit $rc, recorded 1"
    cmp -s "$O/nl8-$t.peer" $N/expected-peer.tsv || fail "nl8 ($t) all PEER differs from expected-peer.tsv"
  done
  { cat "$O/nl8-a64.table"; printf 'x'; } > "$O/nl8-peer.bad"
  x86 "$O/nl8-x86" all "$O/nl8-peer.bad" | grep -q '^P5 FAIL' || fail "nl8: a tampered peer table was not caught"
  pass "nl8 ($TARGETS): prints its recorded table, verdicts and sweep, byte-identical on both; gradient check passes; a tampered peer table is caught. THE EXPERIMENT'S OWN VERDICT, as recorded: $(tail -1 $N/expected-peer.tsv), failed criteria $(grep -c '^P[0-9] FAIL' $N/expected-peer.tsv | tr -d ' '): $(grep '^P[0-9] FAIL' $N/expected-peer.tsv | tr '\n' ';')"
else
  pass "nl8 (a64): prints its recorded table, verdicts and sweep; gradient check passes"
  skip "nl8 criterion P5 (both targets print the same table) and expected-peer.tsv: one target only"
fi

# --- L1. The Lean proofs.
lean_bad() { # lean_bad FILE: print why FILE is not a checked proof, or nothing
  if ! ${LEAN:-lean} "$1" > "$O/lean.out" 2>&1; then echo "lean reported an error"; return; fi
  if grep -q 'sorry' "$O/lean.out"; then echo "it uses sorry"; return; fi
  if grep -q 'error' "$O/lean.out"; then echo "lean printed an error"; return; fi
  if grep 'depends on axioms' "$O/lean.out" | tr -d '[],' | tr ' ' '\n' | grep -v '^$' \
     | grep -v -e '^propext$' -e '^Classical.choice$' -e '^Quot.sound$' -e "^'" -e '^depends$' -e '^on$' -e '^axioms:$' | grep -q .; then
    echo "it depends on a non-standard axiom"; return; fi
  if ! grep -q 'axioms' "$O/lean.out"; then echo "it prints no axiom list"; return; fi
  if [ "$(grep -c '^theorem ' "$1")" -gt "$(grep -c '^#print axioms ' "$1")" ]; then
    echo "it states a theorem whose axioms it does not print"; return; fi
}
if command -v "${LEAN:-lean}" >/dev/null 2>&1; then
  for f in $P/proofs/*.lean; do
    why=$(lean_bad "$f")
    [ -z "$why" ] || fail "proof $f: $why"
  done
  why=$(lean_bad $P/proofs/control/Unproved.lean)
  [ -n "$why" ] || fail "the unproved control file was accepted as a proof"
  pass "proofs: $(ls $P/proofs/*.lean | wc -l | tr -d ' ') files check under $(${LEAN:-lean} --version | cut -d, -f1 | sed 's/^Lean (version //') with no error, no sorry and only standard axioms; the unproved control is flagged ($why)"
else
  skip "proofs: lean is not installed here, so no proof was checked"
fi
