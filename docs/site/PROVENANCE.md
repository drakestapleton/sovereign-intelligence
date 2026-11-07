# docs/site/: provenance

The source of my personal site, drakestapleton.com, as of 26 October 2026. The live site is still deployed from the GitHub repository; this copy does not deploy.

| Field | Value |
|---|---|
| Source | GitHub `drakestapleton/drakestapleton.com`, my personal account. It has no Radicle project. |
| Commit | `270f2dc5c5c89ae16944b2cd28e3da01cca96b77` (2026-10-26T12:01:05-05:00), the head of `main` |
| Fetched | 2026-11-07, `git clone --mirror https://github.com/drakestapleton/drakestapleton.com` |
| Imported | 2026-11-07, `git archive HEAD \| tar -x`: all 157 tracked files, byte for byte, executable bits kept |

`SHA256SUMS` lists the sha256 of every imported file. To check this tree, run `sha256sum -c SHA256SUMS` from this directory. `PROVENANCE.md` and `SHA256SUMS` are the only files here that are not from the import.

Only `main` is imported. The repository has 10 branches; each one's head commit and length are in [`stack/FORKS.tsv`](../../stack/FORKS.tsv) (rows with action `si`). Any `.github/workflows` here is inert: GitHub runs workflows only from a repository's root.
