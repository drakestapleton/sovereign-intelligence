# DGX Spark Physical Bare-Metal Boot Runbook (`DRA-938` — Operator Console Only)

> **HARD SAFETY BANNER — OPERATOR PHYSICAL CONSOLE ONLY**
> - **NEVER automate UEFI NVRAM or SPI/MTD writes.** Agents, CI jobs, and unattended scripts MUST NOT invoke `efibootmgr`, write to `/sys/firmware/efi/efivars`, write to `/boot/efi/EFI/*`, or touch `flashrom` / `fwupdmgr` / `/dev/mtd*` / `/dev/spidev*`.
> - **ONLY the human operator (Drake) sitting physically at the DGX Spark console with UART `0x16A00000` attached may perform physical boot staging.**
> - **NEVER warm-reboot after Linux `nvidia.ko` has run.** Always perform a **full cold AC power-cycle** (`sudo poweroff` + 10-second AC disconnect) before booting `SPARK.EFI`.
> - **NEVER modify `BootOrder` or `Boot0001` (`ubuntu`).** Prefer the **zero-NVRAM removable FAT32 USB boot path** in §2 so internal `nvme0n1` ESP and UEFI NVRAM are never touched at all.

**Current Evidence Status (honest):**
- `tests/a64efi/run.sh` (QEMU/EDK2): **`EXERCISED_EMULATED` PASS** (`pass=35 fail=0 not_run=1`)
- `aienux/spark/run_spark_qemu_e2e.sh` (20-core QEMU `virt,iommu=smmuv3` + EDK2): **`EXERCISED_EMULATED` PASS** (Stages 1–3 + 2 fail-closed negative controls)
- Physical DGX Spark silicon cold-boot (`DRA-938`): **`PHYSICAL_SILICON=NOT_RUN` / `BLOCKED_HARDWARE`** (this checklist governs that attended ceremony)

---

## 1. Pre-Ceremony Read-Only Build & SHA-256 Verification (Safe Before Console)

Run these strictly read-only / local-build checks on DGX Spark before walking up to the console. Zero writes to `/boot/efi`, NVRAM, or `/dev/nvidia*`.

### 1.1 Verify Pinned `seed/out/omc`
```sh
sha256sum -c seed/out/omc.sha256
# Expected at unified SI 1.0 omc pin: 85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134  seed/out/omc
```

### 1.2 Build & Verify `SPARK.EFI` (`PLAT=gb10` PE32+ ARM64)
```sh
sh aienux/spark/build_spark_efi.sh build/spark/SPARK.EFI
sha256sum build/spark/SPARK.EFI
ls -lh build/spark/SPARK.EFI
# Expected properties: PE32+ ARM64 (0xaa64), Subsystem=EFI_APP (10), SizeOfImage <= 64 MiB
# Zero Linux syscalls, zero embedded firmware bytes, zero 184 MiB host-sim .bss
```

### 1.3 Build & Verify Standalone CPU UEFI LLM (`ollm_a64efi`)
> **Status:** `train/omega-llm/native/cli.om` `fn cmdtrainfc` register-pressure fix (`error 12` under `target a64efi`) landed in commit `28f10d173` (`OMEGA-TRAIN-UNITS PASS units=81` on unified `omc` `85b84c6d...`).

```sh
# Compile standalone CPU UEFI LLM unit (read-only verification build)
{ printf 'target a64efi\n'; cat train/omega-llm/native/ollm_efi.om; } | ./seed/out/omc > build/spark/OLLM.EFI
sha256sum build/spark/OLLM.EFI
```

### 1.4 Pack Offline `OMFWBND1` Firmware Bundle (`0700` Local Path Only — Zero Firmware in Git)
Follow `docs/baremetal/SPARK-LIVE-BOOT.md` §(b) to build `/aienos/spark-bundle.img` (`0600`) from pinned `/lib/firmware/nvidia/580.173.02/gsp_ga10x.bin` and record its digest:
```sh
sha256sum /aienos/spark-bundle.img
```

### 1.5 Run Strictly Read-Only Preflight
```sh
tools/spark-boot/preflight.sh --spark-efi build/spark/SPARK.EFI --check-spark
```
Require **`VERDICT: PASS`** before proceeding (confirms `Boot0001` Ubuntu intact, `nvme0n1p2` ext4 compatible with `ext4_ro.om`, weights present, RTL8127 link up, and `/dev/nvidia*` idle without opening GPU device nodes).

---

## 2. Removable-USB FAT32 Staging (Physical Console Only — Zero Internal NVRAM Touch)

Using a dedicated removable FAT32 USB drive avoids writing to `/boot/efi` or touching internal UEFI NVRAM (`efibootmgr`/`efivars`) completely.

**Operator steps at physical console:**
1. Insert a clean removable USB flash drive (verify its exact device node with `lsblk -o NAME,SIZE,TRAN,MODEL,MOUNTPOINT`; confirm `TRAN=usb` and **never** touch `/dev/nvme0n1*`).
2. Prepare a single FAT32 partition (`ESP` / `0xEF00` or standard `FAT32`, volume label `AIENOS_BOOT`) and mount it at a temporary mountpoint (e.g. `/mnt/si-usb`):
   ```sh
   sudo mkdir -p /mnt/si-usb/EFI/BOOT /mnt/si-usb/EFI/AIENOS
   sudo cp build/spark/SPARK.EFI /mnt/si-usb/EFI/BOOT/BOOTAA64.EFI
   sudo cp build/spark/SPARK.EFI /mnt/si-usb/EFI/AIENOS/SPARK.EFI
   # Optional: include OLLM.EFI when standalone CPU UEFI LLM build is green
   [ -f build/spark/OLLM.EFI ] && sudo cp build/spark/OLLM.EFI /mnt/si-usb/EFI/AIENOS/OLLM.EFI
   ```
3. Write and verify `SHA256SUMS.txt` on the USB stick against the host build digests:
   ```sh
   (cd /mnt/si-usb && sha256sum EFI/BOOT/BOOTAA64.EFI EFI/AIENOS/SPARK.EFI | sudo tee SHA256SUMS.txt)
   (cd /mnt/si-usb && sha256sum -c SHA256SUMS.txt)
   sha256sum build/spark/SPARK.EFI
   ```
   Confirm the SHA-256 of `EFI/BOOT/BOOTAA64.EFI` and `EFI/AIENOS/SPARK.EFI` on USB is **byte-for-byte identical** to `build/spark/SPARK.EFI`.
4. Flush and unmount cleanly:
   ```sh
   sync
   sudo umount /mnt/si-usb
   ```

*(Alternative documented in `docs/baremetal/SPARK-LIVE-BOOT.md` §(d): if booting from internal ESP instead of USB, Drake at console may use `stage_bootnext.sh --dry-run` then `--apply --i-am-at-the-console` to set one-shot `BootNext` ONLY — never altering `BootOrder` or `Boot0001`. Removable USB requires zero NVRAM writes and is the lowest-risk default.)*

---

## 3. Cold Power-Cycle & UART `0x16A00000` / Framebuffer Checkpoints

1. **Attach serial console** to Spark UART `0x16A00000` (`115200 8N1`) and start logging to a timestamped file on the observer host (e.g. Raspberry Pi 5).
2. **Full cold power-cycle (MANDATORY):**
   - Run `sudo poweroff` on Spark.
   - Wait until the power LED is completely dark.
   - **Unplug AC power for 10 full seconds**, then reconnect AC and power on.
3. **Select the removable USB drive** (`AIENOS_BOOT` -> `\EFI\BOOT\BOOTAA64.EFI`) from the physical UEFI Boot Menu (`Esc` / `F7` at console).
4. **Verify sequential UART & framebuffer checkpoints:**

| Stage | Expected Checkpoint Marker | Pass Criterion / Mandatory Stop Condition |
|---|---|---|
| **1/6** | `[SPARK 1/6]` ... `SMP_ONLINE online=20 expected=20 failed=0` | `ExitBootServices`, EL2→EL1h MMU (`MAIR=0x440004FF`, 512 MiB Normal-NC pool), GICv3 + ITS, all 20 Grace cores online. |
| **2/6** | `[SPARK 2/6]` ... `SMMUv3` ... `CrashCat` | PCIe MCFG segments 4/7/15 probed; SMMUv3 A/B/C mode-1 disjoint streams live (NVMe `0x50100`, RTL8127 `0x80100`, GB20B `0x100`); unused PCIe quiesced. |
| **3/6** | `[SPARK 3/6]` ... `NVMe` / `GPT` / `ext4` / `OMFWBND1` | Strictly read-only NVMe (`I/O Read 0x02` only) + GPT + `ext4_ro.om` verified `/aienos/spark-bundle.img` SHA-256 TOC + Qwen3.8-27B weights; RTL8127 `PHYSTAT` link up. |
| **4/6** | `[SPARK 4/6]` ... `GSP_INIT_DONE` | GB20B SEC2/GSP-FMC cold-boot + `RPC 54/79` + `0xca6f`/`0xcec0` channel live. **MANDATORY THERMAL GATE:** confirm audible/tachometer **EC fan spin** and live GSP thermal/DPM telemetry (`CBKDPM`/`CBKPW2` active). **ABORT IMMEDIATELY** (power off) if fan does not spin or thermal telemetry is missing — Spark hard-cuts at ~88–92 W! |
| **5/6** | `[SPARK 5/6]` ... `q38_run` | Pure-Omega `sm_121` SASS codegen + `DC CIVAC` + `DSB SY` + KV zero + L2 flush. |
| **6/6** | `[SPARK 6/6]` ... `OMTK v1` `:18100` (or `OLLM DONE` for standalone `OLLM.EFI`) | Zero-userspace `wire_loop.om` listening on `192.168.1.108:18100` (or CPU `OLLM.EFI` prints `OLLM DONE` and flushes output cleanly). |

5. **Drive `OMTK v1` inference from Raspberry Pi 5 (while watching package power & fan):**
   ```sh
   ./pi_drive_omtk 192.168.1.108 18100 ping
   ./pi_drive_omtk 192.168.1.108 18100 reset 0
   ./pi_drive_omtk 192.168.1.108 18100 infer 1 151645 9707
   # Only after 1-token infer + EC fan/thermal look completely healthy:
   ./pi_drive_omtk 192.168.1.108 18100 infer 32 151645 9707 11 1265
   ```
   Verify bit-exact Qwen3.8-27B token parity against the Linux reference run.

---

## 4. Clean Instant Rollback to Stock Ubuntu Linux

1. **Power off** (or let `SPARK.EFI` invoke PSCI `SYSTEM_RESET` `0x84000009`).
2. **Unplug the removable USB stick** (`AIENOS_BOOT`).
3. **Power Spark back on.** Because internal `BootOrder`, `Boot0001` (`\EFI\ubuntu\shimaa64.efi`), and `/dev/nvme0n1` were never modified, DGX Spark boots straight back into stock Ubuntu Linux on the very first boot.
4. *(Only if the optional one-shot `BootNext` path was used instead of USB)*: one-shot `BootNext` auto-clears upon consumption; if cancelling before rebooting, Drake runs `sudo efibootmgr -N` at console.

---

## 5. Post-Ceremony Evidence Capture (To Lift 1.0 Hold)

Once back in Ubuntu:
1. Archive the exact UART `0x16A00000` capture, `pi_drive_omtk` transcript, `SPARK.EFI` SHA-256, and `omega-mv` commit SHA as a new content-addressed receipt under `evidence/` (additions only).
2. Update `aienux`, `omega-gpu-driver`, and `rtl8127-omega` in `si/release-1.0/MANIFEST-1.0.tsv` to `EXERCISED_SILICON` / `QUALIFIED_SILICON` + `PASS`.
3. Re-run `si_release_gate` against `MANIFEST-1.0.tsv` and `seed/out/omc.sha256` to obtain `STAMP 1.0-READY`.
