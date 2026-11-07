export const CHIPS = [
  "Multi-agent orchestration",
  "Human-in-the-loop gates",
  "Tool / function interfaces",
  "Policy, safety, source records",
  "Eval & incident recovery",
  "Python · TypeScript",
  "GitHub @aien-dev",
];

export const METRICS = [
  { title: "One thesis", body: "The operating system around AI determines the quality of the work." },
  { title: "16 months", body: "dated, SHA-deduped history · Apr 2025 - Aug 2026" },
  { title: "4,701", body: "internal workstation commits across 94 project trees" },
  { title: "Production desk", body: "Claude, Codex, and Grok as governed engines" },
];

export const STORY = [
  {
    era: "2025: ship software with models in the loop.",
    body: "Ledger, CRM, SDS parsing, meetings, DMAIC. I learned what “done” means when an LLM is helping write the system.",
  },
  {
    era: "Early 2026: ship operator products.",
    body: "MobPay, DefiantMob, BeltBrain, and DHG became live desks for access, money movement, ledgers, and planning.",
  },
  {
    era: "Mid 2026: the accidental agent platform.",
    body: "Inside MobPay I built MobDev (task → brief) and a multi-vendor panel arena. Every rule was still prose. The model still got a vote.",
  },
  {
    era: "Jul 2026 onward: build the operating desk.",
    body: "Atlas Harness (formerly codeharness) turns that prose into typed policy, clear work lanes, completion checks, source records, recovery, and evaluation. Atlas Symphony is the named process that runs that desk.",
  },
];

export const ARCH = [
  { title: "1. Intent", body: "A business job with standing authorization and a scoped goal." },
  { title: "2. Coordination", body: "Named roles, clear lanes, and a defined command path." },
  { title: "3. Tools", body: "Function interfaces connect subprocesses and APIs while credentials stay protected." },
  { title: "4. Review", body: "Completion criteria, human approval, escalation, and redaction." },
  { title: "5. Proof", body: "Source records, receipts, sealed evaluations, recovery, and cost awareness." },
];

export const CASES = [
  {
    title: "Atlas Symphony: the named process",
    meta: "First run 30 Jul 2026 · invented and first operated by Drake Stapleton",
    body: "Atlas is the orchestrator. Symphony is the process: exclusive lanes, a gatekeeper, cost-aware model routing, and a human who still owns GO. This is the public record: who started it, who sat in the first chairs, and the diagrams.",
    href: "/symphony",
    featured: true,
  },
  {
    title: "Atlas Harness: an operating desk for AI work",
    meta: "Jul 2026 → present · TypeScript / Python · formerly codeharness · 406 spine commits",
    body: "A policy and recovery layer for coding tools. The desk defines who may act, when work is complete, which lane owns it, and what evidence remains.",
    points: [
      "Coordination pattern: steward, heartbeat, workers, review team, and historian. The topology is enforced.",
      "Tool interfaces: Claude, Codex, and Grok as engines on existing subscriptions.",
      "Human oversight: typed completion gates keep final approval with the operator.",
    ],
  },
  {
    title: "MobDev + Panel Arena: the use case that forced the architecture",
    meta: "Inside MobPay / The Midnight Mob · 1,081 commits on the product tree",
    body: "A live operations desk grew an internal agent platform: task-to-brief, six-vendor panel review, a prompt compiler that emitted the operating contract. I ran thousands of agent sessions against that contract, then stopped treating the contract as prose.",
  },
];

export const SIDE_CASES = [
  {
    title: "DefiantMob",
    meta: "Production operator software · 250 commits",
    body: "Member ops, ledgers, training-desk automation, payouts. The substrate agent systems have to touch.",
  },
  {
    title: "BeltBrain",
    meta: "Local-first decision engine · 234 commits",
    body: "Planning, inventory intelligence, and execution depend on a strong system of record.",
  },
  {
    title: "DHG / HiveMind / Toolbox",
    meta: "Community platform + 804-commit toolkit",
    body: "Where I learned “hive” as an org pattern, later codified inside Atlas (notify ≠ command).",
  },
  {
    title: "2025 foundations",
    meta: "Financial Ledger, ParseSDS, CRM, meetings, DMAIC",
    body: "670 commits on the ledger alone. Correct systems before orchestrating models over them.",
  },
];

export const ROLE_MAP: [string, string, string][] = [
  ["Multi-agent patterns & orchestration", "Lanes, role topology, capped fan-out, hive operating model", "Ready to map onto LangGraph, AutoGen, or Strands"],
  ["Tool / function interfaces", "CLI and API adapters with protected credentials", "The same contract maps onto SAP, Salesforce, or Snowflake"],
  ["Memory / RAG design", "Source records, governed memory, channel firewalls, evidence ledgers", "Built around durable operational memory"],
  ["Human oversight", "Done-gates, interrupt, escalate, emergency court", "Need to express this in the firm’s HITL / SoD language"],
  ["Safety & compliance", "Stop-safe policy, redaction, authority boundaries, sealed exams", "PHI/PII, GDPR, SOC 2 as a named control pack with Legal/Risk"],
  ["Eval, observability, ops", "Sealed evals, receipts, recovery, cost-as-architecture", "Enterprise SLAs, tracing stack, FinOps on Bedrock/Azure"],
  ["Cloud agent platforms", "Multi-provider routing (Claude / Codex / Grok) under one policy", "Bedrock AgentCore and Azure AI Foundry are the next platform mappings"],
  ["Mentoring & exec narrative", "I can teach the pattern; this site is the narrative", "A cross-functional enterprise program is the next scale"],
];

export const TREES: [string, string, string, string][] = [
  ["Atlas Harness", "Operating desk: policy, lanes, reviews, evaluation", "406", "118k"],
  ["Midnight Mob / MobPay", "Production ops + the agent platform that forced Atlas", "1,081", "466k"],
  ["DefiantMob", "Second production domain, ledgers, automation", "250", "420k"],
  ["BeltBrain", "Decision engine / system of record", "234", "141k"],
  ["DHG Toolbox + platform", "Long-running product + hive as org language", "1,003", "267k"],
  ["Financial Ledger + 2025 line", "Correctness before agents", "670+", "198k+"],
];

export const VOLUME = {
  months: ["Apr 25", "May 25", "Jun 25", "Jul 25", "Aug 25", "Sep 25", "Oct 25", "Nov 25", "Dec 25", "Jan 26", "Mar 26", "Apr 26", "May 26", "Jun 26", "Jul 26", "Aug 26"],
  added: [74806, 177760, 79505, 0, 32346, 53655, 68205, 51876, 4330, 13749, 2161, 130, 35445, 369000, 1550049, 364442],
};
