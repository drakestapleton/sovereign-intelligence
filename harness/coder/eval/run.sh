#!/bin/sh
# Held-out eval for `aien --omega` (harness tooling, not product code).
# usage: sh run.sh ARM OUTDIR TASKDIR [TASK_ID...]
#   ARM     omega   - Omega context pack as the system prompt, pack readable
#           control - same model, tools, guard and check loop; rules-only prompt, no readable pack
#   TASKDIR holds TASK_ID/{spec.md,stdin,expected.out,expected.exit}; reference solutions live elsewhere
# Tasks run one after another (the live 35B takes serial requests only). Each task gets a fresh empty
# directory; the model must leave main.om there. Scoring is independent of the session: compile with
# the pinned omc, then run the om2 gate on the task's case line in a fresh scratch directory.
# Per task: OUTDIR/ID/{work/,cases.txt,transcript.jsonl,stderr,guard.log,score.log}; summary OUTDIR/results.tsv.
set -u
arm=${1:?arm: omega or control}
out=${2:?outdir}
tasks=${3:?taskdir}
shift 3
home=${OMEGA_HOME:-$HOME/.local/share/aien-omega}
omc="$home/omc"
sha=2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f
[ "$(sha256sum "$omc" | cut -d' ' -f1)" = "$sha" ] || { echo "pinned omc mismatch" >&2; exit 2; }
command -v aien > /dev/null || { echo "aien not on PATH" >&2; exit 2; }
case $arm in
omega) prompt_file="$home/context/OMEGA.md"; context="$home/context" ;;
control) prompt_file="$home/context/CONTROL.md" ;;
*) echo "arm must be omega or control" >&2; exit 2 ;;
esac
mkdir -p "$out" "$out/empty-context"
out=$(cd "$out" && pwd)
[ "$arm" = control ] && context="$out/empty-context"
ids=${*:-$(ls "$tasks")}
# Resumable: a task already scored in results.tsv is skipped; an interrupted task left no row and is re-run.
[ -s "$out/results.tsv" ] ||
	printf 'id\tverdict\tomc_rc\tgate_rc\tsession_rc\twall_s\tstop_refusals\tnon_om_files\n' > "$out/results.tsv"
for id in $ids; do
	if cut -f1 "$out/results.tsv" | grep -qx "$id"; then continue; fi
	t="$tasks/$id"
	d="$out/$id"
	rm -rf "$d"
	mkdir -p "$d/work"
	printf 'deadline 10\n%s run %s/work/main.om file:%s/stdin file:%s/expected.out - %s\n' \
		"$id" "$d" "$t" "$t" "$(cat "$t/expected.exit")" > "$d/cases.txt"
	if [ -s "$t/stdin" ]; then
		input="Standard input for the check (JSON string): $(jq -Rs . < "$t/stdin")"
	else
		input="Standard input for the check is empty."
	fi
	prompt="Task: $(cat "$t/spec.md")
$input
Write the program to main.om in the working directory, check it with omega_run, and finish only when it is correct."
	start=$(date +%s)
	(cd "$d/work" && OMEGA_HOME="$home" OMEGA_PROMPT="$prompt_file" OMEGA_CONTEXT="$context" \
		OMEGA_CASES="$d/cases.txt" OMEGA_STOP_LIMIT=5 OMEGA_LOG="$d/guard.log" \
		timeout 900 aien --omega -p --mode json --max-time 600 --no-session "$prompt" \
		> "$d/transcript.jsonl" 2> "$d/stderr")
	src=$?
	# 126/127: the session never started (not executable / not found). Scoring that as compile-fail would
	# count an infrastructure failure against the model; stop without writing a row so a rerun retries it.
	if [ "$src" -eq 126 ] || [ "$src" -eq 127 ]; then
		echo "$id: session did not start (rc $src), see $d/stderr; no row written" >&2
		exit 3
	fi
	wall=$(($(date +%s) - start))
	orc=NA
	grc=NA
	if [ ! -f "$d/work/main.om" ]; then
		verdict=compile-fail
		echo "no main.om" > "$d/score.log"
	else
		"$omc" < "$d/work/main.om" > "$d/main.elf" 2> "$d/score.log"
		orc=$?
		if [ "$orc" -ne 0 ]; then
			verdict=compile-fail
		else
			rm -rf "$d/scratch"
			(cd "$home" && ./gate "$omc" "$sha" "$d/cases.txt" "$d/scratch") >> "$d/score.log" 2>&1
			grc=$?
			if [ "$grc" -eq 0 ] && grep -q '^OM2GATE PASS ' "$d/score.log"; then verdict=pass; else verdict=wrong-output; fi
		fi
	fi
	refusals=$(grep -c 'stop refused' "$d/guard.log" 2>/dev/null || true)
	nonom=$(find "$d/work" -type f ! -name '*.om' ! -name NOTES.md | wc -l)
	printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$verdict" "$orc" "$grc" "$src" "$wall" "${refusals:-0}" "$nonom" >> "$out/results.tsv"
done
cat "$out/results.tsv"
