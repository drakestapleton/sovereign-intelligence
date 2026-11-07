---
name: omega-encoding
description: "Write .om that the seeded Omega compiler actually accepts: syntax, types, traps, bounds, register limits, host I/O, byte encoding, compiler errors, verified examples. Use before writing, reviewing or explaining any Omega program."
---

# Omega encoding: writing `.om` that the seeded compiler actually accepts

Use this before writing, reviewing or explaining any `.om` program, before claiming what Omega can or
cannot express, and before encoding bytes, integers or host I/O in Omega.

## 0. Pin and how to re-check it

Merge status, 2026-10-29: compiler batch #904 merged at `e2662fffbce1c21ef09da71c0d8808133a6af8ab`;
x86 integration #923 merged at `bf54b19fa590e8ae925c0e80815516dbf41e7326`.
Earlier pending labels describe the recorded pre-merge tests. Native x86
execution remains NOT_RUN; merging is not hardware qualification.

The quantity and diagnostic audit is merged through omega-mv #914 at main
`d94a503f7aae57d09697046405da2e9a5895be6d`. The older candidate observations
below remain dated history, not claims about the newer integration.

### Current main pin (checked 2026-11-05)

| Item | Value |
|---|---|
| Repository | `github.com/aien-dev/omega-mv`, branch `main` |
| Commit | `f4df82394e35893dcf1354dda69a2fe028d94bc1` (merge commit of [#1022](https://github.com/aien-dev/omega-mv/pull/1022), `efi 14` machine identity, head `81c5cb25`, merged 2026-11-05T23:48:11Z) |
| Compiler source `seed/omc/omc.om` | 18,224 lines, 511 `^fn ` lines, sha256 `0effe37afc4ddd0507151c9f2afa34b3e6774eae7006cbecd8c59f11bc386db7` |
| Compiler `seed/out/omc` | sha256 `3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`, 625,676 bytes (equals `seed/out/omc.sha256`; last `seed/omc/size-history.tsv` row `x86efi-ident-1022`) |
| Seed loader `seed/rung0/seed0.hex` | sha256 `baaf081fe6055a768485c5d25d7435681ce00b04cfa80b26c48169f78944e14d` (unchanged) |

#1022 is the only merge after `d3d1b1bc7` that changes `seed/out/omc.sha256` (`git log
d3d1b1bc..f4df8239 -- seed/out/omc.sha256`). It adds x86efi OP 14 (machine identity: CPUID brand,
firmware vendor/revision, SMBIOS copy). `omc.om` went from 510 to 511 `^fn ` lines, so the om4 cap
(section 8) has 1 free entry at this pin. Still current at main `2a1e6d29` (2026-11-05).

Observed 2026-11-05 on a Linux AArch64 host in a clean detached worktree at main `2a1e6d29`:
`sh seed/omega-from-seed.sh` printed `RC=0` and left `seed/out/omc` at exactly `3ad9f10f…3194`.
The example gate result is in the "Rerun at omega-mv `f4df8239`" section.

### Previous pin `d3d1b1bc` (checked 2026-11-04, history)

Commit `d3d1b1bc7e3b970016a2176435f78c8f0251bad1` (merge commit of #1015, `target x86efi`, head
`19ee7e99`); `omc.om` 18,056 lines, 510 `^fn ` lines, sha256 `16b4ca40…c749`; `seed/out/omc`
sha256 `b4f45121f6c6d5d8a6ed0f5c4f3934b7cc4bec369bfa89523699bd33928f9b55`, 611,620 bytes.
#1015 was the only merge after `9920aab14` that changed `seed/out/omc`. It added the x86efi
backend; AArch64 and x86linux output of the 1305 tracked `.om` files was unchanged except the
4 x86efi test programs (#1015's corpus TSVs).

Observed 2026-11-04 on a Linux AArch64 host in a clean detached worktree at `d3d1b1bc7`:
`sh seed/omega-from-seed.sh` exited 0 and left `seed/out/omc` at exactly `b4f45121…9b55`.
`fnv1a32.om` and `trap_narrow.om` compiled to binaries byte-identical to the ones `be8c5130`
emits; `abc` gave `0b e9 47 1a`, exit 0; `trap_narrow` exited 105. The example gate result is in
the "Rerun at omega-mv `d3d1b1bc`" section.

### Previous pin `9920aab1` (checked 2026-10-31, history)

| Item | Value |
|---|---|
| Repository | `github.com/aien-dev/omega-mv`, branch `main` |
| Commit | `9920aab1413983c2867d02d75b2276341595adb8` (squash of [#994](https://github.com/aien-dev/omega-mv/pull/994), `scrub` keeps live float registers, merged 2026-10-31T10:48:56Z) |
| Compiler source `seed/omc/omc.om` | 16,432 lines, 495 `^fn ` lines, sha256 `d4b4b89d8a58cc90d30d15a525b417e4b31e5bfe5288d21d665f1c7958a330f6` |
| Compiler `seed/out/omc` | sha256 `be8c51301307555254fc59e351d281aae1aa096d91521777e33a41c8b446448a`, 517,856 bytes (equals `seed/out/omc.sha256`; last `seed/omc/size-history.tsv` row `scrub-flive`) |
| Seed loader `seed/rung0/seed0.hex` | sha256 `baaf081fe6055a768485c5d25d7435681ce00b04cfa80b26c48169f78944e14d` |

Merges after `91c83438d` (omc `2aec185d…d8d5`) that change the compiler, oldest first: #967
(`96ea448ad`, IR-mode `TYPE` casts read the operand at its own type, section 4), #948 (`dc0d06e95`,
B/BL imm26 displacements checked by the shared `bdisp`, section 4 error 24 entry), #875
(`236787439`, OM-2 words `dit` 225 / `scrub` 226, section 6), #918 (`2d848d939`, host word
`peername` 224, section 9), #853 (`4722cba58`, floats in V registers, codegen only; see the `scrub`
entry in section 6), #848 (`157bab57c`, `while ... bound N` up to 2^63-1, section 8), #857
(`3a163bc5e`, `for ... bound N`, IR loop ranges, section 8) and #994 (`9920aab14`, `scrub` no longer
zeroes the V16+j twin of a live float slot, section 6; the only merge after `3a163bc5e`). #990, #992
and #989 touch tests and docs only. `seed/rung0`, `seed/rung4/om4.s`, `seed/rung4/om4.bin` (sha256
`d0da40e4…19efab`), `seed/omega-from-seed.sh` and `seed/omc/gate12.sh` are unchanged between
`91c83438d` and `9920aab14`. `omc.om` went from 512 to 495 `^fn ` lines with #853 (#994 adds none),
so the om4 cap (section 8) has 17 free entries at this pin.

Observed 2026-10-31 on a Linux AArch64 host in a clean detached worktree at `9920aab14`:
`sh seed/omega-from-seed.sh` exited 0 (`RC=0`) and left `seed/out/omc` at exactly `be8c5130…448a`
with a clean `git status`. Both guide examples were rerun with that omc and gave the same results
as at the previous pin: `fnv1a32.om` and `trap_narrow.om` compiled with exit 0 to binaries
byte-identical to the ones `24caacf4` emits; `abc`, `a` and empty input gave `0b e9 47 1a`,
`2c 29 0c e4`, `c5 9d 1c 81`, exit 0; 65536 zero bytes gave no output, exit 2; `trap_narrow.om` ran
with exit 105. The same `fnv1a32.om` prefixed with `target x86linux` printed `0b e9 47 1a` for
`abc` with exit 0 under `qemu-x86_64` 8.2.2: EMULATED, not native x86.

The omega MCP tools (`compile`, `run`, `lookup`) use the guide pin since omega-mcp
[#6](https://github.com/aien-dev/omega-mcp/pull/6): omega-mv `f4df8239`, omc `3ad9f10f…3194`.
Before that they used omega-mv `e5b32567`, omc `2c824805…029f` (history): that omc predated #848,
so `while ... bound 1000000` was `error 8` there (1..999999), and it still had the #775 empty-text
defect (`len` of a `text e ""` passed as `view uchar *` returned a stale register value, exit 36 in
the program recorded under "Empty text" below). Both are gone at the MCP pin. A server process
started before the repin still runs the old binary: check `compiler_sha256` in a `compile` result.
At this pin `execprog` closes every descriptor at or above 3 (omega-mv #970); omega-mcp #6 moved its
bwrap control pipes to fds 0..2 for that reason.

### Previous pin `3a163bc5` (2026-10-31, history)

| Item | Value |
|---|---|
| Commit | `3a163bc5eafa5be4b9ca97b7f17046c33f0d9032` (squash of [#857](https://github.com/aien-dev/omega-mv/pull/857), `for ... bound N` and the IR loop ranges, 2026-10-31) |
| Compiler source `seed/omc/omc.om` | 16,422 lines, 495 `^fn ` lines, sha256 `0ed35c70437d498cbce3deb661bb24ba4753ec16a8890450a482aaea147bca2a` |
| Compiler `seed/out/omc` | sha256 `24caacf463cc29c5413d5b2565ef8f88c76e60a585bbad44d2388cb1ac29abb7`, 517,768 bytes (equals `seed/out/omc.sha256`; last `seed/omc/size-history.tsv` row `forbound-857-main`) |

This pin had #967, #948, #875, #918, #853, #848 and #857 but not #994, so its `scrub` zeroed live
float locals (section 6). #990, #992 and #989 touched tests and docs only, and the seed files listed
above were unchanged between `91c83438d` and `3a163bc5e`.

Observed 2026-10-31 on a Linux AArch64 host in a clean detached worktree at `3a163bc5e`:
`sh seed/omega-from-seed.sh` exited 0 (`RC=0`) and left `seed/out/omc` at exactly `24caacf4…abb7`
with a clean `git status`. Both guide examples were rerun with that omc: `fnv1a32.om` compiled with
exit 0 and empty stderr to a binary byte-identical to the one `2aec185d` emits; `abc`, `a` and empty
input gave `0b e9 47 1a`, `2c 29 0c e4`, `c5 9d 1c 81`, exit 0; 65536 zero bytes gave no output,
exit 2; the wrong-prime control (`16777617`) gave `55 be dc f5` for `abc`. `trap_narrow.om`
compiled with exit 0 and empty stderr and ran with exit 105; deleting only its unmasked store
(negative control) changed the run exit to 44. The same `fnv1a32.om` prefixed with
`target x86linux` printed `0b e9 47 1a` with exit 0 under `qemu-x86_64` 8.2.2: EMULATED, not
native x86.

### Previous pin `91c83438` (2026-10-31, history)

| Item | Value |
|---|---|
| Commit | `91c83438daec0bdb88bf5c077cae10f3d15d365d` (squash of [#965](https://github.com/aien-dev/omega-mv/pull/965), error-code registry and IR error 30, 2026-10-31) |
| Compiler source `seed/omc/omc.om` | 15,952 lines, 512 `^fn ` lines, sha256 `92eb49f35715147ccb6c6b00a96b9cb38d7f7383de14d4f6521d2e07eaad465c` |
| Compiler `seed/out/omc` | sha256 `2aec185d4ed6d7a6a5779ed656b4e56904742bde5551b02893fb5f73916ad8d5`, 495,668 bytes (last `seed/omc/size-history.tsv` row `error-registry-965`) |

Three merges after `4376c2112` (omc `62775d2a…712b`) changed the compiler: #946 (`d94617177`, host
words `cpufence` 199 / `cpurelax` 200), #970 (`1db941627`, `execpure` word 198 and `close_range`
before `exec`; omc `7a8b84fcc07808a52e6cbb65aa7450c754b3ad62eeddf9ec64cc0edd0938b2de`) and #965
(`91c83438d`: error-code registry and IR error 30, section 11; float literal scans and the untyped
long float literal miscompile, section 4). The `omc.om` line links in this file are permalinks to the
commit they name; on main the line numbers have moved.

Observed 2026-10-31 on a Linux AArch64 host in a fresh clone at `91c83438d`: the committed
`seed/out/omc` hashed to `2aec185d…d8d5`; `seed/rung4/om4.bin` alone compiled that `omc.om` with exit 0
to a 495,668-byte binary with the same sha256; `sh seed/omega-from-seed.sh` exited 0 (`RC=0`) and
left `seed/out/omc` at exactly `2aec185d…d8d5`. Both guide examples were rerun with that omc, with
the same results as with the previous main omc `7a8b84fc…` (both compilers emit byte-identical
`fnv1a32.om` binaries): `fnv1a32.om` compiled with exit 0 and empty stderr; `abc`, `a` and empty
input gave `0b e9 47 1a`, `2c 29 0c e4`, `c5 9d 1c 81`, exit 0; 65536 zero bytes gave no output,
exit 2; the wrong-prime control (`16777617`) gave `55 be dc f5` for `abc`. `trap_narrow.om`
compiled with exit 0 and ran with exit 105; deleting only its unmasked store (negative control)
changed the run exit to 44. The same `fnv1a32.om` prefixed with `target x86linux` compiled with
exit 0 to an x86-64 ELF that printed `0b e9 47 1a` with exit 0 under `qemu-x86_64` 8.2.2:
EMULATED, not native x86.

### x86 integration as tested before merge (observed 2026-10-28)

Then-draft [#923](https://github.com/aien-dev/omega-mv/pull/923), source
`7ab5fdd067884fd3044155084b39163da1be5c8a`, integrated main and batch 3
(#904). Its `seed/omc/omc.om` and `seed/out/omc` hashes equal the main pin `bf54b19fa`
(omc `62775d2a…712b`, main until #946). The seed gate passed, including GATE5. Both guide examples compiled with empty
stderr: `fnv1a32.om` on `abc` exited 0 with bytes `0b e9 47 1a`;
`trap_narrow.om` exited 105, while removing its unmasked store exited 44.

The exact first line `target x86linux` selects the x86 backend. Quantity
negation and complement refuse with error 7 on both targets. Empty text remains
sized with length zero and emits no literal bytes; bounds checks still apply.
Target-specific diagnostic contracts preserve the extra x86 stack-check records
and exact growth-refusal records. See the source's `docs/X86-LINUX.md` and
`seed/omc/x86-diagnostic-contracts.json`. Historical failed experiments and
frozen compatibility rows remain separate from current acceptance.
At main `bf54b19f`, `docs/X86-LINUX.md` is headed "Status: DRAFT; native x86
qualification NOT_RUN". Its last complete differential (section "Current acceptance
contracts", source `7ab5fdd0`, QEMU, EMULATED) reported 15179 PASS, 4 NOT_RUN,
222 EXCLUDED and no FAIL cases, aggregate verdict FAIL because NOT_RUN is not PASS;
`00ebdee8` then passed the two text-write cases (5 PASS), leaving two invalid-fd ioctl
cases unrun. Merged in source; not native x86 qualification.

**Error 25 on x86 at main `62d1d0d66` (observed 2026-10-30, compile only; rechecked 2026-10-31 at `4376c2112`).** `docs/X86-LINUX.md`
([#L201-L202](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/docs/X86-LINUX.md#L201-L202))
defines error 25 as an unsupported target/emission path. In `seed/omc/omc.om` at that commit it is
raised by the target-line parser for any `target` word other than `x86linux`
([#L15549-L15550](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L15549-L15550);
`target x86efi` gives `omc: line 1: error 25`), by `emit` when a nondefault target reaches the
AArch64 emitter ([#L571-L574](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L571-L574)),
by `hostval`, `xhost` and `xio` on a target mismatch
([#L6807-L6809](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L6807-L6809),
[#L14663-L14665](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L14663-L14665),
[#L15398-L15400](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L15398-L15400)),
and by the `xcc` condition-code fallthrough ([#L14841](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L14841)).
The device and mapping words 166..177 are **not** refused on x86: `xhost` dispatches them to x86
helpers (`xhdev`, `xhmnew`, `xhmbind`, `xhmdrop`, `xhmcopy`, `xhmmio`;
[#L14679-L14707](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L14679-L14707)).
`seed/host/tests/device.om`, `mapping.om` and `devcall.om`, each prefixed with `target x86linux`,
compiled with exit 0 to x86-64 ELF files with main's omc, at `62d1d0d66` and again at `4376c2112`
(where `target x86efi` still gave `omc: line 1: error 25`, exit 25). They were not run, so no x86
execution of device words is claimed. The VFIO words `vfioctl`/`vfiomap` are not on main (pending
draft [omega-mv#878](https://github.com/aien-dev/omega-mv/pull/878), open on 2026-10-31).
At main `91c83438d` (omc `2aec185d…`, 2026-10-31), at main `3a163bc5e` (omc `24caacf4…`,
2026-10-31) and again at main `9920aab14` (omc `be8c5130…`, 2026-10-31) `target x86efi` still gives
`omc: line 1: error 25`, exit 25 (observed); `vfioctl` is still absent from `omc.om` at `9920aab14`
and #878 is still an open draft. Since #970, `docs/X86-LINUX.md`
also lists `execpure` (word 198) among the `xhost` error-25 refusals on x86 (source text, not run
here). These are observations of the omc before #1015; since #1015 merged (`d3d1b1bc7`, omc
`b4f45121…`) error 25 on `target x86efi` covers only the refusals listed in the next section.

### `target x86efi`: omega-mv#1015 (merged `d3d1b1bc7`, the current pin; observed 2026-11-01 to 2026-11-04)

[omega-mv#1015](https://github.com/aien-dev/omega-mv/pull/1015), branch `feat/x86efi-main`,
head `19ee7e99fafaa6a509e0fd166126a16226e414f7`, merged 2026-11-04 with the merge commit
`d3d1b1bc7e3b970016a2176435f78c8f0251bad1`, so the commits cited below stay reachable. First observed at
`5ce9ecaa7b2034d5a7b4502403591d5c2489c06d` on main `ba5559d9b` (2026-11-01); the omc is the same
at both: sha256 `b4f45121f6c6d5d8a6ed0f5c4f3934b7cc4bec369bfa89523699bd33928f9b55` (committed
`seed/out/omc`, reproduced by `seed/omega-from-seed.sh`). An omc built before the merge, such as
the previous pin's `be8c5130…`, refuses every `target x86efi` unit with error 25 (section above).
Observed 2026-11-04 at `d3d1b1bc7`: `target x86efi` with `fn main to int` / `ret 0` / `end` compiles
with exit 0 to a file starting `MZ`; the same unit with `be8c5130` gives `omc: line 1: error 25`.

- The exact first line `target x86efi` emits a PE32+ EFI application for x86-64 UEFI firmware.
  Only whole programs (`fn main`) are accepted. Error 25 there means one of three refusals: a bare
  unit (`omc: line 1: error 25`), a Linux host word such as `read` or `write` (error 25 at its
  line), or an `efi` OP literal outside 0..13 (0..14 with omega-mv#1022, open on
  2026-11-04). An OP that is not a literal, such as a name, is error 16. `efi` under
  `target x86linux` is an ordinary unknown name, error 3 (`docs/one_layer/OMEGESE.md` lines
  441-451 at `19ee7e99`). Observed 2026-11-04 with omc `b4f45121`: `efi 13` compiles, `efi 14` and
  `efi 15` give `omc: line 4: error 25`, `k = ulong 13` then `efi k …` gives `omc: line 5: error
  16`, a unit without `fn main` gives `omc: line 1: error 25`, `write` gives `omc: line 4: error
  25`; under `target x86linux` `efi` gives `omc: line 4: error 3`. With the #1022 omc `3ad9f10f`
  `efi 14` compiles and `efi 15` is error 25.
- Keyword 178 `efi`: `st = efi OP ARG BUF OFF N`. `efi 12` is files: ARG bits 0-7 are the sub-op
  (0 OPEN-READ, 1 OPEN-WRITE, 2 READ, 3 WRITE, 4 CLOSE, 5 OPEN-UPDATE), bits 8-15 the volume
  (255 = the boot volume), bits 16-63 the position; one open file at a time; an error returns
  bit 63 | code. `efi 13` is the console: it accepts bytes 9, 10, 13 and 32..126 and writes LF as
  CR LF; with a NULL ConOut it returns error 43 without calling firmware (source; NOT_RUN, OVMF
  always installs ConOut). Ops 0..11 ship but are NOT_RUN (`docs/X86-EFI.md` ops table at `19ee7e99`).
- Exit closes the open file: on `return`, `exit` or any trap, a still-open file is flushed (if
  opened for writing) and closed with its volume root. Without this, a refusal path that exits
  between OPEN-WRITE and CLOSE loses the data: `tests/x86efi/run.sh` at `5ce9ecaa` gave
  `SUMMARY pass=11 fail=0` with `b4f45121` and `pass=9 fail=2` with the previous candidate
  `d0f756d9…` (both exit checks: `X.TXT` left at 0 bytes). The runner prints NOT_RUN for each
  check it cannot run (OVMF missing) and exits 77 when nothing ran; since review commit
  `e6d14505` it no longer reports a false `PASS exit e1`.
- At entry the program calibrates the TSC with a 100 ms `Stall(100000)` when CPUID reports an
  invariant TSC.
- `efi 14` machine identity: [omega-mv#1022](https://github.com/aien-dev/omega-mv/pull/1022)
  (branch `feat/x86efi-ident`, stacked on #1015, observed at `fbcf08826` and at head `9bf67eff`;
  omc sha256 `3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194` at `9bf67eff`;
  open, not merged, on 2026-11-04 at head `d07974da`). ARG
  `L << 16` = CPUID leaf L (16 bytes EAX..EDX; N < 16 is error 5), 1 = FirmwareVendor UCS-2 units,
  2 = FirmwareRevision as the result (nothing written), `3 + (P << 16)` = SMBIOS structure table from
  byte P (SMBIOS 3 entry point first, else 2; none is error 44, NOT_RUN); anything else is error 32.
  Structures are left to the program: read only the fields you print (`tests/x86efi/ident/id.om`
  never reads type 1 serial or UUID). Gates at `fbcf08826`: `tests/x86efi/run.sh` pass=18 fail=0,
  AArch64/x86linux sweep 2594 same, 0 differ; all EMULATED (QEMU q35 + OVMF). `seed/omc/omc.om` has
  511 `fn` definitions with #1022 (510 with #1015 alone; the om4 cap is 512) and the seed bootstrap
  still builds it. aien-train [#55](https://github.com/aien-dev/aien-train/pull/55) uses it for the
  `M` line of `OUT.TXT`.
- Gates at `19ee7e99` (`docs/X86-EFI.md`, committed TSVs): the 1305 tracked `.om` files compiled
  by `b4f45121` against main's `be8c5130` with `tools/x86efi/corpus_diff.sh`: AArch64 663
  identical, 638 same-refusal, 4 differ (`evidence/x86efi/corpus_b4f45121_vs_be8c5130.tsv`, sha256
  `e07c912b…`); x86linux 647, 654, 4 (`…_x86linux.tsv`, sha256 `04604a9d…`). The 4 are the
  `target x86efi` test programs, which only `b4f45121` accepts. Both TSVs were reproduced natively
  on AArch64 on 2026-11-04. Since `e6d14505`, `corpus_diff.sh` prints NOT_RUN (exit 3) without
  file(1) and reports the verdict `signal` for an exit above 128. The compiler uses 510 of the om4
  cap of 512 functions (511 with #1022; #1013, the 4096 raise, is parked).
- Evidence class: QEMU q35 + OVMF results are EMULATED; #1015 itself is IMPLEMENTED and EXERCISED
  under emulation, not QUALIFIED. First physical run: EXERCISED on physical hardware (one
  machine), aien-train `ollm.efi` on Drake's iMac (2026-11-01; `evidence/OMEGALLM/imac/` on
  aien-train [#53](https://github.com/aien-dev/aien-train/pull/53) at `df1fd9a`, merged `19c952b6`).
  The run records no machine identity; iMac18,3 and Core i5-7500 come from earlier aienux
  evidence. The OUT.TXT body equals the AArch64 reference under `tests/omegallm/efi-check.sh` (next
  bullet), and the written files TR.BIN, HE.BIN and S.CK match their recorded sha256. Reading the
  stick back: macOS 26 refused to mount the partition the firmware wrote (fsck clean), so copy it
  with `sudo dd if=/dev/rdiskNs1` and extract with mtools.
- Pitfall met while porting: `le` is a keyword (comparison), so a local named `le` is error 16;
  rename it (`lend`).
- First application: aien-train's Omega LLM `ollm` (aien-train#52, #53 at `df1fd9a`) builds with
  `TARGET=x86efi sh tests/omegallm/build.sh` (platform unit `native/omegallm/eio.om`, which reads
  `\OLLM\JOB.TXT` and writes `\OLLM\OUT.TXT`). `tests/omegallm/efi-receipts.sh` boots it under OVMF
  and requires `EV=` to name a new or empty directory, so it never overwrites receipts.
  `tests/omegallm/efi-check.sh OUT.TXT REF JOBS BYTES` checks positions as well as content: the
  first line must be exactly `OLLM efi BYTES`, each reference job must be followed by exactly one
  `J <ms>` line (an extra one is refused), and the last line must be `OLLM DONE JOBS <ms>`.
  J-shaped and DONE-shaped lines inside a job's output stay in the comparison. A `> ` job line
  holding only spaces or tabs runs nothing, gets no J line and is not counted in JOBS. It prints
  `EQUAL` (exit 0) or `DIFFERENT` (exit 1); exit 2 is a usage error.

### Historical quantity/check/next candidate (observed 2026-10-28)

| Item | Value |
|---|---|
| Repository | `github.com/aien-dev/omega-mv`, PR #911 head |
| Commit | `1fe5976d398646b17acabbf6d9dfae96b017e439` |
| Compiler source `seed/omc/omc.om` | 12,520 lines, sha256 `3f937160c823d3a90a6b4cc296f00f517f36ede7fd27a06505c998985ec62240` |
| Compiler `seed/out/omc` | sha256 `d6290c7663c2b4bafb59eb3fdf812476e977f4c144def71095c6248ef9b96b84` |
| Seed loader `seed/rung0/seed0.hex` | sha256 `baaf081fe6055a768485c5d25d7435681ce00b04cfa80b26c48169f78944e14d` |

Host-only observations below used a fresh clone checked out detached at this commit.
Hash and count commands: `sha256sum seed/omc/omc.om seed/out/omc seed/rung0/seed0.hex`
and `wc -l seed/omc/omc.om`; their observed values are in this table.
The fresh-clone `sh seed/omega-from-seed.sh` run exited 0 and printed:

```text
PASS seed0 408 bytes, rebuilds itself
PASS hex1 776 bytes, born from seed0
PASS asm2 2464 bytes, born from hex1
PASS om4 om4.bin 14224 bytes
PASS omc fixpoint d6290c7663c2b4bafb59eb3fdf812476e977f4c144def71095c6248ef9b96b84
PASS fwd exit 0
PASS fwd runs, exit 7
PASS mut exit 0
PASS mut runs, exit 0
PASS cycle exit 9
PASS assign exit 7
RC=0
```
This reproduces the independently recorded binary digest, not an independent
correctness proof or a full gate5/host qualification.


### Pending optional kernel-leaf experiment (2026-10-28; not an active pin)

Compiler [draft #925](https://github.com/aien-dev/omega-mv/pull/925) and bridge
[draft #38](https://github.com/aien-dev/omega-bridge/pull/38) describe an optional
restricted ABI experiment, not a prerequisite for Linux-hosted Omega policy.
Function-mode continuations/effect records can use the existing policy language;
kernel adapter, lifetime and non-leaf hardening requirements remain separate.

The host-tested compiler source is
`c4b4500d172690c8a72ae2df7124c1bf70c39173` (isolated base
`6999fa9e6dae4847c155ef4eacaece74f491d3ca`, distinct from FR9).
`seed/omc/omc.om` SHA256 is
`545e630349b45b826d49f8e75ed1fbc0e5d76c90410650f9945e0d89829441c8`;
experimental executable SHA256 is
`e7e95a8305fe0bf8331f579533b1fca69101eaf351fc5cea8208e3892a8733b8`.
The untouched seed remains
`d6290c7663c2b4bafb59eb3fdf812476e977f4c144def71095c6248ef9b96b84`.
Bridge source `9a4e5102a82c913699fb7c3dd99a2736cab2b3d6`,
`src/kernel_leaf.om`, has SHA256
`3f599cd22bc636084e81d4d3118a352da5ed1c42ce93624c88d7394ebed044cb`.
None replaces the current candidate/general-language/native-command pin.

The experimental `kleaf` directive permits one bounded unsigned scalar function,
normal x0 value/x1 status returns and allocated volatile-register clearing.
It rejects stack/calls/views/loops/host/OM-2 rather than claiming a general kernel
backend. Its `.om` bridge envelope matches only inspected
Linux `7.0.0-1019-nvidia` leaf tracing/PAC metadata; GNU binutils 2.42
performs assembly/object packaging. Native ET_REL generation is not added.
The compiler-side `seed/omc/kernel-leaf-experiment.py` requires clean compiler
and bridge commits and produced immutable host receipt SHA256
`254e2f3ea3acc3f9578e0854c6bd4664df234b3d8c9a9cf970a8c0c3ef8504d7`,
filed in #925. Self-rebuild, ABI/status/trap/register, refusal/mutant and explicit
single-kbuild-object comparisons passed. No module link/modpost/sign/load,
kernel execution, tracing exercise, DMA/IRQ or GPU qualification occurred.
The broader Linux effect contract is proposed only. Existing examples and
active pins are unchanged.

### Historical general-language pin (2026-10-25)

| Item | Value |
|---|---|
| Repository | `github.com/aien-dev/omega-mv`, branch `main` |
| Commit | `55f9b0af47de70a3d06357985cf99ae3e45c016f` (2026-10-25, merge of PR #766) |
| Compiler source `seed/omc/omc.om` | 7,838 lines, sha256 `2e35db7d6c2066fb4a20d19b8a9579c44caca9c9937b0594a89422010b673637` |
| Committed compiler `seed/out/omc` | sha256 `734f0a39319fbfa930bcc62cb30dbf06d47d78e126372b74f5baf478e6126b61` |
| Seed loader input `seed/rung0/seed0.hex` | sha256 `baaf081fe6055a768485c5d25d7435681ce00b04cfa80b26c48169f78944e14d` |
| Language document `docs/one_layer/OMEGESE.md` | blob `89a27d2e68519eb45c103abb23dfe05a68d8ad69` |

Every citation links to that commit: `https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/<path>#L<n>`.

### Rerun at omega-mv `f4df8239` (2026-11-05)

The example gate pins `f4df82394e35893dcf1354dda69a2fe028d94bc1` (#1022), `seed/out/omc` sha256
`3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`, built from seed at main
`2a1e6d29`. With only the pin moved and no expectation changed, `bash examples/gate.sh` against that
binary printed
`GATE PASS examples=110 pass=110 fail=0 omc=3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`
(exit 0) on 2026-11-05, Linux AArch64. Negative control: the gate pointed at the previous omc
`b4f45121…9b55` was refused with exit 2 (`GATE FAIL omc sha256 b4f45121…, pinned 3ad9f10f…
(omega-mv f4df8239…)`). The section below is the previous pin.

### Rerun at omega-mv `d3d1b1bc` (2026-11-04, previous pin)

The example gate pins main `d3d1b1bc7e3b970016a2176435f78c8f0251bad1` (#1015), `seed/out/omc`
sha256 `b4f45121f6c6d5d8a6ed0f5c4f3934b7cc4bec369bfa89523699bd33928f9b55`. #1015 adds the x86efi
target and leaves AArch64 output unchanged; with only the pin moved and no expectation changed,
`bash examples/gate.sh` against that binary printed
`GATE PASS examples=101 pass=101 fail=0 omc=b4f45121f6c6d5d8a6ed0f5c4f3934b7cc4bec369bfa89523699bd33928f9b55`
(exit 0) on 2026-11-04, Linux AArch64. Negative control: the gate pointed at the previous omc
`be8c5130…448a` was refused with exit 2 (`GATE FAIL omc sha256 be8c5130…, pinned b4f45121…
(omega-mv d3d1b1bc…)`). The section below is the previous pin.

### Rerun at omega-mv `9920aab1` (2026-10-31, previous pin)

The example gate pins main `9920aab1413983c2867d02d75b2276341595adb8` (#994), `seed/out/omc`
sha256 `be8c51301307555254fc59e351d281aae1aa096d91521777e33a41c8b446448a`. #994 changed only the
`scrub` emitter, and no example uses `scrub`; with only the pin moved and no expectation changed,
`bash examples/gate.sh` against that binary printed
`GATE PASS examples=101 pass=101 fail=0 omc=be8c51301307555254fc59e351d281aae1aa096d91521777e33a41c8b446448a`
(exit 0) on 2026-10-31, Linux AArch64. Negative controls: the gate pointed at the previous omc
`24caacf4…abb7` was refused with exit 2 (`GATE FAIL omc sha256 24caacf4…, pinned be8c5130…
(omega-mv 9920aab1…)`), and on a scratch copy `const N ulong 16` changed to 15 in
`examples/consts.om` ended `GATE FAIL examples=101 pass=100 fail=1` with exit 1 (`stdout differs
from consts.stdout`). The section below is the pin before.

### Rerun at omega-mv `3a163bc5` (2026-10-31)

The example gate then pinned main `3a163bc5eafa5be4b9ca97b7f17046c33f0d9032` (#857), `seed/out/omc`
sha256 `24caacf463cc29c5413d5b2565ef8f88c76e60a585bbad44d2388cb1ac29abb7`. With the previous tree
and only the pin moved, the gate against that binary ended `GATE FAIL examples=99 pass=97 fail=2`:
`mistake_bound_range.om` (`while ... bound 1000000`, valid since #848) and `mistake_for_bound.om`
(`for ... bound 10`, valid since #857) both compiled with exit 0 where error 8 and error 5 were
expected. `mistake_bound_range.om` now uses `bound 9223372036854775808` (error 8, line 4);
`mistake_for_bound.om` became `for_bound.om` (exit 10); `trap4_for_bound.om` (a value count 11 over
`bound 10`, exit 104) and `mistake_ir_bound.om` (`ir`, `while ... bound 1000001`, error 8, line 5)
are new. On 2026-10-31, Linux AArch64, `examples/gate.sh` against `24caacf4…abb7` printed
`GATE PASS examples=101 pass=101 fail=0` (exit 0). Negative controls on a scratch copy each ended
`GATE FAIL examples=101 pass=100 fail=1` with exit 1: `bound 9223372036854775807` in
`mistake_bound_range.om` (`compile exit 0, expected 8`) and `bound 4` in `for_bound.om`
(`exit 104, expected 10`). The gate pointed at the previous omc `2aec185d…d8d5` was refused with
exit 2. The section below is the previous pin.

### Rerun at omega-mv `91c83438` (2026-10-31)

The example gate then pinned main `91c83438daec0bdb88bf5c077cae10f3d15d365d` (#965), `seed/out/omc`
sha256 `2aec185d4ed6d7a6a5779ed656b4e56904742bde5551b02893fb5f73916ad8d5`. On 2026-10-31, Linux
AArch64, `examples/gate.sh` against that binary printed `GATE PASS examples=98 pass=98 fail=0`
(exit 0) with no expectation changed. The rerun also showed that code 25 is emitted (it has been
since the x86 integration `bf54b19f`): `target foo` as the first line is `omc: line 1: error 25`
under both `2aec185d` and the pre-#965 `7a8b84fc`. `examples/err25_target.om` now records it, and
the gate printed `GATE PASS examples=99 pass=99 fail=0` (exit 0); with its first line changed to
`target x86linux` (a known target) that example fails (`compile exit 0, expected 25`). Negative
controls on a scratch copy of the 99-program tree each ended `GATE FAIL examples=99 pass=98 fail=1`
with exit 1: `const N ulong 16` changed to 15 in `examples/consts.om` (stdout `15` instead of
`16`), and one byte appended to `consts.stdout`. The gate pointed at the pre-#965 omc `7a8b84fc…`
was refused with exit 2. The 2026-10-29 section below is the previous pin.

### Rerun at omega-mv `bf54b19f` (2026-10-29)

The example gate now pins this compiler. On 2026-10-29, Linux AArch64, `examples/gate.sh` against
`seed/out/omc` sha256 `62775d2a391cfef7cde64e387655caa9809a267093112910ec76bfa568f3712b` printed
`GATE PASS examples=98 pass=98 fail=0` after the keyword-prefix expectation was updated. The same
gate pinned to `2c824805…029f` had passed 98/98 with the old expectation. A copy of the new gate
pointed at `2c824805` was refused (exit 2).

| Item | Value |
|---|---|
| Commit | `bf54b19fa590e8ae925c0e80815516dbf41e7326` (2026-10-28, merge of PR #923) |
| `seed/omc/omc.om` | 15,624 lines, sha256 `96d51b63c8f451661ac715395078e04f39195e50c9e8fe37746cda121e4d7a1e` |
| `seed/out/omc` | sha256 `62775d2a391cfef7cde64e387655caa9809a267093112910ec76bfa568f3712b` |
| `seed/rung0/seed0.hex` | sha256 `baaf081fe6055a768485c5d25d7435681ce00b04cfa80b26c48169f78944e14d` (unchanged) |
| `docs/one_layer/OMEGESE.md` | blob `90fa5d0c32757da6e7c271e96406b75105ba8008` |

Two defects recorded at `e5b32567` are fixed in this compiler (the #904 integration, `e2662fff`):
`fn continue_x` compiles and the program exits 7 (`examples/defect_keyword_prefix.om`); `bitcast int`
of `uint 4294967295` compares equal to -1 and `add` 2 returns 1, and `bitcast uint` of `int -1`
compares equal to 4294967295. At `2c824805` those three programs were error 16, exit 2 and exit 2,
and `add` 2 trapped 1. `fn continue` is still error 16. The #775 empty-text defect was reproduced at
`2c824805` (see the bullet below); it is fixed at the guide and MCP pin, so `part e 0 0` is only
needed for an older vendored omc. Other "observed at e5b32567" lines below are dated history; the
example suite still matches them.

### Historical rerun at omega-mv `e5b32567` (2026-10-27)

Every example and rule in this file that a program can show was rerun on 2026-10-27 with the
compiler below, on a Linux AArch64 host only. The 2026-10-29 section above is current where it
disagrees with this list.

| Item | Value |
|---|---|
| Commit | `e5b32567a7aff3ce594e3254a622a846a6cd190b` (2026-10-26, merge of PR #868) |
| `seed/omc/omc.om` | 12,040 lines, sha256 `7703da00055fc0c7a91fcae43071df76a3f277dbe867cb284a3bdff3bedb7e1b` |
| `seed/out/omc` | sha256 `2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f` |
| `seed/rung0/seed0.hex` | sha256 `baaf081fe6055a768485c5d25d7435681ce00b04cfa80b26c48169f78944e14d` (unchanged) |
| `docs/one_layer/OMEGESE.md` | blob `119c559557e4f227dee348c0e0e1240c71a42df3` |

The executable record is [`examples/gate.sh`](../../examples/gate.sh): it refuses any other compiler
hash, then compiles and runs 98 programs (`examples/*.om` and this skill's `examples/*.om`) against
exact expected stdout bytes, exit statuses and compiler stderr lines. Observed:
`GATE PASS examples=98 pass=98 fail=0`. Negative controls on a copy each ended `GATE FAIL` with
exit 1: one changed digit in an expected stdout, an expected exit 105 changed to 104, an expected
stderr line number changed, a removed `.expect` file, and a changed program body; a compiler with one
appended byte was refused with exit 2. Arithmetic expectations were checked with Wolfram
(`examples/WOLFRAM.md`).

Changes and confirmations against the rules below, each observed with a program:

- **Hex literals are OM-2 only.** In an OM-1 unit `uint 0x10` is error 6. After an `om2` line it is
  16; `0X10` (uppercase prefix) is error 6, and the value must fit the type: `int 0xffffffff` is
  error 8 (`examples/om2_hex_rotr.om`, `mistake_om2_upper_hex.om`, `mistake_om2_int_hex.om`).
- **`+` is refused.** `y = x + 1` is error 5 and a value starting with `+` is error 3
  (`mistake_infix.om`). OMEGESE 9.9's "`+ - * /`" is still wrong at this pin.
- **Float to integer truncates toward zero and saturates; it never traps.** `long 1.0e30f64` is
  9223372036854775807, `long -1.0e30f64` is -9223372036854775808, `long -5.75f64` is -5,
  `uint -5.5f64` is 0, `uchar 300.0f64` is 255, and a NaN converts to 0 (`float_to_int.om`). Integer
  to integer conversion stays checked (trap 5).
- **The `=` of an assignment is optional** (OMEGESE line 24), so `return x` compiles as an assignment
  to a new name `return`. In a value function the missing `ret` then shows as error 18
  (`mistake_return.om`).
- **`for ... bound N` and the bound range** (since #848 and #857, in the pin since `3a163bc5`): `for i ulong
  n bound 10` compiles (`for_bound.om`, exit 10) and a count past the bound traps 4
  (`trap4_for_bound.om`); a bound is 1..9223372036854775807, so `bound 0` and `bound
  9223372036854775808` are error 8 (`mistake_bound_range.om`), and in IR mode it is 1..1000000
  (`mistake_ir_bound.om`). `trap` takes 1..14 (`trap 15` and `trap 0` are error 8; `trap 14` exits
  114).
- **Names:** an 8-character variable compiles and 9 is error 13; a 63-character function name
  compiles and 64 is error 13. `len` or `stat` as a variable is error 16, `free` is error 9, and
  `bits` is an ordinary name.
- **Placement:** a `struct` line after the first `fn` is error 9; `new` inside a block is error 9; a
  variable `new` length is error 16; `main` with a parameter is error 9. A `const` in function mode
  compiles.
- **Parameter slots, not parameter count.** Parameters fill x0..x5: an OM-2 unsized `view T *` /
  `edit T *` takes two slots (pointer, count), every other parameter one, a sized array included
  (OMEGESE 9.13 "Parameter slots"). Observed: 3 sized views plus 3 scalars compile and run; 2 unsized
  views plus 2 scalars compile; 2 unsized views plus 3 scalars, or 7 scalars, are error 9 on the `fn`
  line (`examples/om2_param_slots.om`, `mistake_om2_param_slots.om`, `mistake_seven_params.om`).
- **Function names of 9..63 bytes are not keywords by their first 8 bytes** (fixed in the #904
  integration, measured 2026-10-29 at omc `62775d2a`). `continue_x` compiles and returns 7
  (`examples/defect_keyword_prefix.om`). At omc `2c824805` the same file was error 16. An exact
  keyword name (`fn continue`) is still error 16.
- **OM-2 slices:** `part A off n` is only an argument to an unsized `view T *` parameter. As a value
  of its own it is error 9, to a sized parameter error 7, of a global error 19; `off + n` past the end
  traps 3 at run time (`om2_views.om`, `om2_part_trap.om`).
- **Errors 1 and 2 reproduce:** a directory as the compiler's stdin gives exit 1,
  `omc: line 0: error 1`; stdout on `/dev/full` gives exit 2 with the line after the last input line
  (`omc: line 5: error 2` for a 4-line unit). A 33rd `export fn` in an OM-2 unit is error 14; exports
  are function mode, so an `export` beside `fn main` is error 9.
- **The seeded C bridge accepts typed views at bridge main `29d9cff7`.** Rechecked 2026-11-06
  with `OMEGA_SEEDED_OMC=<e5b32567-omc> sh tools/bridge-seeded c unit.om`: a unit
  `fn first a view T 1 to T` / `ret get a 0` / `end` emits C with status 0 for each
  `T` in `uchar ushort uint ulong f32`; omega MCP compile also accepts all five.
  The earlier `uint`/`ushort`/`f32` error-24 refusal at bridge `bc11b30b` is obsolete
  after typed views [#73](https://github.com/aien-dev/omega-bridge/pull/73).
  The checked borrowed-view freestanding profile [#77](https://github.com/aien-dev/omega-bridge/pull/77)
  also covers these element kinds; see `omega-harness` for its separate ABI and limits.
- **A bool does not convert to a number at omc `e5b32567`.** Rechecked with MCP compile
  on 2026-11-06 (omc `2c824805…029f`, not the section 0 compiler):
  `x = ulong eq a 1` in a function is error 9 at that line; `ret ulong f u` when
  `f` returns bool is likewise error 9. `fn f a ulong to ulong` / `if eq a 1` /
  `ret 1` / `end` / `ret 0` / `end` compiles and emits seeded C successfully.
  Use the explicit branch rather than a numeric conversion of bool.
- **Error 24 needs more than 1 MiB of code inside one loop.** 40 functions of 4,000 checked `add`
  lines each compiled and ran, because each function's branches stay short. One `while` loop with
  270000 copies of `x = add x 1` was refused with `omc: line 270006: error 24` (the loop's `end`);
  with 140000 copies it compiled. The check is `disp19` (omc.om line 2465 at `e5b32567`, line 2956
  at `91c83438`): a conditional branch reaches at most 2^18 - 1 words forward. The recipe is in
  `writing-omega` section 11. Rerun 2026-10-31 with omc `2c824805` and with the then pin omc
  `2aec185d`: both give exit 24 and that line for 270000 copies, and exit 0 for 140000 copies (the
  program then exits 0). At `e5b32567`, codes 25 and 26 are not emitted by any `fail` call. Since
  #948 (`dc0d06e95`, in the pin since `3a163bc5`) every B.cond/CBZ/CBNZ imm19 and every B/BL imm26 site goes
  through one checked `bdisp` ([omc.om#L2982-L2992](https://github.com/aien-dev/omega-mv/blob/3a163bc5eafa5be4b9ca97b7f17046c33f0d9032/seed/omc/omc.om#L2982-L2992));
  the 8 MiB output ceiling (error 14) keeps every B/BL inside its 128 MiB reach, so imm26 error 24
  is a defence no legal program reaches (`seed/qualification/security673/README.md`). Observed
  2026-10-31 at `3a163bc5e`: that directory's `gate669.om`, built with omc `24caacf4…`, ended
  `GATE669 PASS bounded Linux AArch64 execution and independent decoding only` (exit 0, host only);
  rerun 2026-10-31 at `9920aab14` with omc `be8c5130…`: compile exit 0, the same PASS line, exit 0
  (host only). `bdisp` is unchanged by #994.
- **Narrow `bitcast`:** at omc `2c824805`, `bitcast int` of `uint 4294967295` was not -1 and `add` 2
  trapped 1, and `bitcast uint` of `int -1` was not 4294967295. At omc `62775d2a` those two cases
  are correct (exit 1 and exit 1; `add` 2 returns 1). `ushort`/`short`, `uchar`/`byte` and `f32` to
  `int` were not retested on 2026-10-29. Do not assume they are fixed. Decode signed values
  arithmetically when you have not measured the pair (`examples/wire_le.om`).
- **`byte` is signed 8-bit** (`i8`, OMEGESE line 109); `char` is not a type (error 3).
- **Empty text through `view uchar *` (omega-mv #775).** The stale `len` depends on layout, so one
  passing two-text unit proves nothing (a 2026-10-29 two-text unit returned 0 on `2c824805` and
  `62775d2a`). Reproduced 2026-11-04 on the MCP omc `2c824805…` (`omega_run`), with
  `fn f t view uchar * to ulong` / `ret len t` under `om2`:
  - `text ta "abc"`, `text te ""`, `text tb "xy"`, `main` `ret int f te`: exit 36 (expected 0);
    `ret int f tb` exits 2 and `ret int f part tb 0 0` exits 0.
  - only `text e ""`, `ret int f e`: exit 28; adding `text f "0123456789abcdef0123456789abcdef"`
    makes it exit 60; `ret int f part e 0 0` exits 0.

  With the guide pin all three exit 0 (`be8c5130…` 2026-11-04, `b4f45121…` 2026-11-05; fixed by the
  #904 integration `e2662fff`). The MCP pin has carried the fix since omega-mcp #6. On an older
  vendored omc (anything built before `e2662fff`) pass `part e 0 0` instead
  (`examples/empty_text_part.om`). synapse-mcp hit it: every empty-text record arrived with len
  28-60 and positional arguments were refused as too long.
- **`and`/`or` are eager everywhere, not only in contracts.** `if and gt n 0 eq get a sub n 1 13`
  traps 3 (exit 103) when `n` is 0, because `get a sub n 1` still runs (`2c824805`, `omega_run`,
  2026-11-04). Guard an index with a nested `if`.
- **Skill examples rerun:** `fnv1a32.om` compile exit 0, empty stderr; `abc`, `a`, empty and 65535
  zero bytes gave `0be9471a`, `2c290ce4`, `c59d1c81`, `47dac371`, each exit 0; 65536 zero bytes gave
  exit 2 and no output; the prime changed to `16777617` gave `55bedcf5` for `abc`.
  `trap_narrow.om` compiled with exit 0 and ran with exit 105, and 44 without the unmasked store. The
  section 13 inline refusal gave exit 7, `omc: line 3: error 7`.
- **Section 11a contract fixtures rerun** from `seed/omc/contracts/`: `ok.om` exit 0, `requires.om`
  exit 109, `release.om` exit 0 and byte-identical to `erased.om`; `diagproof.om` stderr
  `omc-check 1 erased line=3 rule=constant-true kind=requires`, `diagrelease.om` stderr
  `omc-check 1 erased line=3 rule=release kind=requires`, each compile exit 0.

### Merged IR/wasm backend (2026-10-26)

Source: omega-mv main `3364a1dfd0ca50c1b82bf19ba34932d8bc10a7a9`,
[#787](https://github.com/aien-dev/omega-mv/pull/787), after the separate boolean IR
fix [#786](https://github.com/aien-dev/omega-mv/pull/786), merge
`87489da90a1a7a750fd4a7f9eeb005b1221721f6`. Source merge is not deployment.

| Backend item | Verified value |
|---|---|
| `seed/omc/omc.om` | sha256 `bd64bb6f20952818e155328f429ab6cd36bba213e3e00b60d796336f9d0c9343` |
| `seed/out/omc` | sha256 `befb8199db8c4bca188a494dfaac2a6f0ee5c36fcea11188c75666c55fce8a1d` |
| Prior main compiler at `ec07d25d5506d33567adbd4d9b518177b7933bad` | sha256 `499236398aabc652e2dae27fe4bdc4c5db3d3726314356e0dbef23e3345803ec` |
| `seed/wasm/irwasm.om` | sha256 `8dc7bf602eb882e26a18b9e2dc4cacdd3ad68827215e71874b14c4acb237ccf8` |

The compiler corrects IR-mode boolean AND/OR/XOR typing: all three previously
exited 7 and now compile to bytes identical to the C encoder, accepted by checker2.
Boolean arithmetic and shifts remain refused. The om4-built compiler and two
self-rebuilds are byte-identical; the full compiler referee/wrong-word-mutant gate
ended `GATE5 PASS`. Retained evidence:
`evidence/IR-BOOL-20261026/` from merged #786.

`seed/wasm/irwasm.om` is a seeded Omega backend for **scalar OSC IR v1**, not an
arbitrary foreign-source converter. It writes an import-free WebAssembly MVP module
and exports each function under its ASCII IR name. ABI tags bool/u8/u16/u32/i8/i16/i32
map to i32, u64/i64 to i64, void to no result. Internal canonical i64 locals preserve
width and signedness; signed overflow, invalid shifts/casts/division, explicit traps
and lowered loop guards become wasm runtime traps. Wasm does not expose Omega's
numeric trap code. Supported instructions: CONST/MOV/BIN/UN/CMP/CAST/CALL/TRAP/BR/CBR/RET.
Limits and exact mappings:
[`OMEGESE.md` section 11.1](https://github.com/aien-dev/omega-mv/blob/3364a1dfd0ca50c1b82bf19ba34932d8bc10a7a9/docs/one_layer/OMEGESE.md#L914).
Versions other than 1, memory/reference/arena/pool/slice tags and operations refuse.
The module is buffered so parse/type/capacity refusals have empty stdout.

Host command: `nice -n 19 sh seed/wasm/gate-irwasm.sh`.
Observed on Linux AArch64, Node v24.21.0 used **only as a read-only oracle**:
`PASS parity cases=129 units=13 traps=29; every export exercised`.
The parity checker rejected an add-to-sub IR-byte mutant with exit 1; two translations
of every unit were identical, and named refusal exits were pinned with empty stdout.
Source-bound full logs/artifacts: `evidence/IRWASM-20261026/` from merged #787.
Re-exercised at head `0e81d5a6f990000f1dca50f05f0c6050f7cdf9a5` before merge;
the backend gate did not run browser integration or GPU qualification.

Existing guide examples were rerun with this compiler: FNV `abc` emitted
`0b e9 47 1a`, compile/run exit 0; `trap_narrow.om` compiled with exit 0 and ran with
exit 105. Removing only the unmasked store (negative control) changed the run exit
to 44. The historical examples and their old measured evidence below remain intact.

Downstream browser integration is separately **merged**, not qualified as deployed here:
[aienos.com #109](https://github.com/aien-dev/aienos.com/pull/109), merge
`a6aec5e2628804abd27101ba184d7a319f95774e`; #108 closed as superseded.
Its existing OM-1 compiler pin `734f0a39319fbfa930bcc62cb30dbf06d47d78e126372b74f5baf478e6126b61`
compiled the same upstream `irwasm.om` to **identical** backend bytes
`2d235a70c39ac1461a09c41e10e058d962b767ae83893cdcfc693ef6c47182e6`.
No site compiler pin bump was necessary. `irwasm.provenance` records the source and build.
The site unit `om/hive-page/fresh.om` accepts clock/timestamps, the caller's stale
threshold and fetch status; `check.sh` uses an `ir` header and the pinned backend to
produce `public/wasm/hive-fresh.wasm`, sha256
`af9e1fb0d9e736949b2aa83c0bf978ac2d98f37428a8507176abaa1dd50b777b`.

`freshness-js.om` emits the loader and explicit JS load-failure fallback.
`data-fresh-engine="wasm|js"` discloses the engine; the four state codes are
0 fresh, 1 stale (strictly past the supplied threshold), 2 backwards timestamp,
3 interrupted fetch. Source-clock trust gating remains separate. Browser-supplied
fractional elapsed age is rounded upward only at the integer wasm boundary,
preserving a strict comparison against the validated integer threshold.
`sh om/hive-page/gate-fresh.sh` compared ten boundary cases with actual native
AArch64 execution and read-only Node wasm execution. Real Chromium poll fixtures
exercised all four wasm states, incorrect-MIME arrayBuffer loading, and one-byte
module corruption falling back to JS. Corrupting that byte on disk made the
x86_64-compatible asset hash test fail with exit 101; original bytes were restored.
Historical evidence/fixtures/results remain `om/hive-page/fresh-evidence.log` and sibling
`fresh-*` files on closed #108, not in the #109 main tree. These were synthetic acceptance
feeds, not production telemetry. The helper source and wasm artifact were carried over
byte-identically. Production browser verification, deployment and GPU qualification
remain NOT_RUN by this guide update.

### Current main, OM-2 contract and the 1.0 roadmap (2026-10-26)

omega-mv main `19f014f2178ca9cd3473728fe00a475a2398c409` (merge of
[#801](https://github.com/aien-dev/omega-mv/pull/801)) changed no compiler file after `3364a1dfd`:
`seed/out/omc` and its sidecar are still `befb8199...8a1d`, the backend pin above. Read only; not
rebuilt for this note.

- **OM-2 is merged.** The opt-in profile (first non-`note` line `om2`, `om2 diag` or `om2 fmt`)
  landed through [#750](https://github.com/aien-dev/omega-mv/pull/750),
  [#753](https://github.com/aien-dev/omega-mv/pull/753),
  [#754](https://github.com/aien-dev/omega-mv/pull/754),
  [#764](https://github.com/aien-dev/omega-mv/pull/764), the SHA-256 cutover
  [#776](https://github.com/aien-dev/omega-mv/pull/776) and the qualification harness
  [#752](https://github.com/aien-dev/omega-mv/pull/752). What `omc` implements is
  [OMEGESE section 9.13](https://github.com/aien-dev/omega-mv/blob/19f014f2178ca9cd3473728fe00a475a2398c409/docs/one_layer/OMEGESE.md#L624).
- **The normative OM-2 contract is on main since #801**, byte-identical to branch `om2/contract`
  @ `23fc7f5c9`: `spec/omegese-om2.md` sha256 `245bb74e940c811ab325e6fabb33f0599ad46aaf6b9064fd2750c43980040881`,
  `spec/omegese-om2-errata.md` (E1..E18) `7b8c1ea58738806cfc29a145a2d60ede5e1c399366a1665004859304bdd2d671`,
  `spec/omegese-om2-measure.md` `507702d0e69ccc76cefb3675e2b22f7279497d362b42ee3043f3a1057aa17bad`.
  Before #801 these files existed only on that branch; older notes that call the contract "missing"
  or "draft only" are stale.
- **OM-2 is frozen.** `spec/omegese-om2.md` says "A change after freeze needs `omegese-om3.md`", and its
  sha256 `245bb74e…` is pinned by `evidence/OM2-COMPILER/*/PINS.txt` and
  `seed/qualification/om2/oracle/s0s2/PROVENANCE.txt`. Never edit it to add a feature: write the
  addition in `spec/omegese-om3.md` (first proposed in draft omega-mv#1008, not on main 2026-11-04).
  The errata file only resolves conflicts inside the frozen text.
- **Omega 1.0 roadmap:** [`docs/ROADMAP-1.0.md`](https://github.com/aien-dev/omega-mv/blob/19f014f2178ca9cd3473728fe00a475a2398c409/docs/ROADMAP-1.0.md),
  milestones RM1..RM11 with acceptance gates, tracked in
  [#790](https://github.com/aien-dev/omega-mv/issues/790) (gate coverage),
  [#791](https://github.com/aien-dev/omega-mv/issues/791) (contracts),
  [#792](https://github.com/aien-dev/omega-mv/issues/792) (efficiency),
  [#793](https://github.com/aien-dev/omega-mv/issues/793) (memory model),
  [#794](https://github.com/aien-dev/omega-mv/issues/794) (strings),
  [#795](https://github.com/aien-dev/omega-mv/issues/795) (modules),
  [#796](https://github.com/aien-dev/omega-mv/issues/796) (bridge FFI),
  [#797](https://github.com/aien-dev/omega-mv/issues/797) (diagnostics),
  [#798](https://github.com/aien-dev/omega-mv/issues/798) (targets),
  [#799](https://github.com/aien-dev/omega-mv/issues/799) (compiler trust and C retirement),
  [#800](https://github.com/aien-dev/omega-mv/issues/800) (stability). It is a plan, not a readiness
  claim; a gap listed there is missing, not impossible.
- **Gate coverage at main:** `seed/wasm/gate-irwasm.sh` and `seed/qualification/om2/gate.om` are
  merged but no `tests/gates/*.gate` runs them (RM1, #790). `tests/gates/run.sh seed` passing says
  nothing about OM-2 fixtures or irwasm; run those yourself and report them separately.
- **OM-2 defect** [#775](https://github.com/aien-dev/omega-mv/issues/775), closed 2026-10-29: an
  empty `text` passed to a `view uchar *` parameter was reported to see the next text's bytes
  (`len` 32, not 0). Fixed by #897 inside the #904 merge `e2662fff`, an ancestor of main
  `bf54b19f`: an empty `text` is now a sized array of length 0. On 2026-10-29, with main
  `seed/out/omc` `62775d2a...712b` (AArch64 host), `seed/omc/om2/s4/v-text-empty.om` compiled
  and ran with exit 0, and `v-bad-text-empty.om` refused with `omc: line 5: error 21`. Compiler
  pins in this file older than the #904 batch predate the fix.
- **Semantic tools, merged:** `seed/semhash` ([#830](https://github.com/aien-dev/omega-mv/pull/830),
  train r4, main merge `f9a9a40b`, 2026-11-02) is a per-function meaning hash plus `diff` that ignores
  local/parameter renames, notes, layout and function order; its oracle requires `omc(canon(x))` to be
  byte-identical to `omc(x)` for every accepted unit. `seed/effects`
  ([#820](https://github.com/aien-dev/omega-mv/pull/820), train r1, main squash `f56a372a`, 2026-10-30)
  is described in section 9. Both build by concatenation and do not change the compiler. Observed
  2026-11-04 at main `d3d1b1bc`, omc `b4f45121…`: `sh seed/semhash/check.sh` printed
  `SEMHASH PASS cases=249 controls=13`, exit 0.

### Merged compiler batch: contracts, capacity and f32 returns

Omega main `91b3c9326919faf1491e29ae9276929e8349b8c7` merges #768, including executable
contracts #807 and f32 return repair #812. Status: MERGED and EXERCISED on arm64 Linux;
not GPU qualification. The batch receipt is `evidence/BATCH-189ada82/README.md` at that commit.
Host qualification with C oracles, gate5, contract checks and mutants, float and capacity
boundaries and IR-trap mutants passed. Frozen C2 retains three expected failures from the
intentional capacity expansion; `manifest-c2-capacity.txt` records those three newly accepted
units separately. Do not claim the frozen manifest itself passes or rewrite it.

| Item | Value |
|---|---|
| `seed/omc/omc.om` | 11,555 lines, sha256 `de7f5c8035608c244fb612ed5bf7691ae22d3b64735a5e7122fe9d0c67853d2b` |
| `seed/out/omc` | sha256 `189ada82e00bb440cb41351bd252cc68c54a1b1050051cc42a1df700081c3b54` |
| Language text | `docs/one_layer/OMEGESE.md` section 12, "Executable native contracts, version 1" |
| Fixtures | `seed/omc/contracts/contracts.cases` (44 rows), `mutant.cases` (2 mutants, both must FAIL) |
| Size ledger | `seed/omc/size-history.tsv`, row `RM2-capacity-f32` with that sha256 |

The capacity is 4096 functions, 8192 names and 524288 call sites per unit. Native `to f32`
returns now work: internal void return code 12 is distinct from f32 value type 10 and f64 11.
`gate8.sh` exercises f32 values and rejects void-as-value (7) and f32 fallthrough (18).
Consumers must explicitly migrate and qualify their own pins; a main merge does not deploy them.

### Compiler batch 3 (merged #904; superseded on main by #923)

[omega-mv#904](https://github.com/aien-dev/omega-mv/pull/904) merged at
`e2662fffbce1c21ef09da71c0d8808133a6af8ab`; that merge carries the same `omc.om` and
`seed/out/omc` hashes as the tested source below. Tested on 2026-10-28 at
`7bce2a4fddc43268ac2af09cddc4a5a67d78312d` over main `d94a503f7`, merges #896
(integer `bitcast` re-extension), #897 (empty `text` sized `nm_len 0`, view count 0; closes the
#775 defect above), #898 (function names that start with a keyword) and #903 (`pread`/`pwrite`
destination writable check) and reseeds `seed/out/omc` to sha256
`1811d4047f118440cc35e995261af6768b606148cb17e18c42158afd15fcad58` (12,577 source lines, 418
functions, size-history row `RM-batch3-current`). Compiler source SHA-256:
`d33ef5cab603f85a5cbcbdfdd55391f2ce0448bfcbc5fecbf0393599b636ef04`.
Status when recorded: HOST_TESTED before merge; merged in source, not deployed. The targeted regression cases, seed/GATE5,
OM-2 s1 through s4 and their mutants, current-language quantity cases, diagnostic experiment,
bindings/parity, JSON/HTTP, WebAssembly, CPU OpenCL, IR-trap checks and local TLS suites pass.
The frozen C2 corpus still fails its six historical assertions; its capacity and batch2
replacement manifests pass. TLS live-internet parity and GPU gates are NOT_RUN.
The earlier `397346de` receipt remains immutable history in `evidence/BATCH-397346de/`.
At this new pin, the guide's FNV example with `abc` outputs `0be9471a` (exit 0), the narrowing
example exits 105, and removing its unmasked store exits 44. All compile with empty stderr.
Main has since moved to the x86 integration compiler `62775d2a...712b` and then to `2aec185d…d8d5` (section 0); cite
`1811d404...ad58` only as the #904 merge pin, never as current main or as x86 qualification.


Re-check recipe (read only, in a fresh clone, never in a shared working tree another agent may be using):

```sh
git clone rad://z6do9WDBhuSnvopDkgFdFr1yWA62 omega-src
git -C omega-src checkout f4df82394e35893dcf1354dda69a2fe028d94bc1
git -C omega-src rev-parse HEAD
sha256sum omega-src/seed/omc/omc.om omega-src/seed/out/omc
```

If the hashes differ from the table, the rules below are unverified for that tree. Read the changed
parts of `OMEGESE.md` and `omc.om` first.

Status words used here: **implemented** (in `omc.om` at the pin), **gated** (a committed gate script
or fixture checks it), **author-verified** (the repository records a run; not re-run for this note),
**proposed** (described, not on `main`). Nothing here is hardware qualification, and nothing here is
deployed anywhere.
### `qty`: checked quantities, not modular words

At the current candidate pin, `qty` is distinct from `ulong`. Do not silently mix
quantity arithmetic with modular words. Save this as `qty-overflow.om`:

```text
fn main to int
a = qty 18446744073709551615
b = qty 1
c = add a b
ret int 0
end
```

Use the section 1a compile/run recipe with `prog.om` replaced by `qty-overflow.om`.
Observed: compile exit 0, empty stderr; run exit 101, empty stdout and stderr.
The boundary literal is copied from the pinned `tests/quantity/qty_add_overflow.om`.

Negative control: change only `a = qty 18446744073709551615` to `a = qty 0`
and `ret int 0` to `ret int c`. Observed: compile exit 0, run exit 1,
empty stdout/stderr. The trap is not an unconditional program exit.

For the modular contrast, replace both `qty` spellings with `ulong` and return
`int c`. Observed: compile exit 0, run exit 0, empty stdout/stderr: `ulong`
still wraps. Mixed operands are refused, not coerced:

```text
fn main to int
a = qty 1
b = ulong 1
c = add a b
ret int 0
end
```

Observed: compile exit 7, empty stdout, stderr:

```text
omc: line 4: error 7
```

### `check` and `next`: text diagnostics and prefix context

These are leading input lines to the seeded compiler, not command-line flags
and not the legacy C `omegese next` interface. At the current candidate pin:

```sh
printf 'check\nfn main to int\nret true\nend\n' | seed/out/omc
```

Observed stdout (exit 7):

```text
omega-diag v1
om1 TYPE span=19-23 FINAL REPAIRABLE code=7 line=2 expect=value found=true
```

Observed stderr:

```text
omc: line 3: error 7
```

Negative control: replace `ret true` with `ret 0`. Observed exit 0, empty stderr,
stdout exactly `omega-diag v1` followed by a newline. Check mode emits diagnostics,
not an executable. Its record line is relative to the program after the leading
mode line; the ordinary stderr line includes that mode line.

```sh
printf 'next\nfn main to int\na = ulong 3\nwhile lt a 9\n' | seed/out/omc
```

Observed exit 0, empty stderr, stdout:

```text
omega-query v1
scope: function
constructs: ret if while for trap exit put end note break continue
names:
a ulong local
functions:
fn main to int
```

This is prefix context (scope, constructs, visible names and signatures), not a
promise of an exact next-token mask. The unfinished loop above is intentional.
Negative control: compare the observed query with a copy whose name line is
`a ulong param`. Observed comparison: unequal (`REJECTED`), so a local/parameter
kind error is detectable.


## 1. Which language is which

| Thing | Where | Status |
|---|---|---|
| **Omegese**, the `.om` language | `docs/one_layer/OMEGESE.md`, sections 1-11 on main | current |
| Profile **OM-2** (opt-in per unit) | contract `spec/omegese-om2.md` plus errata E1..E18 (normative, on main since #801); implemented subset in OMEGESE section 9.13 | current, merged; host evidence only |
| WebAssembly MVP backend `seed/wasm/irwasm.om` | OMEGESE sections 11.1-11.2; scalar OSC IR v1, plus IR v7 (regions, f32/f64, RLOAD/RSTORE/BITCAST/RINIT) since #818 reached main in train r4 `f9a9a40b` (2026-11-01). omc IR mode still writes only v1; v7 test units come from `seed/wasm/v7/writer.js`. `seed/equiv/irequiv.om` keeps the v1 reader, and `seed/equiv/gate-irequiv.sh` checks irwasm's reader against it plus the edits recorded in `seed/equiv/irwasm-v7.sed` (omega-mv #1039) | merged; neither gate in any manifest (#790) |
| Executable contracts (`requires`, `ensures`, `invariant`, `result`) | OMEGESE section 12; section 11a here | merged in #768, including #807; host-exercised |
| The seeded compiler `omc`, written in `.om` | `seed/omc/omc.om`, built `seed0 -> hex1 -> asm2 -> om4 -> omc` by `sh seed/omega-from-seed.sh` | on `main` since PR #696 ([README.md#L27](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/README.md#L27)) |
| Keyword table, the authority for reserved words | `fn kw` in `seed/omc/omc.om` ([#L375](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/omc.om#L375) at `55f9b0af`, [#L765](https://github.com/aien-dev/omega-mv/blob/e5b32567a7aff3ce594e3254a622a846a6cd190b/seed/omc/omc.om#L765) at `e5b32567`, [#L818](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/omc.om#L818) and `fn kw2` [#L1328](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/omc.om#L1328) at `91c83438`); same list in `seed/omc/genkw.awk` ([#L16](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/genkw.awk#L16) at `55f9b0af`; [#L16-L18](https://github.com/aien-dev/omega-mv/blob/e5b32567a7aff3ce594e3254a622a846a6cd190b/seed/omc/genkw.awk#L16-L18) at `e5b32567`, which adds `flock` 197 and a second list for `peercred`, `pollfds`, `sendmsg`; [#L17-L20](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/genkw.awk#L17-L20) at `91c83438`, whose second list adds `qty`, `cpufence`, `cpurelax`), parity checked by `seed/omc/gate18.sh` | gated |
| C translator `tools/omegese/omegese.c` and `omegese next` | OMEGESE sections 1-8 | legacy referee and token-mask tool, not the compiler |
| `spec/omega-language-v0.md` (`let x: u8 = ...`, `fn f(x: T) -> T { }`, `//` comments) | Visor console line language, lowered by C in `src/language/` ([#L1-L13](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/spec/omega-language-v0.md#L1-L13)) | history; never write `.om` in that syntax |
| C under `src/`, including `src/compiler/` | `main` | unfinished migration ([README.md#L50](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/README.md#L50)) |

OMEGESE sections 2-6 describe the C translator's rules; sections 9-12 describe `omc` at
`91b3c932`. Where they
disagree, `omc` is what compiles your program:

- Calls: the C path allows calls to earlier functions only. `omc` reads every signature first, so a
  call may name any function in the unit; recursion is allowed in program mode and refused (error 9)
  in function mode ([OMEGESE#L409-L417](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L409-L417)). IR mode
  (a leading `ir` line) again allows earlier functions only ([#L755-L763](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L755-L763)).
- **IR-mode `TYPE value` casts** (merged on omega-mv main as [omega-mv#967](https://github.com/aien-dev/omega-mv/pull/967),
  squash commit `96ea448add639f8448a4787ef36a2ade06a1a244`, 2026-10-31; harness issue #141). In IR mode a
  cast reads its operand at the operand's own type, so it converts an operand of any scalar type; a bare
  number is range-checked against the cast's type (error 8); bool to or from a number is refused (error 9),
  a bool comes only from a comparison. Pinned by `seed/omc/gate-ir.sh`. Observed (host only) with omc
  sha256 `e4d84bc3ff5c91b83ce9a156d262eb28c9563e43374537293129898da093b7a6` built from seed at omega-mv
  main `d39450a23b5936a0aafd35cc23ca70e5468fd4c0`: `ret ulong sub c 48` and `ret long sub c -128`
  compile; `ret uchar 256` and `ret ulong sub c 300` (c uchar) are error 8; `ret bool c` and
  `ret ulong eq a b` are error 9. An earlier pin of this skill (omega-mv `91c83438`, omc `2aec185d…`)
  predates #967: it gives error 7 for the two widening casts and for `ret ulong eq a b`, and compiles
  `ret bool c`. The pins `9920aab1` and `d3d1b1bc` include #967 (since `3a163bc5`): observed 2026-10-31, the
  IR unit `fn dig c uchar to ulong` / `ret ulong sub c 48` compiles with omc `24caacf4…` (124 bytes of
  IR) and is `omc: line 3: error 7` with `2aec185d…`; with omc `be8c5130…` the `ir` unit
  `ir` / `fn dig c uchar to ulong` / `ret ulong sub c 48` / `end` compiles with exit 0 to output
  byte-identical to `24caacf4…`'s (sha256 `40b76639…6cba`).
- `new` lengths: C path 1..64 ([#L85](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L85)); `omc` 1..16777216
  per array and at most 4 MiB of local arrays per function ([#L460-L463](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L460-L463), gate12; "per function" observed
  2026-11-04 with omc `be8c5130…` and `2c824805…`: `examples/local_arrays_per_fn.om` and
  `mistake_local_arrays.om`).
- Unread names: the C path refuses a name that is written and never read ([#L37-L38](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L37-L38)).
  `omc` fixtures contain unread results (`w = write ...` in `seed/rung4/tests/bytecopy.om`). Do not
  rely on either behaviour; check every result you write.

Language rule: `.om` is the only forward first-party implementation language. C, Rust and shell that
remain are unfinished migration, not exemptions ([README.md#L50](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/README.md#L50)).
- **Tokenization is not a language rule:** Language design optimizes for verified programs produced
  per unit of inference cost (measured on held-out tasks by first-attempt correctness, successful
  compilation, verified behavior, latency, and total compute cost). Fitting words into single tokens
  under particular tokenizers (e.g. Qwen3) is an empirical measurement and cost consideration, not a
  binding rule of Omega or Omegese. The compiler-guided interface remains portable across models and
  tokenizers.

## 1a. Compile and run (Linux AArch64 host only)

```sh
OMC=omega-src/seed/out/omc                 # after checking its sha256 against section 0
"$OMC" < prog.om > prog 2> prog.err
compile_rc=$?
printf 'compile rc=%s\n' "$compile_rc"
cat prog.err
if [ "$compile_rc" -eq 0 ]; then
    chmod +x prog
    ./prog
    run_rc=$?
    printf 'run rc=%s\n' "$run_rc"
fi
```

Only compile status 0 permits running the new output. Check the runtime status
separately: a program may intentionally return nonzero (modulo 256), and a trap
has its own status. Empty compiler stderr alone is not a successful compile.
To rebuild the compiler from the seed instead, run `sh seed/omega-from-seed.sh` from the root of a
disposable clone (prints `PASS ...` lines and `RC=0`). It writes `build/seed/`, rewrites the tracked
`seed/rung4/om4.s` size word and `seed/rung4/om4.bin` (`seed/rung4/mk4.sh`), and rewrites
`seed/out/omc` and `seed/out/omc.sha256` with whatever fixpoint it reached, so check `git status`
and compare the new hash with the pin yourself ([omega-from-seed.sh#L52-L60](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omega-from-seed.sh#L52-L60)).
Full host qualification is `sh seed/host/check.sh` (author-verified on 2026-10-23 per
`seed/host/README.md`); a host pass is never hardware qualification.

## 2. Program shape

```
note any text to the end of the line
const LIMIT ulong 64
global buf uchar 4096
text msg "hello\n"
struct Pair a uint b long end
fn helper x ulong y ulong to ulong
ret add x y
end
fn main to int
ret 0
end
```

- One statement per line; words separated by spaces or tabs; no commas, semicolons, braces or
  indentation. `note` is the only comment form; the rest of its line is not read
  ([omc.om#L4873](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/omc.om#L4873)).
- `fn NAME (PARAM TYPE)* to TYPE|void` ... `end`. At most 6 parameters (error 9). `main` takes none.
  In an OM-2 unit the limit is 6 parameter *slots*: an unsized array (`view T *`, `edit T *`) takes 2,
  so a 7th slot is error 9 on the `fn` line (observed with omc `befb8199`, 2026-10-26, building
  omega-mv `om/tls`). Pack small fixed inputs into one array. A scalar or a sized array
  (`view uchar 8`) takes one slot: `fn f a view uchar * b view uchar * c ulong d ulong to ulong`
  (6 slots) compiles, adding `e ulong` is `line 2: error 9`, and two `view uchar 8` plus three `ulong`
  (5 slots) compiles in both OM-2 and OM-1. `part B OFF LEN` (OM-2) is an argument form only:
  binding it to a local (`r = part b 0 4`) is error 9; pass `part` directly in the call (exit 4 for a
  4-byte part). In an OM-1 unit the same call is `error 3` (unknown name). First probed on omc `2c82480596bb…`
  (omega-mv `audit/tls-integration` 9472e9615); all rechecked 2026-10-31 with main omc
  `62775d2a…712b` at omega-mv `4376c2112`.
- A unit with `fn main` is a static AArch64 Linux ELF (program mode). Without `fn main` the output is
  bare function words (function mode): it compiles with exit 0 but is **not runnable**. Host words
  and `global` are error 9 there, and `text` is program-mode only ([#L400-L407](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L400-L407), [#L454-L459](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L454-L459), [#L629](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L629)).
  **PENDING exception, draft [omega-mv#1008](https://github.com/aien-dev/omega-mv/pull/1008)** (`2992a68b`,
  omc `c000ec02…b911`, not on main, 2026-11-04): an OM-2 function unit (first line `om2`, no `fn main`)
  may use `fopen fclose fstat stat lstat getuid geteuid getgid getegid` on AArch64; every other host
  word, any host word in an OM-1 unit and any other target stay error 9 (gate
  `seed/omc/om2/fnhost/fnhost.cases`; PROPOSED contract `spec/omegese-om3.md` section 1). The
  omega-bridge binds such a unit only with `tools/native --host` (omega-bridge#54, merged 2026-11-05
  as `d1124611`; the bridge side is on main, the compiler side is not). With main's compilers (the
  harness pin omc `b4f45121…` at omega-mv `d3d1b1bc`, and the previous `be8c5130…`) these are still
  error 9.
- Program exit status = `main`'s value mod 256 (0 for void main). `exit v` (v `int`) ends at once.
  A runtime trap exits **100 + code**. Keep your own exit codes below 100, or a result is
  indistinguishable from a trap ([#L404-L407](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L404-L407), [#L484](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L484)).
- A value-returning function used as a statement is error 7; a bare host word used as a statement
  (`write 1 m 0 3` on its own line) is error 16 (observed 2026-10-26, omc `befb8199...a1d` at omega-mv
  `19f014f2`; rechecked 2026-10-31 with main omc `62775d2a…712b` at omega-mv `4376c2112`: bare
  `write` gives `omc: line 3: error 16`, a bare call of a value-returning `fn` gives error 7, and the
  bound form prints and exits 0). Bind the result either way: `w = write 1 buf 0 n`.
- A function with a return type whose `end` is reachable is error 18. `ret`, `break`, `continue`,
  `trap` and `exit` end the path; a line after them in the same block is error 17.

## 3. Values: prefix words, fixed arity

Every operator is a prefix word with a fixed number of values, so nesting needs no brackets:
`add mul r r 4` = (r*r)+4; `eq rem n 2 0` = (n mod 2)=0 ([#L73-L75](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L73-L75)).
Evaluation is innermost first, left to right ([#L137-L141](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L137-L141)).

| Words | Takes | Result |
|---|---|---|
| `add sub mul div rem and or xor shl shr` | 2 | same type as operands |
| `eq ne lt le gt ge` | 2 | `bool` |
| `neg not` | 1 | negate / bool not or bitwise not |
| `TYPE v` | 1 | typed number (`uint 5`) or checked conversion (`ulong x`) |
| `bitcast TYPE v` | 2 | same-width reinterpretation (section 5) |
| `get A i`, `get S f`, `get S f i` | 2-3 | load from array / struct field |
| `len A` | 1 | array length, `ulong` |
| `sizeof T`, `offsetof S f` | 1-2 | compile-time `ulong` ([#L591-L599](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L591-L599)) |
| `FUNCTION args` | its parameter count | call |
| `( v )` | 1 | grouping only; adds no code ([#L583-L588](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L583-L588)) |

There are no infix operators. `+ - * /` are not keywords (they are absent from the keyword table);
OMEGESE 9.9 ([#L564](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L564)) writes "`+ - * /`" but its own
float fixtures use `add sub mul div` (`seed/omc/tests/float/arith.om`). Write the words. Observed at
`e5b32567`: `y = x + 1` is error 5 (`examples/mistake_infix.om`).

`and` / `or` evaluate **both** sides; there is no short circuit ([#L104](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L104)).
`and lt i len a eq get a i 0` still loads `a[i]` when `i` is out of range and traps 3. Test the
bound in an outer `if`, then load inside it.

## 4. Types, literals, typing

- Types: `bool uchar ushort uint ulong byte short int long` = bool, u8, u16, u32, u64, i8, i16, i32,
  i64; aliases `u8 .. u64`, `i8 .. i64`; floats `f32 f64` ([#L109-L111](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L109-L111), [#L549](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L549)).
  `uchar` is an 8-bit number, never a character ([#L442](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L442)).
- **No implicit conversions** (decision 20): both values of an op, a value and the name it is written
  to, an argument and its parameter must have the same type, else error 7
  ([#L440-L442](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L440-L442)). `add get b 0 uint 1` with `b` a
  `uchar` array is error 7; write `add uint get b 0 1`.
- A bare number takes the type of the other value in its op, or the type its place needs
  (`ret 0`, an argument, an index). Two bare numbers in one op, or a bare number with no context
  (`x = 5` for a new `x`), is error 11: write `x = uint 5` ([#L94-L100](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L94-L100), gate15 `e11_ambiguous`).
- Integer literals: decimal only, optional leading `-`, at most 20 digits, and the value must fit the
  type it takes (error 8), e.g. `long` -2^63..2^63-1, `ulong` 0..2^64-1. A non-digit (`12a`,
  `0x10`) is error 6 ([#L443-L446](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L443-L446)). In an OM-1 unit: no hex, no octal,
  no character literals: write byte 65, not `'A'` (error 3). OM-2 units (first non-`note` line `om2`)
  also take lowercase hex, `0xdeadbeef`, which must still fit its type (`int 0xffffffff` is error 8,
  `0X10` is error 6; observed at `e5b32567`; full rule in the next item). An `om2` unit with
  `x = uint 0x10` compiled and the program exited 16; the same line without `om2` is error 6 (omc
  `befb8199...a1d`, 2026-10-26; same results 2026-10-31 with main omc `62775d2a…712b` at omega-mv
  `4376c2112`; see also **Hex** in section 8).
  `true` / `false` are the bools.
- Hex literals, OM-2 units only (`om2` first non-note line; `spec/omegese-om2.md` section 2): `0x`
  then 1..16 lowercase digits `0-9a-f`, value unsigned, typed by the place under the decimal range rule
  (`int 0xffffffff` is error 8: no two's-complement reinterpretation). Error 6: `-0x..`, `0X`, no
  digits, 17+ digits, uppercase, `_`, any other character. `0x2a` and `42` compile to identical bytes;
  signed minima need decimal. An OM-1 unit, IR mode included, has no hex literal (error 6). Fixtures:
  `seed/omc/om2/hex/` (gate PR #951, merged by train r3 #979 as `4376c2112`). Rerun 2026-10-31 at
  main `91c83438d` with omc `2aec185d…`: `hex.cases` gives `OM2GATE PASS cases=51 pass=51`, and
  `mutants.cases` gives the expected `OM2GATE FAIL cases=8 pass=3 fail=5` (each `tok_hex` mutant killed).
- Shift with a bare left operand takes the shift amount's type: `shl 1 sh` with `sh` a `uchar` shifts
  a `uchar`. Write `shl ulong 1 sh` when you mean 64 bits ([#L97-L99](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L97-L99)).
- Float literals: `digits.digits[e[+|-]digits][f32|f64]`, a digit on both sides of the dot; exact
  decimal-to-binary rounding; overflow to infinity is error 8 ([#L555-L563](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L555-L563)).
  Two compiler defects in float literals are fixed at main `91c83438d` (#965, omc `2aec185d…`;
  source [`fparse`/`fexp`/`fbits`](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/omc.om#L1908-L1913)
  and [`fspan`](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/omc.om#L2252-L2255)).
  Observed 2026-10-31 on the AArch64 host, with omc `7a8b84fc…` (main before #965) as the control:
  - **Miscompile: float literal of 64 or more characters without an `f32`/`f64` suffix.** Such a
    literal is converted late, once its type is known, from a stored span `pos*64+len`; a length of
    64 or more spilled into the position, so the wrong input text was read (the `fspan` note above).
    `x = f64 2.0` / `y = add <61 zeros>1.5 x` / `ret int y` (a 64-character literal) exits 2 with
    `7a8b84fc` and 3 with `2aec185d`; 70 zeros: 2 and 3; 60 zeros (63 characters) and plain `1.5`:
    3 with both. The type word does not avoid it: `add f64 <70 zeros>1.5 x` and
    `x = f64 <70 zeros>1.5` / `add x f64 2.0` also gave 2 with `7a8b84fc` and 3 with `2aec185d`.
    The suffixed `add <70 zeros>1.5f64 x` gave 3 with both. A binary built by an older omc from
    such a literal computed with the wrong value; recompile it.
  - **Literals longer than about 1000000 characters.** The digit scans ran under the 1000000-pass
    loop guard, so the compiler itself trapped 4 (exit 104, no diagnostic) on such a literal. Now
    they compile: `x = f64 <1000001 zeros>3.5` / `ret int x` exits 3, `1.5e<1000001 zeros>1` gives
    15, `add f64 0.<1000001 zeros>1 f64 7.0` gives 7 (each compile 104 with `7a8b84fc`). The
    mantissa limit below still applies: `7.<1000001 zeros>1` is error 8 with both compilers.
- Named constants: `const NAME TYPE LITERAL` at top level, visible only after their definition, also
  usable as array lengths, `trap` codes and `while` bounds ([#L602-L622](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L602-L622)).

## 5. Arithmetic, conversions and traps

From OMEGESE 9.3 ([#L429-L447](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L429-L447)), gate fixtures in
`seed/rung4/tests/t_*.om` with expected statuses in the matching `.want` files:

| Behaviour | Result | Fixture |
|---|---|---|
| Unsigned `add sub mul shl neg not` | wrap mod 2^width | gate 3 |
| Signed `add sub mul neg div shl` out of range (incl. MIN div -1) | trap 1, exit 101 | `t_ovf.om` -> 101 |
| `div` / `rem` by zero | trap 2, exit 102 | `t_div0.om` -> 102 |
| Array index or I/O slice out of bounds (also a negative signed index) | trap 3, exit 103 | `t_bounds.om`, `t_rw.om`, `t_write_wrap.om` -> 103 |
| Loop past its bound | trap 4, exit 104 | `t_loop.om` -> 104 |
| Conversion whose value does not fit the new type | trap 5, exit 105 | `t_conv.om`, `t_conv_sign.om` -> 105 |
| Call or local array below the 8 MiB stack | trap 6, exit 106 | `t_stack.om` -> 106 |
| Shift amount outside 0..width-1 (every type) | trap 7, exit 107 | gate 4 s.5 |
| `trap N`, N 1..14 | exit 100+N | `seed/omc/tests/loop/t1.om` -> 105 |

Signed `div` rounds toward zero; signed `rem` has the dividend's sign; signed `shr` keeps the sign.
Comparisons follow the operand type: with `ulong` x = 2^64-1 and y = 1, `lt x y` is false
(`t_cmp_unsigned.om` -> 0).
Floats never trap: IEEE results, NaN compares false except `ne` ([#L564-L567](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L564-L567)).

Conversions are **checked**, not truncating. `uchar x` with x = 300 traps 5. Mask first:
`uchar and x 255` (see `examples/trap_narrow.om`). `long x` with x = 2^63 as `ulong` traps 5.

`bitcast T v` reinterprets bits of the same width; `bool` and different widths are error 7, a bare
number is error 11 ([omc.om#L4640-L4662](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/omc.om#L4640-L4662)). Every fixture
uses it between floats and unsigned integers. The code also accepts integer-to-integer of equal
width. At omc `2c824805` results across signedness below 64 bits were wrong (section 0). At omc
`62775d2a` the two measured 32-bit pairs are correct; narrower pairs and `f32` to `int` were not
retested. Do not bitcast an unmeasured pair; decode signed values arithmetically (section 10).

Float to integer conversion is the exception to "checked": it truncates toward zero and saturates at
the target's limits, and a NaN gives 0, with no trap (observed at `e5b32567`,
`examples/float_to_int.om`).

## 6. Names, scope, registers

- Function names: up to 63 characters. Every other name (variable, parameter, global, text, const,
  struct, field): **at most 8 characters**, else error 13 ([#L423](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L423), gate15 `e13_long_variable`).
  Rechecked 2026-11-04 (Linux AArch64): `counter_a = int 20` is `omc: line 2: error 13` with both the
  harness pin omc `be8c5130…` (omega-mv `9920aab1`) and omega-mv main `d3d1b1bc`'s omc `b4f45121…`.
- PENDING, not merged or pinned: draft [omega-mv #837](https://github.com/aien-dev/omega-mv/pull/837)
  (head `f1b9ecb5d13f3b7303c055a187fff06e802eb952`, base `integ/omc-batch3`, source-only: its committed
  `seed/out/omc` is still the old `2c824805…`) raises every such name to 63 bytes, compared in full.
  Rebuilt from that head with `sh seed/omega-from-seed.sh` on 2026-10-30 (`RC=0`, `PASS omc fixpoint
  21d34e12eb6516a2c5f3fc160ccb0feca5054786c57def055056c04270c302fa`); with that compiler
  `counter_a = int 20`, `counter_b = int 1`, `ret add counter_a counter_b` ran with exit 21, a 63-byte
  local compiled and ran, a 64-byte local is error 13, and an IR-mode parameter `counter_a` is still
  error 13. IR-mode locals and parameters, `abstract`/`layout` names and layout fields stay at 8, and so
  does om4. Until #837 lands and is pinned, keep names at 8.
- A new name may not equal a visible name, a function or a struct (error 10). A name first written
  inside `if` / `else` / `while` / `for` dies at its `end`; assign it before the block to carry it out.
- **Declaration order.** Only functions may be named before their line. A `text`, `const` or
  `global` named in a function above its own declaration line is error 3 at the use, so put them all
  above the first `fn` (`examples/decl_order.om` exit 8, `mistake_decl_order.om` error 3; observed
  2026-11-04 with omc `be8c5130…` and `2c824805…`, host only).
- A `global` is visible only to lines after its declaration: a function above it that reads it is
  **error 3** (unknown name). `global` needs program mode, so the unit must have `fn main` (without
  it `global` is error 9). Checked 2026-11-04 on omc `2c824805…` via the omega MCP: `fn f to ulong`
  / `ret get g 0` / `end` / `global g ulong 4` / `fn main to int` / `ret int f` / `end` gives
  `omc: line 2: error 3`; the same seven lines with the `global` line first compile and exit 0;
  the first four lines with the `global` first and no `fn main` give error 9 (`omc: line 5: error
  9` with a trailing newline). In multi-file units (`build.sh` concatenation) the file that
  declares a global must come before every file that uses it.
- Reserved words cannot be names. Besides the obvious ones, the table reserves `len read write text
  new free own view edit global note exit const bound` and every host word, including `stat link bind
  send recv random fork cwd chdir umask accept listen connect waitio memfd mapget mapset`. `bits min
  max abs sqrt` are deliberately **not** reserved (gate11), and they are not operators either: `ret
  min a b`, `max`, `abs` and `mod` are all error 3 (unknown name) with omc `be8c5130…`. Remainder is
  `rem` (`ret rem a b` with ints a=7, b=3 exits 1). Check the keyword table, not memory.
  A reserved word used as a name is **error 16** (unknown word), not error 10, so the message does
  not say "reserved". Observed on omc `2c824805…` (omega-mv `e5b32567`), host only: `fn f len ulong
  to ulong` gives `omc: line 1: error 16`, and a local `len = ulong 3` gives `omc: line 2: error 16`.
  The same program with the parameter renamed to `n` compiles (exit 0). Use `n`, `cnt` or `size`.
- **`dit` and `scrub`: merged in [omega-mv#875](https://github.com/aien-dev/omega-mv/pull/875) as
  `2367874399001efdc7f1ff345fb327469bc1a135` (2026-10-31), committed omc sha256
  `3862655902e3bb9f502ebca2e1e5e5edb6175bf512be731a63c700a6dce8d355`; included in the current pin
  `d3d1b1bc` (omc `b4f45121…`), in `9920aab1` (omc `be8c5130…`) and in `3a163bc5` (omc `24caacf4…`).** Keyword ids: `dit` 225, `scrub` 226 in `fn kw2`, the OM-2 table
  ([omc.om#L1329](https://github.com/aien-dev/omega-mv/blob/2367874399001efdc7f1ff345fb327469bc1a135/seed/omc/omc.om#L1329),
  [#L1384-L1388](https://github.com/aien-dev/omega-mv/blob/2367874399001efdc7f1ff345fb327469bc1a135/seed/omc/omc.om#L1384-L1388)).
  Both are emitted inline, not as helper functions, because om4 holds 512 functions and `omc.om` is at
  that limit ([#L7525-L7526](https://github.com/aien-dev/omega-mv/blob/2367874399001efdc7f1ff345fb327469bc1a135/seed/omc/omc.om#L7525-L7526));
  the merge commit has 512 `^fn ` lines. Two OM-2-only, program-mode-only, AArch64-only value
  words, reserved only in `om2` units. `dit v` (v int 0/1, else trap 3) writes PSTATE.DIT and gives the
  previous bit as a long. `scrub n` (n ulong, a multiple of 16, at most 1048576, else trap 3; trap 6 when
  SP - n is below the stack floor) zeroes `[SP - n, SP)`, the dead general registers (free pool
  registers, X16, X7, X18-X26, X29), V0-V15 and every dead float twin V16+j (since #994; up to
  `3a163bc5` all of V0-V31), and gives 0. Refusals: function mode error 9, a wrong
  operand type error 7, use as a name or as a bare statement (`scrub 16` on its own line) in an `om2`
  unit error 16, `target x86linux` error 25; `ir` with `om2` is already error 16. Observed with omc
  `38626559…` on 2026-10-31 (host only), each fixture of `seed/omc/om2/s5/` at `23678743` run directly:
  `dit-ok` exit 0, `dit-two`/`dit-neg`/`scrub-odd`/`scrub-big` trap 3 (exit 103), `scrub-floor` exit
  106, `scrub-ctl` exit 10 (its negative control), `scrub-mem`/`scrub-live`/`scrub-emit`/`om1-names`
  exit 0, the refusal fixtures 9/7/16 as above, `scrub-emit` output sha256 `5ba83eaf…` as in
  `s5.cases`, and `dit-ok` behind `target x86linux` error 25. The previous pin omc `2aec185d…` does not know
  the words: every fixture that uses them is error 3, while `dit-name`/`scrub-name` (the words as
  names) compile as in OM-1, and `scrub-ctl`/`om1-names` behave as with `38626559…`.
  Rerun 2026-10-31 with the then pinned omc `24caacf4…` (host only): every `s5` fixture gives the same exit
  as with `38626559…` above, `scrub-emit` output sha256 `5ba83eaf…` again, and `dit-ok` behind
  `target x86linux` is `omc: line 6: error 25`; the pin before it, `2aec185d…`, still gives error 3 for
  the fixtures that use the words.
  **Fixed by [omega-mv#994](https://github.com/aien-dev/omega-mv/pull/994) (`9920aab1`): `scrub`
  keeps live floats.** Up to `3a163bc5` (omc `24caacf4…`) the emitter zeroed all of V0-V31 although
  #853 keeps f32/f64 locals and held float values in the twin V16+j of their pool slot. Since #994 it
  emits `MOVI #0` only for V0-V15 and the dead twins, sparing the twin of each live slot whose value
  lives there; nothing is saved or restored
  ([omc.om#L7830-L7842](https://github.com/aien-dev/omega-mv/blob/9920aab1413983c2867d02d75b2276341595adb8/seed/omc/omc.om#L7830-L7842),
  [#L7873-L7884](https://github.com/aien-dev/omega-mv/blob/9920aab1413983c2867d02d75b2276341595adb8/seed/omc/omc.om#L7873-L7884);
  OMEGESE 9.13.1). Observed 2026-10-31, Linux AArch64 host: the unit `om2` / `fn main to int` /
  `f = f64 1.5` / `g = f64 2.5` / `k = scrub 16` / `h = add f g` / `if ne h f64 4.0` / `ret 50` /
  `end` / `ret int k` / `end` compiles with exit 0 under both compilers and exits 50 with omc
  `24caacf4…` (the defect) and 0 with omc `be8c5130…`; with `f64 4.5` in the comparison (negative
  control) the `be8c5130` build exits 50. At `9920aab1`, with omc `be8c5130…` run directly on each
  `seed/omc/om2/s5/` fixture: `dit-ok`/`om1-names`/`scrub-mem`/`scrub-live`/`scrub-emit`/
  `scrub-flive`/`scrub-femit` exit 0, `dit-two`/`dit-neg`/`scrub-odd`/`scrub-big` exit 103,
  `scrub-floor` exit 106, `scrub-ctl` exit 10, `dit-fm`/`scrub-fm` error 9, `dit-type`/`scrub-type`
  error 7, `dit-name`/`scrub-name` error 16, and `dit-ok` behind `target x86linux` is
  `omc: line 6: error 25`. The `scrub-emit` output sha256 is
  `5ba83eaff95e73bdca1584d1d8bcfd083b18af549c7da2777f7a5c03005a04cc` (unchanged: no live float
  there) and the new `scrub-femit` output is
  `3d33c8ebfeff422d2ad746952f32fedab01cc46238097bb64b4b9a0a068c20c8` (with `24caacf4` it is
  `c01cd0c5…7b76`, and `scrub-flive`/`scrub-femit` exit 1). `OM2GATE` on `s5.cases` printed
  `OM2GATE PASS cases=21 pass=21 fail=0 invalid=0 not_run=0`; on `s5-mutants.cases` all 7 `ctl-*`
  cases passed and all 9 `m-*` mutants (including `m-twinall` and `m-twinnone`) were detected
  (`OM2GATE FAIL cases=16 pass=7 fail=9`, the expected verdict).
- **16 registers per function** (pool x0-x6, x8-x15, x17; [omc.om#L82-L91](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/omc.om#L82-L91)).
  Parameters, every live name, the hidden counter of each open `while` / value-count `for`, and the
  temporaries of the current statement all draw from it; error 12 when the next one is not available
  ([omc.om#L1479-L1487](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/omc.om#L1479-L1487)). gate15 pins the 17th live name as
  error 12. In practice keep functions to about 10 live names and split deep nested expressions or
  helpers into smaller functions. A name first written inside a block gives its register back at the
  block's `end`: 10 names, 5 more inside `if true` ... `end`, then 5 after it compile
  (`examples/block_frees_registers.om`, exit 15), and the same 20 names without the block are error
  12 on the 17th. One name is enough to exhaust the pool through nesting: `ret add a add a ...` with
  16 `add`s compiles, 17 is error 12 (`mistake_deep_nest.om`); bind partial results on separate lines.

## 7. Arrays, globals, structs

From OMEGESE 9.4 and 9.7 ([#L449-L474](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L449-L474), [#L494-L516](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L494-L516)):

- `global NAME T N`: zero-filled pool in the program image, N 1..16777216, at most 1 GiB of pools
  total (error 23), program mode only. Globals are visible in every function.
- **A global is never passed as an argument** (error 19). A function works on a global by naming it
  directly; parameters carry scalars and local arrays only. Two `part`s of one array, or an array and
  a part of it, in one call are also error 19 (omc `befb8199`). The arrays of one call must be distinct
  names (error 19).
- `NAME = new T N v`: local stack array, N elements each v, only in a function's outermost block
  (error 9 inside a block), at most 4 MiB of local arrays per function (error 23; another function's
  arrays do not count, see `local_arrays_per_fn.om`). **N must be a literal or an
  integer `const`**; a variable length is error 16 (gate16 `len_varname`), so there are no
  run-time-sized arrays. No heap and no `free` (decision 24; `free` is error 9).
- Array parameters state type and length exactly: `a view uchar 64` / `a edit uchar 64` (error 7 for
  any other length), so OM-1 has no length-generic array parameters; use fixed sizes, an integer
  `const`, or a global. OM-2 (`om2` first line) adds unsized views, `a view T *`: one function took
  arrays of 5 and 9 bytes and `len a` returned each length (exit 14; omc `befb8199...a1d`, 2026-10-26;
  also `examples/om2-tour.om` at omega-mv `19f014f2`; rechecked 2026-10-31 with main omc
  `62775d2a…712b` at omega-mv `4376c2112`: exit 14, and the OM-1 form is `line 1: error 16`). A view
  or a `text` is read-only (error 20 on `put`, `read` or `pread` into it; see section 9).
- `get A i`, `put A i v`, `len A`. A constant index outside the array is error 21; any other index is
  checked at run time (trap 3). No word yields an address or adds to one.
- `text NAME "bytes"`: read-only `uchar` array; escapes only `\n \t \\ \"` (error 22 otherwise).
  There is no `\r`: protocols that need CR LF (HTTP, SMTP) write the CR at run time
  (omega-mv `om/tls/test/tls/client.om` `cl_crlf`).
- Structs: fields are 8-byte cells, no padding, no packed layouts (a `uint` field still takes 8
  bytes). `read`/`write`/`len` of a struct are error 7. Never treat a struct as a wire layout.

## 8. Loops and bounds

From OMEGESE section 3 and 4 ([#L58-L60](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L58-L60), [#L131-L135](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L131-L135)) and [omc.om#L5493-L5494](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/omc.om#L5493-L5494);
the bound ranges below are those of the pin `3a163bc5`, and the cited lines are unchanged at the pin `9920aab1` (the `omc.om` ones moved down 10 lines) (OMEGESE [#L63-L69](https://github.com/aien-dev/omega-mv/blob/3a163bc5eafa5be4b9ca97b7f17046c33f0d9032/docs/one_layer/OMEGESE.md#L63-L69),
[#L140-L149](https://github.com/aien-dev/omega-mv/blob/3a163bc5eafa5be4b9ca97b7f17046c33f0d9032/docs/one_layer/OMEGESE.md#L140-L149);
`s_while` [omc.om#L8853-L8854](https://github.com/aien-dev/omega-mv/blob/3a163bc5eafa5be4b9ca97b7f17046c33f0d9032/seed/omc/omc.om#L8853-L8854),
`sf_num` [#L8912-L8915](https://github.com/aien-dev/omega-mv/blob/3a163bc5eafa5be4b9ca97b7f17046c33f0d9032/seed/omc/omc.om#L8912-L8915),
`ir_bound` [#L13162-L13163](https://github.com/aien-dev/omega-mv/blob/3a163bc5eafa5be4b9ca97b7f17046c33f0d9032/seed/omc/omc.om#L13162-L13163)):

- `while COND bound N`: at most N body passes, N 1..9223372036854775807 (2^63-1), a number or an
  integer const; 0 and 9223372036854775808 are error 8 on the loop's line. Without `bound` the limit
  is 1000000 passes. One more pass traps 4. The condition is recomputed before every pass. Merged as
  omega-mv #848 (`157bab57`); before it (pins up to `91c83438`, omc `2aec185d`) the range was
  1..999999 and `bound 1000000` was error 8.
- `for i T K` runs i = 0..K-1. A literal K needs no hidden guard; a name or expression K gets the
  1000000-pass guard. `for i T K bound N` (omega-mv #857, `3a163bc5`) takes the same N as `while`;
  with a bound every count, literal or not, traps 4 after N passes. Before #857 `for` took no `bound`
  word (error 5).
- IR mode (`ir` first line) keeps the C oracle's ranges so that checker2 proves every guard: `bound N`
  on `while` or `for` is 1..1000000, and a number or integer-const `for` count is 0..1000000; outside
  them (a minus sign included) is error 8 on the loop's line. An IR `for` with a value count (a name)
  now carries the hidden 1000000-pass guard; before #857 it was emitted unguarded and checker2
  rejected it (C2-LOOP-UNBOUNDED).
- Observed 2026-10-31, Linux AArch64 host, omc `24caacf4…abb7` (negative control: the previous pin
  omc `2aec185d…d8d5`): `while lt i 1500000 bound 2000000` exits 83 = 1500000 mod 89 (old: error 8);
  `bound 9223372036854775807` and `bound 1000000` compile and run (old: error 8); `bound 0` and
  `bound 9223372036854775808` are `omc: line 3: error 8` on both; `const BIG ulong 5000000` as the
  bound runs 1100000 passes (exit 49 = 1100000 mod 89; old: error 8); `bound 5` with 10 passes wanted
  and 1000001 passes with no bound both exit 104 (trap 4) on both. `for i ulong 1234567 bound 1300000`
  exits 48 = 1234567 mod 89 (old: error 5); `for i ulong 11 bound 10` and the same with `k = ulong 11`
  as the count exit 104 (old: error 5); `for ... bound 0` and `bound 9223372036854775808` are error 8
  (old: error 5); `for i ulong 2000000` without a bound still runs unguarded (exit 81 = 2000000 mod
  89). IR mode: `while ... bound 1000000` compiles (old: error 8), `bound 1000001` is error 8 on both;
  `for i ulong 1000000` compiles, `for i ulong 1000001` is error 8 (old: compiled); `for i ulong 3
  bound 10` compiles and `bound 1000001` is error 8 (old: error 5 for both); `for i ulong k` with
  `k = ulong 3` grows from 162 to 225 bytes of IR (the guard). Wolfram:
  `{Mod[1500000,89], Mod[1100000,89], Mod[1234567,89], Mod[2000000,89]}` -> `{83, 49, 48, 81}`.
- `break` and `continue` (`omc` only, gate7); `continue` in a `while` re-runs the condition and bound.
- Choose N from a proof, not a guess. Example: a read loop where every pass adds at least one byte to
  a 65536-byte buffer needs at most 65536 passes. Write that reasoning in a `note`.
- No loop runs forever and recursion is bounded by the 8 MiB stack. A long-running service needs an
  explicit epoch/restart design, not a bigger bound.

### Compiler limits checked at main `bf54b19fa` (2026-10-29; rechecked at `91c83438d` on 2026-10-31)

Checked with main's `seed/out/omc` (sha256 `62775d2a391cfef7cde64e387655caa9809a267093112910ec76bfa568f3712b`)
and `seed/rung4/om4.bin` (`d0da40e4…19efab`) on the Linux AArch64 host; facts 2, 3, 5 and 6 were also
reproduced with the omega MCP `run` tool (pin `e5b32567`, compiler `2c824805…029f`). Host evidence only.
The first six facts (value slots through x86 target) were rerun on 2026-10-31 with main
`91c83438d`'s omc `2aec185d…d8d5` and with the previous main omc `7a8b84fc…` (#970): the same exit
codes and diagnostics with both. The om4 cap was rechecked as stated in its entry; the 4096 cap on
user programs was not rerun. Float literals longer than about 1000000 characters are a separate,
fixed limit (section 4).

- **Value slots.** `fn alloc` ([omc.om#L2848-L2855](https://github.com/aien-dev/omega-mv/blob/bf54b19fa590e8ae925c0e80815516dbf41e7326/seed/omc/omc.om#L2848-L2855))
  fails error 12 when `npar + nslot >= 16`. There is no spilling: split the function. Fifteen
  `aN = int N` names summed in one nested `add` chain already give `omc: line 17: error 12`.
- **Loop guard.** `for i ulong k` with a name `k = ulong 1000001` compiles and exits 104 (trap 4,
  LOOP_BOUND); `k = ulong 1000000` exits 0. A literal count is unguarded: `for i ulong 2000000` exits 0.
- **Float literal mantissa.** The digits of a float literal, read without the dot, must fit in
  2^63-1 = 9223372036854775807 (Wolfram `2^63-1`). `922337203685477580.7f64` compiles;
  `92233720368547758.08f64` and `9223372036854775807.0f64` are error 8.
- **Forward calls** are allowed: `main` calling `f` defined after it compiles and exits 7.
  **Globals and texts are not:** a `global` or `text` named in a function before its definition line
  is `error 3`. Rechecked 2026-11-06 with the omega MCP pin omc `2c824805…029f` (`e5b32567`, not the section 0 compiler): `fn f` that
  does `put g 0 uchar 7`, then `global g uchar 1`, gives `omc: line 2: error 3`; the same unit with the
  `global` first compiles and exits 7; a `text` written after its first `write` use is also
  `omc: line 2: error 3`; moving the text first compiles, prints `x` and exits 0. When a unit is built by concatenating files (a library such as CUDApp
  `native/nvrm/context.om`, then the code that uses it), each file's globals and texts must sit
  above their first use in the concatenated order; functions may come in any order.
- **Hex.** OM-1 rejects `0x10` with error 6; under `om2` the same unit compiles and exits 16.
- **x86 target.** A first line exactly `target x86linux` emits an x86-64 ELF; with a leading space it
  is error 16.
- **om4 function cap: 512 functions in `omc.om` itself (contributors to the compiler).** Measured at
  main `57a4135d6` on 2026-10-31: `omc.om` has 495 `^fn ` lines (16,432 lines, sha256 `d4b4b89d…30f6`,
  the same file as at `9920aab14`) and `om4.bin` is still `d0da40e4…19efab`. `omc.om` plus 17 appended
  `fn zqN to ulong` / `ret 0` / `end` functions compiled with exit 0; plus 18 gave
  `om4: line 16484: error 14`, exit 14. So 17 entries were free then; at the current pin
  `d3d1b1bc` `omc.om` has 510 `^fn ` lines, so 2 are free (section 0). **Decision (Drake, 2026-10-31): stay
  within 512 for now (option 3).** A prototype that moves om4's table to 4096 entries is draft
  [omega-mv#1013](https://github.com/aien-dev/omega-mv/pull/1013) (`646ed1ec`, om4 `bfc1cfd1…`, omc
  bytes unchanged), **parked until after alpha**: do not merge it unless `omc.om` needs more than 512
  functions or an alpha-critical fix needs more than the free entries. If it merges, the published
  challenge pin moves in the same release as a new version (v1 = om4 `d0da40e4` at `369dbc96` stays
  checkable), `seed/challenge/run.sh` builds the new pin, and never while an outside recheck
  (DRA-58) is running. Its cubic cycle check is omega-mv#1014. Until it merges, the 512 cap below holds. Earlier
  checks: main `62d1d0d66` (2026-10-30), `4376c2112` and `91c83438d` (2026-10-31), when `omc.om` had
  512 functions and one more gave `om4: line 15953: error 14`. om4 is the seed rung that compiles `seed/omc/omc.om` into the first
  `omc` (`seed/omega-from-seed.sh`
  [#L43-L46](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omega-from-seed.sh#L43-L46)).
  Its function table is 128-byte entries at `0x1840000`
  ([om4.s#L45](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/rung4/om4.s#L45)),
  and a new function is refused with `E_FULL` (error 14) once 512 are recorded
  ([om4.s#L768-L769](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/rung4/om4.s#L768-L769),
  `cmp.x.i x10 512` / `b.hs E_FULL`; [#L3073-L3075](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/rung4/om4.s#L3073-L3075)).
  512 entries x 128 bytes fill exactly `0x1840000..0x1850000`, where the state slots begin
  (Wolfram `IntegerString[16^^1840000 + 512*128, 16]` -> `1850000`). At `62d1d0d66` main's `omc.om` had exactly 512
  `^fn ` lines (`main` included), so it was full. Observed there (dated): om4 compiled that `omc.om` with exit 0;
  the same file plus one three-line function gave `om4: line 15625: error 14`, exit 14, and the seed
  chain stops there. Any omc change that adds a function must fold or remove another one (#875 inlines
  `dit`/`scrub` for this reason; its `omc.om` note is at L7525-L7526 in the merge commit `23678743`,
  which still has exactly 512 `^fn ` lines). On 2026-10-30
  a clean `git merge-tree` of main with draft
  [#817](https://github.com/aien-dev/omega-mv/pull/817) (head `d0d794d0`) has 532 functions and with
  draft [#832](https://github.com/aien-dev/omega-mv/pull/832) (head `707faca6`) 526, so both are
  blocked until 20 and 14 functions are folded (Wolfram `{532-512, 526-512}` -> `{20, 14}`) or the cap
  is raised. Raising the om4 cap changes a seed rung and is Drake's decision, not a contributor's.
  Check before every compiler PR: `grep -c '^fn ' seed/omc/omc.om` must print at most 512. To
  measure the headroom, append k three-line functions (`fn zqN to ulong`, `ret 0`, `end`, N unique;
  never `fN`, because `f32`/`f64` are type words) and run `seed/rung4/om4.bin < omc.om > /dev/null`.
- **Do not confuse it with omc's cap on user programs.** The compiled `omc` holds 4096 functions per
  program ([omc.om#L116-L118](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L116-L118),
  refusal [#L7809-L7810](https://github.com/aien-dev/omega-mv/blob/62d1d0d668f897386a0e311374f8dbcc5c32dde8/seed/omc/omc.om#L7809-L7810);
  gated by `seed/omc/gate12.sh`, 4095 helpers plus `main` accepted, 4096 plus `main` error 14). The
  "1024 functions" in omega-harness issue #9 described omc on branch `feat/allen-imac-competition`
  (`7eca2ac3f`, 2026-10-25), not om4 and not current main.
- **IR-mode capacity and nested call arguments: PENDING, not on omega-mv main**
  ([omega-mv#889](https://github.com/aien-dev/omega-mv/pull/889), draft, rechecked 2026-10-30 at head
  `916a082a90e09de4df04cbeb57dadc84939954ec`, committed omc sha256
  `34768ee8f2779347c0cfa49a1b8a82b8d110b14123a7693774d4e1e435c944c6`; harness issue #142). Per that PR's
  OMEGESE diff and gate comment (author-stated, not observed here), main's omc stops an IR-mode (`ir`)
  function at 64 registers, 32 literals, 32 blocks and 256 instructions (error 14), and miscompiles a call
  nested in a later argument of another call: for `ret add2 uint 30 add2 uint 4 uint 5` it passes 4, not
  30, as `add2`'s first argument. #889 raises the
  limits to the OSC IR v1 format's own (480 registers, each distinct literal taking one; 512 blocks; 4096
  instructions; 480 names in scope; 64 open blocks; error 14 beyond) and keeps the earlier arguments.
  Observed with that omc (host only): its `seed/omc/gate-ir.sh` exited 0, with `call_nested_arg` and
  `capacity_100_literals` (100 distinct literals, 40 `if` blocks) byte-identical to the C oracle and
  accepted by checker2, and `capacity_481_literals` error 14. Main's omc `62775d2a…` gives
  `omc: line 36: error 14` for the 100-literal unit and, for `call_nested_arg`, IR bytes that differ from
  the oracle (sha256 prefix `47d5c7b0` against `09f9f859`). Until #889 merges, keep IR-mode functions
  under the old limits and bind a nested call's result to a name before passing it.

## 9. Host I/O: counts, errors, evidence

Base words ([#L476-L486](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L476-L486)): `read fd A off n`,
`write fd A off n`, `pread`/`pwrite fd A off n pos`. Native host words ([#L624-L747](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L624-L747)):
files, directories, clocks, sockets, poll, processes, arguments, environment, random.

**cpufence / cpurelax: merged in [omega-mv#946](https://github.com/aien-dev/omega-mv/pull/946) as `d94617177`; in the current pin `d3d1b1bc` / omc `b4f45121` (since `91c83438`).**
Rechecked 2026-10-31 at omega-mv main `91c83438daec0bdb88bf5c077cae10f3d15d365d` (omc sha256
`2aec185d4ed6d7a6a5779ed656b4e56904742bde5551b02893fb5f73916ad8d5`).
These are operand-free statements. `cpufence` (keyword 199) is a full host CPU barrier, AArch64 `DSB SY`
and x86-64 `MFENCE`. `cpurelax` (200) is a spin-wait hint with no ordering, `YIELD` and `PAUSE`.
Unlike every other host word they compile in function mode too. An operand gives error 5, use as a
value or at top level gives error 16, use as a name gives error 5, after `ret` gives error 17, and IR
mode gives error 16. `seed/host/cpufence.sh` proves this: a fixture that exits 42 natively and under
qemu-x86_64, objdump instruction deltas, and a nop-fence mutant that is caught. These are host results
only. An omc older than `d94617177` (its parent's omc is `62775d2a…`) does not know either word: the
fixture fails with error 4 (a bare `cpufence` line read as a name waiting for `=`) and `cpurelax 1` is
error 11, so check the pin before writing them.
**Keyword ids:** #946 landed with ids 199/200. Draft [omega-mv#878](https://github.com/aien-dev/omega-mv/pull/878)
(`vfioctl`/`vfiomap`, with #890 stacked on it) is still open, PENDING, and must take ids that do not
collide; recheck `fn kw` in `seed/omc/omc.om` at the pin before quoting any id.

**pread/pwrite writability (landed via [omega-mv#904](https://github.com/aien-dev/omega-mv/pull/904), `e2662fff`).**
At omega-mv main `bf54b19f` (omc sha256 `62775d2a391cfef7cde64e387655caa9809a267093112910ec76bfa568f3712b`),
`pwrite` only reads its array, so it accepts a `text` or a `view`; `pread` writes its array, so
`pread` into a `text` or an unsized `view` is error 20, as for `read`. Observed 2026-10-30 on the
AArch64 host with main `seed/out/omc` (`omc < file`): `seed/omc/om2/s4/v-bad-pread-text.om` gives
`omc: line 5: error 20` (rc 20); `seed/omc/om2/s4/v-pwrite-text.om` compiles (rc 0) and runs with
exit 0, writing `ABC\n` to stdout. Host evidence only.

Historical note: up to omc `2c824805…` (omega-mv `e5b32567`, the omega MCP pin before omega-mcp #6) the check sat on
the wrong word: `pwrite` from a `text` was error 20 and `pread` into a `text` compiled and returned
`-EFAULT` at run time. Code written for that pin copied a text into a `new` array before `pwrite`.

**x86efi firmware boundary word `efi`, OP 11 boot-file word (in the pin: omega-mv `d3d1b1bc` / omc `b4f45121…`, merged via [omega-mv#1015](https://github.com/aien-dev/omega-mv/pull/1015); the previous pin `9920aab1` / omc `be8c5130…` refuses `target x86efi` with error 25).**
Read [omega-mv `docs/X86-EFI.md`](https://github.com/aien-dev/omega-mv/blob/main/docs/X86-EFI.md) for the full word. Under `target x86efi` it is `r = efi OP ARG A OFF N`:
OP a literal 0..13 (14 is error 25), `ulong` result, bit 63 set means an error with its code in
the low bits. OPs 0..10: info, key, stall, gop blt, time, rng, recv, tx, net up, pointer, clock;
12 general file, 13 console. OP 11 is the boot-file word of the firmware Allen's self-install
contract (first proposed in draft [omega-mv#981](https://github.com/aien-dev/omega-mv/pull/981)):
`ARG` bits 0..7 = sub-op, bits 8..15 = volume index k. Sub 0 counts the Simple-File-System volumes
and finds the one this image was loaded from, result `count | index << 8`. Sub 1 reads
`\EFI\BOOT\BOOTX64.EFI` from volume k into `A[OFF..OFF+N)` and returns the byte count. Sub 2
writes `A`'s N bytes as that file (the merged code deletes it first, unlike #981's "must already
exist") and returns the bytes written. File and root handles close on every path (source notes
above `fn xefile` in `seed/omc/omc.om` at `d3d1b1bc`; quote error codes from that source, not from #981).
omega-mv's own table marks OP 11 "shipped, NOT_RUN" at `d3d1b1bc` (only OPs 12 and 13 are
EXERCISED, EMULATED under QEMU q35 + OVMF); physical hardware NOT_RUN. Observed 2026-11-04 with
the pinned omc `b4f45121…`: `efi 11 0 a 0 0` under `target x86efi` compiles (exit 0, `MZ` image) and the
same unit with `efi 14` is `omc: line 4: error 25`; the previous pin's omc `be8c5130…` gives `line 1: error 25`.

**`peername`: bounded peer address of an existing descriptor** (merged in
[omega-mv#918](https://github.com/aien-dev/omega-mv/pull/918) as `2d848d939`, committed omc
`38748442…`; in the current pin `d3d1b1bc` / omc `b4f45121`, since `3a163bc5` / omc `24caacf4`). `peername fd A off n` is host word 224,
program mode only. It writes the connected peer's address into `A[off, off+n)` through AArch64
`getpeername` 205 (not `getsockname` 204) or x86-64 `getpeername` 52 (not 51), with the same slice and
private 32-bit length convention as `sockname`. Zero capacity is allowed, at the array end too, and
returns the full length. The result is the full address length (above `n` means truncated) or a
negative errno. An invalid slice traps 3; a read-only buffer (a view or text) is error 20. It creates
and connects no descriptor; the caller owns the descriptor's lifetime. The peer is the transport
endpoint, not an authenticated user; forwarding headers gain no authority from it. Observed
2026-10-31 (host only) with `seed/host/tests/peername.om` at `3a163bc5e`: omc `24caacf4…` compiles it
and the run prints `PASS native peername: accepted peer, truncation, empty slices, errno and bounds`,
exit 0; its mutant arguments 1, 2 and 3 each exit 103; prefixed with `target x86linux` it gives the
same PASS line and exits under `qemu-x86_64` 8.2.2 (EMULATED, not native x86). The earlier pin
`2aec185d…` gives `omc: line 24: error 3` for that file, and compiles `peername = int 1` as a name
(at `24caacf4` that is `omc: line 2: error 16`). Rerun 2026-10-31 at `9920aab14` with omc
`be8c5130…` (host only): the same PASS line with exit 0, mutant arguments 1, 2 and 3 each exit 103,
the `target x86linux` build gives the same PASS line with exit 0 under `qemu-x86_64` 8.2.2 (EMULATED),
and `peername = int 1` as a one-line unit is `omc: line 1: error 16`. This supersedes the pending
candidate notes of harness draft #108 (candidate omc `4ef67f18`/`6a2916cd`).

**`execpure` and descriptor closing in `execprog`** (merged in
[omega-mv#970](https://github.com/aien-dev/omega-mv/pull/970) as `1db941627`; in the current pin
`d3d1b1bc` / omc `b4f45121`; observed below with the then pin `91c83438` / omc `2aec185d`). `execpure A off n` is host word 198
(AArch64 only; `target x86linux` is error 25): it decodes the packet as `execprog` does, pins the
executable as descriptor 3, applies a fixed strict stdio profile (Landlock execute/read beneath that file,
no-new-privs, seven `prlimit64` ceilings, a seccomp filter allowing only `read` on 0, `write` on 1 and 2,
`exit`, `exit_group` and `execveat` on 3) and calls `execveat(AT_EMPTY_PATH)`. It returns only on failure,
with the first failing step's negative errno, and has no weaker fallback. `execprog` also changes: it now
closes every descriptor at or above 3 with `close_range(3, UINT_MAX, CLOSE_RANGE_UNSHARE)` before exec,
so a child no longer inherits them. Observed 2026-10-31 with omc `2aec185d` (host only): the
`seed/qualification/security673/pure-launch.om` fixture launching a static omc program that exits 7 gave
exit 7; launching `/nonexistent/x` printed `PURE_LAUNCH_REFUSED` and exited 2 (ENOENT); a child that reads
descriptor 3 got EPERM (exit 1) under `execpure`, and EBADF (exit 9) under `execprog` with the parent's
descriptor 3 open. The omc of `1db941627^` (`0243e4aff`, sha256 `1578b357…`) refuses `execpure` with
error 3, and its `execprog` child read the inherited descriptor 3 (exit 50). Older pins, including the
omega MCP pin before omega-mcp #6 (`2c824805…`), lack both; the current MCP pin `3ad9f10f…` has both.

- Types: `fd`, flags, modes, pids are `int`; offsets, counts, capacities `ulong`; file positions and
  intervals `long`; buffers are `uchar` arrays. Every result is `long`.
- A result is a **count or minus the Linux errno**. `read` may return fewer bytes than asked, 0 at
  end of input, or a negative error; `write` may write fewer bytes. Loop until done, and handle
  `k < 0` and `k == 0` separately. Do not copy `seed/rung4/tests/bytecopy.om`'s loop as error
  handling: it ends silently on a negative result.
- Slices are checked before the kernel call: `n <= len A` and `off <= len A - n`, else trap 3. `off`
  does not wrap (`t_write_wrap.om`).
- Count conventions differ per word and are part of the contract: `cwd` includes the trailing zero;
  `readlnk` has none and a result equal to capacity may be truncated; `sockname` may return more
  than capacity; `argread`/`envread` return -105 on short capacity without touching the buffer.
- `send` adds `MSG_NOSIGNAL`; `write` does not, so writing to a closed pipe follows ordinary Linux
  SIGPIPE behaviour [INFERENCE from Linux semantics; not gated here].
- These words carry the process's permissions; they are not a sandbox. Linux ARM64 is the only
  qualified host ([#L739-L743](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L739-L743)).
- Merged: `seed/effects` ([omega-mv #820](https://github.com/aien-dev/omega-mv/pull/820), train r1,
  main squash `f56a372a`, 2026-10-30) lists the host words a unit uses with their Linux syscalls,
  checks that the omc binary issues no others, and emits a seccomp filter for `bwrap --seccomp`
  (`effects src|elf|verify|bpf|table`, `seed/effects/README.md`). It works at syscall granularity
  only and gives no filesystem isolation. **Its own qualification fails at current main:** observed
  2026-11-04 at main `d3d1b1bc` (omc `b4f45121…`) and at `19b8340d` (omc `be8c5130…`),
  `sh seed/effects/check.sh` printed `SEMANTIC EFFECTS FAIL failed=3 checks=49`, exit 1: the closure
  check found the host-coded keywords of `seed/omc/genkw.awk` and the effects table different (the
  table lacks `execpure`, added by #970, and lists `peercred`, `pollfds` and `sendmsg`, which the
  closure list does not have), `execprog`'s ELF issues syscall 436 beyond its table row 221, and
  `seed/host/tests/memcheck.om`, `process.om` and `peername.om` fail `verify`. Until that check
  passes again, an `effects` manifest is not evidence that a unit's syscall set is complete.
  PENDING fix, not merged: [omega-mv #1023](https://github.com/aien-dev/omega-mv/pull/1023) (head
  `eb7b3c60`, open) makes the closure read every keyword list of `genkw.awk` by content, adds rows
  `peername net 205`, `execprog proc 221 436` and an `execpure` row, and lets a table row hold any
  number of syscalls (a pool replacing the fixed two slots `ws1`/`ws2`). Observed 2026-11-04 at
  that head (its `seed/out/omc` `b4f45121…`): `sh seed/effects/check.sh` printed
  `SEMANTIC EFFECTS PASS checks=50`, exit 0, with the tool mutants still killed.
- Evidence for any host claim: compiler sha256, source sha256, output binary sha256, exact command,
  exit status, and the observed bytes. A program that ignores a negative result is not evidence.
- Measured 2026-10-25 while building a disk image with the seed compiler `seed/out/omc` sha256
  `c99eda2465036c0637a444689a65dd7fc736e4fa8a8b4cf3456b0ce1b57f8996` (omega branch
  `feat/allen-imac-competition` `c3fb79697`, off main `55f9b0af`). Except where noted, these are NOT
  re-measured at the current pin (omc `2c824805…`). The failures that cost the most wasted compiles:
  - `fopen` returns `long`, but `read`, `write`, `fclose`, `fsync`, `fseek`, `ftrunc` and `fchmod`
    take `fd` as `int`: `read int fi A 0 n`. `fseek`'s offset and `ftrunc`'s length are `long`, so a
    `ulong` constant must be converted explicitly (`ftrunc int fo long IMGLN`); a plain `ulong`
    value there is error 7, not a quiet narrowing.
  - There are no implicit conversions in any argument position: mixing a `ulong` value with a
    `uchar` array element (`xor c get A i`) is error 7 until you write `xor c ulong get A i`
    (reproduced at omc `2c824805…`: `d = xor c get A 0` is error 7, `xor c ulong get A 0` compiles).
  - Host words and `global` need program mode: without `fn main` the unit compiles in function mode
    and every host word is error 9 with an empty output file, which reads like a broken pin. (Pending
    exception for nine file/identity words in OM-2 units: section 2, omega-mv#1008. Observed
    2026-11-04: `om2` / `export fn f to long` / `r = geteuid` gives `omc: line 3: error 9` with
    omc `be8c5130…` and `b4f45121…`, and compiles with the #1008 omc `c000ec02…` at `2992a68b`.)
- **Owned DMA-window integration: PENDING, not the main compiler or a kernel driver.**
  Depends on the VFIO words described below ("VFIO device words", added by
  [guide #79](https://github.com/aien-dev/omega-harness/pull/79), merged `d3d6738`; the words stay PENDING), compiler
  [omega-mv#890](https://github.com/aien-dev/omega-mv/pull/890) stacked on #878, exact source
  `397e67040fb74853c6814097fe02ae4e1ebd6f66`, omc sha256
  `bcfa582892afca8f65e551fe56867d918d86e84540c7381be8fa9ef18d0cf0f6`.
  Driver source
  [`c69470f5`](https://github.com/aien-dev/omega-gpu-driver/blob/c69470f5fac6fe603a45b2c4af0c79eea3409ec6/chan/gmmu.om)
  distinguishes simulator `mmwinit` (`mmwin`) from `mmwalloc` (owned shared anonymous handle).
  CPU accesses use handle+offset; IOVA, informational CPU base and GPU VA remain separate.
  `mmwdmap(epoch, fd)` maps the whole owned extent; `mmwpublish(epoch)` must precede any externally
  visible DMA reference. Epoch/handle/length/IOVA/container identity stays fixed for that lifetime.
  Rebuild MAP_DMA requests after every call: the compiler overwrites vaddr even on ioctl error.
  An unpublished DMA-mapped extent closes only after UNMAP_DMA returns its exact original length,
  then successful `mapdrop`; a never-mapped OWN extent drops directly. Only EBADF is proven no-target;
  uncertain mapping errors,
  failed/partial/unexpected unmaps and drop failures retain backing. Published or quarantined backing
  cannot be reset/reused/dropped: TLB invalidation or a simulator idle is not a documented DMA-idle
  proof, and no GB10 reclaim-proof API exists here. The single owner must retain process/container
  lifetime (no fork, fd close/reuse or restart); the latch is process-local, not crash-safe containment.
  `tests/dma_host.sh`: EXERCISED anonymous memory, real invalid-fd refusal/retry, 23 explicit host
  replay/boundary cases and 11 compiling negative-control mutants. Simulator parity remains 391
  byte-identical C-reference lines. This is Linux userspace VFIO, not a Linux kernel module;
  hardware/DMA/kernel execution NOT_RUN. It neither opens a VFIO device nor grants authorization.
- **VFIO device words: PENDING, not on `main`.** Draft
  [omega-mv#878](https://github.com/aien-dev/omega-mv/pull/878), rechecked 2026-10-30 at head
  `019108d5cbaae12bdad818741b6a97ac8572501b` (committed omc sha256
  `d5d7d1029bf1b7011570d346e320bc793a0f3ee3c227033f7f8d2bbc292c4054`, self-rebuild byte-identical), adds
  keyword ids 178/179 ([MAPPING.md#L18-L19](https://github.com/aien-dev/omega-mv/blob/019108d5cbaae12bdad818741b6a97ac8572501b/seed/host/MAPPING.md#L18-L19),
  allowlist [#L66](https://github.com/aien-dev/omega-mv/blob/019108d5cbaae12bdad818741b6a97ac8572501b/seed/host/MAPPING.md#L66)):
  `vfioctl fd req A off n -> long` takes only a **literal** request from the allowlist at its exact
  `n` (GET_API_VERSION 15204/0, CHECK_EXTENSION 15205/4, SET_IOMMU 15206/4 value 3 only,
  GROUP_GET_STATUS 15207/8, GROUP_SET_CONTAINER 15208/4, GROUP_GET_DEVICE_FD 15210 nonempty name
  without zero bytes, DEVICE_GET_INFO 15211/24, DEVICE_GET_REGION_INFO 15212/32), writes
  `argsz = n` when `n >= 8`, returns the result or -errno. A non-literal or unlisted request
  (including DEVICE_RESET 15215) is compile error 9; wrong sizes or values trap 103 at run time.
  Both words are AArch64 only: under `target x86linux` either one is error 25
  ([#L85-L86](https://github.com/aien-dev/omega-mv/blob/019108d5cbaae12bdad818741b6a97ac8572501b/seed/host/MAPPING.md#L85-L86)).
  Observed with that omc on Linux AArch64: `r = vfioctl neg int 1 uint 15207 a 0 8` returned -9
  (EBADF, run exit 0 in a program checking it); `uint 15215` and a request held in a name are
  error 9; a count held in a name compiled and trapped 103 at run time; the x86 form is error 25;
  the PR's `seed/host/tests/vfio.om` exits 0 and `vfiocheck.om` prints
  `PASS 15 VFIO compiler refusals`. Main's omc `62775d2a…` does not know the words (error 3); nor
  does the guide-pin omc `be8c5130…` or main `d3d1b1bc7`'s omc `b4f45121…` (rechecked 2026-11-04:
  `r = vfioctl neg int 1 uint 15207 a 0 8` is `omc: line 3: error 3` on both).
  Not calling DEVICE_RESET does not avoid a reset: Linux vfio-pci FLRs on device open when a reset
  method is enabled and calls `pci_reset_bus` (SBR) on release even with `reset_method` empty.
  `vfiomap fd A off 32 -> handle` maps one `vfio_region_info` read-only and shared, exactly its size
  at its offset; flags must include READ and MMAP. Read with `mapget`, release with `mapdrop`;
  `mapset` through it traps. Exercised on host fixtures and in QEMU against real `vfio-pci`
  ([omega-gpu-driver qemu/w0-edu.log](https://github.com/aien-dev/omega-gpu-driver/blob/main/qemu/w0-edu.log)); not qualified on GB10.
- **Keyword-id conflict, PENDING:** [omega-mv#946](https://github.com/aien-dev/omega-mv/pull/946)
  (`cpufence`/`cpurelax`) merged as `d9461717` (2026-10-31) with ids 199/200, so it no longer
  collides. Main `d3d1b1bc7` (#1015, 2026-11-04 recheck) now returns 178 for `efi`, a keyword only
  under `target x86efi` (`fn kw` in `seed/omc/omc.om`), while #878 (head `019108d5`, open draft,
  conflicting with main) still returns 178/179 for `vfioctl`/`vfiomap`. #878 must renumber and
  reseed when it is brought up to main, so the ids above can still change; recheck `fn kw` at the
  merge commit before quoting them.
- **VFIO DMA and writable BAR: PENDING, stacked on #878.** Draft
  [omega-mv#890](https://github.com/aien-dev/omega-mv/pull/890) (base branch `feat/vfio-device-calls`;
  rechecked 2026-10-30 at head `f850c52622577eedcb65af3e1af09ab568101e7a`, which contains #878's head;
  committed omc sha256 `fe6e986596f5d22fcfce2bd66006608f49a8f9a28c555066569350aedd3c408b`, self-rebuild byte-identical) adds keyword id 180
  `vfiomapw fd A off 32 -> handle`: as `vfiomap`, but the
  region flags must include READ, WRITE and MMAP and the map is shared read/write, so `mapget`/`mapset`
  drive registers (one aligned access each, DSB SY on both sides)
  ([MAPPING.md#L20](https://github.com/aien-dev/omega-mv/blob/f850c52622577eedcb65af3e1af09ab568101e7a/seed/host/MAPPING.md#L20)).
  It also allows IOMMU_MAP_DMA 15217/32 and IOMMU_UNMAP_DMA 15218/24 in `vfioctl`
  ([#L84-L99](https://github.com/aien-dev/omega-mv/blob/f850c52622577eedcb65af3e1af09ab568101e7a/seed/host/MAPPING.md#L84-L99)):
  Omega code never supplies an address. Write a mapping handle into bytes 8..15 and the IOVA into
  16..23; the compiler checks the handle like `mapget`, requires a read/write mapping and flags exactly
  3, then stores the mapping's own base and whole length; any failed check traps 3 (exit 103).
  UNMAP_DMA requires flags 0. Unmap before `mapdrop`: a dropped mapping that is still DMA-mapped
  stays pinned until the container closes. All three VFIO words are error 25 under `target x86linux`
  ([#L104-L105](https://github.com/aien-dev/omega-mv/blob/f850c52622577eedcb65af3e1af09ab568101e7a/seed/host/MAPPING.md#L104-L105)).
  Observed with that omc: MAP_DMA on a zeroed span (no live handle) trapped 103; UNMAP_DMA on fd -1
  returned -9; `vfiomapw` under x86 is error 25; the PR's `vfio.om` exits 0 and `vfiocheck.om` prints
  `PASS 19 VFIO compiler refusals`. #878's omc refuses 15217 (error 9) and does not know `vfiomapw`
  (error 3). Exercised on host fixtures only.

## 9a. GPU kernels written in `.om` (GB10 sm_121, raw driver)

Observed 2026-11-02 to 2026-11-04 while building the Omega LLM GPU training path in aien-dev/aien-train
[#56](https://github.com/aien-dev/aien-train/pull/56) (head `4e0039070cce87802654a74b869288159ce94f5d`;
merged `e186ea29`): rungs 4 and 5 at `d6ff5f5`, `geval` and the
Kahan CE sum at `154fd8c`, kernel round k1 (one-warp softmax, split-K weight gradients, `gprof`) at
`ed2e1925d7a838995582131196b60cbfda1b666b`, k2 (64×64 GEMM tile) at
`ea0f078ed8bec21f9a50cccaf85a7cba11bc3a34`, k3 (warp-per-row RMS norm) at
`1d241c38d213c8921d24ab970c7260aaf93c5a36`, k4 (warp-per-row cross-entropy) at
`9a5225a4bbc4df0ee19d4cc416ebe72db5c518b0`, k5 (causal attention GEMMs) at
`f84a657246e80686302f534017540fee68e85171`, k6 (causal predicated softmax loads and stores) at
`8dff0ba1d249583c1a9f00e6f47b2dc3d80c3c9a` (evidence crumb `af29657423dc548a40a9e685484cf95a1ccc0e7e`,
README fix `099fa9e68e94516404486c2c3ef27956149e249b`), k7 (FFMA operand reuse plus an accumulator
remap) at `d3d4551d2c3726e3927c9cf0a95b8091e11919f7`, k7b (remap removed) at
`574e78afaa80976538c8f08cf1a2ddbf8e5a36c2`, k8 (pipelined 64×64 GEMM, per-kernel shared-memory
TARGET, GPR guard) at `c05b89f7e08ea8d2c3717a500fc3e17af8e30a9d`, k9 (ReLU fused into the FFN GEMM
epilogues) at `1575dc866bb556c8b6b605044e5bd43d17c3f2a0`, rung 6 (30000 steps, evidence
`0d744749465cf31c5220ac0eaad26462a993b0e4`); rung 7 (v2 shape D 384, F 1536, #57, head
`43f374a6042769a3d853d9b953dbe4d86348b01b`) at
`b312942460bc81ef590a92fde8f23a298e119916` (files `native/omegallm/gpu/gk.om`,
`gr.om`, `gg.om`), the BF16 path (#58, head `cb556468380944f4aa1a9a5da389f4ad193f4154`) at
`a82fc1a11f01031162fd305e9ce6158afb760eb6` (adds `gb.om`), rung 8 (60000-step schedule, #59, head
`7baaf8b4bda00a4394f1f094aece5ce7b3b6ed5c`, evidence only) at
`2d19e6fec5b12930e17d6ad6ddbb038263732c5b`, v3 (L ≤ 16, banked storage, #60, head
`b92c96b627f33beadd69dc2d8f70833e973a377f`), rung 9 (first long BF16 run, #61, head
`fcf6cdedec3024806a82f40e977c1d1389d684a4`, evidence only) at
`687bbcb82aa0bf03e9d3fa71447ce544909f642c`, and rung 10 (BF16 on the 60000-step schedule, #62, head
`3ed47a0503f15cdff38ad911eeddb13cf13b4c32`, evidence only) at
`6929722a36023f0c807d8b05945e845bbe88534e`; every cited commit is an ancestor of its PR head. All
merged on aien-train main (checked with `gh pr view` 2026-11-04): #56 `e186ea29`, #57 `16e9932e`,
#58 `4461e3fa`, #59 `24d21497`, #60 `a9c720db`, #61 `930ae21c`, #62 `56cc8870` (main head). The
best trained model is rung 10's BF16 v2 checkpoint (P 15,833,472, T 256, held-out `E 60000 2243
1204466`). The Omega LLM is the planned model for `:18091` (Linear P-DRA-7), not served yet: its
only inference path is the CPU command `ollm sample`, and no HTTP server exists. Compiled with omc `2c824805…` (omega-mv
`e5b32567`). The device words come from the vendored CUDApp `context.om`/`vector.om`/`launch.om`
(`dcba8bb8`). Status EXERCISED on one GB10, non-quiet windows; not QUALIFIED. These are pin-specific
facts, not rules of the language.

- The kernels are instruction words that the program emits itself: `.om` code writes 16-byte SASS
  words into a code slot, then launches them through a QMD. Verify every new instruction encoding
  with nvdisasm (CUDA 13.0, `nvdisasm -b SM121`) as a read-only oracle. A slot dumped whole ends in
  zero bytes that disassemble as illegal instructions. Trim trailing zero bytes to a 16-byte
  multiple first (`tests/omegallm/gpu-disasm.sh`).
- `LDC.64` loads a 64-bit constant-bank value and needs an 8-byte aligned offset. A pointer
  argument must start at an even 32-bit argument slot (`gr.om` `grptr`: pointer i sits in slots
  i+1, i+2), with the argument area laid out so slot pairs start 8-byte aligned.
- Allocate GPU-uncached any memory that the CPU writes or polls (pushbuffer, constant bank, QMD,
  completion marks, code). When cached, a release sat in L2 for about 1.06 s (recorded in the
  `gk.om` note at lines 1023-1026 at `1575dc8`, the 1.06 s on line 1024). The data arena can stay
  cached, provided the host invalidates it after host writes and every launch ends with
  `L2_FLUSH_DIRTY` before the CPU reads results.
- Output buffered in the program (`oputu`/`oputc`, flushed by `oflush` in aien-train `lio.om`)
  is lost on `exit` or `trap` unless it is flushed first. Call `oflush` before every diagnostic
  `exit N` (`gg.om` `ggdie`), or the failure prints nothing.
- Host loops over parameter-sized arrays need chunking. A `for` with a computed bound gets the
  1000000-pass guard (section 8), and P = 7409920 parameters exceed it (trap 4, exit 104). Loop over
  chunks of at most 999999 elements (`gg.om` `ggupc`, `OCH`).
- Host glue around launches needs many values at once (pointer halves, grid sizes, argument
  counts), and each live name takes a register from the 16-register pool (section 6). Pass launch
  arguments through a small global (`gkarg`) and split pointers in a helper (`ggpt`), so callers
  stay inside the pool.
- For f32 Adam on chip, use `sqrt(v) + eps` followed by a reciprocal (`MUFU.SQRT`, then `MUFU.RCP`,
  `gr.om` `gradam`). Avoid `v · rsqrt(v)`, because v = 0 occurs for parameters with zero gradient
  and 0 · inf is NaN.
- Gate f32 chip numerics against the f64 CPU reference with a tolerance derived from the summation
  length, not a fixed constant. The gradient gate uses relative error < R·2^-24 for a reduction
  over R rows. A fixed tolerance of 1e-4 failed at 1.61e-4 on the night shape. The maximum came
  from ReLU units whose pre-activation lies within f32 resolution of zero. Both sides are valid
  subgradients, and forcing the CPU onto the chip's side gave 7.1e-5 (aien-train
  `evidence/OMEGALLM/gpu/README.md`, `probe/`). Never loosen the gate to make it pass; explain the
  maximum.
- A mutant must be able to change the observed value. A wrong Adam β1 is invisible on a step-0
  checkpoint, because m = 0. Run the Adam gate's negative control on a trained checkpoint
  (mutant h fails at step 1000, resid 0.114 against 2^-16).
- A long f32 sum in one register is biased, not just noisy. The CE kernel summed exp(l − m) over
  V = 4096 logits sequentially; once the running sum is large, terms below half its ulp vanish, so
  log Σ came out ~1.04e-5 low on every row and the chip's held-out loss missed the f64 CPU's by
  11 µnats on a 10 µnat gate. Find such a bias by comparing per-row intermediates against the CPU,
  not the final loss (`gg.om` `ggdiag`: max logit and l_y agreed to ~3e-7, log Σ did not). The fix
  is a compensated (Kahan) sum (`gr.om` `grce`, `OMUTK`), after which the chip printed the CPU's
  E line exactly (aien-train `evidence/OMEGALLM/geval/`). There the plain sum (`--mutant k`) failed
  the gate by 11 µnats. Since k4 each lane sums only V/32 = 128 terms before the warp tree, and the
  plain per-lane sum moves `geval` by at most 1 µnat (`gpu-k4/`): a mutant whose effect falls below
  the gate is an observation, not a control. Replace it with one the gate can see.
- A kernel launched with `gkgpr` G may use R0 to R(G−3) only. On Volta and later two registers of the
  QMD count go to the program counter (Mesa `0b6d3f401e2b2e53be44786692f12e31055b749c`, main
  2026-11-04: NAK `src/nouveau/compiler/nak/sm70.rs:101` `hw_reserved_gprs`; `api.rs:275` sets the
  count to `max(4, num_gprs + 2)`). Two hangs fit that rule: Kahan
  state in R69-R71 under `put gkgpr id 72` (`gr.om` `grall`) timed out every launch (`GX 121 -110`,
  exit 84) while R40-R42 ran (`evidence/OMEGALLM/geval/a1/`), and k8's 64×64 GEMM using R158 under
  160 did the same (`GX 99 -110`, `gpu-k8/a1/`); 168 runs. `tests/omegallm/gpu-disasm.sh` now prints
  `GPR <id> max R<n> need <n+3> declared <g> OK|LOW` per slot from the dump's `gkgpr` table and exits
  4 (`GPR_LOW`) on any LOW; its negative control is the 160 tree (`gpu-k8/disasm-neg-gpr160.txt`).
- Every ordered comparison with NaN is false in the pinned omc (0/0 takes neither `gt n 1.0`,
  `lt n 1.0` nor `gt 1.0 n`), so a running max `if gt d best` silently skips NaN. Count non-finite
  values separately and fail on any (`gg.om` gcmp2).
- ReLU sign flips grow with the shape: at P 7.4M the fixed-mask gradient gate failed at 1.58e-4 from
  4 units whose pre-activation was within 2.4e-7 of zero. The rung-5 gate (`gcmp2`) bounds the
  chip's pre-activations first, then compares gradients on the chip's branches (aien-train
  `evidence/OMEGALLM/gpu-max/README.md`). A pass of one gate is not a pass of the other.
- `ollm eval CK HELD W` needs W·T + 1 ≤ N held tokens and exits 23 otherwise (`cli.om` `cmdeval`):
  doubling T from 128 to 256 halves the usable W (4486 → 2243 on the v1 held set). On rung 6's
  `ck30000` the CPU `eval` (5519 s on one core, nice 19) and the chip `geval` (about 7 s) printed the
  same line, `E 30000 2243 1338156 499194` (aien-train `evidence/OMEGALLM/gpu-r6/`).
- Profile before tuning. `ollm-gb10 gprof` (k1) prints one `GP id gx gy gz m n k wait_ns` line per
  launch of the last profiled step. With every launch synchronous, GPU wait was 91.6% of the 200-step
  wall at k2 (`evidence/OMEGALLM/gpu-k2/`), so per-kernel wait, not launch preparation, names the
  next kernel to fix. A batching variant (one wait per group of launches) could save at most 0.69%
  of the measured step and was dropped.
- A retile that keeps every output element's FFMA order over k gives a result that is
  bit-identical, not just within tolerance. The k2 64×64 tile (`gk.om` ids 32-39, `gktile` picks it
  when m and n are multiples of 64, ids 0-7 stay for the rest) left the checkpoint after 200
  `gtrainf` steps byte-equal to k1's (sha256 `fde1fae9…`). Use that equality as a check in
  addition to the f32 gates. Its budget: 64 threads, an 8×8 microtile each, K8, 144 GPRs and 4352 B
  of shared memory (`put gkgpr id 144`, `put gksm id 4352`).
- A row kernel with one thread per row reads its row at a stride of 4·D bytes across the warp, so
  each warp load touches 32 lines. k3 runs `gr.om` RMS norm (ids 10, 11) one warp per row: lane l
  holds columns l + 32u in registers, loads and stores are coalesced 128-byte lines, each input is
  read once, and the row sum is a per-lane FFMA chain plus a 16-8-4-2-1 `SHFL.BFLY` butterfly
  (`grwred`). Launch R·32 threads (`gg.om` `ggrmsf`), and refuse D or T not a multiple of 32
  (`grall`). Forward 2.50× and backward 2.47× faster per profiled step, 237.6 and 215.8 GB/s of
  required traffic (aien-train `evidence/OMEGALLM/gpu-k3/`). The sum order changes, so the result is
  within the f32 gates but not bit-identical to the thread-per-row kernel.
- The same layout serves the CE kernel (k4, `gr.om` `grce`, id 21, one warp per row over V 4096):
  warp max, per-lane Kahan sum of e without storing it, warp sum, then a third pass recomputes e
  with the same FFMA and `MUFU.EX2` (the same value), scales and stores it, so the logit matrix is
  read 3 times and written once instead of 3 + 2. The lane that stored L[y] (y & 31) alone applies
  L[y] − sc and writes the row stats, so no lane reads another lane's store. 13.51 → 3.68 ms per
  profiled step (3.68×, 99 → 292 GB/s of required traffic); `grall` refuses V not a multiple of 256.
- `grwred` uses R65 as its shuffle scratch register (and R64 for the value). A value parked in R65
  across a butterfly is overwritten; k3's backward kernel keeps s in R67 for that reason, and k4's
  first CE build read R65 as −m·log2e after the warp sum. The slot-21 disassembly showed it before any
  chip run; the fix keeps m in R43 and recomputes R65 = R43·R29. Check a helper's scratch registers
  before giving a live value a register near the reduction.
- Skip causal work with runtime argument words, not new kernel ids (k5, `gk.om` words 22, 26, 27,
  28; `gg.om` `ggbh` sets the mode with `gkopz`, and `gkmm` reads and clears it, so an unmarked
  GEMM stays dense). The GEMM prologue exits a block whose column tile is above row tile + X (S and
  DP: X = 0), and reads kn = r·ka + base K tiles from tile r·kc (P·U and DS·K: ka = pt; Pᵀ·DO and
  DSᵀ·Q: ka = −pt, kc = pt). `gkczok` refuses a shape the mode does not fit (nverr −22). Every
  skipped FFMA term is ±0 and a +0 accumulator stays +0 under round-to-nearest, so the checkpoint
  after 200 steps stayed byte-equal to k4's. The three attention GEMMs ran 1.35×, 1.52× and 1.42×
  faster per profiled step, and 200 steps 1.059× faster (aien-train `evidence/OMEGALLM/gpu-k5/`).
  Skipped output tiles are no longer written and keep stale arena data, so every consumer must mask
  them rather than multiply by zero: p · (stale NaN) is NaN even when p = 0. `grsoftb` (id 16)
  `FSEL`s dp to 0 for columns > t.
- A bandwidth-bound row kernel gets faster only by moving fewer bytes: skip the causal upper triangle
  with predicated `LDG`/`STG` (k6, `gr.om` `grsoftf`/`grsoftb`, ids 15/16). `gk.om` `gkldgp`/`gkstgp`
  put the guard predicate in word 0 bits 12-15 (p 7 = PT, +8 negates; `gkldg`/`gkstg` are these with
  p 7). Set the load predicates (t ≥ 32u) with `ISETP` before the first load: an `ISETP` placed
  between loads waits on their scoreboard. Recompute them before the stores if a mask loop reused a
  predicate. Store only what a consumer reads (here chunk pairs with t ≥ 64·⌊u/2⌋, the end of the
  diagonal tile), and `FSEL` every unloaded register before arithmetic (−∞ in softf, +0 in softb),
  so the checkpoint after 200 steps stayed byte-equal to k5's. Softmax 1.639× and 1.676× faster per
  profiled step at about the same GB/s, 200 steps 1.053× (aien-train `evidence/OMEGALLM/gpu-k6/`).
- Check a new predicate encoder in the disassembly at a shape that uses it. `gk.om` `gkisge` wrote its
  destination predicate at word 0 bit 16; `ISETP`'s field is word 2 bit 17 (as in `gkisetp`), so every
  `gkisge` wrote P0. It went unseen because every caller asked for P0 and the parity shape (T = 32,
  one chunk) emits no predicates; the first max-shape dump showed seven `ISETP`s all writing P0.
- Mark FFMA operand reuse in the instruction word; nothing sets it for you (k7, `gk.om` `gkffma`'s
  reuse mask `ru`, control word 3 bits 26-28: Ra 1, Rb 2, Rc 4). `gkru` sets Ra reuse on every FFMA
  of a row run that reads the same a register except the last, which releases it; in a 64×64 slot
  that is 448 of the 512 k-loop FFMAs. Set control bit 109 (word 3 bit 13) with every nonzero mask:
  nvdisasm 13.0 prints `.reuse` only when bit 109 is also set, and ptxas 13.0 `-arch sm_121` sets it on
  every `.reuse` instruction of a probe kernel. What bit 109 does alone is unknown, so attribute
  results to the pair. Switch `OKREU` (`build.sh --variant r0` builds it off, byte-equal to k6's
  code). The checkpoint after 200 steps stayed byte-equal; the GEMMs' profiled wait fell to 0.955× of
  k6's over three rotated rounds and 200 steps ran 1.0457× faster (aien-train
  `evidence/OMEGALLM/gpu-k7b/`). A Volta-style register-bank remap (accumulator column j xor 1, off
  the b registers' low two bits) gave no measured gain on sm_121: remap-only 0.989× of k6, inside
  the k6 spread (`gpu-k7/`). k7b removed it, and 200 steps stayed equal to k7 (1.0003). Measure a
  bank model before coding to it; sm_121's is unpublished.
- Size the shared-memory carveout per kernel in QMD word 36, or a kernel that uses more shared
  memory loses blocks per SM. Word 36 holds `SHARED_MEMORY_SIZE_SHIFTED7` and the MIN, MAX and TARGET
  SM configs at bits 11, 17 and 23 (hw value = KiB / 4 + 1 over the GB10 carveouts 0, 8, 16, 32, 64 and
  100 KiB, Mesa `0b6d3f40` `src/nouveau/winsys/nouveau_device.c:218-231`). `gk.om` used a fixed
  TARGET of 32 KiB.
  `gksmw` now picks the smallest carveout holding smem × ⌊65536 / (`gkgpr` · `gkthr`)⌋ bytes, as Mesa
  NAK `qmd.rs` `gv100_get_hw_smem_sizes` does from its own residency bound. k8 double-buffered the
  64×64 GEMM's K loop (ids 40, 42, …, 54, two 16 KiB slots each, 2 × 4352 B shared, staging in
  R142-R157, one barrier per K tile). Under the fixed TARGET it was bit-identical but its GEMM wait
  1.12× k7b's (6 blocks × 8704 B do not fit in 32 KiB). Under `gksmw` its 64×64 wait was 0.913× of k7b's
  kernel under the same rule (max below min in all three rotated rounds), GEMM wait 0.914× and 200
  steps 0.969× of k7b's wall, checkpoint byte-equal (aien-train `evidence/OMEGALLM/gpu-k8/`). The
  carveout the hardware chose was not read back, so the cause is inferred from the reversal. In the
  same window k7b's own kernel with an identical QMD (arm C against B) ran 0.982× of B in every
  round: identical code spreads about 2% in a non-quiet window, so a gain must clear that.
- Fuse an elementwise kernel into the GEMM that produces or consumes the same tensor through an
  epilogue the caller arms per launch, and make the GEMM refuse every combination the epilogue was
  not written for. k9 removed `gr.om` RELUF/RELUB (ids 17/18): `gkope 1 y` makes the next `gkmm`
  with operand modes ma 1 mb 0 (W1 forward) store FP and also relu(FP) to y (ids 25 for the 32×32
  tile, 56 for the 64×64); `gkope 2 FP` makes the ma 1 mb 1 GEMM (dF backward) store C only where
  FP > 0 (ids 26, 58). `gkepok` refuses any other mode, beta or epilogue with -22. The select is the
  same `FSETP.GT` against RZ plus `FSEL` the separate kernels used (NaN → 0), so the result stayed
  bit-identical: equal gate lines, equal `geval` E lines, equal checkpoint after 200 steps. Launches
  fell by 16 per max-shape step, and summed GPU wait was 0.924× of k8's (144.56 → 133.54 ms/step, max
  k9 below min k8 in all three rounds; the pre-registered model gave an 8.49-14.15 ms/step saving and
  11.02 was measured). 200 steps took 0.942× of k8's wall (aien-train `evidence/OMEGALLM/gpu-k9/`).
  When `gktile` picks 32 at some shape, the 32×32 epilogue needs its own gate: neither the parity nor
  the max shape reaches it, so k9 ran `gcmp2` and mutant m at F = 96 (`ollm init … 256 32 64 2 96 2`).
- Make mutants build-time constants (`OMUTT`, `OMUTS`, `OMUTP`, `OMUTR`, `OMUTX`, `OMUTQ`, `OMUTW`;
  BF16 `OMUTU`, `OMUTL`, `OMUTO`, `OMUTV`, `OMUTN`; v3 `OMUTY`, selected with
  `tests/omegallm/build.sh --mutant t|s|p|r|x|q|w|u|l|o|v|n|y`), not runtime switches, so the
  product binary carries no mutant path. Check statically that a mutant changes exactly the intended
  slots before the window: mutant t differs from the product only in the 64×64 slots (32-39 until k7b,
  40-54 since k8), with one FFMA fewer per K tile (511 FFMA in slot 32 against 512; since k7, 447 of
  them `.reuse` against 448; k8's β kernels 575/447 against 576/448); mutant r's
  slot 11 has four `SHFL.BFLY` steps instead of five (the lane-1 step of the backward row sum is
  missing) and fails `gcmp2` with rc 47;
  mutant x's slot 21 has nine instead of ten (the CE sum's lane-1 step), fails `gcmp2` with rc 47 and
  moves `geval` by −362083 µnats. Mutant q is host-only (P·U and DS·K row tiles stop one K tile short
  through word 22), so its device code dump equals the product's; it fails `gcmp2` with rc 47.
  Mutant w differs from k6 only in the seven softmax `ISETP` immediates (+32, so each row's diagonal
  chunk is not loaded) and fails `gcmp2` at the max shape with rc 47. At the small shape its code is
  the product's and it passes with rc 0: a mutant needs a shape where its code differs.
- `tests/omegallm/gpu-disasm.sh` builds the CPU sources without `gg.om`. Every hook that `model.om`
  calls must therefore come from `nogpu.om`, or omc stops with error 5 at the call (seen from
  rung 5 until k2's fix). The dump writes all 64 slots of `gkcode` (1 MiB). A 32-slot dump silently
  drops ids 32-39. Since k6 `SHAPE="V T D H F B"` (the `grset` arguments, default the parity shape
  `256 32 64 2 128 2`) dumps any shape; the script exits 2 with `SHAPE_NOT_SET` when the substitution
  into `gpu-dump.om` did not take, and an empty slot prints `SLOT n empty`.
- Widening a shape past a register or scratch bound needs the old shape's code to stay byte-equal,
  and every host scratch sized by the old cap found before the window. Rung 7 (aien-train
  [#57](https://github.com/aien-dev/aien-train/pull/57) at `b312942`, `docs/omegallm/CONTRACT-V2.md`:
  D ≤ 384, F ≤ 1536) moved the warp-per-row RMS kernels' four D/32-word register banks above the
  scalars once D/32 > 8 (`gr.om` `grrb`: R32 + 8k up to 8 words, R72 + n·k beyond, ending at R119
  for D 384), so the v1-shape `gpu-code.bin` and GPR dump stayed byte-identical (`gpu-disasm.sh` with
  the rung-6 `SHAPE`). The first gate window still trapped (exit 103, BOUNDS) in `gcmp2` at the v2
  maximum: the host row scratch `gg.om` `ggfs` held 1024 rows, indexed by FFN unit j < F. grep the
  `global … f64 N` arrays for the old cap before opening a window. The v2 model (P 15,833,472) then
  trained 30000 steps on rung 6's data, seed and schedule to a chip `geval` of 1.254741 nats against
  1.338156 (EXERCISED, non-quiet; `evidence/OMEGALLM/gpu-r7/`); the CPU `eval` of that checkpoint
  printed the same `E 30000 2243 1254741 468077` (`gpu-r7/run/eval30000.txt`, `5bd9993`, 15,371 s
  on one core). An init-loss bound written without
  a derivation (v2 init within 0.05 nats of ln V, then of the v1 init) failed twice while the Python
  referee reproduced the product's init loss exactly: the contract init (uniform, sd 0.02) does not
  scale with D, so a wider model starts further above ln V. Derive such bounds or check against the
  referee instead.
- A BF16 tensor-core path can be added beside the f32 kernels without touching them. aien-train
  [#58](https://github.com/aien-dev/aien-train/pull/58) (`docs/omegallm/CONTRACT-BF16.md`, at
  `a82fc1a`) puts ten `gkgemmb` kernels in slots 27-36 (64x64 tile per 128-thread block, K tile 32,
  two 8192-byte shared buffers, `HMMA.16816.F32.BF16` with f32 accumulation, the f32 epilogues
  including fused 1 and 2). Operands stay f32 in memory and are rounded RNE by
  `F2FP.BF16.F32.PACK_AB` while staged into shared memory; master weights, Adam and checkpoints do
  not change, and `geval` keeps the f32 kernels, so the held-out metric is the same measure. It is
  opt-in (`gtrainb`/`gprofb`, `gkbf 1`). Every slot outside 27-36 (f32 ids 0-26 and 37-63) keeps its
  code and register bytes and the AArch64
  CPU build is byte-identical, so every f32 receipt still stands. Gates: `gbfrag` (exit 50) is exact
  per kernel on fixed data with NaN in every word the kernel must not read, both operand roles, and
  long-K cases; `gbcmp` (48) samples every BF16 launch of a gradient pass against an f64 sum over the
  bf16-rounded operands with bound (kn·2^-23 + 2^-22)·(|α|·Σ|a·b| + |old C|); `gbcmp2` (49) is
  `gcmp2` with the loose heuristic tolb = n_c·(2u + u²), u = 2^-8, n_c = 10L + 3 (0.6497 at L 8),
  which catches gross failures only. Put the rounding in the reference: then the gate checks the
  stated numerics, and bf16-vs-f32 distance is a separate, pre-registered training comparison. At
  B 64 (kn 16384) `gbcmp` is blind to one wrong K tile, so long K loops need `gbfrag`'s exact
  long-K cases (mutant o, one K tile short, is invisible at k = 32 because the K loop is a
  do-while). Mutants l (lane g / g^1 A rows swapped in the LDS layout), o and v (F2FP toward zero)
  are caught by `gbfrag` and `gbcmp`; mutant u (reference skips the rounding) is caught by
  `gbfrag`, while `gbcmp` only reports it, since per-sample RNE error can sit inside the f32 bound.
  Mutant n (`gb.om` `OMUTN`: the host overwrites one C padding word after each short case's launch,
  no kernel change) is the negative control of `gbfrag`'s padding check, the only check that can see
  it; in the v3-g1 window (aien-train #60 at `b92c96b`, `evidence/OMEGALLM/v3/chip-g1/REPORT.txt`)
  the product printed `GFS 0` and mutant n failed with rc 50, `GFS 26`.
  Window bf-t1 (EXERCISED, non-quiet): `E 2000 2243 1749889` against
  rung 7's f32 1756935 (bound 1765719), the 250→2000 leg 1.18117x faster (367.57 s vs 434.16 s), median
  GEMM wait 135.3 vs 176.6 ms/step; BF16 GEMMs reached 11.6-22.4 TFLOP/s against 118.81 measured
  HMMA, and 54 ms/step of non-GEMM wait plus the synchronous launch round trip now dominate. It
  relaxes the bitwise f64-CPU gate on the GEMM path. Drake adopted it for training on 2026-11-03
  (CONTRACT-BF16 section 7): long runs use `gtrainb`, every f32 command keeps its behaviour, `geval`
  stays f32, and the CPU `eval` of a final checkpoint must still print the chip's line. Adoption is
  not a quality claim; the first long BF16 run carries its own prereg.
- Rung 8 (aien-train [#59](https://github.com/aien-dev/aien-train/pull/59), stacked on #57,
  `evidence/OMEGALLM/gpu-r8/`) changes only the schedule: rung 7's binary, seed, data and batch with
  init TOTAL 60000 (`cmp -l` against rung 7's ckL0: bytes 81-82 only). Chip `geval`
  `E 60000 2243 1206290 450002`, 1.206290 nats against rung 7's 1.254741 (−3.86%), the curve
  strictly decreasing over 22 points, summed `gtrainf` wall 14,688-14,864 s for 250→60000
  (0.24471 s/step on undisturbed legs, non-quiet). EXERCISED; the CPU `eval` of ck60000 (P4) printed
  the same E line (`gpu-r8/run/eval60000.txt`, `8915b46`). At step 30000 rung 8 was 30,366 µnats above rung 7's final value, because its
  learning rate there is still 0.5508 of peak: comparing intermediate steps across different
  schedules says nothing, so the prereg only compares final values. Two infrastructure events, both
  disclosed and counted in the wall sum: a full root disk (`gtrainf` rc 70 on the checkpoint write;
  `ck.bin.tmp` plus rename left `ck.bin` intact), and an agent session ending that killed a leg
  mid-window. Launch long drivers with `setsid nohup` so they do not belong to the agent session;
  batches derive from (seed, step), so resuming from the last checkpoint trains the same steps.
- Rung 9 (aien-train [#61](https://github.com/aien-dev/aien-train/pull/61), stacked on #58,
  `evidence/OMEGALLM/gpu-r9/`) is the first long BF16 run after adoption. It replays rung 7 step for
  step with `gtrainb` (same ckL0, data, seed, schedule and legs; binary 54fb8233…). Chip `geval`
  `E 30000 2243 1251860 467002`, against rung 7's f32 1254741 (−2,881 µnats, −0.230%), and the
  pre-registered bound was ≤ 1261014 (+0.5%). BF16 sits 0.14-0.81% below f32 at all 12 shared
  steps. With one seed per arm that is no regression, not a demonstrated gain. The CPU `eval` of
  ck30000 printed the same E line. Summed `gtrainb` wall for 250→30000 was 5,740.26 s
  (0.19295 s/step, 1.2387x rung 7, non-quiet). ck2000 and E 2000 reproduced bf-t1 byte for byte, so
  `gtrainb` is deterministic across windows on one chip. EXERCISED on one GB10.
- Rung 10 (aien-train [#62](https://github.com/aien-dev/aien-train/pull/62), stacked on #58,
  `evidence/OMEGALLM/gpu-r10/`) replays rung 8's 60000-step schedule with `gtrainb` (same ckL0
  e02c6234…, data, seed and legs; binary 54fb8233…). Chip `geval` `E 60000 2243 1204466 449322`,
  against rung 8's f32 1206290 (−1,824 µnats, −0.151%); the pre-registered bound was ≤ 1212321
  (+0.5%). BF16 sits 0.05-0.76% below f32 at all 22 shared steps, and 0.09-0.16% over
  30000→60000, so the gap does not widen with twice the steps. The CPU `eval` of ck60000 printed the
  same E line. Summed `gtrainb` wall for 250→60000 was 11,478.56 s (0.192110 s/step, 1.2738x
  rung 8's undisturbed rate, non-quiet). Hazard seen here: a run script written without the
  execute bit makes `spark-window` return leg rc 126 ("Permission denied") with no training done;
  `chmod +x` the leg script before the first window (its sha256 is unaffected). EXERCISED on one GB10.
- v3 (aien-train [#60](https://github.com/aien-dev/aien-train/pull/60) at `b92c96b`, stacked on
  #57 with #58 merged in; `docs/omegallm/CONTRACT-V3.md`) raises the L maximum from 8 to 16 at the
  v2 width (P 29,995,392) by moving parameters, gradients and activations into banked storage while
  every sum keeps its order, so v0-v2 commands, files and outputs keep their bytes. Test the bank
  boundaries at a small shape by shrinking the bank-A capacities (variant bx: `OWC 8400`, `OGC 5000`,
  `OAC 12344`, so `256 8 16 2 32 4` crosses every bank) and comparing checkpoint, T lines, eval and
  sample against the normal build; mutant y (bx plus `OMUTY 0`: `ostw` stages the first bank-B layer
  for every layer) must fail all four. Two branches that each add an `OMUTV` collide when merged
  (omc error 10, a duplicate name): v3's mutant was renamed `OMUTY`/`--mutant y`, and receipts that
  predate the rename keep the file name `ollm-mut-v`. Keep every `const OMUT*` unique across
  branches. Chip gates F1-F8, L1-L4 and B1-B6 ran pre-registered in window v3-g1 (2026-11-04) and
  all held, every gated mutant failing as predicted (`evidence/OMEGALLM/v3/chip-g1/REPORT.txt`).
  v3 is not trained yet: at aien-train main `56cc8870` `evidence/OMEGALLM/v3/` holds the host
  checks and `chip-g1` only, no training run.
  EXERCISED on one GB10, non-quiet.

## 10. Wire serialization (only what the pin defines)

- There is no byte-layout type. Encode and decode integers with shifts and masks into `uchar`
  arrays. Little-endian `uint` store (as in `examples/fnv1a32.om`):
  `put b 0 uchar and h 255`, `put b 1 uchar and shr h 8 255`, ... `shr h 24`.
- Little-endian `uint` load: `or or or uint get b 0 shl uint get b 1 8 shl uint get b 2 16 shl uint get b 3 24`.
  Split it over lines if it hits error 12.
- Signed decode without relying on integer `bitcast`: with `u` the loaded `uint`, write
  `v = long u`, then `if ge u 2147483648` / `v = sub v 4294967296` / `end`, then use `int v`
  (`v` is assigned before the block so it survives the block's `end`).
- Formats the pin itself defines: packed lists are a little-endian `u16` count (1..64) then records
  of little-endian `u16` length plus bytes, at most 4096 bytes, no padding or terminator
  ([#L724-L730](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md#L724-L730)); `pipefds` writes two
  little-endian 32-bit descriptors; `fstat`/`stat` write the 128-byte Linux ARM64 stat structure;
  `waitpid` writes a 4-byte status. Any other protocol layout needs its own spec citation and test
  vectors.
  At the pin `9920aab1` (OMEGESE lines 1050-1056) a packed list with embedded zero bytes, a truncated
  record, extra trailing bytes or a count outside 1..64 traps 3; the first `execprog` record (path and
  argument zero) must be nonempty, and `renames` needs exactly two nonempty records. These refusals are
  gated by `seed/qualification/security673/packets.cases` (see `omega-harness`, seed tools section).
- IR mode and floats, observed 2026-11-05 with omc `be8c5130…`: a float type in an `ir` function
  signature (`fn fa a f64 b f64 to f64`) is `omc: line 2: error 9`, and a float word in the body
  (`x = f64 a`) is `omc: line 3: error 3` (OMEGESE says error 3 only). No producer of float IR exists, so
  float backends (`seed/stablehlo` wire v7, `irnki f32`) use hand-written fixtures or retyped u32 lanes.

## 11. Compiler errors (exit code = error number, stderr `omc: line N: error K`)

The single source of the codes on main `91c83438d` (#965) is the registry
[`seed/omc/error-codes.reg`](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/error-codes.reg)
(issue #797). `seed/omc/gate15.sh` ([#L1-L9](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/gate15.sh#L1-L9),
cases [#L45-L72](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/gate15.sh#L45-L72))
holds one minimal program per code for codes 1..25 and 27..30 (26 has no emitting site), each
checked for its exact exit code and `omc: line L: error C` line, and runs `seed/omc/codereg.om`,
which fails when an emitting site in `omc.om` has no registry row, an emitted row has no site, the
table in OMEGESE section 9.14 ([#L811-L855](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/docs/one_layer/OMEGESE.md#L811-L855))
differs from the registry, or a case did not refuse as listed. irwasm exit codes 20..28 are a
separate namespace in the same registry (OMEGESE section 11.1). The message format is `fn fail`
([omc.om#L122-L148](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omc/omc.om#L122-L148) at `55f9b0af`;
[omc.om#L292-L322](https://github.com/aien-dev/omega-mv/blob/e5b32567a7aff3ce594e3254a622a846a6cd190b/seed/omc/omc.om#L292-L322) at `e5b32567`;
[omc.om#L324-L356](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/omc/omc.om#L324-L356) at `91c83438`,
`fn fail` on the first line and `exit int code`, the only non-zero `exit` in the compiler, on the last).

| Code | Meaning | Code | Meaning |
|---|---|---|---|
| 1, 2 | compiler input / output (stdin a directory: 1; stdout `/dev/full`: 2; both observed) | 13 | non-function name over 8 characters (over 63 once #837 is pinned) |
| 3 | unknown name or field | 14 | capacity at `91b3c932`: 8192 names, 4096 functions, 512 nested blocks, 1024 nesting depth, 8 MiB input/output |
| 4 | line ends too early | 15 | missing `end` |
| 5 | extra words on the line | 16 | syntax / unknown word |
| 6 | malformed number | 17 | line after `ret`/`break`/`continue`/`trap`/`exit` |
| 7 | type mismatch | 18 | missing `ret` |
| 8 | number out of range | 19 | global passed, or the same array twice in one call |
| 9 | word in a disallowed place | 20 | write to a view or text |
| 10 | duplicate name | 21 | constant index out of range |
| 11 | ambiguous bare number | 22 | bad text literal |
| 12 | register pool exhausted | 23 | size capacity |
| 24 | AArch64 branch displacement out of range | 28 | abstract type: `seal` outside its constructor, or an unsupported `holds` |
| 25 | unknown target, an AArch64-only path on another target, or an x86efi refusal (omega-mv#1015: bare unit, Linux host word, `efi` OP literal outside 0..13, 0..14 with #1022) | 29 | external `layout` out of bounds or misplaced |
| 26 | unused (no emitting site) | 30 | contract syntax misplaced or not supported here (IR mode included) |
| 27 | `fresh` element read before it is definitely written, or a fresh array passed on | | |

A refused compile may still leave bytes on stdout. Never run output from a non-zero compile.
Capacity boundaries are gated in `seed/omc/gate12.sh` (8192 globals accepted, 8193 refused;
4095 helper functions plus `main` accepted, 4096 plus `main` refused).

OM-2 units add or extend codes ([OMEGESE 9.13](https://github.com/aien-dev/omega-mv/blob/19f014f2178ca9cd3473728fe00a475a2398c409/docs/one_layer/OMEGESE.md#L624),
[`spec/omegese-om2.md` section 8](https://github.com/aien-dev/omega-mv/blob/19f014f2178ca9cd3473728fe00a475a2398c409/spec/omegese-om2.md#L225)):
27 initialization (`fresh`), 28 constructor discipline (`seal`, `holds`), 29 external `layout`;
14 also covers expansion fuel (`obligation=growth`) and a 33rd `export`; 24 keeps its OM-1 meaning
(branch displacement). Merged contracts (#807 through #768) add error **30**, diagnostic
`obligation=contract` (section 11a).

**IR mode refuses contract clause lines with error 30** (main `91c83438d`, #965, #791; OMEGESE
section 11 [#L1097-L1102](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/docs/one_layer/OMEGESE.md#L1097-L1102)).
Contracts are native only; an IR unit that writes one is refused rather than misread. Only the clause
form is refused: a contract word followed by `=` (`ensures = ulong 1`) still assigns a local of that
name. Observed 2026-10-31 with omc `2aec185d…`, control omc `7a8b84fc…` (main before #965):
`ir` / `fn f x uint to uint` / `requires lt x 10` / `ret x` / `end` is `omc: line 3: error 30`,
exit 30 (control: exit 0, 59 bytes of IR, the clause read as a local named `requires`); the same
with `ensures lt x 10`: error 30 (control: exit 0, 59 bytes); with `invariant lt x 10`: error 30
(control: `omc: line 3: error 13`, a 9-byte name). `ensures = ulong 1` / `ret ensures` compiles with
exit 0 to the same 55 bytes of IR under both compilers. Native units are unaffected: with
`2aec185d`, as with `7a8b84fc`, an OM-1 unit (no `om2` first line) with `requires ge x 0`, called
with -5, still compiles and exits 6 (the contract is not checked), and the same unit with `om2`
first exits 109 (trap 9).

Limits met while porting CUDApp's encoder and cubin writer (aien-dev/CUDApp#143, merged
`2fab72fde0`), rechecked with omega-mv main `bf54b19f` (`seed/out/omc` sha256 `62775d2a...`):
an array parameter of length 16777216 compiles and 16777217 is error 23, so one `.om` buffer holds at
most 16 MiB of `uchar`; `text` inside a function-mode unit is error 9 (both OBSERVED, identical on
omc `2c824805`). AUTHOR-CLAIMED, not rechecked: `global` inside a function-mode unit is error 9, and
omega-bridge `431fff0a` `native c` exits 110 when an entry's array length is written as a `const`
name (write the literal in the entry signature).

One minimal refusal per code is in `examples/errNN_*.om` of this repository, with its exact stderr
line in `errNN_*.expect`, and `examples/gate.sh` runs them: codes 1..23 and 27..30, observed at
`e5b32567`, plus code 25 (`err25_target`, added 2026-10-31 at `91c83438`). Code 24 needs a
generated program of more than 1 MiB inside one loop (recipe in `writing-omega` section 11;
observed at `e5b32567` and rerun at `91c83438`, section 0). 25 and 26 were unused at `e5b32567`;
since `bf54b19f` the target checks emit 25 (section 0, rerun at `91c83438`).

## 11a. Executable contracts (merged #807 through #768)

Source: OMEGESE section 12 and `seed/omc/contracts/` at main
`91b3c9326919faf1491e29ae9276929e8349b8c7`, compiler `189ada82...3b54` (section 0).
The committed fixtures below were exercised by the batch host qualification:
`evidence/BATCH-189ada82/qualification.log` records all 44 contract cases and the two mutants.
Older compiler `befb8199` does not implement these contextual contract words.

- **Opt-in and policy.** Only OM-2 units. The first non-`note` line selects the build policy:
  `om2` or `om2 debug` checks contracts at run time; `om2 release` erases their evaluation after the
  same syntax, scope, type and purity checks; `om2 diag debug` / `om2 diag release` add diagnostic
  records; `om2 fmt` keeps its canonical output and still checks contracts. No environment variable
  selects the policy. The words are contextual: OM-1 units and the keyword table are unchanged.
  Warning: an OM-1 unit that contains a contract line still compiles, and the contract never runs.
  `fn step x long to long` / `requires ge x 0` / `ret add x 1` called with -5 compiles with no
  diagnostic and returns -4; adding `om2` as the first line makes the same call trap 9 (exit 109),
  and with `om2` a call with 5 passes the contract and returns 6. Observed with omc 734f0a39,
  2c824805, the guide pin 2aec185d (omega-mv `91c83438`) and omc e4d84bc3 (omega-mv main
  `d39450a2`). Every unit that relies on a contract must start with `om2`.
- **Where clauses go.** `requires BOOL` and `ensures BOOL` form a function's prefix, before its first
  executable statement (blank and `note` lines may separate them; at most 64). `invariant BOOL` forms
  the prefix of a `while` or `for` body (at most 64 per loop). Anywhere else is error 30.
- **When they run.** Preconditions in order on entry, inline calls included. Postconditions in order
  on every normal return (`ret`, void fallthrough, inline return), never on `exit` or a trap; the
  return value is computed once and `result` (value functions only) names it. A parameter in a
  postcondition is its value at return: there is no `old`. Invariants run at the loop head before
  the condition: on entry even for zero trips, on every backedge, after `continue` (a `for` increments
  first) and before the final false test; `break` skips the next check.
- **What a predicate may use.** Type `bool`; integer and bool literals and names, integer and bool
  operations, checked conversions, grouping, `len`, ordinary checked array, struct and layout reads.
  User calls (inline too), floats, abstract values, host and device words, allocation, writes and
  ownership words are error 30, recursively, in release as well. `and`/`or` stay eager, so they do
  not guard a bounds check.
- **Failure.** False `requires` is trap 9 (exit 109); false `ensures` or `invariant` is trap 10 (exit
  110); function-mode callers get the same codes through `OscRt.trap`. A trap raised while evaluating
  a predicate keeps its own code (the `arithmetictrap` fixture expects 102). Note that 10 is also the
  OM-2 `holds` check trap, so the trap site, not the code, identifies the failing clause.
- **Erasure.** Only a predicate that folds to true without trapping is proved and erased in debug.
  Release erases evaluation by policy, never uses a predicate as an optimizer assumption, and never
  removes the body's own arithmetic, bounds, initialization, stack or loop-fuel checks. The fixtures
  require byte-identical output for `release.om` against `erased.om` and for `proved.om` against
  `plain.om`, not just equal exit statuses.
- **Diagnostics.** With `om2 diag` (debug) or `om2 diag release`, every contract site gets a
  `omc-check 1 kept|erased line=N rule=RULE kind=KIND` record on stderr: rule `runtime` for a kept
  check, `constant-true` for a proved one, `release` for policy erasure; kind `requires`, `ensures` or
  `invariant`. Postconditions are reported at their return sites. Error 30 carries
  `obligation=contract` in the `omc-diag` record. Fixture expectations: `diagproof.om`
  (`requires eq add uint 1 2 3`) gives `omc-check 1 erased line=3 rule=constant-true kind=requires`;
  `diagrelease.om` (`om2 diag release`, `requires false`) gives
  `omc-check 1 erased line=3 rule=release kind=requires`.

`seed/omc/contracts/ok.om` (expected exit 0):

```
om2
fn step x uint to uint
requires lt x 10
ensures eq result add x 1
ret add x 1
end
fn main to int
i = uint 0
while lt i 3
invariant le i 3
i = step i
end
ret int sub i 3
end
```

`seed/omc/contracts/requires.om` (expected exit 109; the precondition fails on entry):

```
om2 debug
fn f x int to int
requires gt x 0
ret x
end
fn main to int
ret f 0
end
```

`seed/omc/contracts/release.om` (expected exit 0, and byte-identical to `erased.om`, which is the
same program without the three contract lines and with `om2` in place of `om2 release`):

```
om2 release
fn f x int to int
requires gt x 0
ensures eq result add x 1
ret x
end
fn main to int
while false
invariant false
end
ret f 0
end
```

Refusals pinned by `contracts.cases`: a user call, host word, float (also through a float constant
or float array), misplaced clause, late `invariant`, `result` in a `requires` or in a void function
are error 30; a non-bool predicate is 7; a name declared later in the body is 3; reading an
unwritten `fresh` element is 27. The cases run through the existing OM-2 conductor
`seed/qualification/om2/gate.om`. `mutant.cases` builds two broken compilers: one with enforcement
disabled (`requires.om` must still exit 109) and one whose prover treats any constant predicate as
proved (`false.om`, `requires false`, must exit 109). Both run to exit 0, so the suite must end
`OM2GATE FAIL cases=2 pass=0 fail=2 invalid=0 not_run=0` (conductor exit 1), which
`seed/host/check.sh` requires with the exact `VERDICT` lines. A passing mutant suite would mean the
check proves nothing.

## 11b. Composed units and traps that compile

Omega has no imports: a multi-file program is its units concatenated into one input
(`cat a.om b.om main.om | omc`). These rules bite there, and several compile without a word.
Observed 2026-11-04, Linux AArch64 host only, with the pinned omc `be8c5130…` (omega-mv
`9920aab1`); the first three are gated as `examples/pitfall_*.om` in this skill. Source citations
are `seed/omc/omc.om` at `9920aab1`.

- **There is no `elif`.** A statement `NAME VALUE` is an assignment; the `=` is optional
  (`s_assign`, [omc.om#L8197-L8207](https://github.com/aien-dev/omega-mv/blob/9920aab1413983c2867d02d75b2276341595adb8/seed/omc/omc.om#L8197-L8207)).
  So `elif eq k 1` (or `elsif`, `elseif`) silently makes a local bool and the line after it runs
  every time: `zz ulong 9` / `ret int zz` exits 9, and `examples/pitfall_elif.om` returns 20 where
  10 is meant (compile exit 0, no diagnostic; same with omega-mv main omc `b4f45121`). Write
  separate `if ... ret ... end` blocks or nest the test inside `else`; both forms of the same
  function return 10, 20 and 0 for k = 0, 1, 2. A refusal (error 16) is omega-mv
  [#858](https://github.com/aien-dev/omega-mv/pull/858), an open draft, not on main at `d3d1b1bc`.
- **One namespace for the whole input.** Globals, texts, consts, structs and functions of every unit
  are visible in every other one. A local named like another unit's global array is error 7, not
  error 10 (`examples/pitfall_shared_name.om`, `omc: line 8: error 7`; renamed, exit 7); a local
  named like another unit's value function, `const` or `text` is also error 7 (a function name
  parses as a call). Two units that each define `fn twice` give `omc: line 4: error 10`; a second
  `global sh`, `const` or `text` of the same name is error 10 on its line, a second `struct P`
  error 9.
  Prefix every global and helper with the unit's short name. Modules are roadmap RM6
  ([omega-mv#795](https://github.com/aien-dev/omega-mv/issues/795)), not built.
- **Line numbers count the composed input.** `omc: line N` and every `omc-check`/`omc-site` record
  give N in the concatenated stream: composed from a 4-line unit (`global sh` and `seta`), a 4-line
  unit with the clashing local, and `main`, the clash is `omc: line 6: error 7`, line 2 of the
  second unit. Keep the per-unit `wc -l` or run `grep -n . composed.om` to map back.
- **The `om2` line must be the first non-`note` line of the composed input.** It sets the mode of
  the whole input. `om2 diag debug` as a one-line first unit, then a 3-line OM-1 library, then a
  unit with `requires gt x 0` compiles, prints `omc-check 1 kept line=6 rule=runtime kind=requires`
  and exits 4 as written; with a `note` line in front it prints `line=7`; the same header placed
  after the library is `omc: line 4: error 16`.
- **Four global `get` terms in one `or` chain exhaust the registers.** `or or or ne get hdr 0 1 …`
  over a global is error 12 (`examples/pitfall_or_global.om`, `omc: line 5: error 12`; also with
  `k`-relative indices). Three terms, the same four on a local `new` array (exit 9), or
  `a = or …` / `b = or …` / `if or a b` (exit 9) compile.
- **A trap names its code and function, never its line.** Each trap site records only its branch
  and code; `finish` emits one stub per code used in the function and patches every site of that
  code to it ([#L2939-L2952](https://github.com/aien-dev/omega-mv/blob/9920aab1413983c2867d02d75b2276341595adb8/seed/omc/omc.om#L2939-L2952),
  [#L9852-L9898](https://github.com/aien-dev/omega-mv/blob/9920aab1413983c2867d02d75b2276341595adb8/seed/omc/omc.om#L9852-L9898)).
  A function with `get ga i` (4 bytes) and `get gb i` (8 bytes) on two paths exits 103 with empty
  stderr for index 9 on either path (indices 3 and 7 exit 0). When the site matters, test the range
  yourself and give each site its own exit below 100 (`if ge i len ga` / `exit 21`): the same
  inputs then exit 21 and 22. Bounds are per array, so an index from one buffer's offset space used
  on another traps 3 only once the data grows past the smaller array.
- **The output has no symbols.** `file` reports `statically linked, no section header`,
  `readelf -S` `There are no sections in this file.`, `nm` `no symbols`; the function name `pick`
  occurs 0 times in the binary while a `text` literal `pickmark` occurs once. perf and gdb cannot
  name functions; profile by timing separate programs or entry points. A perf map from omc would be
  a compiler change.
- **Rechecked at this pin:** `le` as a local or function name is error 16 (`lte` compiles, exit 4);
  `line` and `out` are *not* reserved (`line = ulong 3` / `ret int line` exits 3); `getppid` returns
  the real parent (`sh -c 'echo $$ | ./ppid'` exit 0, a wrong pid exit 1); `\r` in a `text` is
  `omc: line 1: error 22`; `global g uchar 16777217` is error 23 and 16777216 compiles; a global
  argument is error 19 (copy into a local: exit 6). Eager `and`/`or` is section 3, the 16-register
  pool section 6.
- **Mutation runners:** write each mutant to a path that is not the build's own output `.om`;
  otherwise the runner overwrites one with the other and tests the wrong file.

## 12. Before any claim

1. Inspect the compiler, not memory. Find the rule in `omc.om` or a gate fixture at the pinned commit
   and cite file and line. Skills, older notes and this file can be stale.
2. Compile with the pinned `omc` and run. Report what was observed, labelled host-only.
3. Add a negative control: change an expected value or remove a guard and confirm the exit status
   changes.
4. No silent fallback. If `omc` cannot express something, do not write it in C, Rust, shell or
   Python and call the result Omega. Say exactly which word or capacity is missing.
5. Missing is not impossible, and it is not a stopping point. Drake's standing rule (2026-10-26):
   "If .om doesn't have a feature, you need to make that feature." Build it in Omega as an omega-mv
   pull request, coordinated with whoever owns the compiler lane at the time. The PR names the
   hardware or OS need, the word and its types, refusal codes and a new error code if one is needed,
   gates with a negative control, parity against an independent oracle, and the matching update to
   this skill. Host code is a last resort only. When it is used, record it with its Omega successor
   and the omega-mv PR that will replace it. Known decision-blocked gaps still need Drake's decision
   before they are built (roadmap RM4 heap, RM6 imports;
   [omega-mv#793](https://github.com/aien-dev/omega-mv/issues/793), [#795](https://github.com/aien-dev/omega-mv/issues/795)).
   They are listed at `55f9b0af` ([OM_COMPLETION.md#L62-L72](https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OM_COMPLETION.md#L62-L72)),
   unchanged at main `bf54b19f` ([#L65-L73](https://github.com/aien-dev/omega-mv/blob/bf54b19fa590e8ae925c0e80815516dbf41e7326/docs/one_layer/OM_COMPLETION.md#L65-L73)):
   packed structs (FR-2), imports (FR-3, units concatenate), threads/atomics (FR-6), C ABI/shared
   objects (FR-7), heap (decision 24). x86-64 (FR-9) is no longer missing: since main `bf54b19f`
   (#923, 2026-10-28) `target x86linux` selects an x86-64 Linux static-ELF backend in
   `seed/omc/omc.om`. Its status there is DRAFT, x86 execution is EMULATED (QEMU) only and native
   x86 qualification is NOT_RUN (`docs/X86-LINUX.md` lines 3 and 286).
6. Documents can disagree with the code; trust the code and name the conflict. At main `91c83438d`
   (rechecked 2026-10-31) the earlier conflicts are resolved: OM_COMPLETION FR-5
   ([#L68](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/docs/one_layer/OM_COMPLETION.md#L68))
   lists `devctl devcall uvmctl mapnew ... mapbind` (ids 166..177 in `seed/omc/genkw.awk`) as
   implemented for AArch64 program mode (omega-mv #944, merged by train r5 #985 as `613765d2b`; it
   said "absent" through `4376c2112`), and `seed/host/MAPPING.md`
   ([#L68-L70](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/seed/host/MAPPING.md#L68-L70))
   says the device words are on `main` (train r2 #972, `f5c9bd89a`). GPU launch and model execution
   through them are not qualified. The FR-9 row
   ([#L72](https://github.com/aien-dev/omega-mv/blob/91c83438daec0bdb88bf5c077cae10f3d15d365d/docs/one_layer/OM_COMPLETION.md#L72))
   and `docs/X86-LINUX.md` line 450 now cite the same EMULATED differential at `62d1d0d6` (15182 PASS,
   0 FAIL, 2 NOT_RUN, 222 EXCLUDED, aggregate FAIL); native x86 stays NOT_RUN.
7. `devctl` request set at the pin (unchanged at omega-mv main `d3d1b1bc7`, rechecked 2026-11-04 in
   `hdevctl`, `seed/omc/omc.om`): FIONREAD (21531) and encoded read/write NVRM `'F'` requests only;
   any DRM request is error 9. PENDING, not merged: aien-dev/omega-mv#899 (head `15fb0b88`, open,
   its body says draft pending review, conflicting with main on 2026-11-04) adds an explicit list of
   eleven accel/ethosu requests (the ten `DRM_IOCTL_ETHOSU_*` of Linux v7.3 plus
   `DRM_IOCTL_GEM_CLOSE`), with the exact-size check unchanged. Until it merges and the pin moves,
   code that issues those requests needs that branch's `omc` and must say so.

## 13. Examples

- `examples/fnv1a32.om`: reads all of stdin with a partial-read loop, hashes it (FNV-1a 32, unsigned
  wrap), writes 4 little-endian bytes with a partial-write loop, distinct exit codes for each failure.
- `examples/trap_narrow.om`: a masked narrowing succeeds, an unmasked one traps 5 (exit 105).
- `examples/pitfall_elif.om`, `pitfall_shared_name.om`, `pitfall_or_global.om`: the first three
  traps of section 11b (exit 20, `omc: line 8: error 7`, `omc: line 5: error 12`).

Each carries `.expect` (and `fnv1a32` also `.stdin` `abc` and the 4 expected bytes in `.stdout`) and
runs in [`examples/gate.sh`](../../examples/gate.sh) with the 105 programs in the repository's
`examples/` directory; section 0 records the `e5b32567` rerun of every row below. The portable guide
for writing a first program is [`skills/writing-omega/SKILL.md`](../writing-omega/SKILL.md).

Observed on 2026-10-25, Linux AArch64 host only, compiler sha256 `734f0a39...6b61`:

| Check | Observed |
|---|---|
| `fnv1a32.om` compile | exit 0, empty stderr |
| input `abc`, `a`, empty, 65535 zero bytes | `0be9471a`, `2c290ce4`, `c59d1c81`, `47dac371`; each exit 0 and equal to an independent Python FNV-1a computation |
| 65536 zero bytes | exit 2, no output |
| prime changed to `16777617` (negative control) | `abc` gives `55bedcf5`, differing from the expected hash |
| `trap_narrow.om` | compile exit 0, run exit 105 |
| unmasked line removed | run exit 44 |
| refusal below | compile exit 7, stderr `omc: line 3: error 7` |

Refusal to try inline (expected exit 7, the same class as gate15 `e7_type_mismatch`):

```
global b uchar 1
fn main to int
x = add get b 0 uint 1
ret int x
end
```

- Numeric work in or behind an `.om` unit (limits, sizes, masks, checksums, expected values, tolerances) is computed with Wolfram and quoted with the query, never by hand: see `skills/wolfram-math/SKILL.md`.
