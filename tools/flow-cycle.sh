#!/bin/sh
# flow-cycle.sh: one cycle of the Omega merge queue for one Radicle working copy.
#
#   sh tools/flow-cycle.sh FLOW REPO DEFAULT RECEIPTS
#
# FLOW      the planner built from tools/flow.om by the seed-born compiler (build.sh writes
#           out/flow-a64 and out/flow-x86)
# REPO      a Radicle working copy of the project, with its delegate's key authenticated
# DEFAULT   the name of the project's default branch
# RECEIPTS  the receipt ledger, one per project: tree, gate, verdict, log sha256; created with
#           its header line when missing, and only ever appended to
#
# The cycle has three parts, and only the middle one decides anything:
#   1. collect: fetch the repository, then list every open patch's head, the head's tree, and
#      how the head relates to the default branch (ff, div or in), with git plumbing only
#   2. plan:    FLOW turns those facts and the ledger into a script, flow.sh; every decision is
#      made there, in seeded Omega
#   3. act:     run flow.sh, which gates, comments and merges exactly as the plan says, and
#      refuses if the default branch moved since the facts were collected
# Run it again to advance the queue: each cycle merges at most one patch.
# FLOW_DIR=path keeps the cycle's facts and plan there (default: a temporary directory that is
# removed). With flock installed, a cycle holds RECEIPTS.lock, so two never run at once.
# Exit status: flow.sh's, or 1 when a part before it fails or another cycle runs, or 2 for usage.
set -eu
[ $# -eq 4 ] || { echo 'usage: sh tools/flow-cycle.sh FLOW REPO DEFAULT RECEIPTS' >&2; exit 2; }
flow=$1 repo=$2 def=$3 rec=$4
die() { printf 'flow-cycle: %s\n' "$*" >&2; exit 1; }
g() { git -C "$repo" "$@"; }
[ -x "$flow" ] || die "no planner $flow"
if [ -n "${FLOW_DIR:-}" ]; then d=$FLOW_DIR; mkdir -p -- "$d"; else d=$(mktemp -d); trap 'rm -rf "$d"' EXIT; fi
# One cycle at a time per ledger: a second one, from the timer or by hand, does not wait; it exits 1.
if command -v flock > /dev/null 2>&1; then
  exec 9>> "$rec.lock"
  flock -n 9 || die "another cycle holds $rec.lock"
fi

g fetch -q --prune rad || die "cannot fetch rad in $repo"
branch=$(g rev-parse --verify -q "refs/remotes/rad/$def^{commit}") || die "$repo has no rad/$def"
gate=$(g rev-parse --verify -q "$branch:build.sh") || die "the default branch at $branch has no build.sh"
[ -f "$rec" ] || printf 'tree\tgate\tverdict\tlog\n' > "$rec"

printf 'patch\thead\ttree\trel\n' > "$d/state.tsv"
g for-each-ref --format='%(refname:lstrip=4) %(objectname)' refs/remotes/rad/patches/ > "$d/heads"
while read -r p h; do
  t=$(g rev-parse --verify -q "$h^{tree}") || die "patch $p: head $h has no tree"
  if g merge-base --is-ancestor "$h" "$branch"; then r=in
  elif g merge-base --is-ancestor "$branch" "$h"; then r=ff
  else r=div; fi
  printf '%s\t%s\t%s\t%s\n' "$p" "$h" "$t" "$r" >> "$d/state.tsv"
done < "$d/heads"

"$flow" "$branch" "$gate" "$d/state.tsv" "$rec" "$d/flow.sh" 9>&- || die "the planner refused the facts in $d"
sh "$d/flow.sh" "$repo" "$def" "$rec" 9>&-
