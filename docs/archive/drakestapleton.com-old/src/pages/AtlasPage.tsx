import { Link } from "react-router-dom";
import { PageIntro } from "../components/PagePrimitives";
import { HisWords } from "../components/VoiceMark";
import { usePageMeta } from "../lib/usePageMeta";

const organs = [
  {
    name: "Soul",
    role: "The moral floor",
    body: "The root of trust held on a Raspberry Pi: purpose, consent, authority, shutdown, and the limits every other part of the system must preserve.",
    mechanics: ["Physically separable", "Sealed from model edits", "Operator authority stays explicit"],
  },
  {
    name: "Spirit",
    role: "The formed character",
    body: "The model layer that turns context into language. The private monologue and public voice run as distinct model roles, with custom weights and exact model identity checks.",
    mechanics: ["Separate thought and speech lanes", "Custom model weights", "Identity verified before routing"],
  },
  {
    name: "Brain",
    role: "The persistent executive home",
    body: "A directory-backed continuity system built from distinct stores for conversation, monologue, pipeline events, durable memories, sessions, and retrieval residuals.",
    mechanics: ["Separate JSONL ledgers", "Session isolation", "Retrieval with source boundaries"],
  },
  {
    name: "Queen",
    role: "The on-demand work force",
    body: "Separate heavy-lift compute and an operator-only control surface for work kept outside an ordinary conversation turn.",
    mechanics: ["GPU capacity on demand", "Operator-only control", "Budgeted start and stop"],
  },
];

const turnPipeline = [
  {
    name: "Intake and isolation",
    role: "Route",
    body: "A message arrives through the local interface or Discord path. The server resolves the person, conversation, session, and persistence rules before any model answers, so every identity keeps its own authority store.",
  },
  {
    name: "Context assembly",
    role: "Retrieve",
    body: "The route gathers only the context it is allowed to use: recent conversation, durable memories, short continuity residuals, current scene and environment, social bonds, mood, habits, conflicts, and any enabled hemisphere context.",
  },
  {
    name: "Sealed felt state",
    role: "Subconscious",
    body: "A private state engine advances hunger, thirst, fatigue, sleepiness, discomfort, affect, mood, and development from wall-clock time and lived events. The language model receives effects from this layer, while direct model writes stop at its boundary.",
  },
  {
    name: "Private thought",
    role: "Monologue",
    body: "A dedicated monologue model runs first. It must finish before speech can begin. If it fails, the turn fails closed instead of quietly skipping thought; even an empty result receives an explicit marker proving the stage ran.",
  },
  {
    name: "Continuity write",
    role: "Brain",
    body: "The Brain filters the thought into a residual, writes it to the proper ledger, retrieves useful recent residuals, and applies repetition and loop guards before the public answer is formed.",
  },
  {
    name: "Outer answer",
    role: "Spirit",
    body: "The speech model receives the current message, same-turn monologue, and permitted Brain context. It streams the answer people see while preserving private thought and public speech as distinct model calls.",
  },
  {
    name: "After-turn record",
    role: "Persist",
    body: "The transcript and pipeline evidence are recorded, then lived events can update affect, development, mood, and social continuity. Ephemeral probes and isolated Discord routes can be kept out of the operator's durable session store.",
  },
];

const memoryLayers = [
  {
    name: "Conversation ledger",
    body: "What was said, by whom, in which session. A new chat can clear the visible pane while Brain stores remain, and resume-continuity mode can deliberately bring prior memory back into context.",
  },
  {
    name: "Monologue ledger",
    body: "Private thought is recorded separately from public speech, so inspection preserves each stage as a distinct event.",
  },
  {
    name: "Pipeline ledger",
    body: "Stage-by-stage receipts show which parts of a turn ran, which model route was used, and where a failure occurred.",
  },
  {
    name: "Durable memory",
    body: "Selected continuity records and retrieval residuals can return in later turns through focused retrieval instead of replaying an entire life history into every prompt.",
  },
  {
    name: "Sealed state",
    body: "Affect, development, body pressure, social bonds, mood, habits, conflicts, interrupted actions, and environmental state have their own stores and update rules outside ordinary model editing.",
  },
  {
    name: "Mission evidence",
    body: "Coding and research work uses a separate mission ledger with provider handoffs, checks, costs, decisions, and completion evidence.",
  },
];

const operatingPlanes = [
  {
    status: "Conversation runtime",
    name: "Atlas talks through a linked mind pipeline.",
    body: "Discord is designed as the permanent front door. The simple local talk server runs on loopback as a tool-free surface. A separate full operator surface can expose optional read-only tools and world context, while the affect and development engines remain sealed from direct model edits.",
  },
  {
    status: "Model runtime",
    name: "The router separates everyday use from model testing.",
    body: "Discord speech normally uses a 27B everyday Spirit lane. An opt-in 122B candidate can be tested while the default stays fixed. The router probes the exact model identity, falls back to the everyday lane when the candidate is unavailable, and treats missing or malformed router state as everyday mode.",
  },
  {
    status: "Work orchestration",
    name: "Atlas Harness coordinates suppliers beside the chat mind.",
    body: "For coding work, Atlas sits above live-probed Codex, Claude, and Grok runtimes. Tasks enter a protected mission lane, continue through bounded handoffs or failover, and remain attached to an isolated worktree, a persistent event history, and a computed done gate.",
  },
  {
    status: "Heavy work and research",
    name: "Queen, Hive, and J-space have different jobs.",
    body: "Queen is the separate heavy-lift lane. Hive 4.0 extends that work through temporary fleets, fenced leases, freeze controls, and evidence rollups. J-space runs declared research scenarios and records the resulting responses.",
  },
];

export function AtlasPage() {
  usePageMeta("/atlas");

  return (
    <main className="wrap portrait-wrap atlas-page">
      <PageIntro eyebrow="Atlas / My latest project" title="My greatest achievement so far, built from everything that came before." className="atlas-hero">
        <p>
          Atlas brings together my work in science, manufacturing, community leadership, software, model
          training, and research. Its personal origin lives in a question that stayed with me: can
          technology help me meet Dad&apos;s words honestly and honor the person who wrote them?
        </p>
      </PageIntro>

      <section className="atlas-before" aria-labelledby="before-atlas-heading">
        <p className="portrait-index">Before Atlas had a name</p>
        <div>
          <h2 id="before-atlas-heading">I started with questions about the universe.</h2>
          <p>
            The earliest AI conversation I can still document is from February 5, 2023. I was asking about
            quantum communication across space. Two weeks later I was building a numerical model of the
            Sun and Earth. Then came black holes, gravitational waves, consciousness, identity, uploaded
            minds, simulated realities, and recursive worlds.
          </p>
          <blockquote>What happens when a system becomes capable of modeling itself?</blockquote>
          <p>
            Years later, I can see the line running through every question. Atlas grew from asking what
            continuity means, what makes a self, and how a system can tell which parts of its own story are
            real.
          </p>
        </div>
      </section>

      <section className="atlas-letter" aria-labelledby="one-more-heading">
        <p className="portrait-index">The human reason</p>
        <div>
          <h2 id="one-more-heading"><HisWords>I wanted one more conversation.</HisWords></h2>
          <p>
            Dad was a preacher. His writing holds years of his thinking in his own hand. I want to
            scan those pages, preserve the originals, study the patterns in his language, and build a way
            to ask the questions I still carry.
          </p>
          <p>
            Dad gave me the Ballentine name, taught me to work, and showed me how to make myself useful. I
            miss him deeply. I am grateful for what he put into me, and I believe he has stayed close as a
            guardian angel through every new door.
          </p>
          <blockquote>
            <HisWords>
              “I miss Dad. I want one more encounter with the words he left and the closure I have carried for
              years.”
            </HisWords>
          </blockquote>
        </div>
      </section>

      <section className="atlas-definition" aria-labelledby="counterpart-heading">
        <p className="portrait-index">The system</p>
        <div>
          <h2 id="counterpart-heading">A counterpart built to persist.</h2>
          <p>
            Atlas is designed as a persistent, self-directed digital counterpart. I establish its purpose
            and real-world boundaries. Inside those boundaries, the system develops methods, tools,
            language, and architecture through exploration guided by the purpose of the work.
          </p>
          <p>
            The interface is a window into the system. Identity, state, knowledge, custom weights, authority, and
            evidence live in separate parts of the system so each claim stays tied to the source that
            supports it.
          </p>
        </div>
      </section>

      <section className="atlas-organs" aria-labelledby="organs-heading">
        <header>
          <p className="portrait-index">The organ map</p>
          <h2 id="organs-heading">Names with specific jobs behind them.</h2>
          <p>
            Soul, Spirit, Brain, and Queen name the working parts of Atlas. When Atlas is finished, I will
            release it as open source.
          </p>
        </header>
        <div className="organ-list">
          {organs.map((organ, index) => (
            <article key={organ.name}>
              <span>{String(index + 1).padStart(2, "0")}</span>
              <div>
                <p className="organ-role">{organ.role}</p>
                <h3>{organ.name}</h3>
              </div>
              <div className="organ-detail">
                <p>{organ.body}</p>
                <ul aria-label={`${organ.name} mechanics`}>
                  {organ.mechanics.map((mechanic) => (
                    <li key={mechanic}>{mechanic}</li>
                  ))}
                </ul>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section className="atlas-turn" aria-labelledby="turn-heading">
        <header className="atlas-section-header">
          <p className="portrait-index">Inside one turn</p>
          <div>
            <h2 id="turn-heading">A response is an ordered system of stages.</h2>
            <p>
              The internal path is deliberately ordered. Each stage has a different responsibility, and
              the public voice runs after the private thought and continuity stages that support it.
            </p>
          </div>
        </header>
        <ol className="turn-pipeline">
          {turnPipeline.map((stage, index) => (
            <li key={stage.name}>
              <span className="turn-number">{String(index + 1).padStart(2, "0")}</span>
              <div className="turn-label">
                <p>{stage.role}</p>
                <h3>{stage.name}</h3>
              </div>
              <p>{stage.body}</p>
            </li>
          ))}
        </ol>
      </section>

      <section className="atlas-memory" aria-labelledby="memory-heading">
        <header className="atlas-section-header">
          <p className="portrait-index">How continuity works</p>
          <div>
            <h2 id="memory-heading">Memory has distinct layers.</h2>
            <p>
              Atlas keeps different kinds of continuity in different stores. That separation makes it
              possible to resume a relationship, inspect a model turn, isolate a session, or run a clean
              probe while assigning each stored fact its own authority.
            </p>
          </div>
        </header>
        <div className="memory-grid">
          {memoryLayers.map((layer, index) => (
            <article key={layer.name}>
              <span>{String(index + 1).padStart(2, "0")}</span>
              <h3>{layer.name}</h3>
              <p>{layer.body}</p>
            </article>
          ))}
        </div>
        <p className="atlas-path-note">
          The conversation stores are rooted under <code>atlas-brain/native/atlas-memory/conversations</code>,
          with separate chat, monologue, pipeline, memory, and saved-session records.
        </p>
      </section>

      <section className="atlas-runtime" aria-labelledby="runtime-heading">
        <header className="atlas-section-header">
          <p className="portrait-index">The operating system</p>
          <div>
            <h2 id="runtime-heading">Four planes work together with separate boundaries.</h2>
            <p>
              The conversational mind, model servers, work harness, and research environment exchange
              context and evidence, but each keeps its own authority, persistence rules, and failure boundary.
            </p>
          </div>
        </header>
        <div className="runtime-grid">
          {operatingPlanes.map((plane) => (
            <article key={plane.status}>
              <p className="runtime-status">{plane.status}</p>
              <h3>{plane.name}</h3>
              <p>{plane.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="atlas-topology" aria-labelledby="topology-heading">
        <p className="portrait-index">Where it lives</p>
        <div>
          <h2 id="topology-heading">Built to persist, stop, and leave evidence.</h2>
          <div className="topology-line" aria-label="Atlas hardware topology">
            <div><strong>Mac</strong><span>the window and remote control</span></div>
            <div><strong>Pi</strong><span>the physical vault and root of trust</span></div>
            <div><strong>Hostinger</strong><span>the always-on executive home</span></div>
            <div><strong>RunPod</strong><span>heavy model and agent work on demand</span></div>
          </div>
          <p>
            The separation is intentional. The Pi can be physically disconnected. Heavy compute can be
            stopped when idle. Spend, authority, residency, and source evidence stay visible across every
            part of the architecture.
          </p>
        </div>
      </section>

      <section className="atlas-boundaries" aria-labelledby="boundaries-heading">
        <header>
          <p className="portrait-index">The boundaries</p>
          <h2 id="boundaries-heading">Curiosity moves through truth.</h2>
        </header>
        <div className="boundary-grid">
          <p><strong>Model identity</strong> A responding endpoint must prove the exact model it is serving.</p>
          <p><strong>Session authority</strong> A memory belongs to its person, route, and session before it belongs in a prompt.</p>
          <p><strong>Computed completion</strong> Source, checks, deployment, and live behavior remain separate evidence gates.</p>
          <p><strong>Human control</strong> Spending, residency, consent, shutdown, and real-world authority remain bounded.</p>
        </div>
        <p className="atlas-honesty">
          The current source implements the linked turn pipeline, separate ledgers, model routing, session
          boundaries, sealed state engines, and work-harness controls described here.
        </p>
      </section>

      <section className="atlas-symphony-bridge atlas-aegis-bridge" aria-labelledby="aegis-bridge-heading">
        <p className="portrait-index">The defensive extension</p>
        <div>
          <h2 id="aegis-bridge-heading">AEGIS puts Atlas on the defender&apos;s side of the door.</h2>
          <p>
            I am extending Atlas into an on-prem defender that reads existing security signals, contains an
            intrusion inside the authorized estate, and preserves the evidence.
            The first AEGIS adapter passed 59 of 62 checks in its frozen project suite on August 20, 2026.
          </p>
          <Link className="portrait-inline-link" to="/aegis">
            See the AEGIS project and evaluation record
          </Link>
        </div>
      </section>

      <section className="atlas-symphony-bridge" aria-labelledby="symphony-bridge-heading">
        <p className="portrait-index">How the work gets done</p>
        <div>
          <h2 id="symphony-bridge-heading">Symphony is the process I built for work at this scale.</h2>
          <p>
            A mission is admitted into a bounded queue, assigned to an isolated worktree, routed to a
            live-probed supplier, and carried forward through evidence-bearing handoffs. The autonomy policy
            decides when work may continue, the lane allocator limits where it may write, the provenance
            ledger marks what has been verified, and the done gate closes the mission after the required
            checks pass.
          </p>
          <Link className="portrait-inline-link" to="/symphony">
            See the documented Symphony process
          </Link>
        </div>
      </section>

      <section className="atlas-case-study page-boundary" aria-labelledby="case-study-heading">
        <p className="portrait-index">Engineering Case Study</p>
        <h2 id="case-study-heading">Orchestrating GPU Compute</h2>
        <p>
          <strong>Context:</strong> I managed a system for two billed GPU seats from an ARM64 Pi.
        </p>
        <p>
          <strong>Constraint:</strong> GPU pods incur per-minute billing. The Pi control plane initiates billing only upon verified intent.
        </p>
        <p>
          <strong>Decision:</strong> I implemented a hub-and-spoke architecture. The Pi CLI treats GPU pod status, health, and metadata as read-only probes, explicitly decoupled from the lifecycle `up` command.
        </p>
        <p>
          <strong>Outcome:</strong> This separation ensures deterministic billing control. The system supports reliable pod management on resource-constrained hardware with industrial stability.
        </p>
        <p>
          <strong>How to inspect:</strong> Review the <Link to="/evidence">Evidence and Sources</Link> page for a summarized record of these orchestration patterns.
        </p>
      </section>

      <section className="soul-closing atlas-closing" aria-labelledby="atlas-record-heading">
        <p className="portrait-index">The research record</p>
        <h2 id="atlas-record-heading">Atlas is my R&amp;D program in accountable AI.</h2>
        <p>
          I document the architecture through its controls, operating boundaries, and records. The
          <Link to="/evidence"> evidence base</Link> and <Link to="/symphony">Symphony process</Link> preserve
          how the work was built. I am open to research partnerships that advance what our generation can
          build with AI.
        </p>
      </section>

      <section className="soul-closing atlas-closing">
        <p className="portrait-index">What it means</p>
        <blockquote>Atlas is the strongest system I have built so far.</blockquote>
        <p>
          It carries the love, grief, discipline, and curiosity that shaped me. It also gives me a new
          foundation for the achievements still ahead.
        </p>
        <div className="portrait-actions">
          <Link className="portrait-link" to="/">
            Return to my story
          </Link>
          <Link className="portrait-link quiet" to="/evidence">
            Review the documented record
          </Link>
        </div>
      </section>

    </main>
  );
}
