# RM10 Compiler Trust Evidence: Diverse Double Compilation (#650) & Branch Displacement Extremes (#669)

Evidence status: **`HOST_VERIFIED`** (DGX Spark Linux AArch64, Grace CPU, unified `seed/out/omc` sha256 `85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134`). Pure seeded Omega (`seed/ddc/gate_ddc.om` and `seed/ddc/gate_bdisp.om`) with zero C, Python, or shell on the verification path.

---

## 1. Diverse Double Compilation (`#650`) — `seed/ddc/gate_ddc.om`

David A. Wheeler's Diverse Double Compilation (DDC) test verifies that a self-hosted compiler binary `c` corresponds to its audited source code `s_C` (and does not harbor a binary-only *Trusting Trust* implant) by compiling `s_C` with a second, diverse compiler `T` to produce `c_1 = T(s_C)`, then compiling `s_C` with `c_1` to produce `c_2 = c_1(s_C)`, and asserting **byte-for-byte identity** `c_2 == c`.

### Build and Run (Linux AArch64)

```sh
{ printf 'om2\n'; cat seed/ng/sha256.om seed/ddc/gate_ddc.om; } | seed/out/omc > /tmp/gate_ddc
chmod +x /tmp/gate_ddc
/tmp/gate_ddc . /path/to/ng /tmp/ddc_scratch          # PASS (exit 0)
/tmp/gate_ddc . /path/to/ng /tmp/ddc_wrong wrong      # FAIL-CLOSED control (exit 60)
```

### Three Verified Diverse Paths on `seed/omc/omc.om`

Source under test: `seed/omc/omc.om` (`sha256 = 83965aef702718c3f248dbd5e640553d9a5d04e691812820477744886de5603e`).
Pinned target binary: `seed/out/omc.sha256` (`85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134`).

| Path | Stage-1 Compiler Toolchain | Stage-1 Binary (`bytes`, `sha256`) | Stage-2 `stage1(omc.om)` (`bytes`, `sha256`) |
|---|---|---|---|
| **Path A (Cold Seed)** | `seed0.hex` (408 B) -> `hex1` (776 B) -> `asm2` (2,464 B) -> `om4.bin` (16,200 B) | `omc_stage1` (`1,012,856 B`, `85b84c6d...f23134`) | `omc_A` == `omc_A2` (`1,012,856 B`, `85b84c6d...f23134`) |
| **Path B1 (NG Default)** | `ng` (`@ng front-ir` -> `@ng a64`, STP/LDP register-allocating SSA backend) | `omc_by_ng` (`579,936 B`, `7e4957cb...5915d9`) | `omc_B1` (`1,012,856 B`, `85b84c6d...f23134`) |
| **Path B2 (NG Opt + Split)** | `ng` (`@ng front-ir` -> `@ng opt` -> `@ng a64 split`, loop-opt + STR/LDR saves) | `omc_by_ng_opt` (`552,792 B`, `a171df5d...7acc95`) | `omc_B2` (`1,012,856 B`, `85b84c6d...f23134`) |

All three Stage-1 compiler executables are genuinely distinct AArch64 binaries (`1,012,856 B` vs `579,936 B` vs `552,792 B`, three different SHA-256 digests), yet compiling `seed/omc/omc.om` with each produces **byte-for-byte identical** `1,012,856`-byte output matching `seed/out/omc.sha256`.

### Measured Spark Digests (`/tmp/om_sw_si10_unified/run1/scr_ddc`)

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| `seed0.bin` (pure-Omega decoder == `load0.sh`) | 408 | `aca00cf3677236809f0f223437398c6bb429e4c65f13d58762bcf96d13799474` |
| `hex1.bin` | 776 | `920e1756aec399c7c74f5cedd1676abb91b844ea75448e14aa50dcb0bbc7ba5d` |
| `asm2.bin` | 2,464 | `6988abe072fac3cdef2240d5ad13a3ecd8fb576fa09112d344b9e7c2315969c4` |
| `om4.bin` (`audit2.sh`: 3560 insns, 1960 data B, **0 mismatches**) | 16,200 | `69c30a419c7d6dc6ed34266159bdc90d27ad98a76ac88b833ac002fa00f4bb77` |
| `omc_stage1` (Path A, `om4`) | 1,012,856 | `85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134` |
| `omc_by_ng` (Path B1, `ng a64`) | 579,936 | `7e4957cb4eb8852666d7e2be098b6d26defdf765d9a6b86067f873d27a5915d9` |
| `omc_by_ng_opt` (Path B2, `ng opt + a64 split`) | 552,792 | `a171df5d3f24aa7b1fea12247afeb16f94ddd03269304799ba80a522877acc95` |
| `omc_A`, `omc_A2`, `omc_B1`, `omc_B2` (final fixpoint) | 1,012,856 | `85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134` |
| `omc_B_trojan` (NC1 planted `EI_ABIVERSION=1` implant, caught!) | 1,012,856 | `dd08d34fa79341d21b2dd5d13af4a3f3b194aff87d0dcd55d05b4c901ee00eeb` |

### Planted Trusting-Trust Miscompile Negative Controls

1. **NC1 (Planted Compiler Implant):** `gate_ddc.om` copies `seed/omc/omc.om` to `SCRATCH/omc_planted.om` (never mutating the repository), splices a 1-line `wrword 8 1` (`EI_ABIVERSION=1`) watermark right after `wrword 4 65794`, compiles it via `ng` into `SCRATCH/omc_trojan`, and compiles clean `seed/omc/omc.om` with `omc_trojan` -> `omc_B_trojan` (exit 0, valid runnable ELF of identical size `1,012,856 B`). Both SHA-256 and byte comparison immediately detect the divergence (`dd08d34f... != 85b84c6d...`).
2. **NC2 (1-Bit Binary Flip):** Flipping 1 bit at byte offset 200 of `omc_B1` is caught by SHA-256 comparison.
3. **CLI `wrong` Control:** Running `gate_ddc REPO NG SCRATCH wrong` substitutes `omc_B_trojan` into the primary Path B comparison; the gate fails closed with `DDC-GATE FAIL step=60` (exit 60).

### Honest Independence & Trusted Computing Base (TCB) Boundary

**What IS genuinely independent between Path A and Path B:**
- **Compiler source & architecture:** Path A compiles `omc.om` through `seed/rung4/om4.s` (a 16 KiB handwritten single-pass AArch64 assembler/compiler), while Path B1/B2 compiles `omc.om` through `seed/ng/src/{ir,front,opt,a64,main}.om` (an independently written multi-stage compiler with ΩIR SSA lowering, preheader/PHI/BCE/LICM/rotation optimizer, and register-allocating AArch64 backend). Path A and Path B share zero compiler source code.
- **Intermediate compiler machine code:** `omc_stage1` (`1,013 KB`), `omc_by_ng` (`580 KB`), and `omc_by_ng_opt` (`553 KB`) have completely different instruction sequences, register allocations, calling prologues (`STP`/`LDP` vs `STR`/`LDR`), and code layouts.
- **External instruction referee:** `seed/check/audit2.sh` uses GNU `objdump -M no-aliases` (external C toolchain, never on the build path) to independently decode and verify all 3,560 instructions of `om4.bin` against `seed/rung4/om4.s` with `mismatch=0`.

**What IS STILL SHARED (explicit TCB disclosures — never overclaimed):**
- **Host compiler that built `ng`:** On this single host, the `ng` binary (`682836c2...`) was itself built from `seed/ng/ng.units` using `omc`. Consequently, this test rules out any binary-only implant targeting `omc.om` (or any miscompile in either `om4` or `ng`), whereas a hypothetical dual-targeted implant inside `omc` that simultaneously recognized and subverted *both* `omc.om` *and* `seed/ng/src/{front,a64}.om` would require building `ng` with a completely foreign compiler/architecture outside this host.
- **Host hardware and kernel:** Both paths execute on the same DGX Spark Linux AArch64 kernel and Grace CPU.
- **Source code `seed/omc/omc.om`:** DDC proves that the binary `seed/out/omc` faithfully corresponds to `seed/omc/omc.om`; it does not by itself prove `omc.om` is free of source-level bugs (which are covered by `seed/host/check.sh`, `seed/qualification/`, and `#669` below).

---

## 2. Branch Displacement Extremes (`#669`) — `seed/ddc/gate_bdisp.om`

In `seed/omc/omc.om`, `fn bdisp` checks every AArch64 branch offset before patching or emitting:
- `w = 19` (`B.cond`, `CBZ`, `CBNZ`, `B.AL` for `break`/`continue`, `B.LO`/`B.LT` for OM-2 `lpback`): signed 19-bit word offset `[-1,048,576, +1,048,572]` bytes (`[-262,144, +262,143]` words), else **`error 24`**.
- `w = 26` (`else` skip `B`, `while`/`for` latch `B`, `BL`, trap `island` skip `B`): signed 26-bit word offset `[-134,217,728, +134,217,724]` bytes, else **`error 24`**.

### Build and Run (Linux AArch64)

```sh
seed/out/omc < seed/ddc/gate_bdisp.om > /tmp/gate_bdisp
chmod +x /tmp/gate_bdisp
/tmp/gate_bdisp seed/out/omc /tmp/bdisp_scratch       # PASS (exit 0)
/tmp/gate_bdisp seed/out/omc /tmp/bdisp_wrong wrong   # FAIL-CLOSED control (exit 3)
```

### Verified Boundary Matrix (15 Cases + 2 Negative Controls + `wrong` CLI Control)

| Case | Branch Form | Width | Body Size (`x = add x 1`) | Expected | Verified Result |
|---|---|---|---:|---|---|
| `c01` | `if` `B.cond` (taken) | `imm19` | `262,142` (`+1,048,572 B` exact max) | compile 0, exit `254` | PASS |
| `c02` | `if` `B.cond` (skipped) | `imm19` | `262,142` (`+1,048,572 B` exact max) | compile 0, exit `77` | PASS |
| `c03` | `if` `B.cond` (+1 insn over) | `imm19` | `262,143` (`+1,048,576 B`) | **refused `error 24`** | PASS |
| `c04` | `if` `CBZ` bool var (true) | `imm19` | `262,142` (`+1,048,572 B` exact max) | compile 0, exit `254` | PASS |
| `c05` | `if` `CBZ` bool var (false) | `imm19` | `262,142` (`+1,048,572 B` exact max) | compile 0, exit `55` | PASS |
| `c06` | `if` `CBZ` (+1 insn over) | `imm19` | `262,143` (`+1,048,576 B`) | **refused `error 24`** | PASS |
| `c07` | `else` `B` (`if` taken, jumps >1.2 MiB) | `imm26` | `300,000` (`1,200,000 B`) | compile 0, exit `43` | PASS |
| `c08` | `else` `B` (`else` taken, runs >1.2 MiB) | `imm26` | `300,000` (`1,200,000 B`) | compile 0, exit `224` | PASS |
| `c09` | `while` (head + bound-trap) exact max | `imm19` | `262,135` | compile 0, exit `247` | PASS |
| `c10` | `while` (+1 insn over bound-trap `B.HS`) | `imm19` | `262,136` | **refused `error 24`** | PASS |
| `c11` | `while` backward `continue` + forward `break` + latch `B` | `imm19`+`imm26` | `250,000` (`~1.0 MiB`) | compile 0, exit `39` | PASS |
| `c12` | OM-2 `for` `lpback` backward `B.LO` exact max | `imm19` | `262,139` (2 iters) | compile 0, exit `246` | PASS |
| `c13` | OM-2 `for` (+1 insn over) | `imm19` | `262,140` | **refused `error 24`** | PASS |
| `c14` | OM-1 `for` over `imm19` | `imm19` | `262,200` | **refused `error 24`** | PASS |
| `c15` | `fn` `BL` backward & forward >1.2 MiB + trap `island` `B` | `imm26` | 2 x `300,000` spacers | compile 0, exit `17` | PASS |

Additional binary/negative checks inside `gate_bdisp.om`:
- **Independent AArch64 `B.cond` decoder audit:** reads compiled `c02.bin` ELF code `[176, n)` word-by-word, verifies every `B.cond` target stays strictly within `[176, n)`, and confirms the emitted forward branch carries exact architectural maximum `imm19 == 262,143` (`+1,048,572 B`).
- **NC1 (Corrupted displacement):** mutating `imm19` to `0x40000` (`-1,048,576 B`, underflowing below ELF code start `176`) is caught fail-closed by `bd_audit_bcond`.
- **NC2 (Runtime wrong-exit check):** verifies `c02.bin` (`exit 77`) fails comparison against deliberately wrong expectation `78`.
- **CLI `wrong` Control:** `gate_bdisp OMC SCRATCH wrong` inverts `c03`'s `error 24` expectation and fails closed with `BDISP-GATE FAIL check=3` (exit 3).
