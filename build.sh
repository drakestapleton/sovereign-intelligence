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
#      5b. compiler/links.om, built for both targets, must accept this checkout's link table and
#      tree, and refuse a repos.tsv whose first row carries a withdrawn crypto RID
#   6. tools/ledger.om, built for both targets, must print tests/ledger/expected.tsv
#   7. the Omega harness examples and the compiler regressions in tests/regress, on both targets
#      (tests/examples.sh)
#   8. gpu/cuda-crack, on both targets: its Omega table generator regenerates isa/sm121-forms.txt, its
#      Omega reencoder rebuilds the 70 kernels that ran on the GB10 from the tables to the chip
#      receipt's sha256, and its four planted bugs, made by check/mutate.om, are each caught
#   9. tools/forkpush.om, built for both targets, must print tests/forkpush/expected.sh, refuse every
#      tests/forkpush/bad/*.tsv, and write the same out/fork-push.sh from stack/FORKS.tsv
#  10. the examples of compiler words beyond the imported harness (tests/omc), on both targets
#  11. control: omc.om with count's slice check deleted must build a compiler that fails both trap-3
#      examples of count on every target that runs, while count_word still passes
#  12. tools/flow.om, the merge queue's planner, built for both targets, must print
#      tests/flow/expected.sh and expected-empty.sh and refuse every tests/flow/bad/*.tsv and three
#      malformed arguments; 12b. with rad, git-remote-rad and bwrap installed, tests/flow/e2e.sh
#      runs the whole queue, sandboxed, against a throwaway Radicle repository with each build, and
#      tests/flow/install.sh deploys it on a throwaway seed with tools/flow-install.sh; else NOT_RUN
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

# 5b. The link table: compiler/links.om must accept this checkout (every repos.tsv row a valid,
# non-crypto RID; no project source vendored in) and refuse the same checkout with one RID broken.
for t in a64 x86; do
  if [ $t = x86 ] && [ "$X86" = none ]; then note "NOT_RUN links on x86-64"; continue; fi
  if [ $t = a64 ]; then
    a64 $O/omc < compiler/links.om > $O/links-$t
  else
    { printf 'target x86linux\n'; cat compiler/links.om; } | x86 $O/omc-x86 > $O/links-$t
  fi
  mk $O/links-$t
  $t $O/links-$t . > $O/links-$t.out 2>&1 || fail "links ($t) refused this checkout: $(cat $O/links-$t.out)"
  w=$O/links-bad-$t
  rm -rf $w && mkdir -p $w/compiler
  awk -F'\t' 'BEGIN{OFS="\t"} NR==2{$2="rad:z2ft64" substr($2,11)} {print}' repos.tsv > $w/repos.tsv
  ! cmp -s $w/repos.tsv repos.tsv || fail "links ($t): the crypto-RID control did not change repos.tsv"
  if $t $O/links-$t $w > /dev/null 2> $w.err; then fail "links ($t) accepted a repos.tsv row with a crypto RID"; fi
  grep -q 'withdrawn crypto project is never linked' $w.err || fail "links ($t) refused the crypto-RID control for another reason: $(cat $w.err)"
  pass "links ($t) accepts this checkout and refuses a crypto RID"
done

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
sh tests/examples.sh "$O/omc" "$O/omc-x86" ${A64:+"$A64"} || fail "harness examples and regressions"
pass "harness examples and regressions"

# 8. gpu/cuda-crack: the sm_121 tables and the 70 kernels that ran on the GB10, checked on the CPU.
# This is check/check.sh and gen/run.sh of cuda-crack, on both targets; their planted bugs are made
# by check/mutate.om, which must equal check.sh's own awk and od one-liners (ccmut) byte for byte.
C=gpu/cuda-crack
E3=$C/receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z
T=$C/isa/sm121-forms.txt
(cd $C && sha256sum -c --quiet SHA256SUMS) || fail "cuda-crack: a file differs from gpu/cuda-crack/SHA256SUMS"
(cd $C/receipts && sha256sum -c --quiet SHA256SUMS) || fail "cuda-crack: a receipt differs from receipts/SHA256SUMS"
[ "$(sha $C/gen/bw_enc_sm121.om)" = fe16b024c3242d12c7c8ef759d84c34a22c7d21cba676cd987f4f3a1ff56ba86 ] \
  || fail "cuda-crack: gen/bw_enc_sm121.om is not the encoder of CUDApp b774723f"
pass "cuda-crack: $(wc -l < $C/SHA256SUMS | tr -d ' ') imported files and $(wc -l < $C/receipts/SHA256SUMS | tr -d ' ') receipts match their sha256 sums; the encoder is CUDApp b774723f's"
omb() { # omb TARGET OUT UNIT...: compile the units, one after another, for TARGET
  ot=$1; oo=$2; shift 2
  if [ "$ot" = a64 ]; then cat "$@" | a64 $O/omc > "$oo"
  else { printf 'target x86linux\n'; cat "$@"; } | x86 $O/omc-x86 > "$oo"; fi
  mk "$oo"
}
ccmut() { # ccmut MODE FILE: the planted bug MODE of check/check.sh at cuda-crack 7e3c9a73, verbatim
  case $1 in
    1) nop=$(awk '$1=="F" && $3==255 {print $5,$6,$7,$8,$9,$10}' "$2")
       awk -v key="$nop" '$1=="F" && ($5" "$6" "$7" "$8" "$9" "$10)==key {if ($5 % 2 == 1) $5 = $5 - 1; else $5 = $5 + 1} {print}' "$2" ;;
    2) b0=$(od -An -tu1 -N1 "$2" | tr -d ' '); printf "$(printf '\\%03o' $((b0 ^ 1)))"; tail -c +2 "$2" ;;
    3) awk 'd == 0 && $1=="D" && $8 > 1 {$8 = $8 - 1; d = 1} {print}' "$2" ;;
    4) awk 'd == 0 && $1=="D" && $8 > 0 {w = int($7 / 32); $(4 + w) = $(4 + w) - 2 ^ ($7 % 32); d = 1} {print}' "$2" ;;
  esac
}
tchk() { # tchk TABLE: reencode's exit status on TABLE's D records against its F records
  rc=0
  { cat "$1"; printf 'E\n'; } | $t $w/reencode > /dev/null 2>&1 || rc=$?
  echo $rc
}
rebuild() { # rebuild TABLE DIR: rebuild every chip kernel from TABLE into DIR; prints "kernels instructions unmatched"
  mkdir -p "$2"
  n=0; i=0; u=0
  for k in $E3/kernels-om/*.bin; do
    { cat "$1"; printf 'E\n'; cat "$k"; } | $t $w/reencode > "$2/$(basename "$k")" 2> $w/err || true
    read ni nu < $w/err || true
    case "$ni:$nu" in *[!0-9:]*|:*|*:) echo "bad bad bad"; return ;; esac
    n=$((n + 1)); i=$((i + ni)); u=$((u + nu))
  done
  echo "$n $i $u"
}
tail -n +5 $T > $O/cc-forms.body
k1=$(ls $E3/kernels-om/*.bin | head -1)
for t in a64 x86; do
  if [ $t = x86 ] && [ "$X86" = none ]; then note "NOT_RUN cuda-crack on x86-64"; continue; fi
  w=$O/cc-$t
  mkdir -p $w
  omb $t $w/isa-gen $C/gen/bw_enc_sm121.om $C/gen/isa.om
  $t $w/isa-gen > $w/forms.body || fail "cuda-crack ($t): gen/isa.om failed"
  cmp -s $w/forms.body $O/cc-forms.body || fail "cuda-crack ($t): gen/isa.om does not regenerate isa/sm121-forms.txt"
  pass "cuda-crack ($t): gen/isa.om probes the Omega encoder and regenerates all $(grep -c '^F' $O/cc-forms.body) forms of isa/sm121-forms.txt byte for byte"
  omb $t $w/reencode $C/check/reencode.om
  [ "$(tchk $T)" = 0 ] || fail "cuda-crack ($t): the D records of isa/sm121-forms.txt disagree with its F records"
  set -- $(rebuild $T $w/k)
  [ "$*" = "70 13520 0" ] || fail "cuda-crack ($t): rebuilt kernels, instructions, unmatched: $*; wanted 70 13520 0"
  (cd $w/k && sha256sum *.bin) > $w/k.sha256
  cmp -s $w/k.sha256 $E3/kernels-om.sha256 || fail "cuda-crack ($t): kernels rebuilt from the tables differ from the chip receipt kernels-om.sha256"
  pass "cuda-crack ($t): the tables' field records are consistent, and all 70 chip kernels (13520 instructions) rebuilt from the tables alone match the chip receipt"
  omb $t $w/mutate $C/check/mutate.om
  for f in $T $C/check/mutate-tests/*.txt; do
    for m in 1 3 4; do
      $t $w/mutate $m < "$f" > $w/mut.om.out || fail "cuda-crack ($t): mutate $m refused $f"
      ccmut $m "$f" > $w/mut.sh.out
      cmp -s $w/mut.om.out $w/mut.sh.out || fail "cuda-crack ($t): check/mutate.om mode $m differs from check.sh's awk on $f"
    done
  done
  for k in $E3/kernels-om/*.bin; do
    $t $w/mutate 2 < "$k" > $w/mut.om.out || fail "cuda-crack ($t): mutate 2 refused $k"
    ccmut 2 "$k" > $w/mut.sh.out
    cmp -s $w/mut.om.out $w/mut.sh.out || fail "cuda-crack ($t): check/mutate.om mode 2 differs from check.sh's od and printf on $k"
  done
  set +e
  $t $w/mutate 2 < /dev/null > $w/mut.om.out 2> /dev/null; rc=$?
  set -e
  [ $rc = 1 ] && [ ! -s $w/mut.om.out ] || fail "control: mutate 2 accepted an empty kernel (exit $rc)"
  pass "cuda-crack ($t): check/mutate.om makes check.sh's four planted bugs byte for byte (the table, $(ls $C/check/mutate-tests/*.txt | wc -l | tr -d ' ') edge cases, all 70 kernels) and refuses an empty kernel"
  for m in 1 3 4; do $t $w/mutate $m < $T > $w/mut$m.txt; done
  $t $w/mutate 2 < $k1 > $w/mut2.bin
  set -- $(rebuild $w/mut1.txt $w/m1)
  (cd $w/m1 && sha256sum *.bin) > $w/m1.sha256
  bad=$(diff $w/m1.sha256 $E3/kernels-om.sha256 | grep -c '^<' || true)
  [ "$3:$bad" = "540:67" ] || fail "control ($t): a flipped fixed bit left $3 instructions unmatched and $bad kernels wrong; check/CHECK.txt has 540 and 67"
  rc=0
  { cat $T; printf 'E\n'; cat $w/mut2.bin; } | $t $w/reencode > /dev/null 2>&1 || rc=$?
  [ $rc = 4 ] || fail "control ($t): a corrupted instruction was accepted (reencode exit $rc, wanted 4)"
  [ "$(tchk $w/mut3.txt)" = 7 ] || fail "control ($t): a field width off by one was accepted"
  [ "$(tchk $w/mut4.txt)" = 7 ] || fail "control ($t): a field mask missing one bit was accepted"
  pass "cuda-crack ($t) controls, as check/CHECK.txt: a flipped fixed bit fails 67 kernels, a corrupted instruction matches no form, a short field width and a short field mask are refused"
done
note "NOT_RUN cuda-crack on the GB10: running these kernels needs the chip; see gpu/cuda-crack/REPRODUCE.md"

# 9. The fork-push generator: the script that sends my personal forks' branches to Radicle.
for t in a64 x86; do
  if [ $t = x86 ] && [ "$X86" = none ]; then note "NOT_RUN forkpush on x86-64"; continue; fi
  if [ $t = a64 ]; then
    a64 $O/omc < tools/forkpush.om > $O/forkpush-a64
  else
    { printf 'target x86linux\n'; cat tools/forkpush.om; } | x86 $O/omc-x86 > $O/forkpush-x86
  fi
  mk $O/forkpush-$t
  $t $O/forkpush-$t tests/forkpush/forks.tsv $O/fp-fixture-$t.sh || fail "forkpush ($t) refused tests/forkpush/forks.tsv"
  cmp -s $O/fp-fixture-$t.sh tests/forkpush/expected.sh || fail "forkpush ($t) differs from tests/forkpush/expected.sh"
  nbad=0
  for b in tests/forkpush/bad/*.tsv; do
    rm -f $O/fp-bad.sh
    if $t $O/forkpush-$t "$b" $O/fp-bad.sh 2>/dev/null; then fail "forkpush ($t) accepted $b"; fi
    [ ! -e $O/fp-bad.sh ] || fail "forkpush ($t) wrote output for $b"
    nbad=$((nbad + 1))
  done
  $t $O/forkpush-$t stack/FORKS.tsv $O/fork-push-$t.sh || fail "forkpush ($t) refused stack/FORKS.tsv"
  pass "forkpush ($t) prints tests/forkpush/expected.sh and refuses all $nbad bad manifests"
done
if [ -f $O/fork-push-x86.sh ]; then
  cmp -s $O/fork-push-a64.sh $O/fork-push-x86.sh || fail "forkpush: the AArch64 and x86-64 builds write different fork-push.sh"
fi
sh -n $O/fork-push-a64.sh || fail "forkpush: the generated fork-push.sh does not parse"
cp $O/fork-push-a64.sh $O/fork-push.sh
pass "forkpush: out/fork-push.sh from stack/FORKS.tsv, $(grep -c "^fp '" $O/fork-push.sh) branches to push, sha256 $(sha $O/fork-push.sh)"

# 10. The examples of words this repository adds to the compiler (seed/PROVENANCE.md), on both targets.
EXAMPLES_ROOT=tests/omc sh tests/examples.sh "$O/omc" "$O/omc-x86" ${A64:+"$A64"} || fail "tests/omc examples"
pass "tests/omc examples"

# 11. Control: count without its slice check must be caught by the trap-3 examples.
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

# 12. tools/flow.om, the Omega merge queue's planner (tools/flow-cycle.sh runs it), on both targets.
fb=b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0
fg=9a7e777777777777777777777777777777777777
for t in a64 x86; do
  if [ $t = x86 ] && [ "$X86" = none ]; then note "NOT_RUN flow on x86-64"; continue; fi
  if [ $t = a64 ]; then
    a64 $O/omc < tools/flow.om > $O/flow-$t
  else
    { printf 'target x86linux\n'; cat tools/flow.om; } | x86 $O/omc-x86 > $O/flow-$t
  fi
  mk $O/flow-$t
  for f in state:expected empty:expected-empty; do
    i=tests/flow/${f%%:*}.tsv e=tests/flow/${f#*:}.sh
    $t $O/flow-$t $fb $fg $i tests/flow/receipts.tsv $O/fl-$t.sh || fail "flow ($t) refused $i"
    cmp -s $O/fl-$t.sh $e || fail "flow ($t) differs from $e"
    sh -n $O/fl-$t.sh || fail "flow ($t): $e does not parse"
  done
  nbad=0
  for b in tests/flow/bad/*.tsv; do
    case ${b##*/} in
      state-*) st=$b rf=tests/flow/receipts.tsv ;;
      rec-*) st=tests/flow/state.tsv rf=$b ;;
      *) fail "flow: $b is neither state-* nor rec-*" ;;
    esac
    rm -f $O/fl-bad.sh
    if $t $O/flow-$t $fb $fg $st $rf $O/fl-bad.sh 2> $O/fl-bad.err; then fail "flow ($t) accepted $b"; fi
    [ ! -e $O/fl-bad.sh ] || fail "flow ($t) wrote output for $b"
    [ "$(wc -l < $O/fl-bad.err)" -eq 1 ] && grep -q '^flow: ' $O/fl-bad.err || fail "flow ($t) refused $b without one flow: line"
    nbad=$((nbad + 1))
  done
  for a in "${fb%b0}b $fg" "$(printf %s $fb | tr b B) $fg" "$fb ${fg%7}g"; do
    rm -f $O/fl-bad.sh
    if $t $O/flow-$t $a tests/flow/state.tsv tests/flow/receipts.tsv $O/fl-bad.sh 2> /dev/null; then fail "flow ($t) accepted the arguments $a"; fi
    [ ! -e $O/fl-bad.sh ] || fail "flow ($t) wrote output for the arguments $a"
  done
  rc=0; $t $O/flow-$t $fb $fg tests/flow/state.tsv $O/fl-bad.sh 2> /dev/null || rc=$?
  [ $rc -eq 2 ] || fail "flow ($t) exited $rc, not 2, for four arguments"
  pass "flow ($t) prints tests/flow/expected.sh and expected-empty.sh, refuses all $nbad bad inputs and 3 bad arguments"
done
#  12b. The merge queue against a real Radicle repository, offline, and its installer, when rad
#  and bwrap are installed and flow.sh's sandbox can start here. It cannot inside another such
#  sandbox (procfs will not mount there), which is where this gate runs when flow gates SI itself.
fbox() { # the sandbox fl_box gives a gate, around true
  bwrap --ro-bind / / --tmpfs /home --tmpfs /root --tmpfs /run --tmpfs /tmp --dir /tmp/home \
    --dev /dev --proc /proc --unshare-all --die-with-parent --new-session --clearenv true 2> /dev/null
}
if ! { command -v rad && command -v git-remote-rad && command -v bwrap; } > /dev/null 2>&1; then
  note "NOT_RUN flow e2e and install: need rad, git-remote-rad and bwrap (https://radicle.xyz)"
elif ! fbox; then
  note "NOT_RUN flow e2e and install: flow.sh's bwrap sandbox cannot start on this host"
else
  for t in a64 x86; do
    [ -x $O/flow-$t ] || { note "NOT_RUN flow e2e on $t"; continue; }
    if [ $t = a64 ]; then q=$A64; else q=$X86; fi
    printf '#!/bin/sh\nexec %s "%s" "$@"\n' "$q" "$R/$O/flow-$t" > $O/flow-$t.run
    mk $O/flow-$t.run
    sh tests/flow/e2e.sh $O/flow-$t.run > $O/flow-e2e-$t.log 2>&1 || fail "flow e2e ($t): $(grep '^FAIL' $O/flow-e2e-$t.log | head -1)"
    tail -1 $O/flow-e2e-$t.log | grep -qx 'RC=0' || fail "flow e2e ($t) did not finish"
    pass "flow e2e ($t): $(grep -c '^PASS' $O/flow-e2e-$t.log) checks against a real Radicle repository"
  done
  # the installer, with this host's native planner (it installs the native build)
  case $host in aarch64|arm64) nt=a64 ;; *) nt=x86 ;; esac
  if [ -x $O/flow-$nt ]; then
    sh tests/flow/install.sh $O/flow-$nt > $O/flow-install.log 2>&1 || fail "flow install: $(grep '^FAIL' $O/flow-install.log | head -1)"
    tail -1 $O/flow-install.log | grep -qx 'RC=0' || fail "flow install did not finish"
    grep '^NOTE' $O/flow-install.log | while IFS= read -r l; do printf '%s\n' "$l"; done
    pass "flow install: $(grep -c '^PASS' $O/flow-install.log) checks of tools/flow-install.sh on a throwaway seed"
  else
    note "NOT_RUN flow install: no native planner"
  fi
fi

printf 'RC=0\n'
