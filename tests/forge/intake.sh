#!/bin/sh
# tests/forge/intake.sh: the Omega forge's web intake, tools/intake.om, served and spoken to over
# real TCP on the loopback interface.
#
#   sh tests/forge/intake.sh RUN
#
# RUN runs the server built from tools/intake.om (for the AArch64 build, a script that execs
# qemu-aarch64 on it). The client is tests/forge/intake/client.py, a test oracle: python3 is needed,
# without it the script prints NOT_RUN and exits 3. Everything lives in a temporary directory: a
# spool, an ALLOW file and a free port on 127.0.0.1; every server started here is stopped here.
#
# Checks, each printing PASS or FAIL (a FAIL stops the script with exit 1):
#   start: usage exit 2; one "intake:" line and exit 1 for a bad PORT, each malformed ALLOW,
#     a missing tmp/ or new/, and a port already taken
#   accepted forms: an issue, a comment, UTF-8 text, CR LF bodies, an issue with no body, the
#     size limits (title 200, body 60000 after CR LF becomes LF), any field order, case-insensitive
#     header names, a Content-Type with parameters, Expect: 100-continue; each record must equal
#     its tests/forge/intake/*.expect byte for byte except the id and time lines, and its id must
#     be the file name and the receipt on the reply page
#   refusals: every 400 rule (each page names its rule and never echoes the input), 404, 405 with
#     Allow, 411, 413, 503 with a full spool, and 408 for a client that stalls mid-header, while
#     the next client is still answered
#   after every request tmp/ is empty and every reply has Content-Length and Connection: close;
#     the log has one line per request and no peer address; the server is alive at the end
#   negative controls: a wrong expected record and a wrong expected reason must each fail
# Last line: RC=0 when every check passed.
set -eu
[ $# -eq 1 ] || { echo 'usage: sh tests/forge/intake.sh RUN' >&2; exit 2; }
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
case $1 in /*) run=$1 ;; *) run=$(pwd)/$1 ;; esac
command -v python3 > /dev/null 2>&1 || { echo 'NOT_RUN intake: no python3 for the test client'; exit 3; }
F=$R/tests/forge/intake
T=$(mktemp -d)
spid=
cleanup() {
  [ -z "$spid" ] || { kill "$spid" 2> /dev/null || true; wait "$spid" 2> /dev/null || true; }
  rm -rf "$T"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
export LC_ALL=C
umask 022

freeport() { python3 -I -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])'; }

# --- start-up refusals -------------------------------------------------------------------------
mkdir -p "$T/sp/tmp" "$T/sp/new" "$T/nonew/tmp" "$T/notmp/new"
cp "$F/allow" "$T/allow"
refuse() { # refuse NAME ARGS...: RUN ARGS must exit 1 with exactly one "intake:" line
  n=$1; shift
  rc=0; timeout 20 "$run" "$@" > "$T/out" 2> "$T/err" || rc=$?
  [ $rc -eq 1 ] || fail "start: $n exited $rc, not 1"
  [ "$(wc -l < "$T/err")" -eq 1 ] && grep -q '^intake: ' "$T/err" || fail "start: $n without one intake: line: $(cat "$T/err")"
  [ ! -s "$T/out" ] || fail "start: $n wrote to stdout"
}
rc=0; timeout 20 "$run" 1 2 > /dev/null 2> "$T/err" || rc=$?
[ $rc -eq 2 ] && grep -qx 'usage: intake PORT ALLOW SPOOL' "$T/err" || fail "start: two arguments exited $rc, not 2 with the usage line"
p=$(freeport)
refuse 'PORT 0' 0 "$T/allow" "$T/sp"
refuse 'PORT 65536' 65536 "$T/allow" "$T/sp"
refuse 'PORT x' 8x "$T/allow" "$T/sp"
refuse 'a missing ALLOW' "$p" "$T/none" "$T/sp"
: > "$T/a-empty"
printf 'rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj' > "$T/a-nonl"
printf 'rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj\r\n' > "$T/a-cr"
printf 'rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj\n\n' > "$T/a-blank"
printf 'rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj\nrad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQ0\n' > "$T/a-b58"
printf 'rad:zShort\n' > "$T/a-short"
printf 'z2JJz4RDfZZxKGBLn6UhmW5p9VJQj\n' > "$T/a-norad"
for a in empty nonl cr blank b58 short norad; do refuse "ALLOW $a" "$p" "$T/a-$a" "$T/sp"; done
refuse 'ALLOW with a non-base58 digit (line 2)' "$p" "$T/a-b58" "$T/sp"
grep -qx 'intake: ALLOW line 2: not a Radicle ID (rad:z and 20 to 60 base58 digits)' "$T/err" || fail "start: ALLOW b58 named $(cat "$T/err")"
refuse 'SPOOL without new/' "$p" "$T/allow" "$T/nonew"
grep -q '^intake: SPOOL has no directory new/: ' "$T/err" || fail "start: SPOOL without new/ said $(cat "$T/err")"
refuse 'SPOOL without tmp/' "$p" "$T/allow" "$T/notmp"
refuse 'a missing SPOOL' "$p" "$T/allow" "$T/nosuch"
pass "start: usage exits 2; bad PORTs, 8 malformed ALLOWs and 3 bad SPOOLs each refused with one intake: line"

# --- the server --------------------------------------------------------------------------------
port=$(freeport)
"$run" "$port" "$T/allow" "$T/sp" 2> "$T/log" &
spid=$!
i=0
until grep -q '^intake: ready port ' "$T/log" 2> /dev/null; do
  i=$((i + 1)); [ $i -lt 200 ] || fail "the server did not become ready: $(cat "$T/log")"
  kill -0 "$spid" 2> /dev/null || fail "the server exited: $(cat "$T/log")"
  sleep 0.05
done
grep -qx "intake: ready port $port allow 2" "$T/log" || fail "ready line: $(head -1 "$T/log")"
refuse 'a port already taken' "$port" "$T/allow" "$T/sp"
grep -qx "intake: cannot bind 127.0.0.1 port $port" "$T/err" || fail "start: taken port said $(cat "$T/err")"
pass "the server listens on 127.0.0.1:$port; a second server on the same port is refused"

nreq=0
RID1=rad%3Az2JJz4RDfZZxKGBLn6UhmW5p9VJQj
RID2=rad%3Az6do9WDBhuSnvopDkgFdFr1yWA62
TGT=0123456789abcdef0123456789abcdef01234567
CT=application/x-www-form-urlencoded

XH=
mkreq() { # mkreq BODY [CTYPE [PATH [METHOD]]]: a request with that body in $T/req; $XH, when set,
  # is one more header line (without its CR LF)
  b=$1; ct=${2:-$CT}; path=${3:-/forge/intake}; m=${4:-POST}
  n=$(printf '%s' "$b" | wc -c | tr -d ' ')
  {
    printf '%s %s HTTP/1.1\r\nHost: forge.test\r\n' "$m" "$path"
    [ -z "$XH" ] || printf '%s\r\n' "$XH"
    printf 'Content-Type: %s\r\nContent-Length: %s\r\n\r\n%s' "$ct" "$n" "$b"
  } > "$T/req"
}
send() { # send [expect]: send $T/req, reply in $T/resp, status line of the client in $got
  nreq=$((nreq + 1))
  got=$(python3 -I "$F/client.py" "$port" "$T/resp" "$@" < "$T/req")
  [ -z "$(ls -A "$T/sp/tmp")" ] || fail "request $nreq left $(ls "$T/sp/tmp") in tmp/"
}
expect() { # expect NAME CODE: the last reply must have status CODE, framed correctly
  [ "$got" = "$2" ] || fail "$1: got $got, want $2 ($(head -c 300 "$T/resp" | tr '\r\n' '  '))"
}
reason() { # reason NAME TEXT: the last reply page names TEXT
  grep -qF "<p>$2</p>" "$T/resp" || fail "$1: the page does not say: $2"
}
nnew() { ls "$T/sp/new" | wc -l | tr -d ' '; }
record() { # record NAME EXPECT: the one new record since the last call equals EXPECT except id and time
  new=$(ls "$T/sp/new" | sort > "$T/now"; comm -13 "$T/seen" "$T/now")
  [ "$(printf '%s\n' "$new" | grep -c .)" -eq 1 ] || fail "$1: want one new record, have: $new"
  cp "$T/now" "$T/seen"
  f=$T/sp/new/$new
  printf '%s\n' "$new" | grep -qx '[0-9a-f]\{32\}' || fail "$1: record name $new is not 32 hex digits"
  [ "$(sed -n 2p "$f")" = "id $new" ] || fail "$1: the id line is not the file name"
  grep -qF "<code>$new</code>" "$T/resp" || fail "$1: the reply does not name receipt $new"
  t=$(sed -n 6p "$f" | sed -n 's/^time \([0-9]\{1,\}\)$/\1/p')
  [ -n "$t" ] || fail "$1: no time line"
  now=$(date +%s); d=$((now - t))
  [ $d -ge 0 ] && [ $d -le 120 ] || fail "$1: time $t is $d s from now"
  sed -e '2s/^id [0-9a-f]\{32\}$/id ID/' -e '6s/^time [0-9]\{1,\}$/time TIME/' "$f" > "$T/rec"
  cmp -s "$T/rec" "$2" || fail "$1: the record differs from $(basename "$2")"
  [ "$(ls -l "$f" | cut -c1-10)" = '-rw-r-----' ] || fail "$1: record mode is $(ls -l "$f" | cut -c1-10), not -rw-r-----"
}
: > "$T/seen"

# --- accepted forms ----------------------------------------------------------------------------
mkreq "repo=$RID1&kind=issue&title=Hello+%3Cworld%3E+%26+%22you%22&body=line1%0Aline2%09tabbed&website=&unknown=zz"
send; expect issue 200; record issue "$F/issue.expect"
mkreq "repo=$RID2&kind=comment&target=$TGT&body=Thanks%21+Works+for+me.&title="
send; expect comment 200; record comment "$F/comment.expect"
grep -qF "issue-$TGT.html" "$T/resp" || fail "comment: the reply does not link the issue page"
mkreq "kind=issue&body=%E6%97%A5%E6%9C%AC%E8%AA%9E%0A%F0%9F%98%80&title=%C3%9Cn%C3%AFc%C3%B8d%C3%A9+%E2%9C%93+%F0%9F%9A%80&repo=$RID1"
send; expect utf8 200; record utf8 "$F/utf8.expect"
mkreq "repo=$RID1&kind=issue&title=crlf&body=a%0D%0Ab%0D%0A%0D%0Ac"
send; expect crlf 200; record crlf "$F/crlf.expect"
mkreq "repo=$RID1&kind=issue&title=No+body"
send; expect 'no body' 200; record 'no body' "$F/nobody.expect"
pass "accepted: issue, comment, UTF-8, CR LF, no body; each record matches its .expect, named by its receipt"

x200=$(head -c 200 /dev/zero | tr '\0' x)
a60k=$(head -c 60000 /dev/zero | tr '\0' a)
a59k=$(head -c 59999 /dev/zero | tr '\0' a)
mkreq "repo=$RID1&kind=issue&title=$x200&body=$a60k"
send; expect 'title 200 and body 60000' 200
mkreq "repo=$RID1&kind=comment&target=$TGT&body=$a59k%0D%0A"
send; expect 'comment body of 60001 bytes, 60000 after CR LF' 200
b="repo=$RID1&kind=issue&title=hd"
printf 'POST /forge/intake HTTP/1.1\r\nhost: forge.test\r\nCONTENT-TYPE: Application/X-WWW-Form-Urlencoded; charset=UTF-8\r\ncontent-length: \t %s  \r\n\r\n%s' "$(printf '%s' "$b" | wc -c | tr -d ' ')" "$b" > "$T/req"
send; expect 'header names in any case, Content-Type parameters, padded value' 200
XH='expect: 100-Continue'
mkreq "repo=$RID1&kind=issue&title=expect&body=$(head -c 3000 /dev/zero | tr '\0' b)"
XH=
send expect; expect 'Expect: 100-continue' 200
[ "$(nnew)" -eq 9 ] || fail "accepted: want 9 records, have $(nnew)"
pass "accepted: the size limits, header case and parameters, Expect: 100-continue (9 records)"

# --- refusals ----------------------------------------------------------------------------------
bad() { # bad NAME CODE REASON: send $T/req, which must be refused with CODE and REASON, writing nothing
  before=$(nnew)
  send "${4:-}"; expect "$1" "$2"; reason "$1" "$3"
  [ "$(nnew)" -eq "$before" ] || fail "$1: a record was written"
}
form() { mkreq "$2"; bad "$1" 400 "$3"; }
form 'unknown repository' "repo=rad%3Az2JJz4RDfZZxKGBLn6UhmW5p9VJQX&kind=issue&title=t" 'unknown repository'
form 'no repository' "kind=issue&title=t" 'unknown repository'
form 'kind bug' "repo=$RID1&kind=bug&title=t" 'kind must be issue or comment'
form 'no kind' "repo=$RID1&title=t" 'kind must be issue or comment'
form honeypot "repo=$RID1&kind=issue&title=t&website=http%3A%2F%2Fspam.example" 'form rejected'
form 'issue with a target' "repo=$RID1&kind=issue&title=t&target=$TGT" 'an issue takes no target'
form 'empty title' "repo=$RID1&kind=issue&title=&body=b" 'title must be 1 to 200 bytes'
form 'no title' "repo=$RID1&kind=issue&body=b" 'title must be 1 to 200 bytes'
form 'title 201' "repo=$RID1&kind=issue&title=${x200}y" 'title must be 1 to 200 bytes'
form 'TAB in the title' "repo=$RID1&kind=issue&title=a%09b" 'control character in the title'
form 'DEL in the title' "repo=$RID1&kind=issue&title=a%7Fb" 'control character in the title'
form 'LF in the title' "repo=$RID1&kind=issue&title=a%0Ab" 'control character in the title'
form 'bad continuation' "repo=$RID1&kind=issue&title=%C3%28" 'title is not UTF-8'
form 'overlong' "repo=$RID1&kind=issue&title=%C0%AF" 'title is not UTF-8'
form 'surrogate' "repo=$RID1&kind=issue&title=%ED%A0%80" 'title is not UTF-8'
form 'above U+10FFFF' "repo=$RID1&kind=issue&title=%F4%90%80%80" 'title is not UTF-8'
form 'truncated sequence' "repo=$RID1&kind=issue&title=ok%E2%9C" 'title is not UTF-8'
form 'body 60001' "repo=$RID1&kind=issue&title=t&body=${a60k}a" 'body over 60000 bytes'
form 'control byte in the body' "repo=$RID1&kind=issue&title=t&body=a%01b" 'control character in the body'
form 'lone CR in the body' "repo=$RID1&kind=issue&title=t&body=a%0Db" 'control character in the body'
form 'DEL in the body' "repo=$RID1&kind=issue&title=t&body=a%7F" 'control character in the body'
form 'body not UTF-8' "repo=$RID1&kind=issue&title=t&body=%FF" 'body is not UTF-8'
form 'comment target upper case' "repo=$RID1&kind=comment&target=0123456789ABCDEF0123456789abcdef01234567&body=b" 'target must be 40 lowercase hex digits'
form 'comment target 39' "repo=$RID1&kind=comment&target=0123456789abcdef0123456789abcdef0123456&body=b" 'target must be 40 lowercase hex digits'
form 'comment without target' "repo=$RID1&kind=comment&body=b" 'target must be 40 lowercase hex digits'
form 'comment with a title' "repo=$RID1&kind=comment&target=$TGT&title=x&body=b" 'a comment takes no title'
form 'comment with an empty body' "repo=$RID1&kind=comment&target=$TGT&body=" 'a comment body must be 1 to 60000 bytes'
form 'comment without a body' "repo=$RID1&kind=comment&target=$TGT" 'a comment body must be 1 to 60000 bytes'
form 'comment body a lone CR' "repo=$RID1&kind=comment&target=$TGT&body=%0D" 'control character in the body'
form 'repo twice' "repo=$RID1&repo=$RID1&kind=issue&title=t" 'a form field is given twice'
form 'website twice' "repo=$RID1&kind=issue&title=t&website=&website=" 'a form field is given twice'
form 'bad percent digit' "repo=$RID1&kind=issue&title=%G1" 'bad percent escape in the form'
form 'cut percent escape' "repo=$RID1&kind=issue&title=abc%4" 'bad percent escape in the form'
mkreq "repo=$RID1&kind=issue&title=%3Cscript%3Ealert(1)%3C%2Fscript%3E&kind=x"
bad 'no echo' 400 'a form field is given twice'
grep -qi 'script' "$T/resp" && fail 'no echo: the page echoes the input'
mkreq "repo=$RID1&kind=issue&title=t" text/plain
bad 'Content-Type text/plain' 400 'the form must be sent as application/x-www-form-urlencoded'
mkreq "repo=$RID1&kind=issue&title=t" application/x-www-form-urlencodedx
bad 'Content-Type with a longer name' 400 'the form must be sent as application/x-www-form-urlencoded'
printf 'POST /forge/intake HTTP/1.1\r\nHost: h\r\nContent-Length: 4\r\n\r\nab=c' > "$T/req"
bad 'no Content-Type' 400 'the form must be sent as application/x-www-form-urlencoded'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nContent-Type: %s\r\nContent-Length: 4\r\n\r\nab=c' $CT $CT > "$T/req"
bad 'Content-Type twice' 400 'Content-Type given twice'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nContent-Length: 4\r\nContent-Length: 4\r\n\r\nab=c' $CT > "$T/req"
bad 'Content-Length twice' 400 'Content-Length given twice'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nContent-Length: 4x\r\n\r\nab=c' $CT > "$T/req"
bad 'Content-Length 4x' 400 'Content-Length is not a number'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nNoColonHere\r\nContent-Length: 4\r\n\r\nab=c' $CT > "$T/req"
bad 'header line without a colon' 400 'malformed header line'
printf 'POST /forge/intake\r\nContent-Length: 0\r\n\r\n' > "$T/req"
bad 'request line of two words' 400 'malformed request line'
printf 'POST  /forge/intake HTTP/1.1\r\nContent-Length: 0\r\n\r\n' > "$T/req"
bad 'request line with two spaces' 400 'malformed request line'
printf 'POST /forge/intake HTTP/2.0\r\nContent-Length: 0\r\n\r\n' > "$T/req"
bad 'HTTP/2.0' 400 'only HTTP/1.1 and HTTP/1.0 are served'
{ printf 'POST /forge/intake HTTP/1.1\r\nX-Pad: '; head -c 8200 /dev/zero | tr '\0' p; printf '\r\n\r\n'; } > "$T/req"
bad 'header over 8192 bytes' 400 'request header over 8192 bytes'
printf 'GET / HTTP/1.1\r\nHost: h\r\n\r\n' > "$T/req"
bad 'GET /' 404 'no such page'
mkreq "repo=$RID1&kind=issue&title=t" "$CT" '/forge/intake?x=1'
bad 'a query string' 404 'no such page'
mkreq "repo=$RID1&kind=issue&title=t" "$CT" /forge/other
bad 'another path' 404 'no such page'
printf 'GET /forge/intake HTTP/1.1\r\nHost: h\r\n\r\n' > "$T/req"
bad 'GET /forge/intake' 405 'only POST is served here'
grep -q '^Allow: POST' "$T/resp" || fail '405: no Allow: POST header'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\n\r\nrepo=x' $CT > "$T/req"
bad 'no Content-Length' 411 'a Content-Length is required; chunked bodies are not taken'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nTransfer-Encoding: chunked\r\n\r\n6\r\nrepo=x\r\n0\r\n\r\n' $CT > "$T/req"
bad 'Transfer-Encoding chunked' 411 'a Content-Length is required; chunked bodies are not taken'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nContent-Length: 70000\r\n\r\n' $CT > "$T/req"
bad 'Content-Length 70000, no body sent' 413 'body over 65536 bytes'
{ printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nContent-Length: 65537\r\n\r\n' $CT; head -c 65537 /dev/zero | tr '\0' z; } > "$T/req"
bad 'a body of 65537 bytes sent' 413 'body over 65536 bytes'
printf 'POST /forge/intake HTTP/1.1\r\nContent-Type: %s\r\nContent-Length: 10\r\n\r\nrepo=' $CT > "$T/req"
bad 'a body cut short' 400 'the request ended early' half
pass "refused: every 400 rule (each page names its rule, none echoes the input), 404, 405 with Allow, 411, 413"

# 503: a full spool takes nothing, and a spool with room again takes the next form
i=0
while [ $i -lt 4087 ]; do : > "$T/sp/new/full$i"; i=$((i + 1)); done
[ "$(nnew)" -eq 4096 ] || fail "503: the spool holds $(nnew), not 4096"
mkreq "repo=$RID1&kind=issue&title=full"
bad 'a full spool' 503 'the spool is full'
rm -f "$T/sp/new/full0"
mkreq "repo=$RID1&kind=issue&title=No+body"
send; expect 'a spool with room again' 200
[ "$(nnew)" -eq 4096 ] || fail "503: the spool holds $(nnew) after one more form, not 4096"
rm -f "$T/sp/new"/full*
ls "$T/sp/new" | sort > "$T/seen"
pass "503: a spool of 4096 entries refuses a valid form; with one removed it takes it"

# 408: a client that stalls mid-header gets 408 within the deadline; the next client is answered
printf 'POST /forge/intake HTTP/1.1\r\nHost: slow\r\n' > "$T/slow"
t0=$(date +%s)
python3 -I "$F/client.py" "$port" "$T/slowresp" < "$T/slow" > "$T/slowgot" &
cpid=$!
sleep 1
mkreq "repo=$RID1&kind=issue&title=after+the+stall"
send; expect 'the client after a stalled one' 200
t1=$(date +%s)
wait $cpid || fail '408: the stalled client failed'
nreq=$((nreq + 1))
[ "$(cat "$T/slowgot")" = 408 ] || fail "408: the stalled client got $(cat "$T/slowgot")"
grep -qF '<p>no complete request within 10 seconds</p>' "$T/slowresp" || fail '408: the page does not name the deadline'
[ $((t1 - t0)) -ge 8 ] && [ $((t1 - t0)) -le 20 ] || fail "408: the next client was answered after $((t1 - t0)) s"
pass "408: a stalled client is cut off at 10 s ($((t1 - t0)) s), and the next one is answered"

# --- the log, liveness -------------------------------------------------------------------------
mkreq "repo=$RID2&kind=issue&title=last"
send; expect 'the last request' 200
kill -0 "$spid" 2> /dev/null || fail 'the server is not alive at the end'
n=$(grep -c '^intake: [0-9][0-9][0-9] ' "$T/log")
[ "$n" -eq "$nreq" ] || fail "log: $n request lines for $nreq requests"
[ "$(grep -vc '^intake: ' "$T/log")" -eq 0 ] || fail 'log: a line without the intake: prefix'
grep -q '127\.0\.0\.1' "$T/log" && fail 'log: it names a peer address'
[ "$(grep -c '^intake: 500 ' "$T/log")" -eq 0 ] || fail "log: a handler stopped: $(grep '^intake: 500 ' "$T/log")"
pass "log: one line per request ($nreq), no peer address, no handler stopped; the server is alive"

# --- negative controls -------------------------------------------------------------------------
# each wrong expectation must fail on the same reply that its right one passes
ls "$T/sp/new" | sort > "$T/seen"
mkreq "repo=$RID1&kind=issue&title=Hello+%3Cworld%3E+%26+%22you%22&body=line1%0Aline2%09tabbed"
send; expect 'control request' 200
cp "$T/seen" "$T/seen.0"
sed 's/^title Hello/title Hallo/' "$F/issue.expect" > "$T/wrong.expect"
if (record 'wrong record' "$T/wrong.expect") > /dev/null 2>&1; then fail 'negative control: a wrong expected record passed'; fi
cp "$T/seen.0" "$T/seen"
record 'control record' "$F/issue.expect"
mkreq "repo=$RID1&kind=bug"
send; expect 'control refusal' 400
if (reason 'wrong reason' 'unknown repository') > /dev/null 2>&1; then fail 'negative control: a wrong expected reason passed'; fi
reason 'control refusal' 'kind must be issue or comment'
pass 'negative controls: a wrong expected record and a wrong expected reason each fail'

kill "$spid"; wait "$spid" 2> /dev/null || true; spid=
echo RC=0
