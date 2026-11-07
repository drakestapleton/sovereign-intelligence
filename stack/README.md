# stack/ — the sovereign stack

The front door of this repository (`README.md`, `compiler/`, `repos.tsv`) lists
the projects that moved to Radicle when GitHub switched the organization off.
The **stack** pulls those projects back into one tree that builds and verifies
from a single seed, so that everything here is seeded Omega that can be checked
against the seed.

Everything is compiled by the seed-born compilers in `out/` and run on both
targets: **AArch64** (`out/omc`, under `qemu-aarch64-static` on an x86 host) and
**x86-64** (`out/omc-x86`, native). The whole tree is checked by `sh build.sh`,
which prints `RC=0` only when no step FAILed.

## Layout

| path | what | source of truth |
|---|---|---|
| `out/` | the seed-born Omega toolchain (`omc`, `omc-x86`, `omc.om`) | omega-mv (`stack/omega-mv.lock`) |
| `harness/` | skills for writing and operating seeded Omega | omega-harness (`stack/omega-harness.lock`) |
| `tools/` | stack utilities, written in seeded Omega (e.g. `ledger.om`) | this repo |
| `gpu/` | moved GPU projects (first: `gpu/cuda-crack/`) | each project's `PROVENANCE.md` |
| `stack/STACK.tsv` | what has been moved, from where, to where | this repo |
| `evidence/` | receipts produced by the build | this repo |

## When a project counts as moved

A project from `repos.tsv` counts as **moved into the stack** only when all of:

1. **Imported, verifiable.** Its Omega sources and the data they need are copied
   **byte-for-byte** under the project's stack directory, with a `PROVENANCE.md`
   that pins the project's Radicle RID and head commit, and a `SHA256SUMS` over
   every imported file — in the style of `out/` and `harness/`.
2. **Wired in, on both targets, with teeth.** Its existing checks run as a new
   numbered step in `build.sh`, on AArch64 and x86-64, with a **negative control**
   that fails when it should. A step that needs hardware absent here (for
   cuda-crack, the GB10 GPU) is marked **NOT_RUN** with its reason — never PASS.
3. **Shell rewritten in seeded Omega.** Every shell script the project carried is
   rewritten as a `.om` program compiled by `out/omc`, and each rewrite is backed
   by a **differential test** against the original script's output. If Omega lacks
   a feature the script needs, the gap is recorded as a compiler task in the
   project's `PROVENANCE.md` — it is **not** routed around in another language.
4. **Recorded, green.** `stack/STACK.tsv` records the project's RID, head,
   destination and `moved` status, and `sh build.sh` prints `RC=0` with the
   project's step present.

A project at criteria 1–2 but not yet 3 is `partial`, not `moved`.

## The order

Foundation first, then one project at a time, each fully moved before the next:

1. **Foundation** — the seed toolchain (`out/`) and the harness (`harness/`).
2. **Ledger** — `tools/ledger.om`, so every later step can report Omega vs
   foreign line counts.
3. **Projects** — pulled from `repos.tsv` one at a time. **cuda-crack** is first,
   into `gpu/`.

## Measuring the migration

`tools/ledger.om` counts Omega (`.om`) lines against foreign (shell, C, …) lines
across the tree, so progress toward "everything is seeded Omega" is a number the
build prints, not a claim.
