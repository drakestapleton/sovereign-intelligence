# coder: an Omega-only coding session for omp

Harness configuration that makes an `omp` session write Omega and nothing else, with the pinned
seeded compiler in the loop. It is not product code and not part of the trusted Omega stack: the
extension is TypeScript because `omp` extensions are TypeScript, and the builders are small shell
scripts. "Only Omega" is enforced by the harness and the compiler, not by model weights.

| File | What it does |
|---|---|
| `omega-guard.ts` | `omp` extension (load with `-e`). Refuses every write or edit except `.om` files and `NOTES.md` inside the session directory; refuses reads outside the session directory and the context pack; compiles each written `.om` with the pinned `omc` (sha256 checked before every compile) and appends the result, with the error meaning and offending line, to the tool result; adds the `omega_run` tool (compile, then run in a `bwrap` sandbox with no network); refuses to let the session finish while a touched `.om` fails to compile, or, with `OMEGA_CASES` set, until the om2 gate passes those cases. |
| `omega-prompt-head.md` | Rules part of the system prompt (tools, check loop, `DONE <file>`). |
| `omega-observed.md` | Compiler facts observed with the pinned `omc` that the skill does not state. |
| `build-context.sh` | Builds the context pack: `OMEGA.md` = rules + `skills/omega-encoding` sections 2-11 (citation links stripped) + observed facts + eight examples that must each compile with the pinned `omc`; `CONTROL.md` = rules only. |
| `eval/` | Held-out eval: 27 tasks (`tasks/ID/{spec.md,stdin,expected.out,expected.exit}`), manifest `tasks.json`, runner `run.sh`. |

## Environment read by the guard

| Variable | Default | Meaning |
|---|---|---|
| `OMEGA_HOME` | `~/.local/share/aien-omega` | holds `omc`, the built `gate` and `seed/qualification/om2/fixtures` |
| `OMEGA_CONTEXT` | `$OMEGA_HOME/context` | the one directory outside the session the model may read |
| `OMEGA_CASES` | unset | om2 gate case file that must pass before the session may finish |
| `OMEGA_STOP_LIMIT` | `0` (no limit) | after this many refused finishes the finish is allowed and logged |
| `OMEGA_LOG` | unset | append-only log of every allowed/refused tool call, compile and finish |

The required `omc` sha256 (`2c824805...029f`, aien-dev/omega-mv `f1b9ecb5d` `seed/out/omc`) is fixed in
`omega-guard.ts`; a mismatch refuses every compile. `omega_run` and the finish check run the program
with a read-only root, no network and a 10 s timeout (the finish check gives the gate 120 s).

## Running it

Build the pack, install the guard, then start `omp` in the project directory with no shell tool:

```sh
OMEGA_MV=/path/to/omega-mv OMC=$HOME/.local/share/aien-omega/omc sh coder/build-context.sh ~/.local/share/aien-omega/context
cp coder/omega-guard.ts ~/.local/share/aien-omega/
omp --model PROVIDER/MODEL --tools read,edit,write,grep,glob,omega_run --no-skills --no-rules \
    --no-extensions --no-lsp --no-context-files -e ~/.local/share/aien-omega/omega-guard.ts \
    --system-prompt ~/.local/share/aien-omega/context/OMEGA.md
```

`--no-extensions` does not stop an extension named with `-e`. Use an isolated `omp` profile with
advisors off and no other providers so the session cannot fall back to another model.

## Eval

`sh coder/eval/run.sh omega|control OUTDIR coder/eval/tasks` runs every task in a fresh empty
directory, one after another. The `control` arm keeps the model, tools, guard and check loop and swaps
the system prompt for `CONTROL.md` with an empty readable context, so the only variable is the Omega
context. Scoring does not trust the session: the runner compiles `main.om` with the pinned `omc`
(non-zero exit or no file = compile-fail) and runs the om2 gate on the task's case line in a fresh
scratch directory (FAIL = wrong-output).

The reference solutions are held out: they are not in this repository, the context pack or any
session directory; `tasks.json` records only their sha256. They were checked with the pinned gate
(27/27 PASS, with a negative control that failed as it should). Keep `coder/eval/` out of any
training corpus built from this repository, or the eval stops measuring anything.
