import { Link, useParams } from "react-router-dom";
import { WORKS } from "../data/worksCatalog";
import "../styles/reader.css";

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function renderInline(source: string): string {
  const escaped = escapeHtml(source);
  return escaped.replace(/\[([^\]\n]+)\]\(([^)\s]+)\)/g, (full, label: string, href: string) => {
    const allowed = /^(https?:\/\/|mailto:|#|\/(?!\/))/i.test(href);
    if (allowed) return `<a href="${href}">${label}</a>`;
    return full;
  });
}

function bodyMarkdown(markdown: string): string {
  if (!markdown.startsWith("---\n")) return markdown;
  const end = markdown.indexOf("\n---\n", 3);
  if (end === -1) return markdown;
  return markdown.slice(end + 5);
}

function markdownToHtml(markdown: string): string {
  const lines = bodyMarkdown(markdown).replaceAll("\r\n", "\n").split("\n");
  const blocks: string[] = [];
  let paragraph: string[] = [];
  let index = 0;

  const flushParagraph = () => {
    if (paragraph.length === 0) return;
    blocks.push(`<p>${renderInline(paragraph.join(" "))}</p>`);
    paragraph = [];
  };

  while (index < lines.length) {
    const line = lines[index].trim();
    const headingMatch = /^(#{1,6})\s+(.*)$/.exec(line);
    if (headingMatch) {
      flushParagraph();
      const level = headingMatch[1].length;
      blocks.push(`<h${level}>${renderInline(headingMatch[2])}</h${level}>`);
      index += 1;
      continue;
    }

    if (line.startsWith(">")) {
      flushParagraph();
      const quote: string[] = [];
      while (index < lines.length && lines[index].trim().startsWith(">")) {
        quote.push(lines[index].trim().replace(/^>\s?/, ""));
        index += 1;
      }
      blocks.push(`<blockquote><p>${renderInline(quote.join(" "))}</p></blockquote>`);
      continue;
    }

    if (/^[-*]\s+/.test(line)) {
      flushParagraph();
      const items: string[] = [];
      while (index < lines.length) {
        const item = /^[-*]\s+(.*)$/.exec(lines[index].trim());
        if (!item) break;
        items.push(`<li>${renderInline(item[1])}</li>`);
        index += 1;
      }
      blocks.push(`<ul>${items.join("")}</ul>`);
      continue;
    }

    if (/^\d+\.\s+/.test(line)) {
      flushParagraph();
      const items: string[] = [];
      while (index < lines.length) {
        const item = /^\d+\.\s+(.*)$/.exec(lines[index].trim());
        if (!item) break;
        items.push(`<li>${renderInline(item[1])}</li>`);
        index += 1;
      }
      blocks.push(`<ol>${items.join("")}</ol>`);
      continue;
    }

    if (line === "") {
      flushParagraph();
      index += 1;
      continue;
    }

    paragraph.push(line);
    index += 1;
  }

  flushParagraph();
  return blocks.join("");
}

export function WorkReaderPage() {
  const { slug } = useParams();
  const work = WORKS.find((item) => item.slug === slug);

  if (!work) {
    return (
      <main className="reader">
        <article>
          <p>
            This piece is absent from this volume. <Link to="/works">Return to works</Link>
          </p>
        </article>
      </main>
    );
  }

  return (
    <main className="reader">
      <article>
        <h1>{work.title}</h1>
        <p className="reader-date">{work.date}</p>
        <div className="reader-body" dangerouslySetInnerHTML={{ __html: markdownToHtml(work.markdown) }} />
      </article>
    </main>
  );
}
