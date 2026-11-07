# Omega Harness

Agent skills for working in Omega, the `.om` language of AienOS, and in the AIEN repositories. An agent that loads these skills finds the actual source before acting, writes `.om` code that the seeded compiler accepts, runs what it builds, and reports its status without overstating it.

Skills can't make agents flawless. What these do is turn the mistakes agents keep repeating into checks they must run before they claim anything: stale syntax, guessed compiler limits, compiling without running, labeling host-only runs as qualified, and choosing the wrong repository.

| Skill | Use it for |
|---|---|
| [`omega-harness`](skills/omega-harness/SKILL.md) | The overall workflow: orient, implement in `.om`, compile, run, challenge, handle effects, learn from repeated errors |
| [`writing-omega`](skills/writing-omega/SKILL.md) | A portable guide for writing a correct `.om` program on any machine: shape, types, words, traps, errors 1..30, common mistakes with their exact refusals, known compiler defects and workarounds |
| [`omega-encoding`](skills/omega-encoding/SKILL.md) | The language the seeded compiler accepts: prefix words, types, traps, bounds, registers, host I/O, byte layouts, error codes, plus two runnable examples |
| [`omega-communication`](skills/omega-communication/SKILL.md) | Status labels, reports, PR text, agent handoffs, receipts, wire formats, corrections |
| [`aien-repositories`](skills/aien-repositories/SKILL.md) | What AIEN builds, who decides what, and which repository owns a task |
| [`crumb-protocol`](skills/crumb-protocol/SKILL.md) | Directory coordination: read and respect crumbs, claim and release locks, keep committed crumbs fresh, answer `CRUMB-VERIFY` and `crumb-doctor` |
| [`wolfram-math`](skills/wolfram-math/SKILL.md) | Mandatory Wolfram for every computation: MCP setup an agent can do alone, verification calls, failure handling |
| [`lean-verify`](skills/lean-verify/SKILL.md) | Machine-checked Lean 4 + Mathlib proofs of safety invariants over an explicit model through the `lean` MCP: when to use Lean versus Wolfram, the model-to-system link, no `sorry` or extra axioms |

The skills use the Agent Skills layout (`skills/<name>/SKILL.md` with `name` and `description` frontmatter), so any agent that reads that layout picks them up.

## Human-Directed Agentic Engineering

Development follows Human-Directed Agentic Engineering (HDAE): humans define goals, architecture, constraints, acceptance criteria and stopping points; agents implement, execute checks, diagnose failures and revise within those boundaries. Human review retains responsibility for claims, acceptance and release decisions. These skills make the agent's inner loop explicit without transferring the human's authority to a model.

For the documented method and systems-software case study, see Gregory M. Kurtzer, *Ginux: Building an Independent Kernel That Runs Linux Userspace through Human-Directed Agentic Engineering* (2026), [doi:10.5281/zenodo.23682548](https://doi.org/10.5281/zenodo.23682548). Project authorship, compiler pins and historical evidence remain unchanged.

## Install

Clone the repository, then put the skill directories where your agent looks for skills:

```sh
git clone rad://z39gvwWsnkRZsAConQLjaKiNVLHfW omega-harness
```

Radicle is the canonical home (2026-11-07). The `aien-dev` GitHub organization is frozen; its
`github.com/aien-dev/...` links below are historical citations of the commits they name, not live
destinations.

| Agent | Skill directory |
|---|---|
| oh-my-pi (`omp`) | `~/.omp/agent/skills/` or a project's `.omp/skills/` |
| Claude Code | `~/.claude/skills/` or a project's `.claude/skills/` |
| Codex and other Agent Skills readers | `~/.agents/skills/` or a project's `.agents/skills/` |

```sh
cp -R omega-harness/skills/* ~/.agents/skills/   # pick the directory for your agent
```

`omp` can also read them in place. Add the clone's `skills` directory to `skills.customDirectories` in `~/.omp/agent/config.yml`. Once installed, agents load a skill automatically when the task matches its description. In `omp` you can also invoke one directly with `/skill:omega-harness`.

## Conversion

The November 6 local Mac model experiment has explicit
[runtime receipts and an open host-language migration boundary](skills/omega-harness/SKILL.md#2-implement-in-the-actual-language).
Omega inference inside an Aienux firmware guest does not make the temporary
C++ browser adapter Omega, and firmware-hosted emulation does not establish
standalone-kernel or native Apple Silicon support. These are unmerged experiment
branches; they do not change the compiler pin or supported language.

These skills cover working in Omega itself. Conversion between Omega and other languages belongs to [`omega-bridge`](https://github.com/aien-dev/omega-bridge). It converts a declared, checked subset and refuses to attempt universal conversion. You can run an MCP server in front of it if you want automated conversion, but that wrapper doesn't let it convert anything beyond that subset.

Merged [omega-bridge #32](https://github.com/aien-dev/omega-bridge/pull/32) localizes private
ABI1/ABI2 runtime symbols so independent generated translation units link without collisions.
[#33](https://github.com/aien-dev/omega-bridge/pull/33) adds conservative integer-scalar
freestanding output without pthread, mmap, heap or TLS; [#35](https://github.com/aien-dev/omega-bridge/pull/35)
extends finite aggregate frame/output pools with checked refusal. Section 2 pins main
`2efdd48cd0c7c232064d5870e77660a5a75966e1` and records host evidence and negative controls.
Merged host-exercised source is not deployment or GPU qualification.

Merged [omega-bridge #36](https://github.com/aien-dev/omega-bridge/pull/36) (merge
`2ed42c3818e72da321c3218d22d7662be607633c`, 2026-11-01) adds an explicitly pinned
`bridge-seeded` frontend for portable checked C/Python and C declarations.
Section 2 records head `3dc4a00e9966770cce58bdedb401c3b3932c35ee`, compiler and converter
hashes, canonical composition and binary32 limits, the import-free scalar profile,
and exercised differential/refusal controls. Consumer host acceptance is separately
recorded. This does not replace baseline gates or depend on a native x86 Omega compiler.

The merged [omega-mv WebAssembly backend (#787)](https://github.com/aien-dev/omega-mv/pull/787)
is a compiler backend for the existing scalar OSC IR v1 wire format, not a foreign-source
converter. Its seeded Omega writer and read-only Node oracle boundary are documented in
`omega-encoding` section 0 and `omega-harness` sections 2-3. Backend merge:
`3364a1dfd0ca50c1b82bf19ba34932d8bc10a7a9`; boolean IR prerequisite #786:
`87489da90a1a7a750fd4a7f9eeb005b1221721f6`.

The [SPIR-V backend (#804)](https://github.com/aien-dev/omega-mv/pull/804)
merged as `3a10bd29fb7debdcf2c8f5cb58680cc74cb5b1f3`: an Omega-written OpenCL Kernel
emitter, a PoCL CPU parity gate and a minimal OpenCL IL demo. `omega-harness`
section 3 records the exact exercised source, toolchain, ABI, refusal boundary
and evidence. CPU execution is not GPU or DPC++ qualification.

The Neuralese supplement ([#919](https://github.com/aien-dev/omega-mv/pull/919), merged by
train r1 #971 as `f56a372a`) keeps Omega's name and proposes model/decoder-bound
representations that decode into explicit Omega operations on the ordinary checked
path. `omega-harness` section 2 and `omega-communication` record its pin, native host
codebook evidence and trust boundary. The learned experiment is PROPOSED / NOT_RUN; the
bounded reference is MERGED and IMPLEMENTED / EXERCISED on the host, not hardware
QUALIFIED or deployed.

## Host-only NL1R diagnostics

`omega-harness` documents the separate capacity and task-conditioned experiments
under [aien-train #39](https://github.com/aien-dev/aien-train/issues/39), with exact
frozen source/compiler pins, independent judge custody, actual carrier/context
budgets and retained negative results. Constructive capacity, learned recovery,
heldout performance and production execution authority are separate claims.
These host experiments do not qualify device execution or deployment.

## Check the examples yourself

The examples run on Linux AArch64 hosts only. [`examples/`](examples/) holds 105 programs, each
`NAME.om` with `NAME.expect` (and `NAME.stdout` when it prints): every trap, one refusal per error
code, the common mistakes and the known defects. `examples/gate.sh` refuses any compiler but the
pinned one, then compiles and runs every program here and in `skills/*/examples/`:

```sh
git clone rad://z6do9WDBhuSnvopDkgFdFr1yWA62 omega-src
git -C omega-src checkout f4df82394e35893dcf1354dda69a2fe028d94bc1
sha256sum omega-src/seed/out/omc   # 3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194 at main f4df8239 (2026-11-05, #1022 efi 14); b4f45121... at the previous pin d3d1b1bc; be8c5130... at 9920aab1; 24caacf4... at 3a163bc5; 2aec185d... at 91c83438; 734f0a39... at the 2026-10-25 pin 55f9b0af
examples/gate.sh omega-src/seed/out/omc
```

It prints `PASS name` or `FAIL name: reason` per program and ends with
`GATE PASS examples=110 pass=110 fail=0 omc=3ad9f10f...` (exit 0), `GATE FAIL ...` (exit 1), or a hash
refusal (exit 2), for example `GATE FAIL omc sha256 b4f45121..., pinned 3ad9f10f... (omega-mv f4df8239...)`
for the previous pin's compiler. The `omega-encoding` skill (section 0 and section 13) records the observed results
and the negative controls; [`examples/WOLFRAM.md`](examples/WOLFRAM.md) records the Wolfram checks of
the arithmetic expectations.

## Keeping it current

**The agent that makes a change updates the guides.** If your work changes the Omega language, the compiler or its pin, build or gate commands, the encoder or bridge, repository ownership or status, or this harness, update the matching skill in the same piece of work. Then contribute it as a Radicle patch: hand the desk a READY file with the evidence (base, head, bundle, gate logs, negative control); the Radicle publishing lane opens the patch and the desk merges it. Never push to github.com. If you can't, give the desk a note saying what is now stale. `omega-harness` section 6 has the full map of which change goes in which skill.

Each skill names the omega-mv commit it was checked against and lists known disagreements. Historical sections retain their dated pins. `omega-encoding` section 0 adds scoped pins for the IR/wasm backend, the merged Omega 1.0 roadmap, and main `91b3c932` (compiler `189ada82…3b54`): executable contracts, expanded capacity and the f32 return fix. The batch has host evidence, not GPU qualification. When the compiler changes, recheck cited lines, rerun examples, then update pins. Do not edit old evidence. Contributions follow the [shared AIEN agent rules](https://www.aienos.com/agents/RULES.md).

The [native GPU realization guidance](skills/omega-communication/SKILL.md#native-gpu-realization-records-2026-10-28) distinguishes quantization indexes, canonical artifact identity, session residency and independent qualification. It tracks the CUDApp #26 work without treating host fixtures or unmerged components as production admission.

Written by Drake Stapleton with AIEN agents. Apache License 2.0.
