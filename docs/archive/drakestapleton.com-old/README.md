# Drake Stapleton: Freedom Fighter, AI Architect & Operator

The personal project record of Drake Stapleton: production orchestration, GPU systems, model training, research, and Atlas.

Open to good conversation and research partnerships that advance what our generation can build with AI.

Live: [https://www.drakestapleton.com/](https://www.drakestapleton.com/)
Conversation: [https://www.drakestapleton.com/interest](https://www.drakestapleton.com/interest)

## Local development and release

```bash
npm run dev                 # complete portrait development mode
npm run dev:portfolio       # explicit portrait development mode
npm run build               # public portrait release
npm run build:portfolio     # explicit public portrait release
npm run preview             # preview the most recent build
```

Both release commands render the complete story, software and AI practice, evidence record, Atlas history, AEGIS product record, and Symphony pages. The build emits route-specific static metadata, a sitemap, and an indexable robots file.

## Checks

```bash
npm run typecheck
npm run check:copy
npm run test:waitlist
npm run build
npm run build:portfolio
```

The copy check enforces Drake's affirmative voice across page, component, data, and diagram copy. Build verification confirms the complete portrait and its route metadata are present.

## Telemetry and Acquisition Tracking

Google Ads and Google Tag telemetry track inbound campaigns and outbound repository engagement:

- Outbound repository clicks (`repo_outbound_click`) capture developer interest on GitHub destinations.
- Form submissions on `/interest` fire conversation lead conversion events (`conversion`, `generate_lead`).
- Content Security Policy headers whitelist Google Tag Manager, Google Analytics, and Google Ads telemetry endpoints.
- Build injection via `GOOGLE_ADS_ID` or `VITE_GOOGLE_ADS_ID` activates production script loading. When omitted, an in-memory queue prevents runtime client errors.
- Comprehensive campaign structures, search ad groups, negative keywords, and UTM conventions reside in [ops/GOOGLE_ADS_ACQUISITION.md](ops/GOOGLE_ADS_ACQUISITION.md).

## Hosting

GitHub Pages deploys the complete portrait from `main`.

The signup API stores normalized email, consent version, and signup time. Public requests use affirmative consent, origin checks, rate limiting, a honeypot, and TLS.

## Credit

Atlas Symphony was designed, named, and first operated by Drake Stapleton on 30 July 2026.
