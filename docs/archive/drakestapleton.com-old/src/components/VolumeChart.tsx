import { VOLUME } from "../data/portfolio";

function fmt(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1000) return `${Math.round(n / 1000)}k`;
  return String(n);
}

export function VolumeChart() {
  const { months, added } = VOLUME;
  const w = 960;
  const h = 220;
  const pad = { t: 16, r: 48, b: 28, l: 8 };
  const max = Math.max(...added);
  let run = 0;
  const cum = added.map((n) => (run += n));
  const maxC = cum[cum.length - 1];
  const bw = (w - pad.l - pad.r) / added.length;
  const bars = added.map((n, i) => {
    const bh = (n / max) * (h - pad.t - pad.b);
    return { x: pad.l + i * bw + 4, y: h - pad.b - bh, h: bh, n };
  });
  const line = cum
    .map((n, i) => {
      const x = pad.l + i * bw + bw / 2;
      const y = h - pad.b - (n / maxC) * (h - pad.t - pad.b);
      return `${i === 0 ? "M" : "L"}${x.toFixed(1)},${y.toFixed(1)}`;
    })
    .join(" ");

  return (
    <svg className="chart" viewBox={`0 0 ${w} ${h}`} role="img" aria-label="Monthly source added and cumulative">
      {bars.map((b, i) => (
        <rect key={months[i]} x={b.x} y={b.y} width={bw - 8} height={Math.max(b.h, 0)} fill="#7fb8a6cc" rx="3" />
      ))}
      <path d={line} fill="none" stroke="#a9462b" strokeWidth="2" />
      {months.map((m, i) => (
        <text key={m} x={pad.l + i * bw + bw / 2} y={h - 8} textAnchor="middle" fill="#6d626a" fontSize="9">
          {m}
        </text>
      ))}
      <text x={w - 4} y={18} textAnchor="end" fill="#6d626a" fontSize="10">
        peak {fmt(max)} · total {fmt(maxC)}
      </text>
    </svg>
  );
}
