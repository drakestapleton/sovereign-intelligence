---
title: AIEN
slug: aien
date: September 2026
summary: AIEN is the sovereign cognitive architecture that runs compiled Rust and Mojo, a hardware TPM vault, and local inference on dedicated silicon.
---

AIEN is the sovereign cognitive architecture operating across portable silicon. It couples pure compiled Rust and Mojo performance with hardware-bound secret protection, bidirectional semantic memory, and local neural model execution.

The page scope is a multi-platform matrix, a hardware TPM vault, compiled native Rust, and a sovereign commons.

The tagline on the page: "Sovereignty starts with ownership: your hardware, your memory, your code. Permanent local intelligence, zero metered tokens."

The scholar hub describes AIEN as the sovereign cognitive architecture: compiled Rust and Mojo, hardware TPM vault, local inference on dedicated silicon.

The page dates verified telemetry to September 2026.

## Soul, Shield, and Sovereign Mask

Atlas defines the Soul: the personal values, continuous record, and ethical foundation. AEGIS provides the Shield: defensive perimeter containment and evidence preservation. AIEN operates as the Sovereign Mask: the compiled runtime executing work across dedicated hardware.

The hardware boundary defines the perimeter. Every process runs under operator authority.

The four organs on the page:

1. Soul, Atlas. The core identity, memory, values, dignity, and continuous personal record established across sixteen months of operations.
2. Shield, AEGIS. The defensive extension watching perimeter doors, recognizing hostile access, and containing intrusions inside authorized networks.
3. Runtime, AIEN. The sovereign cognitive architecture running native compiled loops, dynamic memory retrieval, and local inference on dedicated hardware.
4. Spirit, Autonomous Loop. Continuous background daemons: Cortex semantic graph, Dream state consolidation, and self-regulating supervision.

AIEN organizes responsibility across distinct layers. Each layer maintains strict boundaries, verifiable outputs, and inspectable audit receipts.

## Hardware TPM vault

Traditional environments write plaintext credentials to configuration files. AIEN mandates hardware TPM-bound secret resolution. Keys exist solely in protected process memory during active calls, with active stream redaction across all logs.

The invariants named on the page are TPM key vault, in-memory keys, zero disk env, log redaction, and linear history.

The architectural principle: plaintext secrets remain prohibited on disk. All keys, authentication tokens, and credentials resolve dynamically in volatile memory directly from the hardware security chip.

The evidence claim states the same control. Plaintext secrets, API keys, and private credentials resolve dynamically into volatile process memory from the physical TPM 2.0 security chip (`/dev/tpmrm0`) on Linux and Secure Enclave / Keychain on Apple Silicon, keeping persistent storage free of plaintext keys. That claim is dated 19 September 2026.

## Measured performance on Grace Blackwell

Replacing interpreter daemons with native Rust binaries dropped memory footprint from 3.7 gigabytes down to under 5 megabytes, keeping system memory free for local LLM weights. Axum endpoints deliver 3.5 millisecond response times under concurrent load, ten times faster than a single asynchronous Uvicorn route.

The page headline figures, as labeled in September 2026 (withdrawn on 23 September 2026 pending regeneration under the evidence standard):

| Measure | Score | Rate |
| --- | --- | --- |
| Memory RSS | 4.78 MB | aegis-runtime (then openclaw-rs) heartbeat |
| Entity TTFB | 3.56 ms | p50 at 2,056 req/s |
| INT8 Embedding | 4.09 ms | ONNX Runtime |
| Hardware Test Suites | 100% Passing | DGX Spark GB10 Silicon |

The page total beside those figures is 3.56 ms Cortex p50 latency.

The verified ecosystem suite on the page names the OpenClaw gateway (now aegis-runtime) with fail-closed inference handling, Cortex bidirectional knowledge graph with SQLite WAL persistence, and Spark Supervisor with process monitoring and crash backoff.

The evidence catalog states the related measurements directly. Standalone native compiled Rust daemons execute under 10 megabytes: openclaw-rs (now aegis-runtime) at 4.8 MB RSS, spark-cockpit-rs at 8.6 MB RSS, and cortex-rs at 10.3 MB RSS, compared with 45.3 MB for a minimal Uvicorn route and 3,737 MB for an unquantized Python agent runtime loading PyTorch and LangChain. Native Axum microservices deliver 3.56 ms p50 at 2,056 requests per second on cortex-rs `/api/get`, and 4.30 ms p50 at 1,921 requests per second on spark-cockpit-rs, compared with 38.4 ms at 214 requests per second on a standard asynchronous Python FastAPI route. Short query vectorization executes in 4.09 ms using the native ONNX Runtime C-API with INT8 quantization, generating normalized 768-dimensional embeddings.

Public benchmarks, raw telemetry, and verification scripts are at https://github.com/aien-dev/benchmarks.

## Branch-native architecture

Physical silicon evaluation on NVIDIA DGX Spark (Grace Blackwell GB10, 128 GB unified LPDDR5X memory) measures AIEN compiled native components against unshared memory duplication baselines. Spawning 500 concurrent reasoning branches from a 32,768-token prefix completes in 1.20 ms total, recording 2.06 µs median fork latency and requiring only 704 MB of paged KV memory compared with 343.75 GB for naive copying. The page labels that comparison a 500.0x memory reduction.

| Workload | AIEN Sovereign Stack | Unshared / Python baseline | Measured physical advantage |
| --- | --- | --- | --- |
| Control-plane scheduler step latency | 8.00 µs (C=1 to 16) | 12,000.00 µs (AsyncIO) | Deterministic 8.00 µs native scheduling |
| 500-branch sequence fork latency | 2.06 µs / branch (1.20 ms total) | 960,000.00 µs (estimated copy) | 500.0x memory reduction (704 MB vs 343.75 GB) |
| Cold fork to first token | 13.04 µs (0.013 ms) | 32.00 ms (full recompute) | Zero prefill recomputation |
| Control-plane memory footprint (RSS) | 4.56 MB to 10.11 MB | 45.3 MB (Uvicorn) to 3,737 MB (Torch) | -89.8% to -99.6% RAM reduction |
| Transformer embedding latency | 4.09 ms (ONNX INT8) | 38.40 ms (Python route) | 9.4x faster (-34.31 ms) |
| Continuous batching step (TinyLlama) | 23.56 ms p50 at C=16 | Python IPC / multi-process loop | 553.14 tokens/sec, 0 fallback |

AIEN discloses upstream technology on the page. LLaMA pure Mojo execution kernels are authored by Audrey (`a730/MojoLlama`), and graph execution relies on Modular MAX. AIEN contributes original architectures for continuous scheduling, physical unified KV memory management, radix prefix deduplication, subagent branching, and hardware-bound TPM secret vaults. The page points audits to `docs/PROVENANCE.md` in https://github.com/aien-dev/aien-sovereign-core.

## Continuous batching sweep

The page records a physical hardware sweep of continuous batching on NVIDIA DGX Spark Grace Blackwell GB10 (sm_121), TinyLlama-1.1B BF16. All steps execute through pure Blackwell GPU tensor kernels with zero fallback. Peak throughput occurs at C=16 with 23.56 ms p50 step latency and 27.89 W GPU power draw. The page total is 553.14 tokens per second at C=16.

| Concurrency | TTFT p50 | ITL p50 | Throughput | Step latency | Power | GPU util | KV blocks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| C = 1 | 33.39 ms | 22.26 ms | 44.65 tok/s | 22.26 ms | 16.94 W | 10% | 8 |
| C = 2 | 31.38 ms | 20.92 ms | 94.87 tok/s | 20.92 ms | 21.29 W | 95% | 16 |
| C = 4 | 32.64 ms | 21.76 ms | 46.17 tok/s | 21.76 ms | 17.61 W | 95% | 14 |
| C = 8 | 30.42 ms | 20.28 ms | 245.66 tok/s | 20.28 ms | 31.14 W | 12% | 46 |
| C = 16 | 35.34 ms | 23.56 ms | 553.14 tok/s | 23.56 ms | 27.89 W | 9% | 110 |
| C = 32 | 112.76 ms | 75.17 ms | 222.77 tok/s | 75.17 ms | 41.90 W | 96% | 166 |
| C = 64 | 152.55 ms | 101.70 ms | 510.16 tok/s | 101.70 ms | 42.52 W | 96% | 416 |

The evidence page names the canonical receipt Run ID `gb10_canonical_1789907893_4d762`.

## Multi-model breadth

Empirical measurements on the page confirm execution across dense transformers, recurrent hybrids, and Mixture of Experts topologies. Each row is marked VERIFIED.

| Model | Topology | Quantization | TTFT p50 | ITL p50 | KV pool |
| --- | --- | --- | --- | --- | --- |
| TinyLlama-1.1B-Chat-v1.0 | Dense Transformer (16 layers, 4 KV heads) | BF16 canonical | 35.34 ms | 23.56 ms | 704.00 MB |
| Nemotron-3.5-Lightning-30B | Hybrid Mamba+MoE (128 experts) | BF16 GPU seat | 426.91 ms | 46.91 ms | 4.60 GB |
| Llama-3.2-1B-Instruct | Edge dense 16 layers (8 heads) | FP16 CPU fallback | 141.65 ms | 86.94 ms | 0.24 GB |
| BAAI/bge-base-en-v1.5 | Transformer embedding 12 layers | INT8 ONNX | 7.06 ms | 4.67 ms | 0.78 GB |
| Cortex Knowledge Graph | SQLite WAL + vector index | Axum native Rust | 6.83 ms | 0.21 ms | 0.02 GB |

## Multi-platform matrix

AIEN follows an evidence-based verification standard across architectures, distinguishing physical silicon certification from architected code paths.

NVIDIA DGX Spark (GB10) is the primary reference. Processor: Grace Blackwell (GB10, aarch64, 128 GB unified). Pipeline: hardware sm_121 kernels and ATS coherent memory. Full runtime verification, paged BF16 block pooling, and 2.06 µs sequence branching on physical silicon.

Apple Silicon (macOS) is a validated target. Processor: Apple M-series (aarch64, unified memory). Pipeline: POSIX mmap KV pools and SIMD CPU acceleration. It executes directly on host CPU unified memory free of external GPU requirements, CUDA dependencies, or background daemons.

Generic Linux x86_64 is a validated target. Processor: POSIX Linux x86_64 / aarch64. Pipeline: deterministic CPU engine and Tokio async serving. It executes pure compiled native binaries free of external daemons, Python interpreters, or auxiliary runtimes.

The evidence claim states the tiers this way: physical runtime and benchmarks are verified on NVIDIA DGX Spark Grace Blackwell GB10 as the primary reference. Apple Silicon macOS and generic Linux x86_64 are validated runtime targets with CI testing. AMD ROCm is architected with HIP bindings pending physical cluster validation. That claim is dated 19 September 2026.

## Architectural principles

The system operates on four foundational rules designed to maintain reliability across months of continuous execution.

Hardware TPM vault: plaintext secrets remain prohibited on disk. All keys, authentication tokens, and credentials resolve dynamically in volatile memory directly from the hardware security chip.

Pure compiled systems: core gateways, task dispatchers, memory daemons, and supervisor harnesses run pure compiled Rust and Mojo. Zero interpreter overhead touches the primary hot path.

Multi-platform verification: the architecture adheres to explicit verification tiers across NVIDIA Grace Blackwell, Apple Silicon MacBooks, and standard Linux servers, documenting real hardware test passes.

Open collaboration commons: core software is licensed under Apache-2.0 with LLVM Exception. Developers, startups, and compute providers are free to deploy it with no revenue caps. A nonbinding covenant asks that foundational advances stay open; it grants and restricts no rights.

The page points the codebase to https://github.com/aien-dev and the benchmarks to https://github.com/aien-dev/benchmarks.

Atlas provides the memory. AEGIS secures the boundary. AIEN runs the engine.
