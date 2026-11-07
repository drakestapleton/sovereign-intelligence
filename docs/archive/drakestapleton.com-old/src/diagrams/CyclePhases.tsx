function Phase({
  n,
  title,
  lines,
  x,
  accent = "#2b2233",
}: {
  n: string;
  title: string;
  lines: string[];
  x: number;
  accent?: string;
}) {
  return (
    <g>
      <rect x={x} y={62} width={176} height={142} fill="#fffaf3" stroke={accent} strokeWidth="2" />
      <rect x={x} y={62} width={176} height="7" fill={accent} />
      <text x={x + 18} y={92} fill={accent} fontSize="11" fontWeight="700" letterSpacing="1.5">
        {n}
      </text>
      <text x={x + 18} y={119} fill="#2b2233" fontSize="14" fontWeight="700">
        {title}
      </text>
      {lines.map((line, index) => (
        <text key={line} x={x + 18} y={145 + index * 18} fill="#6d626a" fontSize="11">
          {line}
        </text>
      ))}
    </g>
  );
}

export function CyclePhases() {
  return (
    <svg viewBox="0 0 1180 270" role="img" aria-label="Current Atlas Symphony cycle">
      <Phase n="01" title="Admit" lines={["bind scope", "cost and authority"]} x={18} accent="#a9462b" />
      <Phase n="02" title="Conduct" lines={["reuse prior work", "coordinate the sequence"]} x={211} />
      <Phase n="03" title="Separate" lines={["independent L2 lanes", "independent review"]} x={404} accent="#a9462b" />
      <Phase n="04" title="Execute" lines={["focused L3 cells", "edits · tests · receipts"]} x={597} />
      <Phase n="05" title="Verify" lines={["exact candidate", "proof and teardown"]} x={790} accent="#a9462b" />
      <Phase n="06" title="Close" lines={["L2 verdicts", "L1 synthesis · human GO"]} x={983} />
      <path d="M194 133 H211 M387 133 H404 M580 133 H597 M773 133 H790 M966 133 H983" stroke="#2b2233" strokeWidth="2" fill="none" />
      <text x="590" y="242" textAnchor="middle" fill="#6d626a" fontSize="12">
        Each gate preserves the evidence and returns the exact result to the next focused attempt.
      </text>
    </svg>
  );
}
