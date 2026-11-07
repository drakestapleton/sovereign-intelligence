#!/bin/sh
# build.sh: grow the Omega compiler from 408 hand-written bytes, then build and check everything here.
#
#   sh build.sh
#
# Run from anywhere; it works in the repository that holds it and writes only to its out/ directory.
# Needs: POSIX sh, cmp, sha256sum. The seed chain is AArch64 machine code: on an AArch64 Linux host
# it runs directly; on an x86-64 Linux host it runs under qemu-aarch64 (user mode; set QEMU_A64 to its
# path, default qemu-aarch64-static, then qemu-aarch64). The native x86-64 compiler, omc-x86, runs
# directly on x86-64; on AArch64 its steps run under qemu-x86_64 when it exists, or are NOT_RUN.
#
# The one outside tool is seed/rung0/load0.sh, which turns seed0.hex into seed0.bin with the shell's
# own printf. No C compiler, assembler or linker writes a byte of anything this builds.
#
# Steps, each printing PASS or FAIL (a FAIL stops the build with exit 1):
#   1. seed0, hex1, asm2, om4 from their hand-written sources, each checked against seed/PINS.tsv;
#      seed0 and hex1 must rebuild themselves
#   2. omc from omc.om: born from om4, then rebuilt by itself twice; all three equal the pin
#   3. omc-x86, the native x86-64 compiler, from "target x86linux" + omc.om; it must rebuild itself,
#      and compiling omc.om with it must give exactly the AArch64 omc (diverse double compilation)
#   4. controls: a one-word edit of seed0.hex and a one-line edit of omc.om (a global grown by 32 KiB) must change what is
#      born, so the pins catch them
#   5. compiler/si.om, built for both targets, must regenerate the committed README.md and repos.tsv
#      byte for byte, and both builds must write the same si.sh
#   6. tools/ledger.om, built for both targets, must print tests/ledger/expected.tsv
#   7. the Omega harness examples, on both targets (tests/examples.sh)
#   8. the examples of compiler words beyond the imported harness (tests/omc), on both targets
#   9. control: omc.om with count's slice check deleted must build a compiler that fails both trap-3
#      examples of count on every target that runs, while count_word still passes
# Last line: RC=0 when every step passed.
set -eu
R=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$R"
O=out
rm -rf "$O"
mkdir -p "$O/seed" "$O/tmp"

fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
note() { printf 'NOTE %s\n' "$*"; }
sha() { sha256sum < "$1" | cut -c1-64; }
pin() { # pin NAME FILE: FILE must have the size and sha256 PINS.tsv gives NAME
  want=$(awk -F'\t' -v n="$1" '$1 == n { print $3 }' seed/PINS.tsv)
  [ -n "$want" ] || fail "no pin for $1"
  got=$(sha "$2")
  [ "$got" = "$want" ] || fail "$1: sha256 $got, pin $want"
}

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
    [ -n "$A64" ] || fail "x86-64 host without qemu-aarch64: install qemu-user (Debian/Ubuntu: apt-get install qemu-user-static) or set QEMU_A64" ;;
  *) fail "host $host: the seed chain runs on AArch64 Linux, or on x86-64 Linux under qemu-aarch64" ;;
esac
note "host $host; AArch64 programs run ${A64:-directly}; x86-64 programs run ${X86:-directly}"

a64() { # a64 PROG ARGS...: run an AArch64 program
  p=$1; shift
  if [ -n "$A64" ]; then "$A64" "$p" "$@"; else "$p" "$@"; fi
}
x86() { # x86 PROG ARGS...: run an x86-64 program
  p=$1; shift
  if [ -n "$X86" ]; then "$X86" "$p" "$@"; else "$p" "$@"; fi
}
mk() { chmod +x "$1"; }
S=seed
B=$O/seed

# 1. The rungs.
sh $S/rung0/load0.sh $S/rung0/seed0.hex $B/seed0.bin; mk $B/seed0.bin
pin seed0.bin $B/seed0.bin
a64 $B/seed0.bin < $S/rung0/seed0.hex > $B/seed0.self
cmp -s $B/seed0.bin $B/seed0.self || fail "seed0 does not rebuild itself"
pass "seed0 $(wc -c < $B/seed0.bin | tr -d ' ') bytes from shell printf; rebuilds itself"
a64 $B/seed0.bin < $S/rung1/hex1.hex > $B/hex1.bin; mk $B/hex1.bin
pin hex1.bin $B/hex1.bin
a64 $B/hex1.bin < $S/rung1/hex1.hex > $B/hex1.self
cmp -s $B/hex1.bin $B/hex1.self || fail "hex1 does not rebuild itself"
pass "hex1 $(wc -c < $B/hex1.bin | tr -d ' ') bytes, born from seed0; rebuilds itself"
a64 $B/hex1.bin < $S/rung2/asm2.hex1 > $B/asm2.bin; mk $B/asm2.bin
pin asm2.bin $B/asm2.bin
pass "asm2 $(wc -c < $B/asm2.bin | tr -d ' ') bytes, born from hex1"
cat $S/rung2/table.s2 $S/rung3/table3.s2 $S/rung4/table4.s2 $S/rung4/om4.s | a64 $B/asm2.bin > $B/om4.bin; mk $B/om4.bin
pin om4.bin $B/om4.bin
pass "om4 $(wc -c < $B/om4.bin | tr -d ' ') bytes, born from asm2"

# 2. omc, from om4 and then from itself.
a64 $B/om4.bin < $S/omc/omc.om > $B/stage1; mk $B/stage1
a64 $B/stage1 < $S/omc/omc.om > $B/stage2; mk $B/stage2
a64 $B/stage2 < $S/omc/omc.om > $B/stage3; mk $B/stage3
cmp -s $B/stage1 $B/stage2 || fail "omc built by om4 differs from omc built by omc"
cmp -s $B/stage2 $B/stage3 || fail "omc is not a fixpoint"
pin omc $B/stage3
cp $B/stage3 $O/omc
pass "omc $(wc -c < $O/omc | tr -d ' ') bytes: om4-built = omc-built = rebuilt, sha256 $(sha $O/omc)"

# 3. omc-x86, the native x86-64 compiler, and diverse double compilation.
{ printf 'target x86linux\n'; cat $S/omc/omc.om; } > $B/omc-x86.om
a64 $O/omc < $B/omc-x86.om > $B/omc-x86; mk $B/omc-x86
pin omc-x86 $B/omc-x86
cp $B/omc-x86 $O/omc-x86
pass "omc-x86 $(wc -c < $O/omc-x86 | tr -d ' ') bytes, built by omc, sha256 $(sha $O/omc-x86)"
if [ "$X86" = none ]; then
  note "NOT_RUN omc-x86 self-rebuild and diverse double compilation: no x86-64 host or qemu-x86_64"
else
  x86 $O/omc-x86 < $B/omc-x86.om > $B/omc-x86.self
  cmp -s $O/omc-x86 $B/omc-x86.self || fail "omc-x86 does not rebuild itself"
  pass "omc-x86 rebuilds itself byte for byte"
  x86 $O/omc-x86 < $S/omc/omc.om > $B/omc.ddc
  cmp -s $O/omc $B/omc.ddc || fail "diverse double compilation: omc-x86 does not reproduce omc"
  pass "diverse double compilation: omc-x86 compiles omc.om to the AArch64 omc, byte for byte"
fi

# 4. Controls: the pins must catch a changed seed and a changed compiler.
awk 'done == 0 && /^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]/ { c = substr($0, 1, 1); r = (c == "0") ? "1" : "0"; $0 = r substr($0, 2); done = 1 } { print }' \
  $S/rung0/seed0.hex > $B/seed0.mut.hex
cmp -s $S/rung0/seed0.hex $B/seed0.mut.hex && fail "control: the seed0.hex edit did not change it"
sh $S/rung0/load0.sh $B/seed0.mut.hex $B/seed0.mut.bin
[ "$(sha $B/seed0.mut.bin)" != "$(sha $B/seed0.bin)" ] || fail "control: an edited seed0.hex gave the pinned seed0"
pass "control: one edited word of seed0.hex changes seed0.bin, so its pin catches it"
awk 'done == 0 && $0 == "global line ulong 1" { $0 = "global line ulong 4096"; done = 1 } { print }' $S/omc/omc.om > $B/omc.mut.om
cmp -s $S/omc/omc.om $B/omc.mut.om && fail "control: the omc.om edit did not change it"
a64 $O/omc < $B/omc.mut.om > $B/omc.mut
[ "$(sha $B/omc.mut)" != "$(sha $O/omc)" ] || fail "control: an edited omc.om gave the pinned omc"
pass "control: a one-line edit of omc.om changes the compiler it builds, so its pin catches it"

# 5. The front door: compiler/si.om must regenerate what is committed.
siin="compiler/inventory.tsv compiler/order.tsv compiler/vetted.md"
for t in a64 x86; do
  if [ $t = x86 ] && [ "$X86" = none ]; then note "NOT_RUN si on x86-64"; continue; fi
  w=$O/si-$t
  mkdir -p $w/compiler
  cp $siin $w/compiler/
  cp README.md repos.tsv $w/
  if [ $t = a64 ]; then
    a64 $O/omc < compiler/si.om > $O/si-a64.bin
  else
    { printf 'target x86linux\n'; cat compiler/si.om; } | x86 $O/omc-x86 > $O/si-x86.bin
  fi
  mk $O/si-$t.bin
  (cd $w && $t ../si-$t.bin compiler/inventory.tsv compiler/order.tsv compiler/vetted.md README.md repos.tsv si.sh) \
    || fail "si ($t) refused the committed inputs"
  cmp -s $w/README.md README.md || fail "si ($t): README.md is not what compiler/si.om makes from the committed inputs"
  cmp -s $w/repos.tsv repos.tsv || fail "si ($t): repos.tsv is not what compiler/si.om makes from the committed inputs"
  pass "si ($t) regenerates README.md and repos.tsv byte for byte"
done
if [ -f $O/si-x86/si.sh ]; then
  cmp -s $O/si-a64/si.sh $O/si-x86/si.sh || fail "si: the AArch64 and x86-64 builds write different si.sh"
  pass "si: AArch64 and x86-64 builds write the same si.sh"
fi
cp $O/si-a64/si.sh $O/si.sh
note "si.sh sha256 $(sha $O/si.sh); compare: curl -fsSL https://www.aienos.com/si | sha256sum"

# 6. The stack ledger tool.
for t in a64 x86; do
  if [ $t = x86 ] && [ "$X86" = none ]; then note "NOT_RUN ledger on x86-64"; continue; fi
  if [ $t = a64 ]; then
    a64 $O/omc < tools/ledger.om > $O/ledger-a64
  else
    { printf 'target x86linux\n'; cat tools/ledger.om; } | x86 $O/omc-x86 > $O/ledger-x86
  fi
  mk $O/ledger-$t
  $t $O/ledger-$t < tests/ledger/input.tsv > $O/ledger-$t.out || fail "ledger ($t) refused tests/ledger/input.tsv"
  cmp -s $O/ledger-$t.out tests/ledger/expected.tsv || fail "ledger ($t) output differs from tests/ledger/expected.tsv"
  pass "ledger ($t) prints tests/ledger/expected.tsv"
done

# 7. The Omega harness examples, on both targets.
sh tests/examples.sh "$O/omc" "$O/omc-x86" ${A64:+"$A64"} || fail "harness examples"
pass "harness examples"

# 8. The examples of words this repository adds to the compiler (seed/PROVENANCE.md), on both targets.
EXAMPLES_ROOT=tests/omc sh tests/examples.sh "$O/omc" "$O/omc-x86" ${A64:+"$A64"} || fail "tests/omc examples"
pass "tests/omc examples"

# 9. Control: count without its slice check must be caught by the trap-3 examples.
awk '/^fn / { f = ($2 == "cnt_word") } f && $0 == "vs_chk e ro rn" { f = 0; next } { print }' $S/omc/omc.om > $B/omc.nochk.om
[ "$(wc -l < $B/omc.nochk.om)" -eq "$(($(wc -l < $S/omc/omc.om) - 1))" ] || fail "control: cnt_word's vs_chk line was not deleted exactly once"
a64 $O/omc < $B/omc.nochk.om > $B/omc-nochk || fail "control: the compiler without count's check does not build"
mk $B/omc-nochk
{ printf 'target x86linux\n'; cat $B/omc.nochk.om; } | a64 $O/omc > $B/omc-x86-nochk || fail "control: omc-x86 without count's check does not build"
mk $B/omc-x86-nochk
[ "$(sha $B/omc-nochk)" != "$(sha $O/omc)" ] || fail "control: deleting count's check did not change omc"
if EXAMPLES_ROOT=tests/omc sh tests/examples.sh $B/omc-nochk $B/omc-x86-nochk ${A64:+"$A64"} > $B/nochk.log; then
  fail "control: the compiler without count's slice check passed tests/omc"
fi
for t in a64 x86; do
  if grep -q "^NOT_RUN $t " $B/nochk.log; then note "NOT_RUN control on $t"; continue; fi
  for c in count_trap3 count_trap3_wrap; do
    grep -q "^FAIL $t examples/$c: exit " $B/nochk.log || fail "control: $t examples/$c did not catch the missing check"
  done
  grep -qx "PASS $t examples/count_word" $B/nochk.log || fail "control: $t count_word failed for another reason"
done
pass "control: count without its slice check fails count_trap3 and count_trap3_wrap; count_word still passes"

printf 'RC=0\n'
