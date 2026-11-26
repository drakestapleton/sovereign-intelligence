# Bare-Metal Aienux & `target a64efi` Readiness Audit (Sovereign Intelligence 1.0)

- **Audit date:** 2026-11-26
- **Unified `stage/si-1.0-unified` re-check (2026-11-26):** Pinned `seed/out/omc` moved to `85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134`; Finding #1 (`ollm_a64efi` `error 12` in `train/omega-llm/native/cli.om` `fn cmdtrainfc`) was **FIXED** in commit `28f10d173` and re-verified on Spark with `OMEGA-TRAIN-UNITS PASS units=81 controls=1 caught=1 hardware=NOT_RUN`! Physical DGX Spark cold-boot (`DRA-938`) remains `PHYSICAL_SILICON=NOT_RUN` / `BLOCKED_HARDWARE`.
- **Original audit commit:** `7130bd1e94d10d59699b75406732d67329dac524` (`seed/out/omc` `180323d7...`)
- **Audit host:** DGX Spark (`aarch64` Linux, QEMU + EDK2 `QEMU_EFI.fd`, KVM enabled) in isolated `/tmp/om_sw_si10/repo`
- **Safety invariant:** Strictly read-only + QEMU/EDK2 only. Zero physical UEFI NVRAM (`efibootmgr` / `efivars`), zero `/boot/efi`, zero SPI/MTD, and zero `/dev/nvidia*` writes or opens.

## Summary Matrix (Honest Evidence Labels)

| Subsystem / Check | Evidence Class | Verdict | Observed Result on Spark (`7130bd1e`) |
|---|---|---|---|
| `tests/a64efi/run.sh` (QEMU `virt` + EDK2 + KVM) | `EXERCISED_EMULATED` | **PASS** | `SUMMARY pass=35 fail=0 not_run=1` (exit `0`; `file11` is `x86efi`-only, declared `NOT_RUN`) |
| `aienux/spark/build_spark_efi.sh` (`PLAT=gb10` PE32+) | `EXERCISED_HOST` | **PASS** | `SPARK.EFI` PE32+ `0xaa64`, `EFI_APP`, `FileSize=592896 B`, `SizeOfImage=10559488 B`, `sha256=a11b7a63b057f11d2333bcff806aa7c3bc4405cf773be58e87c4dc80c38aec47` (exit `0`) |
| `aienux/spark/run_spark_qemu_e2e.sh` (`PLAT=qemu`, 20-core QEMU `virt,iommu=smmuv3` + EDK2) | `EXERCISED_EMULATED` | **PASS** | `SPARK-QEMU.EFI` (`593408 B`, `sha256=2deb51f236a9dfab893ec0ae8d88e4716c5173755de559ef6fe1822b30c42dc5`): Stage 1 (`SMP_ONLINE online=20 expected=20 failed=0 boot_ms=6870`), Stage 2 (PCIe MCFG + mode-1 SMMUv3 streams live), Stage 3 (RO NVMe + GPT + ext4 + `OMFWBND1` TOC SHA-256), plus both fail-closed negative controls caught (`stage=3 code=304` tampered bundle, `stage=2 code=208` SMMU base mismatch) |
| `train/units.tsv` unit `ollm_a64efi` (`target a64efi` standalone CPU LLM image) | `EXERCISED_HOST` | **FAIL (Regression Caught)** | Fails to compile with pinned `omc` `180323d7...` at `omc: line 5417: error 12` (register pool exhausted in `train/omega-llm/native/cli.om` `fn cmdtrainfc` under non-pinned-global `target a64efi` mode). See Finding #1 below. |
| Physical DGX Spark `SPARK.EFI` Window 0 cold-boot (`DRA-938`) | `NOT_RUN` | **BLOCKED_HARDWARE** | Requires Drake attended at physical console + UART `0x16A00000` + full cold AC power-cycle. Never claimed from QEMU/host runs. |

> **Evidence boundary:** QEMU `virt` + EDK2 passes (`EMULATED` / `VIRTUALIZED`) exercise the UEFI PE32+ entry, `ExitBootServices`, EL2→EL1h MMU (`MAIR=0x440004FF`, 512 MiB Normal-NC pool), GICv3 + ITS, 20-core PSCI SMP, ACPI IORT + mode-1 SMMUv3, RO NVMe + GPT + ext4, and `OMFWBND1` SHA-256 fail-closed verification. They do **NOT** qualify GB20B SEC2/GSP-FMC cold-boot, RTL8127 10GbE physical NIC DMA, EC fan/thermal ramp, or physical Spark UEFI firmware.

---

## Detailed Audit Observations

### 1. `tests/a64efi/run.sh` on Spark QEMU + EDK2 (`PASS`)
Exact command run in `/tmp/om_sw_si10/repo`:
```sh
sh tests/a64efi/run.sh /tmp/om_sw_si10/repo/seed/out/omc
```
Observed results (`rc=0`):
- **19/19 compile-time refusal checks PASS:** Linux host words (`getpid`, `read`, `write`), function mode, run-time pools (`global p uchar *`), `efi` without `efirt`, `efi` OP > 14, `om2` before `target a64efi`, unknown target, reserved firmware names (`fwld`, `efi`, `fwadr`), malformed `efirt` / `efiexit` signatures.
- **Default target control PASS:** `fwld` and `efi` remain ordinary identifiers without `target a64efi` (exit 42).
- **15/15 QEMU/EDK2 execution & codegen checks PASS:**
  - `float a64efi` (41 lines match `tests/x86efi/float/expected.txt`)
  - `refusals` (21 `efi 12` refusal codes + `OFF+N` bounds trap 3 `0x8000000000000067`)
  - `file` round-trip (`T.TXT` on FAT disk verified as `abcd`)
  - `exit e1` (normal return flushes `X.TXT`) & `exit e2` (trap 3 flushes `X.TXT` via `fn efiexit`)
  - `ident` SMBIOS type 1 strings read (`sm=OmegaTest/IdentBox/7.1`) with zero serial/UUID leak + negative control (`OtherMaker`)
  - `om2` under `target a64efi` prints `om2 7 26`, zero X18 global-base loads, and `scrub` preserves X18 while clearing X19.
- **1 declared `NOT_RUN`:** `file11` (`efi 11` is `x86efi`-only).
- **Summary:** `SUMMARY pass=35 fail=0 not_run=1`.

### 2. `aienux/spark/SPARK.EFI` Build & 20-Core QEMU E2E (`PASS` Emulated)
1. **Production `PLAT=gb10` image (`build_spark_efi.sh`):**
   - Pure seeded-Omega builder (`seed/build/common.om` + `seed/build/sparkefi.om`, zero Python) produced `/tmp/om_sw_si10/SPARK.EFI`:
     - PE32+ `Machine=0xaa64`, `Subsystem=EFI_APP`, `FileSize=592896 B` (`579 KiB`), `SizeOfImage=10559488 B` (`10.07 MiB <= 64 MiB` ceiling)
     - `sha256=a11b7a63b057f11d2333bcff806aa7c3bc4405cf773be58e87c4dc80c38aec47`
     - Zero Linux syscalls, zero embedded firmware bytes, zero 184 MiB static host-sim `.bss`.
2. **Real `spark_main.om` under QEMU (`run_spark_qemu_e2e.sh`, `PLAT=qemu`):**
   - Stage 1: `UEFI->EL1h MMU GICv3+ITS 20-core SMP` -> `SMP_ONLINE online=20 expected=20 failed=0 boot_ms=6870`.
   - Stage 2: `PCIe MCFG/ECAM(Bus 0..1) SMMUv3 A/B/C BAR0-MMIO(mode=1) irqbm(iqmode=2)` -> `SMMUv3 streams live: gpu-standin sid=0x10 nvme sid=0x08`.
   - Stage 3: `RO-NVMe GPT ext4 80MiB OMFWBND1(TOC+SHA256)` -> `stage 3 bundle verified`.
   - Negative control 1 (1-byte flip in `OMFWBND1` payload): caught fail-closed `[SPARK FAIL stage=3 code=304]`.
   - Negative control 2 (platform vs IORT SMMUv3 base mismatch `0x09050000` vs `0x09060000`): caught fail-closed `[SPARK FAIL stage=2 code=208]`.
   - Explicitly stubbed in QEMU: GB20B BAR0/GSP registers, RTL8127/TCP wire loop, Stages 4–6 (`compute.om` / `q38_run.om` / `wire_loop.om`).

### 3. Finding #1 (Open Boot-to-LLM Blocker): `ollm_a64efi` `error 12` Regression
When compiling the standalone CPU UEFI boot-to-LLM unit `ollm_a64efi` listed in `train/units.tsv` (line 8) with the current pinned `seed/out/omc` (`180323d7...`):
- **Observed failure:** `omc: line 5417: error 12` (16-register pool exhausted) inside `train/omega-llm/native/cli.om` `fn cmdtrainfc`:
  ```om
  if and gt get og 59 1 lt flay add get og 57 get og 58
  ```
- **Root cause:** Under `target a64efi`, globals are not pinned to X18..X26 (all global accesses compute relative offsets via X27), so evaluating three `get og ...` loads inside a single compound `and` condition alongside live locals (`na`, `until`, `every`, `flay`) exhausts the 16-register pool.
- **Required fix (owned by `train/omega-llm/`):** Split the compound condition in `fn cmdtrainfc` into two short scalar assignments / nested `if`s, re-verify `ollm_a64efi` compiles cleanly to PE32+ and boots under QEMU/EDK2 with exact `OUT.TXT` parity against the AArch64 Linux reference.
- **Note:** `SPARK.EFI` (`aienux/spark/spark_main.om`, the 6-stage bare-metal GB10 Qwen3.8-27B boot-to-LLM image) does **not** use `train/omega-llm/native/cli.om` and compiles cleanly (`592,896 B`).

---

## Exact Remaining Steps for Drake's Attended Physical Spark Boot Ceremony (`DRA-938`)

Per `docs/baremetal/SPARK-LIVE-BOOT.md` and standing UEFI/SPI safety rules (only Drake may execute UEFI/NVRAM steps directly at the physical Spark console):

1. **Resolve open pre-ceremony software gates:**
   - Land and verify all 1.0 swarm lanes (`ng-wiring`, `infix-front`, `rust-bridge`, `gpu-tma-codegen`, `multi-gpu-targets`, `si-umbrella`) on Interplane `main`.
   - Fix `train/omega-llm/native/cli.om` `fn cmdtrainfc` `error 12` so `ollm_a64efi` also builds and passes QEMU/EDK2 boot-to-LLM parity.
2. **Build `SPARK.EFI` and offline `OMFWBND1` firmware bundle (on Spark, local `0700` path only — zero firmware bytes in git):**
   - Run `sh aienux/spark/build_spark_efi.sh build/spark/SPARK.EFI` and record its SHA-256.
   - Run `fwprep` + `pack_bundle` on pinned `/lib/firmware/nvidia/580.173.02/gsp_ga10x.bin` and install `/aienos/spark-bundle.img` (`0600`).
3. **Run strictly read-only preflight (zero writes):**
   - `tools/spark-boot/preflight.sh --spark-efi build/spark/SPARK.EFI --check-spark` -> require `VERDICT: PASS` (confirms `Boot0001` Ubuntu intact, ESP free >= 64 MiB, `nvme0n1p2` ext4 compatible, weights present, RTL8127 link up, `/dev/nvidia*` idle).
4. **Stage `\EFI\AIENOS\SPARK.EFI` via one-shot `BootNext` ONLY (Drake at console + UART `0x16A00000`):**
   - Dry-run first (`stage_bootnext.sh --spark-efi build/spark/SPARK.EFI --dry-run`).
   - Apply at console (`--apply --i-am-at-the-console`). Never touch `BootOrder` or `Boot0001`.
5. **Full cold power-cycle (NEVER `sudo reboot` after `nvidia.ko`):**
   - Attach serial console to Spark UART `0x16A00000` (`115200 8N1`).
   - Run `sudo poweroff`, wait for power LED off, **disconnect AC for 10 seconds**, reconnect AC and power on.
6. **Window 0 UART verification & mandatory EC fan/thermal gate:**
   - Observe sequential markers `[SPARK 1/6]` through `[SPARK 6/6]` on UART `0x16A00000`.
   - Immediately after `[SPARK 4/6]` (`GSP_INIT_DONE`), confirm audible/tachometer **EC fan spin** and active GSP thermal/DPM telemetry before any inference (Spark hard-cuts power at ~88–92 W).
7. **Drive `OMTK v1` inference from Raspberry Pi 5 (`pi_drive_omtk`):**
   - Run `./pi_drive_omtk 192.168.1.108 18100 ping`, `reset 0`, and 1-token -> 32-token `infer`, verifying bit-exact Qwen3.8-27B token parity against Linux reference.
8. **Capture content-addressed receipt & flip `aienux`/`omega-gpu-driver`/`rtl8127-omega` in `MANIFEST-1.0.tsv`:**
   - Power-cycle to return cleanly to Ubuntu (`Boot0001`), archive UART log + `pi_drive_omtk` output + exact commit/image SHA-256 into `evidence/`, update `si/release-1.0/MANIFEST-1.0.tsv` to `EXERCISED_SILICON` / `QUALIFIED_SILICON` + `PASS`, and re-run `si_release_gate` to obtain the `STAMP 1.0-READY` seal.
