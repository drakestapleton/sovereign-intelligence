type NodeSpec = { id: string; x: number; y: number; w: number; h: number; title: string; sub: string; fill: string; stroke: string };

const NODES: NodeSpec[] = [
  { id: "drake", x: 430, y: 16, w: 200, h: 54, title: "Drake Stapleton", sub: "inventor · final approval", fill: "#2b2233", stroke: "#9b819f" },
  { id: "atlas", x: 400, y: 110, w: 260, h: 58, title: "Atlas", sub: "orchestrator agent · named 30 Jul 2026", fill: "#24202c", stroke: "#7fb8a6" },
  { id: "sym", x: 370, y: 210, w: 320, h: 58, title: "Symphony", sub: "the multi-lane process", fill: "#27212f", stroke: "#7fb8a6" },
  { id: "gk", x: 24, y: 330, w: 190, h: 52, title: "Gatekeeper", sub: "preserves lane boundaries", fill: "#27212f", stroke: "#9b819f" },
  { id: "rec", x: 232, y: 330, w: 190, h: 52, title: "Recovery", sub: "destructive / secrets", fill: "#321b22", stroke: "#d7755d" },
  { id: "pub", x: 440, y: 330, w: 190, h: 52, title: "Publisher", sub: "contained deploy", fill: "#27212f", stroke: "#8eac78" },
  { id: "dr", x: 648, y: 330, w: 190, h: 52, title: "Backup / DR", sub: "synthetic smoke", fill: "#27212f", stroke: "#7fb8a6" },
  { id: "cap", x: 856, y: 330, w: 190, h: 52, title: "Capability", sub: "tools + artifacts", fill: "#27212f", stroke: "#7fb8a6" },
  { id: "claude", x: 80, y: 440, w: 280, h: 52, title: "Claude · first catalog", sub: "behavior + harness requirements", fill: "#1d1824", stroke: "rgba(184,170,185,.5)" },
  { id: "grok", x: 400, y: 440, w: 280, h: 52, title: "Grok · first observer", sub: "pack 16:40Z · technique + identity", fill: "#1d1824", stroke: "rgba(184,170,185,.5)" },
  { id: "codex", x: 720, y: 440, w: 280, h: 52, title: "Codex · first runtime", sub: "ChatGPT desktop · Sol", fill: "#1d1824", stroke: "rgba(184,170,185,.5)" },
];

export function FirstRunDiagram() {
  return (
    <svg viewBox="0 0 1070 520" role="img" aria-label="First Atlas Symphony: Drake names Atlas, Atlas runs Symphony, lanes and first reviewers">
      <defs>
        <marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
          <path d="M 0 0 L 10 5 L 0 10 z" fill="rgba(155,129,159,.8)" />
        </marker>
      </defs>
      <line x1="530" y1="70" x2="530" y2="110" stroke="rgba(155,129,159,.58)" strokeWidth="1.6" markerEnd="url(#arr)" />
      <line x1="530" y1="168" x2="530" y2="210" stroke="rgba(155,129,159,.58)" strokeWidth="1.6" markerEnd="url(#arr)" />
      <line x1="480" y1="268" x2="119" y2="330" stroke="rgba(155,129,159,.58)" strokeWidth="1.6" markerEnd="url(#arr)" />
      <line x1="500" y1="268" x2="327" y2="330" stroke="rgba(155,129,159,.58)" strokeWidth="1.6" markerEnd="url(#arr)" />
      <line x1="530" y1="268" x2="535" y2="330" stroke="rgba(155,129,159,.58)" strokeWidth="1.6" markerEnd="url(#arr)" />
      <line x1="560" y1="268" x2="743" y2="330" stroke="rgba(155,129,159,.58)" strokeWidth="1.6" markerEnd="url(#arr)" />
      <line x1="580" y1="268" x2="951" y2="330" stroke="rgba(155,129,159,.58)" strokeWidth="1.6" markerEnd="url(#arr)" />
      <line x1="220" y1="382" x2="220" y2="440" stroke="rgba(184,170,185,.45)" strokeWidth="1.4" strokeDasharray="5 4" />
      <line x1="530" y1="382" x2="540" y2="440" stroke="rgba(184,170,185,.45)" strokeWidth="1.4" strokeDasharray="5 4" />
      <line x1="860" y1="382" x2="860" y2="440" stroke="rgba(184,170,185,.45)" strokeWidth="1.4" strokeDasharray="5 4" />
      {NODES.map((n) => (
        <g key={n.id}>
          <rect x={n.x} y={n.y} width={n.w} height={n.h} rx="14" fill={n.fill} stroke={n.stroke} strokeWidth="1.8" />
          <text x={n.x + n.w / 2} y={n.y + 22} textAnchor="middle" fill="#fff8ee" fontSize="14" fontWeight="700">
            {n.title}
          </text>
          <text x={n.x + n.w / 2} y={n.y + 40} textAnchor="middle" fill="#b8aab9" fontSize="11">
            {n.sub}
          </text>
        </g>
      ))}
    </svg>
  );
}
