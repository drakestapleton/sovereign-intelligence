# compiler/

`si.om` is the front-door generator, written in pure seeded Omega. From my Radicle node's inventory, filtered by the vetted public table, it writes three things:

- in `../README.md`, the clone line of the lead project between `<!-- si:lead:begin -->` and `<!-- si:lead:end -->`, the link to its `AGENT-PROMPT.md` between `<!-- si:agent:begin -->` and `<!-- si:agent:end -->`, and the project table between `<!-- si:index:begin -->` and `<!-- si:index:end -->`. While the lead project is not in the inventory, the lead and agent blocks say it is being published;
- `../repos.tsv`, the manifest: name, RID, full head commit, tier and description of every public project;
- `si.sh`, the POSIX sh bootstrap served at `https://www.aienos.com/si`. It is never committed here.

Inputs, all data:

- `vetted.md`: the vetted public table, one Markdown row per project, `| name | RID | branch | head |`. It is copied from RadPublish's `RIDS.md` by the command below and is the single source of what may be listed.
- `inventory.tsv`: one project per line, `name TAB rid TAB visibility TAB head TAB description`, exported from the node for the vetted RIDs only, by the command below.
- `order.tsv`: hand-kept. `core TAB name` lines give the core projects, in order. `deny TAB name` lines name projects that are never listed. One `lead TAB name` line names the project the README leads with.

A project is listed only when its name and RID are both on a `vetted.md` row and the node calls it public. Every private or denied project is never emitted. Core projects come first, in `order.tsv` order; the rest follow in inventory order. `si` refuses, with exit 1 and nothing written, when a core project is missing, unvetted or not public, a name or RID appears twice, a field is malformed, or an inventory row is not fresh: its RID has no `vetted.md` row on branch `main`, or its head is not that row's head. The refusal names the row, so a stale export or a stale `vetted.md` cannot regenerate the front door. The output depends only on the input bytes: no clock and no environment, so two runs give identical files.

## Build

Use the pinned seeded compiler `omc` from omega-mv (`rad:z6do9WDBhuSnvopDkgFdFr1yWA62`) at commit `f4df82394e35893dcf1354dda69a2fe028d94bc1`, built as `seed/out/omc` with sha256 `3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`. It runs on Linux aarch64.

```sh
sha256sum "$OMC"                       # must print 3ad9f10f…3194
"$OMC" < compiler/si.om > si && chmod +x si
```

## Export the vetted table and the inventory

Run on the machine whose Radicle node holds the projects, from the repository root (it needs `rad`, `git` and `jq`). The first command copies the public rows of `RIDS.md`, stopping at its first `## ` section (WITHDRAWN, Extra branches or anything later). `si` applies the same rule to `VETTED`, so a well-formed row under any `## ` section is never listed:

```sh
{ printf '# Vetted public projects\n\n| name | RID | branch | head |\n|---|---|---|---|\n'; awk '/^## /{exit} /^\| [^|]+ \| rad:z[0-9A-Za-z]+ \| [^|]+ \| [0-9a-f]{40} \|/' /path/to/RIDS.md | awk -F'|' '{print "|" $2 "|" $3 "|" $4 "|" $5 "|"}'; } > compiler/vetted.md
grep '^| [^|]* | rad:z' compiler/vetted.md | cut -d'|' -f3 | tr -d ' ' | while read -r rid; do id="${rid#rad:}"; p="$(rad inspect "$rid" --payload)" || continue; br="$(printf '%s' "$p" | jq -r '."xyz.radicle.project".defaultBranch')"; printf '%s\t%s\t%s\t%s\t%s\n' "$(printf '%s' "$p" | jq -r '."xyz.radicle.project".name')" "$rid" "$(rad inspect "$rid" --visibility | sed -n '1{s/ .*//;p;}')" "$(git --git-dir="$HOME/.radicle/storage/$id" rev-parse "refs/heads/$br")" "$(printf '%s' "$p" | jq -r '."xyz.radicle.project".description')"; done | LC_ALL=C sort > compiler/inventory.tsv
```

## Regenerate

From the repository root:

```sh
./si compiler/inventory.tsv compiler/order.tsv compiler/vetted.md README.md repos.tsv si.sh
```

To check what is served, rebuild and compare:

```sh
curl -fsSL https://www.aienos.com/si | sha256sum
sha256sum si.sh
```

The two hashes match when the served script was built from the inventory committed here.

## Links

`links.om` is the link check, also in pure seeded Omega. Every project lives in its own Radicle repository; this repository only links to it. From the repository root, with the pinned `omc`:

```sh
"$OMC" < compiler/links.om > links && chmod +x links && ./links .
```

It writes nothing and checks two things. Every row of `repos.tsv` is a name, a valid Radicle ID (`rad:z` then 27 or 28 base58 characters that decode to a 20-byte id), a 40-digit head and a tier of `core` or `rest`; the withdrawn crypto projects (`omega-pearl`, `aien-crypto`, any RID starting `rad:z2ft64`) are refused. And no project source is copied in: the entries of the root, `compiler/` and `gpu/` must be on the fixed lists in `links.om` (the root's files and the directories the GitHub line already had, `gpu/cuda-crack` only, and the eight files of `compiler/`), `.git` skipped. It prints `links: pass: N link rows, every RID valid; the tree holds only SI files` and exits 0, or `links: ` and the first refusal on stderr and exits 1. `build.sh` step 5b runs it on both targets, with a crypto-RID control.

## Gate

`gate.om` is the gate of `si.om` and `links.om`, also in pure seeded Omega. From the repository root, with the pinned `omc` and an existing scratch directory `$W`:

```sh
"$OMC" < compiler/gate.om > "$W/gate" && chmod +x "$W/gate" && "$W/gate" "$OMC" "$W"
```

It first checks the `omc` it is given by its sha256: any other `omc`, or none, prints `SI NOT_RUN` and exits 3. It then builds `si` from `si.om` and `links` from `links.om` and checks eight cases. For `si`: the committed inputs regenerate `README.md` and `repos.tsv` byte-identically; an inventory with one head digit changed, an inventory with one RID character changed (both written by the gate), and the stale inventory of commit `3c37e6fb` (`gate-3c37e6fb.tsv`) are each refused with exit 1, the matching message, the README unchanged and nothing written. For `links`: the repository root passes; a `repos.tsv` whose first RID ends in `0` (not base58), one whose first RID starts `rad:z2ft64`, and the committed `repos.tsv` beside a planted project directory `omega-mv/main.om` are each refused with exit 1 and the matching message. Each mutated input must have a sha256 different from the committed file's (the planted file must exist), so a mutation that did not apply counts as a failure. It prints `SI pass=8 fail=0` and exits 0.
