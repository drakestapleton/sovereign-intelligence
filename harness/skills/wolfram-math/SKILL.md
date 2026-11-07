---
name: wolfram-math
description: Mandatory mathematics through Wolfram. Use for any computation, derivation, identity, unit conversion, numeric constant, formula check or quantitative claim, and to set up or repair the Wolfram tools so an agent never computes by hand.
---

# Mathematics goes through Wolfram. Mandatory.

Drake, 2026-10-25: every agent uses Wolfram for mathematics. Not mental arithmetic, not an ad-hoc script,
not a spreadsheet cell, not a number produced by fluency.

## What is in scope

- Any computation, derivation, integral, series, solve, simplification, identity check, dimensional
  analysis, unit conversion, statistical calculation, tolerance, expected value or numeric constant.
- Any number you are about to put in a report, receipt, PR body, gate, evidence file or user answer.
- Checking a formula that code implements against its symbolic form.
- The physics behind a visual or a claim, not only the arithmetic of the numbers already measured.

Not in scope: a number that is already measured and filed with its source (quote it with the source);
integer bookkeeping such as line counts, byte sizes, exit codes, PIDs and commit shas.

## Tools in this harness

Mounted as MCP tools by the hosted service `https://agenttools.wolfram.com/mcp`:

| Tool | Use |
|---|---|
| `mcp__wolfram_wolframlanguageevaluator` | Wolfram Language evaluation. Exact results: `Integrate`, `Solve`, `Reduce`, `Series`, `D`, `Simplify`, `Quantity`, `UnitConvert`, `NIntegrate` |
| `mcp__wolfram_wolframalpha` | Natural-language facts, constants, identities and conversions when you do not want to write code |
| `mcp__wolfram_wolframcontext` | Semantic retrieval for background on a term |

## Setup, so no human has to be involved

1. **Check the mount.** `~/.omp/agent/mcp.json` must contain:

   ```json
   "wolfram": { "type": "http", "url": "https://agenttools.wolfram.com/mcp", "timeout": 120000 }
   ```

   This transport needs **no token, no local Wolfram Engine and no npm package** on the project machine.
   Verified 2026-10-25 by two calls: `Integrate[x^2, {x, 0, 1}]` returned `1/3`, and `sqrt(27)/2`
   returned `(3 sqrt(3))/2`.
2. **If the tools are missing**, add that block and restart the session. MCP servers mount at session
   start, so a running session cannot pick up the new block. Do not install a local Wolfram Engine to
   satisfy this rule: the hosted endpoint is the supported path. Some hosts keep `mcp.json` read-only
   under an operator-managed store (the file is a symlink into a protected location). There, never
   unlink, replace or chmod it: ask the operator, and change it only through the host's documented
   update command. Adding or changing another MCP server (for example an issue tracker) follows the
   same route, and the Wolfram block must survive the change.
3. **If the endpoint demands credentials** (another machine, a changed policy), the secret lives in the
   vault and is injected at launch, for example `atlas-vault run CORTEX_TOKEN -- <server>`. Never write
   a token into `mcp.json`, a repository file, a commit or a log.
4. **Verify before claiming the session is math-capable.** Two calls: the evaluator above and one
   WolframAlpha fact. If either fails, the session is not math-capable: say so and stop. Do not compute
   by hand as a workaround.

## How to use it

- One call per question, and quote the query with the result where the work lives:
  `WolframLanguageEvaluator: Integrate[x^2, {x, 0, 1}] -> 1/3`.
- Prefer exact results. Take `N[...]` only when a decimal is what the reader needs, and say which form
  you used. `Quantity` and `UnitConvert` carry the unit into the text; a bare number without a unit is
  not a result.
- When Wolfram contradicts the code, the code is wrong until shown otherwise. Record both and open the
  investigation instead of picking the friendlier number.
- Wolfram is the calculator, not a receipt: the project's MODELED versus MEASURED labels are unchanged,
  and a Wolfram result does not show that a modelled mechanism runs on the hardware.

## Failure modes

- **Tools absent**: the session is not math-capable. Report it. Never improvise arithmetic.
- **401 or 403**: credential wiring. Fix or report it; it is not a reason to skip the mathematics.
- **Timeout**: retry once with a smaller query; if it still fails, report the exact query and error.
- **A result you cannot interpret**: ask again in explicit form (`Solve`, `Reduce`, `Assuming`) and
  report the ambiguity rather than rounding it away.

## Why it is mandatory

Hand arithmetic and invented constants are the most common silent error in agent work, and they survive
review because they look reasonable. A symbolic or numeric check is cheap, reproducible and quotable.
