export const AUDIT_SCOPE = [
  { value: "33", label: "project records in the handoff" },
  { value: "168", label: "evidence claims cataloged" },
  { value: "88", label: "dated timeline events" },
  { value: "180", label: "merged pull requests retrieved" },
];

export const EVIDENCE_CLASSES = [
  {
    title: "Connected engineering record",
    status: "Verified in the audit",
    body: "The retrieved MobHub, Defiant Mob, and Atlas records include source, automated checks, commits, pull requests, merges, migrations, deployments, health checks, release repairs, restorations, and recoveries.",
  },
  {
    title: "Reconstructed ChatGPT history",
    status: "Historical reconstruction",
    body: "Sixteen historical notes preserve the work, dates, and themes in the reconstructed record.",
  },
  {
    title: "Direct Atlas conversations",
    status: "Direct Atlas record",
    body: "Seven direct Atlas sessions contain 270 messages and 135 paired exchanges. These sessions document the Atlas record.",
  },
  {
    title: "Official ChatGPT export",
    status: "Next source",
    body: "The original ChatGPT export will add lifetime conversation, message, token, model, branch, and monthly activity totals.",
  },
];

export const VERIFIED_FINDINGS = [
  {
    title: "MobHub and Defiant Mob reached production",
    body: "The record covers source, testing, deployment, restoration, and repair. The retrieved Defiant history includes 94 merged pull requests. MobHub includes 24 and a verified Raspberry Pi auto-deployment path.",
  },
  {
    title: "Atlas developed into a sustained engineering program",
    body: "The audit found 64 Atlas Harness pull-request records, including 62 merges. The retrieved work covers durable jobs, provider adapters, an operator board, evidence controls, an Obsidian knowledge base, an encrypted Context Vault, recovery source, governance, and personal-model lifecycle controls.",
  },
  {
    title: "The personal-model experiment reached private inference",
    body: "A Devstral adapter trained on an H100 using 143 samples. A later vLLM service exposed devstral-personal, and the model-list request, Atlas probe, and chat smoke test succeeded.",
  },
  {
    title: "Community leadership produced documented results",
    body: "The Nemesis record documents direct outreach, member movement during a transition, a 46-member roster with 39 active members, two officer-development cycles, and a planned handoff to new leaders.",
  },
  {
    title: "Human-resources work produced operating tools",
    body: "The evidence includes credentialing workbooks, an education-repayment agreement, performance-review redesign, separation documentation, leave and benefit workflows, recognition systems, and manager tools. The audit distinguishes AI-assisted drafting from my decisions and implementation.",
  },
  {
    title: "GPU compute orchestration follows probe-first principles",
    body: "Atlas manages two billed GPU seats on ARM64 hardware through a hub-and-spoke control plane. The system treats all status, health, and metadata requests as side-effect-free probes, ensuring billing is only initiated by verified, intentional 'up' commands.",
  },
];

export const NEXT_SOURCES = [
  "The original ChatGPT data export will add an account-wide history.",
  "Privacy-controlled Discord and Torn exports will support a broader community record.",
  "Full repositories, release artifacts, host logs, model hashes, migration ledgers, and restore tests will deepen the lifecycle record.",
  "Future Atlas milestones include a final merged-model export, cross-session memory, voice, persistent world interaction, physical embodiment, and physical shutdown verification.",
  "Atlas language ties every technical claim to the mechanism and source that supports it.",
];
