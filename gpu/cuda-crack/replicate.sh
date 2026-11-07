#!/bin/sh
# replicate.sh: reproduce the GB10 / Omega / CUDA++ host work from Radicle in a clean userspace.
#
#   curl -fsSL https://www.aienos.com/replicate | sh                  # run every host step of AGENT-PROMPT.md
#   curl -fsSL https://www.aienos.com/replicate | sh -s -- --agent    # let YOUR OWN local model drive it
#
# The steps are the ones in AGENT-PROMPT.md (cuda-crack, rad:z631r2JJiVT8it4tST7RK24hpowi), served as
# text at https://www.aienos.com/agent-prompt. Every repository is cloned from Radicle over git+HTTPS:
# https://www.aienos.com/rad/<RID>.git first, then https://rosa.radicle.network/<RID>.git.
#
# Options:
#   --chip          also run section 7 on a GB10 (checks the driver is 580.173.02 and asks y/N first; off by default)
#   --corpus        also run step 5.2 (the full kernel corpus, three builds; long on one core; off by default)
#   --agent         a local model proposes one shell command per turn; you approve each with y
#   --yes           with --agent: run without asking only commands on a fixed allow-list (make <replication
#                   target>, sh seed/omega-from-seed.sh, sha256sum, git log/show/rev-parse, ls/cat/head/wc/grep -n
#                   on workspace paths, uname -sm, nproc, free; optionally after cd $R/<repo> &&); every other
#                   command asks you, never chip steps, never sudo
#   --turns N       with --agent: stop after N turns, 1 to 200 (default 40)
#   -h, --help      this text
# Environment:
#   AIEN_MODEL_URL  OpenAI-compatible base URL for --agent (e.g. http://127.0.0.1:11434/v1)
#   AIEN_MODEL      model id for --agent (default: the first one /models lists)
#   AIEN_RAD_HTTP   first git+HTTPS Radicle seed (default https://www.aienos.com/rad)
#   AIEN_RAD_HTTP2  second git+HTTPS Radicle seed (default https://rosa.radicle.network)
#
# What it does: refuses root; makes a fresh workspace $HOME/aien-replicate-<UTC>; re-runs itself under
# `env -i HOME=<workspace> PATH=/usr/bin:/bin LC_ALL=C`, so no CUDA toolkit, nvcc or personal tools are on
# PATH; runs each step in a new clean shell; prints PASS/FAIL/NOT_RUN per step; writes RUNLOG.md and
# summary.tsv in the workspace. Exit 0 only when every required step passed. NOT_RUN is not PASS.
# It never uses sudo, never changes clocks, power or thermal settings, and writes only inside the workspace.
#
# Host dependencies (Drake's rule: every non-Omega piece in the path is recorded with its Omega replacement):
#   POSIX sh, git, make, gcc, coreutils, diffutils, sed, grep, awk, bash, curl: the steps of AGENT-PROMPT.md
#     themselves need them (gcc builds CUDApp's C parts; bash runs one CUDApp test). Replacement: the
#     steps move to Omega as CUDApp and the bridge do.
#   python3 (only --agent): JSON and HTTP for the chat loop. Replacement (follow-up, not done): an Omega
#     agent loop (JSON codec + HTTP client in .om, emitted through omega-bridge or the seeded omc).
set -u

if [ "$(id -u)" = 0 ]; then
	echo "replicate: refusing to run as root. Run it as an ordinary user; it never needs sudo." >&2
	exit 2
fi
prev=
for a in "$@"; do
	if [ "$prev" = --turns ]; then
		case $a in [1-9]|[1-9][0-9]|1[0-9][0-9]|200) ;; *) echo "replicate: --turns needs an integer from 1 to 200" >&2; exit 2 ;; esac
	fi
	prev=$a
	case $a in -h|--help) cat <<'HELP_EOF'
replicate: reproduce the GB10 / Omega / CUDA++ host work from Radicle in a clean userspace.
  curl -fsSL https://www.aienos.com/replicate | sh                  every host step of AGENT-PROMPT.md
  curl -fsSL https://www.aienos.com/replicate | sh -s -- --agent    your own local model drives it
Options: --chip (section 7 on a GB10, asks y/N first)  --corpus (step 5.2, long)
         --agent  --yes (auto-approve allow-listed agent commands; never chip steps)  --turns N (1-200, default 40)
Environment: AIEN_MODEL_URL, AIEN_MODEL (for --agent), AIEN_RAD_HTTP, AIEN_RAD_HTTP2 (git+HTTPS seeds)
  e.g. curl -fsSL https://www.aienos.com/replicate | AIEN_MODEL_URL=http://127.0.0.1:11434/v1 sh -s -- --agent
Steps: https://www.aienos.com/agent-prompt
HELP_EOF
	exit 0 ;; esac
done

ws_ts=$(date -u +%Y%m%dT%H%M%SZ)
WS="$HOME/aien-replicate-$ws_ts"
[ -e "$WS" ] && WS="$WS-$$"
mkdir -p "$WS" || { echo "replicate: cannot create $WS" >&2; exit 2; }
echo "replicate: workspace $WS"

cat > "$WS/replicate-inner.sh" <<'INNER_EOF'
# replicate-inner.sh: written by replicate.sh into the workspace and run under env -i. Do not edit.
set -u
WS=$HOME
R=$WS/replica
WSD="~/${WS##*/}"
export R
RAD_HTTP=${AIEN_RAD_HTTP:-https://www.aienos.com/rad}
RAD_HTTP2=${AIEN_RAD_HTTP2:-https://rosa.radicle.network}
CRACK_RID=z631r2JJiVT8it4tST7RK24hpowi
PROMPT_PIN=7ad53bab4cbc120b690fd2ca42fbcc5e25c476c9
HARNESS_RID=z39gvwWsnkRZsAConQLjaKiNVLHfW
HARNESS_PIN=c38640db4fe8ee49eff589123415d4a1ba80567a

chip=0 corpus=0 agent=0 yes=0 turns=40
while [ $# -gt 0 ]; do
	case $1 in
	--chip) chip=1 ;;
	--corpus) corpus=1 ;;
	--agent) agent=1 ;;
	--yes) yes=1 ;;
	--turns) shift; turns=${1:-}
		case $turns in [1-9]|[1-9][0-9]|1[0-9][0-9]|200) ;; *) echo "replicate: --turns needs an integer from 1 to 200"; exit 2 ;; esac ;;
	*) echo "replicate: unknown option $1 (try --help)"; exit 2 ;;
	esac
	shift
done

say() { printf '%s\n' "$*"; }
TTY=""
if ( : </dev/tty ) 2>/dev/null; then TTY=/dev/tty; fi
ask() { # question -> 0 when the human typed y
	if [ -z "$TTY" ]; then say "$1 [y/N] (no terminal to ask on: N)"; return 1; fi
	printf '%s [y/N] ' "$1" >"$TTY"
	read -r ans <"$TTY" || return 1
	case $ans in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

mkdir -p "$WS/logs"
LOG=$WS/RUNLOG.md
SUM=$WS/summary.tsv
: > "$SUM"
self_sha=$(sha256sum "$WS/replicate-inner.sh" | cut -c1-64)
{
	say "# RUNLOG: replicate.sh"
	say ""
	say "- Date (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
	say "- Host: $(uname -srm)"
	say "- Workspace: $WSD (HOME inside the run)"
	say "- Environment of every step: env -i HOME=$WSD PATH=/usr/bin:/bin R=$WSD/replica LC_ALL=C sh -c '<command>'"
	say "- Seeds: $RAD_HTTP, then $RAD_HTTP2"
	say "- Steps: AGENT-PROMPT.md at cuda-crack $PROMPT_PIN (rad:$CRACK_RID)"
	say "- replicate-inner.sh sha256 $self_sha"
	say ""
} > "$LOG"

# ---- 1. preflight -------------------------------------------------------------------------------------
os=$(uname -s); arch=$(uname -m)
if [ "$os" != Linux ]; then
	say "replicate: this needs Linux (this host is $os $arch). The seed compiler emits Linux AArch64 binaries."
	exit 2
fi
missing=""
for t in git make gcc sh sha256sum cmp sed grep awk bash curl cut wc date nice; do
	command -v "$t" >/dev/null 2>&1 || missing="$missing $t"
done
if [ "$agent" = 1 ]; then command -v python3 >/dev/null 2>&1 || missing="$missing python3"; fi
if [ -n "$missing" ]; then
	py=""; [ "$agent" = 1 ] && py=" python3"
	say "replicate: missing in /usr/bin:/bin:$missing"
	say "Install the base tools, then run the one-liner again:"
	say "  Debian/Ubuntu: sudo apt-get install -y git make gcc coreutils diffutils sed grep gawk bash curl$py"
	say "  Fedora/RHEL:   sudo dnf install -y git make gcc coreutils diffutils sed grep gawk bash curl$py"
	exit 3
fi
say "replicate: $(uname -sm), clean PATH=/usr/bin:/bin, nvcc on PATH: $(command -v nvcc || echo no)"

# ---- the step runner ----------------------------------------------------------------------------------
req_bad=0
stop_reason=""
record() { # id label rc result secs required note
	printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" "$6" "$7" >> "$SUM"
	if [ "$6" = req ] && [ "$4" != PASS ]; then req_bad=$((req_bad+1)); fi
	printf '%-7s %-28s %5ss  rc=%-4s %s\n' "$4" "$1" "$5" "$3" "$7"
}
notrun() { # id label required reason
	record "$1" "$2" - NOT_RUN 0 "$3" "$4"
	printf '### %s\n\nNOT_RUN: %s\n\n' "$1" "$4" >> "$LOG"
}
# step id label required want expect forbid cmd
#   want: 0 | nz (must fail) | N (exact) | any;  expect: newline-separated fixed strings that must all appear;
#   forbid: an extended regex that must not match any output line ("" for none).
step() {
	id=$1 label=$2 reqd=$3 want=$4 expect=$5 forbid=$6 cmd=$7
	if [ -n "$stop_reason" ]; then notrun "$id" "$label" "$reqd" "$stop_reason"; return 1; fi
	printf 'RUN     %s\n' "$id"
	out=$WS/logs/$id.log
	t0=$(date -u +%s)
	( cd "$WS" && env -i HOME="$WS" PATH=/usr/bin:/bin R="$R" LC_ALL=C RAD_HTTP="$RAD_HTTP" RAD_HTTP2="$RAD_HTTP2" \
		nice -n 10 sh -c "$cmd" ) > "$out" 2>&1 </dev/null
	rc=$?
	secs=$(( $(date -u +%s) - t0 ))
	res=PASS note=""
	case $want in
	0) [ "$rc" -eq 0 ] || { res=FAIL; note="exit $rc, want 0"; } ;;
	nz) [ "$rc" -ne 0 ] || { res=FAIL; note="exit 0, but this control must fail"; } ;;
	any) ;;
	*) [ "$rc" -eq "$want" ] || { res=FAIL; note="exit $rc, want $want"; } ;;
	esac
	if [ "$res" = PASS ] && [ -n "$expect" ]; then
		while IFS= read -r line; do
			[ -n "$line" ] || continue
			grep -F -q -- "$line" "$out" || { res=FAIL; note="missing: $line"; break; }
		done <<EXPECT_EOF
$expect
EXPECT_EOF
	fi
	if [ "$res" = PASS ] && [ -n "$forbid" ] && grep -E -q -- "$forbid" "$out"; then
		res=FAIL; note="forbidden line: $(grep -E -m1 -- "$forbid" "$out")"
	fi
	case $want in 0|any) ;; *) [ "$res" = PASS ] && note="control failed as it must (exit $rc)" ;; esac
	n=$(wc -l < "$out")
	{
		printf '### %s (%s): %s\n\n```sh\n%s\n```\n\nrc=%s, %ss, %s output lines' "$id" "$label" "$res" "$cmd" "$rc" "$secs" "$n"
		[ -n "$note" ] && printf ', %s' "$note"
		[ "$n" -gt 40 ] && printf ' (first 8 and last 25 shown; full output logs/%s.log)' "$id"
		printf '\n\n```text\n'
		if [ "$n" -gt 40 ]; then sed -n 1,8p "$out" | cut -c1-300; echo '[...]'; tail -n 25 "$out" | cut -c1-300
		else cut -c1-300 "$out"; fi
		printf '```\n\n'
	} >> "$LOG"
	record "$id" "$label" "$rc" "$res" "$secs" "$reqd" "$note"
	[ "$res" = PASS ]
}

summary() {
	{
		say "## Summary"
		say ""
		say "| step | label | rc | result | seconds | required | note |"
		say "|---|---|---|---|---|---|---|"
		while IFS="$(printf '\t')" read -r a b c d e f g; do say "| $a | $b | $c | $d | $e | $f | $g |"; done < "$SUM"
		say ""
	} >> "$LOG"
	say ""
	say "SUMMARY (workspace $WSD)"
	printf '%-28s %-16s %-5s %-8s %s\n' step label rc result seconds
	while IFS="$(printf '\t')" read -r a b c d e f g; do printf '%-28s %-16s %-5s %-8s %s\n' "$a" "$b" "$c" "$d" "$e"; done < "$SUM"
}

clone_one() { # name rid dir pin -> clones with fallback, checks out pin if given
	for src in "$RAD_HTTP" "$RAD_HTTP2"; do
		if git clone -q "$src/$2.git" "$3" </dev/null 2>"$WS/logs/clone-$1.err"; then
			if [ -n "$4" ]; then git -C "$3" checkout -q "$4" 2>>"$WS/logs/clone-$1.err" || say "replicate: $1 has no commit $4 yet; using its head $(git -C "$3" rev-parse --short HEAD)"; fi
			return 0
		fi
		rm -rf "$3"
	done
	say "replicate: could not clone $1 (rad:$2) from $RAD_HTTP or $RAD_HTTP2; see $WS/logs/clone-$1.err"
	return 1
}

# ---- --agent: the user's own local model drives the replication --------------------------------------
if [ "$agent" = 1 ]; then
	probe() { curl -fsS -m 2 "$1/models" 2>/dev/null; }
	url="" models=""
	if [ -n "${AIEN_MODEL_URL:-}" ]; then
		case $AIEN_MODEL_URL in *:18091*) say "replicate: port 18091 is reserved and never used by this script; pick another endpoint."; exit 4 ;; esac
		url=${AIEN_MODEL_URL%/}
		models=$(probe "$url") || { say "replicate: no answer from $url/models (AIEN_MODEL_URL)"; exit 4; }
	else
		for u in http://127.0.0.1:11434/v1 http://127.0.0.1:8080/v1 http://127.0.0.1:1234/v1 http://127.0.0.1:8000/v1; do
			if models=$(probe "$u"); then url=$u; break; fi
		done
	fi
	if [ -z "$url" ]; then
		say "replicate --agent: no local OpenAI-compatible model server found."
		say "Probed (GET /models, 2 s): 127.0.0.1:11434 (ollama), :8080 (llama.cpp), :1234 (LM Studio), :8000 (vLLM)."
		say "Start one, for example ollama (https://ollama.com/download):"
		say "  OLLAMA_CONTEXT_LENGTH=32768 ollama serve &"
		say "  ollama pull <a coding model that fits your machine>"
		say "then run again:  curl -fsSL https://www.aienos.com/replicate | sh -s -- --agent"
		say "Any other OpenAI-compatible server: curl -fsSL https://www.aienos.com/replicate | AIEN_MODEL_URL=http://host:port/v1 AIEN_MODEL=<id> sh -s -- --agent"
		exit 4
	fi
	model=${AIEN_MODEL:-}
	if [ -z "$model" ]; then
		model=$(printf '%s' "$models" | python3 -c 'import json,sys
d=json.load(sys.stdin); m=d.get("data") or d.get("models") or []
print((m[0].get("id") or m[0].get("name")) if m else "")' 2>/dev/null)
	fi
	[ -n "$model" ] || { say "replicate: $url/models lists no model; set AIEN_MODEL"; exit 4; }
	say "replicate --agent: endpoint $url, model $model"
	mkdir -p "$WS/context"
	clone_one cuda-crack "$CRACK_RID" "$WS/context/cuda-crack" "$PROMPT_PIN" || exit 1
	clone_one omega-harness "$HARNESS_RID" "$WS/context/omega-harness" "$HARNESS_PIN" || exit 1
	cp "$WS/context/cuda-crack/AGENT-PROMPT.md" "$WS/AGENT-PROMPT.md"
	cat > "$WS/DEPENDENCIES.txt" <<'DEP_EOF'
Host dependencies of this run (recorded per Drake's pure-Omega rule)
- python3: JSON encode/decode and HTTP for the --agent chat loop (agent.py). Omega replacement: FOLLOW-UP,
  not done: a .om agent loop with a JSON codec and HTTP client, built by the seeded omc or emitted through
  omega-bridge.
- git, make, gcc, coreutils, diffutils, sed, grep, awk, bash, curl: required by the AGENT-PROMPT.md steps
  themselves and by the endpoint probe.
- The local model server and model are the user's own; nothing is sent anywhere else.
DEP_EOF
	cat > "$WS/agent.py" <<'AGENT_PY_EOF'
# agent.py: the --agent loop of replicate.sh. One shell command per turn, approved by the human.
import json, os, re, subprocess, sys, time, urllib.request

WS = os.environ["WS"]; URL = os.environ["AGENT_URL"]; MODEL = os.environ["AGENT_MODEL"]
YES = os.environ.get("AGENT_YES") == "1"; CHIP = os.environ.get("AGENT_CHIP") == "1"
TURNS = int(os.environ.get("AGENT_TURNS", "40")); TTY = os.environ.get("AGENT_TTY", "")
MAXOUT = 6000; CMD_TIMEOUT = 3600
R = WS + "/replica"
CLEAN = {"HOME": WS, "PATH": "/usr/bin:/bin", "R": R, "LC_ALL": "C"}
FORBID = re.compile(r"\bsudo\b|\bsu(\s|$)|\bdoas\b|18091|nvidia-smi\b[^\n]*(\s-pl\b|\s-lgc\b|\s-lmc\b|\s-ac\b|\s-rgc\b|\s-rmc\b|\s-rac\b|\s-r\b"
                    r"|--power-limit|--lock|--applications-clocks|--reset-gpu-clocks|--reset-memory-clocks|--reset-applications-clocks|--gpu-reset)")
CHIPCMD = re.compile(r"\bmake\b[^\n]*\b(doctor|hello-gpu|hello-gpu-control)\b|\bbuild/gpu_\w+_test\b|\bhello_gpu\b(?![^\n]*--sim)")
REFUSE_FORBID = "Refused by replicate.sh without asking: sudo/su, port 18091 and clock or power changes are never allowed."
REFUSE_CHIP = "Refused: this is a chip step (section 7) and the human did not start with --chip. Report section 7 as NOT_RUN."

# --yes runs a command without asking ONLY when the whole command matches this allow-list; everything else goes
# to the human y/N (no terminal: declined). A deny-list cannot work: variables, heredocs and interpreters spell
# anything. Allowed: [cd $R/<REPO> && ] one of
#   uname -sm | nproc | free [-h] | make <MAKE_OK> | sh seed/omega-from-seed.sh | sha256sum [-c [--quiet]] PATH..
#   git [-C PATH] log|show|rev-parse GITARG.. | ls [-l|-a|-la|-al|-1|-lh] PATH.. | cat PATH.. | head [-n N|-N] PATH..
#   wc [-l|-c|-w] PATH.. | grep -n|-c|-H|-o|-r|-rn.. PATTERN PATH..
# PATH: [A-Za-z0-9._/-], under the workspace ($R, $R/..., relative, or an absolute path inside it), no "..",
# no leading "-". No other "$", no ; | < > ` ' \ ( ) { } * ? ~ = &, no newline.
REPOS = ("CUDApp", "cuda-crack", "cuda-crack/receipts", "omega-mv", "omega-bridge", "omc-f4df8239", "omc-e5b32567",
         "bridge-6a8f0090")
MAKE_OK = ("hello", "test-hello-sim", "test-om-encoder", "test-om-encoder-mutants", "test-om-encoder-corpus")
PLAIN = re.compile(r"[A-Za-z0-9._/-]+")
CMDCHARS = re.compile(r'[A-Za-z0-9._/ $&"-]+')
CDPRE = re.compile(r'cd (?:\$R/(?P<a>[A-Za-z0-9._/-]+)|"\$R/(?P<b>[A-Za-z0-9._/-]+)") && (?P<rest>.+)')
GITARG = re.compile(r"-[0-9]+|-n|--oneline|--stat|--short|--name-only|[A-Za-z0-9._/][A-Za-z0-9._/-]*")

def wspath(t):
    if t == "$R":
        return PLAIN.fullmatch(R) is not None
    if t.startswith("$R/"):
        t, base = t[3:], R
        if PLAIN.fullmatch(R) is None:
            return False
    else:
        base = WS
    if not PLAIN.fullmatch(t) or t.startswith("-") or ".." in t.split("/"):
        return False
    return not t.startswith("/") or base == WS and (t == WS or t.startswith(WS + "/"))

def simple(t):
    if not t:
        return False
    n, a = t[0], t[1:]
    if t in (["uname", "-sm"], ["nproc"], ["free"], ["free", "-h"]):
        return True
    if n == "make":
        return len(a) == 1 and a[0] in MAKE_OK
    if n == "sh":
        return a == ["seed/omega-from-seed.sh"]
    if n == "sha256sum":
        if a[:1] == ["-c"]:
            a = a[2:] if a[1:2] == ["--quiet"] else a[1:]
            return len(a) == 1 and wspath(a[0])
        return len(a) >= 1 and all(wspath(x) for x in a)
    if n == "git":
        if a[:1] == ["-C"]:
            if len(a) < 2 or not wspath(a[1]):
                return False
            a = a[2:]
        return len(a) >= 1 and a[0] in ("log", "show", "rev-parse") and all(GITARG.fullmatch(x) for x in a[1:])
    flags = {"ls": ("-l", "-a", "-la", "-al", "-1", "-lh"), "cat": (), "wc": ("-l", "-c", "-w"),
             "head": (), "grep": ("-n", "-c", "-H", "-o", "-r", "-rn")}
    if n not in flags:
        return False
    if n == "head" and a[:1] == ["-n"]:
        if len(a) < 2 or not a[1].isdigit():
            return False
        a = a[2:]
    elif n == "head" and a[:1] and re.fullmatch(r"-[0-9]+", a[0]):
        a = a[1:]
    while a and a[0] in flags[n]:
        a = a[1:]
    if n == "grep":
        if not a or not PLAIN.fullmatch(a[0]) or a[0].startswith("-"):
            return False
        a = a[1:]
    return (len(a) >= 1 or n == "ls") and all(wspath(x) for x in a)

def allowed(cmd):
    if not CMDCHARS.fullmatch(cmd):
        return False
    m = CDPRE.fullmatch(cmd)
    if m:
        if (m.group("a") or m.group("b")) not in REPOS:
            return False
        cmd = m.group("rest")
    if '"' in cmd or "&" in cmd:
        return False
    return simple(cmd.split(" "))

def gate(cmd):
    """-> ("refuse", feedback) | ("auto", "") | ("ask", reason). FORBID and CHIPCMD run on the raw command and on
    it with quotes and backslashes stripped and ; | & as spaces; they refuse outright. Under --yes only allowed()
    commands run without a human; chip steps never do."""
    flat = re.sub(r"[;|&]", " ", re.sub(r"[\\'\"`]", "", cmd))
    if FORBID.search(cmd) or FORBID.search(flat):
        return "refuse", REFUSE_FORBID
    if CHIPCMD.search(cmd) or CHIPCMD.search(flat):
        return ("ask", "chip step: needs a y from the human") if CHIP else ("refuse", REFUSE_CHIP)
    if not YES:
        return "ask", ""
    if allowed(cmd):
        return "auto", ""
    return "ask", "not on the --yes allow-list: needs a y from the human"
BLOCK = re.compile(r"```(?:sh|bash|shell)?[ \t]*\n(.*?)```", re.S)

prompt = open(WS + "/AGENT-PROMPT.md", encoding="utf-8").read()
sk_root = WS + "/context/omega-harness/skills"
skills = []
for d in sorted(os.listdir(sk_root)):
    p = os.path.join(sk_root, d, "SKILL.md")
    if not os.path.isfile(p):
        continue
    desc = ""
    for line in open(p, encoding="utf-8"):
        if line.startswith("description:"):
            desc = line.split(":", 1)[1].strip().strip('"')
            break
    skills.append("- %s: %s (read it: cat %s)" % (d, desc, p))

system = f"""You are an agent replicating Drake Stapleton's GB10 / Omega / CUDA++ work on this machine, following AGENT-PROMPT.md below.

How you act here:
- Each reply contains AT MOST ONE shell command, in one ```sh fenced block, after one or two sentences saying which step it is and what you expect.
- A human sees the command and approves it. It runs in a NEW clean shell every time:
  env -i HOME={WS} PATH=/usr/bin:/bin R={R} LC_ALL=C sh -c '<your command>'   (working directory {WS})
  Only files persist between commands; variables do not. $R is already set to {R}.
- With --yes, only plain commands run without a human: make <target>, sh seed/omega-from-seed.sh, sha256sum, git log/show/rev-parse, ls, cat, head, wc, grep -n, uname -sm, nproc, free, optionally after `cd $R/<repo> && `, with plain arguments (no quotes, pipes, ;, redirection, heredocs or variables other than $R). Anything else waits for the human and is declined if nobody answers.
- You get back the exit code, the seconds taken and the output (long output is cut in the middle).
- Go in order from step 1.1. Compare every output with the step's Success line. On a mismatch, stop (rule 0.1).
- Section 7 (chip) only if the human started with --chip; otherwise report it NOT_RUN. Never use sudo. Never change clocks, power or thermal settings.
- The omega-harness skills are on disk; read one when you need it (index at the end).
- When you are finished or stopped, reply with a line that starts with DONE, then the section 9 REPLICATION REPORT, and no sh block.

===== AGENT-PROMPT.md (cuda-crack {os.environ.get('PROMPT_PIN', '')[:8]}) =====
{prompt}

===== omega-harness skill index (rad:z39gvwWsnkRZsAConQLjaKiNVLHfW @ {os.environ.get('HARNESS_PIN', '')[:8]}) =====
""" + "\n".join(skills) + "\n"

messages = [{"role": "system", "content": system}, {"role": "user", "content": "Begin with step 1.1."}]
tpath = WS + "/agent-transcript.md"
tfile = open(tpath, "w", encoding="utf-8")
def tw(s):
    tfile.write(s + "\n"); tfile.flush()
tw(f"# --agent transcript\n\n- endpoint {URL}, model {MODEL}, workspace ~/{os.path.basename(WS)}, auto-approve {YES}, chip {CHIP}\n- system prompt: {len(system)} characters\n")
print(f"agent: system prompt is {len(system)} characters (~{len(system)//4} tokens). If your server cuts context (ollama default), start it with OLLAMA_CONTEXT_LENGTH=32768.", flush=True)

def chat():
    body = json.dumps({"model": MODEL, "messages": messages, "temperature": 0.2, "stream": False}).encode()
    req = urllib.request.Request(URL + "/chat/completions", data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=900) as r:
        d = json.load(r)
    return d["choices"][0]["message"].get("content") or ""

def approve(verdict, why):
    if verdict == "auto":
        print("auto-approved (--yes)", flush=True); return "y"
    if why:
        print(why, flush=True)
    if not TTY:
        print("no terminal to ask on: declined", flush=True); return "n"
    with open(TTY, "w") as w:
        w.write("Run this command? [y = run, n = decline, q = quit] "); w.flush()
    with open(TTY) as r:
        a = r.readline().strip().lower()
    return a[:1] if a else "n"

def shorten_old():
    # keep the context small: tool outputs older than the last 4 turns shrink to 600 characters
    users = [m for m in messages if m["role"] == "user"]
    for m in users[:-4]:
        if len(m["content"]) > 800:
            m["content"] = m["content"][:600] + "\n[older output shortened]"

done = False
for turn in range(1, TURNS + 1):
    try:
        reply = chat()
    except Exception as e:
        print(f"agent: model request failed: {e}", flush=True); tw(f"\nmodel request failed: {e}"); break
    visible = re.sub(r"<think>.*?</think>", "", reply, flags=re.S).strip()
    messages.append({"role": "assistant", "content": visible})
    print(f"\n--- turn {turn}: MODEL ---\n{visible}\n", flush=True)
    tw(f"\n## turn {turn}\n\n### model\n\n{visible}\n")
    m = BLOCK.search(visible)
    if not m:
        if re.search(r"^\s*\**DONE\b", visible, re.M):
            done = True; break
        fb = "No command found. Reply with exactly one ```sh block, or with DONE and the report."
        messages.append({"role": "user", "content": fb}); tw(f"### fed back\n\n{fb}\n"); continue
    cmd = m.group(1).strip()
    print(f"PROPOSED COMMAND:\n{cmd}\n", flush=True)
    verdict, why = gate(cmd)
    if verdict == "refuse":
        print(why, flush=True); messages.append({"role": "user", "content": why}); tw(f"### refused\n\n{why}\n"); continue
    a = approve(verdict, why)
    tw(f"### command\n\n```sh\n{cmd}\n```\n\napproval: {a}\n")
    if a == "q":
        print("agent: stopped by the human", flush=True); break
    if a != "y":
        fb = "The human declined to run this command. Propose something else or explain."
        messages.append({"role": "user", "content": fb}); continue
    t0 = time.time()
    try:
        p = subprocess.run(["nice", "-n", "10", "sh", "-c", cmd], cwd=WS, env=CLEAN, stdin=subprocess.DEVNULL,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=CMD_TIMEOUT)
        rc, out = p.returncode, p.stdout.decode("utf-8", "replace")
    except subprocess.TimeoutExpired as e:
        rc, out = 124, (e.output or b"").decode("utf-8", "replace") + f"\n[killed after {CMD_TIMEOUT} s]"
    secs = int(time.time() - t0)
    if len(out) > MAXOUT:
        out = out[:1500] + f"\n[... {len(out) - MAXOUT} characters cut ...]\n" + out[-(MAXOUT - 1500):]
    print(f"exit code {rc}, {secs}s\n{out}", flush=True)
    res = f"exit code: {rc}\nseconds: {secs}\noutput:\n```text\n{out}\n```"
    tw(f"### result\n\n{res}\n")
    shorten_old()
    messages.append({"role": "user", "content": res})

json.dump(messages, open(WS + "/agent-messages.json", "w"), indent=1)
tw(f"\n---\nend: {'DONE reported' if done else 'stopped without DONE'}")
print(f"\nagent: {'DONE reported' if done else 'stopped without DONE'}; transcript {tpath}", flush=True)
sys.exit(0 if done else 1)
AGENT_PY_EOF
	exec env -i HOME="$WS" PATH=/usr/bin:/bin LC_ALL=C WS="$WS" AGENT_URL="$url" AGENT_MODEL="$model" AGENT_YES="$yes" \
		AGENT_CHIP="$chip" AGENT_TURNS="$turns" AGENT_TTY="$TTY" PROMPT_PIN="$PROMPT_PIN" HARNESS_PIN="$HARNESS_PIN" \
		python3 "$WS/agent.py"
fi

# ---- sections 1 to 6: the host steps of AGENT-PROMPT.md ------------------------------------------------
step 1.1-preflight HOST_TESTED req 0 "Linux aarch64
preflight done" 'MISSING' \
'uname -sm; for t in git make gcc sh sha256sum cmp sed grep awk; do command -v $t >/dev/null || echo "MISSING $t"; done; echo preflight done'
seedok=1
[ "$arch" = aarch64 ] || seedok=0

step 2.1-clone HOST_TESTED req 0 "CUDApp 
omega-mv 
omega-bridge 
cuda-crack 
physics-mv 
omega-gpu-driver 
omega-blas " '' \
'mkdir -p "$R" && cd "$R" && while read name rid; do ok=0; for src in "$RAD_HTTP" "$RAD_HTTP2"; do if git clone -q "$src/$rid.git" "$name" </dev/null; then ok=1; break; fi; rm -rf "./$name"; done; [ $ok = 1 ] || { echo "could not clone $name rad:$rid"; exit 1; }; echo "$name $(git -C "$name" rev-parse HEAD) $src"; done <<EOF
CUDApp z4RxD8vXigmWg61nM8miQ8DVPAXEP
omega-mv z6do9WDBhuSnvopDkgFdFr1yWA62
omega-bridge z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y
cuda-crack z631r2JJiVT8it4tST7RK24hpowi
physics-mv z49She8eifZpLd2aiSvk2pph3DMUo
omega-gpu-driver z2xjD5kxUTTBNCryJ6rg9QXpemzei
omega-blas z47VdC9EFsF4dFyH1QJ1C2JNJK4JS
EOF' || stop_reason="stopped: step 2.1 failed (rule 0.1)"

step 2.2-pins HOST_TESTED req 0 "b774723f537cec16a359fe082b8100317a5b5490
E2 receipt commit 010abb15 is inside CUDApp b774723f
043f993fab0b263eb0edd1a367fee8fee8f6a79b
6efc45728d5080b0fc5d74016a00ba8bbfcf9698
worktrees: omc-f4df8239 omc-e5b32567 bridge-6a8f0090" '' \
'cd "$R" && git -C CUDApp checkout -q b774723f537cec16a359fe082b8100317a5b5490 && git -C CUDApp rev-parse HEAD && git -C CUDApp merge-base --is-ancestor 010abb1549c48a4be6d63da47101d393f76cb2dd HEAD && echo "E2 receipt commit 010abb15 is inside CUDApp b774723f" && git -C cuda-crack checkout -q 043f993fab0b263eb0edd1a367fee8fee8f6a79b && git -C cuda-crack rev-parse HEAD && git -C omega-mv checkout -q 6efc45728d5080b0fc5d74016a00ba8bbfcf9698 && git -C omega-mv rev-parse HEAD && git -C omega-mv worktree add -q --detach ../omc-f4df8239 f4df82394e35893dcf1354dda69a2fe028d94bc1 && git -C omega-mv worktree add -q --detach ../omc-e5b32567 e5b32567a7aff3ce594e3254a622a846a6cd190b && git -C omega-bridge worktree add -q --detach ../bridge-6a8f0090 6a8f0090913283125f14871272f03d144a102d02 && echo "worktrees: omc-f4df8239 omc-e5b32567 bridge-6a8f0090"' \
	|| stop_reason="stopped: step 2.2 failed (rule 0.1)"

# Steps that run seed-built AArch64 binaries.
seed_step() {
	if [ "$seedok" = 0 ] && [ -z "$stop_reason" ]; then notrun "$1" "$2" "$3" "needs Linux aarch64 (the seed compiler emits AArch64 ELF); this host is $arch"; return; fi
	step "$@"
}

seed_step 3.1-seed-f4df8239 HOST_TESTED req 0 "PASS seed0 408 bytes, rebuilds itself
PASS omc fixpoint 3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194
PASS assign exit 7
RC=0" '' 'cd "$R/omc-f4df8239" && sh seed/omega-from-seed.sh'

seed_step 3.2-sha-f4df8239 HOST_TESTED req 0 "3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194  seed/out/omc
rebuilt omc is byte-identical to the committed one" '' \
'cd "$R/omc-f4df8239" && sha256sum seed/out/omc && git diff --exit-code --stat seed/out/omc && echo "rebuilt omc is byte-identical to the committed one"'

seed_step 3.3-seed-e5b32567 HOST_TESTED req 0 "PASS omc fixpoint 2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f
RC=0" '' 'cd "$R/omc-e5b32567" && sh seed/omega-from-seed.sh'

seed_step 3.4-sha-e5b32567 HOST_TESTED req 0 "2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f  seed/out/omc
rebuilt omc is byte-identical to the committed one" '' \
'cd "$R/omc-e5b32567" && sha256sum seed/out/omc && git diff --exit-code --stat seed/out/omc && echo "rebuilt omc is byte-identical to the committed one"'

seed_step 3.5-neg-seed-byte HOST_TESTED req nz "seed/rung0/seed0.hex | 2 +-
Exec format error" '' \
'cd "$R" && git -C omega-mv worktree add -q --detach ../omc-neg f4df82394e35893dcf1354dda69a2fe028d94bc1 && cd omc-neg && sed -i "s/^464c457f /464c457e /" seed/rung0/seed0.hex && git diff --stat && sh seed/omega-from-seed.sh'

seed_step 3.6-neg-compiler-source HOST_TESTED req 1 "seed/omc/omc.om | 2 +-
455a5d1f3d8621d7d03bf842aac30a46c57808493908c7b0e8a70c92cad9ad60  seed/out/omc
seed/out/omc | Bin 625676 -> 625744 bytes" '' \
'cd "$R/omc-neg" && git checkout -q seed/rung0/seed0.hex && sed -i "s/^global out uchar 16777216\$/global out uchar 16777215/" seed/omc/omc.om && git diff --stat && sh seed/omega-from-seed.sh >/dev/null; sha256sum seed/out/omc; git diff --exit-code --stat seed/out/omc'

step 4.1-crack-receipts HOST_TESTED req 0 "all 148 receipt files match" '' \
'cd "$R/cuda-crack/receipts" && sha256sum -c --quiet SHA256SUMS && echo "all $(wc -l < SHA256SUMS) receipt files match"'

seed_step 4.2-crack-gen HOST_TESTED req 0 "isa/sm121-forms.txt: 471 forms, sha256 587d81e2bc8b3dc6fdb48d477a76b717300732ccdb984f05f5b3df658e58e2d7
isa/ regenerated byte-identical" '' \
'cd "$R/cuda-crack" && OMC="$R/omc-f4df8239/seed/out/omc" sh gen/run.sh && git diff --exit-code --stat isa/ && echo "isa/ regenerated byte-identical"'

seed_step 4.3-crack-check HOST_TESTED req 0 "kernels 70 instructions 13520 unmatched 0
PASS: all 70 rebuilt kernels match kernels-om.sha256 byte for byte
PASS: mutant table caught
PASS: corrupted instruction matches no form
PASS: wrong field width caught
PASS: wrong field mask caught
ALL CHECKS PASS" '' \
'cd "$R/cuda-crack" && OMC="$R/omc-f4df8239/seed/out/omc" sh check/check.sh'

step 4.4-same-encoder HOST_TESTED req 0 "cuda-crack gen/bw_enc_sm121.om == CUDApp om/encoder/bw_enc_sm121.om" '' \
'cmp "$R/cuda-crack/gen/bw_enc_sm121.om" "$R/CUDApp/om/encoder/bw_enc_sm121.om" && echo "cuda-crack gen/bw_enc_sm121.om == CUDApp om/encoder/bw_enc_sm121.om"'

step 4.5-neg-tampered-receipt HOST_TESTED req 1 "om-hello.log: FAILED
WARNING: 1 computed checksum did NOT match" '' \
'cd "$R" && rm -rf neg-receipts && cp -r cuda-crack/receipts neg-receipts && printf x >> neg-receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-hello.log && cd neg-receipts && sha256sum -c --quiet SHA256SUMS'

seed_step 5.1-om-encoder HOST_TESTED req 0 "PASS: hosted golden-word fixtures through the .om encoder (0 failing checks)
encoder diff: .om and C byte-identical on 145 golden instructions and 14 fixture programs
red check: one flipped bit aborts the encoder diff, as it must" '' \
'cd "$R/CUDApp" && make test-om-encoder'

seed_step 5.3-neg-mutants-unpinned HOST_TESTED req nz "" '^PASS' \
'cd "$R/CUDApp" && make test-om-encoder-mutants'

seed_step 5.4-om-encoder-mutants HOST_TESTED req 0 "191b776ef98821597c3e30655da6d680a9b66edbc9ceaca3c39c61ea6df098e9  ../omc
bootstrap fixpoint RC=0
69d629df170a24ba0c2cb6d41dbfaed520e248e0d723236dd32abf0581524d84  src/toc.om
mutant 1 red (
mutant 2 red (
mutant 3 red (" 'SURVIVED' \
'cd "$R/bridge-6a8f0090" && OMEGA_SOURCE="$R/omega-mv" sh tools/bootstrap.sh && sh tools/build.sh && cat build/compiler.sha256 && cd "$R/CUDApp" && make test-om-encoder-mutants OMEGA_OMC="$R/omc-e5b32567/seed/out/omc" OMEGA_BRIDGE="$R/bridge-6a8f0090"'

seed_step 5.5-hello-sim SIMULATED req 0 "PASS sim-pass (exit 0)
PASS fault-exit (exit 1)
PASS short-exit (exit 1)
PASS past-end-refused-on-gpu (exit 2)
hello --sim tests: 12 passed, 0 failed" '' \
'cd "$R/CUDApp" && make test-hello-sim'

step 6.1-E2-hello-receipt "receipt verified" req 0 "om-hello.log:checked 1048576 of 1048576 elements: 0 wrong, 0 never written
om-hello-control.log:checked 1048576 of 1048576 elements: 1 wrong, 1 never written
om-hello-control.log:FAIL
om hello-control rc=1
c hello-control rc=1
c gpu_matmul_api_test rc=0" '' \
'cd "$R/CUDApp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z" && grep -H -e "^checked " -e "^PASS$" -e "^FAIL$" om-hello.log om-hello-control.log && cat summary.txt'

step 6.2-E3-chip-kernels "receipt verified" req 0 "70 chip-20261027T080240Z/kernels-om.sha256
243 host/corpus-k-om.sha256
70 chip kernel files match kernels-om.sha256" '' \
'cd "$R/CUDApp/evidence/CUDAPP-OM-ENCODER" && cmp chip-20261027T080240Z/kernels-om.sha256 chip-20261027T080240Z/kernels-c.sha256 && cmp host/corpus-k-om.sha256 host/corpus-k-c.sha256 && wc -l chip-20261027T080240Z/kernels-om.sha256 host/corpus-k-om.sha256 && cd "$R/cuda-crack/receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/kernels-om" && sha256sum -c --quiet ../kernels-om.sha256 && echo "$(ls | wc -l) chip kernel files match kernels-om.sha256"'

step 6.3-E6-seed-vecadd "receipt verified" req 0 "check_words exit=0 want=0 ok
run_seed exit=0 want=0 ok
control_mutant exit=1 want=1 ok
session PASS" '' \
'cd "$R/omega-mv/evidence/SEED-0/sm121/chip" && cat steps.txt'

step 6.4-E7-native-launch "receipt verified" req 0 '"NATIVE_SM121_VECTOR_PASS"
"failed_syscalls"' '' \
'grep -o -e "\"NATIVE_SM121_VECTOR_PASS\"" -e "\"failed_syscalls\": *0" "$R/CUDApp/evidence/speculation/native-kernel/receipt.json"'

step 6.5-E8-doctor "receipt verified" req 0 "ok    NVIDIA kernel module: open module 580.173.02
info  CUDA toolkit: not needed and not used by CUDA++" '' \
'grep -e "NVIDIA kernel module" -e "CUDA toolkit" "$R/CUDApp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-doctor.log"'

step 6.6-E9-exhaustive "receipt verified" req 0 "16 files: each sha256 equals its file name
RESULT chip SIGMOID checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip EXP2 checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS" '' \
'cd "$R/omega-mv/evidence/E1-TRANSC-GB10" && for f in *.json blobs/*.log; do h=$(sha256sum "$f" | cut -c1-64); case "$f" in *"$h"*) ;; *) echo "NOT CONTENT-ADDRESSED: $f"; exit 1;; esac; done && echo "$(ls *.json blobs/*.log | wc -l) files: each sha256 equals its file name" && grep -h "verdict=PASS digest=" blobs/*.log | cut -d" " -f1-8'

step 6.7-E10-builders "receipt verified" req 0 "PASS (902 checks)
318 of 318 configs pass" '' \
'cd "$R/CUDApp/evidence" && grep -o "PASS (902 checks)" GEMM-GENERAL-00c9cf9/chip.log && grep -o -m1 "318 of 318 configs pass" ATTN-GENERAL-20261027-4d51f91f/SUMMARY.md'

step 6.8-E1-no-cuda "receipt verified" req 0 "count of maps lines
Open Kernel Module for aarch64  580.173.02" '' \
'cd "$R/omega-mv/evidence/WHAT-OMEGA-IS-20261021" && grep -A1 "count of maps lines" live-serve-no-cuda.txt && grep -o "Open Kernel Module for aarch64  580.173.02" live-serve-no-cuda.txt'

if [ "$corpus" = 1 ]; then
	seed_step 5.2-om-encoder-corpus HOST_TESTED req 0 "encoder corpus: 243 distinct kernels identical .om vs C" '' \
	'cd "$R/CUDApp" && make test-om-encoder-corpus'
else
	notrun 5.2-om-encoder-corpus HOST_TESTED opt "optional, long (three CUDApp builds on one core); run with --corpus"
fi

# ---- section 7: chip steps, only with --chip and a y ---------------------------------------------------
if [ "$chip" = 1 ] && [ -z "$stop_reason" ]; then
	ver=$(cat /proc/driver/nvidia/version 2>/dev/null | sed -n 1p)
	say ""
	say "--chip: /proc/driver/nvidia/version: ${ver:-<absent: no NVIDIA driver loaded>}"
	case $ver in
	*580.173.02*)
		say "driver 580.173.02: matches what CUDA++ speaks."
		say "Section 7 runs 7.1 doctor, 7.2 hello-gpu and 7.3 hello-gpu-control on this GPU. It changes no clocks or power."
		say "Only with the machine owner's permission, and with no other GPU job running (AGENT-PROMPT.md 7.0)."
		if ask "Run section 7 on this GPU now?"; then
			step 7.1-doctor CHIP_TESTED req 0 "580.173.02
READY" '' 'cd "$R/CUDApp" && make doctor'
			step 7.2-hello-gpu CHIP_TESTED req 0 "checked 1048576 of 1048576 elements: 0 wrong, 0 never written
9e28bd9c46f80584d77238a752e99cecddbc8d622ffbe320885ed2f499e1f075" '' 'cd "$R/CUDApp" && make hello-gpu'
			step 7.3-hello-gpu-control CHIP_TESTED req any "checked 1048576 of 1048576 elements: 1 wrong, 1 never written
RED as it must" '' 'cd "$R/CUDApp" && make hello-gpu-control'
			notrun 7.4-six-suites CHIP_TESTED opt "no script in the repositories; see CUDApp/evidence/CUDAPP-OM-ENCODER/README.md"
		else
			notrun 7-chip CHIP_TESTED opt "declined at the y/N prompt"
		fi ;;
	*)
		notrun 7-chip CHIP_TESTED opt "driver is not 580.173.02 (${ver:-none}); CUDA++ refuses other versions" ;;
	esac
else
	notrun 7-chip CHIP_TESTED opt "chip steps are off by default; run with --chip on a GB10"
fi

summary
if [ "$req_bad" -eq 0 ]; then
	say "RESULT: every required step PASSED. RUNLOG: $WSD/RUNLOG.md"
	exit 0
fi
say "RESULT: $req_bad required step(s) did not PASS (NOT_RUN is not PASS). RUNLOG: $WSD/RUNLOG.md"
exit 1
INNER_EOF

echo "replicate: re-running under env -i HOME=$WS PATH=/usr/bin:/bin LC_ALL=C"
exec env -i HOME="$WS" PATH=/usr/bin:/bin LC_ALL=C \
	${AIEN_MODEL_URL:+AIEN_MODEL_URL="$AIEN_MODEL_URL"} ${AIEN_MODEL:+AIEN_MODEL="$AIEN_MODEL"} \
	${AIEN_RAD_HTTP:+AIEN_RAD_HTTP="$AIEN_RAD_HTTP"} ${AIEN_RAD_HTTP2:+AIEN_RAD_HTTP2="$AIEN_RAD_HTTP2"} \
	sh "$WS/replicate-inner.sh" "$@"
