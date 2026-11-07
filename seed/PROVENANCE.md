# seed/: provenance

Every file here except `PINS.tsv`, `SHA256SUMS`, `LOCAL.patch`, `README.md` and this file is copied byte for byte from omega-mv, the Omega compiler project. `omc/omc.om` then carries the two local changes [below](#local-changes):

| | |
|---|---|
| Project | omega-mv, `rad:z6do9WDBhuSnvopDkgFdFr1yWA62` |
| Commit | `6fbc6cbe4bfa4092608e2b5f06d2e8f537893992` (2026-11-07 06:22 -0600, head of `main`) |
| Fetched | 2026-11-07, `git clone https://rosa.radicle.network/z6do9WDBhuSnvopDkgFdFr1yWA62.git`, head checked against the seed's `/api/v1/repos` answer |
| Licence | Apache License 2.0, as this repository; omega-mv's `NOTICE` is kept as `seed/NOTICE` |

The paths are the same as in omega-mv. `SHA256SUMS` lists the sha256 of every copied file. To audit the copy against omega-mv:

```sh
git -C omega-mv checkout 6fbc6cbe4bfa4092608e2b5f06d2e8f537893992
(cd omega-mv/seed && sha256sum -c ../../sovereign-intelligence/seed/SHA256SUMS)
```

`NOTICE` is checked from omega-mv's root, the rest from its `seed/` directory. `SHA256SUMS` records the files as copied, so every line passes there, `omc/omc.om` included: it gives omega-mv's `omc/omc.om` (sha256 `062c9649af6a1d499b911e5b2f39b5419d7b75047616fe59fbcdc25f7b7b5b73`, the file of this repository's first commit `3e3116f`), not the changed one here. [`LOCAL.patch`](LOCAL.patch) turns the one into the other.

Only the sources needed to grow the compiler are copied. Binaries are not: `build.sh` makes every one of them and checks each against `PINS.tsv`. The pins of `seed0.bin`, `hex1.bin`, `asm2.bin` and `om4.bin` equal the binaries omega-mv commits at that commit (`seed/rung0/seed0.bin`, `seed/rung1/hex1.bin`, `seed/rung2/asm2.bin`, `seed/rung4/om4.bin`). The pins of `omc` and `omc-x86` are those of the changed `omc/omc.om`; omega-mv's `seed/out/omc` is the earlier pin, below. `omc-x86` is new: omega-mv has never committed or pinned a native x86-64 omc.

## Local changes

`omc/omc.om` here is omega-mv `6fbc6cbe`'s with [`LOCAL.patch`](LOCAL.patch) applied: 218 lines added and 6 removed, in two changes, each merged from its own pull request. Each is below.

| | omega-mv `6fbc6cbe` | here |
|---|---|---|
| `omc/omc.om` sha256 | `062c9649af6a1d499b911e5b2f39b5419d7b75047616fe59fbcdc25f7b7b5b73` | `877a22dd7e802002849e715ca0410400216cc88ecd62f9e94b49ec004f445c4f` |
| `omc` pin | 660940 bytes, `cfd96b48b0460ab5557853d6856f9c741b96ac8d0d624e06198defb4cbfa0d8a` | 673376 bytes, `45442c7d517fd605507bda5d1ec52493ff182661301cda69a95fc4f77dc6080d` |
| `omc-x86` pin | 5081428 bytes, `5287a5aac3e2c5d372fadd6b04a038fbe1278d4c3673650796d178b1f90dba46` | 5175010 bytes, `5e1f6e1f511850f3a5c31000ebc1845ad3b317b7f48d4726c7b0d7d781093f19` |

To check the changes against omega-mv:

```sh
git -C omega-mv show 6fbc6cbe4bfa4092608e2b5f06d2e8f537893992:seed/omc/omc.om > omc.om.orig
patch -s -o - omc.om.orig seed/LOCAL.patch | cmp - seed/omc/omc.om && echo same
```

### 1. `count`, a checked bulk word (GitHub #2)

The OM-2 value word `count A off n v`, the number of `uchar` elements of `A[off, off+n)` equal to `v`, checked as `read` and `write` check their slices (trap 3). It replaces the byte-at-a-time loop in which `tools/ledger.om` spent almost all its time: omc-x86 keeps every name in a stack slot, so that loop costs 37 x86-64 instructions per byte, and its loop variable makes two store-to-load round trips per pass. Its contract, refusals and examples are in [`../tests/omc/README.md`](../tests/omc/README.md).

It has five parts:

1. `kw2`, the OM-2 keyword table: `count` (packed `500069396323`) is code 179, a code no other word uses. Like every `kw2` word it is reserved only in an OM-2 unit, so no OM-1 unit, `omc.om` among them, changes meaning. The two-line note above `kw2` names it.
2. `rdval`: code 179 calls `cnt_word` (4 lines, before `get`).
3. `cnt_word` (new): reads `A` (`arrname`; `fz_arg`, so a tracked `fresh` array is error 27; a struct or layout is error 7), `off` and `n` as `ulong`, `v` as `uchar`, then calls `vs_chk`, the slice check of `read` and `write`, unchanged, so a non-`uchar` array is error 7 and an out-of-bounds slice traps 3 before any element is read. Then it calls `cnt_a64` or `xcount` and moves the count to the destination once the temporaries are given back.
4. `cnt_a64` (new): the AArch64 loop, 16 bytes per pass in NEON (`LD1`, `CMEQ`, `SUB`), the lanes summed by `UADDLV` every 255 passes, the last 0..15 bytes with `LDRB` and `CINC`. Four new pool temporaries; no name's register is written.
5. `xcount` (new): the same loop for x86-64 in SSE2 (`MOVDQU`, `PCMPEQB`, `PSUBB`, `PSADBW`), 128 fixed bytes after four setup moves; `target x86efi` takes the same code.

Every machine word and byte was checked against llvm-mc 18 and disassembled from a compiled program on both targets. What changes and what does not:

- **The seed chain still closes.** om4 builds the changed `omc.om` (it stays in om4's subset), and stage1 = stage2 = stage3. omc-x86 rebuilds itself byte for byte, and omc-x86 compiling `omc.om` gives exactly the AArch64 `omc` (diverse double compilation). `build.sh` checks all of it against the pins above.
- **Every unit that does not use `count` compiles to the same bytes as before.** Checked on 2026-11-07 with the old and new pins, on both targets: the 110 harness examples, `compiler/si.om`, `tools/ledger.om` as it was before it used `count`, and `omc/omc.om` itself, 226 compiles, all byte-identical.
- **Trap semantics are exact.** `count` traps 3 exactly when `n > len A` or `off > len A - n`, never otherwise; `off + n` is never formed. `build.sh` step 11 deletes the one `vs_chk` call of `cnt_word` and requires the resulting compiler to fail `count_trap3` and `count_trap3_wrap` on every target that runs, while `count_word` still passes.
- **Not run:** a `target x86efi` program using `count` compiles to a PE image holding the same 128-byte loop, but no UEFI firmware was run here.

Measured on 2026-11-07, on a 4-vCPU x86-64 host (Intel Xeon, 2.30 GHz), page cache warm, the median of 9 interleaved runs each: the stack ledger over the 44 checkouts of `stack/STACK.tsv` (cloned from `https://rosa.radicle.network/<rid>.git` at the listed heads; 68,575 files, 954,659,395 bytes, listed as `tools/ledger-refresh.sh` lists them) took 2.05 s built by the old omc-x86 and 0.34 s built by this one, 6.1 times faster. User time fell from 1.79 s to 0.12 s; the rest is the kernel opening and reading the files. A Python 3 oracle that prints the same table byte for byte (`bytes.count`) took 0.58 s. All three outputs were byte-identical to `stack/LEDGER.tsv`. An earlier measurement the same day on another 4-vCPU x86-64 host gave 3.33 s for the old ledger and 1.25 s for Python; this host is faster, so compare ratios, not seconds.

### 2. `fma`'s refusal order on x86 (GitHub #4)

`fma` is refused for x86 (error 9, no FMA3 and no unfused fallback) only after its three operands are typed, where it used to be refused first. An ill-typed `fma` now gets the same error 7 or 11 on every target. The first native x86-64 run of omega-mv's FR-9 corpus found the old order: 8 FAIL rows, `compile refusal differs` on `seed/omc/tests/float/neg_fma_*` ([`../evidence/x86-native/`](../evidence/x86-native/)). AArch64 refusals and AArch64 code are unchanged. [`../tests/regress/`](../tests/regress/) holds one fixture per operand check. Each fails on x86 with the old compiler and passes with this one. That corpus run used the compiler with this change alone (`omc` `0f2de851…b02f`), before `count` was merged.

### Both together

The two changes touch different functions of `omc.om` (`count`: `kw2`, `rdval` and three new functions; `fma`: `ffma`). Checked on 2026-11-07 on an x86-64 host, the AArch64 side under qemu-aarch64 8.2.2: 136 units (every harness example, `tests/omc`, `tests/regress`, `compiler/si.om`, `tools/ledger.om`, `tools/forkpush.om`, the three cuda-crack programs and `omc.om` itself), each compiled for both targets, 272 compiles. The merged compiler gives the same output bytes, exit status and refusal line as the compiler with `count` alone in every compile but the 3 `tests/regress` fixtures on x86, which now get error 7 or 11 where that compiler gives 9. It gives the same as the compiler with the `fma` change alone in every compile but those of the 17 units that use `count` (the 16 `tests/omc` examples and `tools/ledger.om`), which that compiler refuses.
