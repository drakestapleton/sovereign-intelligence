# Omega forge: what GitHub showed about a project, served from my own seed

GitHub showed people a project's page, its issues and pull requests, and showed me how often it
was cloned. Radicle already holds the code, the issues and the patches, signed by their authors
and copied peer to peer. The Omega forge adds the rest, as seeded Omega that anyone can rebuild
from the 408-byte seed: a public count of every pull my seed serves, a web page for every
project, issue and patch, and a way for people without Radicle to open issues and comment.
[`FLOW.md`](FLOW.md) covers the other half: gating and merging patches.

## What is different from GitHub

| GitHub | Omega forge |
|---|---|
| Clone counts: 14 days, visible to the owner only, computed by GitHub | Every pull my seed served, HTTPS and Radicle alike, per day and for all time, public on every page and in `stats.tsv`. Recomputable by anyone holding the logs: [`tally.om`](tally.om) is a pure function of their bytes |
| Traffic data kept by a company | Only counts are kept. `tally.om` writes no address and no node id, and the logs never leave the machine |
| Issues and pull requests live in GitHub's database | They are Radicle collaborative objects, signed by whoever wrote them and copied to every seed. The pages only show them, and each names the `rad` command that shows the same object |
| A web account is needed to open an issue | A plain form, no account and no script. The seed's node publishes the post as a signed Radicle issue or comment, labelled `web`, with the receipt id the sender was shown |
| CI badge from Actions | The gate verdict the Omega merge queue posted on the patch |
| Pages full of scripts, trackers and outside fonts | Static pages: no script, no cookie, no outside request. The pages are rebuilt from scratch every cycle and switched in atomically |
| Stars | Seeding nodes: the Radicle nodes my seed knows to be copying the project, itself included |

## The three programs, and the glue

| Program | Job | Input | Output |
|---|---|---|---|
| [`tally.om`](tally.om) | count pulls | the seed's nginx access log and radicle-node log, as a stream; the ledger so far | the new ledger: per (project, UTC day) HTTPS pulls, distinct hosts, Radicle pulls, distinct peers |
| [`forge.om`](forge.om) | write the site | the facts (`rad` output for every published project), the ledger, today's date | `index.html` ranked by pulls in 14 days, a page per project, issue and patch, and `stats.tsv` |
| [`intake.om`](intake.om) | take posts from the web | HTTP form posts on 127.0.0.1, behind the web server | one spool record per accepted post, with a receipt id |
| [`forge-cycle.sh`](forge-cycle.sh) | glue, no decisions | the three programs, the list of published projects, the forge's state directory, the logs | publishes the spool with `rad`, runs `tally`, collects the facts with `rad` and git plumbing, runs `forge` into a new directory, then switches the served link to it |

A pull counts once per fetch: `GET /rad/ZID.git/info/refs?service=git-upload-pack` answered 200
in the nginx log, or `Peer NID fetched RID from us successfully` in the radicle-node log. A day
seen in the logs replaces that day's ledger row, so feeding the same logs again counts nothing
twice (proved in [`tests/forge/Forge.lean`](../tests/forge/Forge.lean), `tally_idem`).

Every text byte on a page comes from Radicle data through one escape. `& < > " '` become entities,
and a control byte other than LF and TAB becomes U+FFFD. `escape_safe`, `escape_tokens` and
`unescape_escape` in `Forge.lean` prove the output holds no markup character and loses nothing
else. The independent oracle (Python's JSON and HTML parsers, [`tests/forge/oracle.py`](../tests/forge/oracle.py))
checks the pages themselves against what the facts say.

## What has been checked

| Check | Where | Result, 2026-11-08 |
|---|---|---|
| tally: a 67-line mixed log counted by hand and by an independent awk oracle, byte for byte; idempotent; no host or node id in its output; 32 malformed ledgers refused; bounds of 262,144 rows, 4,096 (project, day) pairs and 262,144 distinct hosts | `build.sh` step 13, `tests/forge/tally.sh` | 9 of 9 PASS, AArch64 under qemu-aarch64 8.2.2 and native x86-64 |
| forge: a real Radicle repository's facts plus edge cases (escapes, surrogates, control bytes, HTML, leap days, the year 2100) give the expected 12 files; the oracle accepts them and refuses a planted `<script>` and a changed count; the same facts in reverse order give the same site; 37 malformed inputs refused, each with its own message, writing nothing | step 13, `tests/forge/forge.sh` | 6 of 6 PASS, both targets, the same bytes from both |
| intake: valid issues, comments, UTF-8 and CR LF posts give byte-exact records; every 400 rule, 404, 405, 411, 413, 503 (spool full) and 408 (a client stalled for 10 s, the next one served); one log line per request, no address | step 13, `tests/forge/intake.sh` | 9 of 9 PASS, both targets. By hand, x86-64: a handler made to trap is logged as `500 handler stopped` and the next post gets 200; servers built without the honeypot check or with surrogates accepted fail the gate |
| the Lean 4 model: escaping safe, tokenised and lossless; ledger merge idempotent and unseen days untouched; distinct counts at most totals; the spool never above 4,096 | step 13, `tests/forge/lean.sh` | 16 theorems, machine-checked with Lean 4 v4.15.0, on propext, Classical.choice and Quot.sound only; a mutant that lets `'` through fails |
| a whole cycle on real Radicle nodes, offline: a second node's `rad clone` is counted from the seed's own log; two web posts, each starting with `-`, become signed Radicle objects; 3 HTTPS pulls from 2 hosts and 1 Radicle pull from 1 peer reach the site; a second cycle with the same logs changes no count; a spool record for a project no longer published is set aside in `spool/failed` with its reason while the cycle goes on | step 13b, `tests/forge/e2e.sh` | 6 of 6 PASS with each build; rad 1.10.3 |
| scale: 1,024 projects, 10,240 issues and a 373,760-row ledger give 11,266 pages | by hand | 3.0 s native x86-64, 3.9 s AArch64 under qemu, the same bytes |
| scale: 1,000,000 log lines, 193 MB | by hand | 1.6 s native x86-64 |

## Running it on the seed (not done yet)

This is the order to deploy in. None of it has run on the hub, so the forge is HOST_TESTED, not
deployed.

1. Build `out/tally-a64`, `out/forge-a64` and `out/intake-a64` with `sh build.sh` (the hub is
   AArch64), and copy them to the hub.
2. Write `ALLOW`: the RIDs of the vetted public rows of the Radicle registry, one per line. Never
   a private, withdrawn or crypto repository.
3. Run `intake PORT ALLOW STATE/spool` as its own user, under `aien-supervise` (no new systemd
   unit). It needs nothing but the spool directory: no key, no git, no Radicle.
4. In nginx, keep the default `combined` log format and add:
   ```nginx
   # http block
   limit_req_zone $binary_remote_addr zone=forge:1m rate=6r/m;
   # server block
   location = /forge/intake {
     limit_req zone=forge burst=5 nodelay;
     client_max_body_size 64k;
     proxy_pass http://127.0.0.1:PORT;
   }
   location /forge/ { alias /var/www/forge/; }
   ```
   where `/var/www/forge` is the WEB symlink of step 5.
5. Every few minutes, as the delegate (its key is needed to publish the spool), run
   `sh tools/forge-cycle.sh forge tally ALLOW STATE /var/www/forge /var/log/nginx/access.log NODELOG`.
   NODELOG holds radicle-node's raw lines, each starting with its own timestamp (for a node under
   journald, `journalctl -u radicle-node -o cat` into a file). Check one line by hand first.
   Then link `/forge/` from www.aienos.com.

## Next

1. **Deploy** as above, then watch the counts against the raw logs for a week.
2. **Patches from the web.** Today people without Radicle can open issues and comment. A patch
   still needs `rad`, because a patch is signed code. Next is a form that takes a public git URL
   and branch, turned into a patch only after the gate passes.
3. **Read COBs directly.** The collector asks `rad cob show` for each object. Reading the
   collaborative objects from the git objects in Omega would remove the last shell decisions.
4. **Signed counts.** Publish each day's ledger rows as a Radicle object signed by the seed, so
   other seeds can add their pulls to the same totals.
