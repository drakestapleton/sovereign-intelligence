# L656: contextual conversation path (issue71)

Functional source: `b33d1cb75c6f4c8ceba734d5d602f563327c2770`.
Public baseline: `e55a667463a170e30603cdc428294abdb1f9f716`.

## Scope and hold

**NO DEPLOYMENT or auto-merge without explicit approval.** The existing Pages workflow deploys main. This branch is local qualification and source publication only, not authorization to merge, dispatch that workflow or deploy. Issue60's private editorial release gate remains intact. No private chapter recovery, new biography, invented media URL, campaign, service/pricing/availability promise or tracker is introduced.

The homepage introduction now has a contextual native `/interest` link. Journey and machine links remain. The existing inquiry page adds three conversation examples, useful-note guidance, existing FormSubmit disclosure and a direct-email alternative. The one original form, action, method, input names, subject and redirect are unchanged. Only an accessible description was added to the message field. Related issue68's external email delivery/error/success acceptance is **not** claimed complete.

## Actual qualification

- Original full native workspace baseline passed. Three new behavior tests failed meaningfully before edits: absent contextual link, absent guidance and absent provider disclosure/fallback. The original form-preservation test already passed and remains unchanged.
- Final full native workspace suite: **13 passed, 0 failed, 0 ignored**. Existing dead-code warnings are preserved, not suppressed.
- Release build and verification passed: **31 rendered routes**. The same captured public facts file was used for baseline and candidate, without replacing the collector or fabricating data.
- Exact output comparison:83 files with identical membership; only `index.html` and `interest/index.html` differ. Other81 files, assets, canonical/social metadata and form payload contract are unchanged. Original story/worlds source bytes preceding the homepage renderer are unchanged.
- Final browser matrix: four states (1440x900 desktop and390x844 phone, each with/without page JavaScript), eight page views and twelve contextual/retained CTA keyboard activations. Actual CSS dimensions and no page-wide horizontal overflow were verified. Every state follows the new CTA with native Enter, verifies the two retained actions, native empty-form refusal, name/email/message/button tab order, labels, description IDs and the direct-email href. No console errors or outside view-time resources were observed.
- The external form handler was blocked during validation-only browser tests; no real message, email or native mail app was invoked. Existing third-party delivery is not proven by these tests.

`browser/final/results.json` and `complete.json` are the canonical final matrix. Initial visual inspection found an oversized contextual heading and inadequate disclosure separation; the final screenshot set follows that focused polish. Earlier screenshots/results are preserved separately as before-polish observations, not mixed into the final count.

`harness-correction.json` records a failed instrumentation assumption: debugger-injected logging can run even with page scripts disabled. The final matrix directly proves actual page-script execution in both modes and uses full native Enter events. Application behavior was not weakened to fix the harness. `browser_matrix.executed.txt` preserves the exact producing script, bound by `browser/final/producer.json`; `browser_matrix.py` adds explicit bindings for the same injected helpers to satisfy static analysis.

## Replay

```sh
cargo test --locked --workspace
AIEN_FACTS_FILE="$PWD/evidence/CONVERSATION-PATH-L656/facts-source.json" \
  cargo run --locked --release --manifest-path crates/site-builder/Cargo.toml -- build dist
cargo run --locked --release --manifest-path crates/site-builder/Cargo.toml -- verify dist
python3 -m http.server 18731 --bind 127.0.0.1 --directory dist
```

Use an owned free loopback port if18731 is occupied. For browser replay, execute the saved matrix through the Browser Use helper environment, with a fresh output directory and the corresponding local URL. It refuses an existing output directory. The provider-blocking and no-deployment constraints remain in force. No inference engine, model, production service or private source is needed.

Independent review and source-only handoff are separate completion gates. L658 carries the deployment hold; this evidence is not a live-site or integrated-acceptance claim.
