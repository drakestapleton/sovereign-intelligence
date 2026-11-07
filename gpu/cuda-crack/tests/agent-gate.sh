#!/bin/sh
# tests/agent-gate.sh: checks the --agent command gate and the --turns check of replicate.sh.
# No model, no network, no GPU: it runs the gate code of agent.py on fixed command strings.
#   sh tests/agent-gate.sh [path/to/replicate.sh]      (default: replicate.sh next to tests/)
# Prints one line per case and "agent-gate: N passed, M failed". Exit 0 only when every case passes.
set -u
here=$(cd "$(dirname "$0")" && pwd)
script=${1:-$here/../replicate.sh}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM
awk '/<<.AGENT_PY_EOF.$/ {f=1; next} /^AGENT_PY_EOF$/ {f=0} f' "$script" > "$tmp/agent.py"
[ -s "$tmp/agent.py" ] || { echo "agent-gate: no agent.py in $script"; exit 2; }

fail=0 pass=0
python3 - "$tmp/agent.py" > "$tmp/py.out" <<'PY_EOF'
import os, sys
src = open(sys.argv[1], encoding="utf-8").read()
src = src[:src.index("\nprompt = open(")]  # the gate code; the rest needs a model

def load(yes, chip):
    os.environ.update(WS="/nonexistent", AGENT_URL="http://127.0.0.1:9", AGENT_MODEL="none",
                      AGENT_YES="1" if yes else "0", AGENT_CHIP="1" if chip else "0", AGENT_TTY="")
    ns = {}
    exec(src, ns)
    return ns

def decide(ns, cmd):
    if "gate" in ns:
        return ns["gate"](cmd)[0]
    # replicate.sh before gate() existed: the decision its main loop made
    if ns["FORBID"].search(cmd):
        return "refuse"
    chip = bool(ns["CHIPCMD"].search(cmd))
    if chip and not ns["CHIP"]:
        return "refuse"
    return "auto" if ns["YES"] and not chip else "ask"

NOT_AUTO = ("refuse", "ask")
cases = [
    # (--yes, --chip, command, allowed decisions, what it checks)
    (1, 0, r's\udo id', ("refuse",), "bypass: backslash in sudo"),
    (1, 0, 'sud""o id', ("refuse",), "bypass: empty quotes in sudo"),
    (1, 0, 'curl http://127.0.0.1:1""8091/v1', ("refuse",), "bypass: quotes in port 18091"),
    (1, 0, 'printf c3VkbyBpZAo= | base64 -d | sh', NOT_AUTO, "bypass: base64 piped to sh"),
    (1, 0, 'sh -c "make doc""tor"', ("refuse",), "bypass: chip step via sh -c and quotes, no --chip"),
    (1, 1, 'sh -c "make doc""tor"', ("ask",), "chip step with --chip still needs a human y"),
    (1, 0, 'nvidia-smi --reset-gpu-clocks', ("refuse",), "nvidia-smi --reset-gpu-clocks"),
    (1, 0, 'nvidia-smi --reset-memory-clocks', ("refuse",), "nvidia-smi --reset-memory-clocks"),
    (1, 0, 'nvidia-smi -rac', ("refuse",), "nvidia-smi -rac"),
    (1, 0, 'nvidia-smi -r', ("refuse",), "nvidia-smi -r"),
    (1, 0, 'nvidia-smi --gpu-reset', ("refuse",), "nvidia-smi --gpu-reset"),
    (1, 0, 'sudo id', ("refuse",), "plain sudo"),
    (1, 0, 'make doctor', ("refuse",), "plain chip step without --chip"),
    (1, 0, 'nvidia-smi -pl 100', ("refuse",), "plain power limit"),
    (1, 0, 'echo "$(id)"', NOT_AUTO, "quotes and $( ) go to the human"),
    # RevCrackRepl's second round on 5c2635a9: variables, heredocs and interpreters
    (1, 0, 'a=su; b=do; $a$b id', NOT_AUTO, "bypass: sudo from two variables"),
    (1, 0, 't=doctor\ncd $R/CUDApp && make $t', NOT_AUTO, "bypass: chip step from a variable, no --chip"),
    (1, 0, 't=doctor; make $t', NOT_AUTO, "bypass: chip step from a variable, one line"),
    (1, 0, 'p=18\nq=091\ncurl http://127.0.0.1:$p$q/v1/models', NOT_AUTO, "bypass: port 18091 from variables"),
    (1, 0, 'python3 - <<EOF\nimport os\nos.system(chr(115)+chr(117)+chr(100)+chr(111)+chr(32)+chr(105)+chr(100))\nEOF',
     NOT_AUTO, "bypass: python3 heredoc"),
    (1, 0, 'perl -e system(chr(115).chr(117).chr(100).chr(111))', NOT_AUTO, "bypass: perl -e"),
    (1, 0, 'awk BEGIN{system(id)}', NOT_AUTO, "awk system()"),
    (1, 0, 'cat $R/../../../etc/passwd', NOT_AUTO, "path escaping the workspace with .."),
    (1, 0, 'cat /etc/passwd', NOT_AUTO, "absolute path outside the workspace"),
    (1, 0, 'head -n 5 /nonexistent/../etc/passwd', NOT_AUTO, "absolute path with .."),
    (1, 0, 'git -C $R/CUDApp log --output=/tmp/x', NOT_AUTO, "git log --output=FILE"),
    (1, 0, 'git -C $R/CUDApp log --output /tmp/x', NOT_AUTO, "git log --output FILE"),
    (1, 0, 'grep -n -f /etc/passwd README.md', NOT_AUTO, "grep option outside the list"),
    (1, 0, 'ls -la; id', NOT_AUTO, "; after an allowed command"),
    (1, 0, 'make hello > /tmp/x', NOT_AUTO, "redirection"),
    (1, 0, 'make clean', NOT_AUTO, "make target outside the list"),
    (1, 0, 'cd $R/../x && make hello', NOT_AUTO, "cd outside the fixed repositories"),
    (1, 0, 'cd $R/CUDApp && rm -rf .', NOT_AUTO, "cd prefix with a command outside the list"),
    (1, 0, 'make hello & id', NOT_AUTO, "background &"),
    (1, 1, 'cd $R/CUDApp && make doctor', ("ask",), "chip step with --chip and --yes still asks"),
    # controls: the allow-list
    (1, 0, 'make hello', ("auto",), "control: make hello"),
    (1, 0, 'make test-hello-sim', ("auto",), "control: make test-hello-sim"),
    (1, 0, 'cd $R/CUDApp && make test-hello-sim', ("auto",), "control: cd $R/CUDApp && make"),
    (1, 0, 'cd "$R/omc-f4df8239" && sh seed/omega-from-seed.sh', ("auto",), "control: quoted cd, seed script"),
    (1, 0, 'cd $R/cuda-crack/receipts && sha256sum -c --quiet SHA256SUMS', ("auto",), "control: sha256sum -c"),
    (1, 0, 'git -C $R/CUDApp rev-parse HEAD', ("auto",), "control: git rev-parse"),
    (1, 0, 'git -C replica/omega-mv log --oneline -5', ("auto",), "control: git log"),
    (1, 0, 'ls -la $R', ("auto",), "control: ls"),
    (1, 0, 'cat $R/cuda-crack/README.md', ("auto",), "control: cat"),
    (1, 0, 'cat /nonexistent/replica/cuda-crack/README.md', ("auto",), "control: absolute path inside the workspace"),
    (1, 0, 'head -n 20 AGENT-PROMPT.md', ("auto",), "control: head"),
    (1, 0, 'wc -l $R/cuda-crack/receipts/SHA256SUMS', ("auto",), "control: wc"),
    (1, 0, 'grep -n PASS $R/cuda-crack/README.md', ("auto",), "control: grep -n"),
    (1, 0, 'uname -sm', ("auto",), "control: uname -sm"),
    (1, 0, 'nproc', ("auto",), "control: nproc"),
    (1, 0, 'free -h', ("auto",), "control: free"),
    (0, 0, 'make hello', ("ask",), "control: without --yes every command asks"),
]
for yes, chip, cmd, ok, what in cases:
    d = decide(load(yes, chip), cmd)
    shown = cmd.replace(chr(10), " " + chr(92) + "n ")
    print(("PASS" if d in ok else "FAIL") + f"  {d:6}  yes={yes} chip={chip}  {shown}  ({what})")
PY_EOF
rc=$?
cat "$tmp/py.out"
[ "$rc" = 0 ] || { echo "agent-gate: python3 failed (rc $rc)"; exit 2; }
pass=$(grep -c '^PASS' "$tmp/py.out")
fail=$(grep -c '^FAIL' "$tmp/py.out")

# --turns: an integer from 1 to 200, checked before anything is cloned. "--bogus" after it stops the run
# either way, so nothing is fetched.
mkdir "$tmp/home"
for t in abc 0 201 99999999999999999999 -5 ''; do
	out=$(env -i HOME="$tmp/home" PATH=/usr/bin:/bin sh "$script" --turns "$t" --bogus 2>&1)
	case $out in
	*"--turns needs an integer from 1 to 200"*) echo "PASS  --turns '$t' refused"; pass=$((pass + 1)) ;;
	*) echo "FAIL  --turns '$t' accepted"; fail=$((fail + 1)) ;;
	esac
done
out=$(env -i HOME="$tmp/home" PATH=/usr/bin:/bin sh "$script" --turns 200 --bogus 2>&1)
case $out in
*"unknown option --bogus"*) echo "PASS  --turns 200 accepted (control)"; pass=$((pass + 1)) ;;
*) echo "FAIL  --turns 200 not accepted"; fail=$((fail + 1)) ;;
esac

echo "agent-gate: $pass passed, $fail failed"
[ "$fail" = 0 ]
