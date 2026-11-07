# evidence/x86-native: omega-mv's x86 corpus, run natively on x86-64

On 2026-11-07, omega-mv's FR-9 x86 qualification oracle ran with its x86-64 programs native for the first time. Until then every run was on an AArch64 host, with the x86 side emulated under qemu-x86_64: the last one is omega-mv's `seed/qualification/x86-linux/20261030-main-62d1d0d6.json`, 15,182 PASS, 0 FAIL, 2 NOT_RUN, 222 EXCLUDED, all EMULATED. omega-mv's `docs/X86-LINUX.md` still calls native x86 NOT_RUN.

The run covers one cloud x86-64 host. It is HOST_TESTED, not QUALIFIED, and no hardware qualification.

## Results

Receipt: [`20261107-6fbc6cbe.json`](20261107-6fbc6cbe.json). Every row the oracle printed: [`20261107-6fbc6cbe.jsonl.xz`](20261107-6fbc6cbe.jsonl.xz), 16,204 lines, sha256 `f88c2847…b736` uncompressed. The oracle's verdict is FAIL, exit 1, because some rows are not PASS.

| Status | Rows | What they are |
|---|---:|---|
| PASS | 15,499 | Every assertion held, the x86-64 program running natively. |
| FAIL | 232 | None is an x86 miscompile. 150 need omega-mv's four om2 candidate compilers, whose commits (`a5927895`, `7fb62f3a`, `ad220c05`, `f6a6492f`) are not on the Radicle seed: `historical compiler source identity mismatch`. 46 are omega-bridge `1958a189` refusing the compiler under test, because its `tools/native` pins the x86 compiler to `62775d2a`. 36 are emit pins that record the AArch64 bytes of an older omc; see [Stale emit pins](#stale-emit-pins). |
| NOT_RUN | 32 | 1 `EMULATOR_ARTIFACT` (`seed/host/tests/uvmctl.om`), classified exactly as in the 10-30 receipt, with the AArch64 arm now the emulated one. 15 entryless units with no reviewed private-ABI caller. 16 sources with unreviewed host effects, among them `seed/host/tests/devcall.om`, whose source has changed since its driver was pinned. |
| MISSING_IMPLEMENTATION | 30 | omc refuses these on x86 by design: OM-2 `dit` (6) and `scrub` (18), the VFIO, IRQ and eventfd words (4), `execpure` (1) and `fma` (1, no FMA3 on the SSE2 baseline and no unfused fallback). All were added for AArch64 after the 10-30 receipt. |
| BLOCKED | 75 | 48 security673 rows exec `/bin/true`, `/bin/echo` and `/bin/tr`. The drivers pin the Ubuntu coreutils 9.4-3ubuntu6.3 arm64 builds; this host has the amd64 ones. 24 rows of `seed/omc/om2/fnhost/mutants.cases`, which has no reviewed verdict authority. 3 rows (`security673/exec-parent.om`) need `RLIMIT_NOFILE` 65600; this VM's hard limit is 20000, and it lacks `CAP_SYS_RESOURCE`. |
| EXCLUDED | 311 | Conductor directives and substitutions, not standalone sources. |

Both negative controls PASS. A deliberately invalid opcode is rejected by the disassembler, and a valid but wrong immediate is caught by the behaviour differential.

Only 52 of the non-PASS rows depend on this host: the 48 pinned children, the 3 descriptor-limit rows and the one QEMU artifact. The causes of the rest are the state of omega-mv at `6fbc6cbe` and its pins, not the CPU.

The corpus and the compiler both differ from the 10-30 run. omega-mv `6fbc6cbe` has 16,179 rows where `62d1d0d6` had 15,406, and its compiler is `cfd96b48`, not `62775d2a`.

### The FAIL that was a compiler bug

Before the fix, 8 more rows failed: `compile refusal differs after exact source-coordinate translation`, on `seed/omc/tests/float/neg_fma_*`. omc refused `fma` for x86 (error 9) before typing its operands, so an ill-typed `fma` got error 7 or 11 on AArch64 and error 9 on x86. [`../../seed/LOCAL.patch`](../../seed/LOCAL.patch) moves the refusal after the operand checks. Each fixture in [`../../tests/regress/`](../../tests/regress/) fails on x86 with the old compiler and passes with the new one.

A discovery run with the old compiler (`cfd96b48`) covered all 16,179 rows. Compared row by row with the final run, exactly those 8 rows changed, FAIL to PASS, and nothing else changed. 207 AArch64 compiles of every harness example, float fixture and host fixture are byte-identical before and after.

### Stale emit pins

[`stale-pins.sh`](stale-pins.sh) recompiles each emit FAIL row's exact source with every AArch64 omc that omega-mv committed from `62d1d0d6` to `6fbc6cbe`, newest first. It also recompiles with the compiler under test. [`20261107-6fbc6cbe-stale-pins.tsv`](20261107-6fbc6cbe-stale-pins.tsv) gives the result: all 36 are STALE_PIN.
- 35 pins are reproduced byte for byte by the omc committed at `e59a0060` (2026-11-06).
- 1 pin, `security673/relational/evidence/run3/embed.bin`, is reproduced by the omc at `2cd0947d`.
- In every row, the compiler under test reproduces what the oracle observed.

Under qemu-aarch64 on this host, the older compilers give exactly the pinned bytes, so the emulation is not the cause. omc's AArch64 output for these sources changed at `2de46b77` (the VFIO merge): `fclose` now also clears the descriptor from two typed-descriptor tables, 31 instructions. omega-mv did not refresh these pins.

## How it ran

- **Oracle:** omega-mv `6fbc6cbe` `seed/omc/qualify-x86.py` (sha256 `206d6cf2…31ce`) with [`qualify-x86-native.patch`](qualify-x86-native.patch), giving `07746827…aef3`. `seed/omc/x86_corpus_drivers.py` is unchanged (`672cbc99…624b`).
- **The patch:** 117 lines added, 15 removed, and no assertion changed.
  - `--host x86-native` runs the x86 arm's `qemu-x86_64 -0 ARGV0 PROGRAM ARGS` as `PROGRAM ARGS` with the same `argv[0]`.
  - AArch64 programs run under qemu-aarch64, including the AArch64 children the corpus execs itself (conductors, `exec-child` helpers, `memcheck`). The kernel routes them through a binfmt_misc entry that the oracle checks: enabled, flag P to keep `argv[0]`, and no entry that takes x86-64 programs away from the kernel.
  - The ioctl `EMULATOR_ARTIFACT` keeps its reason and classification. For this qemu, its attribution is Ubuntu's `qemu_8.2.2+ds-0ubuntu1.18`: the `linux-user/syscall.c` of the orig tarball, with the package's patch series applied, holds the oracle's excerpt byte for byte at lines 5601-5605.
  - The bridge's AArch64 C driver is built with `aarch64-linux-gnu-gcc`.
  - A fixture that needs more descriptors than the hard limit is BLOCKED, where the run used to crash: a `setrlimit` failure in `preexec_fn` raised an exception the oracle did not catch.
- **Reason strings:** the row reasons keep the oracle's labels. In this mode, "native AArch64" means the AArch64 arm, run under qemu-aarch64. "qemu-x86" and "EMULATED x86" mean the x86-64 arm, run natively.
- **Host:** Intel(R) Xeon(R) Processor @ 2.10GHz, 4 vCPUs, Linux 6.18.44-fc-v310 (a Firecracker VM), Ubuntu 24.04 userland, Python 3.13.18.
  - qemu-aarch64-static 8.2.2 (Debian 1:8.2.2+ds-0ubuntu1.18), sha256 `e4f8d99e…a71e`, through `/usr/lib/binfmt.d/qemu-aarch64.conf` (flags POF).
  - GNU objdump 2.42, and gcc 13.3.0 for x86_64 and aarch64.
  - The run took 20 min 50 s, 14:04:28 to 14:25:18 UTC.
- **Compilers:**

  | Role | sha256 | Made by |
  |---|---|---|
  | omc, `--compiler` | `0f2de851…b02f` | `sh build.sh`, pinned in `seed/PINS.tsv` |
  | omc-x86, `--x86-compiler` | `a855330d…377e` | `sh build.sh`, pinned in `seed/PINS.tsv` |
  | bridge baseline | `734f0a39…6b61` | omega-mv `e17039d9:seed/out/omc` |
  | generation-ceiling variant | `2922680d…a8f9` | the oracle, from omega-mv's own `omc.om` (`062c9649`) with its ceilings set to 3, built by omc |
  | om2 candidates s1 to s4 | absent | their commits are not published |

- **Bridge:** omega-bridge `1958a189`, unmodified.

To reproduce, from this repository on Linux x86-64, as root for the binfmt step:

```sh
apt-get install qemu-user-static gcc-aarch64-linux-gnu libc6-dev-arm64-cross jq xz-utils
cat /usr/lib/binfmt.d/qemu-aarch64.conf > /proc/sys/fs/binfmt_misc/register
sh build.sh
git clone https://rosa.radicle.network/z6do9WDBhuSnvopDkgFdFr1yWA62.git omega-mv
git clone https://rosa.radicle.network/z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y.git omega-bridge
sh evidence/x86-native/run.sh omega-mv omega-bridge work
sh evidence/x86-native/stale-pins.sh work/qualify.jsonl omega-mv
```

If binfmt_misc is not mounted, mount it first: `mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc`. The 48 BLOCKED security673 rows can run only where `/bin/true`, `/bin/echo` and `/bin/tr` are the pinned arm64 builds. That is the package `coreutils_9.4-3ubuntu6.3_arm64.deb` from ports.ubuntu.com; all three files match their pins. Installing them replaces host binaries, so it was not done here.

## Supplementary: the bridge rows with the pin moved

This is not the receipt. [`bridge-repin/`](bridge-repin/) records one more run of the same patched oracle, limited to the 49 bridge rows by [`bridge-rows-only.patch`](bridge-repin/bridge-rows-only.patch). It used a copy of omega-bridge `1958a189` with one line changed, [`tools-native-x86-pin.patch`](bridge-repin/tools-native-x86-pin.patch): `X86_PIN` set to the compiler under test.

All 49 bridge rows PASS: [`20261107-bridge-rows.jsonl.xz`](bridge-repin/20261107-bridge-rows.jsonl.xz), sha256 `500f3792…df10` uncompressed. That covers the C-ABI obligations and the SHA-256 driver, including its three 2^32+3-byte cases. In each row, the natively run x86-64 caller returned exactly what the AArch64 caller under qemu returned, and met the original C driver's own checks. The run's other rows are only what the filter leaves: EXCLUDED and BLOCKED directives recorded while expanding cases, and one FAIL because the `t_exit` control row was filtered out.

## A measurement: x86 code is slow

This is not a correctness failure. omega-mv's SHA-256 (`om/sha256/sha256-om2.om`) was built for both targets with `tools/native`, and `sha256_hash` was timed over 64 MiB of zeros. The AArch64 build under qemu-aarch64 took 1.17 s (57 MB/s). The x86-64 build, running natively, took 3.26 s (20.6 MB/s). The digests are equal, and equal to `sha256sum`'s.

The x86 unit is 164,617 bytes and 27,004 instructions, 65% of them with a memory operand. The AArch64 unit is 21,340 bytes and 5,335 instructions, 22% of them loads or stores. omc keeps the parser's sixteen logical slots in each x86 frame (`seed/omc/omc.om`, the note above `global xtarget`), so nearly every x86 operation loads and stores. Register allocation for the x86 backend is the next step.
