#!/bin/sh
# Rebuild the 70 chip-run kernels from isa/sm121-forms.txt alone and compare sha256 with the
# chip receipt kernels-om.sha256, after checking the D (operand field) records against the F records.
# Then four negative controls that must fail.
# Usage: OMC=/path/to/omc check/check.sh     (run from the repository root)
set -eu
OMC=${OMC:?set OMC to the pinned omega-mv seed compiler}
E3=receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z
T=isa/sm121-forms.txt
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
"$OMC" < check/reencode.om > "$tmp/reencode"
chmod +x "$tmp/reencode"

# rebuild every kernel from table $1 into directory $2; prints "kernels instructions unmatched"
rebuild() {
  mkdir -p "$2"
  n=0; i=0; u=0
  for k in "$E3"/kernels-om/*.bin; do
    b=$(basename "$k")
    { cat "$1"; printf 'E\n'; cat "$k"; } | "$tmp/reencode" > "$2/$b" 2> "$tmp/err" || true
    read ni nu < "$tmp/err"
    n=$((n + 1)); i=$((i + ni)); u=$((u + nu))
  done
  echo "$n $i $u"
}

# check table $1's D records against its F records; prints reencode's exit code (0 consistent, 7 not)
tcheck() {
  rc=0
  { cat "$1"; printf 'E\n'; } | "$tmp/reencode" > /dev/null 2>&1 || rc=$?
  echo "$rc"
}

echo "== real tables: $T sha256 $(sha256sum "$T" | cut -d' ' -f1)"
rc=$(tcheck "$T")
echo "D records vs F records: reencode exit $rc"
if [ "$rc" -eq 0 ]; then
  echo "PASS: fields never overlap, field union = form mask, every width>0 field is exactly its bit span"
else
  echo "FAIL: D records disagree with F records"; exit 1
fi
set -- $(rebuild "$T" "$tmp/out")
echo "kernels $1 instructions $2 unmatched $3"
(cd "$tmp/out" && sha256sum *.bin) > "$tmp/out.sha256"
if cmp -s "$tmp/out.sha256" "$E3/kernels-om.sha256"; then
  echo "PASS: all $1 rebuilt kernels match kernels-om.sha256 byte for byte"
else
  echo "FAIL: rebuilt kernels differ from kernels-om.sha256"; exit 1
fi

echo "== mutant 1: bit 0 of word 0 flipped in every form that has the NOP's fixed bits and mask"
nop=$(awk '$1=="F" && $3==255 {print $5,$6,$7,$8,$9,$10}' "$T")
awk -v key="$nop" '$1=="F" && ($5" "$6" "$7" "$8" "$9" "$10)==key {if ($5 % 2 == 1) $5 = $5 - 1; else $5 = $5 + 1} {print}' "$T" > "$tmp/mut1.txt"
echo "mutated forms: $(diff "$T" "$tmp/mut1.txt" | grep -c '^>' || true)"
set -- $(rebuild "$tmp/mut1.txt" "$tmp/mut1")
(cd "$tmp/mut1" && sha256sum *.bin) > "$tmp/mut1.sha256"
bad=$(diff "$tmp/mut1.sha256" "$E3/kernels-om.sha256" | grep -c '^<' || true)
echo "kernels $1 instructions $2 unmatched $3 sha-mismatched kernels $bad"
if [ "$bad" -gt 0 ]; then echo "PASS: mutant table caught"; else echo "FAIL: mutant table not caught"; exit 1; fi

echo "== mutant 2: bit 0 of word 0 flipped in the first instruction of the first kernel"
k=$(ls "$E3"/kernels-om/*.bin | head -1)
b0=$(od -An -tu1 -N1 "$k" | tr -d ' ')
printf "$(printf '\\%03o' $((b0 ^ 1)))" > "$tmp/mut2.bin"
tail -c +2 "$k" >> "$tmp/mut2.bin"
rc=0
{ cat "$T"; printf 'E\n'; cat "$tmp/mut2.bin"; } | "$tmp/reencode" > /dev/null 2> "$tmp/err2" || rc=$?
echo "reencode exit $rc, instructions unmatched: $(cat "$tmp/err2")"
if [ "$rc" -eq 4 ]; then echo "PASS: corrupted instruction matches no form"; else echo "FAIL: corrupted instruction accepted"; exit 1; fi

echo "== mutant 3: width of the first D record with width > 1 reduced by one"
awk 'd == 0 && $1=="D" && $8 > 1 {$8 = $8 - 1; d = 1} {print}' "$T" > "$tmp/mut3.txt"
rc=$(tcheck "$tmp/mut3.txt")
echo "reencode exit $rc"
if [ "$rc" -eq 7 ]; then echo "PASS: wrong field width caught"; else echo "FAIL: wrong field width accepted"; exit 1; fi

echo "== mutant 4: lowest bit cleared in the mask of the first D record with width > 0"
awk 'd == 0 && $1=="D" && $8 > 0 {w = int($7 / 32); $(4 + w) = $(4 + w) - 2 ^ ($7 % 32); d = 1} {print}' "$T" > "$tmp/mut4.txt"
rc=$(tcheck "$tmp/mut4.txt")
echo "reencode exit $rc"
if [ "$rc" -eq 7 ]; then echo "PASS: wrong field mask caught"; else echo "FAIL: wrong field mask accepted"; exit 1; fi
echo "ALL CHECKS PASS"
