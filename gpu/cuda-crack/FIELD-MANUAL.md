# Field manual: running the DGX Spark (GB10) without the CUDA stack

Each finding gives the symptom, what the documents say, what I measured and with which label, the fix, and where to reproduce it. These are the findings that cost me the most time.

**Repositories:**
- **CUDApp** is `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` at `b774723f`. Clone it with `rad clone`, or with `git clone https://www.aienos.com/rad/z4RxD8vXigmWg61nM8miQ8DVPAXEP.git`.
- **omega-mv** is `rad:z6do9WDBhuSnvopDkgFdFr1yWA62`.
- **here** is this repository.

**Labels** say where the evidence came from:
- CHIP_TESTED: ran on the GB10.
- HOST_TESTED: ran on a CPU host.
- DEPLOYED: served live on the given date.
- MEASURED-TOOL: a system tool reported it, not my own kernel.
- DOCUMENTED: a vendor document or open source says it.

Lifecycle words are separate from labels: IMPLEMENTED means written, EXERCISED means run. A label is not a production qualification.

**RECEIPT PENDING** means the finding is real in my notes, but its receipt is not public yet. Treat it as unverified until the receipt is attached.

NVIDIA documents are linked, never copied:
- [GB10 Superchip Whitepaper WP-12718-001_v02](https://www.nvidia.com/content/dam/en-zz/Solutions/dgx-spark/nvidia-gb10-superchip-whitepaper.pdf) ("whitepaper")
- [DGX Spark User Guide](https://docs.nvidia.com/dgx/dgx-spark/) ("user guide")
- [NVIDIA/open-gpu-kernel-modules at tag 580.173.02](https://github.com/NVIDIA/open-gpu-kernel-modules/tree/580.173.02) ("open module")

---

## 1. The machine

### F1. The GB10 is sm_121, not datacenter Blackwell
- **Symptom:** Kernels and images built for datacenter Blackwell do not match this chip.
- **Docs:** See the whitepaper. The GB10 is a Blackwell GPU with compute capability 12.1, plus a 20-core Arm CPU: 10 Cortex-X925 and 10 Cortex-A725.
- **Measured:** DOCUMENTED. The chip identity is confirmed in F10.
- **Fix:** Target sm_121. This repository's tables are sm_121 only (`isa/`).
- **Reproduce:** Read the whitepaper. See F10 for the chip's own report.

### F2. One 128 GB memory pool; "Memory-Usage: Not Supported" is normal
- **Symptom:** `nvidia-smi` shows "Memory-Usage: Not Supported".
- **Docs:** The user guide lists this as a known issue. The machine has 128 GB of LPDDR5x at 273 GB/s, shared by the CPU and GPU. There is no separate GPU memory.
- **Measured:** DOCUMENTED.
- **Fix:** Nothing is broken. Plan memory as one pool shared with the CPU.
- **Reproduce:** User guide, known issues.

### F3. Every GPU DRAM byte crosses NVLink-C2C
- **Symptom:** GPU bandwidth behaves like a link-attached device, not like local HBM.
- **Docs:** Whitepaper Figs. 3 and 6, described here rather than copied. The memory controllers sit on the CPU die (S-die). The GPU die (G-die) holds the compute units and the 24 MiB L2.
- **Measured:** DOCUMENTED.
- **Fix:** Budget DRAM traffic as crossing C2C. See F4.
- **Reproduce:** Whitepaper figures.

### F4. C2C (345 GB/s per direction) is wider than DRAM (273 GB/s)
- **Symptom:** It is unclear whether the link or DRAM is the ceiling.
- **Docs:** No NVIDIA document gives the per-link figure. The tool reports it.
- **Measured:** MEASURED-TOOL. `nvidia-smi c2c -s` on 2026-10-24 reported 8 links × 43.125 GB/s = 345 GB/s per direction. This was a CPU-side STREAM measurement only. **The GPU-side measurement is pending.**
- **Fix:** For bulk traffic, treat DRAM, not the link, as the ceiling. This is a working assumption until the GPU-side measurement exists.
- **Reproduce:** Run `nvidia-smi c2c -s` on your Spark. RECEIPT PENDING: my 2026-10-24 log is not public yet.

### F5. NVIDIA's own documents disagree
- **Symptom:** Different documents give different numbers for the same machine.
- **Docs:**
  - Coherency: the whitepaper p.3 says CHI-G; the Hot Chips 2025 deck says CHI-E.
  - Memory bandwidth: 273 GB/s versus "~301GB/s raw".
  - Aggregate C2C: "~600GB/s" versus the 690 GB/s that `nvidia-smi` reports.
- **Measured:** DOCUMENTED. These are short quotes from the two sources.
- **Fix:** Trust what the machine reports, and say which source each number came from.
- **Reproduce:** Whitepaper, the Hot Chips 2025 GB10 deck, and `nvidia-smi c2c -s`.

### F6. No C2C performance counter is exposed
- **Symptom:** No perf event measures link traffic.
- **Docs:** None.
- **Measured:** MEASURED-TOOL on 2026-10-24. `/sys/bus/event_source` lists only smmuv3_pmcg, armv8_pmuv3 and arm_spe.
- **Fix:** Infer link load from timing, or from DRAM-side counters where they exist.
- **Reproduce:** Run `ls /sys/bus/event_source/devices`.

### F7. The GPU's PCIe link shows Gen1 x1, and that is fine
- **Symptom:** `lspci` or `nvidia-smi` shows a Gen1 x1 link.
- **Docs:** None found.
- **Measured:** MEASURED-TOOL. The PCIe link carries control only. Data goes over C2C.
- **Fix:** None needed.
- **Reproduce:** Run `lspci -vv -d 10de:2e12`, then look at LnkSta. RECEIPT PENDING: my log is not public yet.

### F8. CPU first-touch latency ladder
- **Symptom:** Latency-bound host code waiting on GPU results.
- **Docs:** None.
- **Measured:** HOST_TESTED. This was a CPU measurement on core 7, 2026-10-24:

  | Level | Latency |
  |---|---|
  | L2 | ~8 ns |
  | L3 | ~40–57 ns |
  | Point of coherency, after DC CIVAC | ~60–85 ns |
  | DRAM | ~130–155 ns |
- **Fix:** Poll only words that are allocated uncached (F19). Expect DRAM-class latency on them.
- **Reproduce:** RECEIPT PENDING: my measurement log is not public yet.

### F9. `cudaMemGetInfo` can under-report free memory
- **Symptom:** The free-memory figure looks too small.
- **Docs:** The user guide lists this as a known issue: the CPU can swap pages.
- **Measured:** DOCUMENTED.
- **Fix:** Do not size allocations from this figure alone.
- **Reproduce:** User guide, known issues.

### F10. The GPU identifies as PCI `10de:2e12` "NVIDIA GB10", sm_121
- **Symptom:** You need the exact ID to gate code to this chip.
- **Docs:** None needed.
- **Measured:** CHIP_TESTED, by the doctor on the E2 run.
- **Fix:** Gate on `10de:2e12`.
- **Reproduce:**
  - CUDApp `src/omega_gpu_chip.c:15`.
  - Here: `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-doctor.log`.
  - Run `make doctor` in CUDApp.

## 2. Driving the GPU without libcuda

### F11. Everything goes through ioctls on three device files
- **Symptom:** libcuda looks like the only way in.
- **Docs:** NVIDIA's open module defines every call in public MIT headers.
- **Measured:** CHIP_TESTED, and DEPLOYED on 2026-10-21 (E1). The three device files are:
  - `/dev/nvidiactl`, the resource manager;
  - `/dev/nvidia<minor>`, for CPU mappings;
  - `/dev/nvidia-uvm`, opened twice, which owns the GPU page tables.
- **Fix:** Speak the ioctl ABI directly.
- **Reproduce:**
  - CUDApp `docs/DRIVER.md:7-13` and `docs/HOW_I_DID_IT.md:20`.
  - Here: `receipts/omega-mv/evidence/WHAT-OMEGA-IS-20261021/live-serve-no-cuda.txt`.

### F12. The open sequence is 11 steps
- **Symptom:** Device setup fails partway through.
- **Docs:** Open-module headers.
- **Measured:** CHIP_TESTED. The 11 steps, in order:
  1. root client;
  2. UVM init;
  3. card info;
  4. device object;
  5. subdevice object;
  6. virtual memory object;
  7. class list;
  8. usermode page;
  9. SM version;
  10. FERMI_VASPACE_A;
  11. UVM GPU registration.
- **Fix:** Follow that order.
- **Reproduce:** CUDApp `docs/DRIVER.md:15-30`, and `nvrm/nvrm.c` `nvrm_open()`.

### F13. Three classes, and a one-store doorbell
- **Symptom:** You do not know which classes to allocate, or how to kick work off.
- **Docs:** Open-module class headers, starting with `clcec0.h`.
- **Measured:** CHIP_TESTED. The three classes are:
  - `BLACKWELL_COMPUTE_B` (clcec0);
  - `BLACKWELL_CHANNEL_GPFIFO_A`;
  - `HOPPER_USERMODE_A`.

  The doorbell is one user-space store to `NVC361_NOTIFY_CHANNEL_PENDING` in the mapped 64 KiB usermode page.
- **Fix:** As measured.
- **Reproduce:** CUDApp `docs/DRIVER.md:23-24` and `nvrm/nvrm.c:45,66`.

### F14. The driver ABI is pinned to open module 580.173.02
- **Symptom:** A different module version breaks the ioctl ABI.
- **Docs:** Open module, tag 580.173.02.
- **Measured:**
  - HOST_TESTED: the doctor's version logic.
  - CHIP_TESTED: the doctor ran on the E2 run.
- **Fix:** `make doctor` and `make hello-gpu` refuse other versions. This is a check in the wrapper only. Binaries run directly have no such guard.
- **Reproduce:**
  - CUDApp README, "You need" row.
  - Here: `.../chip-20261027T080240Z/om-doctor.log`.

### F15. The driver client is about 900 lines of C
- **Symptom:** None. This is the size of the job.
- **Docs:** It is written against 67 unchanged MIT headers from the open module. They are linked, not re-hosted.
- **Measured:** IMPLEMENTED, and CHIP_TESTED through E1 and E2.
- **Fix:** None needed.
- **Reproduce:** CUDApp `nvrm/nvrm.c`, `docs/DRIVER.md:3` and `docs/HOW_I_DID_IT.md:20`.

### F16. The launch order comes from Mesa NVK
- **Symptom:** A launch goes nowhere, or runs stale code.
- **Docs:**
  - Mesa NVK, MIT: `src/nouveau/vulkan/nvk_cmd_dispatch.c` and `nvk_cmd_buffer.c`.
  - The open class headers.
- **Measured:** CHIP_TESTED. The order is: code pointer, launch descriptor (QMD), cache invalidates, fire. Credit to Mesa.
- **Fix:** Follow that order.
- **Reproduce:** CUDApp `docs/HOW_I_DID_IT.md:45` and `src/omega_gpu_cmdlist.c`.

### F17. The cost of an extra dependent launch
- **Symptom:** Chains of small launches are slow.
- **Docs:** None.
- **Measured:** CHIP_TESTED on 2026-10-14, in a PASS run with n 16384, k 2048 and 20 reps.
  - With a wait-for-idle barrier: 25.09 to 31.97 µs.
  - Without one: 2.68 to 9.68 µs.

  These figures are specific to this workload. They are not a ceiling.
- **Fix:** Drop barriers that the data dependencies do not need.
- **Reproduce:** Here: `receipts/cudapp/evidence/OWN30B-LAUNCH-COST-20261014T0120Z/r2/receipt.json`. Run r2 only; r1 was a FAIL run.

## 3. Memory and cache: the trap that cost two days

### F18. GPU-cached system memory is not coherent with CPU mappings
- **Symptom:** The CPU does not see what the GPU wrote.
- **Docs:** Open module, `src/common/sdk/nvidia/inc/nvos.h`, lines 1116–1118 at tag 580.173.02 (MIT). The default is "gpu uncached for system memory", and with caching enabled, "For system memory this will not be coherent with direct CPU mappings."
- **Measured:** DOCUMENTED.
- **Fix:** See F19.
- **Reproduce:** [nvos.h at 580.173.02](https://github.com/NVIDIA/open-gpu-kernel-modules/blob/580.173.02/src/common/sdk/nvidia/inc/nvos.h#L1116-L1118).

### F19. Words the CPU polls must be GPU-uncached
- **Symptom:** The CPU sees a done flag about 1 s late, or never. Launches took 1066 ms each, with a rare 600 s stall.
- **Docs:** F18.
- **Measured:** CHIP_TESTED, observed 2026-10-01/02. **RECEIPT PENDING:** the stall receipt is not attached yet.
- **Fix:** Allocate every host-polled word with `nvrm_alloc_gpu_uncached`. The source comment says: "a resident chip program polling the buffer keeps reading its own L2 copy and never sees the store."
- **Reproduce:** CUDApp `nvrm/nvrm.c:620-621` and `src/omega_gpu_platform.h:27`.

### F20. The proven release sequence
- **Symptom:** Making the marker uncached only moves the stall somewhere else.
- **Docs:** None.
- **Measured:** CHIP_TESTED per my notes, chip PASS at fb36109. **RECEIPT PENDING:** the fb36109 receipt is not attached yet.
- **Fix:**
  1. Issue an `L2_FLUSH_DIRTY` mem-op.
  2. Write a second marker to uncached memory.
  3. Have the host wait on both.
- **Reproduce:** CUDApp `src/omega_blackwell_submit.c:374,622` and `src/omega_blackwell_engine.c:518`.

### F21. Stale L2 after the CPU rewrites a buffer (open hypothesis)
- **Symptom:** Results are wrong only under load, or only on the second dispatch.
- **Docs:** None.
- **Measured:** **Hypothesis, not proven.** When the CPU rewrites a buffer the chip may still read, the chip may read its own stale L2 copy.
- **Fix:** Suspect this first for that symptom. The test is still to be run.
- **Reproduce:** None yet.

### F22. "Full cache coherency" means the fabric, not GPU L2 (interpretation)
- **Symptom:** The whitepaper and F18 seem to contradict each other.
- **Docs:** The whitepaper p.1 says "Full cache coherency between CPU and GPU". The other side is the nvos.h comment in F18.
- **Measured:** **Interpretation**, inferred from F18 and F20. Both statements are true at once.
- **Fix:** Keep the F20 flush.
- **Reproduce:** Read F18 and F20.

### F23. My runtime refuses a cached host-polled buffer
- **Symptom:** None. This is a guard against F19.
- **Docs:** None.
- **Measured:** HOST_TESTED.
- **Fix:** The runtime refuses such a buffer with `OMEGA_GPU_PLAT_REFUSED_CACHE_POLICY`.
- **Reproduce:** CUDApp `docs/runtime/PORTABILITY.md:125-126`.

### F24. After one uncertain completion, stop submitting
- **Symptom:** Retrying after a stall makes things worse.
- **Docs:** None.
- **Measured:** IMPLEMENTED. After one uncertain completion, the session refuses further submissions by design.
- **Fix:** Address the first stall. Do not retry.
- **Reproduce:** CUDApp `src/omega_gpu_session.c`, the uncertain-state handling.

## 4. Machine code

### F25. SASS encodings are not published, so I recovered them
- **Symptom:** No public encoding for sm_121 exists.
- **Docs:** NVIDIA does not publish SASS encodings.
- **Measured:** CHIP_TESTED as a method; see E2 and E10. I used three methods:
  1. Offline, I compiled my own probe kernels with nvcc 13.0.88, changing one detail at a time, and read them with `cuobjdump -sass`.
  2. I read the Mesa NAK sources (MIT). No code was copied.
  3. I accepted an encoding only after the chip ran it correctly.
- **Fix:** The derived tables are in `isa/`. The raw dumps are not published (`LEGAL.md`).
- **Reproduce:**
  - CUDApp `docs/HOW_I_DID_IT.md:31-41` and `THIRD_PARTY.md`.
  - Here: `gen/run.sh` and `check/check.sh`.

### F26. Instruction size and encoder scope
- **Symptom:** None. These are planning facts.
- **Docs:** None.
- **Measured:** CHIP_TESTED (E2):
  - Every instruction is 128 bits.
  - The vector add is 32 instructions, 512 bytes.
  - The C builder has 59 IR instruction kinds.
  - The Omega encoder handles IR ops up to 63. Ops 60–63 include SHFL.BFLY and F2FP.BF16. It refuses programs longer than 1024 instructions.
- **Fix:** None needed.
- **Reproduce:**
  - Here: `gen/bw_enc_sm121.om` lines 8, 17 and 471, and `isa/sm121-forms.txt`.
  - Paper: https://doi.org/10.5281/zenodo.23677465.

### F27. Reconvergence: BSSY/BSYNC
- **Symptom:** Divergent code hangs, or produces wrong lanes.
- **Docs:** None.
- **Measured:** CHIP_TESTED per my notes, on the T1–T4 ladder. **RECEIPT PENDING.** The rules:
  - `BSSY.RECONVERGENT` goes right before the divergent region.
  - Loop exits branch to the `BSYNC.RECONVERGENT`.
  - SHFL and BAR go after the BSYNC.
  - nvcc fully predicates short if/else diamonds.
- **Fix:** Follow those rules.
- **Reproduce:** Pending, together with the receipt.

### F28. The tensor-core BF16 MAC model; SFU flushes subnormals
- **Symptom:** BF16 results differ from a naive model.
- **Docs:** None.
- **Measured:** CHIP_TESTED per my notes. I modelled the MAC bit for bit from 2,048 chip cases, chosen to separate the candidate models. **RECEIPT PENDING:** the probe receipt is not attached yet.
- **Fix:** Use the model in `tests/bw_hmma_model.h`.
- **Reproduce:** CUDApp `docs/HOW_I_DID_IT.md:37`, `tests/gpu_tc_probe_test.c` and `tests/bw_hmma_model.h`.

### F29. FP32 transcendentals match on all 2^32 inputs
- **Symptom:** None. This is a parity check.
- **Docs:** None.
- **Measured:** CHIP_TESTED. Nine FP32 ops match a frozen CPU sequence with 0 mismatches. This is parity, not correct rounding. SIN and COS have a restricted domain.
- **Fix:** None needed.
- **Reproduce:** Here: `receipts/omega-mv/evidence/E1-TRANSC-GB10/`.

### F30. The Omega encoder and the C encoder are byte-identical
- **Symptom:** None. This is a cross-check.
- **Docs:** None.
- **Measured:**
  - CHIP_TESTED: the 70 kernels the chip ran.
  - HOST_TESTED: a 243-kernel host corpus.
- **Fix:** None needed.
- **Reproduce:**
  - Here: `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/`.
  - Here: `check/check.sh`, which rebuilds the 70 kernels from `isa/` alone.

## 5. Limits

### F31. The GSP firmware stays NVIDIA's
- **Symptom:** None. This is a limit.
- **Docs:** The chip checks the firmware's signature and boots nothing else.
- **Measured:** DOCUMENTED and observed.
- **Fix:** None is possible. Use NVIDIA's signed firmware; it is not included here.
- **Reproduce:** CUDApp `docs/HOW_I_DID_IT.md:60`.

### F32. The GSP boot sequence and RPC table
- **Symptom:** None. This is research.
- **Docs:** Mapped from the open module source only. No device was opened.
- **Measured:** Source research, so it has no execution label. **RECEIPT PENDING:** the quoted volume of NVIDIA source has not been reviewed yet.
- **Fix:** Not applicable.
- **Reproduce:** CUDApp `docs/nvidia-out/GSP-RPC-TABLE.md`. Its claims are pointers to file and line, not copied source.

### F33. My replacement for `nvidia.ko` has not run on the GB10
- **Symptom:** None. This is a limit.
- **Docs:** None.
- **Measured:** HOST_TESTED, emulated and simulated only.
- **Fix:** Not applicable.
- **Reproduce:** CUDApp README, the driver row.

### F34. What other DGX Spark owners report
- **Symptom:** Other owners report three problems:
  - published Docker images without sm_121a kernels;
  - a missing environment variable that silently breaks NVFP4 MoE;
  - hard hangs on deep-context speculative decoding.
- **Docs:** Third-party reports, quoted with numbered sources.
- **Measured:** Not by me.
- **Fix:** See the sources.
- **Reproduce:** CUDApp `docs/PAIN_POINTS.md` §2.12.
