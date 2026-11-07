import { useEffect, useRef, useState } from "react";

export interface ChapterItem {
  id: string;
  number: string;
  label: string;
  summary: string;
}

export const HOMEPAGE_CHAPTERS: ChapterItem[] = [
  { id: "formation", number: "01", label: "Formation", summary: "Early life and resilience" },
  { id: "drive", number: "02", label: "Drive", summary: "Endurance and recovery" },
  { id: "record", number: "03", label: "Life Record", summary: "Documented milestones" },
  { id: "people", number: "04", label: "People", summary: "Family and inheritances" },
  { id: "work", number: "05", label: "Work", summary: "Career ladder and impact" },
  { id: "software", number: "06", label: "Software and AI", summary: "Engineering and practice" },
  { id: "latest", number: "07", label: "Latest Work", summary: "Atlas and AIEN architecture" },
  { id: "identity", number: "08", label: "Identity", summary: "Freedom Fighter ethos" },
];

export function StickyChapterNav() {
  const [activeId, setActiveId] = useState<string>("formation");
  const [drawerOpen, setDrawerOpen] = useState<boolean>(false);
  const pillListRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActiveId(entry.target.id);
          }
        });
      },
      {
        rootMargin: "-25% 0px -60% 0px",
        threshold: 0,
      }
    );

    HOMEPAGE_CHAPTERS.forEach((chapter) => {
      const element = document.getElementById(chapter.id);
      if (element) {
        observer.observe(element);
      }
    });

    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const container = pillListRef.current;
    if (container) {
      const activePill = container.querySelector(`[data-id="${activeId}"]`) as HTMLElement | null;
      if (activePill) {
        const offsetLeft = activePill.offsetLeft - container.offsetLeft;
        const targetScroll = offsetLeft - container.clientWidth / 2 + activePill.clientWidth / 2;
        container.scrollTo({ left: targetScroll, behavior: "smooth" });
      }
    }
  }, [activeId]);

  const activeIndex = HOMEPAGE_CHAPTERS.findIndex((c) => c.id === activeId);
  const safeIndex = activeIndex >= 0 ? activeIndex : 0;
  const currentChapter = HOMEPAGE_CHAPTERS[safeIndex];

  const hasPrev = safeIndex > 0;
  const hasNext = safeIndex < HOMEPAGE_CHAPTERS.length - 1;

  const scrollToChapter = (id: string) => {
    const target = document.getElementById(id);
    if (target) {
      target.scrollIntoView({ behavior: "smooth" });
      setDrawerOpen(false);
    }
  };

  const progressPercent = Math.round(((safeIndex + 1) / HOMEPAGE_CHAPTERS.length) * 100);

  return (
    <aside className="sticky-chapter-nav" aria-label="Homepage Chapter Navigation">
      <div className="sticky-chapter-inner">
        <div className="chapter-stepper">
          <button
            type="button"
            className="stepper-btn"
            onClick={() => hasPrev && scrollToChapter(HOMEPAGE_CHAPTERS[safeIndex - 1].id)}
            disabled={hasPrev === false}
            aria-label="Previous Chapter"
          >
            ← Prev
          </button>

          <button
            type="button"
            className="chapter-indicator-btn"
            onClick={() => setDrawerOpen(!drawerOpen)}
            aria-expanded={drawerOpen}
            aria-label="Toggle Chapter Drawer"
          >
            <span className="indicator-badge">{currentChapter.number}</span>
            <span className="indicator-label">{currentChapter.label}</span>
            <span className="indicator-chevron">{drawerOpen ? "▲" : "▼"}</span>
          </button>

          <button
            type="button"
            className="stepper-btn"
            onClick={() => hasNext && scrollToChapter(HOMEPAGE_CHAPTERS[safeIndex + 1].id)}
            disabled={hasNext === false}
            aria-label="Next Chapter"
          >
            Next →
          </button>
        </div>

        <nav className="chapter-pill-list" ref={pillListRef} aria-label="Chapter list">
          {HOMEPAGE_CHAPTERS.map((chapter) => {
            const isCurrent = chapter.id === activeId;
            return (
              <button
                key={chapter.id}
                type="button"
                data-id={chapter.id}
                className={`chapter-pill ${isCurrent ? "active" : ""}`}
                onClick={() => scrollToChapter(chapter.id)}
                aria-current={isCurrent ? "true" : undefined}
              >
                <span className="pill-num">{chapter.number}</span>
                <span className="pill-label">{chapter.label}</span>
              </button>
            );
          })}
        </nav>
      </div>

      <div
        className="chapter-progress-bar"
        style={{ width: `${progressPercent}%` }}
        role="progressbar"
        aria-valuenow={progressPercent}
        aria-valuemin={0}
        aria-valuemax={100}
      />

      {drawerOpen && (
        <div className="chapter-drawer-overlay" onClick={() => setDrawerOpen(false)}>
          <div
            className="chapter-drawer-dialog"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-label="All Chapters"
          >
            <div className="drawer-header">
              <h3>Dossier Chapters</h3>
              <button
                type="button"
                className="drawer-close-btn"
                onClick={() => setDrawerOpen(false)}
                aria-label="Close chapter menu"
              >
                ✕
              </button>
            </div>
            <div className="drawer-list">
              {HOMEPAGE_CHAPTERS.map((chapter) => {
                const isCurrent = chapter.id === activeId;
                return (
                  <button
                    key={chapter.id}
                    type="button"
                    className={`drawer-item ${isCurrent ? "active" : ""}`}
                    onClick={() => scrollToChapter(chapter.id)}
                  >
                    <span className="drawer-item-num">{chapter.number}</span>
                    <div className="drawer-item-content">
                      <strong>{chapter.label}</strong>
                      <small>{chapter.summary}</small>
                    </div>
                    {isCurrent && <span className="drawer-item-active-dot">●</span>}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </aside>
  );
}
