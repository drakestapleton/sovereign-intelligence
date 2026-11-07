import { useState } from "react";
import { Link } from "react-router-dom";
import { EvidenceNotice, PageIntro } from "../components/PagePrimitives";
import { CLAIMS, EVIDENCE_CLASS_DEFINITIONS } from "../data/claims";
import { AUDIT_SCOPE, NEXT_SOURCES, VERIFIED_FINDINGS } from "../data/historyAudit";
import { usePageMeta } from "../lib/usePageMeta";

export function EvidencePage() {
  usePageMeta("/evidence");
  const [selectedCategory, setSelectedCategory] = useState<string>("ALL");

  const categories = ["ALL", ...Array.from(new Set(CLAIMS.map((c) => c.category)))];

  const filteredClaims =
    selectedCategory === "ALL"
      ? CLAIMS
      : CLAIMS.filter((c) => c.category === selectedCategory);

  return (
    <main className="wrap portrait-wrap evidence-page">
      <PageIntro
        eyebrow="Canonical Trust Hub / Systems Verification Record"
        title="Evidence, telemetry, and verified claims."
        className="path-header evidence-header"
      >
        <p>
          Every technical, architectural, and performance claim across this site binds directly to physical silicon telemetry,
          public git source code, cryptographic receipts, or structured forensic audit logs.
        </p>
      </PageIntro>

      {/* Silicon Receipt Callout */}
      <section className="silicon-receipt-banner" aria-labelledby="silicon-heading">
        <h3 id="silicon-heading">Physical Silicon Receipt: NVIDIA DGX Spark Grace Blackwell GB10</h3>
        <p>
          Run ID: <code>gb10_canonical_1789907893_4d762</code> | Platform: GB10 (sm_121, 128 GB Unified LPDDR5X, NVLink-C2C 900 GB/s)
        </p>
        <div className="silicon-metrics-grid">
          <div className="silicon-metric-item">
            <strong>2.06 µs</strong>
            <span>Median Fork Latency (500 branches, 32K context)</span>
          </div>
          <div className="silicon-metric-item">
            <strong>500.0x</strong>
            <span>Physical Memory Reduction (704 MB vs 343.75 GB)</span>
          </div>
          <div className="silicon-metric-item">
            <strong>553.14 tok/s</strong>
            <span>Peak Continuous Batching (TinyLlama-1.1B @ C=16)</span>
          </div>
          <div className="silicon-metric-item">
            <strong>13.04 µs</strong>
            <span>Cold Fork to First Token (0 CPU Fallback)</span>
          </div>
        </div>
        <div className="silicon-receipt-footer">
          <span>Manifest SHA256: <code>a78f0ad669b85e92ceffed38...</code></span>
          <span>Summary SHA256: <code>9cf62a25445e643b3f7d0af5...</code></span>
          <span>Verification: <strong>Zero Fallback (Pure sm_121 Kernels)</strong></span>
        </div>
        <div className="claim-reproduce-box" style={{ marginTop: "14px" }}>
          $ cd benchmarks && cargo run --release --bin bench_canonical_suite
        </div>
      </section>

      {/* Evidence Hierarchy */}
      <section className="evidence-section" aria-labelledby="classes-title">
        <p className="portrait-index">Evidentiary standard</p>
        <h2 id="classes-title">The evidence hierarchy: six distinct classes.</h2>
        <p style={{ color: "var(--copy)", marginBottom: "28px", maxWidth: "800px" }}>
          Evidence classes reflect varying degrees of independent verification. Public Reproductions and Public Sources
          are verifiable by independent third parties on standard hardware. Private Audit Records and Historical Records
          rely on archived workstation telemetry and structured forensic packages. Self-Reported accounts document operator intent.
        </p>
        <div className="evidence-class-grid">
          {Object.entries(EVIDENCE_CLASS_DEFINITIONS).map(([cls, def]) => (
            <article className="evidence-class" key={cls}>
              <p className="evidence-status">{def.trustLevel}</p>
              <h3>{def.label}</h3>
              <p>{def.description}</p>
            </article>
          ))}
        </div>
      </section>

      {/* Structured Claims Catalog */}
      <section className="evidence-section" aria-labelledby="claims-catalog-title">
        <p className="portrait-index">Structured Claims Catalog</p>
        <h2 id="claims-catalog-title">Verifiable systems claims index.</h2>
        <p style={{ color: "var(--copy)", marginBottom: "24px" }}>
          Filter claims by category or link directly to any claim ID anchor from documentation or research citations.
          Claims marked REGENERATING are withdrawn until their artifact bundles meet the current evidence standard.
        </p>
        <EvidenceNotice />

        <div className="claim-filters" role="group" aria-label="Filter claims by category">
          {categories.map((cat) => (
            <button
              key={cat}
              type="button"
              className={`claim-filter-btn ${selectedCategory === cat ? "active" : ""}`}
              onClick={() => setSelectedCategory(cat)}
            >
              {cat}
            </button>
          ))}
        </div>

        <div className="claims-grid">
          {filteredClaims.map((claim) => (
            <article className="claim-card" key={claim.id} id={claim.id}>
              <div className="claim-card-header">
                <div className="claim-badges">
                  <span className="claim-badge-class">{claim.evidenceClass}</span>
                  <span className="claim-badge-category">{claim.category}</span>
                  <span style={{ fontSize: "11px", fontWeight: "700", color: claim.currentStatus === "VERIFIED" || claim.currentStatus === "DOCUMENTED" ? "#16a34a" : "#ca8a04" }}>
                    {claim.currentStatus}
                  </span>
                </div>
                <a href={`#${claim.id}`} className="claim-id-anchor" title="Direct link to this claim">
                  #{claim.id}
                </a>
              </div>

              <h3>{claim.shortClaim}</h3>
              <p className="claim-full-text">{claim.fullWording}</p>

              {claim.reproductionInstructions && (
                <div className="claim-reproduce-box">
                  $ {claim.reproductionInstructions}
                </div>
              )}

              <div className="claim-footer-meta">
                <span>Period: <strong>{claim.dateOrPeriod}</strong></span>
                <span>Verified: <strong>{claim.verificationDate}</strong></span>
                <span>
                  Source:{" "}
                  {claim.sourceUrlOrRepo.startsWith("http") ? (
                    <a href={claim.sourceUrlOrRepo} target="_blank" rel="noopener noreferrer">
                      {claim.sourceUrlOrRepo.replace("https://github.com/", "")}
                    </a>
                  ) : (
                    <code>{claim.sourceUrlOrRepo}</code>
                  )}
                </span>
                {claim.artifactHash && (
                  <span className="claim-hash-tag">Hash: {claim.artifactHash.slice(0, 20)}...</span>
                )}
              </div>
            </article>
          ))}
        </div>
      </section>

      {/* Forensic History Scope */}
      <section className="evidence-section" aria-labelledby="audit-scope-title">
        <p className="portrait-index">Historical forensic scope</p>
        <h2 id="audit-scope-title">Forensic audit package coverage.</h2>
        <p style={{ color: "var(--copy)", marginBottom: "24px" }}>
          The nine-file audit package catalogs workstation commit records, pull request histories, and operational systems
          spanning 16 months of development.
        </p>
        <div className="audit-metrics" aria-label="Audit metrics">
          {AUDIT_SCOPE.map((metric) => (
            <div className="audit-metric" key={metric.label}>
              <strong>{metric.value}</strong>
              <span>{metric.label}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Verified Forensic Findings */}
      <section className="evidence-section" aria-labelledby="findings-title">
        <p className="portrait-index">Forensic findings</p>
        <h2 id="findings-title">Documented production systems.</h2>
        <div className="finding-list">
          {VERIFIED_FINDINGS.map((finding, index) => (
            <article className="finding" key={finding.title}>
              <span>{String(index + 1).padStart(2, "0")}</span>
              <div>
                <h3>{finding.title}</h3>
                <p>{finding.body}</p>
              </div>
            </article>
          ))}
        </div>
      </section>

      {/* Next Sources */}
      <section className="evidence-section audit-gaps" aria-labelledby="gaps-title">
        <p className="portrait-index">Verification roadmap</p>
        <h2 id="gaps-title">Ongoing provenance and validation.</h2>
        <ul>
          {NEXT_SOURCES.map((gap) => (
            <li key={gap}>{gap}</li>
          ))}
        </ul>
      </section>

      {/* Closing Actions */}
      <section className="portrait-closing compact">
        <p className="portrait-index">Systems Record</p>
        <h2>Built, operated, and verified on silicon.</h2>
        <p>
          Technical leadership requires measuring execution directly on target hardware rather than assuming theoretical metrics.
        </p>
        <div className="portrait-actions">
          <Link className="portrait-link" to="/">
            Return to the story
          </Link>
          <Link className="portrait-link quiet" to="/research">
            Read the inference research
          </Link>
        </div>
      </section>
    </main>
  );
}
