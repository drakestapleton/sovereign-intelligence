import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

const mode = process.argv[2] || "portfolio";
if (!new Set(["waitlist", "portfolio"]).has(mode)) {
  throw new Error(`Unknown site mode: ${mode}`);
}

const dist = "dist";
const indexPath = join(dist, "index.html");
const indexHtml = readFileSync(indexPath, "utf8");
const pageMetadata = JSON.parse(readFileSync(new URL("../site-metadata.json", import.meta.url), "utf8"));
const routes = [
  { rel: "atlas/index.html", path: "/atlas", ...pageMetadata["/atlas"] },
  { rel: "aegis/index.html", path: "/aegis", ...pageMetadata["/aegis"] },
  { rel: "aien/index.html", path: "/aien", ...pageMetadata["/aien"] },
  { rel: "research/index.html", path: "/research", ...pageMetadata["/research"] },
  { rel: "scholar/index.html", path: "/scholar", ...pageMetadata["/scholar"] },
  { rel: "scholar/omega/index.html", path: "/scholar/omega", ...pageMetadata["/scholar/omega"] },
  { rel: "what-i-learned/index.html", path: "/what-i-learned", ...pageMetadata["/what-i-learned"] },
  { rel: "what-broke/index.html", path: "/what-i-learned", ...pageMetadata["/what-i-learned"], redirect: true },
  { rel: "path/index.html", path: "/path", ...pageMetadata["/path"] },
  { rel: "software/index.html", path: "/software", ...pageMetadata["/software"] },
  { rel: "evidence/index.html", path: "/evidence", ...pageMetadata["/evidence"] },
  { rel: "interest/index.html", path: "/interest", ...pageMetadata["/interest"] },
  { rel: "dad/index.html", path: "/dad", ...pageMetadata["/dad"] },
  { rel: "symphony/index.html", path: "/symphony", ...pageMetadata["/symphony"] },
  { rel: "symphony/first/index.html", path: "/symphony/first", ...pageMetadata["/symphony/first"] },
  { rel: "symphony/workflow/index.html", path: "/symphony/workflow", ...pageMetadata["/symphony/workflow"] },
  { rel: "symphony/map/index.html", path: "/symphony/map", ...pageMetadata["/symphony/map"] },
  { rel: "atlas-symphony/index.html", path: "/symphony", ...pageMetadata["/symphony"], redirect: true },
  { rel: "works/index.html", path: "/works", ...pageMetadata["/works"] },
  { rel: "works/atlas-symphony/index.html", path: "/works/atlas-symphony", ...pageMetadata["/works/atlas-symphony"] },
  { rel: "works/atlas-harness/index.html", path: "/works/atlas-harness", ...pageMetadata["/works/atlas-harness"] },
  { rel: "works/mobdev-panel-arena/index.html", path: "/works/mobdev-panel-arena", ...pageMetadata["/works/mobdev-panel-arena"] },
  { rel: "works/defiantmob/index.html", path: "/works/defiantmob", ...pageMetadata["/works/defiantmob"] },
  { rel: "works/beltbrain/index.html", path: "/works/beltbrain", ...pageMetadata["/works/beltbrain"] },
  { rel: "works/dhg-hive/index.html", path: "/works/dhg-hive", ...pageMetadata["/works/dhg-hive"] },
  { rel: "works/foundations-2025/index.html", path: "/works/foundations-2025", ...pageMetadata["/works/foundations-2025"] },
  { rel: "works/aien/index.html", path: "/works/aien", ...pageMetadata["/works/aien"] },
  { rel: "works/aegis/index.html", path: "/works/aegis", ...pageMetadata["/works/aegis"] },
  { rel: "works/research/index.html", path: "/works/research", ...pageMetadata["/works/research"] },
];

function escapeAttribute(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function escapeText(value) {
  return value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
}

function noscriptSummary(page) {
  const links = [
    ["/", "Home"],
    ["/path", "Path"],
    ["/software", "Software"],
    ["/works", "Works"],
    ["/evidence", "Evidence"],
    ["/atlas", "Atlas"],
    ["/interest", "Conversation"],
    ["/aegis", "AEGIS"],
    ["/aien", "AIEN"],
    ["/research", "Research"],
    ["/symphony", "Symphony"],
  ];
  const nav = links.map(([href, label]) => `<a href="${href}">${label}</a>`).join(" ");
  return `<noscript><main><h1>${escapeText(page.title)}</h1><p>${escapeText(page.description)}</p><nav>${nav}</nav></main></noscript>`;
}

function structuredData(page) {
  const canonical = `https://www.drakestapleton.com${page.path}`;
  const person = {
    "@type": "Person",
    "@id": "https://www.drakestapleton.com/#person",
    name: "Drake Stapleton",
    jobTitle: "AI Architect & Operator",
    description: "Freedom Fighter, AI Architect & Operator documenting projects, research, and the life behind the work.",
    url: "https://www.drakestapleton.com/",
    image: "https://www.drakestapleton.com/og.png?v=20260820",
    sameAs: ["https://github.com/dhgmonkey"],
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

  const graph = page.path === "/"
    ? [
        {
          "@type": "WebSite",
          "@id": "https://www.drakestapleton.com/#website",
          name: "Drake Stapleton",
          url: "https://www.drakestapleton.com/",
        },
        person,
        {
          "@type": "FAQPage",
          "@id": "https://www.drakestapleton.com/#faq",
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
          name: page.title,
          description: page.description,
          url: canonical,
          isPartOf: { "@id": "https://www.drakestapleton.com/#website" },
          about: { "@id": "https://www.drakestapleton.com/#person" },
        },
        person,
      ];

  return JSON.stringify({ "@context": "https://schema.org", "@graph": graph }).replaceAll("<", "\\u003c");
}

let ssrRender = null;
const ssrPath = join(process.cwd(), "dist-ssr/entry-server.js");
if (existsSync(ssrPath)) {
  try {
    const ssrModule = await import(ssrPath);
    ssrRender = ssrModule.render;
    console.log("SSR pre-rendering active: pre-rendering full semantic HTML for all routes");
  } catch (err) {
    console.warn("SSR module failed to load, using noscript fallback:", err.message);
  }
}

function withMetadata(html, page) {
  const title = escapeText(page.title);
  const description = escapeAttribute(page.description);
  const canonical = `https://www.drakestapleton.com${page.path}`;
  const jsonLd = structuredData(page);
  let renderedBody = "";
  let headPreloads = "";
  if (ssrRender && !page.redirect) {
    try {
      renderedBody = ssrRender(page.path);
      renderedBody = renderedBody.replace(/<link rel="preload"[^>]*\/?>/g, (match) => {
        headPreloads += `    ${match}\n`;
        return "";
      });
    } catch (e) {
      console.warn(`SSR render failed for ${page.path}:`, e.message);
      renderedBody = noscriptSummary(page);
    }
  } else {
    renderedBody = noscriptSummary(page);
  }
  return html
    .replace(/<title>[^<]*<\/title>/, `<title>${title}</title>`)
    .replace(/<meta name="description" content="[^"]*"\s*\/?>/, `<meta name="description" content="${description}" />`)
    .replace(/<link rel="canonical" href="[^"]*"\s*\/?>/, `<link rel="canonical" href="${canonical}" />`)
    .replace(/<meta property="og:title" content="[^"]*"\s*\/?>/, `<meta property="og:title" content="${escapeAttribute(page.title)}" />`)
    .replace(/<meta property="og:description" content="[^"]*"\s*\/?>/, `<meta property="og:description" content="${description}" />`)
    .replace(/<meta property="og:url" content="[^"]*"\s*\/?>/, `<meta property="og:url" content="${canonical}" />`)
    .replace(/<meta name="twitter:title" content="[^"]*"\s*\/?>/, `<meta name="twitter:title" content="${escapeAttribute(page.title)}" />`)
    .replace(/<meta name="twitter:description" content="[^"]*"\s*\/?>/, `<meta name="twitter:description" content="${description}" />`)
    .replace(/<script id="structured-data" type="application\/ld\+json">[\s\S]*?<\/script>/, `<script id="structured-data" type="application/ld+json">${jsonLd}</script>`)
    .replace("</head>", `${headPreloads}  </head>`)
    .replace('<div id="root"></div>', `<div id="root">${renderedBody}</div>`);
}

function writePage(rel, html) {
  const destination = join(dist, rel);
  mkdirSync(dirname(destination), { recursive: true });
  writeFileSync(destination, html);
  console.log("site fallback", destination);
}

if (mode === "portfolio") {
  writeFileSync(indexPath, withMetadata(indexHtml, { path: "/", ...pageMetadata["/"] }));
}

for (const route of routes) {
  const routeHtml = mode === "portfolio" ? withMetadata(indexHtml, route) : indexHtml;
  writePage(
    route.rel,
    mode === "portfolio" && route.redirect
      ? routeHtml.replace('content="index, follow"', 'content="noindex, follow"')
      : routeHtml,
  );
}

const notFound = mode === "portfolio"
  ? withMetadata(indexHtml, { path: "/404", ...pageMetadata["/404"] }).replace('content="index, follow"', 'content="noindex, follow"')
  : indexHtml;
writePage("404.html", notFound);

if (mode === "portfolio") {
  const publicRoutes = ["/", ...routes.filter((route) => !route.redirect).map((route) => route.path)];
  const lastmod = new Date().toISOString().slice(0, 10);
  const sitemap = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ...publicRoutes.map((path) => {
      const priority = path === "/" ? "1.0" : new Set(["/interest", "/software"]).has(path) ? "0.9" : "0.7";
      return `  <url><loc>https://www.drakestapleton.com${path}</loc><lastmod>${lastmod}</lastmod><priority>${priority}</priority></url>`;
    }),
    "</urlset>",
    "",
  ].join("\n");
  writeFileSync(join(dist, "robots.txt"), "User-agent: *\nAllow: /\nSitemap: https://www.drakestapleton.com/sitemap.xml\nLLMs: https://www.drakestapleton.com/llms.txt\n");
  writeFileSync(join(dist, "sitemap.xml"), sitemap);
} else {
  writeFileSync(join(dist, "robots.txt"), "User-agent: *\nDisallow: /\n");
  if (existsSync(join(dist, "sitemap.xml"))) {
    throw new Error("Waitlist build retained a sitemap");
  }
}
