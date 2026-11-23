#!/bin/sh
# tests/flow/install.sh: tools/flow-install.sh against a throwaway seed, offline.
#
#   sh tests/flow/install.sh FLOW
#
# FLOW is a native planner built from tools/flow.om. Needs git, rad, git-remote-rad and bwrap; it
# makes a throwaway HOME, Radicle identity and repository under a temporary directory, so no node,
# network, unit or key of yours is touched; without them it prints NOT_RUN and exits 3. It checks:
# the installer refuses a non-Radicle ID, an identity that is not a delegate, and a REPO of another
# repository; installed (from the local storage, with rad checkout, systemctl not called), its
# first cycle gates the open patch and its units pass systemd-analyze verify when that runs here;
# installed again, it keeps the ledger and its cycle merges the patch; and a second cycle cannot
# start while one holds the ledger's lock. Each check prints PASS or FAIL; last line RC=0.
set -eu
[ $# -eq 1 ] || { echo 'usage: sh tests/flow/install.sh FLOW' >&2; exit 2; }
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
case $1 in /*) flow=$1 ;; *) flow=$(pwd)/$1 ;; esac
for c in git rad git-remote-rad bwrap; do
  command -v $c > /dev/null 2>&1 || { echo "NOT_RUN flow install: no $c"; exit 3; }
done
fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
T=$(mktemp -d)
if [ -n "${FLOW_E2E_KEEP:-}" ]; then echo "NOTE install directory $T"; else trap 'rm -rf "$T"' EXIT; fi
unset GIT_AUTHOR_DATE GIT_COMMITTER_DATE XDG_DATA_HOME XDG_CONFIG_HOME FLOW_HOME FLOW_DIR
export HOME="$T/home" RAD_HOME="$T/rad" RAD_PASSPHRASE=flow-install
[ "$(id -u)" != 0 ] || export FLOW_ALLOW_ROOT=1
mkdir -p "$HOME"
q() { "$@" > "$T/last.out" 2>&1 || { cat "$T/last.out" >&2; fail "$*"; }; }
q rad auth --alias flow-install
w=$T/src
git init -q -b main "$w"
g() { git -C "$w" "$@"; }
g config user.email install@flow.invalid
g config user.name flow-install
printf '#!/bin/sh\ngrep -qx good state\n' > "$w/build.sh"
echo good > "$w/state"
g add build.sh state
g commit -qm init
(cd "$w" && q rad init --name demo --description 'flow install' --default-branch main --public --no-confirm --no-seed)
rid=$(cd "$w" && rad .)
g checkout -qb change
echo more > "$w/more"
g add more
g commit -qm change
(cd "$w" && q git push rad HEAD:refs/patches -o patch.message=change)
g checkout -q main
inst() { sh "$R/tools/flow-install.sh" --flow "$flow" --no-systemd "$@"; }

if inst rad:notanid > "$T/o" 2>&1; then fail "the installer accepted rad:notanid"; fi
grep -q 'is not a Radicle ID' "$T/o" || fail "rad:notanid was refused for another reason: $(cat "$T/o")"
mkdir "$T/other"
(cd "$T/other" && git init -q -b main && git commit -q --allow-empty -m x 2> /dev/null || true)
if inst "$rid" "$T/other" > "$T/o" 2>&1; then fail "the installer accepted a REPO of no Radicle repository"; fi
grep -q "is not a working copy of $rid" "$T/o" || fail "the foreign REPO was refused for another reason: $(cat "$T/o")"
if RAD_HOME=$T/rad2 sh -c 'rad auth --alias stranger > /dev/null 2>&1 && exec "$@"' sh \
    sh "$R/tools/flow-install.sh" --flow "$flow" --no-systemd "$rid" "$w" > "$T/o" 2>&1; then
  fail "the installer accepted an identity that is not a delegate"
fi
grep -q 'is not a delegate' "$T/o" || fail "the stranger was refused for another reason: $(cat "$T/o")"
pass "the installer refuses a bad ID, a foreign REPO and an identity that is not a delegate"

inst --once "$rid" > "$T/o1" 2>&1 || { cat "$T/o1" >&2; fail "the first install failed"; }
H=$HOME/.local/share/flow
P=$H/${rid#rad:}
U=$HOME/.config/systemd/user
[ -x "$H/bin/flow" ] && [ -x "$H/bin/flow-cycle.sh" ] && [ -f "$H/bin/SOURCE" ] || fail "the planner was not installed"
cmp -s "$H/bin/flow" "$flow" || fail "the installed planner is not FLOW"
[ "$(cd "$P/repo" && rad .)" = "$rid" ] || fail "no working copy of $rid at $P/repo"
grep -q '^flow-install: first cycle: patches 1 merged 0 merge 0 queued 0 rebase 0 fail 0 gate 1 same 0$' "$T/o1" ||
  fail "the first cycle did not gate the one patch: $(tail -1 "$T/o1")"
[ "$(awk -F'\t' 'NR > 1 { print $3 }' "$P/receipts.tsv")" = pass ] || fail "the ledger has no single pass receipt"
pass "installed from the local storage; the first cycle gated the open patch, pass"

for u in service timer; do [ -f "$U/flow-${rid#rad:}.$u" ] || fail "no flow-${rid#rad:}.$u"; done
grep -qx "ExecStart=/bin/sh $H/bin/flow-cycle.sh $H/bin/flow $P/repo main $P/receipts.tsv" "$U/flow-${rid#rad:}.service" ||
  fail "the service does not run the installed cycle on $P/repo"
if command -v systemd-analyze > /dev/null 2>&1; then
  mkdir -m 700 "$T/run"
  rc=0; XDG_RUNTIME_DIR=$T/run systemd-analyze --user verify "$U/flow-${rid#rad:}.service" "$U/flow-${rid#rad:}.timer" > "$T/verify" 2>&1 || rc=$?
  grep -v 'bus' "$T/verify" > "$T/verify.warn" || true
  [ $rc -eq 0 ] && [ ! -s "$T/verify.warn" ] || { cat "$T/verify" >&2; fail "systemd-analyze --user verify rejects or warns about the units"; }
  pass "systemd-analyze --user verify accepts both units, without a warning"
else
  echo "NOTE NOT_RUN systemd-analyze verify: no systemd-analyze"
fi

exec 8>> "$P/receipts.tsv.lock"
if command -v flock > /dev/null 2>&1 && flock -n 8; then
  if sh "$H/bin/flow-cycle.sh" "$H/bin/flow" "$P/repo" main "$P/receipts.tsv" > "$T/o" 2>&1; then
    fail "a cycle ran while another held the ledger's lock"
  fi
  grep -q 'another cycle holds' "$T/o" || fail "the locked-out cycle failed for another reason: $(cat "$T/o")"
  flock -u 8
  pass "a cycle does not start while another holds the ledger's lock"
else
  echo "NOTE NOT_RUN flow lock: no flock"
fi
exec 8>&-

inst --once "$rid" > "$T/o2" 2>&1 || { cat "$T/o2" >&2; fail "the second install failed"; }
grep -q '^flow-install: first cycle: patches 1 merged 0 merge 1 queued 0 rebase 0 fail 0 gate 0 same 0$' "$T/o2" ||
  fail "after reinstalling, the cycle did not merge the gated patch: $(tail -1 "$T/o2")"
[ "$(grep -c . "$P/receipts.tsv")" -eq 2 ] || fail "reinstalling did not keep the ledger as it was"
[ "$(git -C "$P/repo" rev-parse refs/remotes/rad/main)" = "$(g rev-parse change)" ] || fail "rad/main is not the patch head"
pass "installed again: the ledger is kept, no tree is gated twice, and the cycle merged the patch"
echo RC=0
