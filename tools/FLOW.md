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
| Issues | Radicle issues: `rad issue`, or the forge's web form for people without Radicle | Radicle; the form is HOST_TESTED ([`FORGE.md`](FORGE.md)) |
| Identity, permissions | Radicle node keys, delegates and their threshold | Radicle |
| Actions (CI) | `tools/flow.om` gates every patch with the default branch's `build.sh` | HOST_TESTED 2026-11-08 |
| Required status checks, branch protection | flow merges only a fast-forward whose exact tree has a pass receipt | HOST_TESTED; Lean model, see below |
| Merge queue | flow merges one patch per cycle, queues the rest, refuses a stale plan | HOST_TESTED |
| Pages | www.aienos.com on my own hardware | in use |
| Insights and traffic: clones, cloners | the Omega forge counts every pull my seed serves, per project and day, public ([`FORGE.md`](FORGE.md)) | HOST_TESTED, not deployed |
| Project, issue and pull request pages | the forge's static pages, built from Radicle's own data | HOST_TESTED, not deployed |
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
   worktree with the *default branch's* `build.sh`, never the patch's own, inside a bubblewrap
   sandbox (no network; `/home`, `/root`, `/run`, `/tmp` and the Radicle home hidden; a clean
   environment); append the verdict to the ledger and post it on the patch; fast-forward the
   default branch to at most one patch.

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
| a gate in the sandbox sees no network, no Radicle key directory and none of the delegate's environment; unsandboxed (`FLOW_SANDBOX=none`), e2e fails | e2e cycle 1, control by hand | PASS |
| a sandbox that cannot start stops the step with bwrap's error, never records a fail; SI's own `build.sh` passes inside the sandbox, with step 12b NOT_RUN there | `flow.sh` probe; by hand | PASS, `RC=0` |
| the installer refuses a bad ID, a foreign working copy and an identity that is not a delegate; installs; its units pass `systemd-analyze --user verify` with no warning; two cycles never overlap; reinstalling keeps the ledger | `tests/flow/install.sh`, step 12b | 5 of 5 PASS |
| a rehearsal of the seed: SI as a throwaway Radicle repository, this branch as a patch, installed with the seed build; gated in the sandbox by `main`'s `build.sh`, pass, merged; a second patch gated by the merged `build.sh` (now with step 12), pass, merged | by hand, x86-64 | PASS; a gate of SI takes about 14 s there |
| the merged tree has a pass receipt after every cycle; a stale plan refuses to run | e2e | PASS |
| merge only to a passing fast-forward, at most one merge, each tree gated once, a failed tree never merges | `tests/flow/Flow.lean` | Lean 4.15.0 accepts all six theorems; `#print axioms`: `propext`, `Quot.sound` only, no `sorry` (commit `8f9cce0`); `build.sh` step 12c re-checks it, with the axioms of all 13 theorems, when `lean` is installed |

The Lean file models the decision rules, not the Omega program: the fixtures and the e2e run test
that flow.om follows the model; they do not prove it.

## Deploy on a seed

On the seed, as the user whose Radicle key is a delegate of the repository, with the node running
(`rad node start`) and the repository seeded there:

```sh
sudo apt-get install -y bubblewrap
cd sovereign-intelligence            # a checkout that has tools/flow-install.sh
sh tools/flow-install.sh --once rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj
sudo loginctl enable-linger "$USER"  # keep the timer running after logout
journalctl --user -u flow-z2JJz4RDfZZxKGBLn6UhmW5p9VJQj.service -f
```

The installer builds the planner from the seed (`build.sh` must end `RC=0`), checks the working
copy out of the node's storage, and enables `flow-ID.timer`: a cycle 15 s after the last one ended.
Each cycle's facts and plan stay in `~/.local/share/flow/ID/last`, the ledger in
`~/.local/share/flow/ID/receipts.tsv`. If the key has a passphrase, put `RAD_PASSPHRASE=...` in
`~/.local/share/flow/ID/secret.env` (mode 0600); the service reads it and no gate sees it. If the
installer says bwrap cannot make a sandbox, the kernel forbids unprivileged user namespaces (Ubuntu
24.04 restricts them through AppArmor); allow them for bwrap before going on, because flow never
gates other people's patches without the sandbox. Run the installer again to upgrade.

## Next, in order

1. **Turn it on for SI.** Run the commands above on the seed. Until then the queue is tested and
   rehearsed, not deployed.
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
