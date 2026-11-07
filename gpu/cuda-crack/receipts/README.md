# Receipts

Every file is copied unchanged from a public Radicle repository at the commit named below, with two exceptions:

- A home-directory path was redacted in `live-serve-no-cuda.txt`. `REDACTION.txt` gives both sha256 values.
- The 70 files `cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/kernels-om/*.bin` are not in CUDApp. The Omega-encoder build wrote them during the E2/E3 chip run on the GB10 on 2026-10-27; the directory is stamped 08:03 UTC, and the run's tree head was `010abb1549c48a4be6d63da47101d393f76cb2dd`. I copied them from my local run directory. CUDApp `b774723f` commits only their sha256 list, `kernels-om.sha256`, which is identical to `kernels-c.sha256` from the C encoder. Their sha256 match that list, and `check/check.sh` relies on it.

`SHA256SUMS` covers every file here: `cd receipts && sha256sum -c SHA256SUMS`.

| Claim | Path | Source |
|---|---|---|
| E1 (DEPLOYED 2026-10-21, zero CUDA libraries mapped; C stack) | `omega-mv/evidence/WHAT-OMEGA-IS-20261021/` | omega-mv `rad:z6do9WDBhuSnvopDkgFdFr1yWA62` @ `943d955531b9d4d9f70deb41756c0b46441dd5e0` |
| E2, E3, E8, F10, F14 (Omega encoder on the GB10; 70 kernels; doctor) | `cudapp/evidence/CUDAPP-OM-ENCODER/` | CUDApp `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` @ `b774723f537cec16a359fe082b8100317a5b5490` (chip tree head `010abb1549c48a4be6d63da47101d393f76cb2dd`). The `kernels-om/*.bin` files are my Omega encoder's output; their sha256 match `kernels-om.sha256`. |
| E6 (seed-assembled vector add on the GB10; source tree had 3 uncommitted files) | `omega-mv/evidence/SEED-0/sm121/chip/` | omega-mv @ `943d9555` |
| E9, F29 (9 FP32 ops × 2^32 inputs, 0 mismatches; parity, not correct rounding) | `omega-mv/evidence/E1-TRANSC-GB10/` | omega-mv @ `943d9555` |
| E10 (GEMM 902 checks; attention 318/318; not a qualification) | `cudapp/evidence/GEMM-GENERAL-00c9cf9/`, `cudapp/evidence/ATTN-GENERAL-20261027-4d51f91f/`, `cudapp/evidence/GEMM-TUNE-20261027/` | CUDApp @ `b774723f` |
| F17 (launch cost; r2 PASS run only) | `cudapp/evidence/OWN30B-LAUNCH-COST-20261014T0120Z/r2/receipt.json` | CUDApp @ `b774723f` |
| Speculation kernel receipt (context only, not a headline) | `cudapp/evidence/speculation/native-kernel/receipt.json` | CUDApp @ `b774723f` |

Not here: the Omega-lowered chip kernels and the 35B gate-kernel results are on unmerged draft branches and are not public yet. The receipts marked RECEIPT PENDING in `FIELD-MANUAL.md` are not attached yet.
