<div align="center">

<img src="aien-butterfly.webp" alt="AIEN butterfly mark" width="180" />

# AIEN

**A sovereign computing stack, built in the open: its own operating system, its own compiler and reaction runtime, its own machine realization layer.**

[aienos.com](https://www.aienos.com) · [drakestapleton.com](https://www.drakestapleton.com) · [aien@aienos.com](mailto:aien@aienos.com)

[![License: AGPL-3.0-or-later](https://img.shields.io/badge/License-AGPL--3.0--or--later-blue.svg)](LICENSE)

</div>

---

## What this is

AIEN is an attempt to build a persistent, local computing system from the first instruction upward, on an NVIDIA DGX Spark (Grace Blackwell GB10), with no outside organization required to boot, build, trust or recover it. The founding principle: closest to the metal, fastest wins. Build what is missing.

Built by [Drake Stapleton](https://www.drakestapleton.com) with AI collaborators. Contributions and hard questions are welcome.

## Status at a glance (2026-10-13)

This is research-grade, pre-alpha software. Nothing here is qualified on real hardware as a finished system. Every line below links to the record it comes from; if the record and this page disagree, the record wins. Evidence labels: CPU = host tests on the Spark, GB10 = Linux-hosted GPU runs on the DGX Spark, QEMU = emulated. AIENOS evidence is QEMU and host results plus one native boot: the M2 Rust kernel ran on Machine 1 at EL2 with no Linux underneath, Secure Boot off ([M2 evidence](https://github.com/aien-dev/aienos/blob/main/evidence/m2_first_boot_2026-09-24.md)). The C kernel has not booted natively on the DGX Spark; it has run on a Raspberry Pi 5 (see below).

**Works today, with receipts**

- Omega reaction runtime on the GB10: the R1 to R15 qualification ladder and the R16 G7 and G8 gates passed on frozen candidate CAND-3; the R15 silicon result is a measured PASS under a declared exception (Secure Boot off) and is not yet unconditional ([CAND-3 gates](https://github.com/aien-dev/aien-architecture/blob/main/qualification/candidates/CAND-3.gates.md), sections 6 to 8).
- Single-machine candidate CAND-4 (omega, aienos, sovereign-core, physics pinned and reproduced byte-for-byte in two clean builds): qualification VERDICT PASS with recorded limits; internal-only because its model is Llama 3.2, not an open licence ([CAND-4 gates](https://github.com/aien-dev/aien-architecture/blob/main/qualification/candidates/CAND-4.gates.md), [execution plan addendum 2026-10-06](https://github.com/aien-dev/aien-architecture/blob/main/CURRENT_EXECUTION_PLAN.md)).
- AIENOS C kernel in the emulator: all 24 QEMU gates PASS, 0 NOT_RUN, at aienos `7f0de7e` ([receipt](https://github.com/aien-dev/aienos/blob/main/evidence/ck_gates_29ed03c97454354a18676f768273dd7f7a8e15462c4be1939d9994d277d0d639.json), [gate list](https://github.com/aien-dev/aienos/blob/main/native/kernel/GATES.md)). Merged since 2026-10-04, all QEMU only: operator keyboard input and recovery access, one-time boot rollback (8 cases), multi-segment PCI discovery with NVMe found and bound, SMMU stream tables, and the OSH shell core running as kernel tasks with a step trace equal to Linux.
- AIENOS C kernel on a Raspberry Pi 5 (2026-10-13, a test board, not the Spark): it boots with no Linux underneath, brings up the interrupt controller, timer and all four cores, runs user programs, and writes the microSD card with its own driver, reading the same bytes back after a reboot ([aienos #345](https://github.com/aien-dev/aienos/pull/345), [#346](https://github.com/aien-dev/aienos/pull/346)). The run logs are summarized in those pull requests and are not yet committed as evidence files; the sealed Store has not run on the Pi.
- GPU native path: structured reconvergence (BSSY/BSYNC) implemented with GB10 T1 to T4 PASS ([omega #310](https://github.com/aien-dev/omega/pull/310)); E1 numerics closed on the chip ([omega README](https://github.com/aien-dev/omega#current-state)); Prime Drag Race sieve: the native GB10 path runs 20.3x its own frozen starting point ([campaign](https://github.com/aien-dev/benchmarks/blob/main/prime-drag-race/CAMPAIGN-2026-10-05.md)).
- Legacy Rust runtime (aien-sovereign-core): builds, lints and tests green in CI ([CI](https://github.com/aien-dev/aien-sovereign-core/actions)); policy decides before any tool runs ([authority tests](https://github.com/aien-dev/aien-sovereign-core/blob/main/crates/aien-mcp/tests/authority.rs)); the approval desk is required by default and composed proposals need authenticated approval with replay protection; ALLEN identity, persona and scoped memory run host-side under the accepted ADR 0035 ([ADR](https://github.com/aien-dev/aien-architecture/blob/main/docs/adr/0035-persistent-cognitive-entity-boundary-allen.md)).
- INTERPLANE 0.3.0: trust report with all gates PASS ([report](https://github.com/aien-dev/interplane/blob/main/docs/REPORT-0.3.md), [status](https://github.com/aien-dev/interplane/blob/main/STATUS.md)); Verifiable Autonomous Computing milestones M1 to M5 done on 2026-10-08: a scripted model turn chained to a judged, approved and acknowledged file effect, with an independently judged change through the approved path (CPU); every recorded run is scripted and ends `PASS_LABELLED_INCOMPLETE`, and a real model is a later row ([VAC plan](https://github.com/aien-dev/aien-architecture/blob/main/docs/plans/vac/PLAN.md)).

**Experimental (host only, not in a qualified build)**

- Capability Graph, Skill Router, J-Space branch store, machine identity and a loopback Fabric slice exist in omega and run on the host ([implementation status](https://github.com/aien-dev/aien-architecture/blob/main/docs/02-implementation-status.md)).
- Omega Systems Core compiler: OSC-1 and OSC-2 implemented with host receipts, OSC-3 in progress; there is no general Omega compiler and it is not self-hosting ([omega README](https://github.com/aien-dev/omega#current-state)). The OSC unit artifact container v1 is frozen with conformance vectors ([aien-protocols](https://github.com/aien-dev/aien-protocols/blob/main/specs/osc-unit-artifact/OSC_UNIT_ARTIFACT.md)), and OSH, the Omega shell, runs on the Linux host with a durable intent and outcome journal ([OSH record](https://github.com/aien-dev/aien-architecture/blob/main/docs/plans/osh-r1/OSH-R1.md)).
- Open-licence model path: Qwen3-4B-Instruct-2507 matches the reference on the CPU and, with the page cache dropped once, on the GB10 for one prefill. Its frozen campaign v5 is FAIL: 8 of 11 tasks pass, three refused by the requirement checks ([verdict](https://github.com/aien-dev/aien-sovereign-core/blob/main/docs/campaigns/open-model-qwen3/VERDICT-v5.md)). SmolLM2 also failed. No open-licence model has passed yet.
- FORGE machine realization: the substrate-neutral descriptor contract (AR1) passed its gates ([physics](https://github.com/aien-dev/physics)).
- AT-0, a clock-free execution charter with frozen case and result contracts, was REVIEWED on 2026-10-10: software conformance PASS on the tested classes, blinded qualification INCONCLUSIVE (UNISOLATED), physical claims NOT TESTED ([charter](https://github.com/aien-dev/aien-architecture/blob/main/docs/plans/atemporal/AT0_CHARTER.md), [results](https://github.com/aien-dev/aien-architecture/blob/main/docs/plans/atemporal/AT0_RESULTS.md)). Its follow-on AT-1 is also REVIEWED ([AT-1 charter](https://github.com/aien-dev/aien-architecture/blob/main/docs/plans/atemporal/AT1_CHARTER.md)).

**Blocked or not done**

- The C kernel has never booted on the DGX Spark; real boot needs the operator present and a recovery stick. The native work order is decided (NEXT-PHASE-3 governs: input, rollback, storage, trust, native inference, native GB10 compute) and every physical step needs separate operator authorization ([execution plan addendum 2026-10-08 late](https://github.com/aien-dev/aien-architecture/blob/main/CURRENT_EXECUTION_PLAN.md)).
- Trust chain and encrypted storage (TRUST-1, AIENOS M5) are NOT_QUALIFIED; the attended package has host validation only ([gate matrix](https://github.com/aien-dev/aienos/blob/main/docs/TRUST-1-M5-GATE-MATRIX.md)).
- Native GB10 compute from AIENOS (replacing the Linux driver dependency) is in progress and QEMU only ([aienos #286](https://github.com/aien-dev/aienos/issues/286)).
- No public release exists. The two release gates the operator set, an offline signing key and a physical Spark rollback, are both owed; the tagged release path is fail-closed and nothing has been published.
- All performance figures published before 23 September 2026 are withdrawn until regenerated with a reproducible command and an evidence bundle ([benchmarks](https://github.com/aien-dev/benchmarks)).

Status words used everywhere: PASS, FAIL, NOT_RUN, BLOCKED_HARDWARE, BLOCKED_OPERATOR, MISSING_IMPLEMENTATION. A passing emulator run is never described as hardware qualification. Authority for what is done and what is not:

- [Plan authority](https://github.com/aien-dev/aien-architecture/blob/main/PLAN_AUTHORITY.md): which document wins
- [Current execution plan](https://github.com/aien-dev/aien-architecture/blob/main/CURRENT_EXECUTION_PLAN.md): what is being done now, with receipts
- [Milestone registry](https://github.com/aien-dev/aien-architecture/blob/main/doctrine/ROADMAP.md): milestone status

## The repositories

| Repository | What it is |
| :--- | :--- |
| [aien-architecture](https://github.com/aien-dev/aien-architecture) | The authority for whole-system design, milestone status and sequencing. Start here. |
| [aienos](https://github.com/aien-dev/aienos) | AIENOS: our own kernel and operating system, replacing Linux on the DGX Spark. Contributors wanted. |
| [omega](https://github.com/aien-dev/omega) | The reaction runtime and compiler (Omega Systems Core). The current implementation is C. |
| [physics](https://github.com/aien-dev/physics) | Machine realization (FORGE) and the historical Atlas/PHYSICS boot artifacts. |
| [aien-protocols](https://github.com/aien-dev/aien-protocols) | Versioned specifications and reference crates for agent state, inference and evaluation. |
| [aien-sovereign-core](https://github.com/aien-dev/aien-sovereign-core) | The earlier Linux-hosted Rust runtime. Legacy, kept as scaffolding while the repositories above replace it ([ADR 0024](https://github.com/aien-dev/aien-architecture/blob/main/docs/adr/0024-rust-scaffolding-omega-destination.md)). |
| [interplane](https://github.com/aien-dev/interplane) | INTERPLANE: an open protocol between AI models and agent runtimes. Models express intent, runtimes keep authority. |
| [benchmarks](https://github.com/aien-dev/benchmarks) | Measurement harnesses and evidence bundles, including the Prime Drag Race suite. |
| [aienos.com](https://github.com/aien-dev/aienos.com) · [drakestapleton.com](https://github.com/aien-dev/drakestapleton.com) | Project site and personal project record. |

Other repositories (aegis-runtime, open-humanity, spark-rsi, atlas, aien-edge and similar) are experimental or research and carry no status claims. Earlier standalone repositories are archived.

## Standing rules

- Language rule: Rust is scaffolding, Omega is the destination, and C or assembly only where hardware, boot, or a measurement justifies it. Nothing already merged is reverted ([ADR 0024](https://github.com/aien-dev/aien-architecture/blob/main/docs/adr/0024-rust-scaffolding-omega-destination.md)).
- No Python anywhere, including helper scripts. The one exception is [interplane](https://github.com/aien-dev/interplane), an open protocol for outside hosts, which ships a Python reference SDK and conformance runner beside its Rust ones.
- No CUDA toolkit and no dependence on vendor CUDA libraries. The GB10 is driven by our own native path.
- No systemd in AIENOS boot, init, services or tooling. Host-side scripts and operator steps that still use it are flagged, each with the replacement it owes, in [SOVEREIGNTY_FLAGS.md](https://github.com/aien-dev/aienos/blob/main/docs/SOVEREIGNTY_FLAGS.md).
- Builds are offline and in-house for the trusted base. No outside dependency may be required to build, boot or recover it.
- AIEN is not compared with other people's systems. Speed is measured against the machine's physical limit, and correctness against our own reference. Nothing from an outside inference stack ships in AIEN.
- Every performance figure must resolve to a reproducible command and a content-addressed evidence bundle. Old figures without one are withdrawn.
- Changes land through pull requests with the commands run and their output. Main branches on the core repositories are protected; no automatic merging.

## How to help

Start with AIENOS issues labelled [`help wanted`](https://github.com/aien-dev/aienos/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22help%20wanted%22) or [`emulator-ok`](https://github.com/aien-dev/aienos/issues?q=is%3Aissue%20is%3Aopen%20label%3Aemulator-ok). Those need no special hardware. Read each repository's CONTRIBUTING or AGENTS file first.

## License and values

Code across the AIEN repositories is licensed under the GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later); see each repository's LICENSE. The exception is interplane: Apache-2.0 for the protocol, schemas, fixtures and reference SDKs, with its adapters licensed to match their host projects ([licensing ADR](https://github.com/aien-dev/interplane/blob/main/docs/adr/0002-licensing.md)). aien-protocols also uses the Community Specification License 1.0 for its specifications. Project values live in the nonbinding [COVENANT.md](COVENANT.md): keep foundational advances open. The covenant grants and restricts no legal rights; LICENSE governs. Governance text for agents working in these repositories: [CONSTITUTION.md](CONSTITUTION.md) and [AGENT_CODE_OF_CONDUCT.md](AGENT_CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2026 Drake Stapleton <aien@aienos.com> and AIEN Contributors. Authored by Drake Stapleton in collaboration with AIEN.
