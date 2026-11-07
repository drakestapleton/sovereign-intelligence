import { readFileSync, readdirSync } from "node:fs";
import { extname, join } from "node:path";

const roots = ["src/pages", "src/components", "src/data", "src/diagrams"];
const forbidden = /\b(not|no|never|isn['’]t|wasn['’]t|didn['’]t|don['’]t|doesn['’]t|can['’]t|cannot|won['’]t|without|nobody|nothing|neither|nor|lacked?|unwilling|refus(?:e|ed|ing))\b/gi;
const synthetic = /\b(agentic|delve|tapestry|testament|cutting-edge|seamless|transformative|thought leader)\b/gi;
// HisWords marks the author's own spoken words. His voice is exempt from the
// affirmative-copy rule: the rule governs AI-drafted prose, not him.
const hisWordsOpen = /<HisWords[\s>]/g;
const hisWordsClose = /<\/HisWords>/g;
const findings = [];

function visit(directory) {
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) {
      visit(path);
      continue;
    }
    if (![".ts", ".tsx"].includes(extname(path))) continue;
    const lines = readFileSync(path, "utf8").split("\n");
    let hisWordsDepth = 0;
    lines.forEach((line, index) => {
      hisWordsOpen.lastIndex = 0;
      hisWordsClose.lastIndex = 0;
      const opens = [...line.matchAll(hisWordsOpen)].length;
      const closes = [...line.matchAll(hisWordsClose)].length;
      const inHisWords = hisWordsDepth > 0 || opens > 0;
      hisWordsDepth = Math.max(0, hisWordsDepth + opens - closes);
      if (inHisWords) return;
      for (const pattern of [forbidden, synthetic]) {
        pattern.lastIndex = 0;
        const matches = [...line.matchAll(pattern)].map((match) => match[0]);
        if (matches.length) findings.push(`${path}:${index + 1}: ${matches.join(", ")}`);
      }
    });
  }
}

roots.forEach(visit);
if (findings.length) {
  console.error(findings.join("\n"));
  process.exit(1);
}
console.log("copy check passed");
