# Replication runs of replicate.sh

Each directory holds `RUNLOG.md` and `summary.tsv`, copied unchanged from one run of `replicate.sh`.

| Run (UTC) | Script | Where | Result |
|---|---|---|---|
| `20261107T104021Z` | `replicate.sh` sha256 `58b8671799500fd49a0ae27b1e6cc147d085a387ebfa96aaa220bd6db4789183` (cuda-crack `e3365091`), fetched with `curl -fsSL https://www.aienos.com/replicate \| sh`. RUNLOG line 9: `replicate-inner.sh` sha256 `4a8807face7971db81ca4adc40a86f8ef23a8423b8876e2385b6dc337294ea0a`. | DGX Spark (GB10, Linux aarch64), as a fresh unprivileged user with `PATH=/usr/bin:/bin`, no CUDA toolkit on PATH and no sudo | All 26 required steps PASS, exit 0. 5.2 (`--corpus`) and 7 (`--chip`) are opt-in and NOT_RUN. |

Labels in the logs mean what `AGENT-PROMPT.md` §0 says. HOST_TESTED and SIMULATED steps ran on the host CPU. "receipt verified" steps check committed chip receipts; they did not touch the GPU. This run is not a chip qualification.

sha256:

```
2f1eca4d18d9f8ce90b98c5519593d3d7deeca83915f50ec55a61452a445d2f5  20261107T104021Z/RUNLOG.md
8380dc0841d82ea233d47e8c7a8674f45a79534dac031236e5923b9c8a17dd38  20261107T104021Z/summary.tsv
```
