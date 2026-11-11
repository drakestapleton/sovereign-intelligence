# compiler/

`si.om` is the front-door generator, written in pure seeded Omega. From the list of projects I chose and the state Radicle gives for each, it writes three things:

- in `../README.md`, the clone line of the lead project between `<!-- si:lead:begin -->` and `<!-- si:lead:end -->`, the link to its `AGENT-PROMPT.md` between `<!-- si:agent:begin -->` and `<!-- si:agent:end -->`, and the project table between `<!-- si:index:begin -->` and `<!-- si:index:end -->`. While the lead project is not in the inventory, the lead and agent blocks say it is being published;
- `../repos.tsv`, the manifest: name, RID, full head commit, tier and description of every listed project;
- `si.sh`, the POSIX sh bootstrap served at `https://www.aienos.com/si`. It is never committed here.

## What is typed and what is generated

Typed by a person, because only a person decides it:

- `inventory.tsv`: which projects the front door lists, one per line, `name TAB rid TAB description`, and the one-line description of each.
- `order.tsv`: `core TAB name` lines give the core projects, in order (the tier); `deny TAB name` lines name projects that are never listed whatever the inventory says; one `lead TAB name` line names the project the README leads with.

Generated, never typed:

- `state.tsv`: what Radicle says about each inventory RID, written by [`../tools/si-state.sh`](../tools/si-state.sh). Its first line is `T` and the UTC time it was read. Then, per RID, `D rid branch`: the default branch named by the project's signed identity (`rad inspect RID --payload`); `V rid visibility`: `rad inspect RID --visibility`; `H rid branch head`: the canonical `refs/heads/<branch>` in Radicle storage; and `P rid head file`: one line per landing receipt whose first line is `RECEIPT PASS head=<head>` (or the older `LANDING RECEIPT PASS head=<head>`). These are the reads the records generator (`rids-gen.sh`) makes on every landing; the head is the canonical ref.

Every inventory project that `order.tsv` does not deny is listed, with the branch, head and receipt count `state.tsv` gives for its RID. Core projects come first, in `order.tsv` order; the rest follow in inventory order. `si` refuses, with exit 1 and nothing written, and names the row, when:

- an inventory line has more than three fields: a typed head, branch or visibility, which only `state.tsv` may give (the five-field inventories this repository used until 2026-11-11 are refused this way);
- a listed project is not public on Radicle, or `state.tsv` has no default branch, no visibility or no head of the default branch for it, or two of one;
- a core project is missing or denied, a name or RID appears twice, a field is malformed, or a `state.tsv` line is not one of the five kinds with well-formed fields, or there is not exactly one `T` line.

The output depends only on the input bytes: no clock (the time printed is `state.tsv`'s `T` line) and no environment, so two runs on the same inputs give identical files.

## What a listed head means (no "vetted")

Until 2026-11-11 the heads here were copied by hand into a "vetted" table, and they went stale: on 2026-11-11, 50 of 83 rows were behind Radicle, and cortex was pinned to a branch it no longer uses. Now a head follows the project's Radicle default branch, so it is the latest commit at the time `state.tsv` was read, and nothing here claims it was reviewed. What is claimed is counted, not asserted: the *Receipts* column of the README table counts the landing receipts recorded for exactly that commit, and a receipt counts only when its file follows the receipts' naming convention, `<name>-<first 12 digits of the head>.txt`, and its first line names that full head. `0` means none is recorded. A receipt says the project's own gates passed on a fresh clone before that commit landed on Radicle main; it is not an independent review.

## Build

`build.sh` builds `si` with this repository's own seed-grown `omc` (step 5). The gate below uses the pinned seeded compiler `omc` from omega-mv (`rad:z6do9WDBhuSnvopDkgFdFr1yWA62`) at commit `f4df82394e35893dcf1354dda69a2fe028d94bc1`, built as `seed/out/omc` with sha256 `3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`. Both run on Linux aarch64.

```sh
sha256sum "$OMC"                       # must print 3ad9f10f…3194
"$OMC" < compiler/si.om > si && chmod +x si
```

## Regenerate

On the machine whose Radicle node holds the projects (it needs `rad`, `git` and `jq`), from the repository root, with the landing receipts directory if you have it:

```sh
sh tools/si-state.sh compiler/inventory.tsv /path/to/landing-receipts > compiler/state.tsv
./si compiler/inventory.tsv compiler/order.tsv compiler/state.tsv README.md repos.tsv si.sh
```

Only the generated blocks of `README.md`, `repos.tsv`, `state.tsv` and `si.sh` change. `build.sh` step 5 checks that the committed `README.md` and `repos.tsv` are exactly what `si` makes from the committed `state.tsv`, so a hand edit or a stale block fails the build, and where Radicle storage is at hand it prints how many listed heads have moved since `state.tsv` was read.

## What is served

`https://www.aienos.com/si` does not wait for a commit here. Each deploy of the website (the SiteHub deploy that publishes www.aienos.com) ends by taking this repository at its Radicle main, running `build.sh`, reading the Radicle state afresh with `tools/si-state.sh`, and serving the `si.sh` that `si` makes from it; a refusal stops that step and leaves the previous script served. So the served script names each project's head as of the last site deploy, and its header says when that was. To check what is served:

```sh
curl -fsSL https://www.aienos.com/si | sed -n 3p    # the Radicle state time it was made from
curl -fsSL https://www.aienos.com/si | sha256sum
```

## Links

`links.om` is the link check, also in pure seeded Omega. Every project lives in its own Radicle repository; this repository only links to it. From the repository root, with the pinned `omc`:

```sh
"$OMC" < compiler/links.om > links && chmod +x links && ./links .
```

It writes nothing. Every `repos.tsv` row must have a name, a valid Radicle ID (`rad:z` then 27 or 28 base58 characters decoding to a 20-byte id), a lowercase 40-digit head and tier `core` or `rest`. Withdrawn crypto names and RIDs remain refused. The root, `compiler/` and `gpu/` entries must be on `links.om`'s existing lists; the rebuild mode adds only the regular root file `layers.tsv` and regular `compiler/rebuild.om`. `.git` is skipped, and subdirectories below those three levels are not walked. The existing regular-root-only `README.zh-CN.md` allowance is unchanged. It prints `links: pass: N link rows, every RID valid; root, compiler/ and gpu/ hold only SI entries`, exit 0, or the first refusal with `links: ` on stderr, exit 1. `build.sh` runs it for both targets with a crypto-RID control.

## Gate

`gate.om` gates `si.om`, `links.om` and `rebuild.om`, in pure seeded Omega. From the repository root, with the pinned `omc` and a new, existing scratch directory `$W`:

```sh
"$OMC" < compiler/gate.om > "$W/gate" && chmod +x "$W/gate" && "$W/gate" "$OMC" "$W"
```

It checks the supplied compiler by SHA-256 first; another compiler or none prints `SI NOT_RUN`, exit 3. The original 35 cases remain: byte-identical regeneration; typed head, unknown RID, historical typed inventory and private-state refusals; stale README regeneration; current and minimal link trees; every existing malformed name, RID, head, tier and header; forbidden vendored files, directories and links; and all seven translation-path controls. Mutated inputs must differ from the originals and planted entries must exist. The seven rebuild cases add a real Git fixture with two byte-identical rebuilt artifacts, a changed-artifact mutant, command exit 7 (must be `FAIL` with rc 7), an off-chip hardware mutant even with `hw=yes`, a deleted layer row, no documented command, and macOS-only. The first two layers being `NOT_RUN` must make the run exit 1. The complete gate prints `SI pass=42 fail=0`, exit 0. `DT_UNKNOWN` refusal remains without a fixture on ext4/tmpfs, which never return it.

## Rebuild mode

`si` embeds `compiler/rebuild.om`, `layers.tsv` and its generated `repos.tsv` in `si.sh`. With `SI_REBUILD=1`, after the normal fetch it writes them under `SI_DIR/.si-check`, builds the checker with the fetched `omega-mv/seed/out/omc`, then executes it. Without that opt-in, the fetch/check behavior and exit codes are unchanged. The checker is a Linux program; the one-command bootstrap rebuild mode requires AArch64 Linux.

For an already fetched tree, from this repository:

```sh
"$OMC" < compiler/rebuild.om > out/rebuild && chmod +x out/rebuild
out/rebuild check layers.tsv
mkdir -p /path/to/results
out/rebuild run layers.tsv repos.tsv /path/to/checkouts /path/to/results
```

Each table row is `layer TAB repo TAB needs TAB command TAB artifact TAB compare`. The initial `layers TAB N` declaration requires every layer 1..N to have a row, in order; deleting a layer's only row is refused before executing anything. Separate host, doctor and hardware checks, and the forge and site, have their own rows. No code lists the layers or their commands.

`needs` is `any`, `aarch64-linux`, `macos`, or `pci:VVVV:DDDD`. `macos` is always `NOT_RUN` here. A PCI row requires both an actual matching vendor/device in Linux sysfs and the explicit standalone `hw=yes` option. The generated bootstrap does not supply that option. Hardware detection reads sysfs only; no GPU device is opened by the checker. Even on-chip, host rows do not qualify hardware.

The command is run in the manifest checkout, with stdin `/dev/null` and stdout/stderr in `layer-L-R.log`. The output binds the row to its manifest commit, full command, exit code and artifact SHA-256. `compare` is a file at that commit: `git cat-file` retrieves its immutable bytes and the checker compares SHA-256, so a build cannot overwrite the reference. `-` means no comparable published artifact is supplied; passing that row claims only the repository's own build/check success, not byte reproduction of a release. A missing manifest project is `NOT_RUN`, not silently fetched or added. A nonzero command is `FAIL`, including exits that the called gate labels `NOT_RUN`.

The table's commands were read from each project's Radicle source documentation on 2026-11-11:

| Layer | Documented source and artifact |
|---|---|
| Seed | omega-mv `AGENTS.md`, “Build”; `sh seed/omega-from-seed.sh` grows `build/seed/birth/stage3`, compared with committed `seed/out/omc` |
| Self-check | omega-mv `seed/README.md`, “Rung R5”, and the self-compile invocation in `seed/omega-from-seed.sh`; compile `seed/omc/omc.om` with the rebuilt compiler and compare again with committed `seed/out/omc` |
| GPU toolchain | CUDApp `README.md` build section and `AGENTS.md` host/GPU commands: `make`, `make test`, `make doctor`; hardware recipe `make hello-gpu`, `make hello-gpu-control`, `make zero-cuda-gate` |
| Runtime | aien-sovereign-core-mv `README.md`, “Build and test”: `scripts/repro-build.sh -p aien-cli` and `cargo test --workspace -- --test-threads=1` |
| Own model tools | aien-train `README.md`, CPU reproduction, and `tests/omegallm/build.sh`: pinned CPU compiler, `sh tests/omegallm/build.sh`, then `ollm adamck`; `OUT` keeps its artifact in this clone |
| Forge/site | interplane-forge `README.md`: `./run.sh build`, `bash server/tests/counts.sh` (requires its documented base and compiler); interplane.io `README.md`, “Build”: its pinned `scripts/build-native.sh`, `site build`, `site verify` |
| App | Hop `README.md` and `Omega/README.md`: `sh Omega/tests/check-mac.sh`, macOS arm64 only |

The train and site rows retrieve their own documented historical compiler pins from the fetched omega-mv Git history, never repin them to the newest compiler. Runtime and CUDApp commands still use their documented Rust/C build dependencies; this orchestrator does not claim those layers are all Omega. The fetched projects' own compiler/referee provenance is unchanged.

No layer lacks a documented command in that source snapshot. The current SI inventory does not include `interplane-forge` or `hop`; their rows therefore report `NOT_RUN not in repos.tsv`. This change intentionally adds neither project to the inventory.

For a shared host, `SI_REBUILD_WRAP` (or standalone `wrap=WORDS`) prefixes **each row separately**, so each heavy command can acquire one CPU-pool ticket. Words split at spaces, so use paths without spaces. Example, with the operator's chosen lock and cores:

```sh
SI_REBUILD=1 SI_REBUILD_WRAP="flock /path/to/pool.lock timeout --kill-after=5 590 taskset -c 4,5" sh out/si.sh
```

The lock has no outer timeout. An inner timeout releases the ticket before ten minutes and is a command failure, not a pass or a skipped layer. On a host sharing its GPU with a live model, a device-isolated wrapper can additionally hide device nodes (`bwrap --dev-bind / / --dev /dev --proc /proc --`); the run must report that environment, and the doctor can fail for those hidden nodes. Neither a source landing nor this command publishes `/si`: publication needs the website's separately authorized build/release gates and a fresh Radicle-state generation followed by a served-script hash check.

