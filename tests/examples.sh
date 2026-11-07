#!/bin/sh
# tests/examples.sh OMC_A64 OMC_X86 [QEMU_A64]
#
# Compiles and runs every worked example of the Omega harness (harness/examples/*.om and
# harness/skills/*/examples/*.om) on two targets, against the same NAME.expect files that
# harness/examples/gate.sh reads, with the same meaning:
#   compile N         required; the compiler's exit status
#   stderr LINE       required when N is not 0; the compiler's whole stderr is exactly LINE
#   exit N            required when N is 0; the program's exit status
#   input dir         optional; the compiler reads a directory instead of NAME.om (error 1)
#   output full       optional; the compiler writes to /dev/full (error 2)
# Optional fixtures: NAME.stdout (exact stdout bytes, absent means empty), NAME.stdin (piped in),
# NAME.args (one argument per line), NAME.env (one KEY=VALUE per line). Every program runs with
# `env -i` plus NAME.env, in its own empty scratch directory, under a 20 s timeout, and must write
# nothing to stderr. A compile that is not expected to succeed is never run.
#
# Unlike gate.sh this runner pins no compiler hash: the compilers are the ones the build grew from
# the seed, and the build checks their hashes itself.
#
# Targets:
#   a64  OMC_A64 (an AArch64 omc) compiles the unit as written; the AArch64 program runs.
#        On an AArch64 host both run directly; elsewhere both run under QEMU_A64
#        (default qemu-aarch64-static). Without it every a64 case is NOT_RUN.
#   x86  OMC_X86 (an x86-64 omc) compiles `target x86linux`, a newline, then the unit; the
#        x86-64 program runs. On an x86-64 host both run natively; elsewhere both run under
#        qemu-x86_64(-static) when present, otherwise every x86 case is NOT_RUN.
#        Line numbers: the prepended target line makes the x86 compiler report every source
#        line one higher, so each `omc: line M: error K` line of an x86 compile is compared as
#        `omc: line M-1: error K` (line 0, no line read, stays 0). A unit that selects its own
#        mode at byte 0 (`target `, `ir`, `check`, `next`, `om2 fmt`) cannot take a second
#        selector, so the x86-hosted compiler reads it unchanged and no line shift applies; if
#        such a unit is expected to compile, its output is not an x86 program and the run is
#        NOT_RUN. An `input dir` case also reads the directory unchanged.
#
# tests/examples.known, optional: lines `TARGET NAME reason` (NAME as printed, e.g.
# examples/hello) for confirmed divergences. A listed case that fails prints KNOWN; one that
# passes prints FIXED and fails the run, so the list is pruned; a line naming no case fails too.
#
# EXAMPLES_ONLY=a64 or EXAMPLES_ONLY=x86 runs one target. Exit 0 when nothing FAILs, 1 on any
# FAIL or FIXED, 2 on a usage error.
set -u

usage() { echo "usage: sh $0 OMC_A64 OMC_X86 [QEMU_A64]" >&2; exit 2; }
[ "$#" -ge 2 ] && [ "$#" -le 3 ] || usage

abspath() {
    [ -f "$1" ] || { echo "examples: no such file: $1" >&2; exit 2; }
    printf '%s/%s\n' "$(cd "$(dirname "$1")" && pwd)" "$(basename "$1")"
}
A64=$(abspath "$1")
X86=$(abspath "$2")
QA=${3:-qemu-aarch64-static}
ONLY=${EXAMPLES_ONLY:-}
case $ONLY in ''|a64|x86) ;; *) usage ;; esac

here=$(cd "$(dirname "$0")" && pwd)
root=$(dirname "$here")/harness
known=$here/examples.known
[ -d "$root/examples" ] || { echo "examples: no $root/examples" >&2; exit 2; }

host=$(uname -m)
# arun / xrun: the emulator that runs that target's binaries on this host ('' = run directly);
# anot / xnot: why that target cannot run here ('' = it can).
arun= anot= xrun= xnot=
case $host in
    aarch64|arm64) ;;
    *) arun=$(command -v "$QA" 2>/dev/null) || { arun=; anot="no $QA on this $host host"; } ;;
esac
case $host in
    x86_64|amd64) ;;
    *) xrun=$(command -v qemu-x86_64-static 2>/dev/null || command -v qemu-x86_64 2>/dev/null) ||
           { xrun=; xnot="no qemu-x86_64 on this $host host"; } ;;
esac

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

a_pass=0 a_fail=0 a_not=0 a_known=0
x_pass=0 x_fail=0 x_not=0 x_known=0

# report TGT NAME VERDICT REASON [raw]: apply tests/examples.known (unless raw), print one line, count it
report() {
    tgt=$1 nm=$2 verdict=$3 why=$4
    listed=0
    if [ "${5:-}" != raw ] && [ -f "$known" ] && awk -v t="$tgt" -v n="$nm" '$1 == t && $2 == n { f = 1 } END { exit !f }' "$known"; then
        listed=1
        echo "$tgt $nm" >> "$work/known-hit"
    fi
    if [ "$listed" = 1 ] && [ "$verdict" = FAIL ]; then
        verdict=KNOWN
    elif [ "$listed" = 1 ] && [ "$verdict" = PASS ]; then
        verdict=FIXED why="passes now; remove it from tests/examples.known"
    fi
    if [ -n "$why" ]; then printf '%s %s %s: %s\n' "$verdict" "$tgt" "$nm" "$why"; else printf '%s %s %s\n' "$verdict" "$tgt" "$nm"; fi
    case $tgt.$verdict in
        a64.PASS) a_pass=$((a_pass + 1)) ;;
        a64.NOT_RUN) a_not=$((a_not + 1)) ;;
        a64.KNOWN) a_known=$((a_known + 1)) ;;
        a64.*) a_fail=$((a_fail + 1)) ;;
        x86.PASS) x_pass=$((x_pass + 1)) ;;
        x86.NOT_RUN) x_not=$((x_not + 1)) ;;
        x86.KNOWN) x_known=$((x_known + 1)) ;;
        x86.*) x_fail=$((x_fail + 1)) ;;
    esac
}

# with EMU CMD...: run CMD, under the emulator EMU when it is not empty
with() {
    e=$1; shift
    if [ -n "$e" ]; then "$e" "$@"; else "$@"; fi
}

# one TGT SRC: compile and run one example for one target, then report it
one() {
    tgt=$1 src=$2
    base=${src%.om}
    nm=${base#"$root"/}
    if [ "$tgt" = a64 ]; then omc=$A64 emu=$arun not=$anot; else omc=$X86 emu=$xrun not=$xnot; fi
    if [ -n "$not" ]; then report "$tgt" "$nm" NOT_RUN "$not"; return; fi
    if [ ! -f "$base.expect" ]; then report "$tgt" "$nm" FAIL "no $nm.expect"; return; fi
    want_compile= want_stderr= want_exit= input=file output=file
    while IFS= read -r line || [ -n "$line" ]; do
        case $line in
            "compile "*) want_compile=${line#compile } ;;
            "stderr "*) want_stderr=${line#stderr } ;;
            "exit "*) want_exit=${line#exit } ;;
            "input dir") input=dir ;;
            "output full") output=full ;;
            "") ;;
            *) want_compile=invalid ;;
        esac
    done < "$base.expect"
    case $want_compile in
        ''|invalid|*[!0-9]*) report "$tgt" "$nm" FAIL "malformed $nm.expect"; return ;;
    esac
    if [ "$want_compile" != 0 ] && [ -z "$want_stderr" ]; then
        report "$tgt" "$nm" FAIL "$nm.expect has no stderr line"; return
    fi
    if [ "$want_compile" = 0 ]; then
        case $want_exit in
            ''|*[!0-9]*) report "$tgt" "$nm" FAIL "$nm.expect has no exit line"; return ;;
        esac
    fi

    d=$work/$tgt/$(printf '%s' "$nm" | tr / _)
    mkdir -p "$d/run"
    in=$src
    shift_lines=0
    if [ "$input" = dir ]; then
        in=$d/run
    elif [ "$tgt" = x86 ]; then
        if head -c 7 "$src" | grep -q '^target ' ||
           head -n 1 "$src" | grep -Eq '^(ir|check|next|om2 fmt)([ 	]|$)'; then
            if [ "$want_compile" = 0 ]; then
                report "$tgt" "$nm" NOT_RUN "the unit selects its own mode at byte 0, so its program is not x86"
                return
            fi
        else
            { printf 'target x86linux\n'; cat "$src"; } > "$d/unit.om"
            in=$d/unit.om
            shift_lines=1
        fi
    fi
    out=$d/p
    [ "$output" = full ] && out=/dev/full
    with "$emu" "$omc" < "$in" > "$out" 2> "$d/cerr.raw"
    rc=$?
    if [ "$shift_lines" = 1 ]; then
        awk '/^omc: line [0-9]+: error [0-9]+$/ { n = $3 + 0; if (n > 0) n = n - 1; print "omc: line " n ": error " $5; next } { print }' \
            "$d/cerr.raw" > "$d/cerr"
    else
        cp "$d/cerr.raw" "$d/cerr"
    fi
    if [ "$rc" != "$want_compile" ]; then
        report "$tgt" "$nm" FAIL "compile exit $rc, expected $want_compile: $(head -c 200 "$d/cerr")"
        return
    fi
    if [ "$want_compile" != 0 ]; then
        if printf '%s\n' "$want_stderr" | cmp -s - "$d/cerr"; then
            report "$tgt" "$nm" PASS ""
        else
            report "$tgt" "$nm" FAIL "compiler stderr '$(head -c 200 "$d/cerr")', expected '$want_stderr'"
        fi
        return
    fi
    if [ -s "$d/cerr" ]; then
        report "$tgt" "$nm" FAIL "compiler stderr not empty: $(head -c 200 "$d/cerr")"
        return
    fi

    chmod +x "$d/p"
    (
        cd "$d/run" || exit 125
        set --
        if [ -f "$base.env" ]; then
            while IFS= read -r kv || [ -n "$kv" ]; do set -- "$@" "$kv"; done < "$base.env"
        fi
        [ -n "$emu" ] && set -- "$@" "$emu"
        set -- "$@" "$d/p"
        if [ -f "$base.args" ]; then
            while IFS= read -r a || [ -n "$a" ]; do set -- "$@" "$a"; done < "$base.args"
        fi
        if [ -f "$base.stdin" ]; then
            cat "$base.stdin" | timeout 20 env -i "$@" > "$d/out" 2> "$d/rerr"
        else
            timeout 20 env -i "$@" < /dev/null > "$d/out" 2> "$d/rerr"
        fi
    )
    rc=$?
    want_out=/dev/null
    [ -f "$base.stdout" ] && want_out=$base.stdout
    if [ "$rc" != "$want_exit" ]; then
        report "$tgt" "$nm" FAIL "exit $rc, expected $want_exit"
    elif ! cmp -s "$want_out" "$d/out"; then
        report "$tgt" "$nm" FAIL "stdout differs from $(basename "$want_out"): $(od -An -c "$d/out" | tr -s ' ' | tr -d '\n' | cut -c1-200)"
    elif [ -s "$d/rerr" ]; then
        report "$tgt" "$nm" FAIL "program stderr not empty: $(head -c 200 "$d/rerr")"
    else
        report "$tgt" "$nm" PASS ""
    fi
}

: > "$work/known-hit"
for tgt in a64 x86; do
    [ -z "$ONLY" ] || [ "$ONLY" = "$tgt" ] || continue
    # An expectation without its program is a silent loss of coverage, so it fails.
    for f in "$root"/examples/*.expect "$root"/skills/*/examples/*.expect; do
        [ -e "$f" ] || continue
        [ -e "${f%.expect}.om" ] || report "$tgt" "$(printf '%s' "${f%.expect}" | sed "s|^$root/||")" FAIL "expect file without its .om"
    done
    for src in "$root"/examples/*.om "$root"/skills/*/examples/*.om; do
        [ -e "$src" ] || continue
        one "$tgt" "$src"
    done
done

# A known-divergence line that named no case is stale.
if [ -f "$known" ]; then
    while read -r t n rest || [ -n "$t" ]; do
        case $t in ''|'#'*) continue ;; esac
        [ -z "$ONLY" ] || [ "$ONLY" = "$t" ] || continue
        if ! grep -qx "$t $n" "$work/known-hit"; then
            report "$t" "$n" FAIL "tests/examples.known names a case that does not exist" raw
        fi
    done < "$known"
fi

total=$((a_pass + a_fail + a_not + a_known + x_pass + x_fail + x_not + x_known))
if [ "$total" = 0 ]; then echo "EXAMPLES none found under $root"; exit 1; fi
if [ -f "$known" ]; then
    echo "EXAMPLES a64 pass=$a_pass fail=$a_fail notrun=$a_not known=$a_known x86 pass=$x_pass fail=$x_fail notrun=$x_not known=$x_known"
else
    echo "EXAMPLES a64 pass=$a_pass fail=$a_fail notrun=$a_not x86 pass=$x_pass fail=$x_fail notrun=$x_not"
fi
[ "$a_fail" = 0 ] && [ "$x_fail" = 0 ]
