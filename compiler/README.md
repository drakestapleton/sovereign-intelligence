# compiler/

`si.om` is the front-door generator, written in pure seeded Omega. From my Radicle node's inventory, filtered by the vetted public table, it writes three things:

- in `../README.md`, the clone line of the lead project between `<!-- si:lead:begin -->` and `<!-- si:lead:end -->`, the link to its `AGENT-PROMPT.md` between `<!-- si:agent:begin -->` and `<!-- si:agent:end -->`, and the project table between `<!-- si:index:begin -->` and `<!-- si:index:end -->`. While the lead project is not in the inventory, the lead and agent blocks say it is being published;
- `../repos.tsv`, the manifest: name, RID, full head commit, tier and description of every public project;
- `si.sh`, the POSIX sh bootstrap served at `https://www.aienos.com/si`. It is never committed here.

Inputs, all data:

- `vetted.md`: the vetted public table, one Markdown row per project, `| name | RID | branch | head |`. It is copied from RadPublish's `RIDS.md` by the command below and is the single source of what may be listed.
- `inventory.tsv`: one project per line, `name TAB rid TAB visibility TAB head TAB description`, exported from the node for the vetted RIDs only, by the command below.
- `order.tsv`: hand-kept. `core TAB name` lines give the core projects, in order. `deny TAB name` lines name projects that are never listed. One `lead TAB name` line names the project the README leads with.

A project is listed only when its name and RID are both on a `vetted.md` row and the node calls it public. Anything else on the node, and every private or denied project, is never emitted. Core projects come first, in `order.tsv` order; the rest follow in inventory order. `si` refuses, with exit 1 and nothing written, when a core project is missing, unvetted or not public, a name or RID appears twice, or a field is malformed. The output depends only on the input bytes: no clock and no environment, so two runs give identical files.

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
