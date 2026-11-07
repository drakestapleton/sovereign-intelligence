#!/bin/sh
# Build the Omega-only context pack read by `aien --omega` (harness config, not product code).
# usage: OMEGA_MV=/path/to/omega-mv OMC=/path/to/pinned/omc sh coder/build-context.sh OUTDIR
# Writes OUTDIR/OMEGA.md (system prompt: rules + language reference + compiled examples) and
# OUTDIR/CONTROL.md (rules only, for the no-context eval arm). Every example must compile with OMC.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
skill="$here/../skills/omega-encoding"
mv=${OMEGA_MV:?set OMEGA_MV to an omega-mv checkout}
omc=${OMC:?set OMC to the pinned omc}
out=${1:?usage: build-context.sh OUTDIR}
mkdir -p "$out"
tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp.elf"' EXIT

{
	cat "$here/omega-prompt-head.md"
	printf '\n# Omega language reference\n\n'
	# Sections 2..11 of the omega-encoding skill; citation links are dropped to save tokens.
	awk '/^## 2\. /{on=1} /^## 11a\. /{on=0} on' "$skill/SKILL.md" |
		sed -E 's/ ?\((\[[^]]*\]\([^)]*\)(, ?)?)+\)//g; s/\[([^]]*)\]\([^)]*\)/\1/g'
	cat "$here/omega-observed.md"
	printf '\n# Examples (each compiles with the pinned omc)\n'
	for f in "$skill/examples/fnv1a32.om" "$skill/examples/trap_narrow.om" \
		"$mv/seed/rung4/tests/echo.om" "$mv/seed/rung4/tests/fib.om" "$mv/seed/omc/tests/text.om" \
		"$mv/seed/omc/tests/loop/c1.om" "$mv/seed/omc/tests/loop/w1.om" "$mv/seed/omc/tests/float/structs.om"; do
		"$omc" < "$f" > "$tmp.elf" || { echo "example does not compile: $f" >&2; exit 1; }
		printf '\n## %s\n\n```\n' "$(basename "$f")"
		cat "$f"
		printf '```\n'
	done
} > "$tmp"
mv "$tmp" "$out/OMEGA.md"
cp "$here/omega-prompt-head.md" "$out/CONTROL.md"
