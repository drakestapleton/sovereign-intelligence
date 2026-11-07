#!/bin/sh
# evidence/x86-native/run.sh: omega-mv's FR-9 x86 corpus oracle, run on an x86-64 host.
#
#   sh evidence/x86-native/run.sh OMEGA_MV OMEGA_BRIDGE WORK
#
# OMEGA_MV is a clone of omega-mv (rad:z6do9WDBhuSnvopDkgFdFr1yWA62) and OMEGA_BRIDGE a clone of
# omega-bridge (rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y), each holding the commit pinned below; WORK is a new
# directory. Run sh build.sh first: the compilers under test are its out/omc and out/omc-x86.
#
# The oracle is omega-mv's seed/omc/qualify-x86.py at MV_REV with qualify-x86-native.patch applied.
# The patch adds --host x86-native and changes no assertion: x86-64 programs run directly, AArch64
# programs run under qemu-aarch64. The corpus's own exec children (conductors, helpers) are AArch64,
# so the kernel must hand AArch64 ELF files to qemu-aarch64 through binfmt_misc, with argv[0] kept
# (flag P). On Ubuntu 24.04, as root:
#   apt-get install qemu-user-static gcc-aarch64-linux-gnu libc6-dev-arm64-cross jq xz-utils
#   mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc   # if it is not mounted
#   cat /usr/lib/binfmt.d/qemu-aarch64.conf > /proc/sys/fs/binfmt_misc/register
# The oracle checks that entry, and that no entry takes x86-64 programs away from the kernel.
#
# WORK receives qualify.jsonl (every row the oracle printed), qualify.err, compilers.tsv and
# receipt.json. Exit status: the oracle's (0 only when every row is PASS or EXCLUDED).
set -eu
[ $# -eq 3 ] || { echo "usage: sh evidence/x86-native/run.sh OMEGA_MV OMEGA_BRIDGE WORK" >&2; exit 2; }
R=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
MV=$(cd "$1" && pwd)
BR=$(cd "$2" && pwd)
mkdir "$3"
W=$(cd "$3" && pwd)

MV_REV=6fbc6cbe4bfa4092608e2b5f06d2e8f537893992
BRIDGE_REV=1958a1895279c0d4869bab39eaa20f070b174a6c
BASELINE_REV=e17039d9ceeb30e0637ef4145e37afc5821c3773
ORACLE_SHA256=206d6cf26f2df74aa2017715444bd61a0fe3c208cda6f60170c7ca3b819431ce
PATCHED_SHA256=07746827bf3b6bc349f7b580533d4e2d75914b61970bb933f95b9b897684aef3
DRIVERS_SHA256=672cbc99c98568866abaf49e3944c98dc893ab3bd7906e806ff5c678dd95624b
BASELINE_SHA256=734f0a39319fbfa930bcc62cb30dbf06d47d78e126372b74f5baf478e6126b61

fail() { printf 'run.sh: %s\n' "$*" >&2; exit 1; }
sha() { sha256sum < "$1" | cut -c1-64; }
[ "$(uname -m)" = x86_64 ] || fail "this is the x86-64 host run; on AArch64 run the oracle unpatched"
for f in out/omc out/omc-x86; do [ -x "$R/$f" ] || fail "$f missing: run sh build.sh first"; done
want() { # want NAME FILE: FILE must have the sha256 seed/PINS.tsv gives NAME
  pin=$(awk -F'\t' -v n="$1" '$1 == n { print $3 }' "$R/seed/PINS.tsv")
  [ "$(sha "$2")" = "$pin" ] || fail "$2 is not the pinned $1"
}
want omc "$R/out/omc"
want omc-x86 "$R/out/omc-x86"

# The oracle tree: omega-mv at MV_REV, the oracle patched and nothing else changed.
git -C "$MV" worktree add --detach "$W/omega-mv" "$MV_REV" > /dev/null 2>&1 || fail "omega-mv has no commit $MV_REV"
O=$W/omega-mv/seed/omc
[ "$(sha "$O/qualify-x86.py")" = "$ORACLE_SHA256" ] || fail "qualify-x86.py at $MV_REV is not the reviewed one"
[ "$(sha "$O/x86_corpus_drivers.py")" = "$DRIVERS_SHA256" ] || fail "x86_corpus_drivers.py at $MV_REV is not the reviewed one"
git -C "$W/omega-mv" apply "$R/evidence/x86-native/qualify-x86-native.patch"
[ "$(sha "$O/qualify-x86.py")" = "$PATCHED_SHA256" ] || fail "patched qualify-x86.py has an unexpected sha256"
git -C "$BR" worktree add --detach "$W/omega-bridge" "$BRIDGE_REV" > /dev/null 2>&1 || fail "omega-bridge has no commit $BRIDGE_REV"
git -C "$MV" show "$BASELINE_REV:seed/out/omc" > "$W/baseline-omc"
chmod +x "$W/baseline-omc"
[ "$(sha "$W/baseline-omc")" = "$BASELINE_SHA256" ] || fail "baseline compiler at $BASELINE_REV is not $BASELINE_SHA256"

# Every compiler the oracle runs that it does not itself print: the four historical candidates it
# bootstraps with the baseline (qualify-x86.py HISTORICAL_COMPILERS), rebuilt here the same way when
# their commit is in OMEGA_MV. The oracle fails the rows that need an absent one.
{
  printf 'role\tsha256\tmade_by\n'
  printf 'omc\t%s\tsh build.sh (seed/PINS.tsv)\n' "$(sha "$R/out/omc")"
  printf 'omc-x86\t%s\tsh build.sh (seed/PINS.tsv); --x86-compiler\n' "$(sha "$R/out/omc-x86")"
  printf 'baseline\t%s\tgit %s:seed/out/omc\n' "$(sha "$W/baseline-omc")" "$BASELINE_REV"
  for c in s1:a5927895c02a5abe6b5c3a455f5d54303962ebe8 s2:7fb62f3a87104f48bb1317ab05333c5805ce5340 \
           s3:ad220c054b2e018a985384a33bf09b9f0d612787 s4:f6a6492fd1a3b608f0413a75685ddbb712075a73; do
    if git -C "$MV" cat-file -e "${c#*:}:seed/omc/omc.om" 2> /dev/null; then
      git -C "$MV" show "${c#*:}:seed/omc/omc.om" | "$W/baseline-omc" > "$W/cand-${c%%:*}"
      printf 'cand-%s\t%s\tbaseline from git %s:seed/omc/omc.om\n' "${c%%:*}" "$(sha "$W/cand-${c%%:*}")" "${c#*:}"
    else
      printf 'cand-%s\tABSENT\tcommit %s is not in OMEGA_MV\n' "${c%%:*}" "${c#*:}"
    fi
  done
} > "$W/compilers.tsv"

mkdir "$W/tmp"
set -- python3 seed/omc/qualify-x86.py --host x86-native \
  --compiler "$R/out/omc" --x86-compiler "$R/out/omc-x86" --qemu-aarch64 qemu-aarch64-static \
  --bridge "$W/omega-bridge/tools/native" --bridge-baseline-compiler "$W/baseline-omc" \
  --objdump x86_64-linux-gnu-objdump
start=$(date -u +%Y-%m-%dT%H:%M:%SZ)
rc=0
(cd "$W/omega-mv" && TMPDIR="$W/tmp" "$@") > "$W/qualify.jsonl" 2> "$W/qualify.err" || rc=$?
end=$(date -u +%Y-%m-%dT%H:%M:%SZ)
rm -rf "$W/tmp"

# The receipt: the oracle's own header, metadata and summary lines verbatim, every row that is not
# PASS or EXCLUDED, and the pins. Nothing is recounted here.
n=$(wc -l < "$W/qualify.jsonl")
jq -s --arg start "$start" --arg end "$end" --argjson exit "$rc" --arg command "$*" \
  --arg mv "$MV_REV" --arg bridge "$BRIDGE_REV" --arg oracle "$ORACLE_SHA256" --arg patched "$PATCHED_SHA256" \
  --arg patch "$(sha "$R/evidence/x86-native/qualify-x86-native.patch")" --arg drivers "$DRIVERS_SHA256" \
  --arg bridge_tool "$(sha "$W/omega-bridge/tools/native")" --arg nproc "$(nproc)" \
  --arg a64cc "$(aarch64-linux-gnu-gcc --version | sed -n 1p)" --arg x86cc "$(x86_64-linux-gnu-gcc --version | sed -n 1p)" \
  --arg objdump "$(x86_64-linux-gnu-objdump --version | sed -n 1p)" --arg python "$(python3 --version)" \
  --arg jsonl_sha "$(sha "$W/qualify.jsonl")" --argjson jsonl_bytes "$(wc -c < "$W/qualify.jsonl")" \
  --rawfile compilers "$W/compilers.tsv" '
  .[0] as $header | .[1] as $meta | .[-1] as $final |
  [.[] | select(.status? and .status != "PASS" and .status != "EXCLUDED")] as $other |
  {schema: 1, date: ($start[0:10]), started: $start, finished: $end,
   execution: "NATIVE_X86_64", aarch64_arm: "EMULATED (qemu-aarch64 via binfmt_misc)",
   source_commit: $mv, command: $command, exit: $exit,
   summary: $final.summary, verdict: $final.verdict,
   host: {cpu_model: $meta.cpu_model, nproc: ($nproc | tonumber), kernel: $meta.kernel, platform: $meta.platform,
          qemu_aarch64: $meta.qemu_aarch64, qemu_aarch64_sha256: $meta.qemu_aarch64_sha256,
          qemu_aarch64_version: ($meta.qemu_aarch64_version | split("\n")[0]), binfmt: $meta.binfmt,
          objdump: $objdump, aarch64_cc: $a64cc, x86_64_cc: $x86cc, python: $python},
   compilers: ($compilers | split("\n")[1:] | map(select(length > 0) | split("\t") | {role: .[0], sha256: .[1], made_by: .[2]})),
   compilers_in_rows: {
     x86_hosted_frontend: ([.[] | .evidence?.frontend_compiler?.x86_compiler_sha256? // empty] | unique),
     generation_ceiling_variant: ([.[] | .evidence?.generation_ceiling_whitebox?.variant_compiler_sha256? // empty] | unique),
     bridge_selected: ([.[] | .bridge_result?.observations?[]?.compiler_sha256? // empty] | unique),
     bridge_baseline: ([.[] | .bridge_result?.observations?[]?.baseline_compiler_sha256? // empty] | unique)},
   oracle: {checker_sha256: $header.checker_sha256, original_checker_sha256: $oracle, patched_checker_sha256: $patched,
            patch_sha256: $patch, driver_sha256: $header.driver_sha256, reviewed_driver_sha256: $drivers,
            source_revision_contract: $header.source_revision_contract, compiler_source_sha256: $header.compiler_source_sha256,
            inventory_files: $header.inventory_files},
   bridge: {repo: "omega-bridge rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y", commit: $bridge, tool_sha256: $bridge_tool},
   reasons: $final.reasons,
   not_pass: [$other[] | {status, case, reason, source_sha256}],
   negative_controls: [.[] | select(.case? and (.case | startswith("negative-")))],
   coverage_limits: $final.coverage_limits,
   jsonl_rows: (length), jsonl_bytes: $jsonl_bytes, jsonl_sha256: $jsonl_sha}' \
  "$W/qualify.jsonl" > "$W/receipt.json"
printf 'run.sh: %s rows, oracle exit %s, receipt %s\n' "$n" "$rc" "$W/receipt.json"
exit "$rc"
