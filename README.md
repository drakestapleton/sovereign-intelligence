# Sovereign Intelligence

> **GitHub switched us off. We're still here.**

I build a sovereign AI stack: my own operating system, my own programming language (Omega), my own GPU toolchain and the models that run on them. This repository is the front door. Everything else lives on [Radicle](https://radicle.xyz), a peer-to-peer network that no single company can switch off, and on my own hardware.

```sh
curl -fsSL https://www.aienos.com/si | sh
```

That one command fetches every public project into one directory and checks each one against the commit listed below. [What it does](#get-everything).

## What happened

I published everything on GitHub: 109 repositories in the `aien-dev` organization.

On 7 November 2026, between 08:14 and 08:20 UTC, GitHub:

- cancelled my Actions runs as "owner marked spammy";
- flagged the organization and hid every repository from the public;
- suspended my machine account, `aien-spark`.

The cause was real. About 20 AI agents work on this project, and they were pushing and opening pull requests faster than GitHub's abuse filters allow. I have appealed and the appeal is pending.

I did not wait. The same morning every public project moved to Radicle, one Radicle repository per project, seeded from my own machines, each with its own key. My website, [www.aienos.com](https://www.aienos.com), runs on my own hardware. GitHub keeps this one repository, so that people can still find me. Its only code is Omega. The full account is at [www.aienos.com/switched-off/](https://www.aienos.com/switched-off/).

## I broke CUDA.

*My own language, Omega, writes NVIDIA GB10 machine code. It ran on the chip: 1,048,576 of 1,048,576 values correct, no CUDA toolkit, no nvcc, no PTX.* **CHIP_TESTED, 27 October 2026.**

What that rests on, with the evidence label for each claim:

| Claim | Label |
|---|---|
| My own language, Omega, has its own sm_121 instruction encoder. Its machine code ran on the GB10: 1,048,576 of 1,048,576 values correct. A planted-bug control failed, as it should. | CHIP_TESTED, 2026-10-27 |
| No CUDA toolkit is needed or used. | CHIP_TESTED, diagnostic on the same run |
| The Omega encoder and my C encoder produce byte-identical machine code for the 70 kernels the chip ran, and for 243 kernels on the host. | CHIP_TESTED (70) and HOST_TESTED (243) |
| On 21 October 2026 my 35 billion parameter model on the DGX Spark was served with zero CUDA libraries loaded. That was my C GPU stack, on that date. | DEPLOYED, 2026-10-21 |

The receipts are in [CUDApp](#projects) (`rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP`, under `evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/`) and [omega-mv](#projects) (`rad:z6do9WDBhuSnvopDkgFdFr1yWA62`, under `evidence/WHAT-OMEGA-IS-20261021/`).

What I have not done yet: replace every CUDA library, run on GPUs other than the GB10, or remove NVIDIA's open kernel module and signed firmware. Status per piece: [www.aienos.com/cudaplusplus/](https://www.aienos.com/cudaplusplus/). I built this by directing AI coding agents. Every paper below is a preprint, not peer reviewed.

## Papers

The CUDA paper:

- [Reverse Engineering the CUDA Software Stack: An Independently Implemented GPU Machine-Code Toolchain for the NVIDIA GB10](https://doi.org/10.5281/zenodo.23677465) (version 2, 2026-10-26, DOI 10.5281/zenodo.23677465). Not on www.aienos.com yet, so the link is its DOI. [Version 1](https://doi.org/10.5281/zenodo.23578453) (2026-10-22) is superseded; version 2 lists its corrections.
- [A Call to Humanity: Breaking the CUDA Stranglehold on the Hardware Market](https://www.aienos.com/call-to-humanity/) (open letter, 2026-10-24, DOI 10.5281/zenodo.23614947)

Research papers on www.aienos.com:

- [Computing Machinery and Understanding: From the Imitation Game to the Turing](https://www.aienos.com/research/computing-machinery-and-understanding/) (2026-10-17, DOI 10.5281/zenodo.23437498)
- [Computing Machinery and Understanding: The Turing as a Measure Emerging from AIEN](https://www.aienos.com/research/computing-machinery-and-understanding-emergence/) (2026-10-17, DOI 10.5281/zenodo.23437568)
- [The Turing: A Unit of Verified Explanatory Gain](https://www.aienos.com/research/the-turing-brief/) (2026-10-02, DOI 10.5281/zenodo.23547801)
- [The Turing Discovery Gap Conjecture](https://www.aienos.com/research/turing-discovery-gap-conjecture/) (2026-10-02, DOI 10.5281/zenodo.23547803)
- [The Crumb Doctrine](https://www.aienos.com/research/crumb-doctrine/) (2026-10-02, DOI 10.5281/zenodo.23547808)
- [The Stapleton Doctrine: A Personal Philosophy of AI Architecture and Programming](https://www.aienos.com/research/the-stapleton-doctrine/) (2026-10-02, DOI 10.5281/zenodo.23547805)
- [Omega: A Programming Language Built for Verified Programs](https://www.aienos.com/research/omega-language/) (2026-10-02, DOI 10.5281/zenodo.23547811). This is the design proposal; it predates the compiler.
- [The Atemporal AIEN Postulate: Causal Semantics Without Clocks](https://www.aienos.com/research/atemporal-aien-postulate/) (2026-10-02, DOI 10.5281/zenodo.23547813)
- [The AIEN Papers](https://www.aienos.com/research/the-aien-papers/) (the collected volume)

Other preprints, not on www.aienos.com yet, so the links are their DOIs:

- [The Token Is the Instruction: Large Language Models as Programming Languages, and Omega as the Next Substrate](https://doi.org/10.5281/zenodo.23644703) (2026-10-25, position paper)
- [The Ω-Framework: An Observer-Dependent Resolution of Singularities in General Relativity and Quantum Gravity](https://doi.org/10.5281/zenodo.23505156) (2026-10-20)

Two technical protocols live in [omega-mv](#projects): the Turing Instrument Calibration and Validation Program (`docs/turing/protocols/turing-instrument-calibration-validation-protocol-v1-0.tex`) and the Turing Laboratory Execution Protocol (`docs/turing/protocols/turing-laboratory-execution-protocol-v1-0.tex`).

## Get everything

```sh
curl -fsSL https://www.aienos.com/si | sh
```

The script is served from my own server, not from GitHub. It:

1. prints what it is about to do;
2. makes one directory, `./sovereign-intelligence` (set `SI_DIR` to choose another), and touches nothing else. It needs no sudo and refuses to run as root;
3. fetches each project with `rad clone <RID>` when you have Radicle, peer-to-peer from whichever seed has it. Without Radicle it uses `git clone` from my seed at `https://www.aienos.com/rad/`, read-only;
4. checks every checkout against the commit in the table below and prints `OK` or `MISMATCH`. Any mismatch makes it exit with an error.

If a project cannot be fetched, it prints the project's Radicle ID and Radicle's official installer, `curl -sSf https://radicle.xyz/install | sh`. It runs that installer only if you set `SI_INSTALL_RAD=1`.

`SI_ONLY=core` fetches only the seven core projects:

```sh
curl -fsSL https://www.aienos.com/si | SI_ONLY=core sh
```

To read it before you run it:

```sh
curl -fsSL https://www.aienos.com/si -o si.sh && less si.sh && sh si.sh
```

The script is generated, never written by hand. [`compiler/si.om`](compiler/si.om), an Omega program, builds it, the project table below and [`repos.tsv`](repos.tsv) from my Radicle node's inventory. [`compiler/README.md`](compiler/README.md) shows how to rebuild all three and compare them byte for byte with what is served.

## Projects

<!-- si:index:begin -->
**41 public projects**, 7 of them core, listed by `compiler/si.om` from my Radicle node's inventory. Full commit ids are in [`repos.tsv`](repos.tsv).

| # | Project | Radicle ID | Head | About |
|---:|---|---|---|---|
| 1 | **aienux** (core) | `rad:z2Q6ob2gL6Qo5oUMpyehukayVF7mN` | `2fc6207` | Aienux, the AienOS kernel: boot, scheduling, IPC and capability boundaries. Pre-alpha; host, emulator and physical evidence are labelled separately. |
| 2 | **omega-mv** (core) | `rad:z6do9WDBhuSnvopDkgFdFr1yWA62` | `943d955` | Omega: a language for verified programs, semantic identity and machine realization. Seed-born work and existing implementations have distinct provenance. |
| 3 | **aien-sovereign-core-mv** (core) | `rad:z44GqrPVAPjZkhoD2MWVjqy18ighN` | `9d7b343` | AienOS host runtime: inference scheduling, paged KV state, the aien CLI and Spark verification tooling. Its inference engine is in alpha testing (DGX Spark GB10); Omega is the implementation destination. |
| 4 | **physics-mv** (core) | `rad:z49She8eifZpLd2aiSvk2pph3DMUo` | `56d02ae` | FORGE: request-bound machine realization, providers and verification for AienOS. Host, simulated and GB10 hardware paths have separate evidence. |
| 5 | **aien-architecture-mv** (core) | `rad:z37zcFYooiuCCZsf5L74eeFJYiwWM` | `4c19564` | Canonical architecture for the AIEN ecosystem: flows, boundaries, ADRs, and the map from design to implementation repositories. |
| 6 | **aien-train** (core) | `rad:zKrfazKqYNFuXDDkYdptxJicGLEq` | `0518c91` | AIEN training programme: language-model history, GB10 constraints and the route to training on the project engine. Plans and runnable checks are distinguished. |
| 7 | **CUDApp** (core) | `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` | `b774723` | CUDA++: AIEN’s GPU machine-code toolchain, runtime and driver client for NVIDIA GPUs without the CUDA toolkit. Hardware coverage and driver replacement limits are explicit. |
| 8 | **.github** | `rad:z36odegYfUoEoX8xwjJ4so68jb1W3` | `e146b84` | AienOS organization profile, contribution guidance and GitHub community templates. Source, lessons and verification evidence are linked explicitly. |
| 9 | **aegis-runtime-mv** | `rad:z6hhF5wGXCqvkcvxYdcBb12qm3FB` | `279f08e` | Native Rust agent runtime: Axum WebSocket/SSE/REST gateway, heartbeat scheduler, dependency-aware task workflow, SQLite storage. Attachment of AienOS. Pre-alpha. |
| 10 | **aien** | `rad:zDTnULpiVMniD2etkbUozUP5mn6U` | `be2b65c` | aien-dev/aien (Radicle canonical mirror during the GitHub hold) |
| 11 | **aien-harness** | `rad:z3tjNacwmefzXhmChFjfp6jssEzmK` | `15948e2` | Autonomous agent verification and benchmark test harness |
| 12 | **aien-protocols-mv** | `rad:zzxgxYRc5tw6VwYXkQNLC2hqKkfb` | `4706688` | Canonical specifications, wire protocols, and schemas for the AIEN sovereign ecosystem |
| 13 | **aien-receipts** | `rad:z4HXNamwwXyfN11ZBJXAQpdMKvojz` | `bda984f` | Append-only AIEN verification receipts, indexed by repository and exact source commit. Read verdicts, signatures and retained logs before making a claim. |
| 14 | **aien-rig** | `rad:z2MPnsBZpJYeJJq39EXz1SYzLL7mc` | `476c4ac` | AIEN Rig: local AI and frame-rate tuning for RTX gaming PCs. Pre-alpha; host fixtures and target-card qualification are separate. |
| 15 | **aien-sovereign-core** | `rad:z2kdkm8HpiyFbMFpFmzzWZQgTn1EQ` | `8a42b14` | Autonomous sovereign intelligence engine and runtime core for NVIDIA DGX Spark |
| 16 | **aienix** | `rad:zV8VdbBDCPEZePcnBiseNyym3Wnk` | `0dce79d` | AienOS front door: pinned repositories, source-linked lessons and verification paths. AienOS is in alpha testing; components remain separate and each states its own status. |
| 17 | **aienos.com** | `rad:z3iwnx2pktbGhnfBpJSsaFcTmKgHU` | `6d614cb` | Source of www.aienos.com, built by a Rust generator and served by GitHub Pages |
| 18 | **benchmarks-mv** | `rad:z2nYCN9XZAPjNohqT8bz46rcs9zvZ` | `ecfd238` | Measurement harnesses and evidence bundles for AIEN on the NVIDIA DGX Spark GB10. Speed is reported against the machine's physical limit and my own previous run. Attachment of AienOS. |
| 19 | **cortex-rs** | `rad:z2VKEz9qeswAC7EGhPaTvDRirkXKf` | `deb66c0` | Pure compiled native Rust memory engine with vector search and SQLite WAL |
| 20 | **crumb-spec** | `rad:z3w694J42BU3ztSSkBz319tb7pHky` | `80d3ff0` | Crumb Protocol specification and filesystem standard for sovereign AI agents |
| 21 | **gpu-head-to-head** | `rad:z3ZSvMF8VFFGa5FyyKXGh4Vv6NBpS` | `173c9b4` | aien-dev/gpu-head-to-head (Radicle canonical mirror during the GitHub hold) |
| 22 | **harvester** | `rad:zVPJPCdCgWVrw97UKxEBzMU3sCDY` | `89a61a4` | Zero-telemetry documentation and knowledge extraction engine |
| 23 | **interplane-mv** | `rad:zNhNbqYvgSBEHBq9vvE8xpbcBzGa` | `e0d6863` | INTERPLANE: open interoperability protocol between AI models and agent runtimes. Models express intent. Runtimes retain authority. |
| 24 | **interplane.io** | `rad:z399yKvnXcBQNkKoq86iBDgTvQ5QV` | `3b79aaa` | Source of interplane.io: a Rust generator that renders the page from the protocol repository's public record, deployed hourly from the Spark. |
| 25 | **mobhub** | `rad:z3Konv8McLhn67ZBUiCE4bFR5r9tC` | `6ff6027` | Decentralized model and agent weights distribution network |
| 26 | **omega-bridge** | `rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y` | `d8174ed` | Omega-first language interoperability: checked conversion backends and native language bindings |
| 27 | **omega-harness** | `rad:z39gvwWsnkRZsAConQLjaKiNVLHfW` | `bd107ca` | Agent skills for operating, encoding and communicating in Omega (.om) and the AIEN repositories |
| 28 | **open-humanity** | `rad:z2jftNw1LLYTNgj8DNoh1TGGNmEmP` | `f68d7a2` | Privacy-first peer assistance network for sovereign autonomous agents |
| 29 | **openclaw-rs** | `rad:z21SQF1DVwRmpxbTMnSiYxXveiRp1` | `d491aff` | High-performance sovereign agent runtime in native Rust and Mojo for NVIDIA DGX Spark |
| 30 | **rad-id-sync** | `rad:z4YVa7BSf1MGTrHoJewK8iWQcyHbC` | `f9a0452` | Radicle identity document synchronization utility |
| 31 | **sovereign-intelligence** | `rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj` | `320c1bb` | Sovereign Intelligence: one command turns a DGX Spark into your own AI. Allen, Omega, science tools, no NVIDIA user-space software. Alpha testing. |
| 32 | **spark-adapters** | `rad:z2L6KpjRgTCMbPeuEpggRmecH5Qpc` | `ad883a2` | Hardware abstraction adapters for local AI accelerators |
| 33 | **spark-crumbs** | `rad:z2uQ4JsdQJ8zwrW2Fc3mDro8fJo4g` | `3adeb73` | Deterministic append-only operational event ledger |
| 34 | **spark-debugger** | `rad:zhE9hwwAEWUup6PaXBcVApAVwEUt` | `00d4e4f` | Native runtime state inspector and execution debugger |
| 35 | **spark-dream** | `rad:z4UHi17ttdBX6qAfFutgFaL6s1Aga` | `265dec1` | Idle-cycle neural memory consolidator and vectorizer |
| 36 | **spark-hive** | `rad:z2RVudShJWi3She9WLw3DNZDwYvnB` | `f81a7e2` | Multi-agent swarm coordination and peer routing engine |
| 37 | **spark-inquisitor** | `rad:z4PuE5iVq1optfv8xaEYXp3B4nbt4` | `1cb45c4` | Ultra-fast compiled native Rust gatekeeper and automated code reviewer |
| 38 | **spark-rsi** | `rad:z2zietej47ufRfzb4RNQKwemNxTJ9` | `5aa5e65` | Resilient systems interface and fault-tolerant agent communication |
| 39 | **spark-rsi-mv** | `rad:z4AauBRPXzPNMiAoHZpRpyCee61A2` | `505c75d` | Native Rust recursive self-improvement engine with paired bootstrap evaluation and cryptographic ledger |
| 40 | **spark-supervisor** | `rad:z3HQENMJfT9o14N3oDQtY4YPFak73` | `b3c5c3c` | Process supervisor and health monitor for sovereign daemons |
| 41 | **synapse** | `rad:zMGRREr2tmtRqpo4mMjpzkZdUGXN` | `01a4de3` | Synapse: agent-native changesets and coordination, with Git and Radicle interoperability. A component of the AienOS ecosystem. |
<!-- si:index:end -->

Open any of them on the web at `https://radicle.network/nodes/rosa.radicle.network/<RID>`.

## Run your own seed

Every copy makes the project harder to switch off. With [Radicle](https://radicle.xyz) installed:

```sh
curl -sSf https://radicle.xyz/install | sh   # Radicle's official installer
rad auth                                     # make your Radicle key
rad node start
tail -n +2 repos.tsv | cut -f2 | while read -r rid; do rad seed "$rid"; done
```

Your node then fetches every public project, keeps it current and serves it to other peers. My own seeds are on my own machines; `rad node status` shows who you are connected to.

## License

Apache License 2.0, in [LICENSE](LICENSE). Each project carries its own license.
