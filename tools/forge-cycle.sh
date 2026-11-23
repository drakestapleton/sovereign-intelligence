#!/bin/sh
# forge-cycle.sh: one cycle of the Omega forge on the seed node.
#
#   sh tools/forge-cycle.sh FORGE TALLY ALLOW STATE WEB [LOG...]
#
# FORGE  the page generator built from tools/forge.om; TALLY the pull counter built from
#        tools/tally.om (build.sh writes out/forge-a64, out/forge-x86, out/tally-a64, out/tally-x86)
# ALLOW  the projects to publish: one RID per line, only vetted public ones (the same file
#        tools/intake.om reads)
# STATE  the forge's own directory: ledger.tsv (the pull counts), spool/{tmp,new,done,failed}
#        (what people sent through tools/intake.om), both created when missing, and facts.tsv, the facts
#        of the last cycle, from which FORGE rebuilds the same site byte for byte
# WEB    the path the web server serves as /forge/. It is a symbolic link, switched atomically to
#        each new build (WEB.TIME), so no reader ever sees half a site; the previous build is removed.
#        On the first cycle WEB must not exist
# LOG    the seed's logs to count: nginx access logs and the radicle-node log, in any order
#        (repeat a day's logs freely: a day's counts are replaced, never added twice)
#
# Environment: FORGE_SEED_URL, the base that clones a project over HTTPS (default
# https://www.aienos.com/rad/); FORGE_DAY, today as YYYY-MM-DD (default: today, UTC);
# FORGE_ANNOUNCE=0 publishes without announcing to the network (tests).
#
# The cycle has four parts, and the decisions are made in seeded Omega:
#   1. publish: each record intake.om spooled becomes a Radicle issue or comment, signed by this
#      node, labelled web; the record moves to spool/done (or, refused, to spool/failed)
#   2. count:   TALLY reads the logs and updates ledger.tsv (counts only, never an address)
#   3. collect: what this node holds for every RID in ALLOW, from rad and git plumbing only
#   4. render:  FORGE writes the site into a fresh directory; WEB switches to it only on success
# Exit status: 0, or 1 when a part fails (the site then stays as it was), or 2 for usage.
set -eu
[ $# -ge 5 ] || { echo 'usage: sh tools/forge-cycle.sh FORGE TALLY ALLOW STATE WEB [LOG...]' >&2; exit 2; }
forge=$1 tally=$2 allow=$3 state=$4 web=$5
shift 5
die() { printf 'forge-cycle: %s\n' "$*" >&2; exit 1; }
for x in "$forge" "$tally"; do [ -x "$x" ] || die "no program $x"; done
[ -f "$allow" ] || die "no allow list $allow"
command -v rad > /dev/null 2>&1 || die "rad is required: https://radicle.xyz"
seed=${FORGE_SEED_URL:-https://www.aienos.com/rad/}
day=${FORGE_DAY:-$(date -u +%Y-%m-%d)}
ann=; [ "${FORGE_ANNOUNCE:-1}" = 1 ] || ann=--no-announce
mkdir -p "$state/spool/tmp" "$state/spool/new" "$state/spool/done" "$state/spool/failed"
[ -f "$state/ledger.tsv" ] || printf 'rid\tday\thttps\thosts\trad\tpeers\n' > "$state/ledger.tsv"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
store=$(rad path)/storage
allowed() { grep -qxF "$1" "$allow"; }

# 1. publish
# A record rad will not take (its project left ALLOW, its issue is gone) moves to spool/failed with
# its reason in ID.why, so one bad record never stops later cycles. Every value is passed as
# --option=VALUE: a title or body may begin with "-".
quarantine() { mv "$f" "$state/spool/failed/$id"; printf '%s\n' "$1" > "$state/spool/failed/$id.why"; printf 'forge-cycle: spool record %s failed: %s\n' "$id" "$1" >&2; }
for f in "$state/spool/new"/*; do
  [ -f "$f" ] || continue
  id=${f##*/}
  hdr=$(head -n 8 "$f" | wc -c)
  if [ "$(sed -n 1p "$f")" != 'forge-intake 1' ] || [ "$(sed -n 2p "$f")" != "id $id" ]; then quarantine "not a forge-intake 1 record named $id"; continue; fi
  rid=$(sed -n '3s/^repo //p' "$f") kind=$(sed -n '4s/^kind //p' "$f") target=$(sed -n '5s/^target //p' "$f")
  title=$(sed -n '7s/^title //p' "$f") n=$(sed -n '8s/^body //p' "$f")
  if ! allowed "$rid"; then quarantine "$rid is not in $allow"; continue; fi
  tail -c "+$((hdr + 1))" "$f" > "$work/body"
  if [ "$(wc -c < "$work/body")" != "$n" ]; then quarantine "the body is not $n bytes"; continue; fi
  printf '\n\n(Sent through the web form; receipt %s.)' "$id" >> "$work/body"
  case $kind in
    issue) rad issue open --repo="$rid" --title="$title" --description="$(cat "$work/body")" --labels=web $ann -q < /dev/null > "$work/rad" 2>&1 ;;
    comment) rad issue comment --repo="$rid" --message="$(cat "$work/body")" $ann -q -- "$target" < /dev/null > "$work/rad" 2>&1 ;;
    *) false ;;
  esac || { quarantine "rad refused the $kind: $(head -1 "$work/rad")"; continue; }
  mv "$f" "$state/spool/done/$id"
  printf 'forge-cycle: published %s %s on %s\n' "$kind" "$id" "$rid"
done

# 2. count
if [ $# -gt 0 ]; then
  rm -f "$state/ledger.tsv.new"
  cat -- "$@" > "$work/logs" || die "cannot read the logs"
  "$tally" "$state/ledger.tsv" "$state/ledger.tsv.new" < "$work/logs" || die "tally refused the logs"
  mv "$state/ledger.tsv.new" "$state/ledger.tsv"
fi

# 3. collect
f=$state/facts.tsv
printf 'forge-facts 1\nseed\t%s\n' "$seed" > "$f"
while read -r rid; do
  case $rid in rad:z*) ;; *) continue ;; esac
  z=${rid#rad:}
  rad inspect --payload "$rid" < /dev/null > "$work/j" || die "rad inspect $rid"
  payload=$(tr -d '\n' < "$work/j")
  def=$(printf '%s' "$payload" | sed -n 's/.*"defaultBranch": *"\([^"]*\)".*/\1/p')
  head=$(git --git-dir="$store/$z" rev-parse --verify -q "refs/heads/$def^{commit}" < /dev/null) || die "$rid has no canonical $def"
  printf 'project\t%s\t%s\t%s\n' "$rid" "$head" "$payload" >> "$f"
  rad node routing --rid "$rid" --json < /dev/null 2> /dev/null | sed -n 's/.*"nid":"\(z[1-9A-HJ-NP-Za-km-z]*\)".*/\1/p' | sort -u |
    while read -r nid; do printf 'seeder\t%s\t%s\n' "$rid" "$nid"; done >> "$f"
  for t in issue patch; do
    rad cob list --repo "$rid" --type "xyz.radicle.$t" < /dev/null > "$work/ids" || die "rad cob list $rid $t"
    while read -r oid; do
      rad cob show --repo "$rid" --type "xyz.radicle.$t" --object "$oid" < /dev/null > "$work/j" || die "rad cob show $rid $oid"
      j=$(tr -d '\n' < "$work/j")
      printf '%s\t%s\t%s\t%s\n' "$t" "$rid" "$oid" "$j" >> "$f"
    done < "$work/ids"
  done
done < "$allow"

# 4. render
new=$web.$(date -u +%Y%m%dT%H%M%SZ).$$
mkdir "$new"
"$forge" "$f" "$state/ledger.tsv" "$day" "$new" || { rm -rf "$new"; die "forge refused the facts in $f"; }
old=$(readlink "$web" 2> /dev/null || true)
ln -s "${new##*/}" "$web.link.$$"
mv -T "$web.link.$$" "$web"
case $old in ''|/*|*/*) ;; *) rm -rf "$(dirname -- "$web")/$old" ;; esac
printf 'forge-cycle: %s now serves %s\n' "$web" "$new"
