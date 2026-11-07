export type EvidenceClass =
  | "PUBLIC REPRODUCTION"
  | "PUBLIC SOURCE"
  | "PUBLICATION"
  | "PRIVATE AUDIT RECORD"
  | "HISTORICAL RECORD"
  | "SELF-REPORTED";

export type PublicStatus = "PUBLIC" | "PRIVATE";

export type ClaimStatus = "VERIFIED" | "ACTIVE" | "DOCUMENTED" | "REGENERATING";

export interface ClaimRecord {
  id: string;
  shortClaim: string;
  fullWording: string;
  category:
    | "Inference & Branching"
    | "Memory & KV Cache"
    | "Security Architecture"
    | "Autonomous Multi-Agent"
    | "Hardware Evaluation"
    | "Operational History";
  dateOrPeriod: string;
  evidenceClass: EvidenceClass;
  publicStatus: PublicStatus;
  sourceUrlOrRepo: string;
  verificationDate: string;
  currentStatus: ClaimStatus;
  reproductionInstructions?: string;
  artifactHash?: string;
}

export const EVIDENCE_CLASS_DEFINITIONS: Record<EvidenceClass, { label: string; description: string; trustLevel: string }> = {
  "PUBLIC REPRODUCTION": {
    label: "Public Reproduction",
    description: "Independently runnable code artifacts with open reproduction harnesses, fixed random seeds, and machine-verifiable receipts.",
    trustLevel: "Highest (Empirically Reproducible by Third Parties)",
  },
  "PUBLIC SOURCE": {
    label: "Public Source",
    description: "Publicly visible git repository source code, commit histories, PR reviews, and automated CI test runs.",
    trustLevel: "High (Inspectable in Public Repositories)",
  },
  "PUBLICATION": {
    label: "Publication",
    description: "Formal research manuscripts, architectural specifications, and published systems evaluation papers.",
    trustLevel: "High (Peer-Reviewable Methodology)",
  },
  "PRIVATE AUDIT RECORD": {
    label: "Private Audit Record",
    description: "Structured forensic audit packages, frozen evaluation test suites, and internal test logs preserved from private development runs.",
    trustLevel: "Moderate (Internally Documented with Audit Package)",
  },
  "HISTORICAL RECORD": {
    label: "Historical Record",
    description: "Archived workstation commit trees, migration ledgers, timeline records, and conversation history exports.",
    trustLevel: "Contextual (Reconstructed Historical Evidence)",
  },
  "SELF-REPORTED": {
    label: "Self-Reported",
    description: "First-person narrative accounts, architectural intent statements, and operational reflections.",
    trustLevel: "Foundational (Personal Narrative and Primary Experience)",
  },
};

export const CLAIMS: ClaimRecord[] = [
  {
    id: "claim-branching-fork-gb10",
    shortClaim: "2.06 µs Zero-Copy Sequence Branching on Grace Blackwell",
    fullWording: "On physical NVIDIA DGX Spark Grace Blackwell GB10 hardware (sm_121), spawning 500 concurrent reasoning branches from a 32,768-token prefix completes in 1.20 ms total, measuring a median fork latency of 2.06 µs per branch. Physical paged KV allocation requires 704.00 MB across 2,048 shared blocks with zero duplicate pages, representing a 500.0x memory reduction compared to naive 352,000 MB buffer replication.",
    category: "Inference & Branching",
    dateOrPeriod: "2026-09-20",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/benchmarks/tree/main/artifacts/gb10_canonical_1789907893_4d762",
    verificationDate: "2026-09-20",
    currentStatus: "REGENERATING",
    reproductionInstructions: "cd benchmarks && cargo run --release --bin bench_canonical_suite",
    artifactHash: "sha256:6cf46288e554c41bc5003fd3e0c7d56e25dbc15466ce8ab67ca4db14f7af8155",
  },
  {
    id: "claim-continuous-batching-gb10",
    shortClaim: "553.14 tokens/sec Continuous Batching Peak on TinyLlama-1.1B",
    fullWording: "Physical Grace Blackwell GB10 continuous batching execution of TinyLlama-1.1B BF16 achieves a peak throughput of 553.14 tokens/sec at concurrency C=16 with 23.56 ms p50 step latency and 27.89 W GPU power. Saturated concurrency at C=64 yields 510.16 tokens/sec with 101.70 ms step latency, 42.52 W power, and 96% GPU utilization, maintaining zero CPU fallback across all steps.",
    category: "Inference & Branching",
    dateOrPeriod: "2026-09-20",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/benchmarks/tree/main/artifacts/gb10_canonical_1789907893_4d762",
    verificationDate: "2026-09-20",
    currentStatus: "REGENERATING",
    reproductionInstructions: "cd benchmarks && cargo run --release --bin bench_canonical_suite",
    artifactHash: "sha256:0362ac84d0eb0ddcdc1a877ef449a2030eb59c0d5ed0a621fcc75aac8f661858",
  },
  {
    id: "claim-cold-fork-latency",
    shortClaim: "13 µs Cold Fork to First Token",
    fullWording: "Cold sequence branch initiation from a 32,768-token shared prefix to first token generation executes in 13.04 µs (0.013 ms) on Grace Blackwell GB10, requiring only 1 physical page allocation for copy-on-write tail divergence.",
    category: "Inference & Branching",
    dateOrPeriod: "2026-09-20",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/benchmarks/tree/main/artifacts/gb10_canonical_1789907893_4d762",
    verificationDate: "2026-09-20",
    currentStatus: "REGENERATING",
    reproductionInstructions: "cd benchmarks && cargo run --release --bin bench_canonical_suite",
    artifactHash: "sha256:d09869d5a3ec4365bec4f97f1d8e7ba32ea0d799ea6160bb0aed82b9904fa567",
  },
  {
    id: "claim-cow-mutation-latency",
    shortClaim: "13.30 µs Copy-on-Write Page Mutation",
    fullWording: "Copy-on-write page mutation during branch divergence executes in 13.30 µs (13,297 ns) on physical unified memory, isolating sequence state while peer branches proceed concurrently.",
    category: "Memory & KV Cache",
    dateOrPeriod: "2026-09-20",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/benchmarks/tree/main/artifacts/gb10_canonical_1789907893_4d762",
    verificationDate: "2026-09-20",
    currentStatus: "REGENERATING",
    reproductionInstructions: "cd benchmarks && cargo run --release --bin bench_canonical_suite",
    artifactHash: "sha256:6cf46288e554c41bc5003fd3e0c7d56e25dbc15466ce8ab67ca4db14f7af8155",
  },
  {
    id: "claim-kv-pool-allocation",
    shortClaim: "134M Blocks/Sec KV Allocation Throughput",
    fullWording: "Pure Rust paged memory pool manager achieves 134,338,182 block allocations per second (7.44 ns per block) and 238,709,061 deallocations per second (4.19 ns per block) using deterministic O(1) bitmapped indexing over pre-allocated unified buffers.",
    category: "Memory & KV Cache",
    dateOrPeriod: "2026-09-18",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/aien-sovereign-core/tree/main/crates/aien-kv-cache",
    verificationDate: "2026-09-18",
    currentStatus: "REGENERATING",
    reproductionInstructions: "cd aien-sovereign-core && cargo test -p aien-kv-cache --release",
    artifactHash: "sha256:43f3dbf2...",
  },
  {
    id: "claim-zero-disk-secrets",
    shortClaim: "Dynamic In-Memory Resolution from Hardware TPM 2.0",
    fullWording: "Plaintext secrets, API keys, and private credentials resolve dynamically into volatile process memory from the physical TPM 2.0 security chip (/dev/tpmrm0) on Linux and Secure Enclave / Keychain on Apple Silicon, keeping persistent storage free of plaintext keys.",
    category: "Security Architecture",
    dateOrPeriod: "2026-09-19",
    evidenceClass: "PUBLIC SOURCE",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/aien-sovereign-core/blob/main/docs/adr/0001-trust-evidence-foundation.md",
    verificationDate: "2026-09-20",
    currentStatus: "VERIFIED",
    reproductionInstructions: "cd aien-sovereign-core && cargo test --test test_tier1_feature_coverage test_f17_02_secrets_resolve_via_tpm_vault",
  },
  {
    id: "claim-hardware-matrix",
    shortClaim: "Evidence-Based Multi-Platform Support Matrix",
    fullWording: "AIEN documents explicit verification tiers rather than generic universal support. Physical runtime and benchmarks are verified on NVIDIA DGX Spark Grace Blackwell GB10 (Primary Reference). Apple Silicon macOS and generic Linux x86_64 are validated runtime targets with CI testing. AMD ROCm is architected with HIP bindings pending physical cluster validation.",
    category: "Hardware Evaluation",
    dateOrPeriod: "2026-09-19",
    evidenceClass: "PUBLIC SOURCE",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/aien-sovereign-core/blob/main/docs/PLATFORM_MATRIX.md",
    verificationDate: "2026-09-20",
    currentStatus: "VERIFIED",
  },
  {
    id: "claim-memory-rss-aegis",
    shortClaim: "4.8 MB Resident Set Size for Native Agent Daemons",
    fullWording: "Standalone native compiled Rust daemons execute in under 10 megabytes of memory footprint: aegis-runtime (formerly openclaw-rs) operates at 4.8 MB RSS, spark-cockpit-rs at 8.6 MB RSS, and cortex-rs at 10.3 MB RSS, compared to 45.3 MB for a minimal Uvicorn route and 3,737 MB for an unquantized Python agent runtime loading PyTorch and LangChain.",
    category: "Autonomous Multi-Agent",
    dateOrPeriod: "2026-09-19",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/benchmarks/tree/main/data",
    verificationDate: "2026-09-19",
    currentStatus: "REGENERATING",
    reproductionInstructions: "cd benchmarks && python3 -m unittest discover -s tests",
  },
  {
    id: "claim-axum-latency",
    shortClaim: "3.56 ms p50 TTFB Gateway Latency under Load",
    fullWording: "Native Axum microservices deliver sub-4 ms response times under concurrent load (3.56 ms p50 at 2,056 requests/sec on cortex-rs /api/get, and 4.30 ms p50 at 1,921 requests/sec on spark-cockpit-rs), compared to 38.4 ms at 214 requests/sec on a standard asynchronous Python FastAPI route.",
    category: "Autonomous Multi-Agent",
    dateOrPeriod: "2026-09-19",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/benchmarks/tree/main/data",
    verificationDate: "2026-09-19",
    currentStatus: "REGENERATING",
    reproductionInstructions: "cd benchmarks && python3 -m unittest discover -s tests",
  },
  {
    id: "claim-query-vectorization",
    shortClaim: "4.09 ms Query Vectorization via Native ONNX INT8",
    fullWording: "Short query vectorization executes in 4.09 ms using the native ONNX Runtime C-API with INT8 quantization on Grace Blackwell workstation silicon, generating normalized 768-dimensional embeddings for memory indexing.",
    category: "Hardware Evaluation",
    dateOrPeriod: "2026-09-19",
    evidenceClass: "PUBLIC REPRODUCTION",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://github.com/aien-dev/benchmarks/tree/main/data",
    verificationDate: "2026-09-19",
    currentStatus: "REGENERATING",
  },
  {
    id: "claim-aegis-adapter-eval",
    shortClaim: "59 of 62 Checks Passed in Frozen Project Evaluation",
    fullWording: "The August 20, 2026 AEGIS defender adapter passed 59 of 62 checks (95.2%) in a frozen evaluation suite: 45/45 on tool use, 8/10 on coding, 3/4 on science, and 3/3 on cybersecurity containment actions within authorized estate boundaries.",
    category: "Security Architecture",
    dateOrPeriod: "2026-08-20",
    evidenceClass: "PRIVATE AUDIT RECORD",
    publicStatus: "PRIVATE",
    sourceUrlOrRepo: "artifacts/aegis-eval-20260820.json",
    verificationDate: "2026-08-20",
    currentStatus: "VERIFIED",
  },
  {
    id: "claim-symphony-first-run",
    shortClaim: "First Documented Symphony Multi-Model Run (July 30, 2026)",
    fullWording: "First documented Atlas Symphony run executed on July 30, 2026, invented and operated by Drake Stapleton. It established bounded work lanes, human operator gates, and coordinated review across Claude, Codex, and Grok with zero unmonitored agent autonomy.",
    category: "Autonomous Multi-Agent",
    dateOrPeriod: "2026-07-30",
    evidenceClass: "HISTORICAL RECORD",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://drakestapleton.com/symphony/first",
    verificationDate: "2026-08-01",
    currentStatus: "DOCUMENTED",
  },
  {
    id: "claim-workstation-history",
    shortClaim: "4,701 Workstation Commits Across 94 Project Trees",
    fullWording: "Between April 2025 and August 2026, internal workstation logs document 4,701 commits across 94 project trees, verifying the progression from early ledger accounting and CRM systems to autonomous multi-agent orchestration and compiled cognitive runtimes.",
    category: "Operational History",
    dateOrPeriod: "Apr 2025 - Aug 2026",
    evidenceClass: "HISTORICAL RECORD",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://drakestapleton.com/evidence",
    verificationDate: "2026-09-08",
    currentStatus: "DOCUMENTED",
  },
  {
    id: "claim-defiantmob-production",
    shortClaim: "DefiantMob Production Operator Desk with 94 Merged PRs",
    fullWording: "DefiantMob production operator software reached live operation with 250 commits, 94 merged pull requests, and automated member management, ledgers, and payout tracking.",
    category: "Operational History",
    dateOrPeriod: "Feb 2026 - May 2026",
    evidenceClass: "HISTORICAL RECORD",
    publicStatus: "PUBLIC",
    sourceUrlOrRepo: "https://drakestapleton.com/path",
    verificationDate: "2026-09-08",
    currentStatus: "DOCUMENTED",
  },
];

export function getClaim(id: string): ClaimRecord | undefined {
  return CLAIMS.find((c) => c.id === id);
}

export function getClaimsByCategory(category: ClaimRecord["category"]): ClaimRecord[] {
  return CLAIMS.filter((c) => c.category === category);
}
