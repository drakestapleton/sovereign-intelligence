import { FirstRunDiagram } from "../components/FirstRunDiagram";
import {
  ATLAS_OPENING,
  FIRST_LANES,
  FIRST_OPERATORS,
  INVOCATION,
  LANE_NICKNAMES,
} from "../data/operators";
import { usePageMeta } from "../lib/usePageMeta";

const MONTHS = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

function publicDate(value: string) {
  const [year, month, day] = value.split("-").map(Number);
  return `${day} ${MONTHS[month - 1]} ${year}`;
}

export function FirstRunPage() {
  usePageMeta("/symphony/first");

  return (
    <main className="wrap">
      <p className="kicker">First named instance · Sovereign Forge live-ops</p>
      <h1>The first documented run</h1>
      <p className="lede">
        I wrote the invocation, named the orchestrator Atlas, and authorized the run. Drake Stapleton is the
        inventor; the other entries identify runtimes, reviewers, and task lanes.
      </p>

      <h2 className="sec">The public invocation</h2>
      <blockquote className="invoke">
        {INVOCATION}
        <cite>Drake Stapleton · 30 July 2026 · prior turn: “What’s left in our development plan?”</cite>
      </blockquote>
      <p className="law">Atlas opening in role: “{ATLAS_OPENING}”</p>

      <h2 className="sec">The first diagram</h2>
      <div className="card diagram-card">
        <FirstRunDiagram />
      </div>

      <h2 className="sec">Roster</h2>
      <div className="card roster-table-card table-scroll">
        <table>
          <thead>
            <tr>
              <th>Started</th>
              <th>Name</th>
              <th>Role</th>
              <th>Kind</th>
            </tr>
          </thead>
          <tbody>
            {FIRST_OPERATORS.map((o) => (
              <tr key={o.id}>
                <td>{publicDate(o.started)}</td>
                <td>{o.name}</td>
                <td>{o.role}</td>
                <td>{o.kind}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {FIRST_OPERATORS.map((o) => (
        <article className="case" key={o.id}>
          <p className="kind">{o.kind}</p>
          <h3>{o.name}</h3>
          <p className="meta">
            {o.role} · {publicDate(o.started)}
          </p>
          <p>{o.note}</p>
        </article>
      ))}

      <h2 className="sec">First lanes</h2>
      <div className="grid2">
        {FIRST_LANES.map((l) => (
          <div className="card" key={l.name}>
            <h3>{l.name}</h3>
            <p>{l.job}</p>
          </div>
        ))}
      </div>
      <p className="note">
        These nicknames identified agent lanes in the first run:{" "}
        {LANE_NICKNAMES.join(" · ")}.
      </p>

      <h2 className="sec">Operating record</h2>
      <div className="card current-scope-card">
        <p>
          Symphony began in my operating environment. Grok Hive and Boston roles grew there. Claude
          cataloged the first run, Grok observed it, and I am the inventor and operator.
        </p>
      </div>
    </main>
  );
}
