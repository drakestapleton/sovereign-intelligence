# plumbline/hub: the INTERPLANE site, written out by an Omega program

One Omega program writes the whole static site: the overview, the stack, the evidence, the Omegese page, the protocol overview and its six pages, the stylesheet, `robots.txt`, `sitemap.xml`, `llms.txt` and `facts.json`. There are no templates, no image files and no other language in the path. The picture on the overview is drawn by arithmetic in `src/35-art.om`.

Nothing here is deployed, and nothing here touches a domain. `BASE` is an argument, so the same build can be published at any address.

## Build

The program is the files of `src/` in name order, concatenated (Omega has no imports) and compiled by the seed-grown compilers that `sh build.sh` leaves in `out/`:

```sh
cat plumbline/hub/src/*.om | qemu-aarch64-static out/omc > hub-a64          # AArch64
{ printf 'target x86linux\n'; cat plumbline/hub/src/*.om; } | out/omc-x86 > hub-x86   # x86-64
```

On an AArch64 host, run `out/omc` directly. Compile for both targets: the AArch64 compiler has 16 registers per function and refuses a function the x86-64 one accepts.

## Run

```sh
hub facts PROTO_DIR SHA TIME OUTFILE
hub build OUT BASE REPOS STACK LEDGER PINS README FACTS WIRESUM EXJSON EXIPO NL8 NL8SWEEP REGISTRY
```

`hub facts` reads a checkout of the protocol repository (`STATUS.md`, `ROADMAP.md`, `rust/Cargo.toml`, `docs/REPORT-*.md`) at commit `SHA`, committed at `TIME` (UTC, `YYYY-MM-DDTHH:MM:SSZ`), and writes the facts file. `facts.tsv` here was written that way from `rad:zNhNbqYvgSBEHBq9vvE8xpbcBzGa` at `708b4daed1900ed9da7907fd30a583f468eb9c1b`.

`hub build` arguments:

| Argument | What it is |
|---|---|
| `OUT` | directory to write the site into |
| `BASE` | the address the site will have, `https://host`, no trailing slash |
| `REPOS` | `repos.tsv` |
| `STACK` | `stack/STACK.tsv` |
| `LEDGER` | `stack/LEDGER.tsv` |
| `PINS` | `seed/PINS.tsv` |
| `README` | the front door's `README.md`; its evidence tables and sections are rendered, never retyped |
| `FACTS` | the protocol facts file |
| `WIRESUM` | `plumbline/wire/tests/expected.txt`, the wire selftest's recorded output |
| `EXJSON`, `EXIPO` | `plumbline/wire/tests/example.json` and `example.ipo` |
| `NL8`, `NL8SWEEP` | `plumbline/neuralese/nl8/expected-peer.tsv` (the run in which each build is given the other's table) and `sweep.txt` |
| `REGISTRY` | the Radicle registry (`RIDS.md`) whose first table is the forge's repository count, or `-` |

It prints `HUB files=N` and exits 0. It refuses, exits 1 and writes no file when:

- `BASE` is not `https://` followed by lowercase letters, digits, dots and dashes;
- the ledger's `TOTAL` row is missing or differs from the sum of its rows;
- a ledger project is not in `STACK.tsv`, or a subsystem name is unknown;
- the README lacks a section a page needs;
- the wire summary lacks `vectors=`, `json_bytes=` or `ipo_bytes=`;
- the registry has no Markdown table, or its first table has no rows.

The output depends only on the bytes of the inputs: no clock, no environment, no network.

## Where each number comes from

| On the page | Read from |
|---|---|
| seed bytes, the seed chain | `seed/PINS.tsv` |
| lines of Omega and of other languages, files measured | `stack/LEDGER.tsv`; the `TOTAL` row is checked against the sum |
| share of a subsystem already in Omega | `1000 a / (a + b)` to the nearest permille (`fn permil`, `src/10-data.om`; proved in `../proofs/Share.lean`) |
| the overall share | the ledger's own `om_permille`, which rounds down |
| public projects, their Radicle IDs and heads | `repos.tsv` |
| projects per plane, the lit tiles in the picture | `stack/STACK.tsv` |
| claims with evidence labels | the README's own tables |
| protocol version, licence, status counts, stages, reports | the facts file |
| the forge's repository count | the registry's first table; with `-` the pages state no number |
| sizes on the Omegese page | the byte lengths of the two example files and the selftest's summary line |

Every byte that comes from an input file reaches a page through `emh` (`src/00-core.om`), which escapes `& < > " '`.

## Units

| File | What it holds |
|---|---|
| `00-core.om` | buffers, file loading and writing, escaping, number formatting |
| `10-data.om` | the four tables, the join of ledger and stack, the totals check |
| `12-registry.om` | the forge count, from the registry or not stated |
| `15-md.om` | renders README sections: paragraphs, lists, tables, code, inline code, bold, https links |
| `20-style.om` | the one stylesheet |
| `30-shell.om` | head, navigation, page header, footer |
| `35-art.om` | the picture: four planes, the plumb line, one tile per project, drifting fragments |
| `40-home.om` | the overview, and the planes, proof cards and seed chain other pages reuse |
| `45-pages.om` | the stack, evidence and protocol overview pages; the six protocol pages' frames |
| `47-omegese.om` | the Omegese page |
| `50-facts.om` | `hub facts`, and reading the facts file |
| `60-protocol.om` | the protocol pages' bodies, ported from the Rust generator's `page.rs` |
| `70-discovery.om` | `style.css`, `robots.txt`, `sitemap.xml`, `llms.txt`, `facts.json` |
| `90-main.om` | the program |

## What changed against the Rust generator it replaces

- Facts that the Rust generator read from the Radicle HTTP API are not gathered: open patch and issue counts, the last merged patch, the delegate tag, the latest change's title. The pages link to the project's patches and issues instead. Everything else is read from a checkout at one commit.
- The page no longer says it is rebuilt every hour. That was a statement about a deployment, and this build is not deployed.
- The old home page's protocol sections moved to `/protocol/`. The six protocol pages keep their addresses.
- New pages: `/stack/`, `/evidence/`, `/omegese/`.
- No `hero.webp`: the picture is inline SVG computed by the program.

## Not done

- It is not deployed and has never served a visitor.
- The stale-fact risk is the README's: the site repeats the README's claims as they stand at build time.
- Checked in Chromium only, at 1440 and 390 pixels wide, light and dark. No other browser, no screen reader.
