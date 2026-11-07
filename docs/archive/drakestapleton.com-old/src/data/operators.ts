export type OperatorKind = "human" | "runtime" | "reviewer" | "lane" | "desk";

export type OperatorRecord = {
  id: string;
  kind: OperatorKind;
  name: string;
  role: string;
  started: string;
  note: string;
};

/** Exact public roster for Drake's operating environment. */
export const FIRST_OPERATORS: OperatorRecord[] = [
  {
    id: "drake",
    kind: "human",
    name: "Drake Stapleton",
    role: "Inventor and first operator",
    started: "2026-07-30",
    note: "Named Atlas, wrote the first invocation, and retained final approval authority.",
  },
  {
    id: "instance",
    kind: "desk",
    name: "Sovereign Forge live-ops",
    role: "First named Symphony instance",
    started: "2026-07-30",
    note: "The first documented use of the gated multi-lane process, within Atlas Harness and Sovereign Forge.",
  },
  {
    id: "codex",
    kind: "runtime",
    name: "Codex · ChatGPT desktop",
    role: "First Atlas runtime",
    started: "2026-07-30",
    note: "Thread 019fb4ec… opened at 16:27Z. Atlas began by dividing the task according to risk and cost.",
  },
  {
    id: "claude",
    kind: "reviewer",
    name: "Claude",
    role: "First independent catalog",
    started: "2026-07-30",
    note: "Produced a behavior catalog and harness requirements from the live run as an independent reviewer.",
  },
  {
    id: "grok",
    kind: "reviewer",
    name: "Grok",
    role: "First live observer",
    started: "2026-07-30",
    note: "Produced a 16:40Z observation record covering technique, identity, and the thread map. A later Grok Hive implementation reused the process.",
  },
];

export const FIRST_LANES = [
  { name: "Gatekeeper", job: "Independent review of security and lane boundaries." },
  { name: "Recovery", job: "Storage recovery and compromised-credential work." },
  { name: "Publisher", job: "Documented deployment within the approved boundary." },
  { name: "Backup / DR", job: "Isolated backup audit and non-destructive recovery testing." },
  { name: "Capability / artifacts", job: "Tool selection and artifact packaging." },
];

export const LANE_NICKNAMES = [
  "Popper",
  "Lagrange",
  "Avicenna",
  "Plato",
  "Jason",
  "Hypatia",
];

export const INVOCATION = `Act as the orchestrator of models. Choose the GPT model and thinking level each task requires. Save time and tokens by matching capability to the work. Continue through completion. Use subagents in multiple chats that can work at the same time. Start an independent gatekeeper to preserve the lane boundaries. Act as the executive director and conductor. Your name is Atlas. Welcome to Earth. Please proceed with our Symphony. I'll see you on the other side, brother.`;

export const ATLAS_OPENING =
  "Atlas online. I'm splitting the Symphony by risk and cost…";

export const CITATION = {
  title: "Atlas Symphony",
  inventor: "Drake Stapleton",
  firstRun: "2026-07-30",
  firstInstance: "Sovereign Forge live-ops",
  url: "https://www.drakestapleton.com/symphony/",
};

export const VERSIONS = [
  {
    id: "1.0",
    date: "30 Jul 2026",
    name: "Star",
    blurb: "Atlas coordinated isolated first-level lanes for gatekeeping, recovery, publishing, backup, and capability work.",
  },
  {
    id: "2.0",
    date: "30 Jul 2026",
    name: "Operating desk",
    blurb: "Added a binding operating contract and delivery ledger so source, merge, deployment, and live proof remained separate stages.",
  },
  {
    id: "3.0 / 3.1",
    date: "late Jul 2026",
    name: "Two-tier process",
    blurb: "Introduced lead and leaf roles, cost-aware model selection, and strict isolation between lanes.",
  },
  {
    id: "4.0",
    date: "Aug 2026",
    name: "Hive face",
    blurb: "Formalized four lead roles, limited each node to three children, and kept lateral status signals separate from command authority.",
  },
  {
    id: "Current L-tier",
    date: "13 Aug 2026",
    name: "Conductor, stewards, and focused cells",
    blurb: "L1 coordinates the assignment. Independent L2 stewards own implementation, review, evidence, and operations. L3 cells perform focused edits, tests, provider checks, and receipts. Independent reviewers clear each implementation.",
  },
];
