#!/bin/sh
# tests/forge/lean.sh: machine-check tests/forge/Forge.lean, the Lean 4 model of the forge's rules.
#
#   sh tests/forge/lean.sh
#
# Uses LEAN (default: lean on PATH); checked with leanprover/lean4:v4.15.0, core Lean only. Checks:
#   1. Forge.lean checks with no error, warning or sorry
#   2. every theorem's #print axioms line names only propext, Classical.choice and Quot.sound
#   3. control: the same file with ' passed through unescaped (esc1 39 = [39]) must fail to check
# Prints PASS or FAIL per check, last line RC=0. Without lean: NOT_RUN and exit 3.
set -eu
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
L=${LEAN:-lean}
command -v "$L" > /dev/null 2>&1 || { echo "NOT_RUN forge lean: no $L (Lean 4 v4.15.0)"; exit 3; }
fail() { printf 'FAIL %s\n' "$*"; exit 1; }
pass() { printf 'PASS %s\n' "$*"; }
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
F=$R/tests/forge/Forge.lean
v=$("$L" --version)
"$L" "$F" > "$T/out" 2>&1 || { cat "$T/out"; fail "Forge.lean does not check with $v"; }
if grep -v "depends on axioms\|does not depend on any axioms" "$T/out" | grep -q .; then
  cat "$T/out"; fail "Forge.lean checks with messages other than #print axioms"
fi
n=$(grep -c "^'Forge\.[A-Za-z_]*' \(depends on axioms\|does not depend on any axioms\)" "$T/out" || true)
[ "$n" -eq "$(grep -c '^#print axioms' "$F")" ] || fail "expected one axioms line per #print axioms, got $n"
pass "Forge.lean checks with $v: $n theorems"
if sed -n "s/.*depends on axioms: \[\(.*\)\]/\1/p" "$T/out" | tr ',' '\n' | tr -d ' ' |
    grep -vx 'propext\|Classical.choice\|Quot.sound' | grep -q .; then
  fail "a theorem depends on an axiom beyond propext, Classical.choice and Quot.sound"
fi
pass "every theorem depends only on propext, Classical.choice and Quot.sound"
sed 's/^  else if b = 39 then eApos$/  else if b = 39 then [39]/' "$F" > "$T/Mutant.lean"
cmp -s "$F" "$T/Mutant.lean" && fail "control: the mutant edit did not apply"
if "$L" "$T/Mutant.lean" > "$T/mut" 2>&1; then fail "control: Forge.lean with ' unescaped still checks"; fi
grep -q 'error' "$T/mut" || fail "control: the mutant failed without an error"
pass "control: with ' passed through unescaped, the proofs fail"
echo RC=0
