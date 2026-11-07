import { Link } from "react-router-dom";
import { PageIntro, SectionLead } from "../components/PagePrimitives";
import { usePageMeta } from "../lib/usePageMeta";

const publishedWorks = [
  {
    kind: "Master's Thesis · 2018",
    title: "Imidazolium Ionic Liquids as Multifunctional Solvents, Ligands, and Reducing Agents for Noble Metal Deposition onto Well-Defined Heterostructures and the Effect of Synthetic History on Catalytic Performance",
    venue: "Western Kentucky University · Department of Chemistry · Advisor: Dr. Lawrence J. Hill",
    summary:
      "Investigated [BMIM]Tf2N as a multifunctional solvent, ligand, and reducing agent for platinum deposition onto CdSe@CdS nanorods, thermally and photochemically. Ionic-liquid synthesis outperformed organic-solvent routes in photocatalytic methylene blue degradation.",
    link: "https://digitalcommons.wku.edu/theses/2101/",
    linkLabel: "Read the thesis (WKU Digital Commons)",
  },
  {
    kind: "Peer-Reviewed Paper · 2019",
    title: "Deposition of metal particles onto semiconductor nanorods using an ionic liquid",
    venue: "Beilstein Journal of Nanotechnology · 10:718-724 · DOI 10.3762/bjnano.10.71 · PMID 30931213",
    summary:
      "Platinum, gold, and silver nanoparticles deposited onto CdSe@CdS nanorods from metal salts in an ionic liquid with no added surfactants or reducing agents. Platinum deposited this way outperformed organic-solvent materials in photocatalytic dye degradation.",
    link: "https://pubmed.ncbi.nlm.nih.gov/30931213/",
    linkLabel: "Read the paper (PubMed)",
  },
];

const hubs = [
  {
    to: "/scholar/omega",
    kicker: "Theory of Everything · Manuscript",
    title: "The Omega Framework",
    body: "An observer-dependent resolution of singularities in general relativity and quantum gravity. Browse every chapter as searchable tiles, each with a plain-language summary, and chat with the Astro model that knows the paper.",
  },
  {
    to: "/research",
    kicker: "Systems Research · Mini Hub",
    title: "Orchestration Research",
    body: "The AIEN Sovereign Inference Stack: eliminating the software orchestration tax in LLM inference with a native Rust ABI, paged KV cache, and Grace Blackwell telemetry.",
  },
  {
    to: "/atlas",
    kicker: "R&D Program",
    title: "Atlas",
    body: "The accountable-AI research program: a persistent, self-directed digital counterpart with separate memory, identity, and evidence ledgers.",
  },
  {
    to: "/aegis",
    kicker: "Defense",
    title: "AEGIS",
    body: "The defensive extension: hardware-enforced containment and evidence preservation for the Atlas organism.",
  },
  {
    to: "/aien",
    kicker: "Cognitive Architecture",
    title: "AIEN",
    body: "The sovereign cognitive architecture: compiled Rust and Mojo, hardware TPM vault, local inference on dedicated silicon.",
  },
];

export function ScholarPage() {
  usePageMeta("/scholar");

  return (
    <main className="wrap portrait-wrap aegis-page scholar-page">
      <PageIntro
        eyebrow="Scholar / Academic Work"
        title="Theories, thoughts, and actual academic work."
        className="aegis-hero"
      >
        <p>
          The published record first: a master's thesis and a peer-reviewed paper on semiconductor
          nanorods from Western Kentucky University. Below that, the unpublished and in-progress
          work: the Omega framework manuscript, orchestration research, and open questions.
        </p>
      </PageIntro>

      {/* Published */}
      <section className="aegis-house" aria-labelledby="scholar-published-heading">
        <p className="portrait-index">Published</p>
        <div>
          <h2 id="scholar-published-heading">The published record.</h2>
          <p>
            What survived peer review and a thesis committee. Full text available through the
            university repository and PubMed.
          </p>
        </div>
        <div className="evidence-class-grid" style={{ marginTop: "24px" }}>
          {publishedWorks.map((w) => (
            <article className="evidence-class" key={w.title}>
              <p className="evidence-status">{w.kind}</p>
              <h3>{w.title}</h3>
              <p style={{ fontSize: "13px", color: "var(--muted)" }}>{w.venue}</p>
              <p>{w.summary}</p>
              <p>
                <a href={w.link} target="_blank" rel="noopener noreferrer" style={{ color: "var(--red)", textDecoration: "underline" }}>
                  {w.linkLabel}
                </a>
              </p>
            </article>
          ))}
        </div>
      </section>

      {/* Research hubs */}
      <section className="aegis-response" aria-labelledby="scholar-hubs-heading">
        <SectionLead
          eyebrow="Research Hubs"
          title="Unpublished work, open theories, and live research."
          titleId="scholar-hubs-heading"
        >
          <p>
            Manuscripts in progress, systems research, and the models trained on them.
          </p>
        </SectionLead>
        <div className="evidence-class-grid">
          {hubs.map((h) => (
            <article className="evidence-class" key={h.to}>
              <p className="evidence-status">{h.kicker}</p>
              <h3>{h.title}</h3>
              <p>{h.body}</p>
              <p>
                <Link to={h.to} style={{ color: "var(--red)", textDecoration: "underline" }}>
                  Open →
                </Link>
              </p>
            </article>
          ))}
        </div>
      </section>

      {/* Unpublished & misc */}
      <section className="aegis-knockout" aria-labelledby="scholar-misc-heading">
        <p className="portrait-index">Unpublished &amp; Miscellaneous</p>
        <h2 id="scholar-misc-heading">Working notes and open threads.</h2>
        <p>
          Ages and AIEN research conversations live here as they are organized.
          Check back: this shelf fills in as manuscripts and notes are prepared for publication.
        </p>
      </section>
    </main>
  );
}
