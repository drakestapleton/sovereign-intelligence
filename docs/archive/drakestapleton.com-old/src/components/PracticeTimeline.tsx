import { useState } from "react";
import { PRACTICE_SNAPSHOT, PRACTICE_TIMELINE } from "../data/practice";
import { HisWords } from "./VoiceMark";

type TimelineMetric = "linesAdded" | "commits" | "conversationTokens";

const CHARTS: Record<
  TimelineMetric,
  {
    button: string;
    title: string;
    subtitle: string;
    totalLabel: string;
    source: string;
    color: string;
  }
> = {
  linesAdded: {
    button: "Lines added",
    title: "Weekly source lines added",
    subtitle: "Text additions across 94 SHA-deduped project trees I own",
    totalLabel: "source lines added in the timeline",
    source: "Git history",
    color: "#a9462b",
  },
  commits: {
    button: "Commits",
    title: "Weekly unique commits",
    subtitle: "Distinct commit SHAs across the same 94 project trees",
    totalLabel: "unique commits in the timeline",
    source: "Git history",
    color: "#5a4668",
  },
  conversationTokens: {
    button: "AI conversation",
    title: "Weekly retained AI conversation tokens",
    subtitle: "Human and assistant message text from the coding desks I operated",
    totalLabel: "conversation tokens in the detailed timeline",
    source: "Claude, Codex, and Grok transcripts",
    color: "#9a712d",
  },
};

const compactNumber = new Intl.NumberFormat("en-US", {
  notation: "compact",
  maximumFractionDigits: 1,
});

const fullNumber = new Intl.NumberFormat("en-US");

const shortDate = new Intl.DateTimeFormat("en-US", {
  month: "short",
  year: "2-digit",
  timeZone: "UTC",
});

const longDate = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
  timeZone: "UTC",
});

function dateFromWeek(week: string): Date {
  return new Date(`${week}T00:00:00Z`);
}

function getLabelIndexes(length: number): Set<number> {
  const count = Math.min(length, 6);
  const indexes = Array.from({ length: count }, (_, index) =>
    Math.round((index * (length - 1)) / Math.max(count - 1, 1)),
  );
  return new Set(indexes);
}

export function PracticeTimeline() {
  const [metric, setMetric] = useState<TimelineMetric>("linesAdded");
  const chart = CHARTS[metric];
  const points =
    metric === "conversationTokens"
      ? PRACTICE_TIMELINE.filter((point) => point.conversationTokens > 0)
      : PRACTICE_TIMELINE;
  const values = points.map((point) => point[metric]);
  const maximum = Math.max(...values);
  const total = values.reduce((sum, value) => sum + value, 0);
  const peakIndex = values.indexOf(maximum);
  const peak = points[peakIndex];
  const labelIndexes = getLabelIndexes(points.length);

  const width = 1040;
  const height = 350;
  const padding = { top: 24, right: 18, bottom: 50, left: 76 };
  const innerWidth = width - padding.left - padding.right;
  const innerHeight = height - padding.top - padding.bottom;
  const step = innerWidth / points.length;
  const barWidth = Math.max(3, step * 0.72);
  const yTicks = [0, 0.25, 0.5, 0.75, 1];
  const coverageStart = points[0]?.week ?? PRACTICE_TIMELINE[0].week;

  return (
    <section className="practice-timeline" aria-labelledby="practice-timeline-title">
      <header className="practice-timeline-header">
        <div>
          <p className="portrait-index">What I made over time</p>
          <h2 id="practice-timeline-title"><HisWords>I can see the work accumulate.</HisWords></h2>
        </div>
        <div className="practice-timeline-total" aria-live="polite">
          <strong>{compactNumber.format(total)}</strong>
          <span>{chart.totalLabel}</span>
        </div>
      </header>

      <div className="practice-chart-controls" role="group" aria-label="Choose a timeline measure">
        {(Object.keys(CHARTS) as TimelineMetric[]).map((key) => (
          <button
            type="button"
            key={key}
            className={metric === key ? "active" : undefined}
            aria-pressed={metric === key}
            onClick={() => setMetric(key)}
          >
            {CHARTS[key].button}
          </button>
        ))}
      </div>

      <figure className="practice-chart-figure">
        <figcaption>
          <strong>{chart.title}</strong>
          <span>{chart.subtitle}</span>
        </figcaption>
        <div className="practice-chart-frame">
          <svg
            viewBox={`0 0 ${width} ${height}`}
            role="img"
            aria-labelledby="practice-chart-title practice-chart-description"
          >
            <title id="practice-chart-title">{chart.title}</title>
            <desc id="practice-chart-description">
              {`${chart.subtitle}. The peak week is ${longDate.format(dateFromWeek(peak.week))} at ${fullNumber.format(maximum)}.`}
            </desc>

            {yTicks.map((tick) => {
              const y = padding.top + innerHeight - tick * innerHeight;
              return (
                <g key={tick}>
                  <line
                    x1={padding.left}
                    x2={width - padding.right}
                    y1={y}
                    y2={y}
                    stroke="rgba(43, 34, 51, 0.16)"
                    strokeWidth="1"
                  />
                  <text
                    x={padding.left - 12}
                    y={y + 4}
                    textAnchor="end"
                    fill="#6d626a"
                    fontFamily="ui-monospace, SFMono-Regular, Menlo, monospace"
                    fontSize="11"
                  >
                    {compactNumber.format(maximum * tick)}
                  </text>
                </g>
              );
            })}

            {points.map((point, index) => {
              const value = point[metric];
              const barHeight = maximum === 0 ? 0 : (value / maximum) * innerHeight;
              const x = padding.left + index * step + (step - barWidth) / 2;
              const y = padding.top + innerHeight - barHeight;
              return (
                <g key={`${metric}-${point.week}`}>
                  <rect
                    x={x}
                    y={y}
                    width={barWidth}
                    height={barHeight}
                    rx="2"
                    fill={chart.color}
                  >
                    <title>{`${longDate.format(dateFromWeek(point.week))}: ${fullNumber.format(value)}`}</title>
                  </rect>
                  {labelIndexes.has(index) && (
                    <text
                      x={padding.left + index * step + step / 2}
                      y={height - 18}
                      textAnchor="middle"
                      fill="#6d626a"
                      fontFamily="ui-monospace, SFMono-Regular, Menlo, monospace"
                      fontSize="11"
                    >
                      {shortDate.format(dateFromWeek(point.week))}
                    </text>
                  )}
                </g>
              );
            })}
          </svg>
        </div>
      </figure>

      <div className="practice-chart-facts">
        <p>
          <span>Coverage</span>
          {longDate.format(dateFromWeek(coverageStart))} to {PRACTICE_SNAPSHOT.display}
        </p>
        <p>
          <span>Peak week</span>
          {longDate.format(dateFromWeek(peak.week))} · {fullNumber.format(maximum)}
        </p>
        <p>
          <span>Source</span>
          {chart.source}
        </p>
      </div>
      <p className="practice-chart-note">
        The final week covers 10 through 13 August. I keep each measure attached to its own unit and source.
      </p>
    </section>
  );
}
