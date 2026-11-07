#!/bin/sh
# build.sh -- the sovereign stack build. Numbered steps, each PASS / FAIL / NOT_RUN.
# Everything is compiled by the seed-born Omega compilers in out/ and run on BOTH
# targets: AArch64 (out/omc, under qemu-aarch64-static on an x86 host) and x86-64
# (out/omc-x86, native). NOT_RUN marks a check that needs hardware we do not have
# (e.g. the GB10 GPU); NOT_RUN is never reported as PASS. The run prints RC=0 only
# when no step FAILed.
#
# Usage:  sh build.sh
# On an x86-64 host first:  apt-get install -y qemu-user-static
set -u

ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
cd "$ROOT"
WORK="$ROOT/.build"
rm -rf "$WORK"; mkdir -p "$WORK"

# ---- target runners -------------------------------------------------------
HOSTARCH=$(uname -m)
if [ "$HOSTARCH" = "aarch64" ]; then RUN_A=""; else RUN_A="qemu-aarch64-static"; fi
if ! command -v qemu-aarch64-static >/dev/null 2>&1 && [ -n "$RUN_A" ]; then
  echo "FATAL: qemu-aarch64-static not found; install qemu-user-static" >&2; exit 2
fi

# ---- tallies --------------------------------------------------------------
NPASS=0; NFAIL=0; NNR=0
pass()  { NPASS=$((NPASS+1)); printf '    PASS    %s\n' "$1"; }
fail()  { NFAIL=$((NFAIL+1)); printf '    FAIL    %s\n' "$1"; }
notrun(){ NNR=$((NNR+1));     printf '    NOT_RUN %s\n' "$1"; }
step()  { printf '[%s] %s\n' "$1" "$2"; }

# ---- compile / run helpers -------------------------------------------------
# comp_a SRC OUT : compile SRC for AArch64; echoes omc exit status
comp_a() { $RUN_A ./out/omc < "$1" > "$2" 2>"$2.err"; echo $?; }
# comp_x SRC OUT : compile SRC for x86-64 (prepend the exact target line)
comp_x() { { echo 'target x86linux'; cat "$1"; } | ./out/omc-x86 > "$2" 2>"$2.err"; echo $?; }
run_a()  { $RUN_A "$1"; }   # run an AArch64 ELF
run_x()  { "$1"; }          # run a native x86 ELF

# checksum file verify (GNU coreutils --check)
sumcheck() { sha256sum -c "$1" >/dev/null 2>&1; }

echo "=== sovereign stack build  (host $HOSTARCH; aarch64 via '${RUN_A:-native}') ==="

# ===========================================================================
step 1 "foundation integrity (vendored toolchain + harness pinned by sha256)"
if sumcheck out/SHA256SUMS; then pass "out/SHA256SUMS (omc, omc-x86, omc.om)"; else fail "out/SHA256SUMS mismatch"; fi
if sumcheck harness/SHA256SUMS; then pass "harness/SHA256SUMS ($(wc -l < harness/SHA256SUMS) skill files)"; else fail "harness/SHA256SUMS mismatch"; fi

# ===========================================================================
step 2 "seed self-hosting fixpoint (omc compiles omc.om -> omc, byte-for-byte)"
rc=$(comp_a out/omc.om "$WORK/omc.rebuilt")
if [ "$rc" = 0 ] && cmp -s out/omc "$WORK/omc.rebuilt"; then
  pass "fixpoint $(sha256sum out/omc | cut -c1-16)... reproduced"
else
  fail "fixpoint not reproduced (omc rc=$rc)"
fi

# ===========================================================================
step 3 "dual-target probe + negative control"
# positive: hello must compile and print 'hello, world' on both targets
rc=$(comp_a stack/probe/hello.om "$WORK/hello.a"); chmod +x "$WORK/hello.a" 2>/dev/null
if [ "$rc" = 0 ] && [ "$(run_a "$WORK/hello.a" 2>/dev/null)" = "hello, world" ]; then
  pass "hello AArch64"; else fail "hello AArch64 (omc rc=$rc)"; fi
rc=$(comp_x stack/probe/hello.om "$WORK/hello.x"); chmod +x "$WORK/hello.x" 2>/dev/null
if [ "$rc" = 0 ] && [ "$(run_x "$WORK/hello.x" 2>/dev/null)" = "hello, world" ]; then
  pass "hello x86-64"; else fail "hello x86-64 (omc rc=$rc)"; fi
# negative control: omc MUST reject reject.om (nonzero) on both targets
rc=$(comp_a stack/probe/reject.om "$WORK/reject.a")
if [ "$rc" != 0 ]; then pass "negative control rejected AArch64 (omc rc=$rc)"; else fail "negative control COMPILED AArch64 (checks have no teeth)"; fi
rc=$(comp_x stack/probe/reject.om "$WORK/reject.x")
if [ "$rc" != 0 ]; then pass "negative control rejected x86-64 (omc rc=$rc)"; else fail "negative control COMPILED x86-64 (checks have no teeth)"; fi

# ===========================================================================
step 4 "ledger: Omega vs foreign source lines (both targets, must agree)"
rc=$(comp_a tools/ledger.om "$WORK/ledger.a"); chmod +x "$WORK/ledger.a" 2>/dev/null
rc2=$(comp_x tools/ledger.om "$WORK/ledger.x"); chmod +x "$WORK/ledger.x" 2>/dev/null
# tracked + untracked (not ignored) paths, minus vendored binaries the ledger shouldn't open
if git rev-parse --git-dir >/dev/null 2>&1; then
  git ls-files -co --exclude-standard
else
  find . -type f | sed 's,^\./,,'
fi 2>/dev/null | grep -Ev '^(out/omc|out/omc-x86)$|\.bin$' | LC_ALL=C sort > "$WORK/files.lst"
LA=$($RUN_A "$WORK/ledger.a" < "$WORK/files.lst" 2>/dev/null)
LX=$(run_x "$WORK/ledger.x" < "$WORK/files.lst" 2>/dev/null)
if [ "$rc" = 0 ] && [ "$rc2" = 0 ] && [ -n "$LA" ] && [ "$LA" = "$LX" ]; then
  pass "ledger builds+runs on both targets, output agrees"
  printf '%s\n' "$LA" | sed 's/^/            /'
else
  if [ "$LA" = "$LX" ]; then agree=agree; else agree=DIFFER; fi
  fail "ledger (aarch64 rc=$rc, x86 rc=$rc2, outputs $agree)"
fi

# ===========================================================================
step 5 "gpu/cuda-crack: Omega sm_121 encoder reproduces the 70 chip kernels (both targets); GPU execution NOT_RUN"
CC="$ROOT/gpu/cuda-crack"
E3="receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z"
# x86-64 (native): run cuda-crack's own check/check.sh verbatim
cat > "$WORK/omc-x86-wrap" <<EOF
#!/bin/sh
{ printf 'target x86linux\n'; cat; } | "$ROOT/out/omc-x86"
EOF
chmod +x "$WORK/omc-x86-wrap"
if ( cd "$CC" && OMC="$WORK/omc-x86-wrap" sh check/check.sh >"$WORK/cc.x86.log" 2>&1 ) && grep -q '^ALL CHECKS PASS$' "$WORK/cc.x86.log"; then
  pass "x86-64: check/check.sh verbatim -> ALL CHECKS PASS (70 kernels, 4 mutant controls)"
else
  fail "x86-64: check/check.sh did not reach ALL CHECKS PASS (see $WORK/cc.x86.log)"
fi
# AArch64 (via qemu): reencode reproduces the 70 kernels + D/F consistency.
# (check.sh execs the compiled ELF directly, which cannot be an AArch64 binary on
#  an x86 host without binfmt, so the same checks are driven here under qemu.)
FORMS="$CC/isa/sm121-forms.txt"
rc=$(comp_a "$CC/check/reencode.om" "$WORK/reencode.a"); chmod +x "$WORK/reencode.a" 2>/dev/null
rcx=$(comp_x "$CC/check/reencode.om" "$WORK/reencode.x"); chmod +x "$WORK/reencode.x" 2>/dev/null
if [ "$rc" = 0 ]; then
  { cat "$FORMS"; printf 'E\n'; } | $RUN_A "$WORK/reencode.a" >/dev/null 2>/dev/null; df=$?
  mm=0; n=0
  for k in "$CC/$E3"/kernels-om/*.bin; do
    n=$((n+1))
    { cat "$FORMS"; printf 'E\n'; cat "$k"; } | $RUN_A "$WORK/reencode.a" > "$WORK/rb.bin" 2>/dev/null || true
    cmp -s "$WORK/rb.bin" "$k" || mm=$((mm+1))
  done
  if [ "$df" = 0 ] && [ "$mm" = 0 ] && [ "$n" = 70 ]; then
    pass "AArch64 (qemu): D/F ok, 70/70 kernels reproduced byte-for-byte"
  else
    fail "AArch64: D/F=$df mismatches=$mm/$n"
  fi
else
  fail "AArch64: reencode.om did not compile (omc rc=$rc)"
fi
# Seeded-Omega rewrite of check.sh's mutant-3 transform (check/tblmut.om): differential
# test vs the awk original, then used as the LIVE negative control -- the Omega-mutated
# table must make reencode refuse (exit 7) -- on both targets.
awk 'd==0 && $1=="D" && $8>1 {$8=$8-1; d=1} {print}' "$FORMS" > "$WORK/mut3.oracle"
rcm=$(comp_a "$CC/check/tblmut.om" "$WORK/tblmut.a"); chmod +x "$WORK/tblmut.a" 2>/dev/null
rcmx=$(comp_x "$CC/check/tblmut.om" "$WORK/tblmut.x"); chmod +x "$WORK/tblmut.x" 2>/dev/null
$RUN_A "$WORK/tblmut.a" < "$FORMS" > "$WORK/mut3.a" 2>/dev/null
run_x "$WORK/tblmut.x" < "$FORMS" > "$WORK/mut3.x" 2>/dev/null
da=1; dx=1
cmp -s "$WORK/mut3.oracle" "$WORK/mut3.a" && da=0
cmp -s "$WORK/mut3.oracle" "$WORK/mut3.x" && dx=0
{ cat "$WORK/mut3.a"; printf 'E\n'; } | $RUN_A "$WORK/reencode.a" >/dev/null 2>/dev/null; ca=$?
{ cat "$WORK/mut3.x"; printf 'E\n'; } | run_x "$WORK/reencode.x" >/dev/null 2>/dev/null; cx=$?
if [ "$rcm" = 0 ] && [ "$rcmx" = 0 ] && [ "$da" = 0 ] && [ "$dx" = 0 ] && [ "$ca" = 7 ] && [ "$cx" = 7 ]; then
  pass "tblmut.om == awk original (differential, both targets); drives reencode refusal exit 7 on both"
else
  fail "tblmut.om (compile a=$rcm x=$rcmx; diff a=$da x=$dx; reencode a=$ca x=$cx want 7)"
fi
notrun "cuda-crack GPU execution (hello-gpu, chip corpus, GEMM/attention) -- needs NVIDIA GB10 + driver 580.173.02 (lives in CUDApp); host receipts under gpu/cuda-crack/receipts are verified, not re-run"

# ===========================================================================
# >>> STACK-STEPS-INSERT <<<

# ===========================================================================
echo "=== summary: $NPASS pass, $NFAIL fail, $NNR not_run ==="
if [ "$NNR" -gt 0 ]; then echo "    (NOT_RUN items need hardware absent here; they are not counted as PASS)"; fi
if [ "$NFAIL" -eq 0 ]; then echo "RC=0"; exit 0; else echo "RC=1"; exit 1; fi
