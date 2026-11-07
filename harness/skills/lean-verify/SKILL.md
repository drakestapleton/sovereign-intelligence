---
name: lean-verify
description: Machine-checked proofs with Lean 4 + Mathlib through the `lean` MCP server on the Spark. Use to prove a safety invariant (core disjointness, disk floor, lease exclusion, queue bounds, protocol/state-machine properties) about an explicit model, and to check that a proof has no sorry and no extra axioms.
---

# Lean 4 verification (`lean` MCP)

Lean is a verification oracle, the same class as the pinned compiler or `fsck.vfat`: it checks a claim, it does not run in the product path.

## Pins (checked 2026-11-06)

| Component | Version | Where |
|---|---|---|
| elan | 4.2.4 (227caca13 2026-08-25) | Spark `~/.elan/bin` |
| Lean toolchain | `leanprover/lean4:v4.35.0` | `~/workspace/lean-verify/lean-toolchain` |
| Mathlib | `v4.35.0` (commit `56a005855ea17e0b0958f73ec801ae140b0a1679`), prebuilt oleans from `lake exe cache get` | `~/workspace/lean-verify/lake-manifest.json` |
| MCP server | `lean-lsp-mcp==0.33.0` (MIT, github.com/oOo0oOo/lean-lsp-mcp tag `v0.33.0` = `ed8aa4b9`), `leanclient==0.13.2`, `mcp==2.2.0` | venv `~/workspace/lean-verify/.mcp-venv`, full list in `.mcp-venv-freeze.txt` |

Project: Spark `~/workspace/lean-verify` (lake, library `LeanVerify`, local git history). Worked examples: `LeanVerify/Check.lean`, `LeanVerify/CoreAssign.lean`, `LeanVerify/SkillExamples.lean`; sorry negative control: `Controls/SorryControl.lean` (deliberately not in the library).

The server runs on the Spark over ssh stdio, pinned to cores 0–1 with `nice -n 10`. The four remote search tools (`lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_hammer_premise`) are disabled with `LEAN_MCP_DISABLED_TOOLS`, so `tools/list` returns 18 tools, all local. The full smoke test (below) passed inside `bwrap --unshare-net`, where `curl https://pypi.org` fails, so it needs no network. Search Mathlib with `lean_local_search` (ripgrep) instead.

`mcp.json` entry (Mac `~/.omp/agent/mcp.json`). `<spark>` is your ssh alias for the Spark and `<home>` is the absolute home directory of the remote account. ssh does not expand `~` inside `env` arguments, so write the absolute path:

```json
"lean": {
  "type": "stdio",
  "command": "ssh",
  "args": ["-o", "BatchMode=yes", "-o", "ConnectTimeout=8", "<spark>", "env", "PATH=<home>/.elan/bin:/usr/local/bin:/usr/bin:/bin", "LEAN_PROJECT_PATH=<home>/workspace/lean-verify", "LEAN_LOG_LEVEL=ERROR", "LEAN_MCP_DISABLED_TOOLS=lean_leansearch,lean_loogle,lean_leanfinder,lean_hammer_premise", "taskset", "-c", "0,1", "nice", "-n", "10", "<home>/workspace/lean-verify/.mcp-venv/bin/lean-lsp-mcp", "--transport", "stdio"],
  "timeout": 300000
}
```

## Lean or Wolfram?

| Question | Tool |
|---|---|
| Compute a number, solve, simplify, integrate, convert units, check an identity numerically or symbolically | Wolfram (mandatory, `wolfram-math`) |
| "This property holds for **every** state / input / interleaving of the model" | Lean |
| "These finite sets never overlap", "this arithmetic bound always holds", "two holders can never both own the lease", "the queue never exceeds N" | Lean |
| A proof someone else must be able to re-check mechanically, with an explicit axiom list | Lean |

Wolfram answers *what is the value*; Lean answers *is this statement true for all cases, with a kernel-checked proof*. Use Wolfram to get a constant, then Lean to prove the invariant that uses it.

## Tools

Enabled on the `lean` server (names as `tools/list` returns them; in omp they follow the `mcp__<server>_<tool>` pattern of the other servers, e.g. `mcp__lean_lean_run_code`):

- `lean_run_code` `{code}` — check a self-contained snippet (it needs its own `import`s). The usual entry point. Returns `{success, timed_out, diagnostics[]}`.
- `lean_verify` `{file_path, theorem_name}` — axiom check plus source scan for one theorem in a project file. `file_path` is absolute (`<home>/workspace/lean-verify/...`). Returns `{axioms, trust, non_standard_axioms, warnings}` with `trust` one of `standard`, `incomplete` (sorry), `native`, `custom`.
- `lean_diagnostic_messages` — errors/warnings/infos of a project file.
- `lean_goal`, `lean_term_goal` — proof state at a position.
- `lean_multi_attempt` — try several tactics at one position.
- `lean_hover_info`, `lean_completions`, `lean_declaration_file`, `lean_references`, `lean_file_outline`, `lean_local_search`, `lean_code_actions`, `lean_profile_proof`, `lean_minimal_hypotheses`, `lean_get_widgets`, `lean_get_widget_source`, `lean_build`.

The first call starts `lake serve` and loads Mathlib oleans (about 3–8 s measured). Prefer `import Mathlib.<specific module>` over `import Mathlib` to keep it fast.

Observed results (2026-11-06 smoke test):

| Snippet | `lean_run_code` | Meaning |
|---|---|---|
| `theorem t : (2:Nat)+2=4 := rfl` + `#print axioms t` | `success: true`, info `'t' does not depend on any axioms` | proved |
| `theorem f : (2:Nat)+2=5 := rfl` | `success: false`, error `Not a definitional equality` | refuted |
| `theorem s : (2:Nat)+2=4 := sorry` | **`success: true`**, warning category `sorry`, `'s' depends on axioms: [sorryAx]` | NOT proved |

`success: true` therefore does **not** mean proved. A theorem is proved only if `success` is true, no diagnostic has category `sorry`, and its axioms are within the standard three. `lean_verify` on a sorry theorem returned `trust: "incomplete"`, `axioms: ["sorryAx"]`.

## How to state a safety invariant

1. **Write the model explicitly.** Name every set, constant and transition. Finite, concrete data (`Finset Nat`, `Fin n`) can be decided by the kernel with `by decide`.
2. **State the property as a theorem over the model**, never as a comment.
3. **Write a negative control**: a deliberately broken model and a theorem proving the property *fails* for it. A property that also "holds" for the broken model is vacuous.
4. **Print the axioms** of every theorem.

```lean
import Mathlib.Data.Finset.Basic
import Mathlib.Order.Disjoint

-- Core-assignment disjointness (finite, decidable)
def lanes : Fin 3 → Finset Nat
  | 0 => {4, 5} | 1 => {6} | 2 => {8, 9}
def reserved : Finset Nat := {3, 7, 15}
theorem lanes_disjoint : ∀ i j, i ≠ j → Disjoint (lanes i) (lanes j) := by decide
theorem no_reserved : ∀ i, Disjoint (lanes i) reserved := by decide

-- Disk floor arithmetic: a write of w GiB is admitted only if it keeps ≥ floor free
def admit (free w floor : Nat) : Bool := decide (w + floor ≤ free)
theorem floor_kept (free w floor : Nat) (h : admit free w floor = true) :
    floor ≤ free - w := by
  simp [admit] at h; omega

-- Lease mutual exclusion: once held, acquire by anyone leaves the holder unchanged
structure St where holder : Option Nat
def acquire (s : St) (p : Nat) : St := if s.holder = none then ⟨some p⟩ else s
def release (s : St) (p : Nat) : St := if s.holder = some p then ⟨none⟩ else s
theorem acquire_excl (s : St) (p q : Nat) (h : s.holder = some q) :
    (acquire s p).holder = some q := by simp [acquire, h]
theorem release_other (s : St) (p q : Nat) (h : s.holder = some q) (hpq : p ≠ q) :
    (release s p).holder = some q := by simp [release, h, Ne.symm hpq]

-- Bounded queue capacity: push never exceeds cap
def push (cap : Nat) (q : List Nat) (x : Nat) : List Nat :=
  if q.length < cap then q ++ [x] else q
theorem push_bounded (cap : Nat) (q : List Nat) (x : Nat) (h : q.length ≤ cap) :
    (push cap q x).length ≤ cap := by
  unfold push
  split
  · simp; omega
  · exact h

#print axioms lanes_disjoint  -- [propext, Classical.choice, Quot.sound]
#print axioms floor_kept      -- [propext, Quot.sound]
#print axioms push_bounded    -- [propext, Quot.sound]
```

These examples compile as `LeanVerify/SkillExamples.lean` in the project (`lake build` passes). The full worked example is `LeanVerify/CoreAssign.lean`: eight lane sets, `no_reserved` (none uses 3, 7 or 15), `overlap_6_7` (`{0,1} ∩ {1,2} = {1}`), `disjoint_except_6_7` (every other pair is disjoint) and a negative control from a live `taskset -cp` readout.

For a state machine, prove the invariant is preserved by every transition (`inv s → inv (step s e)`) and holds initially; that gives it for every reachable state by induction.

## A theorem proves the MODEL, not the running system

Every Lean result must state its **model-to-system link**: which file, config, `taskset -cp` readout, unit file or source function the model was taken from, at which revision or time, and how that was checked to match (read back, generated, or hand-copied). Without that link the claim is about the model only. Label it that way. Example: "PROVED for the 8-set model copied from Drake's message 2026-11-06; live `taskset -cp` shows `aien-serve-http` on 2-4, which is NOT in the model and violates it." A proof never upgrades a status beyond what `omega-communication` allows. It is evidence about a design. It does not qualify hardware or a deployment.

## Forbidden: `sorry`, extra axioms, native evaluation

- `sorry` (axiom `sorryAx`) means *not proved*. Lean reports `declaration uses 'sorry'` as a **warning** and `lean_run_code` still returns `success: true`, so "no errors" is not enough. Always check the axioms.
- An elaboration error also turns the declaration into `sorryAx` (`lake build` showed `depends on axioms: [sorryAx]` for a theorem whose proof failed), which is another reason to read the axiom list rather than trust a partial log.
- Run `#print axioms <thm>` (or `lean_verify`). The only acceptable set is a subset of `[propext, Classical.choice, Quot.sound]`. "does not depend on any axioms" is best.
- `native_decide` (axioms `Lean.ofReduceBool` / `Lean.trustCompiler` / `*._native.native_decide.ax*`) trusts the compiler rather than the kernel. Use `decide` or `decide +kernel`.
- A new `axiom` declaration, `unsafe`, `@[implemented_by]` or `@[extern]` in a proof file is forbidden.
- Report the verdict with the axiom list: `PROVED (axioms: [propext]) model=<source>` or `FAILED: <error>`.

## Running outside MCP

```bash
ssh <spark> 'cd ~/workspace/lean-verify && PATH=$HOME/.elan/bin:$PATH taskset -c 0,1 nice -n 10 lake env lean LeanVerify/CoreAssign.lean'
```

Put new proofs under `LeanVerify/` and import them from `LeanVerify.lean` so `lake build` checks them all.

## Repair

- Server does not start: `ssh <spark> ~/workspace/lean-verify/.mcp-venv/bin/lean-lsp-mcp --version` must print `lean-lsp-mcp 0.33.0`. Reinstall the pinned set with `python3 -m venv .mcp-venv && .mcp-venv/bin/pip install -r .mcp-venv-freeze.txt` (network needed once).
- `unknown module Mathlib...` or `environment does not contain`: wrong or missing import (for example `Finset.card` needs `Mathlib.Data.Finset.Card`), or oleans missing. For the latter run `lake exe cache get` (network, once) then `lake build` in the project, on cores 0–1.
- Upgrading Lean or Mathlib: change `lean-toolchain` and the mathlib `rev` together to the same `v4.x.y` tag, `lake update`, `lake exe cache get`, `lake build`, rerun the smoke test (initialize, `tools/list`, the three snippets above), and update the pins table.
