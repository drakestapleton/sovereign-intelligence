function Box({
  x,
  y,
  w,
  h,
  title,
  sub,
  accent = "#2b2233",
}: {
  x: number;
  y: number;
  w: number;
  h: number;
  title: string;
  sub: string;
  accent?: string;
}) {
  return (
    <g>
      <rect x={x} y={y} width={w} height={h} fill="#fffaf3" stroke={accent} strokeWidth="2" />
      <rect x={x} y={y} width="6" height={h} fill={accent} />
      <text x={x + w / 2 + 3} y={y + 24} textAnchor="middle" fill="#2b2233" fontSize="14" fontWeight="700">
        {title}
      </text>
      <text x={x + w / 2 + 3} y={y + 44} textAnchor="middle" fill="#6d626a" fontSize="11">
        {sub}
      </text>
    </g>
  );
}

export function CommandTree() {
  return (
    <svg viewBox="0 0 1180 560" role="img" aria-label="Current Atlas Symphony L1, L2, and L3 command tree">
      <defs>
        <marker id="tier-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
          <path d="M 0 0 L 10 5 L 0 10 z" fill="#2b2233" />
        </marker>
        <marker id="review-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
          <path d="M 0 0 L 10 5 L 0 10 z" fill="#a9462b" />
        </marker>
      </defs>

      <text x="34" y="50" fill="#a9462b" fontSize="11" fontWeight="700" letterSpacing="2">HUMAN AUTHORITY</text>
      <text x="34" y="168" fill="#a9462b" fontSize="11" fontWeight="700" letterSpacing="2">L1</text>
      <text x="34" y="292" fill="#a9462b" fontSize="11" fontWeight="700" letterSpacing="2">L2</text>
      <text x="34" y="430" fill="#a9462b" fontSize="11" fontWeight="700" letterSpacing="2">L3</text>

      <line x1="590" y1="86" x2="590" y2="130" stroke="#2b2233" strokeWidth="2" markerEnd="url(#tier-arrow)" />
      <line x1="590" y1="202" x2="590" y2="242" stroke="#2b2233" strokeWidth="2" markerEnd="url(#tier-arrow)" />
      <path d="M590 312 V350 H175 V398 M590 350 H450 V398 M590 350 H730 V398 M590 350 H1005 V398" fill="none" stroke="#2b2233" strokeWidth="2" markerEnd="url(#tier-arrow)" />

      <Box x={455} y={24} w={270} h={62} title="Drake Stapleton" sub="purpose · limits · final approval" accent="#a9462b" />
      <Box x={430} y={130} w={320} h={72} title="L1 · Conductor" sub="scope · sequence · authority · synthesis" />

      <Box x={55} y={250} w={250} h={62} title="L2 · Architecture" sub="design and implementation steward" />
      <Box x={325} y={250} w={250} h={62} title="L2 · Independent review" sub="challenge · verify · approve" accent="#a9462b" />
      <Box x={595} y={250} w={250} h={62} title="L2 · Evidence" sub="tests · hashes · sources · verdict" accent="#a9462b" />
      <Box x={865} y={250} w={250} h={62} title="L2 · Operations" sub="provider state · cost · teardown" />

      <Box x={55} y={398} w={240} h={68} title="L3 · Build cells" sub="focused edits · focused tests" />
      <Box x={330} y={398} w={240} h={68} title="L3 · Review cells" sub="threats · mismatch · falsifiers" accent="#a9462b" />
      <Box x={610} y={398} w={240} h={68} title="L3 · Proof cells" sub="manifests · receipts · readback" accent="#a9462b" />
      <Box x={885} y={398} w={240} h={68} title="L3 · Provider cells" sub="inventory · lifecycle · cleanup" />

      <path d="M450 312 C450 338 720 338 720 312" fill="none" stroke="#a9462b" strokeWidth="2" strokeDasharray="7 6" markerEnd="url(#review-arrow)" />
      <text x="585" y="335" textAnchor="middle" fill="#a9462b" fontSize="11" fontWeight="700">INDEPENDENT REVIEW CLEARS IMPLEMENTATION</text>

      <path d="M175 466 V510 H590 M450 466 V510 H590 M730 466 V510 H590 M1005 466 V510 H590" fill="none" stroke="#2b2233" strokeWidth="1.6" />
      <text x="590" y="538" textAnchor="middle" fill="#2b2233" fontSize="12" fontWeight="700">L3 RECEIPTS → L2 VERDICTS → L1 SYNTHESIS → HUMAN GO WHEN REQUIRED</text>
    </svg>
  );
}
