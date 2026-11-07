# stack/: my projects, each in its own Radicle repository

On 7 November 2026 GitHub hid the `aien-dev` organization. The public projects were already on Radicle. That day I recovered all of them from the public seed `rosa.radicle.network`: the 44 repositories whose delegate is my key, `did:key:z6MkfZDue1TbaNFi3ZzcD9uiTeduPLC52ucdFVuLKZwexxhK` (`/api/v1/delegates/<did>/repos`), plus this one. Each was cloned at the head the seed advertised, and every clone's `HEAD` matched it.

This directory is a ledger. Each project lives in its own Radicle repository and stays there; this repository links to them (the front door's project table and `repos.tsv`) and does not hold them. Here it lists them, measures what each is written in, and records the branches of my personal forks.

## Files

- `STACK.tsv`: the 44 projects: name, Radicle ID, the head recovered on 2026-11-07, subsystem, whether the front door (`compiler/vetted.md`) lists it, visibility, description, and `moved_to`. `moved_to` is historical: it comes from an earlier plan to move every project into this repository, which was dropped. Its two non-`-` values, `harness/` for omega-harness and `gpu/cuda-crack/` for cuda-crack, name copies taken for the gate; neither project moved, and each one's home is its own Radicle repository. 27 are listed by the front door; 17 are public on Radicle but not vetted for the front door, so `compiler/si.om` still does not list them.
- `LEDGER.tsv`: what each project is made of, in lines of Omega and of foreign code, written by `tools/ledger.om` (seeded Omega) from the recovered checkouts. Rebuild it with `tools/ledger-refresh.sh` (its header gives the command). `om_permille` is the share of code lines already in Omega.
- `FORKS.tsv`: every branch in my personal GitHub account whose work is on no Radicle project, except branches that stay local, 75 in all, with its head, length, date and destination. `radicle` (30): pushed to its project as `fork/<branch>` by `out/fork-push.sh`, which `build.sh` generates with `tools/forkpush.om`; run it where `rad` holds my key. `si` (45): branches of the three repositories imported into `docs/`. Branches that stay local are not listed at all; `tools/forkpush.om` still accepts a `private` row (destination `-`) and writes it only as a comment, but this manifest has none.

## Subsystems

The `subsystem` column of `STACK.tsv` groups the projects. Of the directories below, only `seed/`, `compiler/`, `harness/`, `gpu/`, `evidence/` and `docs/` exist in this repository, and they hold this repository's own files and gate copies, not the projects.

| Subsystem | What it covers | Projects |
|---|---|---|
| `seed/`, `compiler/`, `harness/` | the language, its compiler grown from the seed, the agent harness | omega-mv, omega-harness, omega-mcp, omega-bridge |
| `gpu/` | GPU machine code without the CUDA toolkit | CUDApp, cuda-crack, omega-gpu-driver, omega-blas, gpu-head-to-head |
| `os/` | kernel, machine realization, device adapters, supervision | aienux, physics-mv, spark-adapters, spark-supervisor, spark-debugger |
| `runtime/` | inference and agent runtime | aien, aien-sovereign-core-mv, aien-sovereign-core, aegis-runtime-mv, openclaw-rs, cortex-rs, spark-dream, aien-rig |
| `train/` | training | aien-train |
| `protocol/` | wire protocols and specifications | aien-protocols-mv, interplane-mv, spark-rsi |
| `agents/` | coordination, ledgers, agent networks | synapse, crumb-spec, spark-crumbs, spark-hive, mobhub, open-humanity, rad-id-sync, harvester, spark-inquisitor, spark-rsi-mv |
| `evidence/` | receipts and benchmarks | aien-receipts, benchmarks-mv, aien-harness |
| `docs/` | architecture, websites, profile | aien-architecture-mv, aienos.com, interplane.io, .github, aienix |

## Copies kept for the gate

Nothing moves into this repository. It keeps a byte-for-byte copy of another project only where its own gate needs one, each with a `PROVENANCE.md`: `seed/` (omega-mv's compiler sources, from `seed0.hex` to `omc/omc.om`), `harness/` (omega-harness, whose worked examples `build.sh` step 7 runs) and `gpu/cuda-crack/` (cuda-crack's tables, Omega tools and chip receipts, checked by `build.sh` step 8). `docs/` holds writing and sites from my personal account that have no Radicle project.
