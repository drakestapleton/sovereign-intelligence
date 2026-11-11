#!/bin/sh
# tools/si-state.sh INVENTORY [RECEIPTS]: print the Radicle state compiler/si.om reads, the
# generated input compiler/state.tsv. Nothing in it is typed. For each RID of INVENTORY (the second
# field of every line that is not empty or a # comment), in inventory order:
#   D RID BRANCH      the default branch the RID's signed identity names (rad inspect RID --payload)
#   V RID VISIBILITY  the first word of rad inspect RID --visibility
#   H RID BRANCH SHA  the canonical refs/heads/BRANCH in Radicle storage (RAD_STORAGE, default
#                     ~/.radicle/storage): the head of the default branch
#   P RID SHA FILE    one line per landing receipt in the directory RECEIPTS whose first line is
#                     exactly "RECEIPT PASS head=SHA" (or the older spelling "LANDING RECEIPT PASS
#                     head=SHA") for that head; FILE is the receipt's file name
# and before them one line "T UTC", the time it was read. Fields are TAB-separated. A value it cannot
# read is left out, so si refuses the row by name (no default branch, no visibility, no head); every
# check is si's, this script only reads. Without RECEIPTS no P line is written. Needs rad, git, jq.
#
#   sh tools/si-state.sh compiler/inventory.tsv /path/to/landing-receipts > compiler/state.tsv
set -eu
[ $# -ge 1 ] && [ $# -le 2 ] || { echo "usage: si-state.sh INVENTORY [RECEIPTS]" >&2; exit 2; }
inv=$1
rcp=${2:-}
store=${RAD_STORAGE:-$HOME/.radicle/storage}
[ -r "$inv" ] || { echo "si-state: cannot read $inv" >&2; exit 2; }
[ -d "$store" ] || { echo "si-state: no Radicle storage at $store" >&2; exit 2; }
[ -z "$rcp" ] || [ -d "$rcp" ] || { echo "si-state: no receipts directory $rcp" >&2; exit 2; }
tab=$(printf '\t')
idx=$(mktemp)
trap 'rm -f "$idx"' EXIT
# The receipts index: "SHA FILE" for every receipt whose first line names a head.
if [ -n "$rcp" ]; then
  for f in "$rcp"/*; do
    [ -f "$f" ] || continue
    l=$(head -n 1 "$f")
    case $l in
      "RECEIPT PASS head="*|"LANDING RECEIPT PASS head="*) h=${l##*head=} ;;
      *) continue ;;
    esac
    case $h in *[!0-9a-f]*) continue ;; esac
    [ ${#h} -eq 40 ] || continue
    printf '%s %s\n' "$h" "${f##*/}"
  done | LC_ALL=C sort > "$idx"
fi
printf 'T\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
grep -v '^#' "$inv" | while IFS="$tab" read -r _ rid _; do
  case $rid in rad:z*) ;; *) continue ;; esac
  br=$(rad inspect "$rid" --payload 2>/dev/null | jq -r '."xyz.radicle.project".defaultBranch // empty' 2>/dev/null || true)
  [ -z "$br" ] || printf 'D\t%s\t%s\n' "$rid" "$br"
  vis=$(rad inspect "$rid" --visibility 2>/dev/null | sed -n '1{s/[[:space:]].*//;p;}' || true)
  [ -z "$vis" ] || printf 'V\t%s\t%s\n' "$rid" "$vis"
  [ -n "$br" ] || continue
  h=$(git --git-dir="$store/${rid#rad:}" rev-parse -q --verify "refs/heads/$br^{commit}" 2>/dev/null || true)
  [ -n "$h" ] || continue
  printf 'H\t%s\t%s\t%s\n' "$rid" "$br" "$h"
  awk -v h="$h" -v r="$rid" '$1 == h { printf "P\t%s\t%s\t%s\n", r, h, $2 }' "$idx"
done
