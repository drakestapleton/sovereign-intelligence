# out/ — the seed-born Omega toolchain

Two compilers, both born from the Omega seed in **omega-mv**
(`rad:z6do9WDBhuSnvopDkgFdFr1yWA62`, commit `6fbc6cbe4bfa4092608e2b5f06d2e8f537893992`).
This repository pins that commit and the `sha256` of the `omc` it births, the
child-repo pin pattern described in omega-mv's README.

| file | what | target | how it runs on x86 |
|---|---|---|---|
| `omc` | seed-born compiler | AArch64 static ELF | under `qemu-aarch64-static` |
| `omc-x86` | same compiler, native host build | x86-64 static ELF | natively |
| `omc.om` | the compiler's own source | — | input to the fixpoint |

## Birth and verification
- Upstream births `omc` from the 408-byte `seed0` by `sh seed/omega-from-seed.sh`
  (`seed0 -> hex1 -> asm2 -> om4 -> omc`), AArch64 Linux, static ELF.
  `sha256(omc) = cfd96b48b0460ab5557853d6856f9c741b96ac8d0d624e06198defb4cbfa0d8a`.
- `omc-x86` is produced by compiling `omc.om` with its exact first line set to
  `target x86linux` through `omc`; the result is a native x86-64 static ELF.
- **Self-hosting fixpoint (re-verified here):** `omc` compiling `omc.om`
  reproduces `omc` byte-for-byte. Receipt: `evidence/foundation/fixpoint.txt`.
- Honest limit: omega-mv labels the x86 backend DRAFT and native x86
  qualification NOT_RUN (its CI exercised x86 only under QEMU). Here `omc-x86`
  is built and run natively, but it inherits that DRAFT status; `build.sh`
  cross-checks the two targets against each other rather than asserting an
  independent x86 qualification.

Invocation convention: `omc < source.om > out.elf; chmod +x out.elf; ./out.elf`.
For x86 output the source's exact first line must be `target x86linux`.
