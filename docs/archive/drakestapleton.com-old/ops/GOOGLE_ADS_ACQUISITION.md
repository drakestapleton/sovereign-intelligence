# Google Ads Acquisition and Conversion Tracking Playbook

This document defines the acquisition architecture, Google Tag configuration, conversion actions, and campaign structure for driving developer, researcher, and operator traffic to `drakestapleton.com` and open-source repositories (`aien-dev/aien-sovereign-core`, `aien-dev/benchmarks`, `aien-dev/openclaw-rs`).

---

## 1. Core Architecture

Google Ads cannot directly track downstream conversions (stars, forks, clones) on `github.com` due to GitHub third-party script isolation. Traffic is therefore driven to dedicated high-context routes on `drakestapleton.com` before routing outward.

```
+--------------------------+
| Google Ads (Search/PMax) |
+--------------------------+
             |
             v
+--------------------------------------------------------+
| Landing Pages (drakestapleton.com/aien, /research)     |
| - Pre-rendered semantic HTML with verified benchmarks  |
| - Google Tag (gtag.js) instrumentation                 |
| - CSP-compliant event telemetry                        |
+--------------------------------------------------------+
             |
             +------------------------------+
             |                              |
             v                              v
+--------------------------+  +--------------------------+
| Outbound GitHub Action   |  | Interest Form Conversion |
| - repo_outbound_click    |  | - generate_lead          |
| - github.com/aien-dev/*  |  | - /interest?received=1   |
+--------------------------+  +--------------------------+
```

---

## 2. Google Tag and CSP Directives

The production frontend enforces strict Content Security Policy headers in `index.html`. Google Tag integration permits:

- `script-src`: `self unsafe-inline https://www.googletagmanager.com`
- `connect-src`: `self https://www.google-analytics.com https://region1.google-analytics.com https://www.googletagmanager.com https://googleads.g.doubleclick.net https://pagead2.googlesyndication.com`
- `img-src`: `self data: https://i.ytimg.com https://www.google-analytics.com https://www.googletagmanager.com https://googleads.g.doubleclick.net https://www.google.com https://www.google.co.uk`
- `frame-src`: `self https://bid.g.doubleclick.net`

### Environment Injection

The build step supports dynamic Google Tag injection via `GOOGLE_ADS_ID` or `VITE_GOOGLE_ADS_ID` (e.g. `AW-XXXXXXXXXX` or `G-XXXXXXXXXX`). When omitted, the client runtime exposes an active `window.dataLayer` and fallback `gtag` queue, ensuring zero JavaScript runtime failures.

---

## 3. Campaign Structure and Intent Targeting

### Campaign 1: Systems & ML Inference (Search)
- **Target URL**: `https://www.drakestapleton.com/aien?utm_source=google&utm_medium=cpc&utm_campaign=search_aien_inference`
- **Secondary Target**: `https://www.drakestapleton.com/research?utm_source=google&utm_medium=cpc&utm_campaign=search_research_whitepaper`
- **Ad Groups**:
  - `Rust LLM Engine`: "rust llm runtime", "modular max inference", "dgx spark llm", "low latency llm engine"
  - `Sovereign AI Stack`: "local ai inference stack", "private llm infrastructure", "on premise ai agent runtime"
  - `Hardware Performance`: "gb10 benchmarks", "unified memory llm", "zero copy sequence branching"

### Campaign 2: Research & Collaboration (Search / Display)
- **Target URL**: `https://www.drakestapleton.com/interest?utm_source=google&utm_medium=cpc&utm_campaign=search_research_collab`
- **Ad Groups**:
  - `Research Partnerships`: "ai systems research", "autonomous agent architectures", "distributed ai engineering"

### Negative Keywords (Shared List)
- Filter non-technical, consumer, and employment traffic:
  - `course`, `tutorial`, `salary`, `jobs`, `hiring`, `free download`, `chatgpt login`, `resume`

---

## 4. Tracked Conversion Events

| Event Name | Trigger | Target Payload | Purpose |
| :--- | :--- | :--- | :--- |
| `repo_outbound_click` | Click on any GitHub repository link | `repo_name`, `destination_url` | Measures developer intent to inspect source code |
| `generate_lead` | Submission of `/interest` conversation form | `event_category: lead` | Primary high-intent partnership conversion |
| `conversion` | Arrival at `/interest?received=1` | Google Ads conversion action label | Google Ads bidding algorithm optimization signal |

---

## 5. UTM Tracking Standard

All paid campaigns must append standardized query parameters:

```
https://www.drakestapleton.com/aien?utm_source=google&utm_medium=cpc&utm_campaign={campaign_name}&utm_content={ad_id}&utm_term={keyword}
```
