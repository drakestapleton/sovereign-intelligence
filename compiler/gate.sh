#!/bin/sh
# compiler/gate.sh: build compiler/si.om with the pinned omc and check the generator.
# The checks themselves live in si.om; this runner only feeds it inputs and compares results.
#   1. the committed inputs regenerate README.md and repos.tsv byte-identically (rc 0)
#   2. an inventory head changed by one digit is refused (rc 1, names the row)
#   3. an inventory RID changed by one character is refused (rc 1, names the row)
#   4. the stale inventory of 3c37e6fb, checked against today's vetted.md, is refused (rc 1)
# Mutant inputs must differ from the committed inventory (their sha256 is compared), so a
# mutation that did not apply cannot pass as a refusal.
# usage, from the repository root: sh compiler/gate.sh OMC [WORKDIR]
# exit 0 pass, 1 fail, 3 NOT_RUN (no omc, or not the pin)
set -u
PIN=3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194
OLD=3c37e6fb5a177875bd4637f33cfee56811080990
omc=${1:-}
if [ -z "$omc" ] || [ ! -x "$omc" ]; then echo "SI NOT_RUN: no omc given"; exit 3; fi
have=$(sha256sum "$omc" | cut -d' ' -f1)
if [ "$have" != "$PIN" ]; then echo "SI NOT_RUN: omc $have is not the pin $PIN"; exit 3; fi
root=$(cd "$(dirname "$0")/.." && pwd)
work=${2:-$(mktemp -d)}
mkdir -p "$work"
work=$(cd "$work" && pwd)
cd "$root" || exit 1
pass=0 fail=0
ok() { pass=$((pass + 1)); echo "PASS $1"; }
bad() { fail=$((fail + 1)); echo "FAIL $1"; }

if "$omc" < compiler/si.om > "$work/si" 2> "$work/omc.err" && [ ! -s "$work/omc.err" ]; then
  chmod +x "$work/si"
else
  echo "FAIL compile: $(cat "$work/omc.err")"; exit 1
fi

# run NAME INVENTORY: si on INVENTORY with the committed order.tsv and vetted.md, into $work/NAME
run() {
  mkdir -p "$work/$1"
  cp README.md "$work/$1/README.md"
  "$work/si" "$2" compiler/order.tsv compiler/vetted.md "$work/$1/README.md" \
    "$work/$1/repos.tsv" "$work/$1/si.sh" > "$work/$1/out" 2> "$work/$1/err"
}
# refused NAME INVENTORY WANT: si exits 1, its stderr starts with WANT and README is untouched
refused() {
  if cmp -s "$2" compiler/inventory.tsv; then bad "$1: mutant equals the committed inventory"; return; fi
  run "$1" "$2"; rc=$?
  if [ "$rc" -eq 1 ] && grep -q "^si: $3" "$work/$1/err" && cmp -s README.md "$work/$1/README.md" \
    && [ ! -e "$work/$1/repos.tsv" ]; then
    ok "$1 refused: $(cat "$work/$1/err")"
  else
    bad "$1 rc=$rc: $(cat "$work/$1/err") (want rc 1 and: $3)"
  fi
}

run current compiler/inventory.tsv; rc=$?
if [ "$rc" -eq 0 ] && cmp -s README.md "$work/current/README.md" && cmp -s repos.tsv "$work/current/repos.tsv"; then
  ok "current inventory regenerates README.md and repos.tsv byte-identically"
else
  bad "current inventory rc=$rc: $(cat "$work/current/err")"
fi

# head mutant: the last digit of the first row's head, 0-9a-e -> next, f -> 0
awk -F'\t' 'BEGIN{OFS="\t"; d="0123456789abcdef0"} NR==1{c=substr($4,40,1); $4=substr($4,1,39) substr(d,index(d,c)+1,1)} {print}' \
  compiler/inventory.tsv > "$work/head.tsv"
refused head-mutant "$work/head.tsv" "inventory head is not the vetted main head: "

# RID mutant: the last character of the first row's RID becomes X (or Y if it is X)
awk -F'\t' 'BEGIN{OFS="\t"} NR==1{c=substr($2,length($2),1); $2=substr($2,1,length($2)-1) (c=="X"?"Y":"X")} {print}' \
  compiler/inventory.tsv > "$work/rid.tsv"
refused rid-mutant "$work/rid.tsv" "inventory RID has no vetted main row: "

if git cat-file -e "$OLD:compiler/inventory.tsv" 2> /dev/null; then
  git show "$OLD:compiler/inventory.tsv" > "$work/old.tsv"
  refused old-3c37e6fb "$work/old.tsv" "inventory head is not the vetted main head: "
else
  bad "old-3c37e6fb: commit $OLD is not in this clone"
fi

echo "SI pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
