# Sovereign Intelligence 1.0 — Master Cryptographically-Pinned Receipt Index

> **Status:** `HOST_VERIFIED` / `HOST_THERMAL_LIVE` / `EXERCISED_EMULATED` unified software stage under **Big-Bang 1.0 HOLD**.
> **Policy:** Host, QEMU, and single-machine runs are never relabeled as multi-machine or physical silicon qualification. Every commit SHA, binary SHA-256, and Lean 4 proof digest below was independently reproduced on DGX Spark (Linux AArch64) and Apple M2 macOS (where explicitly labeled) with zero telemetry and zero UEFI/SPI writes.

---

## 1. Pinned Repository Commits & Unified Compiler Anchor

| Component / Repository | Branch / Ref | Pinned Commit SHA | Evidence Class |
|---|---|---|---|
| `omega-mv` (unified 1.0 stage) | `main (unified Sovereign Intelligence 1.0)` (28 commits over `origin/main` `0cc2aff79d4818f9d87711b5b062f3cf908be687`) | `1041e9a36391a1399fc9c7f7ccb98b2bfcd47405` | `HOST_VERIFIED` + `HOST_THERMAL_LIVE` + `EXERCISED_EMULATED` |
| `omega-seats` (`SCM_RIGHTS` Wayland) | `main` | `d1c62a5cf1b9a72091671490d1eba4c5953b2aa0` | `HOST_VERIFIED` (Spark AArch64) + `EXERCISED_EMULATED` (`qemu-x86_64`) |
| `omega-helix` (editable `spclip` + macOS) | `main` (fast-forwardable onto `a909888a`) | `8551f0c4cf7d3ef2191aacbae2dfe693e90ac260` | `HOST_VERIFIED` (Apple M2 + Metal, Spark CPU) + `EXERCISED_EMULATED` (`qemu-x86_64`) |
| `aienos.com` | `main` | `060247aaa75782a69a28a6bb5f700875c21cadec` | `HOST_VERIFIED` (zero-JS / build-checked site) |
| `interplane.io` | `main` | `589f5854f350d653274af8dfa266232bf0832fbb` | `HOST_VERIFIED` (zero-JS CSP / edge-mirror checked) |

### Unified Compiler & Bootstrap Digests (Cold 408 B `seed0.hex` + 3-Path Wheeler DDC)

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| `seed/out/omc` (unified 1.0 pin, 2x fixpoint) | `1,012,856` | `85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134` |
| `seed/omc/omc.om` (audited compiler source) | `621,789` | `83965aef702718c3f248dbd5e640553d9a5d04e691812820477744886de5603e` |
| `ng` (built from unified 15-unit `seed/ng/ng.units`, 2x bit-identical) | — | `682836c26229e76466851e340bbad9c8f8742d9adf90f317a400cccf5d0d3cd4` |
| DDC Stage-1 Path A (`om4`) | `1,012,856` | `85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134` |
| DDC Stage-1 Path B1 (`ng a64`) | `579,936` | `7e4957cb4eb8852666d7e2be098b6d26defdf765d9a6b86067f873d27a5915d9` |
| DDC Stage-1 Path B2 (`ng opt + a64 split`) | `552,792` | `a171df5d3f24aa7b1fea12247afeb16f94ddd03269304799ba80a522877acc95` |
| DDC NC1 Planted Trusting-Trust Trojan (`omc_B_trojan`, CAUGHT) | `1,012,856` | `dd08d34fa79341d21b2dd5d13af4a3f3b194aff87d0dcd55d05b4c901ee00eeb` |

---

## 2. Formal Lean 4 Proofs (4 / 4 PASS, `0 sorry`, `0 sorryAx`, Standard Axioms Only)

Verified on DGX Spark with standalone `~/.elan/bin/lean` (`Lean 4.36.0`):

| Lean 4 Proof File (`omega-mv` `1041e9a36`) | SHA-256 | Scope | Result |
|---|---|---|---|
| `seed/helix/proofs/NgEGraphIR.lean` | `a7acc02e15db1023e18bc15d6412e6f2b8f3d828fe7a6b098eed5e923db34763` | 32-bit & 64-bit ΩIR E-graph rewrite soundness + unsound-rule counterexamples | **PASS (`0 sorry`)** |
| `seed/helix/proofs/Antibody17.lean` | `c0629273a5d6f744fb9b57adfd058282d0cf08d28c297c9ff37bb59fe4584daa` | Antibody `#17a–#17d` SM121 RAW/MMA-floor/anchor/multi-barrier soundness | **PASS (`0 sorry`)** |
| `bridge/rust-trace/proof/TraceBridge.lean` | `8a38e4b4250d9c3e4d9673b264393e8df42578842adffaf9b2c4dfe87b433272` | Byte-traceable ABI v2 lock chain soundness | **PASS (`0 sorry`)** |
| `seed/helix/proofs/WattCBF.lean` | `0c6c3855efc51440ddff54cf70dd8ef126e2863efa52afed105e4d801031f904` | 32 theorems: unconditional thermal CBF barrier safety, Trap-14 ceiling, idempotence, 5 negative controls | **PASS (`0 sorry`)** |

---

## 3. Unified 25-Suite Spark Full-Stack Regression Matrix (`1041e9a362e8b` @ `omc` `85b84c6d...`)

All 25 suites were executed and independently reproduced under ONE cold-rebuilt `seed/out/omc` (`85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134`):

| # | Suite | Evidence Class | Observed Verdict |
|---:|---|---|---|
| 1 | `sh seed/omega-from-seed.sh` | `HOST_VERIFIED` | `PASS omc fixpoint 85b84c6d...`, `SIZE_RECORD PASS cases=8` |
| 2 | `seed/ng/ng.units` (15/15 SHA-256) | `HOST_VERIFIED` | 15/15 OK, 2x bit-identical `ng` (`682836c2...`) |
| 3 | `seed/ng/gate-beyond-c.om` | `HOST_VERIFIED` | `NG-BEYOND-C-GATE PASS checks=80 neg_controls=8 egp3_certs=2 swaps=2 rollbacks=1 cli_checks=10 cli_neg=4` |
| 4 | `seed/ng/infix/gate_infix.om` | `HOST_VERIFIED` | `GATE_INFIX PASS rt=18 direct=4 neg=15 ext=0 fail=0` |
| 5 | `seed/ng/rm3_bench/gate_rm3.om` | `HOST_VERIFIED` | `GATE_RM3 PASS kernels=3 arms=4 neg=7 fail=0` (`ng` `1.094x` faster than `omc` across 11 X925 kernels) |
| 6 | `seed/ng/gpu_tma/gate_tma_sm121.om` | `HOST_VERIFIED` | `GATE_TMA_SM121 PASS checks=52 controls=12` |
| 7 | `seed/ng/gpu_tma/gate_flash_attn_sm121.om` | `HOST_VERIFIED` (`PHYSICAL_SILICON=NOT_RUN`) | `GATE_FLASH_ATTN_SM121 PASS checks=12 controls=12` (BF16 HMMA + NVFP4 OMMA + Antibody `#17` + 16-attack immune) |
| 8 | `seed/ng/multi_target/gate_multi_target.om` | `HOST_VERIFIED` | `MULTI-TARGET-GATE PASS checks=90 controls=29` |
| 9 | `seed/ddc/gate_ddc.om` | `HOST_VERIFIED` | `DDC-GATE PASS paths=3 diverse_bins=3 neg_controls=2 sha256=85b84c6d...` (`wrong` rc=60) |
| 10 | `seed/ddc/gate_bdisp.om` | `HOST_VERIFIED` | `BDISP-GATE PASS cases=15 boundary_ok=10 boundary_refused=5 neg_controls=2` (`wrong` rc=3) |
| 11 | `seed/modules/rm6/gate_rm6.om` | `HOST_VERIFIED` | `RM6-GATE PASS tests=12 controls=7` |
| 12 | `seed/conformance/gate_om_1_0_conformance.om` | `HOST_VERIFIED` | `OM10-CONFORMANCE PASS checks=52 c2=9 determ=5 c1=14 traps=7 errors=10 neg_controls=6 omc=85b84c6d...` |
| 13 | `seed/omc/gate_omc_1_0/run_gate.sh` | `HOST_VERIFIED` + `EXERCISED_EMULATED` | `OMC_1_0_FULL_GATE PASS` (`SCM_RIGHTS`, `x86linux` `execpure` BPF audit, RM8 `OMC_DIAG=1`, `qemu-x86_64`) |
| 14 | `bridge/rust-trace/gate_rust_trace.sh` | `HOST_VERIFIED` | `OMEGA_RUST_TRACE GATE PASS` (`#![forbid(unsafe_code)]`, debug+release `cargo test --offline`, 5 build-time tamper controls) |
| 15 | `bridge/tensorfold-omega/gate_tf_omega.sh` | `HOST_VERIFIED` | `TENSORFOLD_OMEGA GATE PASS` (C + Zig `0.13.0` + 18 EGP3 rules + 4 1-bit tamper controls) |
| 16 | `bridge/abi-v2-spec/gate_abi_v2.sh` | `HOST_VERIFIED` | `ABI_V2_GATE PASS omc_pin=85b84c6d... checks=33 mandatory=32/32 controls=7 langs=7` (C, C-BTI, C++, Rust, Zig, Python, Go + FR-7 `shlib`/`dlvsym`) |
| 17 | `apps/om-codemode/gate_codemode.om` | `HOST_VERIFIED` | `CODEMODE-GATE PASS tests=12 controls=8` |
| 18 | `apps/om-route/gate_om_route.om` | `HOST_THERMAL_LIVE` | `OM_ROUTE_GATE PASS checks=10 controls=6 caught=6` |
| 19 | `apps/omega-hive-feed/gate_hive_feed.om` | `HOST_VERIFIED` | `HIVE-FEED-GATE PASS tests=11 controls=14` + live `--render` (`21,639 B` HTML / `16,013 B` SVG, zero `<script>`) |
| 20 | `apps/omega-wattd/` | `HOST_THERMAL_LIVE` | Live `sense` (7 zones, 20 CPUs, `hw_writes=0`), `9/9` + `13/13` PASS, `--apply` refused `rc=2` |
| 21 | `apps/omega-strand-hub/gate.om` | `HOST_VERIFIED` | `STRAND_HUB_GATE pass=49 fail=0` |
| 22 | `train/units-gate.om` | `HOST_VERIFIED` | `OMEGA-TRAIN-UNITS PASS units=81 controls=1 caught=1` (incl. `ollm_a64efi`) |
| 23 | `seed/helix/sweep_sm121.sh` | `HOST_VERIFIED` | `SM121_SWEEP PASS kernels=46 total_insns=16318 swaps=2775 stall_saved=6243 immune=12/12x46` |
| 24 | `si/release-1.0/` (all 3 gates) | `HOST_VERIFIED` | `SI_1_0_GATE PASS 8/12/12`, `SI_INSTALLER_GATE PASS 9/7/7`, `LAUNCH_KIT_GATE PASS 11/6/9/7/7` |
| 25 | 4 Lean 4 Proofs | `HOST_VERIFIED` | 4/4 PASS (`0 sorry`, `0 sorryAx`, standard axioms only) |

### Cross-Repository Qualification Highlights
- **`omega-seats` (`d1c62a5c` @ `omc` `85b84c6d...`):** `14/14` `GATE_CORE PASS` native AArch64 + `14/14` `qemu-x86_64`, live upstream `libwayland-client.so.0` `wl_shm.create_pool` `SCM_RIGHTS` + `wl_keyboard.keymap` + composited PNG (`320×200`) + 13/13 MCP + 32-seat reclaim (`ALL SPARK VERIFICATION GATES PASSED`).
- **`omega-helix` (`8551f0c4`):** Native Apple M2 macOS (`Darwin arm64`) + Metal GPU `OMEGA_HELIX_PURE_OM_PASS` (`METAL_GPU_OM_PASS`, `SPCLIP_EDITABLE_SUITE_PASS` 41/41 controls, 5 signed `Mach-O` targets) + Spark Linux CPU bit-exact parity (`6f81c33c...`) + `qemu-x86_64` PASS.

---

## 4. Honest Open Physical Hardware & Integration Blockers (Big-Bang 1.0 Hold)

Sovereign Intelligence 1.0 remains under **Big-Bang 1.0 HOLD** (`si_release_gate` -> `REFUSED 1.0-HOLD`) until the following open items are completed and recorded with content-addressed receipts:

1. **`DRA-938` Physical DGX Spark Bare-Metal Aienux Boot (`PHYSICAL_SILICON=NOT_RUN` / `BLOCKED_HARDWARE`):** Attended physical console cold-boot of `SPARK.EFI` over UART `0x16A00000` (GB20B SEC2/GSP-FMC cold-boot, EC fan/thermal ramp verification, RTL8127 10GbE physical NIC DMA, `OMTK v1` Qwen3.8-27B token parity from Pi 5). Governed by [`PHYSICAL-BOOT-RUNBOOK.md`](../PHYSICAL-BOOT-RUNBOOK.md).
2. **External Consumer & Datacenter GPUs (`PHYSICAL_SILICON=NOT_RUN`):** Discrete NVIDIA RTX 5090 (`sm_120`), AMD Instinct MI300X (`gfx942`), AMD Strix Halo (`gfx1151`), and Intel Arc Xe2 (`drm/xe`) are contract- and router-verified on host only; physical hardware execution on those GPUs has not run.
3. **Physical x86-64 Linux Hardware (`PHYSICAL_SILICON=NOT_RUN`):** x86-64 ELF fixpoint, `execpure`, `omega-seats`, and `omega-helix` were exercised under `qemu-x86_64` (`EXERCISED_EMULATED`), not bare-metal x86-64 Linux hardware.
4. **Stage 1 / Stage 2 Zero-C Closure & Operator Gate Wiring (`BLOCKED_OPERATOR`):** Mainline Zero-C retirement continues in `omega-mv`, and wiring new 1.0 gates into `.aien/` / `tests/gates/` / `.github/workflows/` requires an operator run on DGX Spark per `AGENTS.md`.
5. **Standalone Community Repo Exports & `1.0` Tag Ceremony:** Spinning out `omega-wattd`, `omega-sm121-sass`, `omega-ng-egraph`, `tensorfold-omega`, mirroring `omega-seats`/`omega-helix`, and cutting signed `1.0` tags await `STAMP 1.0-READY` from `si_release_gate`.
