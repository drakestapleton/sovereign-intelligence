#!/bin/sh
# evidence/x86-native/stale-pins.sh QUALIFY_JSONL OMEGA_MV
#
# Explains each FAIL row "compiler stdout differs from oracle sha:X" or "... oracle file:F", an emit
# row: the AArch64 compiler's output for the row's exact source must have sha256 X (or equal F as
# committed at omega-mv 6fbc6cbe). For every such row it recompiles that source with
#   - each AArch64 omc omega-mv committed (seed/out/omc) from 62d1d0d6, the compiler of the
#     2026-10-30 x86 receipt, to 6fbc6cbe, newest first, until one reproduces the pin; and
#   - this repository's out/omc, the compiler under test,
# and prints one TSV line: the case, the pin, the newest omega-mv commit whose omc reproduces it
# (and that omc's sha256), our omc's sha256, the sha256 the oracle observed, and a verdict:
# STALE_PIN when an earlier committed omc reproduces the pin and ours reproduces what the oracle saw,
# else UNEXPLAINED. A STALE_PIN row pins AArch64 bytes of an older omc; omc's AArch64 code for that
# source has changed since, so the row fails on any host. Exit 1 if any row is UNEXPLAINED.
set -eu
[ $# -eq 2 ] || { echo "usage: sh evidence/x86-native/stale-pins.sh QUALIFY_JSONL OMEGA_MV" >&2; exit 2; }
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
J=$1 MV=$2
MV_REV=6fbc6cbe4bfa4092608e2b5f06d2e8f537893992
OLDEST=62d1d0d668f897386a0e311374f8dbcc5c32dde8
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
sha() { sha256sum | cut -c1-64; }
{ git -C "$MV" log --format=%H "$OLDEST..$MV_REV" -- seed/out/omc; echo "$OLDEST"; } > "$T/commits"
while read -r c; do
  git -C "$MV" show "$c:seed/out/omc" > "$T/omc-$c"
  chmod +x "$T/omc-$c"
done < "$T/commits"
printf 'case\tpin\tpin_sha256\treproduced_by_commit\treproduced_by_omc_sha256\tnew_sha256\tobserved_sha256\tverdict\n'
: > "$T/verdicts"
jq -r 'select(.status? == "FAIL" and (.reason | test("^compiler stdout differs from oracle (sha|file):")))
       | [.case, .evidence.source_spec, (.reason | capture("^compiler stdout differs from oracle (?<p>[^ ]+): bytes=[0-9]+ sha256=(?<o>[0-9a-f]{64})") | .p, .o)] | @tsv' "$J" |
while IFS="$(printf '\t')" read -r name spec pin observed; do
  case $spec in
    pack:*:*:*) rest=${spec#pack:}; len=${rest##*:}; rest=${rest%:*}; off=${rest##*:}; file=${rest%:*}
                git -C "$MV" show "$MV_REV:$file" | tail -c +"$((off + 1))" | head -c "$len" > "$T/src" ;;
    *) git -C "$MV" show "$MV_REV:$spec" > "$T/src" ;;
  esac
  case $pin in
    sha:*) want=${pin#sha:} ;;
    file:*) want=$(git -C "$MV" show "$MV_REV:${pin#file:}" | sha) ;;
  esac
  by=- bysha=-
  while read -r c; do
    if [ "$("$T/omc-$c" < "$T/src" 2> /dev/null | sha)" = "$want" ]; then by=$c bysha=$(sha < "$T/omc-$c"); break; fi
  done < "$T/commits"
  new=$("$R/out/omc" < "$T/src" 2> /dev/null | sha)
  verdict=UNEXPLAINED
  [ "$by" != - ] && [ "$new" = "$observed" ] && verdict=STALE_PIN
  echo "$verdict" >> "$T/verdicts"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$pin" "$want" "$by" "$bysha" "$new" "$observed" "$verdict"
done
! grep -q UNEXPLAINED "$T/verdicts"
