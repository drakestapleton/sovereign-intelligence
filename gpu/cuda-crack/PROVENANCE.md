# gpu/cuda-crack — provenance and status

## Where it came from

cuda-crack, **`rad:z631r2JJiVT8it4tST7RK24hpowi`**, head
**`7e3c9a731d8607ceb60b5a257c8c3652becd544f`** (cloned from
`https://rosa.radicle.network/z631r2JJiVT8it4tST7RK24hpowi.git`; the cloned HEAD
equalled this commit). "I broke CUDA": the GB10 sm_121 machine-code encoder, its
forms table, and the host check that rebuilds the chip kernels from the table alone.

## What was imported, byte-for-byte

Imported under this directory keeping cuda-crack's own layout, so its scripts'
relative paths resolve when run with this directory as the working directory:

| path | role | imported? |
|---|---|---|
| `gen/bw_enc_sm121.om` | Omega: BlackwellIR → sm_121 bytes encoder (library) | imported |
| `gen/isa.om` | Omega: probes the encoder, emits the forms table | imported |
| `gen/run.sh` | shell: regenerates the table (pin-checked) | imported (see gaps) |
| `check/reencode.om` | Omega: rebuild a kernel from the table; D-vs-F check | imported |
| `check/check.sh` | shell: the host check (70 kernels + 4 mutant controls) | imported (see gaps) |
| `check/CHECK.txt` | expected `check.sh` output | imported |
| `isa/sm121-forms.txt` | the forms table (data) | imported |
| `isa/README.md` | the table format | imported |
| `receipts/.../chip-20261027T080240Z/kernels-om/*.bin` | the 70 chip kernels (data the check rebuilds) | imported |
| `receipts/.../kernels-om.sha256` | the kernel manifest | imported |
| `check/tblmut.om` | **new**: seeded-Omega rewrite of `check.sh`'s mutant-3 transform | stack-authored |

Integrity is pinned in `gpu/cuda-crack/SHA256SUMS`. Two independent byte-for-byte
confirmations were made at import: the 70 kernels reproduce
`kernels-om.sha256` exactly, and `isa/sm121-forms.txt` is sha256
`587d81e2bc8b3dc6fdb48d477a76b717300732ccdb984f05f5b3df658e58e2d7`
(the value its own header records).

**Not vendored** (not needed for the host checks here; pinned by the RID+head above):
the rest of cuda-crack's `receipts/` evidence tree, `FIELD-MANUAL.md`, `LEGAL.md`,
`replicate.sh` (a network orchestrator that clones every project over HTTPS), and
`tests/agent-gate.sh` (a unit test of `replicate.sh`'s argument parser).

## How it is wired into the build

`build.sh` step 5 runs the check on **both** seed-born targets:

- **x86-64 (native):** cuda-crack's own `check/check.sh`, verbatim, with `OMC` set
  to a wrapper that emits native x86 (`target x86linux` + `out/omc-x86`). It prints
  `ALL CHECKS PASS`: the 70 kernels rebuild byte-for-byte and all four of its mutant
  negative controls are caught.
- **AArch64 (under `qemu-aarch64-static`):** `check/reencode.om`, compiled by
  `out/omc`, reproduces all 70 kernels byte-for-byte and the D-vs-F consistency
  check passes.
- **Negative control, both targets:** `check/tblmut.om` (below) mutates the table
  and the mutated table must make `reencode` refuse (exit 7).
- **GPU execution** (`hello-gpu`, the on-chip corpus, the GEMM/attention workloads)
  is **NOT_RUN**: it needs an NVIDIA GB10 and driver 580.173.02, which this host does
  not have, and lives in CUDApp, not here. The in-repo GPU receipts are verified as
  artifacts, not re-run. NOT_RUN is never reported as PASS.

## Seeded-Omega rewrite of the shell (and the differential test)

`check/tblmut.om` is a seeded-Omega rewrite of the one self-contained text transform
in `check/check.sh` — its "mutant 3" control:

```
awk 'd==0 && $1=="D" && $8>1 {$8=$8-1; d=1} {print}'
```

It reads the table on stdin, finds the first `D` record whose width field is > 1,
reduces it by one, and prints the table otherwise unchanged. **Differential test
(run in `build.sh` step 5, both targets):** `tblmut.om`'s output is compared
byte-for-byte against the awk original; they are identical on AArch64 and x86-64,
and the Omega-produced table drives `reencode` to exit 7 on both. The awk one-liner
is retained only as the differential oracle.

## Compiler tasks (gaps found; not routed around)

Per the stack rule, where the seed Omega subset cannot yet express a shell script's
work, the gap is recorded here as a compiler task rather than worked around in another
language. `check/check.sh` and `gen/run.sh` therefore remain shell for now; a full
in-Omega port (`check/verify.om`: read the table, parse the `kernels-om.sha256`
manifest for the 70 names, read each kernel, run the reencode algorithm in-process,
and byte-compare — needing none of sha256/readdir/subprocess) is feasible and tracked.

- **CT-1 — directory enumeration.** The seed host words include `fopen/read/stat/
  makedir/unlink/cwd` but no `opendir`/`readdir`. `check.sh`'s `for k in
  kernels-om/*.bin` cannot be expressed directly. (Avoidable here by reading the
  70 names from `kernels-om.sha256`, but the absence is a real gap.)
- **CT-2 — sha256 as a language word.** `check.sh` and `gen/run.sh` digest with
  `sha256sum`. omega-mv ships an AArch64 sha256 *unit* but the seed language exposes
  no sha256 host word, so an Omega program cannot reproduce the digests. (The kernel
  check needs only byte-equality, which Omega does; `gen/run.sh`'s table-sha pin
  genuinely needs CT-2.)
- **CT-3 — subprocess under emulation.** `fork`/`pipefds`/`execprog` exist, but a
  driver that spawns the separately-compiled `reencode` was not validated — nested
  exec of an AArch64 target binary under `qemu-user` is unverified here. A single
  program embedding the reencode algorithm (the `check/verify.om` above) avoids this.
- **CT-4 — AArch64 register allocation is tighter than x86.** `check/tblmut.om`'s
  integer-parse line `v = add mul v 10 ulong sub get inb p 48` compiled cleanly for
  `target x86linux` but raised `error 12` (too many registers) on the default AArch64
  backend; factoring into a helper and splitting the expression fixed it. The two
  backends should accept the same source. Minimal repro and the fix are in the commit
  history of `check/tblmut.om`. This is the kind of "make the next compiler better"
  item the stack exists to surface.

## `gen/run.sh` and the omc pin

`gen/run.sh` hard-pins the *generating* compiler to omc sha256
`3ad9f10f…` (a historical omc). The seed-born omc vendored here is
`cfd96b48…`, so `gen/run.sh` would abort on the pin before regenerating — by design:
regeneration is a consistency check, and the committed `isa/sm121-forms.txt` is the
authoritative table, which `check/check.sh` verifies against the chip kernels. The
build therefore checks the table, it does not regenerate it.
