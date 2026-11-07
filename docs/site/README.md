# drakestapleton.com: merged into aienos.com

Merged into https://www.aienos.com/engineer/ (About the engineer) on 26 October 2026.

Everything that was on drakestapleton.com, my story, my philosophy, my works and the glossary, now lives in About the engineer on aienos.com. Its single source is [`public/data/engineer.json`](https://github.com/aien-dev/aienos.com/blob/main/public/data/engineer.json) in aien-dev/aienos.com. Edit it there, not here.

This repository keeps `www.drakestapleton.com` resolving, so old links keep working. GitHub Pages cannot send an HTTP 301, so `site/` holds one stub per old address. Each stub carries a canonical link, a meta refresh at 0, a `location.replace` that keeps the `#fragment`, and a visible link. Markdown mirrors (`/path.md` and the rest) say where the page moved, because Pages cannot redirect a file. Any other address gets `404.html`, which sends a browser to the matching page or to About the engineer.

| File | What it is |
|---|---|
| `redirects.tsv` | Every old address and its new URL, tab-separated. |
| `site/` | The published stubs, `CNAME`, `robots.txt` and a `sitemap.xml` of the new URLs. |
| `.github/workflows/pages.yml` | Checks that every row of `redirects.tsv` has a complete stub, then deploys `site/`. |
| `evidence/` | Historical receipts from the old site, kept unchanged. |

The old Rust site builder, content and assets are in this repository's history up to commit `4b2313b`.

## License

The redirect stubs are released under the GNU Affero General Public License v3.0 or later (see [LICENSE](LICENSE)). The content now on aienos.com is published under that site's licensing statement: https://www.aienos.com/licensing/.
