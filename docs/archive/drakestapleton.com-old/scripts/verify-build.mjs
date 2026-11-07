import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const mode = process.argv[2];
if (!new Set(["waitlist", "portfolio"]).has(mode)) throw new Error("Expected waitlist or portfolio mode");

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const index = readFileSync("dist/index.html", "utf8");
const scripts = readdirSync("dist/assets")
  .filter((name) => name.endsWith(".js"))
  .map((name) => readFileSync(join("dist/assets", name), "utf8"))
  .join("\n");
const requiredPages = [
  "404.html",
  "aegis/index.html",
  "aien/index.html",
  "research/index.html",
  "atlas/index.html",
  "what-i-learned/index.html",
  "path/index.html",
  "software/index.html",
  "evidence/index.html",
  "interest/index.html",
  "symphony/index.html",
  "symphony/first/index.html",
  "symphony/workflow/index.html",
  "symphony/map/index.html",
];

assert(!index.includes("__SITE_"), "HTML metadata placeholders remain");
assert(index.includes(`name="site-mode" content="${mode}"`), `Incorrect ${mode} marker`);
assert(index.includes("Content-Security-Policy"), "Content Security Policy metadata is missing");
assert(index.includes("style-src 'self';"), "Production style policy is missing");
assert(!index.includes("style-src 'self' 'unsafe-inline'"), "Development style policy leaked into the production build");
assert(existsSync("dist/og.png"), "Social preview image is missing");
assert(existsSync("dist/favicon.svg"), "Favicon is missing");
requiredPages.forEach((page) => assert(existsSync(join("dist", page)), `Missing ${page}`));

if (mode === "waitlist") {
  assert(index.includes("noindex, nofollow, noarchive"), "Waitlist build is indexable");
  assert(scripts.includes("Join the waiting list"), "Waitlist copy is missing from the public bundle");
  assert(!scripts.includes("I keep finding "), "Portrait copy leaked into the waitlist bundle");
  assert(readFileSync("dist/robots.txt", "utf8").includes("Disallow: /"), "Waitlist robots file is open");
  assert(!existsSync("dist/sitemap.xml"), "Waitlist build includes a sitemap");
} else {
  assert(index.includes("index, follow"), "Portfolio build is hidden from search");
  assert(index.includes("AI Architect"), "Homepage AI Architect metadata is missing");
  assert(index.includes("application/ld+json"), "Homepage structured data is missing");
  assert(index.includes('property="og:site_name" content="Drake Stapleton"'), "Homepage og:site_name missing");
  assert(index.includes("Drake Stapleton"), "Homepage Drake Stapleton missing");
  assert(scripts.includes("I keep finding "), "Portrait copy is missing from the portfolio bundle");
  assert(!scripts.includes("Join the waiting list"), "Waitlist copy leaked into the portfolio bundle");
  assert(existsSync("dist/sitemap.xml"), "Portfolio sitemap is missing");
  const interest = readFileSync("dist/interest/index.html", "utf8");
  assert(interest.includes("Start a Conversation"), "Conversation metadata is missing");
  const atlas = readFileSync("dist/atlas/index.html", "utf8");
  assert(atlas.includes("Why Atlas Exists"), "Atlas static metadata is missing");
  assert(atlas.includes("https://www.drakestapleton.com/atlas"), "Atlas canonical URL is missing");
  const aegis = readFileSync("dist/aegis/index.html", "utf8");
  assert(aegis.includes("AEGIS Defensive Atlas Extension"), "AEGIS static metadata is missing");
  assert(aegis.includes("https://www.drakestapleton.com/aegis"), "AEGIS canonical URL is missing");
  const aien = readFileSync("dist/aien/index.html", "utf8");
  assert(aien.includes("AIEN Sovereign Cognitive Architecture"), "AIEN static metadata is missing");
  assert(aien.includes("https://www.drakestapleton.com/aien"), "AIEN canonical URL is missing");
  const research = readFileSync("dist/research/index.html", "utf8");
  assert(research.includes("LLM Inference Research & Architecture"), "Research static metadata is missing");
  assert(research.includes("https://www.drakestapleton.com/research"), "Research canonical URL is missing");
  assert(scripts.includes("59/62"), "AEGIS evaluation result is missing from the portfolio bundle");
  assert(!scripts.includes("Discuss a partnership"), "Sales language remains in the portfolio bundle");
  assert(!scripts.includes("License AEGIS"), "AEGIS sales language remains in the portfolio bundle");
  assert(existsSync("dist/llms.txt"), "Portfolio llms.txt is missing");
  const whatBroke = readFileSync("dist/what-broke/index.html", "utf8");
  assert(whatBroke.includes("noindex, follow"), "what-broke is indexable");
  assert(whatBroke.includes("https://www.drakestapleton.com/what-i-learned"), "what-broke missing canonical link");
  const atlasSymphony = readFileSync("dist/atlas-symphony/index.html", "utf8");
  assert(atlasSymphony.includes("noindex, follow"), "atlas-symphony is indexable");
  assert(atlasSymphony.includes("https://www.drakestapleton.com/symphony"), "atlas-symphony missing canonical link");
  const sitemap = readFileSync("dist/sitemap.xml", "utf8");
  assert(
    !sitemap.includes("https://www.drakestapleton.com/what-broke</loc>"),
    "sitemap lists the what-broke alias",
  );
  assert(
    !sitemap.includes("https://www.drakestapleton.com/atlas-symphony</loc>"),
    "sitemap lists the atlas-symphony alias",
  );
  const fourOhFour = readFileSync("dist/404.html", "utf8");
  assert(fourOhFour.includes("noindex, follow"), "404 is indexable");

}
console.log(`${mode} build verified`);
