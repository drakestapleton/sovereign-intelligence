import type { ReactNode } from "react";

/**
 * HisWords marks a passage as the author's own words: spoken aloud by him,
 * placed on the page by AI. Rendered as one small, quiet marker; the site
 * footer carries the key that explains it. Unmarked prose was drafted with
 * AI from his direction and kept only with his approval.
 */
export function HisWords({
  children,
  block = false,
}: {
  children: ReactNode;
  block?: boolean;
}) {
  const mark = (
    <span className="his-words-mark" aria-hidden="true">
      ◆
    </span>
  );
  const srNote = (
    <span className="visually-hidden">His own words, spoken aloud. </span>
  );
  if (block) {
    return (
      <div className="his-words-block" title="His own words, spoken aloud">
        {srNote}
        {mark}
        {children}
      </div>
    );
  }
  return (
    <span className="his-words" title="His own words, spoken aloud">
      {srNote}
      {mark}
      {children}
    </span>
  );
}
