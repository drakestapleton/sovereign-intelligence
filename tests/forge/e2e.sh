#!/bin/sh
# tests/forge/e2e.sh: a whole cycle of the Omega forge against real Radicle nodes, offline.
#
#   sh tests/forge/e2e.sh FORGE TALLY INTAKE
#
# FORGE, TALLY and INTAKE run the programs built from tools/forge.om, tools/tally.om and
# tools/intake.om. Needs git, rad, radicle-node, git-remote-rad and curl; without one it prints
# NOT_RUN and exits 3. Everything lives under a temporary directory with its own RAD_HOMEs and
# loopback ports, so no node, network or key of yours is touched.
#
# A seed node holds a project with one issue and one patch. A second node clones it with rad
# clone, so the seed's own log records a real Radicle pull. People without Radicle use the intake:
# one opens an issue and one comments, through HTTP form posts, each text starting with "-" (which
# rad would read as an option if it were passed as a separate argument). The web server's log is stood in
# for by three nginx lines. Then tools/forge-cycle.sh runs twice with the same logs. Checks:
#   - intake answers 200 with a receipt for each good post, 400 for a project outside ALLOW
#   - cycle 1 publishes both posts as Radicle objects signed by the seed (the issue labelled web),
#     empties spool/new, counts 3 HTTPS pulls from 2 hosts and 1 Radicle pull from 1 peer, and
#     serves a site where the new issue's page escapes its title; the oracle accepts the site
#   - cycle 2, with the same logs, changes no count (a day is replaced, never added twice),
#     publishes nothing, switches WEB to a new build and removes the previous one
#   - a spool record naming a project outside ALLOW (withdrawn after the post) is set aside in
#     spool/failed with its reason, unpublished, and the cycle goes on
# Each check prints PASS or FAIL; the last line is RC=0.
set -eu
[ $# -eq 3 ] || { echo 'usage: sh tests/forge/e2e.sh FORGE TALLY INTAKE' >&2; exit 2; }
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
abs() { case $1 in /*) printf '%s' "$1" ;; *) printf '%s/%s' "$(pwd)" "$1" ;; esac; }
forge=$(abs "$1") tally=$(abs "$2") intake=$(abs "$3")
for c in git rad radicle-node git-remote-rad curl; do
  command -v $c > /dev/null 2>&1 || { echo "NOT_RUN forge e2e: no $c"; exit 3; }
done
fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
T=$(mktemp -d)
S=$T/seed P=$T/peer
ipid=
stop() {
  [ -z "$ipid" ] || kill "$ipid" 2> /dev/null || true
  RAD_HOME=$S rad node stop > /dev/null 2>&1 || true
  RAD_HOME=$P rad node stop > /dev/null 2>&1 || true
}
if [ -n "${FORGE_E2E_KEEP:-}" ]; then trap 'stop; echo "NOTE e2e directory $T"' EXIT
else trap 'stop; rm -rf "$T"' EXIT; fi
export RAD_PASSPHRASE=forge-e2e
unset GIT_AUTHOR_DATE GIT_COMMITTER_DATE
q() { "$@" > "$T/last.out" 2>&1 || { cat "$T/last.out" >&2; fail "$*"; }; }
base=$(( $$ % 20000 + 30000 ))
ps=$base pp=$((base + 1)) pi=$((base + 2))

# The seed: an identity, a project with an issue and a patch, a node.
export RAD_HOME=$S
q rad auth --alias seed
w=$T/demo
git init -q -b main "$w"
git -C "$w" config user.email e2e@forge.invalid
git -C "$w" config user.name forge-e2e
echo one > "$w/a"
git -C "$w" add a
git -C "$w" commit -qm init
(cd "$w" && q rad init --name demo --description 'forge e2e' --default-branch main --public --no-confirm --no-seed)
rid=$(cd "$w" && rad .)
z=${rid#rad:}
q rad seed "$rid" --scope all
(cd "$w" && q rad issue open --title 'First issue' --description 'opened with rad' --no-announce)
first=$(rad cob list --repo "$rid" --type xyz.radicle.issue)
git -C "$w" checkout -q -b change
echo two >> "$w/a"
git -C "$w" commit -qam 'a second line'
(cd "$w" && q git push rad HEAD:refs/patches -o patch.message='A second line')
git -C "$w" checkout -q main
nid=$(rad node status --only nid 2> /dev/null || rad self --nid 2> /dev/null)
radicle-node --listen "127.0.0.1:$ps" > "$T/node.log" 2>&1 &

# The peer clones the project from the seed: a real Radicle pull.
RAD_HOME=$P q rad auth --alias peer
RAD_HOME=$P radicle-node --listen "127.0.0.1:$pp" > "$T/peer.log" 2>&1 &
i=0
until RAD_HOME=$P rad node connect "$nid@127.0.0.1:$ps" > /dev/null 2>&1; do
  i=$((i + 1)); [ $i -lt 30 ] || fail "the peer cannot connect to the seed"; sleep 1
done
(cd "$T" && RAD_HOME=$P q rad clone "$rid" clone --seed "$nid")
i=0
until grep -q "fetched $rid from us successfully" "$T/node.log"; do
  i=$((i + 1)); [ $i -lt 30 ] || fail "the seed's log has no pull"; sleep 1
done
pass "the peer cloned $rid from the seed, and the seed's log records it"

# The intake, and two posts from people without Radicle.
st=$T/state
mkdir -p "$st/spool/tmp" "$st/spool/new" "$st/spool/done"
printf '%s\n' "$rid" > "$T/allow"
"$intake" "$pi" "$T/allow" "$st/spool" 2> "$T/intake.log" &
ipid=$!
i=0
until curl -s -o /dev/null "http://127.0.0.1:$pi/"; do
  i=$((i + 1)); [ $i -lt 50 ] || fail "intake does not listen on $pi: $(cat "$T/intake.log")"; sleep 0.2
done
post() { # post FORMDATA...: print the status code
  curl -s -o "$T/reply" -w '%{http_code}' "http://127.0.0.1:$pi/forge/intake" "$@"
}
c=$(post --data-urlencode "repo=$rid" -d kind=issue --data-urlencode 'title=-from the web <b>&' --data-urlencode 'body=Seen on the site.
Second line.')
[ "$c" = 200 ] || fail "intake answered $c to a good issue"
c=$(post --data-urlencode "repo=$rid" -d kind=comment -d "target=$first" --data-urlencode 'body=- a comment from the web')
[ "$c" = 200 ] || fail "intake answered $c to a good comment"
c=$(post -d repo=rad:z2ZMLsS8pmAVkrR6y63wD6jtdy1bg -d kind=issue -d title=x -d body=y)
[ "$c" = 400 ] || fail "intake answered $c, not 400, for a project outside ALLOW"
[ "$(ls "$st/spool/new" | wc -l | tr -d ' ')" -eq 2 ] || fail "spool/new does not hold the 2 posts"
pass "intake spooled an issue and a comment, and refused a project outside ALLOW"

# The web server's log, as nginx writes it.
now=$(date -u +%d/%b/%Y:%H:%M:%S)
day=$(date -u +%Y-%m-%d)
for h in 192.0.2.7 192.0.2.7 2001:db8::1; do
  printf '%s - - [%s +0000] "GET /rad/%s.git/info/refs?service=git-upload-pack HTTP/1.1" 200 412 "-" "git/2.43.0"\n' "$h" "$now" "$z"
done > "$T/access.log"
printf '198.51.100.9 - - [%s +0000] "GET /rad/%s.git/info/refs?service=git-receive-pack HTTP/1.1" 403 0 "-" "git/2.43.0"\n' "$now" "$z" >> "$T/access.log"

cycle() { FORGE_DAY=$day FORGE_ANNOUNCE=0 sh "$R/tools/forge-cycle.sh" "$forge" "$tally" "$T/allow" "$st" "$T/web" "$T/access.log" "$T/node.log"; }
cycle > "$T/c1.log" 2>&1 || { cat "$T/c1.log"; fail "cycle 1"; }
[ -z "$(ls "$st/spool/new")" ] && [ "$(ls "$st/spool/done" | wc -l | tr -d ' ')" -eq 2 ] || fail "cycle 1 left the spool $(ls "$st/spool/new")"
rad cob list --repo "$rid" --type xyz.radicle.issue > "$T/ids"
[ "$(wc -l < "$T/ids" | tr -d ' ')" -eq 2 ] || fail "the seed holds $(wc -l < "$T/ids") issues, not 2"
web=
for x in $(cat "$T/ids"); do
  rad cob show --repo "$rid" --type xyz.radicle.issue --object "$x" > "$T/j"
  if grep -q '"title":"-from the web <b>&"' "$T/j"; then web=$x; fi
done
[ -n "$web" ] || fail "no Radicle issue titled -from the web <b>&"
rad cob show --repo "$rid" --type xyz.radicle.issue --object "$web" | grep -q '"labels":\["web"\]' || fail "the web issue is not labelled web"
rad cob show --repo "$rid" --type xyz.radicle.issue --object "$first" | grep -q -- '- a comment from the web' || fail "the web comment is not on the first issue"
pass "cycle 1 published the web issue (labelled web) and the web comment, both starting with -, signed by the seed"

row=$(awk -F'\t' -v r="$rid" '$1 == r' "$T/web/stats.tsv")
want=$(printf '%s\t4\t3\t1\t4\t' "$rid")
case $row in "$want"*) ;; *) fail "stats.tsv: '$row', want '$want...'";; esac
case $row in *"	2	2	1	1") ;; *) fail "stats.tsv: '$row', want 2 open issues of 2 and 1 open patch of 1";; esac
grep -qx "$(printf '%s\t%s\t3\t2\t1\t1' "$rid" "$day")" "$st/ledger.tsv" || fail "ledger: $(cat "$st/ledger.tsv")"
grep -q -- '-from the web &lt;b&gt;&amp;' "$T/web/$z/issue-$web.html" || fail "the web issue's page does not escape its title"
if command -v python3 > /dev/null 2>&1; then
  o=$(python3 -I "$R/tests/forge/oracle.py" "$st/facts.tsv" "$st/ledger.tsv" "$day" "$T/web") || fail "oracle on the site: $o"
  pass "the site counts 3 HTTPS pulls from 2 hosts and 1 Radicle pull from 1 peer; $o"
else
  pass "the site counts 3 HTTPS pulls from 2 hosts and 1 Radicle pull from 1 peer (oracle NOT_RUN: no python3)"
fi

b1=$(readlink "$T/web")
cp "$st/ledger.tsv" "$T/ledger1"
cp "$T/web/stats.tsv" "$T/stats1"
sleep 1
cycle > "$T/c2.log" 2>&1 || { cat "$T/c2.log"; fail "cycle 2"; }
cmp -s "$st/ledger.tsv" "$T/ledger1" || fail "cycle 2 changed the ledger with the same logs"
cmp -s "$T/web/stats.tsv" "$T/stats1" || fail "cycle 2 changed stats.tsv"
! grep -q published "$T/c2.log" || fail "cycle 2 published again"
b2=$(readlink "$T/web")
[ "$b1" != "$b2" ] && [ ! -e "$T/$b1" ] && [ -d "$T/$b2" ] || fail "WEB did not switch from $b1 to $b2 and remove $b1"
pass "cycle 2 with the same logs counts nothing twice, publishes nothing, and switches WEB atomically"

x=0123456789abcdef0123456789abcdef
printf 'forge-intake 1\nid %s\nrepo rad:z2ZMLsS8pmAVkrR6y63wD6jtdy1bg\nkind issue\ntarget -\ntime 0\ntitle x\nbody 1\ny' "$x" > "$st/spool/new/$x"
cycle > "$T/c3.log" 2>&1 || { cat "$T/c3.log"; fail "cycle 3 stopped on a record for a project outside ALLOW"; }
[ -f "$st/spool/failed/$x" ] && grep -q 'is not in' "$st/spool/failed/$x.why" || fail "the record for a project outside ALLOW is not in spool/failed with its reason"
[ -z "$(ls "$st/spool/new")" ] || fail "cycle 3 left spool/new $(ls "$st/spool/new")"
[ "$(rad cob list --repo "$rid" --type xyz.radicle.issue | wc -l | tr -d ' ')" -eq 2 ] || fail "cycle 3 published the record"
[ "$(readlink "$T/web")" != "$b2" ] || fail "cycle 3 did not build the site"
pass "a spool record for a project outside ALLOW goes to spool/failed with its reason; the cycle and the site go on"
echo RC=0
