import { useMemo, useState } from "react";
import { PageIntro } from "../components/PagePrimitives";
import { usePageMeta } from "../lib/usePageMeta";

type Chapter = {
  n: string;
  title: string;
  part: string;
  summary: string;
};

const CHAPTERS: Chapter[] = [
  {
    n: "1",
    title: "Algebraic Construction of the Ω-Number Algebra",
    part: "Part I · Core Theory",
    summary:
      "Builds a new number system where dividing by zero gives a finite value: a fixed universal size Ω tied to the Planck length, times a phase factor that depends on the observer. Extends the complex numbers into a graded algebra so every operation physicists need still works.",
  },
  {
    n: "2",
    title: "Observer-Dependent Limits and Physical Mechanism",
    part: "Part I · Core Theory",
    summary:
      "Explains where the observer-dependent phase comes from: the accumulated twist (holonomy) of an observer connection traced along the observer's path, combining gravitational geometric phase, dynamical phase, and measurement context. Derives transformation rules proving different observers still get the same physics.",
  },
  {
    n: "3",
    title: "Variational Principle and Field Equations",
    part: "Part I · Core Theory",
    summary:
      "Derives the framework's equations of motion from a generalization of the action principle behind Einstein's equations. In ordinary conditions everything matches standard general relativity; at would-be singularities it predicts finite, observer-independent curvature instead of infinities.",
  },
  {
    n: "4",
    title: "Conservation Laws and Algebraic Consistency",
    part: "Part I · Core Theory",
    summary:
      "Verifies the new equations respect spacetime symmetries and standard conservation laws (energy-momentum via Noether's theorem), and that the algebra does not contradict itself.",
  },
  {
    n: "5",
    title: "Physical Predictions and Invariant Quantities",
    part: "Part I · Core Theory",
    summary:
      "The headline testable claim: the curvature at a black hole's center is a finite number set by the black hole's mass, identical for every observer, rather than an infinity.",
  },
  {
    n: "6",
    title: "Gravitational Wave Signature Predictions",
    part: "Part II · Observational Predictions",
    summary:
      "Predicts how a finite Ω-scale core at a black hole's center would change gravitational waves from mergers: post-merger echoes, altered ringdown tones, inspiral phase shifts, and changed radiation reaction.",
  },
  {
    n: "7",
    title: "Observer-Dependent Physical Manifestations",
    part: "Part II · Observational Predictions",
    summary:
      "Catalogs other observable consequences of the observer-dependent machinery: gravitational geometric-phase effects, measurement-entanglement signatures, relativistic transformation effects, and cosmic variability.",
  },
  {
    n: "8",
    title: "Quantum Gravity Interface and Divergence Regularization",
    part: "Part II · Observational Predictions",
    summary:
      "Shows how the framework slots into quantum field theory practice: corrections to effective field theories, modified renormalization-group flow, vacuum-fluctuation effects, and changes to black-hole evaporation.",
  },
  {
    n: "9",
    title: "Specific Numerical Predictions for Current Detectors",
    part: "Part II · Observational Predictions",
    summary:
      "Concrete numbers for LIGO-Virgo-KAGRA, LISA, the Event Horizon Telescope, pulsar timing arrays, and cosmological redshift effects. Includes predicted ~10⁻⁴-level deviations from general relativity for LISA.",
  },
  {
    n: "10",
    title: "Error Analysis and Confidence Intervals",
    part: "Part II · Observational Predictions",
    summary:
      "Quantifies the uncertainty budget behind every prediction, from numerical-relativity simulation errors to detector calibration and astrophysical noise.",
  },
  {
    n: "11",
    title: "Comparison with Existing Observational Data",
    part: "Part II · Observational Predictions",
    summary:
      "The scorecard: every existing measurement (GW150914 ringdown, the M87* shadow, pulsar timing) matches classical general relativity within errors, and the framework's predicted deviations sit below today's detection thresholds.",
  },
  {
    n: "12",
    title: "Experimental Validation Pathways",
    part: "Part II · Observational Predictions",
    summary:
      "A testing roadmap: LIGO A+ (2025 to 2030), LISA (2030 to 2040), next-generation detectors (2040+), with explicit pass/fail criteria the theory must meet.",
  },
];

const ASTRO_ENDPOINT = "/api/astro/chat";

type Msg = { role: "user" | "astro"; text: string };

function AstroChat() {
  const [messages, setMessages] = useState<Msg[]>([
    {
      role: "astro",
      text: "I am Astro, trained on the full Ω-framework manuscript. Ask me about any chapter, prediction, or open question.",
    },
  ]);
  const [input, setInput] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function send() {
    const text = input.trim();
    if (!text || busy) return;
    setInput("");
    setError(null);
    setMessages((m) => [...m, { role: "user", text }]);
    setBusy(true);
    try {
      const res = await fetch(ASTRO_ENDPOINT, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: text }),
      });
      if (!res.ok) throw new Error(`Astro is not reachable right now (HTTP ${res.status}).`);
      const data = await res.json();
      setMessages((m) => [...m, { role: "astro", text: data.reply ?? "Astro returned no reply." }]);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Astro is not reachable right now.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="aegis-house" aria-labelledby="omega-chat-heading">
      <p className="portrait-index">Conversation</p>
      <div>
        <h2 id="omega-chat-heading">Chat with Astro about the paper.</h2>
        <p>
          Astro is a model served from the DGX Spark that knows this manuscript end to end.
          Ask it to explain a chapter, defend a prediction, or steelman an objection.
        </p>
      </div>
      <div
        className="claim-card"
        style={{ marginTop: "20px", display: "flex", flexDirection: "column", gap: "12px", minHeight: "320px" }}
      >
        <div style={{ display: "flex", flexDirection: "column", gap: "10px", maxHeight: "380px", overflowY: "auto" }}>
          {messages.map((m, i) => (
            <div
              key={i}
              style={{
                alignSelf: m.role === "user" ? "flex-end" : "flex-start",
                maxWidth: "85%",
                padding: "10px 14px",
                borderRadius: "10px",
                background: m.role === "user" ? "var(--blue-pale)" : "var(--dark-surface)",
                border: "1px solid var(--line)",
                color: "var(--copy)",
                fontSize: "15px",
              }}
            >
              {m.text}
            </div>
          ))}
          {busy && <div style={{ color: "var(--muted)", fontSize: "14px" }}>Astro is thinking…</div>}
        </div>
        {error && <p style={{ color: "var(--red)", fontSize: "14px" }}>{error}</p>}
        <div style={{ display: "flex", gap: "10px" }}>
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && send()}
            placeholder="Ask Astro about the Ω-framework…"
            aria-label="Ask Astro about the Omega framework"
            style={{
              flex: 1,
              padding: "10px 14px",
              borderRadius: "8px",
              border: "1px solid var(--line)",
              background: "var(--paper)",
              color: "var(--copy)",
              fontSize: "15px",
            }}
          />
          <button
            onClick={send}
            disabled={busy}
            className="aegis-action-primary"
            style={{ textDecoration: "none", cursor: busy ? "wait" : "pointer" }}
          >
            Send
          </button>
        </div>
      </div>
    </section>
  );
}

export function OmegaPage() {
  usePageMeta("/scholar/omega");
  const [query, setQuery] = useState("");

  const results = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return CHAPTERS;
    return CHAPTERS.filter(
      (c) =>
        c.title.toLowerCase().includes(q) ||
        c.summary.toLowerCase().includes(q) ||
        c.part.toLowerCase().includes(q) ||
        c.n.toLowerCase() === q
    );
  }, [query]);

  return (
    <main className="wrap portrait-wrap aegis-page omega-page">
      <PageIntro
        eyebrow="Scholar / Unpublished Manuscript"
        title="The Ω-Framework: An Observer-Dependent Resolution of Singularities in General Relativity and Quantum Gravity."
        className="aegis-hero"
      >
        <p>
          A manuscript in progress. Classical general relativity predicts infinities where collapsing
          matter and the early universe evolve toward infinite curvature. This framework assigns
          division by zero a finite, observer-dependent value, x/0 = Ω·e^(iτ), and derives
          testable predictions from it. Search the chapters below, or ask Astro.
        </p>
      </PageIntro>

      <div className="aegis-scope-strip" aria-label="Manuscript highlights">
        <span>12 Chapters · 2 Parts</span>
        <span>x/0 = Ω·e^(iτ)</span>
        <span>Finite curvature at r = 0</span>
        <span>Status: unpublished manuscript</span>
      </div>

      {/* Chapter search + tiles */}
      <section className="aegis-response" aria-labelledby="omega-chapters-heading">
        <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", flexWrap: "wrap", gap: "12px" }}>
          <h2 id="omega-chapters-heading" style={{ margin: 0 }}>Chapters.</h2>
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search chapters…"
            aria-label="Search Omega framework chapters"
            style={{
              padding: "10px 14px",
              borderRadius: "8px",
              border: "1px solid var(--line)",
              background: "var(--paper)",
              color: "var(--copy)",
              fontSize: "15px",
              minWidth: "240px",
            }}
          />
        </div>
        <p style={{ fontSize: "14px", color: "var(--muted)" }}>
          {results.length} of {CHAPTERS.length} chapters{query.trim() ? ` matching “${query.trim()}”` : ""}.
        </p>
        <div className="evidence-class-grid" style={{ marginTop: "16px" }}>
          {results.map((c) => (
            <article className="evidence-class" key={c.n}>
              <p className="evidence-status">
                Chapter {c.n} · {c.part}
              </p>
              <h3>{c.title}</h3>
              <p>{c.summary}</p>
            </article>
          ))}
        </div>
        {results.length === 0 && (
          <p style={{ color: "var(--muted)" }}>No chapters match that search. Try “LISA”, “algebra”, or “singularity”.</p>
        )}
      </section>

      <AstroChat />

      {/* Honest status */}
      <section className="aegis-knockout" aria-labelledby="omega-status-heading">
        <p className="portrait-index">Status</p>
        <h2 id="omega-status-heading">Where this stands, honestly.</h2>
        <p>
          This is an unpublished manuscript, not a peer-reviewed paper. It has not been submitted
          to a journal or posted to a preprint server. The manuscript's own analysis reports null
          statistical significance against current data and flags open problems: dimensional
          inconsistencies in some predictions, tension with cosmic microwave background bounds,
          and an observer connection not yet derived from first principles.
        </p>
        <p>
          It is published here so others can study it, check the math, and argue with it.
          That is the point.
        </p>
      </section>
    </main>
  );
}
