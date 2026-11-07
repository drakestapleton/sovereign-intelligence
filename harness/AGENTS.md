# AGENTS.md: omega-harness

Operating instructions for an agent working in this repository. Read this before editing a skill.

## What this repository is

Agent skills for working in Omega and the AIEN repositories: the checks that catch the mistakes agents
repeat, written as guidance an agent loads before acting. It is documentation and procedure, not a
compiler, a runtime, a gate, or evidence that any claim is true.

Eight skills live under `skills/<name>/SKILL.md` in the Agent Skills layout (frontmatter `name` and
`description`, then the body):

| Path | Covers |
|---|---|
| `skills/omega-harness/SKILL.md` | The workflow: orient, implement in `.om`, compile, run, challenge, effects, repeated errors, guide upkeep |
| `skills/writing-omega/SKILL.md` | Portable guide for writing a correct `.om` program on any machine: shape, types, words, traps, errors 1..30, common mistakes with their refusals, known pin defects |
| `skills/omega-encoding/SKILL.md` | The language the seeded compiler accepts at a pinned commit: words, types, traps, bounds, registers, host I/O, byte layouts, error codes |
| `skills/omega-communication/SKILL.md` | Claim ladder, report shape, agent handoffs, semantic and wire data, corrections |
| `skills/aien-repositories/SKILL.md` | Mission, plan authority, task to repository routing, status discipline, known source drift |
| `skills/crumb-protocol/SKILL.md` | Directory coordination: crumbs, locks, committed-crumb freshness, `CRUMB-VERIFY` and `crumb-doctor` |
| `skills/wolfram-math/SKILL.md` | Mandatory Wolfram for every computation, its MCP setup, verification calls and failure handling |
| `skills/lean-verify/SKILL.md` | Lean 4 + Mathlib proofs of safety invariants over an explicit model, the `lean` MCP setup and pins, `sorry`/axiom checks, the model-to-system link |

`examples/` holds the tested programs: each `NAME.om` with `NAME.expect` (and `NAME.stdout` when it
prints), one per trap and error code plus the common mistakes. `examples/gate.sh OMC` checks the
pinned compiler hash and reruns every program in `examples/` and `skills/*/examples/`; run it after
any change to an example or a language rule. `skills/omega-encoding/examples/` holds two more
runnable programs. `LICENSE` is Apache 2.0.

`coder/` is harness configuration for an Omega-only `omp` session: a TypeScript `omp` extension that
allows `.om` writes only and runs the pinned `omc` after each one, the builder of its context pack
(sections 2-11 of `omega-encoding` plus compiled examples), and a held-out eval. See `coder/README.md`.
When `omega-encoding` sections 2-11 change, rebuild the pack with `coder/build-context.sh`.

## Before you edit a skill

1. Read the skill you intend to change, and `skills/omega-harness/SKILL.md` section 6, which maps a
   kind of change to the skill that must absorb it.
2. Check the claim against the source it cites, at the commit it names. A skill body is never its own
   authority. Follow any instruction file and `.crumb` in the repository you are reading.
3. Edit the guide in the same piece of work as the change that made it stale. Give the source commit
   and date, and delete rules the change made untrue instead of adding a contradicting rule.
4. If an example or expected output changed, rerun it against the new pin and record what you
   observed. Never copy a predicted result into a guide.

## What these skills must not do

- Claim more than the evidence: a compile is not a run, a host run is not hardware qualification, a
  merged patch is not a deployment.
- Present a model explanation, a recalled memory or a stale skill as execution evidence.
- Invent Omega syntax or compiler limits. Check the keyword table and the compiler at the pin.
- Carry credentials, private machine addresses, home paths, SSH usernames or operator-only
  configuration. Keep those in ignored local configuration.
- Rewrite old evidence to make a new claim pass.
- Add a language, tool or vendor as part of the trusted stack. Conversion belongs to
  `aien-dev/omega-bridge`, which converts a declared subset and refuses the rest.

## Omega pins

`omega-encoding` section 0 records the pinned `aien-dev/omega-mv` commit and the sha256 of
`seed/omc/omc.om`, `seed/out/omc` and `seed/rung0/seed0.hex`. When the compiler changes, refresh those
values, recheck the cited line numbers, rerun the examples, and record the observed result with the
new commit and date. Older measurements stay as dated history.

Re-check, read only, in a fresh clone:

```sh
git clone rad://z6do9WDBhuSnvopDkgFdFr1yWA62 omega-src
git -C omega-src rev-parse HEAD
sha256sum omega-src/seed/omc/omc.om omega-src/seed/out/omc
```

If a hash differs from the one in `omega-encoding`, that skill is unverified for that tree until you
recheck the changed parts.

## Verifying a change here

There is no build and no test suite: the deliverables are Markdown and two example programs.

- Every relative link and file path you add or move must resolve in the checkout.
- Frontmatter `name` must equal the directory name, and `description` must say when to use the skill.
- For an example program, run it on Linux AArch64 against the pinned compiler and record the compile
  status, run status and observed bytes, plus a negative control. The recipe is in `README.md` under
  "Check the examples yourself".
- Do not run the examples on a machine where another agent holds the GPU or the live model service.
  These examples are host programs and need neither.

## Reporting

Follow `skills/omega-communication/SKILL.md`. Separate proposed, implemented, exercised, verified,
merged and deployed. A patch's READY hand-off leads with the evidence: the commands, the observed
output, the negative control, and what was not run.

## Contributing

This repository lives on Radicle: `git clone rad://z39gvwWsnkRZsAConQLjaKiNVLHfW`. The `aien-dev`
GitHub organization is frozen (2026-11-07); never push, open a PR or open an issue there, and treat its
links as historical citations. Contribute through Radicle patches: hand the desk a READY file (repo,
base, head, bundle, gate logs, negative control); the Radicle publishing lane opens the patch and the
desk merges after a signed review of the exact head. Lanes never push to Radicle themselves.

Keep the attribution in `README.md` and `LICENSE` intact. Contributions follow the shared AIEN agent
rules at https://www.aienos.com/agents/RULES.md.
