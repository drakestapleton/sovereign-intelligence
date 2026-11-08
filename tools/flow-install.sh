#!/bin/sh
# flow-install.sh: deploy the Omega merge queue for one Radicle repository on this seed.
#
#   sh tools/flow-install.sh [--flow BIN] [--no-systemd] [--once] RID [REPO]
#
# Run it from a checkout of sovereign-intelligence on the seed, as the user whose Radicle key is a
# delegate of RID (never as root). It:
#   1. checks git, rad, git-remote-rad, bwrap (and that bwrap can make a sandbox), the Radicle
#      identity, and that this identity is one of RID's delegates;
#   2. builds the planner from the seed with build.sh, which must end RC=0, and installs the
#      native build (out/flow-a64 on AArch64, out/flow-x86 on x86-64) with tools/flow-cycle.sh;
#      --flow BIN installs BIN instead and skips the build;
#   3. makes the working copy REPO (default FLOW_HOME/ID/repo, checked out from the local Radicle
#      storage with rad checkout, so the repository must already be seeded here) and the receipt
#      ledger FLOW_HOME/ID/receipts.tsv;
#   4. writes the systemd user units flow-ID.service (one cycle) and flow-ID.timer (a cycle 15 s
#      after the last one ended), and enables the timer; --no-systemd writes them without
#      calling systemctl;
#   5. with --once, runs one cycle now and prints its plan counts.
# ID is RID without "rad:". FLOW_HOME defaults to ${XDG_DATA_HOME:-$HOME/.local/share}/flow; units
# go to ${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user. Each cycle's facts and plan stay in
# FLOW_HOME/ID/last. If the Radicle key has a passphrase, put RAD_PASSPHRASE=... in
# FLOW_HOME/ID/secret.env, mode 0600; the service reads it, and the gate's sandbox never sees it.
# Run it again to upgrade: the planner and units are replaced, the ledger and REPO are kept.
# FLOW_ALLOW_ROOT=1 lets it run as root, for a disposable test container only, never on a seed.
# Exit status: 0 installed; 1 a check or step failed (one "flow-install:" line says which); 2 usage.
set -eu
umask 077
say() { printf 'flow-install: %s\n' "$*"; }
die() { printf 'flow-install: %s\n' "$*" >&2; exit 1; }
usage() { echo 'usage: sh tools/flow-install.sh [--flow BIN] [--no-systemd] [--once] RID [REPO]' >&2; exit 2; }
SI=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
bin= sysd=1 once=0
while [ $# -gt 0 ]; do
  case $1 in
    --flow) [ $# -ge 2 ] || usage; bin=$2; shift 2 ;;
    --no-systemd) sysd=0; shift ;;
    --once) once=1; shift ;;
    -*) usage ;;
    *) break ;;
  esac
done
[ $# -eq 1 ] || [ $# -eq 2 ] || usage
rid=$1
case $rid in rad:z*) ;; *) die "$rid is not a Radicle ID (rad:z...)" ;; esac
id=${rid#rad:}
case $id in *[!0-9A-Za-z]*) die "$rid is not a Radicle ID" ;; esac

# 1. checks
[ "$(id -u)" != 0 ] || [ "${FLOW_ALLOW_ROOT:-}" = 1 ] || die "refusing to run as root; run it as the delegate's own user"
for c in git rad git-remote-rad bwrap sha256sum; do
  command -v $c > /dev/null 2>&1 || die "$c is required"
done
bwrap --ro-bind / / --unshare-all --die-with-parent true 2> /dev/null ||
  die "bwrap cannot make a sandbox here (unprivileged user namespaces off?); gates must not run without one"
me=$(rad self --did 2> /dev/null) || die "no Radicle identity: run rad auth"
case $(uname -m) in
  aarch64|arm64) t=a64 ;;
  x86_64|amd64) t=x86 ;;
  *) die "host $(uname -m): the planner is built for AArch64 and x86-64 only" ;;
esac
H=${FLOW_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/flow}
P=$H/$id
mkdir -p "$H/bin" "$P/last"

# 2. the planner, from the seed
if [ -z "$bin" ]; then
  say "building the planner from the seed: sh build.sh (log $P/build.log)"
  sh "$SI/build.sh" > "$P/build.log" 2>&1 || die "build.sh failed: $(grep '^FAIL' "$P/build.log" | head -1)"
  [ "$(tail -1 "$P/build.log")" = RC=0 ] || die "build.sh did not end RC=0; see $P/build.log"
  bin=$SI/out/flow-$t
fi
[ -x "$bin" ] || die "no planner at $bin"
cp "$bin" "$H/bin/flow.new" && mv "$H/bin/flow.new" "$H/bin/flow"
cp "$SI/tools/flow-cycle.sh" "$H/bin/flow-cycle.sh.new" && mv "$H/bin/flow-cycle.sh.new" "$H/bin/flow-cycle.sh"
chmod 755 "$H/bin/flow" "$H/bin/flow-cycle.sh"
src=$(git -C "$SI" rev-parse HEAD 2> /dev/null || echo unknown)
printf 'si\t%s\nflow\t%s\nflow-cycle.sh\t%s\n' "$src" "$(sha256sum < "$H/bin/flow" | cut -c1-64)" \
  "$(sha256sum < "$H/bin/flow-cycle.sh" | cut -c1-64)" > "$H/bin/SOURCE"

# 3. the working copy and the ledger
if [ $# -eq 2 ]; then
  case $2 in /*) repo=$2 ;; *) repo=$(pwd)/$2 ;; esac
else
  repo=$P/repo
  if [ ! -d "$repo/.git" ]; then
    rm -rf "$P/co"
    mkdir "$P/co"
    (cd "$P/co" && rad checkout "$rid" > /dev/null 2>&1) ||
      die "rad checkout $rid failed: the repository must be in this seed's storage (rad seed $rid)"
    set -- "$P/co"/*
    [ $# -eq 1 ] && [ -d "$1/.git" ] || die "rad checkout $rid did not make one working copy"
    mv "$1" "$repo"
    rmdir "$P/co"
  fi
fi
[ "$(cd "$repo" && rad . 2> /dev/null)" = "$rid" ] || die "$repo is not a working copy of $rid"
(cd "$repo" && rad inspect --delegates 2> /dev/null) | grep -q "^$me\\( \\|\$\\)" ||
  die "$me is not a delegate of $rid; only a delegate's merges are canonical"
def=$(cd "$repo" && rad inspect --payload 2> /dev/null | sed -n 's/^ *"defaultBranch": *"\([^"]*\)".*/\1/p' | head -1)
[ -n "$def" ] || die "cannot read $rid's default branch from rad inspect --payload"
case $def in *[!0-9A-Za-z._/-]*) die "default branch '$def' has characters the units cannot carry" ;; esac
git -C "$repo" fetch -q rad || die "cannot fetch rad in $repo"
git -C "$repo" rev-parse --verify -q "refs/remotes/rad/$def:build.sh" > /dev/null ||
  die "$rid's $def has no build.sh: flow gates with it"
rec=$P/receipts.tsv
[ -f "$rec" ] || printf 'tree\tgate\tverdict\tlog\n' > "$rec"

# 4. the units
U=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user
mkdir -p "$U"
for v in "$H" "$repo" "$PATH" "${RAD_HOME:-}"; do
  case $v in *[!0-9A-Za-z._/:+-]*) die "a path or PATH entry has characters the units cannot carry: $v" ;; esac
done
{
  printf '[Unit]\nDescription=Omega flow merge queue: one cycle for %s\n' "$rid"
  printf 'Documentation=file:%s/tools/FLOW.md\n\n' "$SI"
  printf '[Service]\nType=oneshot\nNice=10\n'
  printf 'Environment=PATH=%s\n' "$PATH"
  [ -z "${RAD_HOME:-}" ] || printf 'Environment=RAD_HOME=%s\n' "$RAD_HOME"
  printf 'Environment=FLOW_DIR=%s/last\n' "$P"
  printf 'EnvironmentFile=-%s/secret.env\n' "$P"
  printf 'ExecStart=/bin/sh %s/bin/flow-cycle.sh %s/bin/flow %s %s %s\n' "$H" "$H" "$repo" "$def" "$rec"
} > "$U/flow-$id.service"
{
  printf '[Unit]\nDescription=Omega flow merge queue for %s, every 15 s\n\n' "$rid"
  printf '[Timer]\nOnActiveSec=5s\nOnUnitInactiveSec=15s\nAccuracySec=1s\nUnit=flow-%s.service\n\n' "$id"
  printf '[Install]\nWantedBy=timers.target\n'
} > "$U/flow-$id.timer"
if [ $sysd = 1 ]; then
  command -v systemctl > /dev/null 2>&1 || die "no systemctl: run --no-systemd and start the cycle another way"
  systemctl --user daemon-reload || die "systemctl --user daemon-reload failed"
  systemctl --user enable --now "flow-$id.timer" > /dev/null 2>&1 || die "cannot enable flow-$id.timer"
  if [ "$(loginctl show-user "$(id -un)" -p Linger --value 2> /dev/null)" != yes ]; then
    say "NOTE the timer stops at logout until lingering is on: sudo loginctl enable-linger $(id -un)"
  fi
  say "enabled flow-$id.timer; watch it with: journalctl --user -u flow-$id.service -f"
else
  say "wrote $U/flow-$id.service and .timer; systemctl was not called (--no-systemd)"
fi
say "installed: planner $H/bin/flow, $repo on $def, ledger $rec"

# 5. one cycle now
if [ $once = 1 ]; then
  FLOW_DIR=$P/last sh "$H/bin/flow-cycle.sh" "$H/bin/flow" "$repo" "$def" "$rec" || die "the first cycle failed"
  say "first cycle: $(sed -n 's/^# plan-counts //p' "$P/last/flow.sh")"
fi
