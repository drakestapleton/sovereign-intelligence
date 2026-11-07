export type PracticeTimelinePoint = {
  week: string;
  linesAdded: number;
  commits: number;
  conversationTokens: number;
};

export const PRACTICE_SNAPSHOT = {
  iso: "2026-08-13",
  display: "13 August 2026",
  gitCoverage: "14 April 2025 to 13 August 2026",
  denseConversationCoverage: "22 June to 13 August 2026",
};

export const PRACTICE_METRICS = [
  {
    value: "4.97M",
    label: "source lines present",
    detail: "First-party source I wrote, directed, reviewed, or maintain across six curated Mac roots.",
  },
  {
    value: "2.88M",
    label: "source lines added",
    detail: "My weekly Git history across 94 SHA-deduped project trees.",
  },
  {
    value: "4,701",
    label: "internal workstation commits",
    detail: "Distinct commit SHAs across 94 project trees on local workstations and DGX clusters, now distilling into public open source.",
  },
  {
    value: "3,622",
    label: "retained AI sessions",
    detail: "Sessions from the Claude, Codex, Grok, ChatGPT, and Cursor desks I used.",
  },
  {
    value: "122,304",
    label: "retained messages",
    detail: "27,569 messages I wrote and 94,735 assistant messages I received.",
  },
  {
    value: "32.1M",
    label: "retained conversation tokens",
    detail: "Human and assistant text from the work I prompted, directed, and reviewed.",
  },
];

export const PRACTICE_HOME_METRICS = [
  { value: "4,701", label: "internal workstation commits" },
  { value: "4.97M", label: "source lines across 94 trees" },
  { value: "3,622", label: "retained AI sessions" },
  { value: "79.9M", label: "documented AI I/O tokens" },
];

export const TOKEN_LAYERS = [
  {
    value: "32.1M",
    label: "retained conversation text",
    body: "I wrote prompts, supplied briefs and context, reviewed answers, and preserved useful human and assistant text across Claude, Codex, Grok, ChatGPT, and Cursor.",
  },
  {
    value: "47.8M",
    label: "MobHub product I/O",
    body: "I orchestrated 4,895 MobDev, Panel Arena, and member-facing AI calls during July 2026, from idea intake through debate and returned product output.",
  },
  {
    value: "76.6B",
    label: "coding-agent processing",
    body: "I ran coding sessions that repeatedly loaded source, tools, cache, and parallel work. This total describes the computational volume behind the work I directed.",
  },
];

export const AI_STORY = [
  {
    date: "February 2023",
    title: "I began by asking GPT about consciousness.",
    body: "I wanted to understand what consciousness is, whether another kind of system could hold it, and what memory or continuity might mean for identity. I kept turning the question until I could see the assumptions inside it.",
  },
  {
    date: "2023",
    title: "I wrote my way across the universe.",
    body: "I wrote questions, scenarios, and numerical thought experiments about quantum communication, the Sun and Earth, black holes, gravitational waves, Einstein's equations, simulated realities, uploaded consciousness, identity, memory, and a universe able to model itself.",
  },
  {
    date: "2023 and 2024",
    title: "I applied the same questioning to Six Sigma.",
    body: "Beginning with my Black Belt work in 2023, I used AI to pressure-test problem statements, organize measures, compare causes, and turn DMAIC, kaizen, tier reviews, process maps, root-cause analysis, and standard work into operating plans people could carry.",
  },
  {
    date: "March 2024",
    title: "I brought that practice onto the manufacturing floor.",
    body: "At 3M, I led work across safety, quality, service, and cost. I mapped workflows, balanced lines, developed standard work, ran cross-functional process improvements with operators, and produced $1 million in cost savings through efficiency improvements.",
  },
  {
    date: "April 2025 to May 2026",
    title: "I used Windsurf to turn direction into software.",
    body: "I wrote the operating rules, described the product behavior, paired with Cascade through implementation, reviewed what it changed, and carried the work into project trees that could run. Windsurf taught me how to orchestrate a coding model beyond asking it for an answer.",
  },
  {
    date: "June 2026",
    title: "I built a working desk across several models.",
    body: "I used Claude Code for deep implementation, Codex for repository execution and verification, and Grok Build for rapid operations and recovery. I assigned work to each, compared the results, reviewed failures, and kept source control, testing, deployment, and live proof as separate gates.",
  },
  {
    date: "July 2026",
    title: "I orchestrated a room where models challenged each other.",
    body: "I built MobDev to turn community ideas into build briefs. I orchestrated Panel Arena across six model families, asked them to challenge each proposal, resolve disagreements, and return a verdict that could revise the brief before implementation.",
  },
  {
    date: "July and August 2026",
    title: "I trained, served, and tested models myself.",
    body: "I prepared training data, directed adapter runs, rented GPU capacity, brought inference endpoints online, designed evaluations, compared outputs, and preserved the receipts that showed where each run succeeded or failed.",
  },
  {
    date: "The work now",
    title: "I am building Atlas from all of it.",
    body: "I am combining chemistry, manufacturing discipline, community leadership, software, model operations, grief, memory, and my questions about consciousness into one long exploration. I write the questions, set the boundaries, direct the work, test the result, and decide what deserves to continue.",
  },
];

export const AI_WORKSPACES = [
  {
    name: "ChatGPT",
    measure: "Earliest dated record: 5 Feb 2023",
    body: "I used ChatGPT to explore consciousness, cosmology, simulation, identity, writing, continuous improvement, and my earliest software ideas.",
  },
  {
    name: "Windsurf / Cascade",
    measure: "40 receipts / 32 pairing records",
    body: "I wrote rules, described product behavior, paired with Cascade through implementation, and reviewed the project trees it helped me build from April 2025 through May 2026.",
  },
  {
    name: "Codex",
    measure: "1,380 retained threads",
    body: "I use Codex to execute repository work, coordinate parallel tasks, review changes, verify behavior, and carry delivery across desktop, CLI, Boston, and Raspberry Pi systems.",
  },
  {
    name: "Claude Code",
    measure: "760 retained sessions",
    body: "I used Claude Code for architecture, deep repository work, implementation, and long coding loops where a system needed sustained attention.",
  },
  {
    name: "Grok Build",
    measure: "1,461 retained sessions",
    body: "I use Grok Build for hands-on model operations, infrastructure recovery, testing, and rapid build loops across the Mac, Boston host, and Raspberry Pi.",
  },
  {
    name: "OpenRouter in MobHub",
    measure: "4,895 product calls",
    body: "I orchestrated MobDev, Panel Arena, and member-facing AI features across several model providers, producing 47.8 million input and output tokens during July 2026.",
  },
];

export const WORKING_STACK = [
  {
    eyebrow: "Daily surface",
    title: "Ghostty, Chrome, and terminal-first work",
    body: "I use Ghostty for SSH, Git, coding models, model serving, and training logs. I use Chrome for product testing, local previews, provider consoles, and research.",
    tools: ["Ghostty", "Chrome", "Git", "GitHub CLI", "SSH"],
    proof: "I move through this surface every day across Atlas, RunPod, and the portfolio.",
  },
  {
    eyebrow: "Languages",
    title: "TypeScript and Python at the center",
    body: "I use TypeScript for product interfaces, operator desks, policies, and APIs. I use Python for research, parsing, evaluation, training, automation, and small services. SQL, JavaScript, HTML, CSS, and shell complete my working set.",
    tools: ["TypeScript", "Python", "SQL", "JavaScript", "HTML/CSS", "Shell"],
    proof: "I use these languages across Atlas Harness, MobPay, MobHub, BeltBrain, research systems, and this site.",
  },
  {
    eyebrow: "Product software",
    title: "React, Vite, Next.js, Node.js, and Postgres",
    body: "I build responsive product surfaces, server routes, data models, background jobs, and permission-aware workflows. I use Clerk for user authentication and Supabase for Postgres, authentication, storage, and realtime product behavior.",
    tools: ["React", "Vite", "Next.js", "Node.js", "Postgres", "Clerk", "Supabase"],
    proof: "I use this stack for community operations, planning, ledgers, research, and AI-assisted workflows.",
  },
  {
    eyebrow: "Delivery",
    title: "Git history is part of the product",
    body: "I use branches, isolated worktrees, pull requests, reviews, migrations, deployment receipts, and live checks to carry a change from idea to operating software.",
    tools: ["Git", "GitHub", "Forgejo", "Docker", "Linux", "CI"],
    proof: "I have preserved 4,701 unique commits across 94 project trees.",
  },
  {
    eyebrow: "Models and compute",
    title: "Training, serving, and evaluation",
    body: "I work across hosted models, local models, adapters, quantization, GPU services, sealed evaluations, and multi-provider review. RunPod supplies training and inference compute while Atlas supplies the operating discipline.",
    tools: ["RunPod", "Hugging Face", "PEFT", "vLLM", "OpenRouter", "Ollama"],
    proof: "I have trained adapters, operated private inference and live model services, run evaluations, and recovered failed systems.",
  },
  {
    eyebrow: "Interfaces",
    title: "Discord, Raspberry Pi, and real communities",
    body: "I use Discord as a permanent front door for Atlas and community systems. I connect Raspberry Pi services, APIs, databases, and browser products so people can use the work directly.",
    tools: ["Discord APIs", "Raspberry Pi", "REST APIs", "Webhooks", "Browser UI"],
    proof: "I use these interfaces across Atlas, Guild operations, MobHub, MobPay, and community automation.",
  },
];

export const PRACTICE_METHODS = [
  {
    title: "Source lines present",
    body: "A 13 August census counted first-party source in six curated Mac roots.",
  },
  {
    title: "Lines added and commits",
    body: "The weekly Git timeline covers 94 own trees, deduplicates commit SHAs, and sums text additions from 14 April 2025. The final week covers 10 through 13 August.",
  },
  {
    title: "Retained conversation text",
    body: "The 32.1 million measure estimates unique human and assistant message text at four characters per token.",
  },
  {
    title: "Product AI I/O",
    body: "MobHub recorded 47.8 million input and output tokens across 4,895 product calls. Adding this measured surface to retained conversation text yields 79.9 million documented AI I/O tokens.",
  },
  {
    title: "Coding-agent processing",
    body: "Native coding-agent usage totals 76.6 billion tokens. Context replay, cache reads, tools, and subagents dominate that measure, so the site presents it as processing volume rather than conversation.",
  },
  {
    title: "Early-story evidence",
    body: "Sixteen reconstructed notes preserve the dated titles and themes. My resume and work record establish the Six Sigma and manufacturing chronology.",
  },
  {
    title: "Windsurf evidence",
    body: "Forty paid receipts, 32 pairing records, project trees, and a rules file establish Windsurf use from April 2025 through May 2026.",
  },
  {
    title: "Source archive",
    body: "The archive contains detailed Claude, Codex, and Grok history plus 16 reconstructed ChatGPT threads.",
  },
];

export const PRACTICE_TIMELINE: readonly PracticeTimelinePoint[] = [
  { week: "2025-04-14", linesAdded: 6572, commits: 3, conversationTokens: 0 },
  { week: "2025-04-21", linesAdded: 19387, commits: 119, conversationTokens: 0 },
  { week: "2025-04-28", linesAdded: 123323, commits: 549, conversationTokens: 0 },
  { week: "2025-05-05", linesAdded: 1081, commits: 2, conversationTokens: 0 },
  { week: "2025-05-12", linesAdded: 88721, commits: 2, conversationTokens: 0 },
  { week: "2025-05-19", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-05-26", linesAdded: 13845, commits: 11, conversationTokens: 0 },
  { week: "2025-06-02", linesAdded: 24267, commits: 12, conversationTokens: 0 },
  { week: "2025-06-09", linesAdded: 43286, commits: 14, conversationTokens: 0 },
  { week: "2025-06-16", linesAdded: 11589, commits: 2, conversationTokens: 0 },
  { week: "2025-06-23", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-06-30", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-07-07", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-07-14", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-07-21", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-07-28", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-08-04", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-08-11", linesAdded: 4021, commits: 34, conversationTokens: 0 },
  { week: "2025-08-18", linesAdded: 8446, commits: 1, conversationTokens: 0 },
  { week: "2025-08-25", linesAdded: 19879, commits: 35, conversationTokens: 0 },
  { week: "2025-09-01", linesAdded: 14871, commits: 62, conversationTokens: 0 },
  { week: "2025-09-08", linesAdded: 3570, commits: 57, conversationTokens: 0 },
  { week: "2025-09-15", linesAdded: 16196, commits: 59, conversationTokens: 0 },
  { week: "2025-09-22", linesAdded: 16972, commits: 73, conversationTokens: 0 },
  { week: "2025-09-29", linesAdded: 20554, commits: 63, conversationTokens: 0 },
  { week: "2025-10-06", linesAdded: 11240, commits: 42, conversationTokens: 0 },
  { week: "2025-10-13", linesAdded: 12289, commits: 27, conversationTokens: 0 },
  { week: "2025-10-20", linesAdded: 10909, commits: 24, conversationTokens: 0 },
  { week: "2025-10-27", linesAdded: 20061, commits: 31, conversationTokens: 0 },
  { week: "2025-11-03", linesAdded: 10597, commits: 18, conversationTokens: 0 },
  { week: "2025-11-10", linesAdded: 6407, commits: 20, conversationTokens: 0 },
  { week: "2025-11-17", linesAdded: 4322, commits: 12, conversationTokens: 0 },
  { week: "2025-11-24", linesAdded: 25748, commits: 10, conversationTokens: 0 },
  { week: "2025-12-01", linesAdded: 1110, commits: 2, conversationTokens: 0 },
  { week: "2025-12-08", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-12-15", linesAdded: 1308, commits: 1, conversationTokens: 0 },
  { week: "2025-12-22", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2025-12-29", linesAdded: 15550, commits: 26, conversationTokens: 0 },
  { week: "2026-01-05", linesAdded: 21, commits: 1, conversationTokens: 0 },
  { week: "2026-01-12", linesAdded: 90, commits: 4, conversationTokens: 0 },
  { week: "2026-01-19", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-01-26", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-02-02", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-02-09", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-02-16", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-02-23", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-03-02", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-03-09", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-03-16", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-03-23", linesAdded: 2161, commits: 1, conversationTokens: 0 },
  { week: "2026-03-30", linesAdded: 130, commits: 1, conversationTokens: 0 },
  { week: "2026-04-06", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-04-13", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-04-20", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-04-27", linesAdded: 35445, commits: 3, conversationTokens: 0 },
  { week: "2026-05-04", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-05-11", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-05-18", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-05-25", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-06-01", linesAdded: 0, commits: 0, conversationTokens: 0 },
  { week: "2026-06-08", linesAdded: 7690, commits: 18, conversationTokens: 0 },
  { week: "2026-06-15", linesAdded: 40952, commits: 151, conversationTokens: 0 },
  { week: "2026-06-22", linesAdded: 202356, commits: 497, conversationTokens: 1102381 },
  { week: "2026-06-29", linesAdded: 325049, commits: 604, conversationTokens: 4339938 },
  { week: "2026-07-06", linesAdded: 179568, commits: 388, conversationTokens: 1501306 },
  { week: "2026-07-13", linesAdded: 348023, commits: 444, conversationTokens: 1002409 },
  { week: "2026-07-20", linesAdded: 543713, commits: 439, conversationTokens: 982287 },
  { week: "2026-07-27", linesAdded: 321233, commits: 514, conversationTokens: 4169111 },
  { week: "2026-08-03", linesAdded: 163439, commits: 159, conversationTokens: 7698265 },
  { week: "2026-08-10", linesAdded: 151468, commits: 166, conversationTokens: 1331888 },
];
