# I broke CUDA.

**GitHub censored me. I demand to be heard.**

On 7 November 2026, 08:14–08:20 UTC, GitHub's automated system flagged my organisation "owner marked spammy" after the write volume of about 20 AI coding agents, and hid 109 repositories. My appeal is pending. Details: [Why this is on Radicle](#why-this-is-on-radicle).

My own language, Omega, writes NVIDIA GB10 machine code. It ran on the chip: 1,048,576 of 1,048,576 values correct, with no CUDA toolkit, no nvcc and no PTX.

What I have not done yet: replace every CUDA library, run on GPUs other than the GB10, or remove NVIDIA's open kernel module and signed firmware. Status per piece: https://www.aienos.com/cudaplusplus/

**Replicate it with any AI agent: [AGENT-PROMPT.md](AGENT-PROMPT.md)**

Replicate on your machine (clean userspace, no CUDA toolkit, no sudo): `curl -fsSL https://www.aienos.com/replicate | sh`

Let your own local model drive it: `curl -fsSL https://www.aienos.com/replicate | sh -s -- --agent` (or set AIEN_MODEL_URL / AIEN_MODEL). Other options: --chip, --corpus, --yes.

## The moat

CUDA's moat is that only NVIDIA's toolchain can put code on NVIDIA silicon. On the GB10 that is no longer true. The method, the encoder and every receipt are public on Radicle, where no single company can switch them off.

This repository is the single place to fetch that crack:

| Path | What it is |
|---|---|
| `isa/sm121-forms.txt` | Machine-readable sm_121 encoding tables: 471 instruction forms with opcode, fixed bits, operand-field bit positions and default control word. Generated, not hand-typed (see `isa/README.md`). |
| `gen/` | `bw_enc_sm121.om`, my Omega instruction encoder (unchanged copy from CUDApp `b774723f`), and `isa.om`, the Omega program that derives the tables by probing it. |
| `check/` | `reencode.om` checks the operand-field records against the forms, then rebuilds the 70 kernels that ran on the GB10 from the tables alone; `check.sh` compares them to the chip receipt and runs four planted-bug controls. Result: `check/CHECK.txt`. |
| `receipts/` | My chip logs and receipts behind every claim below, with `receipts/SHA256SUMS`. |
| `FIELD-MANUAL.md` | The DGX Spark findings that cost me weeks: symptom, document, measurement, fix, where to reproduce. |
| `REPRODUCE.md` | Commands for a GB10 owner, and for anyone without one. |
| `LEGAL.md` | Interoperability statement and what is deliberately not here. |

## What the receipts show

Each claim has a label: DEPLOYED, CHIP_TESTED (ran on the GB10), HOST_TESTED (ran on a CPU host). The labels say where the evidence came from; they are not qualification for production.

| # | Claim | Label | Receipt in this repo |
|---|---|---|---|
| E1 | On 21 October 2026 my 35 billion parameter model on the DGX Spark was served with zero CUDA libraries loaded. That served stack was my C implementation. This is a dated fact, not a claim about today. | DEPLOYED (2026-10-21) | `receipts/omega-mv/evidence/WHAT-OMEGA-IS-20261021/live-serve-no-cuda.txt` (home path redacted, see `REDACTION.txt`) |
| E2 | My own language, Omega, has its own sm_121 instruction encoder. Its machine code ran on the GB10: 1,048,576 of 1,048,576 values correct. The planted-bug control failed as it must (exit 1). | CHIP_TESTED (2026-10-27) | `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-hello.log`, `om-hello-control.log` |
| E3 | The Omega encoder and my C encoder produce byte-identical machine code for the 70 kernels the chip ran, and for 243 kernels on the host; 3 of 3 mutant encoders were caught. | CHIP_TESTED (70) + HOST_TESTED (243) | `.../chip-20261027T080240Z/kernels-om.sha256`, `kernels-c.sha256`, `kernels-om/*.bin`; `.../host/` |
| E6 | A vector add assembled by Omega's seed toolchain ran on the GB10 through my own launcher, no CUDA library. Caveat: the source tree had 3 uncommitted files. | CHIP_TESTED (2026-10-19/20) | `receipts/omega-mv/evidence/SEED-0/sm121/chip/` |
| E8 | No CUDA toolkit is needed or used. | CHIP_TESTED (diagnostic on the E2 run) | `.../chip-20261027T080240Z/om-doctor.log` |
| E9 | Nine FP32 operations match a frozen CPU sequence on all 4,294,967,296 inputs each, zero mismatches. This is parity, not correctly rounded maths; SIN and COS have a restricted domain. | CHIP_TESTED | `receipts/omega-mv/evidence/E1-TRANSC-GB10/` |
| E10 | Large chip workloads on my own (C) kernel builders: general GEMM (902 checks pass), attention (318 of 318 configurations). Not a qualification. | CHIP_TESTED | `receipts/cudapp/evidence/GEMM-GENERAL-00c9cf9/`, `ATTN-GENERAL-20261027-4d51f91f/`, `GEMM-TUNE-20261027/` |
| E12 | The paper: "Reverse Engineering the CUDA Software Stack: An Independently Implemented GPU Machine-Code Toolchain for the NVIDIA GB10". A preprint, not peer reviewed. | Published 2026-10-26 | https://doi.org/10.5281/zenodo.23677465 |

Two more results exist but are not in this repository, because their branches are not merged and not public yet: Omega-lowered kernels on the GB10 (645 checks, 0 failed; a planted bug fails 8) and the 35B model's gate kernel lowered by Omega giving golden output on a test server.

What is still NVIDIA's in the path: the open kernel modules `nvidia.ko` and `nvidia-uvm.ko` (version 580.173.02) and the signed GSP firmware the chip boots. Register allocation, kernel builders, runtime and driver client on the chip-tested path are still my C, not Omega. I used nvcc 13.0.88 and nvdisasm offline, on my own probe code, only as references.

## Check the tables in five minutes (any Linux machine, no GPU)

You need the pinned Omega seed compiler: omega-mv `seed/out/omc`, sha256 `3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194` (from rad:z6do9WDBhuSnvopDkgFdFr1yWA62).

```sh
rad clone rad:z631r2JJiVT8it4tST7RK24hpowi   # or: git clone https://www.aienos.com/rad/z631r2JJiVT8it4tST7RK24hpowi.git cuda-crack
cd cuda-crack
(cd receipts && sha256sum -c SHA256SUMS)   # every receipt is the file I published
OMC=/path/to/omc gen/run.sh             # regenerate isa/sm121-forms.txt from the Omega encoder
git diff --exit-code isa/               # the tables you got are the tables I committed
OMC=/path/to/omc check/check.sh         # check the field records, rebuild the 70 chip kernels from the tables, four red controls
```

`check.sh` must print `ALL CHECKS PASS`. First, every form's operand-field (D) records must cover its operand bits exactly once, with each linear field's start and width matching its mask. Then all 70 kernels (13,520 instructions) rebuilt from the tables must match the sha256 recorded on the chip run. Each of the four planted bugs must be caught:
- a table with one flipped fixed bit fails 67 kernels;
- one corrupted instruction matches no form;
- a field width off by one is refused;
- a field mask missing one bit is refused.

The 14 non-linear fields (`width` 0) are checked only by regenerating the table; see `isa/README.md`. To run the kernels on a GB10 yourself, see `REPRODUCE.md`.

## Links

- This repository: `rad:z631r2JJiVT8it4tST7RK24hpowi`, web: https://radicle.network/nodes/rosa.radicle.network/rad:z631r2JJiVT8it4tST7RK24hpowi
- Paper: https://doi.org/10.5281/zenodo.23677465
- CUDApp (CUDA++), the runtime, driver client and encoder: `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` at `b774723f`, web: https://radicle.network/nodes/rosa.radicle.network/rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP
- omega-mv, the Omega language and seed compiler: `rad:z6do9WDBhuSnvopDkgFdFr1yWA62`, web: https://radicle.network/nodes/rosa.radicle.network/rad:z6do9WDBhuSnvopDkgFdFr1yWA62
- The DGX Spark field manual on the web: https://www.aienos.com/spark/

## Why this is on Radicle

On 7 November 2026, between 08:14 and 08:20 UTC, GitHub's automated system flagged my organisation as "owner marked spammy" after the write volume of about 20 AI coding agents working in it. 109 repositories were hidden. My appeal is pending. I build this work by directing AI coding agents, and an automated filter cannot tell that apart from spam. So the method, the encoder and the receipts live here, on a peer-to-peer network, where no single company can switch them off.

GitHub censored me. I demand to be heard.

NVIDIA and CUDA are trademarks of NVIDIA Corporation. This project is not affiliated with or endorsed by NVIDIA. See `LEGAL.md`.
