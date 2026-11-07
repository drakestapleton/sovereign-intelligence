# seed/: provenance

Every file here except `PINS.tsv`, `SHA256SUMS`, `README.md` and this file is copied byte for byte from omega-mv, the Omega compiler project:

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

Only the sources needed to grow the compiler are copied. Binaries are not: `build.sh` makes every one of them and checks each against `PINS.tsv`. The pins equal the binaries omega-mv commits at that commit (`seed/rung0/seed0.bin`, `seed/rung1/hex1.bin`, `seed/rung2/asm2.bin`, `seed/rung4/om4.bin`, `seed/out/omc`). `omc-x86` is new: omega-mv has never committed or pinned a native x86-64 omc.
