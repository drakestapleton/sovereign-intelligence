import { Link } from "react-router-dom";
import { FirstRunDiagram } from "../components/FirstRunDiagram";
import { CITATION, FIRST_OPERATORS, VERSIONS } from "../data/operators";
import { usePageMeta } from "../lib/usePageMeta";


export function SymphonyPage() {
  usePageMeta("/symphony");

  return (
    <main className="wrap">
      <p className="kicker">Public record · first run 30 July 2026</p>
      <h1>
        Atlas <em>Symphony</em>
      </h1>
      <p className="lede">
        Atlas Symphony is a gated process for coordinating multiple AI agents on one task. I designed,
        named, and first used it on 30 July 2026.
      </p>
      <p className="law">
        A Symphony divides work into isolated lanes, assigns an independent gatekeeper, selects models by
        task and cost, and reserves final approval for the human operator. It is the working process that
        connects the people, models, tools, reviews, and evidence.
      </p>

      <div className="metrics">
        <div className="metric">
          <b>Drake Stapleton</b>
          <span>Designer, first operator, and final approver.</span>
        </div>
        <div className="metric">
          <b>30 Jul 2026</b>
          <span>Date of the first documented run, for Sovereign Forge live operations.</span>
        </div>
        <div className="metric">
          <b>Versioned process</b>
          <span>The initial star topology later became a two-tier control structure.</span>
        </div>
        <div className="metric">
          <b>Current operating record</b>
          <span>My runtimes and reviewers form the operating record.</span>
        </div>
      </div>

      <h2 className="sec">Who started using it</h2>
      <div className="card roster">
        {FIRST_OPERATORS.map((o) => (
          <div className="roster-row" key={o.id}>
            <div>
              <div className="kind">{o.kind}</div>
              <div>{o.started}</div>
            </div>
            <div>
              <strong>{o.name}</strong>
              <div className="meta">{o.role}</div>
              <p>{o.note}</p>
            </div>
          </div>
        ))}
      </div>
      <p className="note">
        Popper, Lagrange, Avicenna, Plato, Jason, and Hypatia identified agent lanes in the first run. The
        complete roster and original invocation are on the{" "}
        <Link to="/symphony/first">first run</Link>.
      </p>

      <h2 className="sec">First run</h2>
      <div className="card diagram-card">
        <FirstRunDiagram />
        <p className="note">
          Solid lines show command relationships. Dashed lines show independent review. Codex hosted the
          first runtime; Claude cataloged the behavior; Grok observed the run.
        </p>
      </div>

      <h2 className="sec">Diagrams</h2>
      <div className="grid3">
        <Link className="card" to="/symphony/first">
          <h3>First Symphony</h3>
          <p className="meta">React diagram · this project</p>
          <p>The original invocation, participating runtimes, reviewer roles, and five work lanes.</p>
        </Link>
        <Link className="card" to="/symphony/workflow">
          <h3>Command tree + cycle</h3>
          <p className="meta">Illustrated process map</p>
          <p>The command structure and launch sequence used during a Symphony cycle.</p>
        </Link>
        <Link className="card" to="/symphony/map">
          <h3>Bird’s-eye</h3>
          <p className="meta">Jun 18 - Aug 13 2026</p>
          <p>Six concurrent Atlas workstreams shown on a shared timeline.</p>
        </Link>
      </div>

      <h2 className="sec">Versions of the process</h2>
      <div className="grid2">
        {VERSIONS.map((v) => (
          <div className="card" key={v.id}>
            <p className="meta">
              {v.id} · {v.date}
            </p>
            <h3>{v.name}</h3>
            <p>{v.blurb}</p>
          </div>
        ))}
      </div>

      <h2 className="sec">Cite this</h2>
      <div className="citebox">
        Stapleton, Drake. <i>Atlas Symphony</i>. First run 30 July 2026 (Sovereign Forge live-ops).{" "}
        <a href={CITATION.url}>{CITATION.url}</a>
      </div>
    </main>
  );
}
