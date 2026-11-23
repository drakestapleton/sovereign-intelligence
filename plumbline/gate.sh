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

# --- H3. The verifier: an independent Omega program that judges an output directory.
K=$P/hub/check
build1() { # build1 NAME TARGET UNIT: compile one unit for one target into $O/NAME-TARGET
  if [ "$2" = a64 ]; then a64 "$OMC_A64" < "$3" > "$O/$1-a64" || fail "$1 (a64) does not compile"
  else { printf 'target x86linux\n'; cat "$3"; } | x86 "$OMC_X86" > "$O/$1-x86" || fail "$1 (x86) does not compile"; fi
  chmod +x "$O/$1-$2"
}
build hubcheck $K/check.om
build hcrun $K/tests/run.om
build hcsubst $K/tests/subst.om
for t in $TARGETS; do
  # the driver starts hubcheck itself, so under emulation it needs the emulator's full path
  if [ $t = a64 ]; then q=$A64; else q=$X86; fi
  runner=""
  if [ -n "$q" ]; then runner=$(command -v "$q"); fi
  $t "$O/hubcheck-$t" "$O/site-$t" > "$O/hubcheck-$t.out" || fail "hubcheck ($t) rejects the generated site: $(cat "$O/hubcheck-$t.out")"
  $t "$O/hubcheck-$t" "$O/c-hostile-$t" > /dev/null || fail "hubcheck ($t) rejects the site built from the hostile description"
  mkdir -p "$O/hc-work-$t"
  $t "$O/hcrun-$t" "$O/hubcheck-$t" $K/tests "$O/hc-work-$t" $runner > "$O/hcrun-$t.out" \
    || fail "hubcheck ($t) fails its own case table: $(tail -3 "$O/hcrun-$t.out")"
  cp -r "$O/site-$t" "$O/site-planted-$t"
  printf "<script src='https://evil.example/x.js'></script>\n" >> "$O/site-planted-$t/stack/index.html"
  if $t "$O/hubcheck-$t" "$O/site-planted-$t" > "$O/hubcheck-planted-$t.out"; then fail "hubcheck ($t) passed a site with a planted outside script"; fi
  grep -q '^HUBCHECK FAIL R01 stack/index.html' "$O/hubcheck-planted-$t.out" || fail "hubcheck ($t) failed the planted site for another reason"
  for m in r09 r03; do
    if [ $m = r09 ]; then from='\nr09 n\n'; want=2; else from='\nscan 0 n 3\n'; want=6; fi
    $t "$O/hcsubst-$t" $K/check.om "$O/check-$m-$t.om" "$from" '\n' > /dev/null 2>&1 || fail "subst ($t) could not build the $m mutant of the verifier"
    build1 hubcheck-$m $t "$O/check-$m-$t.om"
    mkdir -p "$O/hc-work-$m-$t"
    if $t "$O/hcrun-$t" "$O/hubcheck-$m-$t" $K/tests "$O/hc-work-$m-$t" $runner > "$O/hcrun-$m-$t.out"; then fail "the verifier's case table passed the $m mutant ($t)"; fi
    grep -q "^HUBCHECK-TESTS FAIL cases=[0-9]* failed=$want\$" "$O/hcrun-$m-$t.out" || fail "the $m mutant ($t) did not fail exactly $want cases: $(tail -1 "$O/hcrun-$m-$t.out")"
  done
done
if [ "$TARGETS" = "a64 x86" ]; then
  cmp -s "$O/hubcheck-a64.out" "$O/hubcheck-x86.out" || fail "hubcheck: the two targets judged the site differently"
  cmp -s "$O/hcrun-a64.out" "$O/hcrun-x86.out" || fail "hubcheck: the two targets ran the case table differently"
fi
pass "hubcheck ($TARGETS): $(cat "$O/hubcheck-a64.out"); $(tail -1 "$O/hcrun-a64.out"); a planted outside script fails R01; the verifier with rule R09 removed fails 2 of its cases and with R03 removed fails 6"

# --- W1. The wire codec: ipo1, the INTERPLANE Omegese form.
V=$P/wire
build ipo $V/src/*.om
build wdrive $V/tests/drive.om
build wgen $V/tests/gen.om
build wsubst $V/tests/subst.om
wmut() { # wmut NAME TARGET UNIT...: compile a mutant of ipo from the given units for one target
  n=$1; t=$2; shift 2
  if [ "$t" = a64 ]; then cat "$@" | a64 "$OMC_A64" > "$O/$n-a64" || fail "$n (a64) does not compile"
  else { printf 'target x86linux\n'; cat "$@"; } | x86 "$OMC_X86" > "$O/$n-x86" || fail "$n (x86) does not compile"; fi
  chmod +x "$O/$n-$t"
}
for t in $TARGETS; do
  if [ $t = a64 ]; then q=$A64; else q=$X86; fi
  runner=""
  if [ -n "$q" ]; then runner=$(command -v "$q"); fi
  $t "$O/ipo-$t" selftest < $V/tests/vectors.jsonl > "$O/ipo-$t.self" || fail "ipo ($t) selftest failed: $(tail -1 "$O/ipo-$t.self")"
  cmp -s "$O/ipo-$t.self" $V/tests/expected.txt || fail "ipo ($t) selftest differs from tests/expected.txt"
  $t "$O/ipo-$t" selftest < $V/tests/edge.jsonl > "$O/ipo-$t.edge" || fail "ipo ($t) selftest failed on the edge values"
  cmp -s "$O/ipo-$t.edge" $V/tests/edge-expected.txt || fail "ipo ($t) edge selftest differs from tests/edge-expected.txt"
  $t "$O/ipo-$t" enc < $V/tests/example.json | cmp -s - $V/tests/example.ipo || fail "ipo ($t) enc of the example is not tests/example.ipo"
  $t "$O/ipo-$t" dec < $V/tests/example.ipo | cmp -s - $V/tests/example.json || fail "ipo ($t) dec of the example frame is not tests/example.json"
  $t "$O/ipo-$t" shapes > "$O/ipo-$t.shapes" || fail "ipo ($t) shapes failed"
  grep -q "$(sha "$O/ipo-$t.shapes")" $V/SPEC.md || fail "ipo ($t): the shape table's sha256 is not the one pinned in SPEC.md"
  $t "$O/wgen-$t" bigjson > "$O/22-input-over-1mib.json" || fail "gen ($t) bigjson failed"
  $t "$O/wgen-$t" bigipo > "$O/23-decodes-over-1mib.ipo" || fail "gen ($t) bigipo failed"
  $t "$O/wdrive-$t" bad $runner "$O/ipo-$t" -- $V/tests/bad/* "$O/22-input-over-1mib.json" "$O/23-decodes-over-1mib.ipo" > "$O/ipo-$t.bad" \
    || fail "ipo ($t): a refusal fixture was not refused as named: $(grep -v '^pass ' "$O/ipo-$t.bad" | head -3)"
  # mutant b: two keys of one shape swapped; the table's own check must refuse it
  $t "$O/wsubst-$t" '"peer\tid\tkind\n"' '"peer\tkind\tid\n"' < $V/src/20-shape.om > "$O/mutb-20-$t.om" || fail "subst ($t) could not make mutant b"
  wmut ipo-mutb $t $V/src/00-core.om $V/src/10-json.om "$O/mutb-20-$t.om" $V/src/30-frame.om $V/src/40-main.om
  if $t "$O/ipo-mutb-$t" selftest < $V/tests/vectors.jsonl > "$O/ipo-mutb-$t.self" 2> /dev/null; then fail "ipo mutant b ($t) passed selftest"; fi
  # mutant b2: that check removed too; it stays self-consistent, so only the recorded output catches it
  $t "$O/wsubst-$t" 'if ne skcmp sub k 1 k 0' 'if false' < "$O/mutb-20-$t.om" > "$O/mutb2-20-$t.om" || fail "subst ($t) could not make mutant b2"
  wmut ipo-mutb2 $t $V/src/00-core.om $V/src/10-json.om "$O/mutb2-20-$t.om" $V/src/30-frame.om $V/src/40-main.om
  $t "$O/ipo-mutb2-$t" selftest < $V/tests/vectors.jsonl > "$O/ipo-mutb2-$t.self" 2> /dev/null || true
  if cmp -s "$O/ipo-mutb2-$t.self" $V/tests/expected.txt; then fail "ipo mutant b2 ($t) reproduced tests/expected.txt"; fi
  # mutants c and c2: the canonical-form checks of dec removed; the refusal fixtures must catch both
  $t "$O/wsubst-$t" 'fail ENOTBARE p' 'p = add p 0' < $V/src/30-frame.om > "$O/mutc-30-$t.om" || fail "subst ($t) could not make mutant c"
  $t "$O/wsubst-$t" 'fail ENONCAN i' 'i = add i 0' < "$O/mutc-30-$t.om" > "$O/mutc2-30-$t.om" || fail "subst ($t) could not make mutant c2"
  for m in mutc mutc2; do
    wmut ipo-$m $t $V/src/00-core.om $V/src/10-json.om $V/src/20-shape.om "$O/$m-30-$t.om" $V/src/40-main.om
    if $t "$O/wdrive-$t" bad $runner "$O/ipo-$m-$t" -- $V/tests/bad/* "$O/22-input-over-1mib.json" "$O/23-decodes-over-1mib.ipo" > "$O/ipo-$m-$t.bad"; then fail "ipo mutant $m ($t) passed every refusal fixture"; fi
    grep -q '^BADRUN FAIL files=[0-9]* runs=[0-9]* failed=2$' "$O/ipo-$m-$t.bad" || fail "ipo mutant $m ($t) did not fail exactly 2 refusal fixtures: $(tail -1 "$O/ipo-$m-$t.bad")"
  done
done
if [ "$TARGETS" = "a64 x86" ]; then
  cmp -s "$O/ipo-a64.bad" "$O/ipo-x86.bad" || fail "ipo: the two targets refused the fixtures differently"
  cmp -s "$O/ipo-a64.shapes" "$O/ipo-x86.shapes" || fail "ipo: the two targets hold different shape tables"
fi
# mutated inputs, on the natively running target only (one process per input)
if [ -z "$A64" ]; then ft=a64; else ft=x86; fi
if [ "$ft" = x86 ] && [ "$TARGETS" = a64 ]; then
  skip "ipo fuzz: no natively running target"
else
  $ft "$O/wdrive-$ft" each "$O/ipo-$ft" enc < $V/tests/vectors.jsonl > "$O/seeds-v.ipo" 2> /dev/null || fail "ipo: drive each failed on the vectors"
  $ft "$O/wdrive-$ft" each "$O/ipo-$ft" enc < $V/tests/edge.jsonl > "$O/seeds-e.ipo" 2> /dev/null || fail "ipo: drive each failed on the edge values"
  cat "$O/seeds-v.ipo" "$O/seeds-e.ipo" > "$O/seeds.ipo"
  cat $V/tests/vectors.jsonl $V/tests/edge.jsonl > "$O/seeds.jsonl"
  fz=""
  for m in dec enc canon; do
    if [ $m = dec ]; then in="$O/seeds.ipo"; else in="$O/seeds.jsonl"; fi
    $ft "$O/wdrive-$ft" fuzz $m 100 "$O/ipo-$ft" < "$in" > "$O/fuzz-$m.out" 2> /dev/null || fail "ipo fuzz ($m): $(tail -1 "$O/fuzz-$m.out")"
    fz="$fz $(tail -1 "$O/fuzz-$m.out");"
  done
  pass "ipo fuzz ($ft): every mutated input was refused cleanly or stayed consistent:$fz"
fi
pass "ipo ($TARGETS): $(tail -1 $V/tests/expected.txt); the example is $(($(wc -c < $V/tests/example.json) - 1)) bytes of JSON and $(($(wc -c < $V/tests/example.ipo) - 1)) bytes as a frame, and decodes back to it; $(tail -1 "$O/ipo-a64.bad"); edge values pass; shape table matches its pin; mutants b, b2, c and c2 are each caught"

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

printf 'RC=0 not_run=%s\n' "$notrun"
