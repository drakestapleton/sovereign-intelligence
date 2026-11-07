# harness/: provenance

This directory is the Omega harness, imported verbatim. No imported file is edited here.

| Field | Value |
|---|---|
| Project | omega-harness |
| Radicle ID | `rad:z39gvwWsnkRZsAConQLjaKiNVLHfW` |
| Commit | `c38640db4fe8ee49eff589123415d4a1ba80567a` (2026-11-07T03:42:59-06:00, "aien-repositories: SI front door is the Omega-generated /si script pulling from Radicle") |
| Fetched | 2026-11-07, `git clone --depth 1 https://rosa.radicle.network/z39gvwWsnkRZsAConQLjaKiNVLHfW.git`; the head matched the seed's advertised `refs/heads/main` |
| Imported | 2026-11-07, `git archive HEAD \| tar -x -C harness`: all 394 tracked files, byte-identical (checked file by file with `cmp`), executable bits kept |
| Licence | Apache License 2.0, [`LICENSE`](LICENSE) |

`SHA256SUMS` lists the sha256 of every imported file, in `LC_ALL=C` path order. Check the tree with:

```sh
cd harness && sha256sum -c SHA256SUMS
```

`PROVENANCE.md` and `SHA256SUMS` themselves are the only files here that are not from the import.

`../.claude/skills` is a symlink to `skills/`, so an agent session in this repository loads the harness skills.

`../tests/examples.sh` runs every worked example (`examples/*.om` and `skills/*/examples/*.om`) against its `.expect`, `.stdout`, `.stdin`, `.args` and `.env` files on two targets: AArch64, and native x86-64 through `target x86linux`. The semantics are those of `examples/gate.sh`, without its compiler-hash pin. The guide's examples were written against omc `3ad9f10f…` (omega-mv `f4df8239`); the runner checks them against whichever compilers the build grew from the seed.
