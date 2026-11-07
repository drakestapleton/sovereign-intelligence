> ## I tried it GitHub's way. GitHub said no.
>
> I tried to be good and do it their way: everything public, on GitHub, in the open. 109 repositories in the `aien-dev` organization. On 7 November 2026 GitHub's answer was no. It flagged the organization, hid every repository and suspended my machine account.
>
> **So now I'm doing it the sovereign way, the way I should have done it from the start. Lesson learned.**
>
> My code isn't published on GitHub anymore. Each project is moving into its own repository on [Radicle](https://radicle.xyz), a peer-to-peer network that no single company can switch off, served from my own hardware. This repository is only a signpost. The Radicle links below are the only way in.

# Sovereign Intelligence

**Omega's seed-grown compiler and the front-door tools, written in Omega and grown from 408 hand-written bytes.**

Besides being the signpost, this repository carries two things: the Omega compiler, grown from a 408-byte program I wrote by hand in hex so that every binary built here can be traced back to bytes a person can read, and the front-door tools that list, fetch and check my projects. It does not hold the projects. Every project lives in its own Radicle repository, with its own key and its own history. Their Radicle links are [below](#projects); they are the only way in.

Clone this repository over Radicle, or read-only from my own seed without Radicle, then build it:

```sh
rad clone rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj
# without Radicle, read-only from my seed:
git clone https://www.aienos.com/rad/z2JJz4RDfZZxKGBLn6UhmW5p9VJQj.git sovereign-intelligence
cd sovereign-intelligence
sh build.sh
```

GitHub keeps, at most, a read-only mirror of this one repository so that people can still find me. Nothing is published there first.

## Built from the seed

`build.sh` grows the compiler, then builds and checks everything else with it. No C compiler, assembler or linker writes a byte. The one outside tool is a 24-line shell script, `seed/rung0/load0.sh`, that writes the first 408 bytes with `printf`. It ends with `RC=0` when every step passed.

| Claim | Label | Receipt |
|---|---|---|
| The Omega compiler, omc, grows from 408 hand-written bytes in four rungs (seed0, hex1, asm2, om4). It then compiles itself to a fixpoint, sha256 `45442c7d…080d`: omega-mv's compiler with two local changes, [`seed/LOCAL.patch`](seed/LOCAL.patch): the checked bulk word `count`, and `fma` refused on x86 only after its operands are typed. Without them the fixpoint is `cfd96b48…0a8d`, the same bytes as the compiler omega-mv commits. | HOST_TESTED, 2026-11-07, on x86-64, the AArch64 rungs under qemu-aarch64 8.2.2 | `build.sh` steps 1 and 2; pins in [`seed/PINS.tsv`](seed/PINS.tsv) |
| A native x86-64 Omega compiler, omc-x86 (sha256 `5e1f6e1f…3f19`), built by omc. It rebuilds itself byte for byte. Compiling omc.om with it gives exactly the AArch64 omc: the same compiler source, compiled through two instruction sets, agrees with itself. | HOST_TESTED, 2026-11-07, native x86-64 | step 3 |
| A one-word edit of the seed, and a one-line edit of the compiler, each change what is born, and the pins catch both. | HOST_TESTED, 2026-11-07 | step 4 |
| The front-door generator, [`compiler/si.om`](compiler/si.om), built for both targets, regenerates this README's generated blocks and [`repos.tsv`](repos.tsv) byte for byte. Both builds write the same `si.sh`. From the inputs of 2026-11-07 morning that was the script www.aienos.com/si served (sha256 `d939d394…a48f`); for the current inventory, `build.sh` prints its sha256 on the `NOTE si.sh sha256` line, and www.aienos.com/si does not serve it yet. | HOST_TESTED, 2026-11-07 | step 5 |
| The stack ledger, [`tools/ledger.om`](tools/ledger.om), gives the same counts on both targets as an independent oracle, over 68,575 files and 954,659,395 bytes of the recovered stack. | HOST_TESTED, 2026-11-07 | step 6 (fixture); [`stack/LEDGER.tsv`](stack/LEDGER.tsv) |
| All 110 worked examples of the Omega harness, and the 3 compiler regressions in [`tests/regress/`](tests/regress/), pass on AArch64 and on native x86-64: compile status, exit status, stdout and refusal line. | HOST_TESTED, 2026-11-07 | step 7, [`tests/examples.sh`](tests/examples.sh) |
| cuda-crack, a copy of its tables and Omega tools for this gate (its home stays its own Radicle repository, `rad:z631r2JJiVT8it4tST7RK24hpowi`): its Omega table generator, built by the seed-born compilers, regenerates all 471 sm_121 instruction forms. Its Omega reencoder rebuilds the 70 kernels that ran on the GB10 (13,520 instructions) from those tables alone, to the chip receipt's sha256. Its four planted bugs, now made by Omega (`check/mutate.om`, byte for byte the same as the original awk and od), are each caught. | HOST_TESTED, 2026-11-07, AArch64 and native x86-64; the kernels themselves ran on the chip on 2026-10-27 | step 8, [`gpu/cuda-crack/PROVENANCE.md`](gpu/cuda-crack/PROVENANCE.md) |
| The fork-push generator, [`tools/forkpush.om`](tools/forkpush.om), writes the same script on both targets from [`stack/FORKS.tsv`](stack/FORKS.tsv). It refuses 18 malformed manifests, and a branch marked private appears only as a comment, never as a push. | HOST_TESTED, 2026-11-07 | step 9 |
| The checked bulk word `count A off n v`, added to omc ([`seed/PROVENANCE.md`](seed/PROVENANCE.md#local-changes)): its 16 examples in [`tests/omc/`](tests/omc/) pass on both targets, and a compiler with its slice check deleted fails both trap-3 examples. Built with it, the stack ledger runs 6.1 times faster on native x86-64. | HOST_TESTED, 2026-11-07; the speed-up was measured over the 44 stack checkouts, outside the gate | steps 10 and 11; speed-up in [`seed/PROVENANCE.md`](seed/PROVENANCE.md#local-changes) |
| omega-mv's whole FR-9 x86 corpus ran with its x86-64 programs native for the first time: 16,179 rows, 15,499 PASS, 232 FAIL, 32 NOT_RUN, 30 MISSING_IMPLEMENTATION, 75 BLOCKED, 311 EXCLUDED. No FAIL is an x86 miscompile. 150 need om2 candidate compilers whose commits are not published; 46 are omega-bridge refusing the compiler's hash (all 49 bridge rows pass when that one pin is moved); 36 pin the AArch64 bytes of an older omc. The run also found a cross-target bug in omc, fixed in [`seed/LOCAL.patch`](seed/LOCAL.patch). | HOST_TESTED, 2026-11-07, native x86-64; the AArch64 side under qemu-aarch64 8.2.2 | [`evidence/x86-native/`](evidence/x86-native/) |

The whole gate takes 19.3 s on a 4-vCPU x86-64 cloud machine. There, omc-x86 compiles the 337,225-byte compiler in 0.10 s natively.

omega-mv records its x86-64 backend as a draft that has never run on x86-64 hardware (`docs/X86-LINUX.md`, FR-9). These are its first native runs: one cloud x86-64 host, covering the compiler itself, the programs above and omega-mv's full FR-9 fixture corpus. The oracle's verdict is still FAIL, and the reasons are in [`evidence/x86-native/`](evidence/x86-native/). Native x86 code is correct there but slow: omega-mv's SHA-256 runs at 20.6 MB/s on x86-64, against 57 MB/s for the AArch64 build under emulation, because the x86 backend keeps its values in memory. Nothing here has run on a GPU.

The only hardware result above is the cuda-crack kernels' chip run of 2026-10-27, which the gate checks by sha256 without a GPU. Hardware scope: GB10 only. The NVIDIA open kernel module 580.173.02 and NVIDIA-signed firmware remain in the path.

## What is in this repository

| Path | What it is |
|---|---|
| [`seed/`](seed/) | the compiler's sources, from the hand-written `seed0.hex` to `omc/omc.om`, copied from omega-mv with [provenance](seed/PROVENANCE.md) |
| [`build.sh`](build.sh) | the one build and gate |
| [`compiler/`](compiler/) | `si.om`, the front-door generator |
| [`tools/`](tools/) | `ledger.om`, the stack ledger; `forkpush.om`, which writes the script that sends my forks' branches to Radicle |
| [`harness/`](harness/) | the Omega harness: agent skills for writing correct Omega; `.claude/skills` points at it |
| [`tests/`](tests/) | the ledger and fork-push fixtures, the example runner, the compiler regressions and the examples of the words this repository adds to the compiler |
| [`gpu/cuda-crack/`](gpu/cuda-crack/) | a copy of cuda-crack's sm_121 encoding tables, Omega encoder and reencoder, and chip receipts, so the gate can rebuild the chip kernels; [provenance](gpu/cuda-crack/PROVENANCE.md). cuda-crack itself lives in its own Radicle repository |
| [`docs/`](docs/) | writing and sites from my personal account that have no Radicle project: the AIEN constitution, drakestapleton.com's source, and the old site as an archive |
| [`evidence/`](evidence/) | receipts of runs made from this repository, starting with the native x86-64 corpus run |
| [`stack/`](stack/) | the 44 recovered projects, their Radicle IDs and what each is made of; every branch of my personal forks and where it goes |

## The stack

The 44 projects are listed in [`stack/STACK.tsv`](stack/STACK.tsv), with their Radicle IDs and the heads recovered on 7 November 2026. Each one stays in its own Radicle repository; this repository only measures them. [`stack/LEDGER.tsv`](stack/LEDGER.tsv) counts what each one is written in: 902,624 lines of Omega and 2,518,966 lines of other languages (1,366,364 Rust, 862,390 C, 165,160 shell, 81,780 Python, 43,272 other). Omega is 26.3% of it today.

| Subsystem | Projects | Omega lines | Other lines | Omega share |
|---|---:|---:|---:|---:|
| `compiler` | 4 | 214,235 | 537,943 | 28.5% |
| `gpu` | 5 | 89,600 | 230,442 | 28.0% |
| `os` | 5 | 349,008 | 986,798 | 26.1% |
| `runtime` | 8 | 24,327 | 460,355 | 5.0% |
| `train` | 1 | 112,692 | 11,425 | 90.8% |
| `protocol` | 3 | 3,165 | 56,067 | 5.3% |
| `agents` | 10 | 20,249 | 139,462 | 12.7% |
| `evidence` | 3 | 12,584 | 18,852 | 40.0% |
| `docs` | 5 | 76,764 | 77,622 | 49.7% |

## What happened

I published everything on GitHub: 109 repositories in the `aien-dev` organization. On 7 November 2026, between 08:14 and 08:20 UTC, GitHub cancelled my Actions runs as "owner marked spammy", flagged the organization, hid every repository from the public and suspended my machine account, `aien-spark`. About 20 AI agents work on this project, and they had been pushing and opening pull requests faster than GitHub's abuse filters allow. I have appealed and the appeal is pending. My work now lives on [Radicle](https://radicle.xyz), a peer-to-peer network no single company can switch off, and on my own hardware. GitHub switched me off. I'm still here.

## I broke CUDA.

*My own language, Omega, writes NVIDIA GB10 machine code. It ran on the chip: 1,048,576 of 1,048,576 values correct, no CUDA toolkit, no nvcc, no PTX.*

Hardware scope: GB10 only. The NVIDIA open kernel module 580.173.02 and NVIDIA-signed firmware remain in the path.

**The code that broke CUDA**, on Radicle:

<!-- si:lead:begin -->
```sh
rad clone rad:z631r2JJiVT8it4tST7RK24hpowi   # cuda-crack
```

On the web: [radicle.network/nodes/rosa.radicle.network/rad:z631r2JJiVT8it4tST7RK24hpowi](https://radicle.network/nodes/rosa.radicle.network/rad:z631r2JJiVT8it4tST7RK24hpowi)
<!-- si:lead:end -->

**The DGX Spark manual NVIDIA didn't write:** [www.aienos.com/spark/](https://www.aienos.com/spark/)

I reverse engineered how NVIDIA's CUDA stack puts machine code on the NVIDIA GB10, the Blackwell chip in the DGX Spark, and built my own path without CUDA: a compiler back end, an sm_121 SASS encoder, a launcher and a driver client. The encoder is written in Omega, my own programming language, and it needs no nvcc. Its home is its own Radicle repository, cuda-crack, linked above; this repository is the front door to it.

```sh
curl -fsSL https://www.aienos.com/si | sh
```

That one command fetches every public project into one directory and checks each one against the commit listed below. [What it does, and how to read it first](#get-everything).

What I have not done yet: replace every CUDA library, run on GPUs other than the GB10, or remove NVIDIA's open kernel module and signed firmware. Status per piece: [www.aienos.com/cudaplusplus/](https://www.aienos.com/cudaplusplus/).

## Replicate it with any AI agent

<!-- si:agent:begin -->
<https://radicle.network/nodes/rosa.radicle.network/rad:z631r2JJiVT8it4tST7RK24hpowi/tree/AGENT-PROMPT.md>
<!-- si:agent:end -->

Give this file to any coding agent; it fetches everything from Radicle, rebuilds the compiler from seed and reproduces every result.

## What I proved, and at which level

Each line carries its evidence label. CHIP_TESTED means it ran on the GB10 with a receipt; DEPLOYED means it served the live model on that date; HOST_TESTED means it ran on a CPU only.

Hardware scope: GB10 only. The NVIDIA open kernel module 580.173.02 and NVIDIA-signed firmware remain in the path.

| Claim | Label | Receipt |
|---|---|---|
| My own language, Omega, has its own sm_121 instruction encoder. Its machine code ran on the GB10: 1,048,576 of 1,048,576 values correct. A planted-bug control failed, as it should. No CUDA toolkit was needed or used. | CHIP_TESTED, 2026-10-27 | CUDApp `evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/` |
| The Omega encoder and my C encoder produce byte-identical machine code for the 70 kernels the chip ran, and for 243 kernels on the host. | CHIP_TESTED (70), HOST_TESTED (243) | same directory, `kernels-om.sha256`, `kernels-c.sha256`, `host/corpus.log` |
| On 21 October 2026 my 35 billion parameter model on the DGX Spark was served with zero CUDA libraries loaded. That was my C GPU stack, on that date. | DEPLOYED, 2026-10-21 | omega-mv `evidence/WHAT-OMEGA-IS-20261021/live-serve-no-cuda.txt` |
| Kernels whose GPU lowering is written in Omega ran on the GB10: 645 checks, 0 failed. A planted bug fails 8 of them. | CHIP_TESTED, 2026-10-27, on a draft branch | not public yet; it goes public when the branch is merged |
| A vector add assembled by Omega's seed toolchain, grown from hand-written bytes, ran on the GB10 through my own launcher, no CUDA library. | CHIP_TESTED, 2026-10-19 (from a working tree with 3 uncommitted files) | omega-mv `evidence/SEED-0/sm121/chip/` |
| Exhaustive GPU and CPU parity for nine FP32 operations: 4,294,967,296 inputs each, zero mismatches. This is parity with a fixed CPU sequence, not correctly rounded maths. | CHIP_TESTED | omega-mv `evidence/E1-TRANSC-GB10/` |

CUDApp is `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` at `b774723f`; omega-mv is `rad:z6do9WDBhuSnvopDkgFdFr1yWA62` at `943d9555`. I built this by directing AI coding agents.

## What is still NVIDIA's

- NVIDIA's open kernel modules, `nvidia.ko` and `nvidia-uvm.ko`, version 580.173.02. CUDA++ refuses other versions.
- NVIDIA's signed GSP firmware. The GPU checks its signature and boots nothing else.
- NVIDIA's tools were used offline, as references only: nvcc 13.0.88 as an oracle for learning encodings, and nvdisasm to read my bytes back, never to make them.

## What I have not done yet

- It does not replace the CUDA libraries as a whole. They are covered only in part.
- It runs on one chip family, the GB10. No other GPU has run it.
- Not every step from Omega source to running kernel is Omega on the chip yet. Register allocation, kernel builders, runtime and driver client are still C in the chip-tested path.
- I make no speed comparison with CUDA or anything else.

## The DGX Spark manual NVIDIA didn't write

What I learned driving the GB10 without libcuda is going up at [www.aienos.com/spark/](https://www.aienos.com/spark/), every finding with its evidence level. Four of them:

- **Everything libcuda does to the hardware goes through ioctls on three device files:** `/dev/nvidiactl`, `/dev/nvidia<minor>` and `/dev/nvidia-uvm`. NVIDIA's open kernel module defines every call in public MIT headers. CHIP_TESTED; DEPLOYED on 2026-10-21.
- **GPU-cacheable system memory is not coherent with CPU mappings.** NVIDIA's own header says "gpu uncached for system memory" is the default, and cached system memory "will not be coherent with direct CPU mappings" ([`nvos.h` lines 1116 to 1118 at 580.173.02](https://github.com/NVIDIA/open-gpu-kernel-modules/blob/580.173.02/src/common/sdk/nvidia/inc/nvos.h#L1116-L1118)). DOCUMENTED.
- **NVIDIA does not publish SASS encodings.** I recovered them three ways: my own probe kernels compiled offline with nvcc and read back one changed detail at a time; Mesa's NAK sources, with no code copied; and acceptance only when the chip runs the encoding correctly. CHIP_TESTED, as a method.
- **For bulk traffic, DRAM is the ceiling, not the CPU to GPU link.** The C2C link reports 8 links at 43.125 GB/s, 345 GB/s per direction, more than the 273 GB/s of DRAM. MEASURED by NVIDIA's tool and a CPU-side benchmark; the GPU-side measurement is still pending.

Hardware scope: GB10 only. The NVIDIA open kernel module 580.173.02 and NVIDIA-signed firmware remain in the path.

## Read the paper

[Reverse Engineering the CUDA Software Stack: An Independently Implemented GPU Machine-Code Toolchain for the NVIDIA GB10](https://doi.org/10.5281/zenodo.23677465), version 2, 26 October 2026, DOI [10.5281/zenodo.23677465](https://doi.org/10.5281/zenodo.23677465). A preprint, not peer reviewed. Version 2 lists the corrections to version 1. To cite this work, use [CITATION.cff](CITATION.cff).

## Get everything

```sh
curl -fsSL https://www.aienos.com/si | sh
```

The script is served from my own server, not from GitHub. It:

1. prints what it is about to do;
2. makes one directory, `./sovereign-intelligence` (set `SI_DIR` to choose another), and touches nothing else. It needs no sudo and refuses to run as root;
3. fetches each project with `rad clone <RID>` when you have Radicle, peer-to-peer from whichever seed has it. Without Radicle it uses a read-only `git clone` from my seed at `https://www.aienos.com/rad/`, then from the public Radicle seed `rosa.radicle.network`;
4. checks out the commit the table below names for each project, so you get exactly what I published even when a project has moved on since, and prints `OK` or `MISMATCH`. A missing commit is a mismatch and makes it exit with an error.

If a project cannot be fetched, it prints the project's Radicle ID and Radicle's official installer, `curl -sSf https://radicle.xyz/install | sh`. It runs that installer only if you set `SI_INSTALL_RAD=1`.

`SI_ONLY=core` fetches only the seven core projects:

```sh
curl -fsSL https://www.aienos.com/si | SI_ONLY=core sh
```

You don't have to pipe anything into a shell. Download it, read it, then run it:

```sh
curl -fsSL https://www.aienos.com/si -o si.sh
less si.sh
sh si.sh
```

The script is generated, never written by hand. [`compiler/si.om`](compiler/si.om), an Omega program, builds it, the project table below and [`repos.tsv`](repos.tsv) from my Radicle node's inventory. [`compiler/README.md`](compiler/README.md) shows how to rebuild all three and compare their sha256 with what is served.

Or take single projects straight from Radicle:

```sh
rad clone rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP   # CUDApp (CUDA++)
rad clone rad:z6do9WDBhuSnvopDkgFdFr1yWA62    # omega-mv, the Omega compiler
rad clone rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj   # sovereign-intelligence: the seed-grown compiler and this front door
```

## Projects

<!-- si:index:begin -->
**28 public projects**, 7 of them core, listed by `compiler/si.om` from my Radicle node's inventory. Each project's home is its own Radicle repository; this table only links to them. Clone one peer-to-peer with `rad clone`, or read-only with `git clone` from its mirror on my own seed. Full commit ids are in [`repos.tsv`](repos.tsv).

| # | Project | Radicle ID | Get it | Head | About |
|---:|---|---|---|---|---|
| 1 | **aienux** (core) | `rad:z2Q6ob2gL6Qo5oUMpyehukayVF7mN` | `rad clone rad:z2Q6ob2gL6Qo5oUMpyehukayVF7mN`, [git mirror](https://www.aienos.com/rad/z2Q6ob2gL6Qo5oUMpyehukayVF7mN.git) | `fab52c1` | Aienux, the AienOS kernel: boot, scheduling, IPC and capability boundaries. Pre-alpha; host, emulator and physical evidence are labelled separately. |
| 2 | **omega-mv** (core) | `rad:z6do9WDBhuSnvopDkgFdFr1yWA62` | `rad clone rad:z6do9WDBhuSnvopDkgFdFr1yWA62`, [git mirror](https://www.aienos.com/rad/z6do9WDBhuSnvopDkgFdFr1yWA62.git) | `1a7aa1e` | Omega: a language for verified programs, semantic identity and machine realization. Seed-born work and existing implementations have distinct provenance. |
| 3 | **aien-sovereign-core-mv** (core) | `rad:z44GqrPVAPjZkhoD2MWVjqy18ighN` | `rad clone rad:z44GqrPVAPjZkhoD2MWVjqy18ighN`, [git mirror](https://www.aienos.com/rad/z44GqrPVAPjZkhoD2MWVjqy18ighN.git) | `6af0d0d` | AienOS host runtime: inference scheduling, paged KV state, the aien CLI and Spark verification tooling. Its inference engine is in alpha testing (DGX Spark GB10); Omega is the implementation destination. |
| 4 | **physics-mv** (core) | `rad:z49She8eifZpLd2aiSvk2pph3DMUo` | `rad clone rad:z49She8eifZpLd2aiSvk2pph3DMUo`, [git mirror](https://www.aienos.com/rad/z49She8eifZpLd2aiSvk2pph3DMUo.git) | `4626f28` | FORGE: request-bound machine realization, providers and verification for AienOS. Host, simulated and GB10 hardware paths have separate evidence. |
| 5 | **aien-architecture-mv** (core) | `rad:z37zcFYooiuCCZsf5L74eeFJYiwWM` | `rad clone rad:z37zcFYooiuCCZsf5L74eeFJYiwWM`, [git mirror](https://www.aienos.com/rad/z37zcFYooiuCCZsf5L74eeFJYiwWM.git) | `945a366` | Canonical architecture for the AIEN ecosystem: flows, boundaries, ADRs, and the map from design to implementation repositories. |
| 6 | **aien-train** (core) | `rad:zKrfazKqYNFuXDDkYdptxJicGLEq` | `rad clone rad:zKrfazKqYNFuXDDkYdptxJicGLEq`, [git mirror](https://www.aienos.com/rad/zKrfazKqYNFuXDDkYdptxJicGLEq.git) | `bf8459f` | AIEN training programme: language-model history, GB10 constraints and the route to training on the project engine. Plans and runnable checks are distinguished. |
| 7 | **CUDApp** (core) | `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` | `rad clone rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP`, [git mirror](https://www.aienos.com/rad/z4RxD8vXigmWg61nM8miQ8DVPAXEP.git) | `f1b50cb` | CUDA++: AIEN’s GPU machine-code toolchain, runtime and driver client for NVIDIA GPUs without the CUDA toolkit. Hardware coverage and driver replacement limits are explicit. |
| 8 | **.github** | `rad:z36odegYfUoEoX8xwjJ4so68jb1W3` | `rad clone rad:z36odegYfUoEoX8xwjJ4so68jb1W3`, [git mirror](https://www.aienos.com/rad/z36odegYfUoEoX8xwjJ4so68jb1W3.git) | `e146b84` | AienOS organization profile, contribution guidance and GitHub community templates. Source, lessons and verification evidence are linked explicitly. |
| 9 | **aegis-runtime-mv** | `rad:z6hhF5wGXCqvkcvxYdcBb12qm3FB` | `rad clone rad:z6hhF5wGXCqvkcvxYdcBb12qm3FB`, [git mirror](https://www.aienos.com/rad/z6hhF5wGXCqvkcvxYdcBb12qm3FB.git) | `0dfd941` | Native Rust agent runtime: Axum WebSocket/SSE/REST gateway, heartbeat scheduler, dependency-aware task workflow, SQLite storage. Attachment of AienOS. Pre-alpha. |
| 10 | **aien** | `rad:zDTnULpiVMniD2etkbUozUP5mn6U` | `rad clone rad:zDTnULpiVMniD2etkbUozUP5mn6U`, [git mirror](https://www.aienos.com/rad/zDTnULpiVMniD2etkbUozUP5mn6U.git) | `be2b65c` | aien-dev/aien (Radicle canonical mirror during the GitHub hold) |
| 11 | **aien-protocols-mv** | `rad:zzxgxYRc5tw6VwYXkQNLC2hqKkfb` | `rad clone rad:zzxgxYRc5tw6VwYXkQNLC2hqKkfb`, [git mirror](https://www.aienos.com/rad/zzxgxYRc5tw6VwYXkQNLC2hqKkfb.git) | `83632c6` | Canonical specifications, wire protocols, and schemas for the AIEN sovereign ecosystem |
| 12 | **aien-receipts** | `rad:z4HXNamwwXyfN11ZBJXAQpdMKvojz` | `rad clone rad:z4HXNamwwXyfN11ZBJXAQpdMKvojz`, [git mirror](https://www.aienos.com/rad/z4HXNamwwXyfN11ZBJXAQpdMKvojz.git) | `bda984f` | Append-only AIEN verification receipts, indexed by repository and exact source commit. Read verdicts, signatures and retained logs before making a claim. |
| 13 | **aien-rig** | `rad:z2MPnsBZpJYeJJq39EXz1SYzLL7mc` | `rad clone rad:z2MPnsBZpJYeJJq39EXz1SYzLL7mc`, [git mirror](https://www.aienos.com/rad/z2MPnsBZpJYeJJq39EXz1SYzLL7mc.git) | `476c4ac` | AIEN Rig: local AI and frame-rate tuning for RTX gaming PCs. Pre-alpha; host fixtures and target-card qualification are separate. |
| 14 | **aienix** | `rad:zV8VdbBDCPEZePcnBiseNyym3Wnk` | `rad clone rad:zV8VdbBDCPEZePcnBiseNyym3Wnk`, [git mirror](https://www.aienos.com/rad/zV8VdbBDCPEZePcnBiseNyym3Wnk.git) | `0dce79d` | AienOS front door: pinned repositories, source-linked lessons and verification paths. AienOS is in alpha testing; components remain separate and each states its own status. |
| 15 | **aienos.com** | `rad:z3iwnx2pktbGhnfBpJSsaFcTmKgHU` | `rad clone rad:z3iwnx2pktbGhnfBpJSsaFcTmKgHU`, [git mirror](https://www.aienos.com/rad/z3iwnx2pktbGhnfBpJSsaFcTmKgHU.git) | `3fa9623` | Source of www.aienos.com, served from my own hardware |
| 16 | **benchmarks-mv** | `rad:z2nYCN9XZAPjNohqT8bz46rcs9zvZ` | `rad clone rad:z2nYCN9XZAPjNohqT8bz46rcs9zvZ`, [git mirror](https://www.aienos.com/rad/z2nYCN9XZAPjNohqT8bz46rcs9zvZ.git) | `ecfd238` | Measurement harnesses and evidence bundles for AIEN on the NVIDIA DGX Spark GB10. Speed is reported against the machine's physical limit and my own previous run. Attachment of AienOS. |
| 17 | **cuda-crack** | `rad:z631r2JJiVT8it4tST7RK24hpowi` | `rad clone rad:z631r2JJiVT8it4tST7RK24hpowi`, [git mirror](https://www.aienos.com/rad/z631r2JJiVT8it4tST7RK24hpowi.git) | `7e3c9a7` | I broke CUDA: GB10 sm_121 machine code without the CUDA toolkit - method, encoder tables, receipts |
| 18 | **gpu-head-to-head** | `rad:z3ZSvMF8VFFGa5FyyKXGh4Vv6NBpS` | `rad clone rad:z3ZSvMF8VFFGa5FyyKXGh4Vv6NBpS`, [git mirror](https://www.aienos.com/rad/z3ZSvMF8VFFGa5FyyKXGh4Vv6NBpS.git) | `173c9b4` | aien-dev/gpu-head-to-head (Radicle canonical mirror during the GitHub hold) |
| 19 | **interplane-mv** | `rad:zNhNbqYvgSBEHBq9vvE8xpbcBzGa` | `rad clone rad:zNhNbqYvgSBEHBq9vvE8xpbcBzGa`, [git mirror](https://www.aienos.com/rad/zNhNbqYvgSBEHBq9vvE8xpbcBzGa.git) | `6aa1eec` | INTERPLANE: open interoperability protocol between AI models and agent runtimes. Models express intent. Runtimes retain authority. |
| 20 | **interplane.io** | `rad:z399yKvnXcBQNkKoq86iBDgTvQ5QV` | `rad clone rad:z399yKvnXcBQNkKoq86iBDgTvQ5QV`, [git mirror](https://www.aienos.com/rad/z399yKvnXcBQNkKoq86iBDgTvQ5QV.git) | `18ee1ee` | Source of interplane.io: a Rust generator that renders the page from the protocol repository's public record, deployed hourly from the Spark. |
| 21 | **omega-blas** | `rad:z47VdC9EFsF4dFyH1QJ1C2JNJK4JS` | `rad clone rad:z47VdC9EFsF4dFyH1QJ1C2JNJK4JS`, [git mirror](https://www.aienos.com/rad/z47VdC9EFsF4dFyH1QJ1C2JNJK4JS.git) | `e3f1b40` | aien-dev/omega-blas (Radicle canonical mirror during the GitHub hold) |
| 22 | **omega-bridge** | `rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y` | `rad clone rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y`, [git mirror](https://www.aienos.com/rad/z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y.git) | `f6b7cc4` | Omega-first language interoperability: checked conversion backends and native language bindings |
| 23 | **omega-gpu-driver** | `rad:z2xjD5kxUTTBNCryJ6rg9QXpemzei` | `rad clone rad:z2xjD5kxUTTBNCryJ6rg9QXpemzei`, [git mirror](https://www.aienos.com/rad/z2xjD5kxUTTBNCryJ6rg9QXpemzei.git) | `1ac3589` | aien-dev/omega-gpu-driver (Radicle canonical mirror during the GitHub hold) |
| 24 | **omega-harness** | `rad:z39gvwWsnkRZsAConQLjaKiNVLHfW` | `rad clone rad:z39gvwWsnkRZsAConQLjaKiNVLHfW`, [git mirror](https://www.aienos.com/rad/z39gvwWsnkRZsAConQLjaKiNVLHfW.git) | `b1906ae` | Agent skills for operating, encoding and communicating in Omega (.om) and the AIEN repositories |
| 25 | **omega-mcp** | `rad:z3e8UBQVfwEcESJrcTWEbyMAHWFBZ` | `rad clone rad:z3e8UBQVfwEcESJrcTWEbyMAHWFBZ`, [git mirror](https://www.aienos.com/rad/z3e8UBQVfwEcESJrcTWEbyMAHWFBZ.git) | `4b37ec2` | aien-dev/omega-mcp (Radicle canonical mirror during the GitHub hold) |
| 26 | **omega-mission** | `rad:z6HYc7ot5JZD8FSfvU77pWdMUdru` | `rad clone rad:z6HYc7ot5JZD8FSfvU77pWdMUdru`, [git mirror](https://www.aienos.com/rad/z6HYc7ot5JZD8FSfvU77pWdMUdru.git) | `9cf8dc7` | Omega Mission: seeded-Omega mission orchestrator (hash-chained journal, tiered command checks). Host-tested; live dispatch not yet run. |
| 27 | **spark-rsi-mv** | `rad:z4AauBRPXzPNMiAoHZpRpyCee61A2` | `rad clone rad:z4AauBRPXzPNMiAoHZpRpyCee61A2`, [git mirror](https://www.aienos.com/rad/z4AauBRPXzPNMiAoHZpRpyCee61A2.git) | `7d94a1f` | Native Rust recursive self-improvement engine with paired bootstrap evaluation and cryptographic ledger |
| 28 | **synapse** | `rad:zMGRREr2tmtRqpo4mMjpzkZdUGXN` | `rad clone rad:zMGRREr2tmtRqpo4mMjpzkZdUGXN`, [git mirror](https://www.aienos.com/rad/zMGRREr2tmtRqpo4mMjpzkZdUGXN.git) | `fbcf23d` | Synapse: agent-native changesets and coordination, with Git and Radicle interoperability. A component of the AienOS ecosystem. |
<!-- si:index:end -->

Open any of them on the web at `https://radicle.network/nodes/rosa.radicle.network/<RID>`. The CUDApp and cuda-crack rows describe GPU machine-code work. Hardware scope: GB10 only. The NVIDIA open kernel module 580.173.02 and NVIDIA-signed firmware remain in the path.

## Where everything lives now

The morning GitHub switched me off, every public project moved to Radicle, one Radicle repository per project, seeded from my own machines, each with its own key. That is where each project lives, and where it stays. My website, [www.aienos.com](https://www.aienos.com), runs on my own hardware. This repository carries Omega's seed-grown compiler and the front-door tools; GitHub keeps, at most, a read-only mirror of it so that people can still find me. Its own programs are Omega. The exceptions are the shell that starts the seed and runs the gate (`seed/rung0/load0.sh`, `build.sh`, `tests/examples.sh`, `tools/ledger-refresh.sh`), the scripts that ran the receipts in `evidence/`, and the code inside the copies it carries (`gpu/cuda-crack/`, `docs/`, `harness/`) that has not been rewritten yet; each copy's `PROVENANCE.md` lists what is left and what replaces it. The full account is at [www.aienos.com/switched-off/](https://www.aienos.com/switched-off/).

## Run your own seed

Every copy makes the project harder to switch off. With [Radicle](https://radicle.xyz) installed:

```sh
curl -sSf https://radicle.xyz/install | sh   # Radicle's official installer
rad auth                                     # make your Radicle key
rad node start
tail -n +2 repos.tsv | cut -f2 | while read -r rid; do rad seed "$rid"; done
```

Your node then fetches every public project, keeps it current and serves it to other peers.

## All my papers

All are preprints, not peer reviewed. Most are on [www.aienos.com/research/](https://www.aienos.com/research/):

- [Reverse Engineering the CUDA Software Stack](https://doi.org/10.5281/zenodo.23677465) (version 2, 2026-10-26, DOI 10.5281/zenodo.23677465). Not on www.aienos.com yet, so the link is its DOI.
- [A Call to Humanity: Breaking the CUDA Stranglehold on the Hardware Market](https://www.aienos.com/call-to-humanity/) (open letter, 2026-10-24, DOI 10.5281/zenodo.23614947)
- [Computing Machinery and Understanding: From the Imitation Game to the Turing](https://www.aienos.com/research/computing-machinery-and-understanding/) (2026-10-17, DOI 10.5281/zenodo.23437498)
- [Computing Machinery and Understanding: The Turing as a Measure Emerging from AIEN](https://www.aienos.com/research/computing-machinery-and-understanding-emergence/) (2026-10-17, DOI 10.5281/zenodo.23437568)
- [The Turing: A Unit of Verified Explanatory Gain](https://www.aienos.com/research/the-turing-brief/) (2026-10-02, DOI 10.5281/zenodo.23547801)
- [The Turing Discovery Gap Conjecture](https://www.aienos.com/research/turing-discovery-gap-conjecture/) (2026-10-02, DOI 10.5281/zenodo.23547803)
- [The Crumb Doctrine](https://www.aienos.com/research/crumb-doctrine/) (2026-10-02, DOI 10.5281/zenodo.23547808)
- [The Stapleton Doctrine: A Personal Philosophy of AI Architecture and Programming](https://www.aienos.com/research/the-stapleton-doctrine/) (2026-10-02, DOI 10.5281/zenodo.23547805)
- [Omega: A Programming Language Built for Verified Programs](https://www.aienos.com/research/omega-language/) (2026-10-02, DOI 10.5281/zenodo.23547811). The design proposal; it predates the compiler.
- [The Atemporal AIEN Postulate: Causal Semantics Without Clocks](https://www.aienos.com/research/atemporal-aien-postulate/) (2026-10-02, DOI 10.5281/zenodo.23547813)
- [The AIEN Papers](https://www.aienos.com/research/the-aien-papers/), the collected volume
- [The Token Is the Instruction: Large Language Models as Programming Languages, and Omega as the Next Substrate](https://doi.org/10.5281/zenodo.23644703) (2026-10-25, position paper). Not on www.aienos.com yet, so the link is its DOI.
- [The Ω-Framework: An Observer-Dependent Resolution of Singularities in General Relativity and Quantum Gravity](https://doi.org/10.5281/zenodo.23505156) (2026-10-20). Not on www.aienos.com yet, so the link is its DOI.

Two technical protocols live in omega-mv: the Turing Instrument Calibration and Validation Program (`docs/turing/protocols/turing-instrument-calibration-validation-protocol-v1-0.tex`) and the Turing Laboratory Execution Protocol (`docs/turing/protocols/turing-laboratory-execution-protocol-v1-0.tex`).

## Licence and trademarks

This repository is under the Apache License 2.0, in [LICENSE](LICENSE). Each project carries its own licence.

NVIDIA, CUDA, DGX and GB10 are trademarks of NVIDIA Corporation. This project is not affiliated with or endorsed by NVIDIA.
