# Omega flow: everything GitHub did, without GitHub

GitHub did four jobs for this project: it held the repositories, it carried the pull requests and
reviews, it ran the checks (Actions), and it decided what could merge (branch protection). Radicle
already does the first two, peer to peer, with no company in the path. Omega flow does the other
two, as seeded Omega that anyone can rebuild from the 408-byte seed and check.

## What replaces what

| GitHub | Replacement | Status |
|---|---|---|
| Repositories, forks, clones | Radicle repositories, served from my own seed | in use (README) |
| Pull requests | Radicle patches: `git push rad HEAD:refs/patches` | Radicle, in use |
| Review comments | Radicle patch comments and reviews | Radicle; flow posts every gate verdict as a comment |
| Issues | Radicle issues: `rad issue` | Radicle |
| Identity, permissions | Radicle node keys, delegates and their threshold | Radicle |
| Actions (CI) | `tools/flow.om` gates every patch with the default branch's `build.sh` | HOST_TESTED 2026-11-08 |
| Required status checks, branch protection | flow merges only a fast-forward whose exact tree has a pass receipt | HOST_TESTED; Lean model, see below |
| Merge queue | flow merges one patch per cycle, queues the rest, refuses a stale plan | HOST_TESTED |
| Pages | www.aienos.com on my own hardware | in use |
| Discovery | `repos.tsv`, the README's link table, radicle.network | in use |
| A read-only copy for people who look there | the GitHub mirror of this one repository | in use |

## How a cycle works

`sh tools/flow-cycle.sh FLOW REPO DEFAULT RECEIPTS` runs one cycle in three parts. Only the
middle part decides anything, and it is seeded Omega:

1. **Collect** (git plumbing, no decisions): fetch, then list each open patch's head, the head's
   tree, and whether merging it is a fast-forward (`ff`), needs a rebase (`div`) or is already
   in the default branch (`in`).
2. **Plan** (`tools/flow.om`): from those facts and the receipt ledger, give each patch one action,
   `merged`, `merge`, `queued`, `rebase`, `fail`, `gate` or `same`, and write the script `flow.sh`
   that carries them out. The output depends only on the input bytes.
3. **Act** (`flow.sh`): refuse if the default branch moved since step 1; gate each new tree in a
   worktree with the *default branch's* `build.sh`, never the patch's own; append the verdict to
   the ledger and post it on the patch; fast-forward the default branch to at most one patch.

Receipts are keyed by (tree, gate): the git tree of the patch head and the blob id of the gate
that judged it. A tree is gated once, however many patches carry it and however often agents
re-push it, and never again until `build.sh` itself changes. That keeps CI cost proportional to
distinct work, which is what about 20 agents pushing in parallel need, and is the load GitHub's
abuse filters refused.

## What has been checked, and how

| Check | Where | Result, 2026-11-08 |
|---|---|---|
| flow.om reproduces both fixtures byte for byte, AArch64 and native x86-64 | `build.sh` step 12 | PASS |
| refuses 21 malformed inputs and 3 malformed arguments, one `flow:` line each, no output | step 12 | PASS |
| 4096 patches against 16384 receipts | by hand | 0.06 s native x86-64, 0.13 s AArch64 under qemu |
| the whole queue against a real, offline Radicle repository: 5 patches, 3 cycles | `tests/flow/e2e.sh`, step 12b | 7 of 7 PASS with each build (radicle-cli 0.23.0, radicle-node 0.21.1, radicle-remote-helper 0.18.1) |
| a patch that rewrites its own `build.sh` to `exit 0` still fails | e2e cycle 1 | PASS |
| the gate runs without the delegate's `RAD_PASSPHRASE`, `RAD_HOME`, `SSH_AUTH_SOCK` or `HOME`; a planner built without that scrub fails e2e | e2e cycle 1, control by hand | PASS |
| the merged tree has a pass receipt after every cycle; a stale plan refuses to run | e2e | PASS |
| merge only to a passing fast-forward, at most one merge, each tree gated once, a failed tree never merges | `tests/flow/Flow.lean` | written, **not yet machine-checked** |

The Lean file models the decision rules, not the Omega program: the fixtures and the e2e run test
that flow.om follows the model; they do not prove it.

## Next, in order

1. **Run it on the seed.** A timer or a `rad node events` watcher on the seed node runs
   `flow-cycle.sh` for SI with the delegate's key, so a patch is gated within seconds of reaching
   the seed. This is the step that makes GitHub unnecessary for day-to-day work. A gate runs the
   patch's code: flow already keeps the delegate's passphrase, Radicle home and agent socket out of
   its environment, but on the seed it must also run as its own user with no network and no read
   access to the delegate's key file, before it gates anyone else's patches.
2. **Patches from other peers.** e2e today opens patches as the delegate itself. Next: agents as
   separate Radicle peers on two local nodes, with the delegate's node gating and merging.
3. **Signed, shared receipts.** Move the ledger from a local file into a Radicle collaborative
   object signed by the gate node's key, so every seed can trust and reuse a verdict without
   re-running it.
4. **Parallel gates.** Distinct trees are independent, so gate them on all cores, then on several
   machines; content addressing makes the results safe to merge.
5. **No shell glue.** Read refs and objects directly from Omega instead of through `git`, so the
   collector is seeded Omega too.
6. **Releases and triage.** Signed release tags with their gate receipts; issue triage from the
   same receipts.
