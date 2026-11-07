import { Link } from "react-router-dom";
import { EvidenceNotice, PageIntro } from "../components/PagePrimitives";
import { trackRepoOutbound } from "../lib/tracking";
import { usePageMeta } from "../lib/usePageMeta";

const triadPillars = [
  {
    step: "01",
    label: "Soul",
    title: "Atlas",
    body: "The core identity, memory, values, dignity, and continuous personal record established across sixteen months of operations.",
  },
  {
    step: "02",
    label: "Shield",
    title: "AEGIS",
    body: "The defensive extension watching perimeter doors, recognizing hostile access, and containing intrusions inside authorized networks.",
  },
  {
    step: "03",
    label: "Runtime",
    title: "AIEN",
    body: "The sovereign cognitive architecture running native compiled loops, dynamic memory retrieval, and local inference on dedicated hardware.",
  },
  {
    step: "04",
    label: "Spirit",
    title: "Autonomous Loop",
    body: "Continuous background daemons: Cortex semantic graph, Dream state consolidation, and self-regulating supervision.",
  },
];

const performanceMetrics = [
  { label: "Memory RSS", score: "4.78 MB", rate: "aegis-runtime heartbeat" },
  { label: "Entity TTFB", score: "3.56 ms", rate: "p50 @ 2,056 req/s" },
  { label: "INT8 Embedding", score: "4.09 ms", rate: "ONNX Runtime" },
  { label: "Hardware Test Suites", score: "100% Passing", rate: "DGX Spark GB10 Silicon" },
];

const continuousBatchingSweepData = [
  { concurrency: "C = 1", ttft: "33.39 ms", itl: "22.26 ms", throughput: "44.65 tok/s", stepP50: "22.26 ms", power: "16.94 W", gpuUtil: "10%", kvBlocks: "8" },
  { concurrency: "C = 2", ttft: "31.38 ms", itl: "20.92 ms", throughput: "94.87 tok/s", stepP50: "20.92 ms", power: "21.29 W", gpuUtil: "95%", kvBlocks: "16" },
  { concurrency: "C = 4", ttft: "32.64 ms", itl: "21.76 ms", throughput: "46.17 tok/s", stepP50: "21.76 ms", power: "17.61 W", gpuUtil: "95%", kvBlocks: "14" },
  { concurrency: "C = 8", ttft: "30.42 ms", itl: "20.28 ms", throughput: "245.66 tok/s", stepP50: "20.28 ms", power: "31.14 W", gpuUtil: "12%", kvBlocks: "46" },
  { concurrency: "C = 16", ttft: "35.34 ms", itl: "23.56 ms", throughput: "553.14 tok/s", stepP50: "23.56 ms", power: "27.89 W", gpuUtil: "9%", kvBlocks: "110" },
  { concurrency: "C = 32", ttft: "112.76 ms", itl: "75.17 ms", throughput: "222.77 tok/s", stepP50: "75.17 ms", power: "41.90 W", gpuUtil: "96%", kvBlocks: "166" },
  { concurrency: "C = 64", ttft: "152.55 ms", itl: "101.70 ms", throughput: "510.16 tok/s", stepP50: "101.70 ms", power: "42.52 W", gpuUtil: "96%", kvBlocks: "416" },
];

const multiModelBreadthData = [
  { model: "TinyLlama-1.1B-Chat-v1.0", topology: "Dense Transformer (16 Layers, 4 KV Heads)", quant: "BF16 Canonical", ttft: "35.34 ms", itl: "23.56 ms", kv: "704.00 MB", status: "REGENERATING" },
  { model: "Nemotron-3.5-Lightning-30B", topology: "Hybrid Mamba+MoE (128 Experts)", quant: "BF16 GPU Seat", ttft: "426.91 ms", itl: "46.91 ms", kv: "4.60 GB", status: "REGENERATING" },
  { model: "Llama-3.2-1B-Instruct", topology: "Edge Dense 16 Layers (8 Heads)", quant: "FP16 CPU Fallback", ttft: "141.65 ms", itl: "86.94 ms", kv: "0.24 GB", status: "REGENERATING" },
  { model: "BAAI/bge-base-en-v1.5", topology: "Transformer Embedding 12 Layers", quant: "INT8 ONNX", ttft: "7.06 ms", itl: "4.67 ms", kv: "0.78 GB", status: "REGENERATING" },
  { model: "Cortex Knowledge Graph", topology: "SQLite WAL + Vector Index", quant: "Axum Native Rust", ttft: "6.83 ms", itl: "0.21 ms", kv: "0.02 GB", status: "REGENERATING" },
];

const crossSurfaceData = [
  {
    surface: "NVIDIA DGX Spark (GB10)",
    processor: "Grace Blackwell (GB10, aarch64, 128 GB Unified)",
    pipeline: "Hardware sm_121 Kernels + ATS Coherent Memory",
    status: "Primary Reference",
    summary: "Full runtime verification, paged BF16 block pooling, and 2.06 µs sequence branching on physical silicon.",
  },
  {
    surface: "Apple Silicon (macOS)",
    processor: "Apple M-Series (aarch64, Unified Memory)",
    pipeline: "POSIX mmap KV Pools + SIMD CPU Acceleration",
    status: "Validated Target",
    summary: "Executes directly on host CPU unified memory free of external GPU requirements, CUDA dependencies, or background daemons.",
  },
  {
    surface: "Generic Linux x86_64",
    processor: "POSIX Linux x86_64 / aarch64",
    pipeline: "Deterministic CPU Engine + Tokio Async Serving",
    status: "Validated Target",
    summary: "Executes pure compiled native binaries free of external daemons, Python interpreters, or auxiliary runtimes.",
  },
];

const architectureTenets = [
  {
    title: "Hardware TPM Vault",
    body: "Plaintext secrets remain prohibited on disk. All keys, authentication tokens, and credentials resolve dynamically in volatile memory directly from the hardware security chip.",
  },
  {
    title: "Pure Compiled Systems",
    body: "Core gateways, task dispatchers, memory daemons, and supervisor harnesses run pure compiled Rust and Mojo. Zero interpreter overhead touches the primary hot path.",
  },
  {
    title: "Multi-Platform Verification",
    body: "The architecture adheres to explicit verification tiers across NVIDIA Grace Blackwell, Apple Silicon MacBooks, and standard Linux servers, documenting real hardware test passes.",
  },
  {
    title: "Open Collaboration Commons",
    body: "Core software is licensed under Apache-2.0 with LLVM Exception. Developers, startups, and compute providers are free to deploy it with no revenue caps. A nonbinding covenant asks that foundational advances stay open; it grants and restricts no rights.",
  },
];

export function AienPage() {
  usePageMeta("/aien");

  return (
    <main className="wrap portrait-wrap aegis-page aien-page">
      <div style={{ display: "flex", justifyContent: "center", paddingTop: "24px", marginBottom: "16px" }}>
        <video
          src="/images/aien-avatar.mp4"
          poster="/images/aien-avatar-poster.webp"
          autoPlay
          muted
          loop
          playsInline
          aria-label="AIEN"
          style={{
            width: "180px",
            height: "180px",
            borderRadius: "50%",
            boxShadow: "0 0 40px rgba(168, 85, 247, 0.45)",
            border: "3px solid #a855f7",
            objectFit: "cover",
          }}
        />
      </div>

      <PageIntro
        eyebrow="AIEN / Sovereign Cognitive Architecture"
        title="Compiled, vaulted, and sovereign on dedicated silicon."
        className="aegis-hero"
      >
        <p>
          AIEN is the sovereign cognitive architecture operating across portable silicon.
          It couples pure compiled Rust and Mojo performance with hardware-bound secret protection,
          bidirectional semantic memory, and local neural model execution.
        </p>
      </PageIntro>

      <div className="aegis-scope-strip" aria-label="AIEN project scope">
        <span>Multi-Platform Matrix</span>
        <span>Hardware TPM Vault</span>
        <span>Compiled Native Rust</span>
        <span>Sovereign Commons</span>
      </div>

      <blockquote className="aegis-tagline">
        “Sovereignty starts with ownership:
        <br />
        <span>your hardware, your memory, your code.</span>
        <br />
        Permanent local intelligence, zero metered tokens.”
      </blockquote>

      <section className="aegis-house" aria-labelledby="aien-triad-heading">
        <p className="portrait-index">The triad</p>
        <div>
          <h2 id="aien-triad-heading">Soul, Shield, and Sovereign Mask.</h2>
          <p>
            Atlas defines the Soul: the personal values, continuous record, and ethical foundation.
            AEGIS provides the Shield: defensive perimeter containment and evidence preservation.
            AIEN operates as the Sovereign Mask: the compiled runtime executing work across dedicated hardware.
          </p>
          <p className="aegis-law">
            The hardware boundary defines the perimeter. Every process runs under operator authority.
          </p>
        </div>
      </section>

      <section className="aegis-response" aria-labelledby="aien-pillars-heading">
        <header className="aegis-section-lead">
          <p className="portrait-index">The operational structure</p>
          <div>
            <h2 id="aien-pillars-heading">Four distinct organs working as one entity.</h2>
            <p>
              AIEN organizes responsibility across distinct layers. Each layer maintains strict boundaries,
              verifiable outputs, and inspectable audit receipts.
            </p>
          </div>
        </header>
        <ol className="aegis-flow" aria-label="AIEN operational structure">
          {triadPillars.map((stage) => (
            <li key={stage.step}>
              <span>{stage.step}</span>
              <p>{stage.label}</p>
              <h3>{stage.title}</h3>
              <div>{stage.body}</div>
            </li>
          ))}
        </ol>
      </section>

      <section className="aegis-knockout" aria-labelledby="aien-vault-heading">
        <p className="portrait-index">Zero Disk Secrets</p>
        <h2 id="aien-vault-heading">Hardware TPM vault. Volatile memory resolution. Clean disk state.</h2>
        <p>
          Traditional environments write plaintext credentials to configuration files. AIEN mandates
          hardware TPM-bound secret resolution. Keys exist solely in protected process memory during active
          calls, with active stream redaction across all logs.
        </p>
        <div className="aegis-actions" aria-label="AIEN architectural invariants">
          <span>TPM Key Vault</span>
          <span>In-Memory Keys</span>
          <span>Zero Disk Env</span>
          <span>Log Redaction</span>
          <span>Linear History</span>
        </div>
        <p style={{ marginTop: "16px", fontSize: "0.9rem" }}>
          <Link to="/evidence#claim-zero-disk-secrets" style={{ color: "var(--red)", textDecoration: "underline" }}>
            Inspect TPM vault verification evidence
          </Link>
        </p>
      </section>

      <EvidenceNotice />

      <section className="aegis-evaluation" aria-labelledby="aien-benchmarks-heading">
        <div className="aegis-evaluation-intro">
          <div>
            <p className="portrait-index">Prior telemetry / September 2026 / under regeneration</p>
            <h2 id="aien-benchmarks-heading">Measured performance on Grace Blackwell hardware.</h2>
          </div>
          <div className="aegis-total">
            <strong>3.56ms</strong>
            <span>Cortex p50 latency</span>
          </div>
        </div>

        <p className="aegis-evaluation-copy">
          Replacing interpreter daemons with native Rust binaries dropped memory footprint from
          3.7 gigabytes down to under 5 megabytes, keeping system memory free for local LLM weights.
          Axum endpoints deliver 3.5 millisecond response times under concurrent load, ten times faster
          than a single asynchronous Uvicorn route.
        </p>

        <div className="aegis-eval-grid" aria-label="AIEN performance benchmarks">
          {performanceMetrics.map((metric) => (
            <article key={metric.label}>
              <p>{metric.label}</p>
              <strong>{metric.score}</strong>
              <span>{metric.rate}</span>
            </article>
          ))}
        </div>

        <div className="aegis-eval-boundary">
          <div>
            <p className="aegis-eval-label">Verified Ecosystem Suite</p>
            <ul>
              <li>AEGIS gateway with fail-closed inference handling.</li>
              <li>Cortex bidirectional knowledge graph with SQLite WAL persistence.</li>
              <li>Spark Supervisor with process monitoring and crash backoff.</li>
            </ul>
          </div>
          <div>
            <p className="aegis-eval-label">Public Benchmark Suite</p>
            <p>
              Review the automated benchmark suite, raw telemetry data files, and verification scripts
              at <a href="https://github.com/aien-dev/benchmarks" target="_blank" rel="noopener noreferrer" style={{ color: "var(--red)", textDecoration: "underline" }}>github.com/aien-dev/benchmarks</a>.
            </p>
          </div>
        </div>
      </section>

      <section className="aegis-evaluation" aria-labelledby="aien-showdown-heading" style={{ marginTop: "48px" }}>
        <div className="aegis-evaluation-intro">
          <div>
            <p className="portrait-index">Physical Silicon Telemetry / Gate 5</p>
            <h2 id="aien-showdown-heading">Branch-Native Architecture vs Unshared Replication Baselines.</h2>
          </div>
          <div className="aegis-total">
            <strong>500.0x</strong>
            <span>Memory Reduction</span>
          </div>
        </div>

        <p className="aegis-evaluation-copy">
          Physical silicon evaluation on NVIDIA DGX Spark (Grace Blackwell GB10, 128 GB unified LPDDR5X memory)
          measuring AIEN compiled native components against unshared memory duplication baselines.
          Spawning 500 concurrent reasoning branches from a 32,768-token prefix completes in 1.20 ms total,
          recording 2.06 µs median fork latency and requiring only 704 MB of paged KV memory compared to 343.75 GB for naive copying.
        </p>

        <div className="table-scroll">
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.95rem" }}>
            <thead>
              <tr style={{ borderBottom: "2px solid rgba(255, 255, 255, 0.2)", textAlign: "left" }}>
                <th style={{ padding: "12px" }}>Workload / Metric</th>
                <th style={{ padding: "12px" }}>AIEN Sovereign Stack</th>
                <th style={{ padding: "12px" }}>Unshared / Python Baseline</th>
                <th style={{ padding: "12px" }}>Measured Physical Advantage</th>
              </tr>
            </thead>
            <tbody>
              <tr style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.1)" }}>
                <td style={{ padding: "12px", fontWeight: "600" }}>Control-Plane Scheduler Step Latency</td>
                <td style={{ padding: "12px", color: "#a855f7", fontWeight: "700" }}>8.00 µs (C=1 to 16)</td>
                <td style={{ padding: "12px" }}>12,000.00 µs (AsyncIO)</td>
                <td style={{ padding: "12px", color: "#22c55e" }}>Deterministic 8.00 µs native scheduling</td>
              </tr>
              <tr style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.1)" }}>
                <td style={{ padding: "12px", fontWeight: "600" }}>500-Branch Sequence Fork Latency</td>
                <td style={{ padding: "12px", color: "#a855f7", fontWeight: "700" }}>2.06 µs / branch (1.20 ms total)</td>
                <td style={{ padding: "12px" }}>960,000.00 µs (estimated copy)</td>
                <td style={{ padding: "12px", color: "#22c55e" }}>500.0x memory reduction (704 MB vs 343.75 GB)</td>
              </tr>
              <tr style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.1)" }}>
                <td style={{ padding: "12px", fontWeight: "600" }}>Cold Fork to First Token</td>
                <td style={{ padding: "12px", color: "#a855f7", fontWeight: "700" }}>13.04 µs (0.013 ms)</td>
                <td style={{ padding: "12px" }}>32.00 ms (full recompute)</td>
                <td style={{ padding: "12px", color: "#22c55e" }}>Zero prefill recomputation</td>
              </tr>
              <tr style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.1)" }}>
                <td style={{ padding: "12px", fontWeight: "600" }}>Control-Plane Memory Footprint (RSS)</td>
                <td style={{ padding: "12px", color: "#a855f7", fontWeight: "700" }}>4.56 MB to 10.11 MB</td>
                <td style={{ padding: "12px" }}>45.3 MB (Uvicorn) to 3,737 MB (Torch)</td>
                <td style={{ padding: "12px", color: "#22c55e" }}>-89.8% to -99.6% RAM reduction</td>
              </tr>
              <tr style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.1)" }}>
                <td style={{ padding: "12px", fontWeight: "600" }}>Transformer Embedding Latency</td>
                <td style={{ padding: "12px", color: "#a855f7", fontWeight: "700" }}>4.09 ms (ONNX INT8)</td>
                <td style={{ padding: "12px" }}>38.40 ms (Python route)</td>
                <td style={{ padding: "12px", color: "#22c55e" }}>9.4x faster (-34.31 ms)</td>
              </tr>
              <tr>
                <td style={{ padding: "12px", fontWeight: "600" }}>Continuous Batching Step (TinyLlama)</td>
                <td style={{ padding: "12px", color: "#a855f7", fontWeight: "700" }}>23.56 ms p50 @ C=16</td>
                <td style={{ padding: "12px" }}>Python IPC / multi-process loop</td>
                <td style={{ padding: "12px", color: "#22c55e" }}>553.14 tokens/sec, 0 fallback</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div className="aegis-eval-boundary">
          <div>
            <p className="aegis-eval-label">Verified Upstream Attribution</p>
            <p style={{ fontSize: "0.9rem", opacity: 0.9 }}>
              AIEN explicitly discloses upstream technology. LLaMA pure Mojo execution kernels are authored by Audrey (<code>a730/MojoLlama</code>), and graph execution relies on Modular MAX. AIEN contributes original architectures for continuous scheduling, physical unified KV memory management, radix prefix deduplication, subagent branching, and hardware-bound TPM secret vaults. Detailed audits reside in <a href="https://github.com/aien-dev/aien-sovereign-core/blob/main/docs/PROVENANCE.md" target="_blank" rel="noopener noreferrer" style={{ color: "var(--red)", textDecoration: "underline" }}>docs/PROVENANCE.md</a>.
            </p>
          </div>
          <div>
            <p className="aegis-eval-label">Empirical Datasets</p>
            <p style={{ fontSize: "0.9rem", opacity: 0.9 }}>
              Inspect raw benchmark JSON and reproducible measurement harnesses in <a href="https://github.com/aien-dev/benchmarks" target="_blank" rel="noopener noreferrer" style={{ color: "var(--red)", textDecoration: "underline" }}>aien-dev/benchmarks</a>.
            </p>
          </div>
        </div>
      </section>

      <section className="aegis-evaluation" aria-labelledby="aien-pressure-heading" style={{ marginTop: "48px" }}>
        <div className="aegis-evaluation-intro">
          <div>
            <p className="portrait-index">Physical Grace Blackwell Telemetry / TinyLlama-1.1B BF16</p>
            <h2 id="aien-pressure-heading">Continuous batching sweep on NVIDIA DGX Spark GB10.</h2>
          </div>
          <div className="aegis-total">
            <strong>553.14</strong>
            <span>tokens / sec @ C=16</span>
          </div>
        </div>

        <p className="aegis-evaluation-copy">
          Physical hardware sweep of continuous batching execution on NVIDIA DGX Spark Grace Blackwell GB10 (sm_121).
          All steps execute through pure Blackwell GPU tensor kernels with zero fallback. Peak throughput occurs at C=16
          with 23.56 ms p50 step latency and 27.89 W GPU power draw.
        </p>

        <div className="table-scroll">
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.92rem" }}>
            <thead>
              <tr style={{ borderBottom: "2px solid rgba(255, 255, 255, 0.2)", textAlign: "left" }}>
                <th style={{ padding: "10px" }}>Concurrency</th>
                <th style={{ padding: "10px" }}>TTFT p50</th>
                <th style={{ padding: "10px" }}>ITL p50</th>
                <th style={{ padding: "10px" }}>Throughput</th>
                <th style={{ padding: "10px" }}>Step Latency</th>
                <th style={{ padding: "10px" }}>Power Draw</th>
                <th style={{ padding: "10px" }}>GPU Util</th>
                <th style={{ padding: "10px" }}>KV Blocks</th>
              </tr>
            </thead>
            <tbody>
              {continuousBatchingSweepData.map((row) => (
                <tr key={row.concurrency} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                  <td style={{ padding: "10px", fontWeight: "700", color: "#a855f7" }}>{row.concurrency}</td>
                  <td style={{ padding: "10px" }}>{row.ttft}</td>
                  <td style={{ padding: "10px" }}>{row.itl}</td>
                  <td style={{ padding: "10px", fontWeight: "600", color: "#22c55e" }}>{row.throughput}</td>
                  <td style={{ padding: "10px" }}>{row.stepP50}</td>
                  <td style={{ padding: "10px" }}>{row.power}</td>
                  <td style={{ padding: "10px" }}>{row.gpuUtil}</td>
                  <td style={{ padding: "10px", opacity: 0.85 }}>{row.kvBlocks}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <p style={{ marginTop: "12px", fontSize: "0.9rem" }}>
          <Link to="/evidence#claim-continuous-batching-gb10" style={{ color: "var(--red)", textDecoration: "underline" }}>
            View canonical receipt (Run ID: gb10_canonical_1789907893_4d762) in the Evidence Hub
          </Link>
        </p>

        <div style={{ marginTop: "40px" }}>
          <h3 style={{ fontSize: "1.25rem", fontWeight: "700", marginBottom: "8px" }}>Multi-Model Architecture Breadth</h3>
          <p style={{ opacity: 0.85, fontSize: "0.95rem", marginBottom: "16px" }}>
            Empirical measurements confirm consistent execution across dense transformers, recurrent hybrids, and Mixture of Experts topologies:
          </p>
          <div className="table-scroll">
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.92rem" }}>
              <thead>
                <tr style={{ borderBottom: "2px solid rgba(255, 255, 255, 0.2)", textAlign: "left" }}>
                  <th style={{ padding: "10px" }}>Model</th>
                  <th style={{ padding: "10px" }}>Topology</th>
                  <th style={{ padding: "10px" }}>Quantization</th>
                  <th style={{ padding: "10px" }}>TTFT p50</th>
                  <th style={{ padding: "10px" }}>ITL p50</th>
                  <th style={{ padding: "10px" }}>KV Pool</th>
                  <th style={{ padding: "10px" }}>Status</th>
                </tr>
              </thead>
              <tbody>
                {multiModelBreadthData.map((m) => (
                  <tr key={m.model} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                    <td style={{ padding: "10px", fontWeight: "600" }}>{m.model}</td>
                    <td style={{ padding: "10px", opacity: 0.85 }}>{m.topology}</td>
                    <td style={{ padding: "10px", opacity: 0.85 }}>{m.quant}</td>
                    <td style={{ padding: "10px", color: "#a855f7" }}>{m.ttft}</td>
                    <td style={{ padding: "10px" }}>{m.itl}</td>
                    <td style={{ padding: "10px" }}>{m.kv}</td>
                    <td style={{ padding: "10px", color: "#ca8a04", fontWeight: "700" }}>{m.status}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div style={{ marginTop: "40px" }}>
          <h3 style={{ fontSize: "1.25rem", fontWeight: "700", marginBottom: "8px" }}>Multi-Platform Compatibility Matrix</h3>
          <p style={{ opacity: 0.85, fontSize: "0.95rem", marginBottom: "16px" }}>
            AIEN follows an evidence-based verification standard across architectures, distinguishing physical silicon certification from architected code paths:
          </p>
          <div className="aegis-eval-grid" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))" }}>
            {crossSurfaceData.map((item) => (
              <article key={item.surface} style={{ padding: "20px" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: "8px" }}>
                  <p style={{ fontWeight: "700", color: "#fff", margin: 0 }}>{item.surface}</p>
                  <span style={{ fontSize: "0.75rem", padding: "2px 8px", borderRadius: "4px", background: "rgba(34, 197, 94, 0.15)", color: "#22c55e", fontWeight: "700" }}>
                    {item.status}
                  </span>
                </div>
                <strong style={{ fontSize: "0.9rem", color: "#a855f7", display: "block", marginBottom: "6px" }}>
                  {item.processor}
                </strong>
                <span style={{ fontSize: "0.85rem", opacity: 0.8, display: "block", lineHeight: "1.4" }}>
                  {item.summary}
                </span>
              </article>
            ))}
          </div>
          <p style={{ marginTop: "12px", fontSize: "0.9rem" }}>
            <Link to="/evidence#claim-hardware-matrix" style={{ color: "var(--red)", textDecoration: "underline" }}>
              Inspect complete Platform Matrix in the Evidence Hub
            </Link>
          </p>
        </div>
      </section>

      <section className="aegis-boundary" id="principles" aria-labelledby="aien-principles-heading">
        <header className="aegis-section-lead">
          <p className="portrait-index">Architectural principles</p>
          <div>
            <h2 id="aien-principles-heading">Built for longevity, speed, and autonomy.</h2>
            <p>
              The system operates on four foundational rules designed to maintain reliability across months
              of continuous execution.
            </p>
          </div>
        </header>
        <div className="aegis-boundary-grid">
          {architectureTenets.map((tenet) => (
            <article className="aegis-boundary-card" key={tenet.title}>
              <h3>{tenet.title}</h3>
              <p>{tenet.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="aegis-action-bar">
        <div>
          <h3>Inspect the verified codebase</h3>
          <p>
            Review automated CI pipelines, formal verification test cases, and reproducible benchmarks:
          </p>
        </div>
        <div style={{ display: "flex", gap: "12px", flexWrap: "wrap" }}>
          <a
            className="portrait-link"
            href="https://github.com/aien-dev"
            target="_blank"
            rel="noopener noreferrer"
            onClick={() => trackRepoOutbound("aien-dev", "https://github.com/aien-dev")}
          >
            Visit github.com/aien-dev
          </a>
          <a
            className="portrait-link"
            href="https://github.com/aien-dev/benchmarks"
            target="_blank"
            rel="noopener noreferrer"
            onClick={() => trackRepoOutbound("benchmarks", "https://github.com/aien-dev/benchmarks")}
          >
            View aien-dev/benchmarks
          </a>
          <Link
            className="portrait-link quiet"
            to="/evidence"
          >
            Explore Evidence Hub
          </Link>
        </div>
      </section>

      <section className="soul-closing aegis-closing">
        <p className="portrait-index">The broader journey</p>
        <blockquote>
          Atlas provides the memory. AEGIS secures the boundary. AIEN runs the engine.
        </blockquote>
        <div className="portrait-actions">
          <Link className="portrait-link" to="/research">Read Inference Research Paper</Link>
          <Link className="portrait-link" to="/evidence">Inspect Evidence Hub</Link>
          <Link className="portrait-link quiet" to="/atlas">
            Return to Atlas
          </Link>
        </div>
      </section>
    </main>
  );
}
