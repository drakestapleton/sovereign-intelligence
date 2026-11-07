import { useEffect } from "react";
import pageMetadata from "../../site-metadata.json";

type Meta = { title: string; description: string };
type PageMetaInput = string | (Meta & { path: string; robots?: string });

const metadata = pageMetadata as Record<string, Meta>;
const siteUrl = "https://www.drakestapleton.com";

function structuredData(path: string, title: string, description: string) {
  const canonical = `${siteUrl}${path}`;
  const person = {
    "@type": "Person",
    "@id": `${siteUrl}/#person`,
    name: "Drake Stapleton",
    jobTitle: "AI Architect & Operator",
    description: "Freedom Fighter, AI Architect & Operator documenting projects, research, and the life behind the work.",
    url: `${siteUrl}/`,
    image: `${siteUrl}/og.png?v=20260820`,
    sameAs: ["https://github.com/aien-dev"],
    alumniOf: {
      "@type": "CollegeOrUniversity",
      name: "Western Kentucky University",
      url: "https://www.wku.edu/",
    },
    subjectOf: [
      {
        "@type": "Thesis",
        name: "Master of Science in Chemistry thesis",
        datePublished: "2018",
        url: "https://digitalcommons.wku.edu/theses/2101/",
      },
      {
        "@type": "ScholarlyArticle",
        name: "2019 peer-reviewed nanomaterials paper",
        datePublished: "2019",
        url: "https://pubmed.ncbi.nlm.nih.gov/30931213/",
      },
    ],
  };
  const graph = path === "/"
    ? [
        { "@type": "WebSite", "@id": `${siteUrl}/#website`, name: "Drake Stapleton", url: `${siteUrl}/` },
        person,
        {
          "@type": "FAQPage",
          "@id": `${siteUrl}/#faq`,
          mainEntity: [
            {
              "@type": "Question",
              name: "Why did Drake Stapleton build this site?",
              acceptedAnswer: {
                "@type": "Answer",
                text: "This site documents Drake Stapleton's projects, the work behind them, and the life that shaped them.",
              },
            },
            {
              "@type": "Question",
              name: "What work does Drake Stapleton do?",
              acceptedAnswer: {
                "@type": "Answer",
                text: "I design, operate, and audit production orchestration, GPU systems, and verifiable AI architecture.",
              },
            },
            {
              "@type": "Question",
              name: "What is Atlas?",
              acceptedAnswer: {
                "@type": "Answer",
                text: "Atlas is Drake Stapleton's personal R&D program in accountable AI architecture, continuity, model training, and orchestration.",
              },
            },
          ],
        },
      ]
    : [
        {
          "@type": "WebPage",
          "@id": `${canonical}#webpage`,
          name: title,
          description,
          url: canonical,
          isPartOf: { "@id": `${siteUrl}/#website` },
          about: { "@id": `${siteUrl}/#person` },
        },
        person,
      ];
  return { "@context": "https://schema.org", "@graph": graph };
}

export function usePageMeta(input: PageMetaInput, robots?: string) {
  const path = typeof input === "string" ? input : input.path;
  const shared = typeof input === "string" ? metadata[path] : input;
  const title = shared?.title;
  const description = shared?.description;
  const robotPolicy = robots || (typeof input === "string" ? undefined : input.robots);

  if (!title || !description) throw new Error(`Missing page metadata for ${path}`);

  useEffect(() => {
    document.title = title;
    const url = `${siteUrl}${path}`;
    const setMeta = (selector: string, content: string) => {
      document.querySelector(selector)?.setAttribute("content", content);
    };

    setMeta('meta[name="description"]', description);
    setMeta('meta[property="og:title"]', title);
    setMeta('meta[property="og:description"]', description);
    setMeta('meta[property="og:url"]', url);
    setMeta('meta[name="twitter:title"]', title);
    setMeta('meta[name="twitter:description"]', description);
    setMeta(
      'meta[name="robots"]',
      robotPolicy || (import.meta.env.MODE === "portfolio" ? "index, follow" : "noindex, nofollow, noarchive"),
    );
    document.querySelector('link[rel="canonical"]')?.setAttribute("href", url);

    let script = document.querySelector<HTMLScriptElement>('#structured-data');
    if (!script) {
      script = document.createElement("script");
      script.id = "structured-data";
      script.type = "application/ld+json";
      document.head.append(script);
    }
    script.textContent = JSON.stringify(structuredData(path, title, description));
  }, [title, description, path, robotPolicy]);
}
