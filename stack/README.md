# stack/: every project, moving into one repository

On 7 November 2026 GitHub hid the `aien-dev` organization. The public projects were already on Radicle. That day I recovered all of them from the public seed `rosa.radicle.network`: the 44 repositories whose delegate is my key, `did:key:z6MkfZDue1TbaNFi3ZzcD9uiTeduPLC52ucdFVuLKZwexxhK` (`/api/v1/delegates/<did>/repos`), plus this one. Each was cloned at the head the seed advertised, and every clone's `HEAD` matched it.

From now on there is one repository, this one, and one language, Omega. Each project moves in under the subsystem it belongs to. Its Omega comes in byte for byte, with its provenance. Its gates join `build.sh`, on both targets. Its C, Rust, shell and Python get rewritten in Omega.

## Files

- `STACK.tsv`: the 44 projects: name, Radicle ID, the head recovered on 2026-11-07, subsystem, whether the front door (`compiler/vetted.md`) lists it, visibility, description, and `moved_to`: the directory a moved project now lives in, `-` while it has not moved. 27 are listed by the front door; 17 are public on Radicle but not vetted for the front door, so `compiler/si.om` still does not list them.
- `LEDGER.tsv`: what each project is made of, in lines of Omega and of foreign code, written by `tools/ledger.om` (seeded Omega) from the recovered checkouts. Rebuild it with `tools/ledger-refresh.sh` (its header gives the command). `om_permille` is the share of code lines already in Omega.
- `FORKS.tsv`: every branch in my personal GitHub account whose work is on no Radicle project, 78 in all, with its head, length, date and destination. `radicle` (30): pushed to its project as `fork/<branch>` by `out/fork-push.sh`, which `build.sh` generates with `tools/forkpush.om`; run it where `rad` holds my key. `private` (2): the aienos in-house crypto branches, kept off Radicle and out of this repository. `si` (45): branches of the three repositories imported into `docs/`.

## Subsystems

| Directory | What lives there | Projects |
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

## When a project counts as moved

1. Its Omega sources are under its subsystem directory, byte for byte from the head in `STACK.tsv` (or a later head, named), with a `PROVENANCE.md` and a `SHA256SUMS`, as in `seed/` and `harness/`.
2. Its build and its tests run from `build.sh` on AArch64 and on x86-64, with a negative control that fails when it should.
3. Every line of its C, Rust, shell or Python is either rewritten in Omega, with a test showing the old and the new give the same results, or listed with the Omega that will replace it and the compiler feature that needs (a feature Omega lacks gets built in `seed/omc/omc.om`; it does not get routed around in another language).
4. Its row in `STACK.tsv` says where it went, and its Radicle project's README points here.

## Order

The compiler comes first, because everything else is built with it. After it come the projects that are already mostly Omega, smallest first, and then the large foreign code bases in the order the runtime needs them:

1. compiler: `seed/` and `harness/` are in. Next is omega-mv's own example and test gates, run by `build.sh`.
2. gpu: cuda-crack is in, at `gpu/cuda-crack/`; `build.sh` step 8 runs its checks on both targets. Its shell that is orchestration or network work stays until the Omega pieces it needs move here; `gpu/cuda-crack/PROVENANCE.md` lists them. Next: omega-gpu-driver, omega-blas, CUDApp.
3. train and evidence: aien-train, benchmarks-mv, aien-receipts.
4. runtime and os: aien-sovereign-core-mv, aienux, physics-mv.
5. the Rust services in `agents/`, `protocol/` and `runtime/`, each a rewrite in Omega against its own tests.
