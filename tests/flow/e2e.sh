#!/bin/sh
# tests/flow/e2e.sh: the Omega merge queue against a real Radicle repository, offline.
#
#   sh tests/flow/e2e.sh FLOW
#
# FLOW is the planner built from tools/flow.om. Needs git, rad and git-remote-rad; it makes a
# throwaway Radicle identity and repository under a temporary directory (RAD_HOME is never the
# user's), so no node, network or key of yours is touched. Without rad it prints NOT_RUN and
# exits 3.
#
# The repository's gate, build.sh, passes when the file state says good, and fails if it can
# see the delegate's passphrase, Radicle home, agent socket or key directory, or reach any
# network but loopback: flow.sh's sandbox must hide all of them. Five patches:
#   A  a good change                      C  a different commit with A's exact tree
#   B  state=bad                          E  a good change to another file
#   D  state=bad, and its own build.sh rewritten to pass anyway
# Cycle 1 gates A (or C, whichever comes first) once for both, and B, D and E; D must fail,
# because the default branch's gate runs, never the patch's. Cycle 2 merges the first of A, C
# and E (patch ids are random, so any of them) as a fast-forward and queues the other two.
# Cycle 3 gates nothing and sends those two to rebase.
# After every cycle the default branch's tree must hold a pass receipt. A plan made before the
# default branch moved must refuse to run. Each check prints PASS or FAIL; last line RC=0.
set -eu
[ $# -eq 1 ] || { echo 'usage: sh tests/flow/e2e.sh FLOW' >&2; exit 2; }
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
case $1 in /*) flow=$1 ;; *) flow=$(pwd)/$1 ;; esac
for c in git rad git-remote-rad bwrap; do
  command -v $c > /dev/null 2>&1 || { echo "NOT_RUN flow e2e: no $c"; exit 3; }
done
fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
T=$(mktemp -d)
# FLOW_E2E_KEEP=1 keeps the throwaway directory, for reading what a failed check saw.
if [ -n "${FLOW_E2E_KEEP:-}" ]; then echo "NOTE e2e directory $T"; else trap 'rm -rf "$T"' EXIT; fi
# No GIT_COMMITTER_DATE: radicle-cob reads it too, and panics on anything but integer seconds.
export RAD_HOME="$T/rad" RAD_PASSPHRASE=flow-e2e
unset GIT_AUTHOR_DATE GIT_COMMITTER_DATE
q() { "$@" > "$T/last.out" 2>&1 || { cat "$T/last.out" >&2; fail "$*"; }; }
q rad auth --alias flow-e2e
w=$T/demo
git init -q -b main "$w"
g() { git -C "$w" "$@"; }
g config user.email e2e@flow.invalid
g config user.name flow-e2e
cat > "$w/build.sh" << 'GATE'
#!/bin/sh
[ -z "${RAD_PASSPHRASE:-}${RAD_HOME:-}${SSH_AUTH_SOCK:-}" ] || { echo "FAIL the gate can see the delegate's key"; exit 1; }
[ ! -e '@KEYS@' ] || { echo "FAIL the gate can see the Radicle key directory"; exit 1; }
[ "$(grep -c : /proc/net/dev)" -le 1 ] || { echo "FAIL the gate can reach a network"; exit 1; }
if grep -qx good state; then echo PASS state; else echo "FAIL state is not good"; exit 1; fi
GATE
sed -i "s|@KEYS@|$RAD_HOME/keys|" "$w/build.sh"
[ -d "$RAD_HOME/keys" ] || fail "no key directory at $RAD_HOME/keys to hide"
echo good > "$w/state"
g add build.sh state
g commit -qm init
(cd "$w" && q rad init --name demo --description 'flow e2e' --default-branch main --public --no-confirm --no-seed)
base=$(g rev-parse HEAD)

mk() { # mk NAME FILE TEXT [BUILD]: a commit on base changing FILE to TEXT (and build.sh to BUILD)
  g checkout -q --detach "$base"
  printf '%s\n' "$3" > "$w/$2"
  [ $# -lt 4 ] || printf '%s\n' "$4" > "$w/build.sh"
  g add -A
  g commit -qm "$1"
  g rev-parse HEAD
}
open() { # open COMMIT TITLE: open a Radicle patch at COMMIT; prints the patch id
  (cd "$w" && git push rad "$1:refs/patches" -o patch.message="$2" > "$T/open.out" 2>&1) || { cat "$T/open.out" >&2; fail "open $2"; }
  sed -n 's/.*Patch \([0-9a-f]\{40\}\) opened.*/\1/p' "$T/open.out"
}
hA=$(mk A a 'change a'); pA=$(open "$hA" A)
hB=$(mk B state bad); pB=$(open "$hB" B)
hC=$(g commit-tree "$hA^{tree}" -p "$base" -m C); pC=$(open "$hC" C)
hD=$(mk D state bad '#!/bin/sh
exit 0'); pD=$(open "$hD" D)
hE=$(mk E e 'change e'); pE=$(open "$hE" E)
g checkout -q main
for p in "$pA" "$pB" "$pC" "$pD" "$pE"; do [ ${#p} -eq 40 ] || fail "a patch id is not 40 hex: '$p'"; done
tA=$(g rev-parse "$hA^{tree}")
[ "$(g rev-parse "$hC^{tree}")" = "$tA" ] && [ "$hC" != "$hA" ] || fail "C is not a second commit with A's tree"
pass "5 patches opened on a fresh Radicle repository"

rec=$T/receipts.tsv
cycle() { # cycle N: one flow cycle; its plan stays in $T/cN
  FLOW_DIR=$T/c$1 sh "$R/tools/flow-cycle.sh" "$flow" "$w" main "$rec" > "$T/c$1.out" 2>&1 || { cat "$T/c$1.out" >&2; fail "cycle $1 exited non-zero"; }
}
act() { awk -v p="$2" '$1 == "#" && $2 == "plan" && $4 == p { print $3 }' "$T/c$1/flow.sh"; }
verdict() { awk -F'\t' -v t="$1" '$1 == t { print $3 }' "$rec"; }
tip() { g rev-parse refs/remotes/rad/main; }
tip_has_pass() { # the default branch's tree has a pass receipt (or is the initial commit)
  [ "$(tip)" = "$base" ] || [ "$(verdict "$(g rev-parse "$(tip)^{tree}")")" = pass ] || fail "cycle $1: rad/main's tree has no pass receipt"
}

cycle 1
[ "$(act 1 "$pA")$(act 1 "$pC")" = gatesame ] || [ "$(act 1 "$pA")$(act 1 "$pC")" = samegate ] || fail "cycle 1: A and C are '$(act 1 "$pA")' and '$(act 1 "$pC")', not one gate and one same"
for p in "$pB" "$pD" "$pE"; do [ "$(act 1 "$p")" = gate ] || fail "cycle 1: patch $p is $(act 1 "$p"), not gate"; done
[ "$(grep -c . "$rec")" -eq 5 ] || fail "cycle 1: the ledger has $(grep -c . "$rec") lines, not a header and 4 receipts"
[ "$(verdict "$tA")" = pass ] || fail "cycle 1: A's tree did not pass"
[ "$(verdict "$(g rev-parse "$hB^{tree}")")" = fail ] || fail "cycle 1: B did not fail"
[ "$(verdict "$(g rev-parse "$hD^{tree}")")" = fail ] || fail "cycle 1: D passed with its own build.sh"
[ "$(verdict "$(g rev-parse "$hE^{tree}")")" = pass ] || fail "cycle 1: E's tree did not pass"
[ "$(tip)" = "$base" ] || fail "cycle 1 moved rad/main"
pass "cycle 1: 4 trees gated for 5 patches; D's own build.sh was not the gate"
rid=$(cd "$w" && rad .) || fail "rad . in the demo repository"
(cd "$w" && rad cob show --repo "$rid" --type xyz.radicle.patch --object "$pB" > "$T/cobB" 2>&1) || fail "rad cob show B"
tB=$(g rev-parse "$hB^{tree}")
body=$(awk -F'\t' -v t="$tB" '$1 == t { printf "\"body\":\"flow gate %s tree %s gate %s log %s\\nFAIL state is not good\"", $3, $1, $2, $4 }' "$rec")
grep -qF "$body" "$T/cobB" || fail "B's Radicle comment is not exactly its receipt and the gate's FAIL line"
pass "cycle 1: B's Radicle comment is its receipt, word for word, and the gate's FAIL line"

cycle 2
m=$(awk '$1 == "#" && $2 == "plan" && $3 == "merge" { print $4 }' "$T/c2/flow.sh")
hm=$(awk '$1 == "#" && $2 == "plan" && $3 == "merge" { print $5 }' "$T/c2/flow.sh")
case $m in "$pA"|"$pC"|"$pE") ;; *) fail "cycle 2 merged '$m', not one of the passing fast-forwards A, C, E" ;; esac
for p in "$pA" "$pC" "$pE"; do
  [ "$p" = "$m" ] || [ "$(act 2 "$p")" = queued ] || fail "cycle 2: patch $p is $(act 2 "$p"), not queued behind $m"
done
[ "$(act 2 "$pB")$(act 2 "$pD")" = failfail ] || fail "cycle 2: B and D are not fail"
[ "$(tip)" = "$hm" ] || fail "cycle 2: rad/main is $(tip), not the merged head $hm"
tip_has_pass 2
[ "$(grep -c . "$rec")" -eq 5 ] || fail "cycle 2 gated a tree again"
pass "cycle 2: one fast-forward merge, of the first passing patch, to a tree that passed; nothing gated twice"

if sh "$T/c2/flow.sh" "$w" main "$rec" > "$T/stale.out" 2>&1; then fail "cycle 2's plan ran after rad/main moved"; fi
grep -q 'make a new plan' "$T/stale.out" || fail "the stale plan did not say why it refused"
pass "a plan made before rad/main moved refuses to run"

(cd "$w" && rad patch list --merged > "$T/merged" 2>&1) || fail "rad patch list --merged"
grep -q "$(printf '%s' "$m" | cut -c1-7)" "$T/merged" || fail "Radicle does not list the merged patch as merged"
pass "Radicle marks the merged patch merged"

cycle 3
[ "$(grep -c . "$rec")" -eq 5 ] || fail "cycle 3 gated a tree again"
for p in "$pA" "$pC" "$pE"; do
  [ "$p" = "$m" ] || [ "$(act 3 "$p")" = rebase ] || fail "cycle 3: patch $p is $(act 3 "$p"), not rebase"
done
grep -q '^fl_merge ' "$T/c3/flow.sh" && fail "cycle 3 planned a merge"
[ -z "$(act 3 "$m")" ] || fail "cycle 3 still lists the merged patch"
tip_has_pass 3
pass "cycle 3: no gate, no merge; the two passing patches left must rebase"
echo RC=0
