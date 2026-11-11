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

Until 2026-11-11 the heads here were copied by hand into a "vetted" table, and they went stale: on 2026-11-11, 51 of 83 rows were behind Radicle, and cortex was pinned to a branch it no longer uses. Now a head follows the project's Radicle default branch, so it is the latest commit at the time `state.tsv` was read, and nothing here claims it was reviewed. What is claimed is counted, not asserted: the *Receipts* column of the README table counts the landing receipts recorded for exactly that commit, and a receipt counts only when its file follows the receipts' naming convention, `<name>-<first 12 digits of the head>.txt`, and its first line names that full head. `0` means none is recorded. A receipt says the project's own gates passed on a fresh clone before that commit landed on Radicle main; it is not an independent review.

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

It writes nothing and checks two things. Every row of `repos.tsv` is a name, a valid Radicle ID (`rad:z` then 27 or 28 base58 characters that decode to a 20-byte id), a 40-digit head and a tier of `core` or `rest`; the withdrawn crypto projects (any name containing `pearl` or `crypto`, in any case, and any RID starting `rad:z2ft64`) are refused. And no project source is copied in: the entries of the root, `compiler/` and `gpu/` must be on the fixed lists in `links.om` (the root's files and the directories the GitHub line already had, `gpu/cuda-crack` only, and the eight files of `compiler/`: `README.md`, `si.om`, `gate.om`, `links.om`, `inventory.tsv`, `order.tsv`, `state.tsv` and `gate-3c37e6fb.tsv`), `.git` skipped. One translation is allowed: `README.zh-CN.md`, the Simplified Chinese README, as a regular file at the root, with exactly that name (Drake, 2026-11-11, "approved for all", answering "sovereign-intelligence: allow README.zh-CN.md at the root in the links.om allow-list"). No other language, no other spelling or case, no symbolic link or directory of that name, and no copy of it in `compiler/` or `gpu/`. Directories below those three levels, such as `docs/` and `tools/`, are not walked. It prints `links: pass: N link rows, every RID valid; root, compiler/ and gpu/ hold only SI entries` and exits 0, or `links: ` and the first refusal on stderr and exits 1. `build.sh` step 5b runs it on both targets, with a crypto-RID control.

## Gate

`gate.om` is the gate of `si.om` and `links.om`, also in pure seeded Omega. From the repository root, with the pinned `omc` and an existing scratch directory `$W`:

```sh
"$OMC" < compiler/gate.om > "$W/gate" && chmod +x "$W/gate" && "$W/gate" "$OMC" "$W"
```

It first checks the `omc` it is given by its sha256: any other `omc`, or none, prints `SI NOT_RUN` and exits 3. It then builds `si` from `si.om` and `links` from `links.om` and checks 35 cases. For `si`: the committed inputs regenerate `README.md` and `repos.tsv` byte-identically. Four refusals, each with exit 1, the matching message, the README unchanged and nothing written: a typed head (the first inventory row given a fourth field of 40 hex digits after its RID), an inventory with one RID character changed (no Radicle state for it), the old five-field inventory of commit `3c37e6fb` (`gate-3c37e6fb.tsv`, refused as typed), and a private repository (the committed `state.tsv` with its first `V` line, the first inventory project's, made `private`). And a stale block: a `README.md` whose first generated head is one digit off regenerates to the committed `README.md` and `repos.tsv`, which is the comparison `build.sh` step 5 fails on. For `links`: the repository root passes; a `repos.tsv` whose first RID ends in `0` (not base58), one whose first RID starts `rad:z2ft64`, and the committed `repos.tsv` beside a planted project directory `omega-mv/main.om` are each refused with exit 1 and the matching message. A minimal tree (the committed `repos.tsv` and `compiler/` with its eight file names, empty) passes, and 17 one-change variants of it are each refused with their own message: link-row names `Omega-Pearl`, `aien-CRYPTO-mv` and `../x`; heads with capitals, with a `g` and of 41 digits; tier `Core`; a 29-character RID and `rad:z` then 28 `z` (more than 20 bytes); a broken header and a header with no rows; and the planted entries `compiler/evil.om`, `compiler/si.om` as a symbolic link, a root symbolic link, a root file, a root directory and `gpu/x.bin`. The translation has seven more: a root `README.zh-CN.md` (an empty regular file) passes, and `compiler/README.zh-CN.md`, root `README.zh-TW.md`, `README.fr.md` and `readme.zh-cn.md`, and a root `README.zh-CN.md` that is a symbolic link to `repos.tsv` or a directory are each refused as not an SI file. Each mutated input must have a sha256 different from the committed file's (each planted entry must exist), so a mutation that did not apply counts as a failure. It prints `SI pass=35 fail=0` and exits 0. One `links` path has no case: a directory entry of unknown type (`DT_UNKNOWN`), which `links` refuses but ext4 and tmpfs never return.
