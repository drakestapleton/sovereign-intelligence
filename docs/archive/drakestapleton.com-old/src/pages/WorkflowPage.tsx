import { CommandTree } from "../diagrams/CommandTree";
import { CyclePhases } from "../diagrams/CyclePhases";
import { usePageMeta } from "../lib/usePageMeta";

export function WorkflowPage() {
  usePageMeta("/symphony/workflow");

  return (
    <main className="wrap wide workflow-page">
      <p className="kicker">Diagram · command tree · cycle phases</p>
      <h1>Workflow</h1>
      <p className="lede">
        The current Boston Atlas flow uses three explicit levels. L1 coordinates the full assignment. L2
        separates architecture, independent review, evidence, and operations. L3 handles focused edits,
        tests, provider checks, teardown verification, and receipts. Results return through the same chain,
        and independent reviewers approve implementation.
      </p>
      <h2 className="sec">Who talks to whom</h2>
      <div className="card">
        <CommandTree />
      </div>
      <h2 className="sec">Cycle sequence</h2>
      <div className="card">
        <CyclePhases />
      </div>
    </main>
  );
}
