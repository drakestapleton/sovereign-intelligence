# seed/: provenance

Every file here except `PINS.tsv`, `SHA256SUMS`, `LOCAL.patch`, `README.md` and this file is copied byte for byte from omega-mv, the Omega compiler project, and `omc/omc.om` then carries the one local change below:

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

`NOTICE` is checked from omega-mv's root, the rest from its `seed/` directory.

Only the sources needed to grow the compiler are copied. Binaries are not: `build.sh` makes every one of them and checks each against `PINS.tsv`. The seed0, hex1, asm2 and om4 pins equal the binaries omega-mv commits at that commit (`seed/rung0/seed0.bin`, `seed/rung1/hex1.bin`, `seed/rung2/asm2.bin`, `seed/rung4/om4.bin`). `omc-x86` is new: omega-mv has never committed or pinned a native x86-64 omc.

## Local change

`SHA256SUMS` records the files as copied, so it still gives omega-mv's `omc/omc.om`. Since 2026-11-07, `omc/omc.om` here is that file with [`LOCAL.patch`](LOCAL.patch) applied (sha256 `7d802683…91ab`). The `omc` it grows is `0f2de851…b02f`, where omega-mv commits `cfd96b48…0a8d`.

The change: `fma` is refused for x86 (error 9, no FMA3 and no unfused fallback) only after its three operands are typed, where it used to be refused first. An ill-typed `fma` now gets the same error 7 or 11 on every target. The first native x86-64 run of omega-mv's FR-9 corpus found the old order: 8 FAIL rows, `compile refusal differs` on `seed/omc/tests/float/neg_fma_*` ([`../evidence/x86-native/`](../evidence/x86-native/)). AArch64 refusals and AArch64 code are unchanged. [`../tests/regress/`](../tests/regress/) holds one fixture per operand check. Each fails on x86 with the old compiler and passes with this one.

To check the change against omega-mv:

```sh
git -C omega-mv show 6fbc6cbe4bfa4092608e2b5f06d2e8f537893992:seed/omc/omc.om > omc.om.orig
patch -s -o - omc.om.orig seed/LOCAL.patch | cmp - seed/omc/omc.om && echo same
```
