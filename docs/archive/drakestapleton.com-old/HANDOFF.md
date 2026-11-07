# Handoff - drakestapleton.com

**As of 14 Aug 2026.** This branch publishes the complete human portrait while retaining the waiting-list gate as a fail-closed fallback.

- `npm run build` produces the fail-closed, no-index waiting-list release retained as the rollback build.
- `npm run build:portfolio` produces the complete, indexable portrait used by GitHub Pages for the public site.
- Every known route has a static fallback with route-specific metadata.
- Source: https://github.com/dhgmonkey/drakestapleton.com

The portrait uses Drake's supplied first-person history, the reviewed resume chronology, and the complete nine-file derivative audit package in `Downloads/drake-chatgpt-history-handoff`. The audit remains `PARTIAL` by its own evidence definition because the original ChatGPT account export is a future source.

## Release boundary

| Piece | State |
|---|---|
| Stack | Vite 7, React 19, TypeScript, react-router |
| Host | GitHub Pages with HTTPS and `www.drakestapleton.com` CNAME |
| Published Pages build | Full portrait via `npm run build:portfolio`, with route metadata, sitemap, and indexable pages |
| Waiting-list fallback | `npm run build` on every route, `noindex`, disallowing crawler access |
| Signup API | Dedicated Boston Python service on TLS port 8443 |
| Stored signup data | Normalized email, consent version, UTC timestamp |
| Public personal material | First-person story, reviewed work and education chronology, public-safe evidence |
| Private material | Raw transcripts, family source documents, member records, credentials, addresses, financial identifiers |

The public bundle excludes the portrait code. The portfolio bundle excludes the waiting-list code. `scripts/verify-build.mjs` enforces both boundaries.

## Local review

```bash
npm run dev:portfolio
npm run check:copy
npm run test:waitlist
npm run build
npm run build:portfolio
npm run preview
```

## Publication assets

- `public/og-card.svg`: editable source for the aubergine, ember, and parchment social card.
- `public/og.png`: rendered 1200 by 630 social card.
- `public/favicon.svg`: site favicon.
- `dist/robots.txt`: generated for the selected build mode.
- `dist/sitemap.xml`: generated for the portfolio build.

## Deployment order

1. Publish the complete portrait through `npm run build:portfolio` in the GitHub Pages workflow.
2. Verify the home page, every direct route, metadata, social image, 404 behavior, and the deployed commit.
3. To close the portrait again, change the workflow back to `npm run build` and verify the waiting-list gate and crawler block live.

## External security follow-up

- Confirm revocation of the Hostinger API token previously pasted into chat before the portfolio opens.
- Keep raw resumes, personal media, private histories, credentials, host details, and the coding archive outside the public site.
