# gpu/cuda-crack/: provenance

cuda-crack is the published method, sm_121 encoding tables and chip receipts behind "I broke CUDA". This directory is the project imported verbatim, plus the files listed under "Added here".

| Field | Value |
|---|---|
| Project | cuda-crack |
| Radicle ID | `rad:z631r2JJiVT8it4tST7RK24hpowi` |
| Commit | `7e3c9a731d8607ceb60b5a257c8c3652becd544f` (2026-11-07T05:01:21-06:00, "replicate.sh --agent --yes: exact allow-list instead of token deny-list; ...") |
| Fetched | 2026-11-07, `git clone --depth 1 https://rosa.radicle.network/z631r2JJiVT8it4tST7RK24hpowi.git`; the head matched the seed's advertised `refs/heads/main` and `stack/STACK.tsv` |
| Imported | 2026-11-07, `git archive HEAD \| tar -x -C gpu/cuda-crack`: all 169 tracked files, byte-identical (checked file by file with `cmp`), executable bits kept. Nothing was left out; the largest file is 167,751 bytes |
| Licence | Apache License 2.0, [`LICENSE`](LICENSE) |

`SHA256SUMS` lists the sha256 of the 169 imported files, in `LC_ALL=C` path order; `build.sh` step 8 checks it, and `receipts/SHA256SUMS` (148 receipts), on every build.

## Added here

- `PROVENANCE.md` and `SHA256SUMS`.
- `check/mutate.om`: the four planted bugs of `check/check.sh`, in seeded Omega (below).
- `check/mutate-tests/*.txt`: four edge-case tables for it: two NOP records, tabs and a missing final newline, a mask bit already clear (the result goes below zero), a width-0 record with an empty line and a short F record.

## What `build.sh` step 8 runs, on AArch64 and native x86-64

1. `gen/bw_enc_sm121.om` + `gen/isa.om`, built by the seed-born omc and omc-x86, regenerate the 471 forms of `isa/sm121-forms.txt` byte for byte. That file was made with omega-mv omc `3ad9f10f…`. Its four header lines name that compiler and are not regenerated; everything after them is.
2. `check/reencode.om` checks the tables' D records against their F records. It then rebuilds the 70 kernels that ran on the GB10 (13,520 instructions) from the tables alone, and their sha256 must equal the chip receipt `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/kernels-om.sha256`.
3. `check/mutate.om` must produce exactly what `check/check.sh`'s own awk, od and printf one-liners produce (copied verbatim into `build.sh` as `ccmut`). It is checked on the table, the four edge cases and all 70 kernels, and it must refuse an empty kernel.
4. The four planted bugs must be caught as `check/CHECK.txt` records them: a flipped fixed bit leaves 540 instructions unmatched and 67 kernels wrong; a corrupted instruction matches no form (exit 4); a field width off by one and a field mask missing one bit are refused (exit 7).

Running the kernels on the GB10 needs the chip; the build prints it as NOT_RUN. See `REPRODUCE.md`.

## The shell, and what replaces it

| Script | Lines | Status |
|---|---:|---|
| `check/check.sh` | 83 | Its first-party logic, the four planted bugs, is now Omega: `check/mutate.om`, with the differential above on every build. Its checks run in `build.sh` step 8 on both targets. The script stays because it is the published method: `AGENT-PROMPT.md`, `REPRODUCE.md`, `replicate.sh` and `check/CHECK.txt` cite it. What stays shell is orchestration: compiling, running `reencode` once per kernel, `sha256sum`. Omega successor: one Omega driver using the host words `fork`, `execprog`, `waitpid` and `pipefds`, and an Omega SHA-256. omega-bridge has one (`tests/native/v2/sha256-om2.om`, FIPS 180-4, function mode) that has not moved into this repository yet. |
| `gen/run.sh` | 24 | Its check runs in `build.sh` step 8 (point 1). The script stays for the same reason. It pins omc `3ad9f10f…`, so it refuses this repository's compilers; the build checks the generated body instead. Omega successor: the same driver, writing the four header lines itself. |
| `replicate.sh` | 708 | Stays for now. It clones from Radicle seeds over HTTPS, runs other projects' builds, and embeds a Python agent loop that talks HTTP and JSON to a local model. The Omega pieces that loop needs already exist in omega-mv but have not moved into this repository: `seed/json/` (an RFC 8259 reader and writer) and `seed/net/` (an HTTP/1.1 client and server, and HTTPS through its om/tls TLS 1.3 client). Rewriting the loop in Omega waits for them; the git clones and the other projects' builds need the process driver above. |
| `tests/agent-gate.sh` | 125 | Stays with `replicate.sh`: it tests the Python command gate embedded there. |
