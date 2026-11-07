import { Link } from "react-router-dom";
import { PageIntro } from "../components/PagePrimitives";
import { usePageMeta } from "../lib/usePageMeta";

const responsePath = [
  {
    step: "01",
    label: "Observe",
    title: "Watch the house",
    body: "Read the IDS, DNS, identity, endpoint, and firewall signals already present in the security path.",
  },
  {
    step: "02",
    label: "Recognize",
    title: "Name the intrusion",
    body: "Correlate attacker behavior across sensors, separate routine noise from a break-in, and state the risk in plain language.",
  },
  {
    step: "03",
    label: "Contain",
    title: "End the session",
    body: "Choose one tested action inside the authorized estate: cut the session, isolate the host, block the path, or revoke the token.",
  },
  {
    step: "04",
    label: "Preserve",
    title: "Keep the trail",
    body: "Record the signal, decision, action, time, and result for the incident team.",
  },
];

const evaluationSlices = [
  { label: "Tool use", score: "45/45", rate: "100%" },
  { label: "Coding", score: "8/10", rate: "80%" },
  { label: "Science", score: "3/4", rate: "75%" },
  { label: "Cyber", score: "3/3", rate: "100%" },
];

const authorityBoundaries = [
  {
    title: "Authorized estate",
    body: "Every automated action targets systems, devices, accounts, and sessions under the operator's authority.",
  },
  {
    title: "Tested actions",
    body: "Containment relies on pre-cleared, bounded operations: revoke token, isolate host, block IP, terminate session.",
  },
  {
    title: "Human escalation",
    body: "Novel attack patterns, uncertain attribution, or production-impacting cuts escalate to human incident responders.",
  },
  {
    title: "Forensic preservation",
    body: "Every observation, decision, and intervention generates a timestamped, signed receipt for forensic review.",
  },
];

export function AegisPage() {
  usePageMeta("/aegis");

  return (
    <main className="wrap portrait-wrap aegis-page">
      <PageIntro
        eyebrow="AEGIS / A defensive extension of Atlas"
        title="The defender on your side of the door."
        className="aegis-hero"
      >
        <p>
          I am extending Atlas into AEGIS, an on-prem defensive project that reads existing security
          signals, recognizes an intrusion, and contains it inside the authorized estate.
        </p>
      </PageIntro>

      <div className="aegis-scope-strip" aria-label="AEGIS project scope">
        <span>Atlas extension</span>
        <span>Authorized networks</span>
        <span>On-prem deployment</span>
        <span>Evidence-bearing response</span>
      </div>

      <blockquote className="aegis-tagline">
        “Authorized perimeter defense:
        <br />
        <span>detect intrusion, contain session, preserve evidence.</span>
        <br />
        Decisive policy containment inside the wire.”
      </blockquote>

      <section className="aegis-house" aria-labelledby="aegis-house-heading">
        <p className="portrait-index">The architecture</p>
        <div>
          <h2 id="aegis-house-heading">The network is the house.</h2>
          <p>
            Data, payroll, source code, models, and trade secrets live behind the same boundary. AEGIS
            treats that boundary like a house: watch the door, recognize unauthorized access, isolate sessions, and
            preserve forensic trails for incident teams.
          </p>
          <p className="aegis-law">
            Early internal lore summarized the operating posture as &ldquo;You touchy, I knock you out.&rdquo; In production, that
            means deterministic policy containment: verified allow-lists, session revocation, human escalation gates, and forensic audit preservation.
          </p>
        </div>
      </section>

      <section className="aegis-response" aria-labelledby="aegis-response-heading">
        <header className="aegis-section-lead">
          <p className="portrait-index">The response path</p>
          <div>
            <h2 id="aegis-response-heading">See the play. Close the path. Keep the proof.</h2>
            <p>
              AEGIS sits above existing sensors and controls. The sequence stays short, inspectable, and
              bounded to the operator&apos;s authority.
            </p>
          </div>
        </header>
        <ol className="aegis-flow" aria-label="AEGIS response sequence">
          {responsePath.map((stage) => (
            <li key={stage.step}>
              <span>{stage.step}</span>
              <p>{stage.label}</p>
              <h3>{stage.title}</h3>
              <div>{stage.body}</div>
            </li>
          ))}
        </ol>
      </section>

      <section className="aegis-knockout" aria-labelledby="aegis-knockout-heading">
        <p className="portrait-index">One decisive action</p>
        <h2 id="aegis-knockout-heading">Cut the session. Isolate the host. Close the door. Keep the evidence.</h2>
        <p>
          That is the knockout: the intruder loses access to this house, while the operator retains the
          systems, the authority, and the trail.
        </p>
        <div className="aegis-actions" aria-label="AEGIS containment actions">
          <span>Terminate session</span>
          <span>Isolate host</span>
          <span>Block path</span>
          <span>Revoke token</span>
          <span>Preserve trail</span>
        </div>
      </section>

      <section className="aegis-evaluation" aria-labelledby="aegis-evaluation-heading">
        <div className="aegis-evaluation-intro">
          <div>
            <p className="portrait-index">Training evidence / August 20, 2026</p>
            <h2 id="aegis-evaluation-heading">The first AEGIS adapter has a real receipt.</h2>
          </div>
          <div className="aegis-total">
            <strong>59/62</strong>
            <span>Frozen suite result</span>
          </div>
        </div>

        <p className="aegis-evaluation-copy">
          A Grok-led training session continued the Devstral atlas-tools lineage into a rank-16 AEGIS LoRA.
          The run used one epoch at a 5e-6 learning rate on the Devstral-Small-2-24B-Instruct-abliterated
          base, then evaluated the vaulted adapter against the project&apos;s frozen 62-case suite.
        </p>

        <div className="aegis-eval-grid" aria-label="AEGIS frozen evaluation results">
          {evaluationSlices.map((slice) => (
            <article key={slice.label}>
              <p>{slice.label}</p>
              <strong>{slice.score}</strong>
              <span>{slice.rate}</span>
            </article>
          ))}
        </div>

        <div className="aegis-eval-boundary">
          <div>
            <p className="aegis-eval-label">The three visible misses</p>
            <ul>
              <li>JSONL parsing produced an indentation error.</li>
              <li>POSIX path joining missed a slash-normalization case.</li>
              <li>The RC science answer missed the required target.</li>
            </ul>
          </div>
          <div>
            <p className="aegis-eval-label">Current artifact state</p>
            <p>
              The unmerged LoRA adapter is sealed in the Pi vault and recorded in a private model repository
              at 23:00 UTC.
            </p>
          </div>
        </div>
      </section>

      <section className="aegis-boundary" id="boundary" aria-labelledby="aegis-boundary-heading">
        <header className="aegis-section-lead">
          <p className="portrait-index">The authority line</p>
          <div>
            <h2 id="aegis-boundary-heading">The fight ends at the door.</h2>
            <p>
              AEGIS studies attacker behavior so it can close the path inside the authorized estate. The
              operator owns the policy, the automated allow-list, and every escalation decision.
            </p>
          </div>
        </header>
        <div className="aegis-boundary-grid">
          {authorityBoundaries.map((boundary) => (
            <article className="aegis-boundary-card" key={boundary.title}>
              <h3>{boundary.title}</h3>
              <p>{boundary.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="aegis-current" aria-labelledby="aegis-current-heading">
        <p className="portrait-index">Current state</p>
        <h2 id="aegis-current-heading">A trained adapter and a documented evaluation.</h2>
        <p>
          The August 20 adapter and its 59/62 frozen-suite result establish the first AEGIS model milestone.
        </p>
        <p style={{ marginTop: "12px", fontSize: "0.9rem" }}>
          <Link to="/evidence#claim-aegis-adapter-eval" style={{ color: "var(--red)", textDecoration: "underline" }}>
            Inspect AEGIS frozen evaluation record in the Evidence Hub
          </Link>
        </p>
      </section>

      <section className="soul-closing aegis-closing">
        <p className="portrait-index">Walk the journey</p>
        <blockquote>
          Put a defender on your side of the door. If they come in, put them out on your wire and keep the
          house.
        </blockquote>
        <div className="portrait-actions">
          <Link className="portrait-link" to="/evidence">
            Inspect Evidence Hub
          </Link>
          <Link className="portrait-link quiet" to="/interest">
            Start a conversation
          </Link>
          <Link className="portrait-link quiet" to="/atlas">
            Return to Atlas
          </Link>
        </div>
      </section>
    </main>
  );
}
