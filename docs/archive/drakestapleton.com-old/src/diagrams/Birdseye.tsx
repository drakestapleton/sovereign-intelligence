type Block = { x: number; y: number; w: number; title: string; a: string; b?: string; stroke: string; dash?: boolean };

const BLOCKS: Block[] = [
  { x: 150, y: 80, w: 230, title: "4k standing prompt", a: "typed ~169×", b: "MobDev + Panel already exist", stroke: "#9b819f" },
  { x: 390, y: 80, w: 160, title: "codeharness", a: "25 Jul · four primitives", b: "model proposes, harness disposes", stroke: "#7fb8a6" },
  { x: 560, y: 80, w: 150, title: "rename → Atlas", a: "26-27 Jul sole home", b: "codeharness name dies", stroke: "#9b819f" },
  { x: 720, y: 80, w: 170, title: "desktop + remote", a: "Gate A 1 Aug closed", b: "board :4319", stroke: "#8eac78" },
  { x: 900, y: 80, w: 230, title: "Boston atlas CLI", a: "10 Aug front door", b: "separate July Tauri desk", stroke: "#8eac78" },
  { x: 300, y: 194, w: 130, title: "HiveMind", a: "21 Jul · DHG word hive", stroke: "#9b819f" },
  { x: 440, y: 194, w: 150, title: "Documents/Atlas", a: "28 Jul counterpart bible", stroke: "#7fb8a6" },
  { x: 600, y: 194, w: 200, title: "four homes", a: "Mac · Pi · Boston · Queen", stroke: "#8eac78" },
  { x: 810, y: 194, w: 150, title: "intent sealed", a: "4 Aug · two drives", stroke: "#8eac78" },
  { x: 500, y: 308, w: 160, title: "Symphony 3.0→4.0", a: "planners · draft", stroke: "#9b819f" },
  { x: 680, y: 308, w: 200, title: "Boston hive boots", a: "9-10 Aug A→H/B/F", stroke: "#8eac78" },
  { x: 890, y: 308, w: 130, title: "Darwin organs", a: "DNA · kill · breed", stroke: "#d3a85b" },
  { x: 1030, y: 308, w: 100, title: "pop 815", a: "max 40", stroke: "#d7755d", dash: true },
  { x: 860, y: 416, w: 160, title: "Isolated law", a: "12 Aug + Gate B", stroke: "#8eac78" },
  { x: 1030, y: 416, w: 100, title: "L2 factory", a: "13 Aug · staged", stroke: "#d3a85b", dash: true },
  { x: 850, y: 526, w: 150, title: "Image GPU", a: "stoppable 4090", stroke: "#8eac78" },
  { x: 1010, y: 526, w: 120, title: "Video path", a: "installed · 0 clips", stroke: "#d3a85b", dash: true },
  { x: 390, y: 640, w: 180, title: "GitHub leftover", a: "history 25 Jul - 1 Aug", stroke: "#d7755d", dash: true },
  { x: 590, y: 640, w: 200, title: "Forgejo save plane", a: "Mac origin · PR #11", stroke: "#7fb8a6" },
  { x: 810, y: 640, w: 160, title: "Boston factory", a: "7-commit bootstrap", stroke: "#d3a85b" },
];

export function Birdseye() {
  return (
    <svg viewBox="0 0 1180 760" role="img" aria-label="Bird’s-eye development map June to August 2026">
      <line x1="150" y1="36" x2="1140" y2="36" stroke="rgba(155,129,159,.3)" />
      {["18 Jun", "21 Jul", "25 Jul", "27 Jul", "1 Aug", "7-8 Aug", "9-10 Aug", "11-13 Aug"].map((t, i) => (
        <text key={t} className="birdseye-axis" x={160 + i * 130} y="28" fontSize="10">
          {t}
        </text>
      ))}
      <text className="birdseye-axis" x="16" y="72" fontSize="11">1 · Harness</text>
      <text className="birdseye-axis" x="16" y="186" fontSize="11">2 · Counterpart</text>
      <text className="birdseye-axis" x="16" y="300" fontSize="11">3 · Hive</text>
      <text className="birdseye-axis" x="16" y="414" fontSize="11">4 · Isolated law</text>
      <text className="birdseye-axis" x="16" y="518" fontSize="11">5 · Image / video</text>
      <text className="birdseye-axis" x="16" y="632" fontSize="11">6 · Where bits live</text>
      {BLOCKS.map((b) => (
        <g key={b.title}>
          <rect x={b.x} y={b.y} width={b.w} height={b.b ? 64 : 56} rx="10" fill="#24202c" stroke={b.stroke} strokeDasharray={b.dash ? "4 3" : undefined} />
          <text x={b.x + 12} y={b.y + 22} fill="#fff8ee" fontSize="12" fontWeight="700">{b.title}</text>
          <text x={b.x + 12} y={b.y + 38} fill="#b8aab9" fontSize="10">{b.a}</text>
          {b.b ? <text x={b.x + 12} y={b.y + 52} fill="#b8aab9" fontSize="10">{b.b}</text> : null}
        </g>
      ))}
    </svg>
  );
}
