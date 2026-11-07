---
name: omega-harness
description: Operate in Omega and the AIEN repositories. Use for any Omega or .om task, compiler or migration work, AIEN architecture, repository routing, or project status claim. Covers source pins, .om-first implementation, compile and run evidence, safe effects, communication and stopping repeated errors.
---

# Omega Harness: operate, encode, communicate

Merge status, 2026-10-29: omega-mv #904 and #923 are merged (x86 main
`bf54b19fa590e8ae925c0e80815516dbf41e7326`); omega-bridge #40, including the
earlier #37 proposal, merged at `ed420fcbffa1ad83db78111deb836dd880ed891e`.
The pending labels in the dated observations below describe pre-merge tests.
Compiler identities and execution limits are unchanged. Native x86 remains NOT_RUN.

These skills are operating guidance for coding agents. They are not a compiler and cannot guarantee correct output. What they do is require the checks that catch the mistakes agents keep repeating. English is how the work gets steered. Explicit programs, checked contracts and replayable execution evidence are what establish that something was done.

Companion skills in this package:

- `omega-encoding`: the language the seeded compiler actually accepts, with verified examples.
- `writing-omega`: the portable guide for writing a first correct `.om` program, backed by the tested
  programs in `examples/` and `examples/gate.sh`.
- `omega-communication`: status labels, reports, handoffs and corrections.
- `aien-repositories`: what AIEN builds and which repository owns a task.

## Development method: Human-Directed Agentic Engineering

Use Human-Directed Agentic Engineering (HDAE) to describe the development workflow. Humans define the goal, architecture, constraints, acceptance criteria and stopping points. Agents implement, execute checks, diagnose failures and revise inside that boundary. Return architectural decisions, acceptance and release decisions to human review; an agent or advisor cannot enlarge its own authority.

This wording follows the method and systems-software case study documented by Gregory M. Kurtzer, *Ginux: Building an Independent Kernel That Runs Linux Userspace through Human-Directed Agentic Engineering* (2026), [doi:10.5281/zenodo.23682548](https://doi.org/10.5281/zenodo.23682548). It does not rename Omega, change compiler pins, rewrite earlier evidence or establish that an unrun gate passed.

## 1. Orient before acting

1. Identify the owning repository with `aien-repositories`. Record its actual remote, default branch and exact source commit, then read its `AGENTS.md` (or `CLAUDE.md`) and the target directory's `.crumb`. Read `crumb-protocol` before editing, creating or moving a directory, or when a gate reports a stale crumb: it covers reading a crumb, claiming and releasing locks, whispers and regenerating committed crumbs. An open PR, a local branch and a deployed service are three different states.
2. Read `omega-encoding` before writing `.om`. Treat skills, memory and model recall as navigation aids, not language authorities. Check their claims against the chosen revision's `docs/one_layer/OMEGESE.md`, `seed/omc/omc.om`, `seed/host/README.md` and real fixtures. Find a path before opening it; never guess one.
3. Work in an isolated checkout pinned to the canonical source. Do not use another agent's dirty working tree, and never checkout, reset or stash in a shared one. Read lock files and the contracts of callers and the build before choosing dependencies.
4. Write a short plan: intended behavior, invariants, affected consumers, allowed effects, the acceptance command and a negative control. For device work, start from the hardware mechanism and its vendor manual. Having a tool installed does not authorize using it.
5. **Coordinate before you edit (PENDING: the tools below are new; their repos are unmerged drafts until this line is updated).** Ask the map, then take a lease, then edit:
   - `synapse-map where "<task>"`: which repository owns the work, its parent, similar existing repos and the skills to read. Run it before creating a repository; create connected repositories with `synapse-map new <name> --parent <owner/repo> --purpose "<one line>"` instead of growing a parent.
   - `synapse-claims who <target>`, then `synapse-claims claim --agent <id> --session <id> --target <target> --intent "<one line>"` for every repository branch (`branch:aien-dev/r#b`), path glob (`path:aien-dev/r:dir/**`) or outside target (`ext:email:<address>`) you will write to. The `aien-dev/r` slug is only the claim key naming the project; its code lives in the Radicle repository of that name, and the branch you claim is the one your READY file hands to the desk. `pr:aien-dev/r#N` targets name frozen GitHub PRs (history since 2026-11-07); never claim one to write to it. Exit 2 means another agent holds an overlapping lease and names it: do not edit, message the holder. Renew at half the TTL; release with the final state word and evidence.
   - The ledger is append-only, hash-chained and Ed25519-signed; never edit it by hand. `synapse-pulse` reconciles it against GitHub and live sessions and raises one `COORD-DRIFT:` watchdog line for unclaimed PRs on claimed paths, expired leases, contradicted status and duplicate work. The human board is rendered by `synapse-board`; do not hand-append to it once the cutover lands.
   - The same commands are exposed as MCP tools (`coord_where`, `coord_claim`, `coord_who`, ...) by `synapse-mcp`. A lease is coordination, not authority and not a verification verdict.
   - Scope messages: never write to `agent://all`, which wakes parked agents (on 2026-10-27 one broadcast woke eight finished lanes, including a GPU-renting one). Get a lane's recipients with `synapse-claims list --agent-prefix <Lane>` (MCP `coord_lane`) and message each id.

## Mathematics goes through Wolfram (mandatory)

Every computation, derivation, identity check, unit conversion and numeric constant goes through the
Wolfram tools, not mental arithmetic and not a throwaway script. Read `skills/wolfram-math/SKILL.md`:
it carries the rule, the MCP setup that any agent can perform without a human, the two verification
calls, and the failure handling. A session whose Wolfram tools are not mounted is not math-capable:
say so and stop rather than estimating.

A claim that a property holds for **every** case of a finite model (core sets disjoint, a disk floor
kept, one lease holder, a bounded queue) is proved in Lean 4, not argued. Read
`skills/lean-verify/SKILL.md`: it carries the `lean` MCP setup and pins, the rule that a theorem
proves the model and must name its link to the running system, and the ban on `sorry` and
non-standard axioms (`#print axioms`). Wolfram computes values; Lean proves statements about them.

## NL1R host-only experiment boundaries (2026-10-28)

The training experiment belongs to `aien-dev/aien-train`; independent
evaluation belongs to `aien-dev/benchmarks-mv`, not the producer. Follow
[train #39](https://github.com/aien-dev/aien-train/issues/39) and capacity
[draft #40](https://github.com/aien-dev/aien-train/pull/40), final evidence
commit `9061d3b75251d37961268666ab449c5c1a3487cb`, with producer source frozen
at `fed670ae6a7aceabe2ea7db7481e910c8e331b62` before learning.
This is a new diagnostic; the original negative experiment stays unchanged.

Use the exact seeded compiler from omega-mv
`1fe5976d398646b17acabbf6d9dfae96b017e439`, binary SHA256
`d6290c7663c2b4bafb59eb3fdf812476e977f4c144def71095c6248ef9b96b84`.
The replay commands and actual control/mutant receipts are in
`native/neuralese/nl1r/README.md` and its `evidence/` directory at that
capacity commit; no new guide example or compiler pin replaces those receipts.

Capacity is not learning. The recorded Wolfram oracle bounds the original
three-dimensional affine decoder with four output thresholds at 15 strict
patterns; it does not prove that the observed 14/16 is optimal. Constructive
four-coordinate and nonlinear witnesses recover all 16 patterns, but are
not learned checkpoints. Across frozen seeds 17/29/43, random fullfit
accepted-correct counts are 14/14/14 for original affine3, 16/16/16 for
affine4, and 14/15/14 for nonlinear3. Parity heldout counts out of eight
are respectively 5/5/6, 7/8/8 and 5/6/6. Both correlated heldout splits
give every learned arm 0/8; the direct byte baseline gives 8/8.
These are filed measurements in `evidence/public-metrics.json`, not a
general compositionality or optimization guarantee.

The separate task-conditioned experiment freezes source/configuration at
`1bae5bda767c9024c1408ae866c7993eb3d7deb0`, under
`native/neuralese/nl1r-task/`. The sender observes four evidence bits and
the shared task. The receiver gets actual carrier bytes and shared task;
only the declared side-information task additionally receives the first
two original bits. IDs are evaluation labels, not receiver input.
Fixed, dense and factorized carriers each serialize one actual byte;
full evidence uses four ASCII bytes and receiver-only uses no payload.
Dense and factorized share one trained checkpoint and are inference-channel
ablations, not independently trained discrete communication models.

The frozen independent preregistration is benchmarks
`c8aefbc6cf72ea2ca47fe4308bd867cb1a55e86c`, manifest SHA256
`2fe5c72edbfe24df38f70b72275bb008ac71779e66455501662ca8e7d911751c`.
Independent hidden custody and final task results must be reported from
the judge's own receipt, never inferred from producer exit status.
Charge payload, context, checkpoint/codebook, schema, code, metadata,
logs, training and verification costs separately. Quantization spacing is
not a serialized-byte budget. Report wrong acceptance, abstention and
heldout regret as well as successful reconstruction.

The NL4 boundary adapter was source-frozen at train
`18b3d08cdf383033e2c8d674a37325d11f010fc4` (draft
[aien-train#41](https://github.com/aien-dev/aien-train/pull/41)) before
custody opened. `boundary.om` (sha256 `731b682f…aa320ba`) composes the
unchanged NL4 prefix and units and adds no codec, validator or executor.
Every two-bit chunk goes through `lpvalid`, `nlproposal` and `nlmatch`
before any `nlexec` runs. Build it from stdin (`omc < boundary.om > bin`):
a file argument gives error 16. With omc `d6290c76…` the binary is
`a20add32…2d63f`. Errors 7, 9, 12 and 19 from the failed attempts are
kept in `evidence/`. The judge (benchmarks-mv
[#59](https://github.com/aien-dev/benchmarks-mv/pull/59) at
`463123e6aeb77b0ec269f479941310921e6521ff`, `evidence/FINAL-REPORT.md`)
rebuilt it byte-identically and replayed all 9360 original task decisions
with exact stdout, stderr, status and frame match. Of those, 3371 were
accepted, 2243 mismatches refused and 3746 abstentions or omissions
refused. Hidden reveal matched custody commitment `39ce89ee…2772` and all
seven hashes from `8a78e38`. Withheld accepted-correct counts out of 8:
capacity historical 4, four-coordinate 5, learned nonlinear 0, fixed
direct byte 8; task dense/binary reconstruction 4/4, parity 2/4,
receiver side information 4/8. Fixed byte and full evidence score 8/8
on every task, and receiver-only parity scores 4/8, which is chance. No
learned communication or economic advantage over the fixed code is
established.

A task carrier grants no execution authority. NL4 separately verifies its
full typed envelope against independent trusted references. Production
capability/reservation binding, authorized external execution, GPU/device
qualification, live serving and deployment remain **NOT_RUN**. Host
synthetic evidence cannot establish production or economic improvement.

## 2. Implement in the actual language

**Local Mac model experiment, 2026-11-06 (branches, not merged):**
[aien-train `70d048c`](https://github.com/aien-dev/aien-train/tree/70d048c0e1e36150d0ad2998fef992c129914551/tools/omegallm-ui)
adds a temporary C++ llama UI adapter. Its model inference runs in Omega, but
that does not make the host HTTP/process/socket implementation Omega.
The documented successor is an Omega macOS HTTP/JSON and process/socket
runtime; a compiler PR for that successor is absent. Therefore this is
**incomplete language migration**, not an exception that other work may copy
and not full harness compliance. The existing scalar Mach-O bridge does not
establish macOS host-word support. Positive runtime receipts below do not close
this language gap.

- First-party implementation belongs in `.om`. Existing C, Rust and shell are unfinished migration, not permission to add more foreign code. Never pass off a foreign implementation as generated code, vendor code, glue or an `.om` file.
- When the language lacks something, build it (Drake's standing rule, 2026-10-26: "If .om doesn't have a feature, you need to make that feature"). Hand in an omega-mv Radicle patch (`rad:z6do9WDBhuSnvopDkgFdFr1yWA62`) through a READY file to the desk, coordinated with whoever owns the compiler lane, that carries the word or facility, its error code, gates with a negative control, parity against an independent oracle, and the guide update. Do not invent a word you have not implemented, and do not route around the gap with host code. Host code is a last resort only, recorded with its Omega successor and the omega-mv patch that will replace it. A gap that needs a decision Drake has not made (for example heap or imports, omega-mv #793 and #795, frozen GitHub numbers) is put to him rather than built around.
- Seeded Omegese, compiled by `seed/out/omc`, is the forward language. The historical console syntax in `spec/omega-language-v0.md` and the C compiler checks are different things. As of omega-mv main `55f9b0af47de70a3d06357985cf99ae3e45c016f` (2026-10-25), the seeded compiler and its host and device words are on main. Any source saying they exist only on candidate branches is stale.
- Do not promote design ambitions into supported syntax. Check the keyword table, typing and lowering, and the fixtures of the compiler you will actually run. Compiler limits are implementation limits at a pin, not permanent properties of Omega.
- Optimize for verified programs produced per unit of inference cost on held-out tasks (first-attempt correctness, successful compilation, verified behavior, completion time, and total compute cost). Tokenization is not a language rule: fitting vocabulary to single tokens under a specific tokenizer is an empirical cost measurement, not a binding language constraint.
  The token benchmark entry point is
  `sh bench/inference_cost/driver.sh --run-model --endpoint "$AUTHORIZED_ENDPOINT" --model "$MODEL_ID" --langs om,c,py,rs --arms plain,feedback --attempts 3`.
  It never starts a server. Use only an explicitly authorized endpoint; this guide
  update did not contact a model (real token measurements: NOT_RUN).
  Observed negative control at the section 3 candidate pin:
  `sh bench/inference_cost/driver.sh --run-model --model example --langs om,c,py,rs --arms plain,feedback --attempts 3`
  exited 3 and printed exactly:
  ```text
  NOT_RUN: no --endpoint given; no model was contacted
  ```
- Reuse the existing unit composition, error handling, buffer layouts and build patterns. Make bounds, types, ownership, effects and wire encodings explicit. Keep authorization and refusal paths working, not just the happy-path bytes.
- Migrate the actual consumers before deleting a replaced implementation. Preserve history and immutable evidence. Matching a recorded hash does not prove parity with the current foreign reference; where the contract calls for it, run an independently built oracle.
- Route by the ownership rule (Drake's forwarded omega-bridge assessment, 2026-10-27; ADR 0042, Accepted by Drake 2026-10-30, merged as [aien-architecture-mv#342](https://github.com/aien-dev/aien-architecture-mv/pull/342) `6b924d4f8e`): **Omega owns computation, CUDApp owns GPU execution, Omega Bridge owns compatibility.** Language, compiler, compiler pin, semantics and kernel contracts go to omega-mv. Encoders, GPU code generation, cubin writing, disassembly, the driver client, submission and the GPU runtime go to `aien-dev/CUDApp`, even where omega-mv still carries a copy (CUDApp#106, #107, #108, #10, all open). Conversion, bindings, framework attachments and GPU artifact negotiation go to omega-bridge, which never encodes, launches or ships a compiler. A new copy of another repository's owned code needs an ADR amendment first.
- Existing code stays where it is (Drake, 2026-10-27: "keep the repos we've got, but then we make new repos that are connected to the bigger repos"). Do not move, split or rewrite code already in omega-mv, CUDApp, omega-bridge or aienos.com; the copies above stay until Drake decides otherwise. A new standalone server, kit, bench, library or app gets its own Radicle repository (check the hive Radicle registry `RIDS.md` and `synapse-map where` for near-duplicates first; the publishing lane creates it, lanes never create GitHub repositories) that pins its parent by tag or sha, names it in `.crumb`/`.goals.json` (`scaffold-project`, `crumb-protocol`), and is linked both ways (parent README "Connected repos" line). One tool, one job: stdin or files in, plain text or JSONL on stdout, diagnostics on stderr, meaningful exit codes. omega-mv takes only language, compiler and gate changes; aienos.com only the page that consumes a component.
- Conversion between Omega and other languages is not this skill's job. Route it to `aien-dev/omega-bridge`, which implements checked conversion for a declared subset and refuses universal conversion. An MCP wrapper is optional tooling and does not widen what the bridge can convert. A native binding counts as working for a language only when its caller was built and executed by the bridge's native-call runner (section 3); a binding that was generated but never called is IMPLEMENTED, not EXERCISED.
  Bridge ABI2 rollup [PR #15](https://github.com/aien-dev/omega-bridge/pull/15) merged at
  `826cb8aee4a09b65cc1b2e295b1dc9e50e155253` (2026-10-28), preserving its later main
  native-caller gates. Private-linkage [PR #32](https://github.com/aien-dev/omega-bridge/pull/32)
  merged at `31ce3886d7966c27f8208922e27fc79ed76b39c6`: all private ABI1/ABI2 assembly
  runtime, code and entry labels are local, matching static C helpers and hosted per-TU/TLS
  state. Independently generated translation units link without helper collisions; public
  `omega_`/`omega2_` exports and compiler bytes are unchanged. Its private-symbol regression
  checks independent units, trap recovery, concurrent callers, local `nm` bindings and a
  `.globl ombr_enter` link-failure mutant.
  Freestanding [PR #33](https://github.com/aien-dev/omega-bridge/pull/33) merged at
  `37bf93d158e2e4fd7a3c6a1b9a47b569195a2a66`. It adds generator
  output `freest` and `tools/native --freestanding OUTDIR unit.om...`: generated C/header/object,
  same scalar status ABI, caller-owned stack and no pthread, mmap, heap, TLS or mutable runtime
  state. Whole-source validation includes unused helpers and conservatively refuses arrays,
  globals, text, host effects, OM2 and types outside its declared integer/bool scalar subset.
  Traps return status without writing the result; nested and concurrent calls remain isolated.
  PENDING [omega-bridge#45](https://github.com/aien-dev/omega-bridge/pull/45) (draft, head
  `72d6dbc`, not merged): it lifts the OM2 refusal. OM-2 units get output `freest` plus `fapic`
  (`omega_api_decl.h` and `omega_api_defs.{c,o}`, whose wrappers `__builtin_trap()` on a nonzero
  status instead of calling `abort()`) on AArch64 and on `--target x86linux`. Verification is
  HOST_TESTED on AArch64 (`tests/native/test_freestanding_om2.py` from `tests/native/v2/run.sh`)
  and EMULATED on x86 under QEMU 10.0.14 (suite step `freestanding_om2_x86`, 345 PASS); native
  x86 is NOT_RUN. Until #45 merges, main still refuses OM2 here.
  The undefined-import gate permits only the GPU_FS_LINK libc-string allowlist; failed symbol
  extraction/filtering refuses installation. One private input snapshot supplies profile,
  compilation, framing and identity. Tests exercise the pthread-import mutant, failed/missing
  inspectors and a deterministic source swap whose original-reread mutant admits mismatched code.
  Framed source/code must still match the pinned compiler: this is not an arbitrary-bytecode sandbox.
  Current bridge main source pin, including bounded-capacity
  [PR #35](https://github.com/aien-dev/omega-bridge/pull/35) and ABI-v2 verdict
  [PR #34](https://github.com/aien-dev/omega-bridge/pull/34), is
  `0c4cb9ff980af278890b231b994eaede4dc7621c` (2026-10-28; native.om SHA256 unchanged:
  `d3cfe0561696aad92164ddf11340522645cf6daf7af238835c3d3c61ecdef656`).
  Fixed pools hold 4194304 input bytes (accepted input strictly smaller) and 16777216 output
  bytes; exhaustion exits 106 before output. Compiler/per-unit limits are unchanged.
  Historical host evidence with configured language-toolchain PATH: all seven native callers,
  build-failure controls and ABI2 suite passed; private/freestanding controls and a compiler-matched
  16-unit frame beyond both old pool sizes
  passed, while old-bound mutants and both current-overflow probes refused. The independent
  31-root consumer frame emitted and C-compiled with both pinned compilers; those 31 consumer
  functions were not executed by this qualification. Evidence is under
  `evidence/native-{private-symbols,freestanding,capacity}/`. Capacity's
  `coverage-correction.log` preserves and corrects an earlier overclaim; use
  `native-boundaries.log` and `qualification-boundaries.json` for current boundary coverage.
  Remote CodeQL checks are analysis, not functional execution. This is MERGED and HOST EXERCISED,
  not deployed or GPU-qualified.
  A separate ordinary-process-PATH replay at `0c4cb9ff` built and executed C, BTI-C, C++, Python,
  Rust2021 and Rust2024 successfully, but neither Zig nor Go was discoverable on that PATH.
  Both full runners returned exit 1: `NATIVE-CALL NOT_RUN (not run: zig go)` and
  `NATIVE-V2 NOT_RUN (not run: zig go)`. This does not retract the historical configured-PATH
  Zig/Go executions: their logs have individual successful caller lines, not merely aggregate PASS.
  Java, Swift and Node/JavaScript are not callers in these suites. See the
  [coverage clarification and replay receipt hashes](https://github.com/aien-dev/omega-bridge/pull/34#issuecomment-6473079219).
- **PENDING (draft [omega-bridge #56](https://github.com/aien-dev/omega-bridge/pull/56), not merged; results below at head `bc11b30`, head `f9f1f7cf` on 2026-11-05):** the additive seeded C frontend (`tools/bridge-seeded c`, omc `2c824805…029f`) lowers internal `f32`/`f64` scalars, unsuffixed float constants (table of 1024; a suffixed or integer literal is error 16, more than 19 significant digits or overflow to infinity error 8, as in omc), float `add sub mul div neg fabs`, compares, int<->float and f32<->f64 conversions and same-width bitcasts, bit-for-bit with omc's AArch64 output. Baseline `tools/bridge`, Python and public float parameters/arrays still refuse floats. omc decimal conversion is not always correctly rounded ([omega-mv #1024](https://github.com/aien-dev/omega-mv/issues/1024)); the bridge reproduces omc's bits. EXERCISED host plus x86-64 EMULATED (`tests/seeded_float.py`, and CUDApp#147 `mathlibs_ir.om` across 89 cases with identical native/C/x86 bytes); physical x86 and chip NOT_RUN. Until #56 merges, bridge main refuses all floats.
- **Host words in bridged units: bridge side MERGED, compiler side PENDING.** [omega-bridge#54](https://github.com/aien-dev/omega-bridge/pull/54) (merged 2026-11-05 as `d1124611`, head `2518f9f7`; first reviewed 2026-10-31 at `c7f432cd93dc728a8c699b2787cd9a9513a7f84f`) adds `tools/native --host`, built on draft [omega-mv#1008](https://github.com/aien-dev/omega-mv/pull/1008) (a pin mover; tested at `78fa7ec3` with omc sha256 `3988c31f9697a01f1436b7a75f6c956b37bc5301155b3ec8ca1b06b92118f7c4`, the compiler bridge `docs/NATIVE-ABI.md` still names; open draft head `2992a68b` with omc `c000ec02…b911` on 2026-11-05; contract in the PROPOSED `spec/omegese-om3.md` section 1, because OM-2 is frozen). With it an OM-2 function unit may call nine host words, `fclose fopen fstat stat getuid geteuid getgid getegid lstat`, and a Rust/C/... caller runs that unit in-process. Without `--host` any host word in the unit is refused (110, nothing installed); with it every other host word, any host word in an OM-1 unit, `--target x86linux` and `--freestanding` stay refused. The words used are named in the identity (` host=...`). These words are no sandbox: they run with the caller's credentials and descriptors, a trap between `fopen` and `fclose` leaks the descriptor, and out buffers (e.g. a returned secret) stay on the Omega stack until the next call. First consumer: [open-humanity#54](https://github.com/aien-dev/open-humanity/pull/54) (merged `41299541`) (`crates/oh-infer/om/tkcheck.om`, pins in `om/PIN`, `om/regen.sh --check`), which replaced a `libc` token-file check on Drake's request. Bridge main has `--host`, but until #1008 merges and is pinned, main's omc (`b4f45121…`) still refuses every host word in a function unit (error 9), so a `--host` unit needs the #1008 compiler; do not cite it as main compiler behavior.
- MERGED: the additive portable frontend [omega-bridge #36](https://github.com/aien-dev/omega-bridge/pull/36),
  head `3dc4a00e9966770cce58bdedb401c3b3932c35ee`, merge
  `2ed42c3818e72da321c3218d22d7662be607633c` (2026-11-01). It is separate from the
  native-call qualification above. `tools/bridge-seeded c|python|h` requires the exact
  omega-mv `e5b32567` compiler SHA256
  `2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f`.
  It checks one source snapshot before emitting portable checked C, Python or the final
  function's C declaration after validating all bodies. It adds bounded numeric constants,
  six parameters, 512 functions, long function names, larger fixed view/edit shapes,
  explicit view/edit call prefixes, loop break and seeded-C continue. Seeded C supports
  internal binary32 literals, bitcasts, fabs, multiply and ordered le for canonical quant
  roots. Public float ABI, float arrays, numeric float casts and other float operators
  remain refused; baseline/Python float inputs are unchanged refusals. It neither imports
  arbitrary C/Python nor replaces baseline `191b776e`, `tools/bridge` or `tools/test.sh`.
  Integer `bitcast` remains refused by seeded C at bridge main
  `29d9cff72676bcef41a067bdcf4d8b0711042bcd`, rechecked 2026-11-06 with omc
  `2c824805…029f` (`e5b32567`, distinct from the harness example compiler).
  `fn bcneg x long to ulong` / `ret bitcast ulong x` / `end`, the reversed
  `ulong`-to-`long` unit, and the `uint`-to-`int` unit each compile with MCP omc,
  but `OMEGA_SEEDED_OMC=<e5b32567-omc> sh tools/bridge-seeded c unit.om`
  exits 24 with `toc: line 2: error 24` / `unsupported bridge capability`.
  An explicit bool branch returning integer 1 or 0 is a passing converter control.
  Do not replace integer reinterpretation with a checked numeric cast: their contracts differ.
  The merged converter source `src/toc.om` SHA256 is
  `3a416aea14770bd3fab4880337e89020c10476214d7a3c139d8cd1a8ba1423e6`. The earlier
  tested source `ead98302` had `9116caab9b46e8bea1f1f3dc2752b4f2cdec0d4e266859167e6814085dd4fed3`;
  the only converter change since is `916d9f6d`: seeded C/Python loop and while guards
  now trap 4 after omc's 1,000,000 passes instead of 16,777,216.
  `tools/bridge-seeded` SHA256 is
  `23ff7a2356bb5d980060a4685a27ac46587013069b7d24b37c2873d7ee659b37`.
  Consumers record each source-unit SHA256 and generated-C SHA256. The generated C can
  build and execute on native Linux x86-64 without embedding AArch64 Omega machine code;
  generating it still needs the pinned AArch64 compiler. Function-unit wrapper statuses
  are 0 completion, 1 through 14 traps, 32 invalid arguments/alias and 33 reentry.
  C view pointers are const-qualified; edit pointers remain writable.
  Seeded source scalar declarations carry an unused attribute without skipping initializer
  effects, and literal-count loops omit unused guard counters. Strict host coverage keeps
  `-Wall -Wextra -Werror` and adds an annotation-removal negative control.
  `tools/bridge-freest c|h` separately checks an integer-only, stateless,
  nontrapping whole-unit subset and emits import-free scalar C. Revision/epoch
  and binary32-to-binary16 RNE conversion use separate translation units, no TLS,
  libc, setjmp or native machine code. The latter is first-party integer Omega;
  the hosted `_Float16` cast remains a verification oracle. CUDApp
  [PR #170](https://github.com/aien-dev/CUDApp/pull/170) merged 2026-10-31 as
  `be8aea4b64` (bridge lock `ead98302`); CUDApp
  [#245](https://github.com/aien-dev/CUDApp/pull/245), merge
  `c8ccbc34e4cb0b46693f2c6f8321c7c52eb88429` (2026-11-01), moved the lock to `3dc4a00e`.
  At #170 source `3b6ca6fda726a6b2eb01100ae155fbcb890d00af` it completed the unchanged
  58-target ARM host suite, including 40-root regeneration, f16 boundaries,
  sweep and six mutants, native-artifact, zero-CUDA, device-build and
  cubin-disassembly checks. Device-build is not device execution:
  physical Ampere remains **NOT_RUN**.
  `src/freest.om` SHA256 is
  `836cbf9ef8a3c4ee82b0458070884405bc8296f83b10f933556bf27750bb3661`;
  frontend SHA256 is
  `51b41794e7001c5606b715fd7de8a34ec935a6e4e4bc1da36ad08102c009537d`.
  `python3 tests/freest.py` checks actual roots, O0/O2 imports/TLS, x86 emulation,
  28 whole-unit refusal cases and a wrong-result negative control. The integrated
  strict O2 hosted comparison passed; the earlier isolated O0 receipt stays historical.
  Unsigned shifts are accepted only with a literal or resolved constant count
  below the source operand width. Dynamic, negative, boolean, signed-operand
  and out-of-width shifts remain whole-unit refusals, including unused helpers.
  Additional tests compare every unsigned width against the pinned compiler
  and exact Wolfram boundary values; a wrong-direction shift mutant is refused.
  The unchanged baseline suite and seeded differential/control suites were exercised
  during recovery, including binary32 byte parity and float/fast-math refusals.
  Run `tools/test.sh`, `python3 tests/seeded.py` and `python3 tests/seeded_float.py`
  with the exact compilers. The native x86 compiler remains a separate failing path,
  never an assumed dependency of this portable C route.
  No device qualification follows from generated C or x86 host execution.
  [Behavior CI](https://github.com/aien-dev/omega-bridge/actions/runs/40758894095)
  passed at source `ead98302`, and the same workflow passed at the merge
  [`2ed42c38`](https://github.com/aien-dev/omega-bridge/actions/runs/41320157337)
  and at bridge main `7af4d11c`
  ([run 41352235699](https://github.com/aien-dev/omega-bridge/actions/runs/41352235699)):
  source bootstrap, unchanged baseline suite,
  seeded differentials/binary32 refusals, native AArch64 scalar controls
  and explicit-QEMU x86 scalar controls. This is exercised behavior,
  not merely CodeQL and not CUDApp's whole-consumer native x86 acceptance.
  CUDApp's x86 consumer CI source-bootstraps the exact baseline on AArch64,
  verifies its artifact hash and the seeded compiler hash, then uses
  verification-only QEMU `8.2.2+ds-0ubuntu1.19` for ARM provenance on a
  disposable x86 runner. Its package SHA256 is
  `ec80ee896fe8f57f7420f4d4076164cb0fa613df6848568cdf5d1a2dbe2347cb`,
  interpreter SHA256
  `1152646a17920a81c618d62574ee8ae8b63243349957095d40212c2245f20aab`.
  The registration is checked against the exact ARM-only magic/mask and
  removed by an always-run teardown. No Spark host configuration changes.
  ARM compiler/converter provenance is EMULATED; compiled-C x86 consumer
  executables are NATIVE and must still pass their unchanged acceptance.
  This dependency is a verification oracle, not production code. Its
  intended Omega replacement is the separate, still-failing native x86
  compiler. Historical native x86 consumer
  [workflow 40762515409](https://github.com/aien-dev/CUDApp/actions/runs/40762515409)
  passed at `592cee` (test merge `6a2b759`), including 58 targets,
  40 roots and 2,169 oracle comparisons; it is not current-head evidence.
  Current-source native x86
  [workflow 40776306246](https://github.com/aien-dev/CUDApp/actions/runs/40776306246)
  completed successfully at source `3b6ca6fda726a6b2eb01100ae155fbcb890d00af`,
  tested PR merge `cf65a61c8b95f7d0d7b51c5618a9dc87bcbb8cf4`.
  Its provenance and native-consumer jobs passed: 58 host targets,
  40 byte-identical roots, 2,169 offline kernel oracle comparisons,
  73 native FP8 refusals, f16 sweep/six mutants and operand/MMIO/arithmetic/
  branch/join/barrier/carry controls. The 17-file freestanding aggregate
  imports only `memcmp`, `memcpy`, `memset`, `strcmp` and `strlen`.
  This is native generated-C consumer evidence, not native Omega compiler,
  physical GPU or production qualification. With the lock at `3dc4a00e`, CUDApp's
  [Ampere native x86 host](https://github.com/aien-dev/CUDApp/actions/runs/41320173269)
  workflow passed at `c8ccbc34`.
  The current fixture writer creates new output files with mode 0600,
  including under umask 000; it intentionally preserves existing-file modes.
  The historical writer creates mode 0666 with identical bytes, so the
  permission negative control fails as required. Five wrong compiler/bridge
  pins refuse with exit 3 and no installed output. Earlier stale-build
  failures remain historical evidence, not current clean-suite results.
- MERGED: the Omega Universal Translation adapters (omega-mv #624) from [#755](https://github.com/aien-dev/omega-mv/pull/755) (final head `b8957b878f`) are on omega-mv main via train r2 [#972](https://github.com/aien-dev/omega-mv/pull/972), squash `f5c9bd89ae604a65d7c777a5739c176f41a036ec`. They are seeded-Omega importers and exporters for profile S1 only (`spec/universal/translation-v1.md`): one pure function with 0..6 `u64` inputs, built from constants and `+ - *` modulo 2^64, in C17, Rust, Python, C++17, Zig and Go, plus `retarget` and `lower` (lowering through omc `734f0a39...6b61`, the `T624_OMC_SHA256` pin in `mk/translation.mk`, to a native unit bound by omega-bridge `tools/native`). Each tool reads one unit on stdin and writes stdout only on success. A refusal names itself on stderr and exits with the spec's status (64 bad command or name, 65 malformed envelope, 67 LIMIT, 68 PROFILE_MISMATCH). The tools are not reentrant, so run one process per call. Coverage is 12 directions and 30 directed compositions. MEASURED 2026-10-31 on the host (AArch64, cores 5-9 nice 19) at main `91c83438daec0bdb88bf5c077cae10f3d15d365d`, with `OMEGA_NATIVE_OMC` sha256 `734f0a39...6b61`, `OMEGA_BRIDGE_REPO`=`SA_SEED_REPO` an omega-bridge clone holding `0fc7d866`, Go 1.27.3 and Zig 0.17.0: the G3 chain run stage by stage (`make -f mk/translation.mk test-translation-g2`, then `test-source-aware-v2`, `test-retarget`, `test-cpp-u64`, `test-zig-u64`, `test-go-u64` and `make -f mk/translation-validate.mk test-translation-compose-v2`) all exited 0; compose-v2 reported 30 directed compositions plus 6 same-language round trips, `pass 636 fail 0 not_run 0`. Controls: without `ZIG` the Zig stage refuses (exit 2), and Go 1.25.14 against the `go >= 1.27` module fails the Go stage (exit 2) rather than passing. The earlier independent #623 validation passed at head `2d4c6407`. Anything outside S1 is refused, not approximated. The next profile, S2 (signed i64, comparisons, select), is specified in `spec/universal/translation-s2-v1.md` ([#822](https://github.com/aien-dev/omega-mv/pull/822), merged `56d979c4`) with status PROPOSED and no implementing tool on main; its C import, Rust export and lowering are on open [#839](https://github.com/aien-dev/omega-mv/pull/839) (host-tested, not qualified, not merged). The bridge statement above still holds for the bridge itself.
- PENDING, draft [omega-bridge #23](https://github.com/aien-dev/omega-bridge/pull/23) (head `b04dc851`, last pushed 2026-10-27; rechecked 2026-11-04: open, draft, not merged, and conflicting with bridge main): the native binding (`src/native.om`) also binds `edit`/`view f32` arrays and array lengths named by `const NAME ulong DIGITS` lines, and `pytorch/` adds `torch.compile(model, backend="omega")`. That backend lowers core-ATen `mm`, `addmm`, 2-D `permute [1,0]`, `add.Tensor`, `relu` and `_softmax` (float32, static shapes, inference only) to `.om` kernels compiled by omega-mv `369dbc96` `omc` (`2c82480596bb…029f`), not by the current guide pin. Every other op raises at compile time; eager fallback only happens for ops the caller names, and each such call is counted. Describe it exactly as "EXERCISED: CPU, oracle = PyTorch eager, Omega-native codegen, Python glue", never as "Omega runs PyTorch". The Python glue is an interim migration step; its named successor is a PrivateUse1 `omega` device dispatched by an Omega unit through the bridge C ABI. TorchDynamo touches CUDA while tracing, so run it with `CUDA_VISIBLE_DEVICES=` outside an authorized GPU window. At that omc, a function needing more than 16 registers fails with error 12, and large shape constants add to that pressure. Split hot expressions into helper functions and incremental indices; the pressure gets worse as constants grow.
- The scalar IR-to-WebAssembly backend is owned by omega-mv, not a foreign-source import:
  [#787](https://github.com/aien-dev/omega-mv/pull/787) merged as
  `3364a1dfd0ca50c1b82bf19ba34932d8bc10a7a9`, after boolean IR fix
  [#786](https://github.com/aien-dev/omega-mv/pull/786) merged as
  `87489da90a1a7a750fd4a7f9eeb005b1221721f6`. It is written in seeded Omega.
  See `omega-encoding` section 0 for tested hashes, exact limits and refusal boundary.
  Source merge status does not establish browser deployment.
- Optional kernel-leaf/compiler ABI work is pending
  [omega-mv #925](https://github.com/aien-dev/omega-mv/pull/925) and
  [omega-bridge #38](https://github.com/aien-dev/omega-bridge/pull/38);
  exact tested sources/hashes are in `omega-encoding` section 0. It is a narrow
  scalar experiment, not a driver-enabling prerequisite or supported kernel
  transport. Linux callbacks already run in kernel context; direct userspace
  EL1 access and OS replacement are not requirements. Existing function-mode
  continuations need a checked primitive adapter and reviewed target hardening,
  not arbitrary extern calls. Host scalar execution and single-object kbuild
  comparison passed; module/kernel/device execution did not run. No active
  compiler pin, native-command fingerprint, trust path or loading authority
  changes. First-party policy/generation remains `.om`; GNU object tooling is
  a disclosed dependency, not an independent Omega driver.
- No outside dependency is adopted silently (Drake, 2026-10-25). When the work needs one, code it in seeded Omega and route any conversion through `aien-dev/omega-bridge` — which, per `docs/CAPABILITIES.md` and `docs/NATIVE-ABI.md`, emits checked C and Python from a bounded `.om` subset and lets foreign callers call compiled Omega units. It does **not** import arbitrary C or Python (`Python/C input conversion is not implemented`), so an existing host implementation cannot be pulled in; a missing converter is a concrete extension proposal, not an assumption. A host binary, library or language runtime that remains in the build or production path gets its exact version, what it does for us, and the Omega replacement recorded next to the artifact. Verification oracles are exempt: the pinned compiler, QEMU/OVMF and read-only checkers (mtools, sgdisk, fsck.vfat, git, gh) stay in use.

### Neuralese supplement: merged reference, not a second execution language

Keep **Omega**. Neuralese is a **PROPOSED** learned-representation supplement,
not a rename, new compiler mode or latent-reasoning claim. The bounded native
reference from omega-mv #919 is **MERGED** and **IMPLEMENTED / EXERCISED (host)**,
not QUALIFIED or DEPLOYED: train r1 [#971](https://github.com/aien-dev/omega-mv/pull/971)
merged it as `f56a372aec4909f0601bb4f74ce07b066dd54cf2`
([#919 close comment](https://github.com/aien-dev/omega-mv/pull/919#issuecomment-6529992046)).
Current pin: omega-mv main `f4df82394e35893dcf1354dda69a2fe028d94bc1`. The original
evidence pins were documentation `e79566c191ea8ef11888e69ce50d8fadf375d4fd` and clean
implementation `39e89fb1c2aaed99ddc05ec565274dd05792b70f` on main `6999fa9e6`.

- Read `neuralese/README.md` at the current pin. Bind producer model/artifact and decoder
  identities, dimension, dtype, canonical byte encoding and checksum explicitly.
  Different models/layers/decoder revisions are not interchangeable. The current
  producer is explicitly a hand-authored fixture, not a trained model.
- Treat every representation as untrusted data. Decode only into explicit Omega
  operations; preserve the envelope and decoded artifact. Feed the output through
  the ordinary compiler, kept runtime contracts and receiver's existing
  effect/capability admission policy. No decoder-created authority or privileged
  execution path is permitted.
- The reference codebook emits only pure scalar operations and uses `om2 debug`.
  Native host words use ambient process permissions, not general capability
  confinement. This patch is not a sandbox for arbitrary source. An effectful
  proposal without a checked receiver executor must be refused.
- First-party implementation and the existing host conductor are `.om`.
  `neuralese/decode.om` composes with `om/tls/sha2.om`; static independent byte
  fixtures do not introduce a host decoder or runtime dependency.

The original run used compiler `seed/out/omc` SHA-256
`d6290c7663c2b4bafb59eb3fdf812476e977f4c144def71095c6248ef9b96b84` (receipt
`neuralese/host-results.287fdc263f7af93107c378ba63c92202a0e6c1479cb1ff6971706b423b0b15fb.json`,
kept unedited on main). The conductor refuses any compiler other than the pinned one,
so at main `f4df8239` use the current omc SHA-256. From a fresh Linux AArch64 clone,
with the scratch directory absent:

```sh
mkdir -p build
if seed/out/omc < seed/qualification/om2/gate.om > build/neuralese-gate; then
  chmod +x build/neuralese-gate &&
  build/neuralese-gate seed/out/omc \
    3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194 \
    neuralese/host.cases build/neuralese-host
else
  exit 1
fi
```

MEASURED 2026-11-05 at main `2a1e6d29` (omc `3ad9f10f...3194`, the `f4df8239` pin, clean detached worktree):
`OM2GATE PASS cases=54 pass=54 fail=0 invalid=0 not_run=0` (exit 0); passing the previous pin hash
`b4f45121` gives `OM2GATE INVALID cases=54 pass=0 fail=0 invalid=0 not_run=54`.
MEASURED 2026-11-04 at main `d3d1b1bc` (omc `b4f45121...9b55`, clean detached worktree):
`OM2GATE PASS cases=54 pass=54 fail=0 invalid=0 not_run=0` (exit 0); passing the previous pin hash
`be8c5130` gives `OM2GATE INVALID cases=54 pass=0 fail=0 invalid=0 not_run=54` (exit 3).
MEASURED 2026-10-31 at main `9920aab1` (omc `be8c5130...448a`): the same PASS count as at
`3a163bc5` (omc `24caacf4...abb7`), at `91c83438` (omc `2aec185d...d8d5`) and in the original
`d6290c76` receipt; passing the previous pin hash `24caacf4` to the same conductor gives
`OM2GATE INVALID cases=54 pass=0 fail=0 invalid=0 not_run=54` (exit 3). Earlier negative control (2026-10-31 at `91c83438`): one byte appended to
`neuralese/fixtures/positive-1-7.om` gives `decode-positive-1-7 FAIL ... stdout differs
at byte 128` and `OM2GATE FAIL cases=54 pass=53 fail=1`. Cases include exact
decoded-source and executed-result checks, seventeen guard-removal mutant kills,
a wrong-codebook control, type/purity refusals and runtime contracts. The learned-producer experiment remains
**PROPOSED / NOT_RUN**: same tasks and independent acceptance checks for source
text, structured operations and a pinned compatible learned producer/decoder.
No model, GPU, live service or compiler syntax change was used in this work.

### NL3/NL4 canonical latent boundary (source lanes merged)

The canonical LTP0 schema belongs to
[aien-protocols-mv #71](https://github.com/aien-dev/aien-protocols-mv/pull/71),
reviewed source `6fb728a14781eb4e5262ffbdc9c2e6be64974f36`, merged as squash
`703eb1b2fdf72cc03ef9851957d70054957e01fe`; not a second Omega wire format.
Its `specs/latent-payload/validator.om` SHA-256 is
`e85d174839f7d0c3406f783ec0fd69d52ce5576bdcca4892c16b21b09f14b003`.
Compose after `om2 debug`, with the pinned Omega `om/tls/sha2.om`.
The native API is
`lpvalid(frame view uchar *, context view uchar *, now ulong, lastseq ulong) -> int`;
the comma notation here describes the API, not Omega source syntax.
The receiver owns the exact1024-byte context. Status0 means structural and
template conformance only: rank/shape/contiguous strides, precision/quantization,
finite f32 payload, time, seq and receiver challenge, identity/context fields,
reserved bytes and SHA256 integrity. It does not authenticate a sender, allocate
a challenge, consume a durable attempt, verify consent against current authority,
or grant a capability. The source lane's recorded133-case host result belongs
to that exact source/evidence pair; it is not production qualification.

LTP0 field101 is the producer-node effect class, not a receiver grant.
Fields192/224 are existing producer MJR1 DAG/input-binding fields.
Production relation is completed producer MJR1.output_digest ==
SHA256(whole LTP0) == independently admitted consumer CONTENT.digest, with
generation and objective/tenant/subject agreement. The consumer's verifier and
capability admission are independent. Do not invent a self-hashing producer DAG,
an omitted-operand binding, parent/child authority, or producer-supplied trust
booleans. Signed MJB/MJR relation and atomic durable replay admission are NOT_RUN.

[omega-mv #920](https://github.com/aien-dev/omega-mv/issues/920) consumes this
validator and NL1's fixed Hadamard unit, not another implementation:
train source `0e01c58a41f1a2fb976efa75c1cc554503aa2ee4`,
`native/neuralese/hadamard.om` SHA-256
`da4a1b91fcd72b4f5fa3a70461932626acdbc62a9a8d0b9876433f4a44f6ed20`.
Retain its AGPL-3.0-only license in composed executables. The native NL4
`nl4-dependencies.json` locks exact source versions, paths and licenses.
The numerical projection proposes explicit uint operands, output shape and
resource/effect bounds. Independent receiver expectation must match every typed
field before ordinary compiled `om2 debug` operations run.
Only closed pure host-synthetic operations are in scope; all nonzero effect
classes and native-model profiles refuse. No vector bytes become instructions.
`NL4R1` is a HOST_SYNTHETIC stream, not an authorized production receipt.
Never infer learned-channel quality from these deterministic fixed-codebook cases.

The absent bindings are owner proposals, not decoder-created authority:
[AEGIS #79](https://github.com/aien-dev/aegis-runtime-mv/issues/79) binds the
existing gateway/capability admission, and
[protocols #70](https://github.com/aien-dev/aien-protocols-mv/issues/70) binds
the existing atomic durable microjob reservation after `lpvalid`.
Effects remain refused until those existing owner paths are actually exercised.
No new compiler, scheduler, Cortex writer, authority or protocol is needed here.

Compiler hash resolution is source-backed: `d6290c76...` is the committed
`seed/out/omc` introduced by Omega
`1fe5976d398646b17acabbf6d9dfae96b017e439`, matching the full hash above.
Older `2c824805...` (82a399b9) and `49923639...` (ec07d25d) are distinct historical
binaries, not aliases. Do not compile this candidate with a stale mounted pin
and claim the result covers the candidate compiler.

NL4 exercised implementation pin:
`09b1394fe68287eaa10b0d90cf07a9dd00e6cb60`, merged to omega-mv main by train
[#971](https://github.com/aien-dev/omega-mv/pull/971) squash
`f56a372aec4909f0601bb4f74ce07b066dd54cf2` (omega-mv #922).
Its native unchanged OM2GATE conductor observed
`OM2GATE PASS cases=63 pass=63 fail=0 invalid=0 not_run=0`;
the inherited #919 suite separately observed 54/54 PASS.
Rerun 2026-10-31 at omega-mv main `91c83438daec0bdb88bf5c077cae10f3d15d365d`,
omc sha256 `2aec185d4ed6d7a6a5779ed656b4e56904742bde5551b02893fb5f73916ad8d5`,
validator taken from protocols merge `703eb1b2` (byte-identical, same SHA-256):
`OM2GATE PASS cases=63 pass=63` (exit 0); one byte appended to the
`f32-double0` expected fixture gives `OM2GATE FAIL cases=63 pass=62 fail=1` (exit 1).
The content-addressed HOST_SYNTHETIC receipt is
`neuralese/nl4-host-results.03b624d6ad393604d958f554fc55844885712ca49f425f98459974846e9e5280.json`.
Read `neuralese/README.md` and `nl4-dependencies.json` at that exact source for
reproduction and source/license staging. Do not concatenate the consumer before
the Hadamard globals: compose entry + Hadamard unit + proposal + validator + SHA2.
No examples in this guide were changed; no compiler or language pin was changed.
The protocol source/evidence head was
`01b5dc3c9f127d988d7c4e5c9ab10ef8dd140d2e`; at merge `703eb1b2` its
`specs/latent-payload/evidence/host-final.log` still records
`OM2GATE PASS cases=133 pass=133`. That is host structural conformance, not
MJB/MJR authority or production qualification. The independent NL6 replay is
[benchmarks #56](https://github.com/aien-dev/benchmarks-mv/pull/56), merged as
`b1cefe485099f8c7092055274b1844edcb02726f`.


### Pending independent GPU driver host slice

`aien-dev/omega-gpu-driver` [draft #6](https://github.com/aien-dev/omega-gpu-driver/pull/6),
stacked on drafts #4/#3, has candidate source `95383da4789556c9ca09befb9c6ab788e4e25d79`
(2026-10-28). It remains pending, not main, qualified or deployed. Its compiler is specifically
`omega-mv@397e67040fb74853c6814097fe02ae4e1ebd6f66` (draft #890 atop #878),
omc sha256 `bcfa582892afca8f65e551fe56867d918d86e84540c7381be8fa9ef18d0cf0f6`,
not the different compiler candidate in section 3. Protocol authority is NVIDIA
`open-gpu-kernel-modules@20e4e6e19cc26ba47b5cbe23130a396be100c427` (580.173.02);
the independent boot-image oracle is
`aienux@a108b1144a064aa7b824374a622d627c6ba91fd1` (#463). This deliberately corrects
the old `c5bb3a4b` oracle's common-mode GB10B COT bug: the vendor GB10B MCTP HAL
returns 1, not SOM|EOM `0xc0000000`. The old-value mutant now fails exact parity.
Do not treat the former matching C/Omega bytes as proof of the corrected header.

Seeded `.om` now encodes the complete bounded boot arena/COT and non-CC RPC frames,
boot/guest/static handshake, RM allocation/control/free and timeout/error/sequencer suspension.
Reuse `gsp/sysinfo.om` and `chan/params.om`; do not duplicate their encoders.
`gsp/owned.om` stages complete arena bytes through an owned checked map handle and binds
uncertain boot completion to retention of the matching published backing. It is not a real
queue publisher, memory fence, firmware authenticator or hardware RPC endpoint.

At the former `b1c8e6e` candidate all 27 original host runners were exercised. At the
new candidate all 29 `tests/*.sh` host runners have final exit0 with the pinned compiler
and corrected clean C reference. Initial failures are retained: a redundant profile guard
required updating the behavior mutant, and the private window simulator needed the pinned
`build/omc` link; the affected gates were rerun successfully. See
`tests/gsp-qualification-host-receipt.txt` for exact commands, outcomes and assembly/binary
hashes. All 13 arena mutants (including old MCTP) and six compiling SEC2 mutants were detected.
GB20B has 15 passing simulator cases, including wrong profile/package, secure-boot/response
timeouts, bad envelope, firmware error, pointer failure and delayed success.
GCC 13.3.0-6ubuntu2~24.04.1 and Python 3.12.3 are verification-only dependencies.

`gsp/arena.om` profile 2 and `gsp/sec2.om` implement the vendor-selected GB20B cold-production
COTv2 candidate: gb20y and distinct GB20B boot/FMC source profiles, zero FRTS fields,
FWSEC scratch wait and MSGQ command-response validation before common GSP completion.
Package mismatches refuse before register effects. `gpchip` remains GB10B-only transport
admission; `gpclass` classification is not admission. Existing `fwprep` still extracts GB10B,
and caller package assertions are not firmware authentication. The GB20B fixture is synthetic,
not an authenticated extracted package. Read the candidate's `GB20B.md` before composing it.
Vendor secure-boot timing requires a native monotonic timer policy, not a simulator poll count.

Mapped queue cursors use aligned `mapget`/`mapset`; the pinned compiler brackets each with
DSB SY. That is process instruction ordering only, not device coherency, cache maintenance or
`dma_wmb`/`dma_rmb`. Channels follow prepared (`chprep`) -> RM-scheduled (submit-ready) ->
disabled (prepared); hardware sequencer dispatch is refused whole before any effect.
Completion-semaphore progress is not engine idle; WFI/membar is a separate absent effect.
A private implementation outside this public repository is a separate track and is not part
of this candidate.

Hardware and kernel execution remain NOT_RUN. Preserve production refusal until measured device
identity, owned live queue transport, release/acquire/coherency, queue notification, sequencer
dispatch, channel scheduling, completion-semaphore progress and fault/drain idle proof exist.
Published or quarantined backing is retained, never automatically reclaimed after a timeout.
The Linux-process ELF/VFIO compiler profile can remove NVIDIA modules only while retaining Linux
VFIO/IOMMU services; it is not an Omega kernel module or a completed kernel replacement.
A separate reviewed kernel execution/effects profile, typed DMA/MMIO spans and deferred IRQ
transport are required for kernel execution. No device/VFIO open, service/module change,
authorization, gate or trust change was part of this host work.

`build.sh` still builds only `w0`/`fwprep`, not a composed `ogd boot/hello/exec`.
The native Aienux loader/ABI, profile-bound MMIO/DMA/IRQ capabilities, visibility fence,
uncached completion and quiesce/bus-master-off before SMMU reclaim remain absent effects.
The documented minimal W0 identity request is unexecuted and requires current operator
authorization: VFIO open/release can implicitly FLR/SBR even for read-only BOOT_42.
Never infer a hardware window or service-stop permission from these host receipts.

## 3. Compile, execute, challenge

Use the target repository's documented commands. A host-only seed workflow on AArch64 Linux, in a disposable clone pinned to an exact revision, looks like this:

Current main source pin (checked 2026-11-05): omega-mv
`f4df82394e35893dcf1354dda69a2fe028d94bc1` (merge commit of
[#1022](https://github.com/aien-dev/omega-mv/pull/1022), x86efi `efi 14`; the only compiler change
after #1015; still current at main `2a1e6d29`).
`seed/omc/omc.om`: 18,224 lines, sha256
`0effe37afc4ddd0507151c9f2afa34b3e6774eae7006cbecd8c59f11bc386db7`;
`seed/out/omc`: sha256
`3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`, 625,676 bytes, equal to
`seed/out/omc.sha256`, and reproduced by `sh seed/omega-from-seed.sh` in a clean detached
worktree (`RC=0`). Example reruns at this compiler are in `omega-encoding` section 0. The earlier
main pins `d3d1b1bc7` (#1015, omc `b4f45121…9b55`), `9920aab14` (#994, omc `be8c5130…448a`), `3a163bc5e` (#857, omc `24caacf4…abb7`), `91c83438d` (#965, omc `2aec185d…d8d5`),
`bf54b19fa` (#923, omc `62775d2a…712b`, unchanged through `4376c2112`), `1db941627` (#970, omc
`7a8b84fc…`), the candidate pin `1fe5976d` (#911, compiler `d6290c76...6b84`) and older pins below
remain dated history.


```sh
git clone rad://z6do9WDBhuSnvopDkgFdFr1yWA62 omega-src
git -C omega-src checkout f4df82394e35893dcf1354dda69a2fe028d94bc1
cd omega-src || exit 1
git rev-parse HEAD
sha256sum seed/out/omc                        # compare with the pin you expect, recorded beforehand
if seed/out/omc < prog.om > prog 2> prog.err; then
    printf 'compile rc=0\n'
    chmod +x prog || exit 1
    if ./prog; then rc=0; else rc=$?; fi
    printf 'run rc=%s\n' "$rc"
else
    rc=$?
    printf 'compile rc=%s\n' "$rc"
    cat prog.err
    exit "$rc"                               # never execute failed or stale output
fi
```

- The program's return value becomes the process status, modulo 256. A trap exits with 100 plus its code. A nonzero status is not automatically a failure. Tell compiler refusal, runtime trap and intended result apart, and never run output left behind by a failed compile.
- Do not lose the status: no pipelines that hide it, and do not let `set -e` skip collecting an expected nonzero exit.
- Rebuilding with `sh seed/omega-from-seed.sh` rewrites tracked files, including `seed/out/omc.sha256`. Record the expected digest independently beforehand; the rewritten sidecar is not a trust anchor. A self-rebuild fixpoint proves consistency, not correctness and not diverse compilation (diverse double compilation is not on main; omega-mv issue #650 is open). At source `ec07d25d5506d33567adbd4d9b518177b7933bad` on 2026-10-26, the seed gate reproduced `499236398aabc652e2dae27fe4bdc4c5db3d3726314356e0dbef23e3345803ec`. Main later used `befb8199db8c4bca188a494dfaac2a6f0ee5c36fcea11188c75666c55fce8a1d`. Main `91b3c9326919faf1491e29ae9276929e8349b8c7` carried batch compiler `189ada82e00bb440cb41351bd252cc68c54a1b1050051cc42a1df700081c3b54` (contracts, capacity and f32 returns); its host qualification is `evidence/BATCH-189ada82/README.md`.
- Gate5 bookkeeping for any compiler change: since main `91b3c932`, `seed/omc/gate5.sh` writes current outputs to `build/seed/r5/evidence/`, never to immutable `evidence/SEED-0/omc/`. The living ledger `seed/omc/size-history.tsv` keeps the old history byte for byte, then one tab-separated row per compiler change (`rewrite change source_lines functions words sha256`). At `91b3c932` the last row is `RM2-capacity-f32` (`189ada82…`). Gate5 checks that the last row's sha256 equals the freshly built `omc`, and it never appends a row itself. So a compiler change adds exactly one row by hand, with values measured from the new build, in the same commit as the change. Never edit an older row to make the check pass, and never point the check back at `evidence/SEED-0`.
- Merged (2026-10-29): omega-mv#904 merged at `e2662fffbce1c21ef09da71c0d8808133a6af8ab`, carrying the source tested on 2026-10-28 at `7bce2a4fddc43268ac2af09cddc4a5a67d78312d`, compiler `1811d4047f118440cc35e995261af6768b606148cb17e18c42158afd15fcad58` (row `RM-batch3-current`, #896 #897 #898 #903). Main then moved to `62775d2a...712b` (row `FR9-acceptance-fixes`) with #923; at main `bf54b19f` the gate scripts below and `om/units.sh` pin `62775d2a`. The original `397346de` evidence stays historical. A reseed must also move compiler pins in `seed/json/tests/gate-json.sh`, `seed/wasm/gate-irwasm.sh` and `seed/spirv/gate-irspirv.sh`; TLS suites read `OMC_PIN` from `om/units.sh`. The seed/GATE5, current-language and diagnostic checks passed at the tested source. The integration also repairs `s2/mut/cyc.from` and `.to` to preserve the newer `check`/`next` prelude: before repair exact-once substitution matched zero times; after repair the same prohibited-recursion case catches the faulty compiler. An INVALID mutation setup is never a caught fault. Frozen C2 still has its six historical failures, while the separate capacity and batch2 manifests pass; do not call that frozen corpus PASS.
- Pin sites to move together when `seed/out/omc` changes (checked at main `91c83438daec0bdb88bf5c077cae10f3d15d365d`, 2026-10-31; every site there holds `2aec185d…d8d5`; list them with `git grep -l <old digest> -- ':!evidence'` and read each hit): `seed/out/omc` and `seed/out/omc.sha256:1`; one new `seed/omc/size-history.tsv` row; `om/units.sh:21` `OMC_PIN=` (enforced at :30 with `NOT_RUN: omc is not the pinned compiler`, exit 3); the files `om/units.sh` regenerates and `--check` compares (`src/omega_om_units.c:196`, `src/omega_native.h:18`, `src/omega_om_units.ident:1-3`, per its header :7-17); the parity runners' `OMC_PIN=` lines, each refusing with exit 3 on a mismatch: `om/evidence/parity/run.sh:17` (added by #761, checked at :22), `om/aarch64/parity/run.sh:15` (:20), `om/codec/parity/run.sh:12` (:17), `om/gpumath/parity/run.sh:13` (:18), `om/receipt/parity/run.sh:14` (:19); the IR gates: `seed/json/tests/gate-json.sh:9` `PIN=${JSON_OMC_PIN:-…}` (checked at :17), `seed/equiv/gate-irequiv.sh:9` `PIN=` (:10), `seed/nki/gate-irnki.sh:22` `pin=` (:24), `seed/spirv/gate-irspirv.sh:24` `pin=` (:26), `seed/stablehlo/gate-irstablehlo.sh:22` `pin=` (:23), `seed/tensix/gate-tensix.sh:33` `OMC_PIN=` (:86), `seed/wasm/gate-irwasm.sh:11` `pin=` (:12); `native/orig4/orig4.pin:14` `omc` (checked by `tests/orig4/run.sh:67`); plus prose mentions such as `om/evidence/README.md:63`, `om/receipt/README.md:64`, `om/quantity/README.md:45`, `om/codec/README.md`, `om/gpumath/README.md` and `neuralese/README.md`. At `91c83438d`, 25 tracked files outside `evidence/` name `2aec185d`; `CONTRIBUTORS.md` and earlier `size-history.tsv` rows keep `7a8b84fc` and `62775d2a` as history. Between `62d1d0d66` (2026-10-30, 11 files outside `evidence/` named the digest) and `4376c2112` (42 files), the train merges #971 (`f56a372ae`) and #972 (`f5c9bd89a`) added the aarch64, codec, gpumath and receipt parity runners, the equiv, nki, stablehlo and tensix gates and `orig4.pin`. Precedents: #965's merge `91c83438d` and #923's merge `bf54b19fa` moved all of these that existed then, and `82a399b9f` ("build(omc): batch 2 pin 2c824805") moved the `om/units.sh`, `src/` and `seed/out` subset. A draft that still adds `seed/spirv/gate-vkspirv.sh:29` `pin=` (omega-mv#876 head `8a1126f2`, open on 2026-10-31) adds one more site when it lands. Produce the new digest only with `sh seed/omega-from-seed.sh`, which runs om4 then stage1..stage3 and refuses unless stage2 equals stage3 (`seed/omega-from-seed.sh:43-60`, `PASS omc fixpoint`); a self-fixpoint is still consistency, not correctness. A PR branched before #761 (for example omega-mv#918, base `6999fa9e6`) or before #971 lacks some of these sites, and its stale pins elsewhere must be caught when it is brought up to date.
- At main `bf54b19f` (and the earlier candidate pin), `bash tests/gates/run.sh seed` also invokes
  `sh seed/omc/gate5.sh` after the seed build and host checks. Keep one size-history
  row for each distinct compiler change: the qty compiler and the check/next
  compiler have separate rows, even when they arrive in the same PR. A final
  matching row does not excuse omitting an intermediate compiler change.
- **Seed-chain bootstrap challenge (merged in [omega-mv #863](https://github.com/aien-dev/omega-mv/pull/863), merge `52eba8831aa0b8db9fa2f2e13289920be4fa85f6`).** The public command that rebuilds omc from the 408-byte seed without rewriting tracked files is `git clone rad://z6do9WDBhuSnvopDkgFdFr1yWA62 omega-mv && cd omega-mv && sh seed/challenge/run.sh` (Radicle since 2026-11-07; the frozen GitHub URL is history). The script extracts `git archive 369dbc96` (seed/rung0..4, seed/omc) into `build/seed/challenge/src`, then builds seed0 → hex1 → asm2 → om4 → omc stage1/2/3, where each rung is built by the freshly built rung below it. It checks every input and rung against `seed/challenge/expected.txt`, whose values were read from the committed files with `git show <pin>:<path> | sha256sum` (omc `2c824805…`, 325,524 bytes). Exit codes: 0 `CHALLENGE PASS`, 1 FAIL, 2 usage, 3 NOT_RUN (not AArch64 Linux, or pin missing). In a `git clone --depth 1` the pin is missing; first run `git fetch --depth 1 origin 369dbc96daa1684db2d7c2c7085bbf16b3fd77ee` (omega-mv `seed/challenge/CHALLENGE.md`, commit `d764f076`). `--tree DIR` and `--expect FILE` run negative controls. Observed 2026-10-27: a pass on the Spark from a fresh clone of merged main `52eba883` (challenge 0.53 s wall, chain 362 ms), and a pass on GitHub `ubuntu-24.04-arm` (chain 359 ms) together with three controls that fail as required (tampered hex1, wrong omc value, forged log). The public runner and result inbox are in [aien-dev/omega-seed-challenge](https://github.com/aien-dev/omega-seed-challenge): `challenge.yml`, the "I reproduced it" issue form, and `results/*.log` checked by `check-result.sh`. A pass is a fixed-output reproducibility match. It is not general self-hosting and not diverse double compilation, and a log check proves consistency, not that the run happened.
- Run the changed path and compare exact expected bytes, status and state; a successful compile proves nothing about behavior. Also exercise the failure or refusal boundary most likely to regress. If that is impractical, say exactly what was not run.
- Run a negative control: change an expected value or feed invalid input, and confirm the check fails. A verifier that also accepts its negative control has not established anything.
- Qualification case files (`.cases` in omega-mv) are executed by a conductor, not run directly. More than one conductor exists under `seed/qualification/`, and picking the wrong one looks like a failing gate. Read the conductor's `main` for its argument count first. Observed 2026-10-25 with compiler `734f0a39319fbfa930bcc62cb30dbf06d47d78e126372b74f5baf478e6126b61`: `seed/qualification/om2/gate.om` takes four arguments (`omc pinhash casesfile scratchdir`) and summarises as `OM2GATE PASS cases=N pass=N fail=N invalid=N not_run=N`; `seed/qualification/security673/gate669.om` accepts at most one argument and exits 90 under a four-argument call. A usage status such as 90 from a conductor is INVALID setup, never a qualified refusal.
- Executable contracts reuse that conductor. `seed/omc/contracts/contracts.cases` (44 rows) must end `OM2GATE PASS`. `seed/omc/contracts/mutant.cases` builds two broken compilers, one with enforcement disabled and one whose prover accepts any constant predicate, and must exit 1 with `OM2GATE FAIL cases=2 pass=0 fail=2 invalid=0 not_run=0` plus a `VERDICT … FAIL run exit=0 expected=109` line for each. For that suite, exit 1 with the exact verdict lines is the expected outcome; a pass means the negative control failed. `seed/host/check.sh` runs both.
- Capacity expansion intentionally changes three historical C2 refusals at main `91b3c932`: c2-00304 and c2-00675 (1025 names) and c2-00306 (513 functions). Report frozen `manifest-c2.txt` as 5873/5876 and run the additive `manifest-c2-capacity.txt` (3/3) separately; the pre-capacity compiler must fail that delta. Never edit the frozen manifest or call it a clean pass.
- C2 delta manifests (convention merged with omega-mv [#853](https://github.com/aien-dev/omega-mv/pull/853) as `4722cba58`, 2026-10-31; checked at main `d3d1b1bc` 2026-11-04): a compiler change that moves frozen C2 rows adds one additive manifest and never edits the frozen `seed/qualification/om2/manifest-c2.txt`. Main has four: `manifest-c2-capacity.txt` (3 rows), `-batch2.txt` (3), `-fpvreg.txt` (8, #853) and `-closerange.txt` (4, the #970 `close_range` delta, declared in [#1001](https://github.com/aien-dev/omega-mv/pull/1001) `2638a49bd`). The frozen manifest's failures must equal the union of the rows those manifests declare, each of which must pass; diff the two sets, a matching count alone is not enough. Register every new delta manifest in `current_c2_contract()` in `seed/omc/qualify-x86.py` (at main the list at lines 594-597 names all four) and in docs/X86-LINUX.md; #853 first shipped `-fpvreg.txt` without that registration and qualify-x86 reported its 8 rows as frozen-manifest FAILs. A diagnostic that legitimately differs per target goes in `seed/omc/x86-diagnostic-contracts.json` as an exact per-target entry (on main: `unroll-sum-diag.om`), never as a loosened comparison. #853 keeps f64/f32 names in V registers, and its int/float conversions can write d8..d15. PENDING, not merged (2026-11-04): [#865](https://github.com/aien-dev/omega-mv/pull/865) (head `25e264c6`, conflicting with main) is OM-2 only: it drops index checks implied by a constant-count `for`, and hoists at most seven loop constants into x20..x26, in function-mode units too; x27 (program-mode host-args pointer) and x28 (stack floor) are never hoist registers (`hzreg`/`hzcap`, note at omc.om's `poolc`). It adds `seed/omc/gate19.sh` to `seed/host/check.sh` (not on main): nine cases, six line-anchored source mutants, a function-mode register scan (objdump; x19, x27, x28, x29 never written) and a 64-program differential fuzz against a non-hoisting build; gate19 against omc `0d006207` must FAIL. #865 does not move C2 (VERDICT lines byte-identical across omc `0d006207`, `c4a34fc1` and `3c2a1277`), so it adds no delta manifest. A native binding may rely only on a unit never writing x19 or x29 and keeping sp balanced; the trampoline restores x20..x28 and d8..d15 (omega-bridge [#24](https://github.com/aien-dev/omega-bridge/pull/24), open draft, tests this with a direct trampoline probe and one mutant per restore pair). Update this note when #865 and bridge #24 merge.
- `seed/wasm/gate-irwasm.sh` and the OM-2 `gate.om` suites are merged but not in any `tests/gates/*.gate` manifest at main `19f014f21`, so `tests/gates/run.sh seed` does not cover them (omega-mv #790). Run and report them separately.
- A benchmark can need a seekable stdin. A checker replay that seeks back over its input 101 times exits 90 when stdin is a pipe, and the same command exits 0 when stdin is an opened regular file. Supply a file, and do not count the setup-status exit as a control result.
- Native callers of compiled Omega units are qualified per language, and only by execution. Since omega-bridge main `adb26cc654656926e76ab1839adae63e92909e88` (PR #18, merged 2026-10-26), `tests/native/run.sh` prints `NATIVE-CALL PASS` only after all seven required callers (`c`, `c-bti`, `cpp`, `python`, `rust`, `zig`, `go`) built and ran. A present toolchain whose build fails prints `NATIVE-CALL FAIL` and a missing toolchain prints `NATIVE-CALL NOT_RUN`; both exit nonzero. Check the refusal paths with `OMEGA_NATIVE_OMC=<pinned-omc> sh tests/native/test_build_failures.sh`: it injects failing Zig and Go toolchains, hides both for the missing-toolchain control, then requires the real Zig and Go callers to pass. It needs real Zig 0.13.0 and Go binaries (`ZIG`, `GO`) and prints `NOT_RUN` without them. The historical `evidence/native-call-v1/run.log` predates this runner and stays unchanged; do not cite it as a current all-caller PASS.
- Pending, not merged: draft omega-bridge#30 (head `1bb55976`, still open on 2026-11-04) adds an eighth required caller, `python-gen`: the Python `ctypes` module that `src/native.om` writes itself in Python mode (input led by the bytes `\0py\n`), checked by `tests/native/pybind.py`. Until it merges, quote the seven-caller rule above; a Python binding written by hand is not that caller.
- Since omega-bridge PR #26 (merged 2026-10-30 as `f637021f36f0cfff39240a62341a47e442ae05c3`) the native call generator also binds `edit`/`view` arrays of `f32` (4-byte, 4-aligned) and `ushort` (2-byte, 2-aligned, e.g. binary16 bits converted inside Omega), besides `ulong`/`uchar`; other array kinds (e.g. `view uint`) are still refused with exit 110 and the previous output left untouched. Check them with `OMEGA_NATIVE_OMC=<omc 734f0a39…> sh tests/native/kinds.sh` (C caller vs `_Float16`-computed values, six status-32 refusals, an `add -> sub` mutant that must fail; `NATIVE-KINDS PASS` rerun 2026-10-31 at `f637021f`, at bridge main `654305fa` and at bridge main `9532044e`; any other compiler prints `FAIL omc sha256`). The omc pinned by `tools/native` (`734f0a39…`, still the pin at bridge main `9532044e`) rejects functions that return `f32` (error 5); omega-mv omc `2aec185d…` (pin `91c83438`) accepts them (`seed/omc/tests/float/f32_return.om` compiles and exits 0), but bridge units must compile under the pin, so have helpers return `uint` bits and `bitcast` in the caller. First consumer: [aien-dev/ggml-omega](https://github.com/aien-dev/ggml-omega), a llama.cpp backend whose op kernels are Omega units; its per-op `test-backend-ops` table and end-to-end decode are its evidence, not the bridge's.
- **x86 native bridge target and compiler refresh (merged 2026-10-29; native x86 NOT_RUN):** omega-bridge [PR #37](https://github.com/aien-dev/omega-bridge/pull/37) (closed unmerged; #40, stacked on it, squash-merged its changes at `ed420fcbffa1ad83db78111deb836dd880ed891e`), commit `1109b46a19c98c650488d36b465d969de65e3d61`, adds explicit `tools/native --target x86linux OUT unit.om...` for hosted SysV AMD64 C/C++/Python/Rust/Zig/Go callers. AArch64 remains the default; all 150 baseline/output comparisons with bridge `0c4cb9ff` passed byte-for-byte. The generator/bootstrap build host is still AArch64. Do not infer the target from the build host. x86 freestanding refused (exit 110, before creating OUTDIR) until [omega-bridge#44](https://github.com/aien-dev/omega-bridge/pull/44) merged 2026-10-31 as `49b6963587cc625027a0445996e57841430f3c63`; since then `--target x86linux --freestanding` emits the pure-scalar binding with a SysV adapter on the caller's stack (trap anchor R12, owned-stack floor R15 = 0, no bound check), per that revision's `docs/NATIVE-ABI.md`.
  Both compiler baselines remain mandatory: `OMEGA_NATIVE_OMC` sha256 `734f0a39319fbfa930bcc62cb30dbf06d47d78e126372b74f5baf478e6126b61` builds the generator (still required at bridge main `ed420fcb`, `docs/NATIVE-ABI.md` lines 15-16). At bridge `1109b46a19c98c650488d36b465d969de65e3d61`, separate `OMEGA_NATIVE_X86_OMC` was pinned to candidate compiler SHA256 `badedbb0c6287887641fcd7e97301b43b5f82f2d7a2838bbe0d17547873108be`, omega-mv source `3e66b6744590cc72c623d8e09413b9072bcab36e`, source SHA256 `4b5392fffd25a3a37844ad8bb5138fbaada690be7dae95132614524bdb78a1e0`, then-pending [compiler draft #923](https://github.com/aien-dev/omega-mv/pull/923) (merged at `bf54b19f`). `OMEGA_NATIVE_OMC2` is unused for x86; do not substitute the candidate for the baseline.
  The tool prefixes only compiler input with `target x86linux`; source snapshots and `src=` identities retain original bytes. X86 export slots are six bytes, not AArch64's four-byte branches. The pinned private ABI uses negative frame slots, R12 for the caller frame anchor, R14 for the runtime table, R15 for the actual stack floor, and ESI/table slot 2 for nonlocal traps. Advanced host helpers refuse bare units; legacy read/write remain permitted. The adapter does not support CET shadow-stack enforcement.
  Run `python3 tests/native/x86/test_build_failures.py [EMPTY_OUTPUT]` with the cross-toolchain, guest Python and `QEMU_X86_64` environment documented in that bridge revision's `docs/NATIVE-ABI.md`. Its strict positive suite executes all six actual language callers (Rust 2021/2024), pointer statuses 32, signal reentry 33, stale identities, private symbols/TLS, traps, fixed-stack-floor and boundary/API mutants. A mismatched candidate must refuse before creating a fresh output directory and preserve existing output bytes. Failed Zig/Go and missing-toolchain controls must refuse aggregate PASS (#34). `tests/native/x86/prepare.py` records exact guest-Python package custody.
  **QEMU oracle preflight (MERGED 2026-11-05 as [omega-bridge#57](https://github.com/aien-dev/omega-bridge/pull/57), squash commit `8c4abda27b6c5d88c87b80d824528ac7883fdcc5`):** Ubuntu's `/usr/bin/qemu-x86_64` 8.2.2 (sha256 `120db995…`) fails 4 callers at bridge main `7af4d11`: c, go, rust and rust-2024, giving 312 PASS and 4 FAIL. The same main passes 316/316 under the receipt's QEMU 10.0.14, binary sha256 `fd7ae7768c1d698d387893688d28abde90512f1f445d171a1389110eb7c237ee`. 8.2.2 has two defects. It crashes internally reading `/proc/self/maps` (MAPERR addr 0x20). It also enters signal handlers with RSP+8 misaligned by 8, so the `movaps` stack stores in `omega2_vlen` fault inside the C caller's reentry handler. Before blaming the bridge for an x86 caller crash, check the emulator: set `QEMU_X86_64` to a 10.0.14 build per `docs/NATIVE-ABI.md`. Since bridge `8c4abda2`, the suite prints the QEMU path, sha256 and version, then runs `tests/native/x86/qemu_probe.c` (`maps`, `sigframe`). A failing mode prints `NOT_RUN QEMU-ORACLE-UNUSABLE <mode>`, and the run ends `NATIVE-X86 NOT_RUN` with exit 1 before any caller runs. That is a refusal of the emulator, not a bridge FAIL. Never weaken a caller to fit an old QEMU. The preflight was exercised on the PR head; it has not been re-run at merge commit `8c4abda2`.
  **Native execution mode (MERGED 2026-11-05 as [omega-bridge#60](https://github.com/aien-dev/omega-bridge/pull/60), squash commit `4ad48c456de95cacd6250295ce9a092537fc9643`):** `OMEGA_NATIVE_X86_EXEC=native` runs every x86 target program directly on an x86-64 host CPU instead of under `QEMU_X86_64`. `qemu` is the default and keeps its output unchanged. Native mode refuses a non-x86-64 host, and any other mode value is refused before a caller is built. It prints CPU model, hypervisor flag, kernel and `systemd-detect-virt`. The pinned AArch64 compilers need binfmt `qemu-aarch64` on that host. The suite never prints PHYSICAL; bridge `docs/NATIVE-X86-PHYSICAL.md` is the runbook and receipt format, and labels a receipt PHYSICAL only for `virtualization=none` with the hypervisor flag clear. EXERCISED on a VM only: GitHub runner (Xeon Platinum 8573C, `virtualization=microsoft`, run 41965785820) at bridge `95d7e0b6`: 319 PASS, 0 FAIL, `NATIVE PASS`; controls PASS; wrong-pin and mutated-compiler controls exit 1. That is VIRTUAL, not PHYSICAL. Physical native x86 remains **NOT_RUN**.
  **Historical EXERCISED, EMULATED only:** at bridge `81c7ec3d95469b8ae60b3cf6797068decc1900de`, with its old candidate pin `1f0fdef06574ffec782c164941114edcf51f36f9f9cd1e79bc0452dbcebb3322`, the aggregate command exited 0 under unpatched QEMU 10.0.14, source archive sha256 `c7230968906fdb5540d803e2af1f515e77590a414f2a4dbd3ec9ada3c47083d0`. Those command/runtime/tool/source receipts remain immutable in `evidence/native-x86/`; they do not qualify the refreshed pin. QEMU 8.2.2 produced signal and `/proc/self/maps` failures; the same callers passed with the newer oracle, without weakening them. Physical native x86 and GPU execution are **NOT_RUN**. These were unmerged drafts when recorded; the later merges are not deployment, Alpha or hardware qualification.
  **Historical EXERCISED, EMULATED only (2026-10-28):** at bridge `29087763accea55666ac7a4c14ecb37cef1c2be8` with candidate `f7752bc5c800e85c2393a08153786d0a6bc4516c9cea955fe27624228d6d1409`, the aggregate command exited 0, including both mismatched-pin controls; receipts remain in `evidence/native-x86-f7752bc5/`. The compiler's own full differential at `efd15c234afc584e1e67492e736cbb42806c2a7d` is FAIL (14,930 PASS, 60 FAIL, 10 NOT_RUN, 216 EXCLUDED). Never transplant those totals onto the repaired source.
  **Historical EXERCISED, EMULATED only (2026-10-28):** at bridge `1109b46a19c98c650488d36b465d969de65e3d61` with candidate `badedbb0…08be`, the aggregate command exited 0 (294 PASS lines, 0 FAIL), including both mismatched-pin controls; the previous candidate `f7752bc5` refused with exit 1 before creating OUTDIR. Receipts: `evidence/native-x86-badedbb0/`. The compiler's full differential at `3e66b674` was FAIL (14,936 PASS, 54 FAIL, 10 NOT_RUN, 216 EXCLUDED; omega-mv#923 `d5b445b7`). Those totals do not describe the newer candidate.
  **Merged refresh, EMULATED only (exercised 2026-10-28, merged 2026-10-29):** bridge [#40](https://github.com/aien-dev/omega-bridge/pull/40), merged at `ed420fcbffa1ad83db78111deb836dd880ed891e`, exercised source `8a9618fa2f4e623f332973fd12ab5c466e8356f7`, pins `OMEGA_NATIVE_X86_OMC` to `62775d2a391cfef7cde64e387655caa9809a267093112910ec76bfa568f3712b` (the omega-mv main compiler at `bf54b19f`), omega-mv source `7ab5fdd067884fd3044155084b39163da1be5c8a`. The generator baseline remains `734f0a39…`. Both the full six-language suite and `tests/native/x86/test_build_failures.py` exited 0, including failed/missing-toolchain controls and the real-toolchain positive case. Receipt: `evidence/native-x86-62775d2a.json`. The compiler's complete differential is separate; bridge success does not qualify it. Physical native x86 and GPU execution remain **NOT_RUN**.
  For current compiler acceptance, preserve frozen manifests and replay their pinned compilers. Use only the explicit accepted capacity/batch2 deltas for current C2 rows. Target diagnostic expectations are exact, source-hash-pinned records in `seed/omc/x86-diagnostic-contracts.json`, including required stack checks. Historical failed S2 mutation experiments remain recorded as FAIL; successfully replaying one does not turn it into a successful kill. Never transplant old failure totals or erase their transcripts.
  Full run at `7ab5fdd0`: 15179 PASS, 4 NOT_RUN, 222 EXCLUDED, no FAIL cases; aggregate FAIL because of NOT_RUN. All three original large-input SHA cases passed. The isolated text-write driver addition at `00ebdee8` passed both formerly unrun text-write cases plus exit/encoding controls (5 PASS). The remaining two cases are invalid-fd ioctl checks affected by QEMU's ENOTTY versus native EBADF. The compiler binary is identical across these runs. Receipt: omega-mv `evidence/x86_current_acceptance.1db7902db393b0e4e56e93af8f136133b05663cac58e712c219d84c43fc120b1.json`. This is not native x86 qualification.
- ABI-v2's `tests/native/v2/run.sh` has the corresponding terminal refusal since bridge
  `0c4cb9ff980af278890b231b994eaede4dc7621c` (#34, 2026-10-28): actual failures take precedence,
  otherwise any missing required toolchain emits `NATIVE-V2 NOT_RUN` and exits 1.
  `python3 tests/native/v2/test_verdict.py` passed all five compiler-free tests on that pin;
  these execute the real terminal shell suffix, not upstream detection or native callers.
  The separate full native-v2 run above exercised detection and the new missing-toolchain verdict.
- **omega-bridge#54 (merged 2026-11-05 `d1124611`; observations from 2026-10-31):** `tests/native/v2/run.sh` needs `OMEGA_NATIVE_OMC` (734f0a39…) and `OMEGA_NATIVE_OMC2` = the omega-mv#1008 compiler (3988c31f…); its section 11 runs the `--host` refusals and the C and Rust callers of `tests/native/v2/host/hfile.om`. Observed at `c7f432cd` on AArch64 with zig 0.13.0 and go 1.27.3 on PATH: rc 0, 72 PASS, `NATIVE-V2 PASS (not run: none)`; `tests/native/run.sh`: `NATIVE-CALL PASS (not run: none)`. Negative control: removing the source scan from `fn unit` lets a parenthesised `geteuid` through without `--host`, and the suite catches it. The v1/v2 byte-identity baselines on bridge main were stale (#26's f32/ushort kinds changed every unit's Python output), so `v2/run.sh` failed on main until the baseline fix (omega-bridge #55, merged `fa8581e8`; #54 carried the same fix to `74fcd43`). The x86 suites fail identically on main and on #54 on this host (no x86_64 cross g++, `OMEGA_NATIVE_X86_PYTHON` unset): NOT_RUN, not caused by #54. No CI runs the native suites.
- MERGED (omega-bridge #27, merged 2026-11-05 as `077d3d22`; the results below were recorded on branch `feat/native-darwin` @ `362c6d0fb857e9068557bc244a7046051e47fb41`): the C file that `src/native.om` generates also builds on macOS arm64 (Mach-O) and refuses to build there with `#error` for any unit whose code makes Linux system calls (host words). Generation stays Linux AArch64 only (main's `tools/native OUTDIR unit.om ...`, pinned omc `734f0a39…6b61`). The macOS check has two steps: `OMEGA_NATIVE_OMC=<seeded omc> sh tests/native/macos/run.sh bundle DIR` on Linux, then `sh DIR/run.sh run DIR` on the Mac, which must print `NATIVE-CALL-MACOS PASS` (exercised once on macOS 26.6.2, Apple M2, clang 17). It covers the C and Python callers, byte identity, no x18, the add->sub mutant and host-word refusal. C++/Rust/Zig/Go, ABI v2 and BTI on macOS are NOT_RUN.
- Compiler changes need the repository's referee and wrong-word-mutant checks, not just a self-fixpoint. Before running any gate, read its prerequisites, device requirements and whether it writes receipts.
- Local model verification, 2026-11-06 (unmerged branches):
  [aienux `e5669dd`](https://github.com/aien-dev/aienux/tree/e5669dd1648e1b733f2547c57a5b1110fb918969/native/omega/allen/LOCAL-MODEL.md)
  composes Allen's lifecycle with aien-train's model and UEFI I/O. Its opt-in
  `build-local-model.sh AIEN_TRAIN OUT.EFI` requires compiler SHA-256
  `3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`.
  Rebuilding produced the tested image SHA-256
  `be33b905f949d6dab036d3452a248d8fef6bc97695d9de0ca7d173221d136060`.
  [Receipts](https://github.com/aien-dev/aienux/tree/e5669dd1648e1b733f2547c57a5b1110fb918969/evidence/OMEGA-LOCAL-MODEL/macbook-20261106)
  record eight greedy tokens matching the Linux reference on an M2 MacBook,
  invalid-frame refusal, a truncated checkpoint returning 10 without readiness,
  HTTP streaming and cancellation. It is an x86-64 firmware application in
  QEMU, with no Linux guest, not the standalone Aienux kernel or native ARM64
  firmware. One eight-token sample took 110.04 seconds; no speed qualification
  or small-model capability replacement follows. The Mac host adapter's
  `tools/omegallm-ui/check.py --port 8099 --output RECEIPT` passed eight HTTP
  checks and a repeat after VM pause/resume; the same command with port 8098
  checks the Linux path. These are test-oracle commands, not product Python.
  Full repository suites and automated browser interaction were not run.
- For the merged IR/wasm backend above, run `nice -n 19 sh seed/wasm/gate-irwasm.sh`.
  Node v24.21.0 is a read-only wasm validation/execution oracle only; never use Node to generate
  IR or wasm. The production path is `.om -> omc ir -> irwasm.om -> wasm`, with no Node runtime
  dependency. Observed at that source: `PASS parity cases=129 units=13 traps=29; every export exercised`,
  byte-identical repeat translations, add-to-sub mutant rejected by the parity checker (exit 1),
  and named parse/type refusals with empty stdout. Retained logs/artifacts live in
  `evidence/IRWASM-20261026/`. That backend gate did not exercise a browser or GPU/Alpha qualification.
  Compiler sha256 is `befb8199db8c4bca188a494dfaac2a6f0ee5c36fcea11188c75666c55fce8a1d`;
  its om4-built and self-built fixpoint agrees. Re-exercised at tested head
  `0e81d5a6f990000f1dca50f05f0c6050f7cdf9a5` before #787 merged: seed and om-units
  gates passed and the independently pre-recorded compiler digest matched the rebuild.
  The older pin/fixpoint above remains dated history.
- The site integration merged through [aienos.com #109](https://github.com/aien-dev/aienos.com/pull/109),
  merge `a6aec5e2628804abd27101ba184d7a319f95774e`; #108 closed as superseded.
  `sh om/hive-page/gate-fresh.sh` exercises the native/wasm boundary table; the site check regenerates
  wasm without Node and the existing x86_64 CI test only hashes the artifact. Earlier #108 Chromium
  synthetic-feed fixtures exercised four wasm states and corrupt-module fallback to `js`; those
  dated receipts remain on #108, not in the #109 main tree. The helper source and wasm artifact
  were carried over byte-identically. Merge status does not establish deployment or trusted clocks.
- Record the source revision, the compiler, source and binary hashes, the exact command, the platform, expected versus observed result, and the limits. A local smoke run is not repository qualification, not a merge and not a deployment.
- Seed gate integrity, merged: [omega-mv PR #789](https://github.com/aien-dev/omega-mv/pull/789) (head `7d272895`) landed in train r5, main merge `19b8340d` (2026-11-02). Build `build/omegese/omegese`, `build/omega_emit/omega_emit` and `build/checker2/checker2` before standalone `seed/host/check.sh`. A missing oracle returns `NOT_RUN` with status 3 before any rebuild, never host PASS (observed 2026-11-04 at main `d3d1b1bc`: `sh seed/host/check.sh` without the oracles printed `NOT_RUN gate-ir: required C oracles not built`, exit 3). `tests/gates/run.sh seed` builds these oracles and runs the seed chain, `seed/host/check.sh` (IR comparison including the mul-to-add mutant, native host tests, original-fixture comparison) and `seed/omc/gate5.sh`, and fails on any `SKIP`. Run host builds at `nice -n 19` with `MAKEFLAGS=-j2`. The merge does not run the Spark/GB10 operator bundle; host checks do not substitute for it.
- The corrected original-fixture obligation is `seed/host/original-fixtures.tsv`: 62 exact paths and observed parent statuses, not a filtered list whose denominator may silently shrink. Missing, duplicate or malformed obligations and common compiler refusals must fail. Exercise `nice -n 19 python3 seed/host/test_gate_integrity.py` for the fail-closed controls (observed 2026-11-04 at main `d3d1b1bc`: `Ran 11 tests`, `OK`, exit 0).
- The corrected zero-disk-secrets gate checks every tracked path (including forced additions in generated directories), plus untracked paths outside root `build/` and `.git/`, preserves pathname boundaries, refuses enumeration errors and never reuses a cached absence-of-secrets result. Its offline controls do not establish an authorized Spark operator bundle.
- Pinned `aien-test` verifier sources must be built from a trusted directory outside the candidate tree (`RUNNER_TEMP` in GitHub Actions), with an explicit separate target directory. Cargo loads configuration from its current directory and ancestors even with `--manifest-path`; source pins alone do not exclude a candidate `.cargo/config.toml`. Cache dependency registries/git only, never the compiled verifier target from a candidate run. Challenge both PR and Alpha commands with a candidate rustc-wrapper and a trusted-source negative control. This workflow correction is merged in [sovereign-core #771](https://github.com/aien-dev/aien-sovereign-core-mv/pull/771), merge `2369d7c8`; that source status does not assert deployment of local verifier services.
- om/tls coverage commands (merged: omega-mv #862 `audit/tls-coverage`, landed in train #979 `4376c211`; observed at main `91c83438`, omc sha256 `2aec185d4ed6d7a6a5779ed656b4e56904742bde5551b02893fb5f73916ad8d5`, two pins before the current `9920aab1`; not rerun at `24caacf4` or `be8c5130`). `sh om/tls/test/wycheproof/ledger.sh WYCHEPROOF_DIR LOGDIR` accounts for every test of every C2SP/wycheproof `testvectors_v1` file at `d17cc89f` (347 rows in `ledger.tsv`) as pass, fail, na (with the written reason), not_run or unexplained, reading `LOGDIR/SUITE.log` from the primitive suites (`aesgcm chacha sha2 x25519 ec rsa mlkem ecdh`, each `sh om/tls/test/SUITE/run.sh OMC`); exit 0 PASS, 1 FAIL (a failure, an unexplained test or a ledger error), 3 NOT_RUN (applicable tests absent). A skipped or absent suite is NOT_RUN, never a pass. `sh om/tls/test/wycheproof/ledger-nc.sh WYCHEPROOF_DIR LOGDIR` is its negative control: a deleted row, a planted `FAIL` and an altered header sha256 must each make the ledger exit 1. Observed 2026-10-31 at main `91c83438` with omc `2aec185d`, Spark cores 5-9 at nice 19: all eight suites exit 0 (`SHA2 PASS`, `CHACHA PASS`, `AESGCM PASS`, `X25519 PASS`, `EC PASS`, `RSA PASS`, `MLKEM PASS`, `ECDH PASS`, every mutant detected); `ledger.sh` exit 0 with `WYCHEPROOF-LEDGER PASS files=347 tests=145057 pass=13804 fail=0 na=131253 not_run=0 unexplained=0 errors=0`; `ledger-nc.sh` exit 0, each of row, fail and header `rc=1 detected`; control: `ledger.sh` with an empty LOGDIR exits 3 (`WYCHEPROOF-LEDGER NOT_RUN ... pass=0 ... not_run=13804`). `sh om/tls/test/bogo/run.sh OMC BORINGSSL_DIR GO` builds the pure-.om BoGo client shim and the pinned BoringSSL runner (`om/tls/test/bogo/PINS`: commit, Go version, URL and sha256; Go is a test oracle only) and prints `BOGO-RESULTS tests= pass= fail= na= skip=` plus `na-reason`/`fail-reason` lines. `na` is only two runner-side refusals of a TLS 1.3-only client (`tls12-only`: runner MaxVersion below TLS 1.3; `record-301`: BoringSSL demands 0x0301 on the initial record, which RFC 8446 5.1 does not require); na is never counted as a pass. The runs use `-loose-errors`, so expected-failure tests pass on any error; the negative control therefore re-runs passing candidates without `-loose-errors`, keeps only success-expecting ones, runs them against an echo-corrupting shim and requires `BOGO-NC ... still_pass=0`. Exit 0/1/3 as above. The runner's leaf certificates have an empty subject with a non-critical SAN, which `x509.om` refuses per RFC 5280 4.2.1.6, so run.sh applies `runner-critical-san.patch` to the runner fixture by default; with `BOGO_UNPATCHED=1` handshakes using those leaves fail with `X509_ERR_MALFORMED` (an explained policy difference, not a pass). The BoGo run was not rerun for this refresh (NOT_RUN): heavy runs go to GitHub `ubuntu-24.04-arm` runners, not the Spark.

### Seed tools and target directories landed on omega-mv main (checked 2026-11-05)

All of the following are on omega-mv at the harness pin `9920aab1` (omc `be8c5130…`) and on main `d3d1b1bc` (omc `b4f45121…`), except DDC650, which is on main only. Each line names the gate and what was observed on the Spark host (Linux AArch64, `nice -n 19 taskset -c 0-9,15-19`) on 2026-11-05. Host and oracle results are not hardware qualification.

- **`seed/equiv/irequiv.om`** (#826, landed in train r2 #972 `f5c9bd89`): exhaustive equivalence of two OSC IR v1 scalar functions, the way to prove a small-domain refactor. Build `seed/out/omc < seed/equiv/irequiv.om > irequiv`, feed it the IR of a unit (`{ printf 'ir\n'; cat unit.om; } | seed/out/omc > unit.ir`), then `./irequiv check A B < unit.ir`: `EQUIV PASS … checked=N differing=0` or `EQUIV FAIL … first=…`. `check` needs identical signatures and at most 24 parameter bits. `sample A B N SEED` prints `NOT_A_PROOF` and exits 10 even on agreement; running out of fuel (16777216 instructions per evaluation) prints `EQUIV INCONCLUSIVE` and exits 6, never PASS. `sh seed/equiv/gate-irequiv.sh` at `9920aab1`: `CONFORM native rows=140 equal=140`, `GATE-IREQUIV PASS`. The result is about the IR, not the AArch64 words the native path emits. The IR-mode cast gotcha (`ret ulong sub c 48`, error 7) is fixed since #967; see `omega-encoding` section 1.
- **OMEGA-TRACE and OMEGA-TRACECLI** (#608/#610; `tests/gates/omega-trace.gate`, `tests/gates/omega-tracecli.gate`; `tests/gates/run.sh trace|tracecli`). `seed/trace/segment.om` is a library unit (no `main`; concatenate it in front of a program) for trace segment format v1: a 16-byte `AITR` header, 64-byte records with a 52-byte payload and a CRC-32/IEEE per record, at most 4096 records, torn-tail recovery that keeps the valid prefix and quarantines the damaged file as `<segment>.bad`. `seed/trace/tracecli.om` is the read-only inspector. Observed: `sh seed/trace/gate.sh` → `PASS trace 71 checks, 4/4 mutants caught`; `sh seed/trace/cli-gate.sh` → `PASS tracecli 28 cases, mode-0000 refused, 4 mutants caught`.
- **Packed-list runtime ingress** (#959, in `seed/qualification/security673/`): `packets.cases` and `packets-mutant.cases` are OM-2 case files and run under `seed/qualification/om2/gate.om`, not `gate669.om`. `sh seed/host/check.sh` runs both; the mutant file must give `OM2GATE FAIL cases=3 pass=0 fail=3 …`. Observed at `9920aab1`: `OM2GATE PASS cases=60 pass=60 fail=0 invalid=0 not_run=0` and `PASS packed-list ingress: hostile packets refused; size, count and exact-length mutants detected`. The whole `check.sh` exits 3 because `contract C parity` is NOT_RUN without its comparison oracles. The packed-list rules are in `omega-encoding` (formats the pin defines).
- **`seed/nki/irnki.om`** (#854): OSC IR v1 single-op u32 elementwise functions to AWS NKI kernels at the `nki.isa` level (the lowest level AWS documents publicly) for trn1/trn2/trn3. Refusals: 24 UNSUPPORTED_OP (div, rem, shl, shr), 25 UNSUPPORTED_TAG, 29 NOT_ELEMENTWISE, 20–28 as irwasm, 30 USAGE, all before the first stdout byte. `irnki f32` retypes u32 lanes to float32 (add, sub, mul only). `sh seed/nki/gate-irnki.sh` needs `NKI_ORACLE_DIR` from `seed/nki/setup-oracle.sh` (`nki.simulate` 0.7.0 under qemu-user 10.0.13; the host qemu 8.2.2 crashes); without it it prints `NOT_RUN NKI_ORACLE_DIR unset…` and exits 3 (observed). Status: IMPLEMENTED, EXERCISED on the simulator per its README, Trainium/Inferentia NOT_RUN. The NKI compiler is a private beta and `neuronx-cc` needs an AWS account.
- **`seed/stablehlo/irstablehlo.om`** (#852, Google TPU path): `irstablehlo N FUNCTION < unit.ir > module.mlir` lifts one one-block scalar function elementwise to a StableHLO `@main` over `tensor<NxT>`; refusals exit 20..30 with empty stdout. Oracles IREE 3.13 (llvm-cpu) and the XLA CPU PJRT client (jaxlib 0.12.0.1) are interop oracles; without them the gate prints `NOT_RUN requires iree-compile oracle` and exits 3 (observed). Omega's signed overflow trap has no StableHLO form (Omega exits 101, the oracles wrap). libtpu is closed, so StableHLO is the lowest level Omega writes; any TPU run is NOT_RUN.
- **`seed/tensix/`** (#851, Tenstorrent): the unchanged `seed/rung2/asm2.bin` with the table `rv32im.tbl` (registers written as numbers), and `irrv32.om`, which lowers the IR of a `(uint,uint)->uint` unit (CONST/MOV/BIN add,sub,mul,and,or,xor/RET) to an RV32IM elementwise kernel and refuses div/rem/shl/shr with exit 24. `sh seed/tensix/gate-tensix.sh` observed: irrv32 output byte-identical to the asm2 `vecadd.bin`, GNU/LLVM objdump and qemu-riscv32 checks PASS, mutants caught, `RESULT NOT_RUN (9 checks could not run; nothing failed)` because the pinned ttsim v1.15.0 libraries are absent; exit 3. No Tenstorrent card was touched.
- **om/tls fuzz harness** (#849, `om/tls/test/fuzz/`): `fz_*.om` targets plus `run.sh` stages `build replay plant fuzz cmin triage service`. A trap exits 100+code, so any input exiting ≥100 is a crash (AFL++ `AFL_CRASH_EXITCODE=101-114`); campaigns use AFL++ v4.40c `qemu_mode` (`-Q`) with CMPLOG (`-c 0`), and the planted-defect control `fz_plant` must trap natively (exit 103) and be found blind. `run.sh` refuses the X925 cores 5–9 and 15–19 and more than 2 workers. Observed at `9920aab1`: `OUT=… sh om/tls/test/fuzz/run.sh build replay` built 8 targets and printed `replayed 309 inputs`, `fails=0`; `fz_plant` exits 103 on `\0OMFZ` and 0 on `\0OMFY`. The fuzz and plant stages were not run here.
- **om/tls units since train r3 `4376c211`**: `om/tls/build.sh` concatenates `sha2 hkdf drbg x25519 sha3 mlkem chacha aesgcm ec ecdh rsa x509 rev fips tls`. `tls_init c hostname flags`: flag 1 offers ALPN http/1.1, flag 4 is approved-only mode (HMAC_DRBG, NIST-approved algorithms only), flag 8 checks stapled OCSP with must-staple (`om/tls/README.md`).
- **DDC650** (#650, `seed/qualification/ddc650/ddc.om`, merged `a48b6041` in #952): diverse double compilation of `seed/omc/omc.om`. Route S rebuilds from `seed/rung4/om4.bin`; route I interprets the source with `omega_ref` built by GCC from `tools/omega_ref/omega_ref.c` at `190130b7`. Status: PROPOSED gate, host EXERCISED, not in any manifest, not QUALIFIED, and not a trusting-trust cure: same host, kernel and CPU; the oracle is project-authored; other OS/architecture routes are NOT_RUN. Observed on main `d3d1b1bc` with GCC 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1), using the README's run command: `VERDICT DDC650 PASS` (self-regeneration, `stage2 == BIN`, `ref == BIN`, `stage2 == ref` and the NOP sensitivity mutant all PASS), BIN `b4f45121…`.

### SPIR-V OpenCL Kernel backend

`seed/spirv/irspirv.om` in [omega-mv #804](https://github.com/aien-dev/omega-mv/pull/804)
is a handwritten Omega backend for the same OSC IR v1 scalar subset as irwasm.
Source exercised on 2026-10-26:
`4ad014ed3342e202e4fdb1d31b38b8e6f2e0a117`, compiler
`befb8199db8c4bca188a494dfaac2a6f0ee5c36fcea11188c75666c55fce8a1d`.
Merged as `3a10bd29fb7debdcf2c8f5cb58680cc74cb5b1f3`; compiler pin unchanged.

- Read `docs/SPIRV.md` before using the ABI. The output is SPIR-V 1.0, Kernel
  execution model, Physical64/OpenCL memory model, not Vulkan Shader SPIR-V.
  Each original function is a kernel with two global ulong pointers: input
  scalar slots and output `[canonical_result_bits, native_status]`.
  Launch one work item; success status is zero, traps retain `100 + trap`.
- Run `nice -n 19 ionice -c3 sh seed/spirv/gate-irspirv.sh` with
  `SPIRV_VAL` and `POCL_LIBRARY` (absolute trusted PoCL shared-library path).
  The library selection is compiled into the C host, which overwrites inherited
  vendor settings and disables layer discovery before any OpenCL call. It does
  not inspect and reopen an environment-selected ICD manifest.
  The C host is the explicitly requested verification/demo interface to OpenCL,
  never a translator dependency. LLVM is inside the PoCL oracle, not the Omega
  emission path. Validate before executing: the external reader can abort on
  malformed IL, and a nonzero host exit must remain an oracle failure.
- Source-bound CPU evidence: 129 original native/PoCL exact matches, including
  29 traps; 8 supplemental nested-call cases; 3 demo cases; reordered CFG
  regression; 16 byte-identical repeat translations; 17 spirv-val acceptances
  including the valid arithmetic mutant; 16 named refusals with empty stdout.
  The add-to-sub mutant completes successfully but the parity checker exits 1
  for exactly one mismatch. API/setup faults use exit 2 and cannot satisfy it.
  Full logs, per-case tables, raw artifacts and toolchain ledger are retained in
  `evidence/IRSPIRV/20261026-4ad014ed3/`. Host controls also prove inherited
  discovery is ignored and missing/unconfigured libraries fail closed. A separate
  file access trace of the demo host shows no GPU device or system OpenCL
  vendor/layer directory accessed; its public copy redacts home paths.
- Exercised oracle versions: PoCL 7.2 at
  `888c9774b94590fff1afef003154ca2c0ea66605`, LLVM/clang 18.1.3,
  SPIRV-LLVM-Translator 18.1.8, SPIRV-Tools v2025.1, ocl-icd 2.3.2.
  The gate uses `spirv-val --target-env opencl2.1`. Ubuntu PoCL 5.0 lacked IL;
  a user-space SPIR-V-enabled PoCL build was required.
- Non-v1 IR, floats, arrays/memory, vectors, atomics, barriers and host/device
  words are explicit refusals. Contract strings remain metadata, not runtime
  contract checks. No DPC++, Level Zero, GPU or Alpha qualification is implied.
  The standalone acceptance gate is not wired into protected gate manifests.
- Pending, not merged: the E1 open-math SPIR-V tier
  ([omega-mv #889](https://github.com/aien-dev/omega-mv/pull/889) plus the
  stacked [omega-mv #901](https://github.com/aien-dev/omega-mv/pull/901); rechecked
  2026-11-04: #889 open draft at `916a082a9`, conflicting with main; #901 open draft at
  `cec8601dc`, based on #889's branch) adds an NDRange ABI: work item `g` reads
  `inputs[g*P + j]` and writes `outputs[2g]`, `outputs[2g+1]`; `g = 0` is the
  single-call ABI above. `opencl-host --sweep MODULE.spv KERNEL START COUNT`
  launches a one-parameter kernel over `START..START+COUNT-1` and prints the low
  32 bits of each result; any nonzero status fails. Large IR-mode units need the
  #889 candidate compiler (sha256 `2cf38551…`, fixpoint stage1 = stage2 =
  stage3; not the pin): per function 480 registers (each distinct literal takes
  one), 512 blocks, 4096 instructions, 480 names, 64 open blocks, error 14 over
  them. The guide-pin compiler (omega-mv `9920aab1`, and unchanged at main `d3d1b1bc7`:
  `global ir_rty uchar 64`, `ir_cty 32`, `ir_bord 32`, `ir_ok 256` in `seed/omc/omc.om`,
  read 2026-11-04) stops at 64 registers, 32 literals, 32 blocks and 256 instructions.
- Checked conversions trap on the device exactly as on the host: `ulong` of a
  negative `long` returns status `105` (trap 5). Mask on the signed type first
  (`kq = and add k qoff 3`, then `q = ulong kq`); converting first and masking
  after traps for every negative `k`. Sampled PoCL parity found this in the E1
  trig quadrant. Host check with omc `2c824805…`, repeated 2026-11-04 with the guide-pin omc
  `be8c5130…`: `q = ulong add k 1` on `k = -5` exits 105; `kq = and add k 1 3` then `ulong kq`
  exits 0.

### Developer kernel template (GitHub, CPU only)

[aien-dev/omega-kernel-template](https://github.com/aien-dev/omega-kernel-template) was the
public on-ramp for this backend. It is frozen GitHub history since 2026-11-07 and has no Radicle copy in
the hive Radicle registry yet, so do not create repositories from it and do not cite it as available.
The record below describes it as it stood: a developer created a repo from it
(`gh repo create my-kernel --template aien-dev/omega-kernel-template --public --clone`), edited
`kernel.om` and `reference.py`, and pushed. A free `ubuntu-24.04-arm` Actions job then fetches the
pinned omega-mv `omc`, `irspirv.om`, `opencl-host.c` and `parity.py` (commit `369dbc96`, sha256 in
`toolchain.lock`), runs every case natively on AArch64 and as SPIR-V on a PoCL 7.2 CPU device built
by the repo's own `toolchain.yml`, compares with `reference.py`, and uploads an
`omega-kernel-receipt` artifact (`receipt.json`, `SHA256SUMS`).

- Evidence: `main` run 40426781699 PASS 138/138; negative control `demo/wrong-kernel` (overflowing
  average) run 40426783628 FAIL 20/138. Rerun 2026-10-31 by workflow_dispatch: `main` at `02050226`
  run 41196263282 PASS 138/138, `demo/wrong-kernel` at `d26761f0` run 41196264947 FAIL 20/138.
  This is CPU-EXERCISED evidence only: no GPU, sm_121 SASS or CUDA++ path runs, and the receipt
  says so in `not_run`. The template still pins omega-mv `369dbc96` (omc `2c824805`), not the
  general compiler pin above.
- When omega-mv changes `omc` or `seed/spirv/`, a template pin bump needs a passing template run
  first; the PoCL asset changes only through `toolchain.yml`, whose self-test must pass.
- Its `tools/check.sh`, `tools/fetch.sh` and `tools/cases.py` are INTERIM host glue whose successor
  is an Omega conductor unit.

### Aienux SMMU probe event qualification (path 1)

- Merged: [aienux#469](https://github.com/aien-dev/aienux/pull/469) landed on main
  2026-10-30 as `dfdd5a72bbc30c05aa32da79f63f460e763d18b9` (exercised source
  `7d555ade734bd56787d4bfd477caa0e79d0a1134`, 2026-10-28). It adds
  `CK_B7B_PROBE=1 CK_B7B_EVENT_READOUT=1`. It prints all SIDs/raw event words,
  every accepted RMR identity exception, and a bounded final drain of each
  already-live SMMU queue before the final report; overflow/pending and
  inactive/failed instances are explicit. No event is not proof of no DMA.
- Exercised commands (on the source 2026-10-28, rerun 2026-10-31 at `dfdd5a72`):
  `make -C native/kernel test sanitize`,
  `make -C native/kernel iort-mutants smmu-l2-mutants`, and
  `bash scripts/qemu_ck_b7b_probe_test.sh` with `--self-test`, no flag,
  `--positive`, and `--events`, all exit 0. The new events mode observes actual
  emulated NVMe out-of-window DMA, matches decoded SID/address, intact canary
  and recovery read. DROP_EVENT is killed; missing/wrong-SID/wrong-address
  event, overflow and pending controls fail as required.
- A fixture-provisioned full hardware-staging-format artifact is **NOT
  boot-admissible**. Prerequisite 0 is the owner's actual public-key/machine
  identity ceremony; never generate substitute material. The non-staging
  core-only probe requires no Store identity, retains probe/readout code, and
  excludes device/security/Store stages; it is not the combined input/witness
  physical candidate. No staging gate was relaxed.
- Physical GB10/HDA0 faults and GPU DMA/cache visibility/recovery are NOT_RUN.
  The designed GPU test requires a native capability-bound map/submit,
  system-visibility fence, uncached completion and verified-quiesce endpoint;
  a Linux/VFIO protocol simulator does not supply it. Follow aienux
  `docs/campaigns/B7B-PHYSICAL-BOOT-PREP.md` at `dfdd5a72` or later and fresh operator
  authorization. This guide is not permission to stage, stop a service or boot.

### Path 3: bounded seeded Omega NVMe read protocol

Merged: [aienux #472](https://github.com/aien-dev/aienux/pull/472) landed on main
2026-10-30 as `aab6de6d4df4b4d99e764e91303a13d10684f5fe`; its confinement-retention
[fix #470](https://github.com/aien-dev/aienux/pull/470) landed as
`2b77170de9693a3204b65dff059e24c2cdecc197`. `native/disk` at the merge commit is
byte-identical to the exercised source `62393fb2ab03766c4be0273a1388af6d2f7247f8`.
This is HOST/QEMU EXERCISED, not physical qualification, a bootable storage stack
or a TRUST-1 Gate 7 pass.

- Use the existing driver compiler pin: omega-mv
  `397e67040fb74853c6814097fe02ae4e1ebd6f66`, omc SHA256
  `bcfa582892afca8f65e551fe56867d918d86e84540c7381be8fa9ef18d0cf0f6`.
  This compatibility pin does not replace the general compiler pin above.
- From aienux at `aab6de6d`, run `sh native/disk/tests/omega_nvme_test.sh`,
  with `AIEN_OMC` set to the absolute pinned compiler and
  `OMEGA_NVME_EVIDENCE` set to a new absolute evidence directory.
  Observed exit 0 (2026-10-28 on the source, rerun 2026-10-31 at `aab6de6d` with an omc
  rebuilt from seed at that pin): 37 host cases, seven killed guard-removal mutants and ten
  disposable-QEMU cases. The C driver is the independently compiled data oracle;
  the hosted C/QTest relay performs raw memory/register accesses, not the NVMe
  protocol. QEMU 8.2.2 and GCC 13.3.0 are verification-only dependencies. Any other
  compiler is refused before a case runs (`compiler pin mismatch`, exit 2).
- The Omega code owns Identify/manifest parsing, bounded queues and PRPs,
  head/tail/phase wrap, CID/SQID/SQ-head correlation, successful copy-out and
  fail-stop DMA retention. The central opcode guard refuses writes and other
  IO commands; removing it makes a hostile Write reach the model and fails
  the negative control. Identity, extent, format, completion and timeout
  refusals remain separately exercised.
- See `native/disk/tests/omega_nvme_receipt.txt` and
  `native/disk/OMEGA_NVME_READ.md` for hashes, manifest layout, reuse search,
  native adapter contract and the exact measurement-first physical procedure.
  The volatile/MMIO, DMA coherence/lifetime, timer and ownership adapter is an
  explicit integration prerequisite, not an excuse to call the C kernel binder.
  The existing binder reaches a write/flush/restore probe and is not read-only.
- Physical execution stays NOT_RUN until that adapter is exercised and the
  operator approves the exact device/namespace/extent, recovery/evidence media
  and service downtime. Do not open the live root block device or transfer its
  controller while Linux owns it. Capture latency/throughput before any tuning;
  host/QEMU results are not SSD measurements or hardware safety evidence.

### CUDApp portable backend (CUDApp#138, merged `0c782c44af`)

Paths below are on CUDApp main (present at `cc0908bdc0`).

- Target status lives in one place: `backend/targets.om` (`targets doctor`, printed by
  `make doctor OMC=/abs/omc`). Only the GB10 (sm_121) is SUPPORTED. Every other GPU row (other NVIDIA
  generations, AMD gfx9-12, Intel Xe, Apple, Qualcomm, Arm, Imagination, Broadcom, Vortex) is PLANNED,
  hardware NOT_RUN. PoCL and lavapipe rows are HOST-ONLY CPUs, never GPU evidence.
- `targets load FORMAT FILE [ENTRY|gfx]` is the `ob_code_load` admission check (SPIRV_CL, SPIRV_VK,
  AMDGPU_HSACO, SM121_RAW; MSL_SOURCE/AARCH64 refused as PLANNED, CUBIN reserved).
- FP32 SPIR-V comes from `backend/spirv/emit.om` (hand-built words; omc IR mode has no floats until E3,
  omega-mv#883), unlike the scalar-ulong irspirv above. Its CPU launcher is migration-pending C until
  E2 (checked shared-library calls, omega-mv#888).
- The gfx1151 HSACO on CUDApp main is an LLVM ORACLE fixture for the loader, not an AMD encoder.
- Gate: `make test-multitarget OMC=…` with negative controls; receipts
  `evidence/MULTITARGET-20261027T0638Z/` (host EXERCISED, 63 checks, CUDApp `0ec44766`). Never say a
  vendor is "supported" or "runs" from these host runs.
### Omegese GPU kernels (sm_121), PENDING omega-mv #885

This section stays pending until [omega-mv #885](https://github.com/aien-dev/omega-mv/pull/885) merges. It was exercised on its branch `c1/chip-fix` at
`e83c740c75ec3b534eef97ce3118c13f0fa65338` plus the evidence commit `8c66c1853`, and again at
`67d228d265439be346c85aca28bf753f0bc05241` (evidence and docs in `a9835368f`). Rechecked 2026-11-04:
#885 is open, draft and conflicting with main at head `c996a235a` (main merged in 2026-10-30, CodeQL
fixes in the `osc_gpu` tests, `.om` ports pinned to omc `62775d2a`); the results below were not
rerun at that head.

- Read `docs/omegese/GPU.md` before writing a kernel. It covers the kernel form, words, float rules,
  MUFU, shared memory and `sync`, the checker2 rules, and the launch checks in s11. The one encoder is
  `src/omega_blackwell_codegen.h`, and the launcher is `src/omega_osc_launch.c`.
- MUFU (`exp`, `inv`, `inv root`, `root`) is deterministic, but its results are not correctly rounded.
  A denormal input counts as zero. A result that should be denormal becomes a zero of the same sign,
  measured on the GB10 on 2026-10-22. A host reference has to state its tolerance before the run.
- Host: `make test-osc-gpu`. checker2 accepts 13 kernels and refuses 15 broken ones, each for its
  expected reason. The run has 1308 checks, and all 8 backend mutants are caught.
- Chip: `make test-osc-gpu-chip`, under the GB10 lock and the operator's GPU procedure. The green
  run at 2026-10-27T02:55:39Z was 645 checks with 0 failed, `om_vadd`/`om_gate`/`om_gemm`/`om_attn`
  included. The red control, `OSC_GPU_MUTANT=1`, fails 8 checks. Logs are in
  `evidence/omegese-gpu/chip-20261027/`.
- Wire format: GPU kernel units are OSC IR version 8, with kernel opcodes 40..46 (GPU..MAD). 30..39 are
  refused and ATOM is 47 (Determinism lane). #525 keeps v6, and v7 is the memory profile. Tags 13/14/15
  (F32/GVIEW/GEDIT) depend on the version: tag 14 is GVIEW in v8 and f64 in v7.
- Seeded `.om` ports in `seed/oscgpu/` (`oscir.om`, `gpu*.om`, `c2*.om`, built with the pinned
  `seed/out/omc`) stop at BlackwellIR. Register allocation and encoding stay in C, and the C stays the
  production path and oracle. Host: `make test-om-ports`. Run it once per tree, because two makes clobber
  `build/osc_gpu/om`. At 67d228d26: oscir n=6054 diff=0, checker2 21627 cases differ=0, lowering
  n=26556 diff=0, OMBYTES 119/0. `OSC_GPU_OM_DIR=<dir>` (from `tests/osc_gpu/om_build_all.sh`) makes
  the chip test launch the `.om` bytes. The GB10 run on 2026-10-27T16:30:40Z had 645 checks, 0 failed,
  OMBYTES 13/0, and the red control failed 8 (`evidence/omegese-gpu/chip-20261027T1630Z-om/`).
- The 35B gate swap (omega-mv #886, `AIEN_OMEGA_Q36_OMEGESE_GATE=1`) was EXERCISED on the GB10 in an
  authorized exclusive window on 2026-10-27T16:34Z (`evidence/omegese-gate-lever/golden-20261027T1634Z/`).
  Green: 8/8 cells PASS with `omegese gate on (code sha256 fabdfc55)`. Red, with the gate mutated to
  a*sigmoid(-g): 6/6 RED-OK. It is a draft, not merged. q36-extra loads only when the owner-only marker
  `~/.local/state/aien-coordinator/q36-live-down-for-tests` (mode 600) exists. That marker is the
  coordinator's to create, and a refused load is NOT_RUN, not FAIL.
- `make test-checker2-owner-receipt` fails with UNTRUSTED_CHECKER on #885 because checker2's identity
  changed. Drake's YubiKey re-sign is needed (BLOCKED_OPERATOR).

## 4. Effects and authority

- A proposed program or effect description does not authorize running it. Confirm capability and privilege at the execution boundary. Model confidence and semantic identity grant no authority.
- Do not weaken a gate, add a new trust path, publish secrets or fabricate hardware receipts. Never edit a historical receipt to make a new claim pass.
- Keep private machine targets, addresses, usernames and home paths in ignored local configuration. Keep intentional public attribution intact.
- Hardware and live services need the operator's current authorization procedure. Host and emulator checks never qualify hardware. Machine-specific operator rules belong in that machine's local instructions, not in public guidance.
- Escalate to an independent reviewer for hard-to-reverse changes to authority, protocols or gates, for contradictory evidence, or when two distinct fixes have failed. A model review is not an execution receipt.
- For the native GPU swarm, follow the [realization-record evidence boundary](../omega-communication/SKILL.md#native-gpu-realization-records-2026-10-28). A unit test calling an isolated cache or selector is not proof that the existing runtime records the selected code. Exercise the actual generated binding and consuming cache/command-list path, with stale-generation, wrong-artifact and missing-qualification controls. Keep device and whole-model tests NOT_RUN until their authorized execution; never populate production candidates from synthetic host records.
- **Fix it, don't file it** (Drake, 2026-10-25). A defect you can reproduce is a defect you chase in the same piece of work, including one you found while reviewing someone else's lane: read the code, build the smallest reproduction, change it, prove it, ship it. Reporting a blocker you have not tried to fix, or handing a reproduced bug to an "owner", is unfinished work. Stop only for a real external gate (authorization, a user decision, an exhausted check) and name it after the attempt.

### NVIDIA tools and licensed inputs (provenance)

Hardware facts for NVIDIA back ends follow `PROVENANCE.md` in aien-dev/CUDApp (CUDApp#110, merged as `a8878c955ac16c7b507a46e530e4ca102b935b9a`) and aien-dev/omega-mv (omega-mv#874, merged through the train omega-mv#972 as `f5c9bd89ae604a65d7c777a5739c176f41a036ec`; present at omega-mv main `91c83438daec0bdb88bf5c077cae10f3d15d365d`, omc sha256 `2aec185d4ed6d7a6a5779ed656b4e56904742bde5551b02893fb5f73916ad8d5`), which quote the clauses (CUDA Toolkit EULA, January 2025 revision, §1.2(1), §1.2(8), §1.1.2(4), §2.1; NVIDIA driver licence §2.1, §2.2; MAX License §1.4, October 21, 2026). Engineering rule, not legal advice:

- Cite public documentation (PTX ISA, CUDA Binary Utilities, open-gpu-doc), permissively licensed source (NVIDIA open kernel module headers, Mesa NAK/NVK, LLVM `ELF.h`, CUTLASS) or a chip receipt for each fact.
- `nvcc`, `ptxas`, `cuobjdump` and `nvdisasm` are proprietary, internal-use SDK tools. Run them only on inputs we wrote (our probe kernels, our encoder's bytes), only for NVIDIA targets, and record the version and command. Never ship or wrap them.
- Never disassemble, extract or read the machine code of an NVIDIA binary: libcuda, cuBLAS, cuDNN, TensorRT, NCCL, driver, firmware, or cubins inside NVIDIA libraries, on any machine including rentals.
- Never carry a fact learned from NVIDIA tool output into a non-NVIDIA back end.
- Never give MAX source to an AI system to build a substitute for MAX; reading it to interoperate is allowed.
- Record every stored NVIDIA-tool listing in the repository's `PROVENANCE.md`. A golden copied from tool output is a regression pin, not independent evidence.
- In public text, describe the work as independently implemented from public documentation and open source, checked with NVIDIA's tools on my own code. Avoid "reverse-engineered NVIDIA's compiler/driver", "CUDA clone" and an unqualified "byte-identical to nvcc".

### Aienet M1 loopback microjobs (aien#24 and open-humanity#52, merged)

Source of truth: `docs/GOAL_MICROJOBS.md` in aien-dev/aien at
[`c149760e`](https://github.com/aien-dev/aien/blob/c149760e8722ed943abcc5e3c7a33e2065b4036c/docs/GOAL_MICROJOBS.md)
(aien#24, merged 2026-10-31), sections "Canonical Aienet-0 adapter (M1)" and "M1 loopback execution
and interruption acceptance". Rules an agent must keep when touching that path:

- **Canon framing.** `canon emit` takes the 17-word header, one 23-word node, its `101` status and
  the `4 …` binding record, and writes `document[640] || payload[15] || dag_digest[32]`. `canon ingest`
  takes `document[640] || MJR1[404] || AN0V[236]` plus a 23-word ASCII record. Words 15..18 (objective)
  and 19..22 (effective operand) come from the trusted header and from `recovery.om` replay of the
  trusted plan+journal, never from the submitted document or bundle. Success prints exactly two
  events, RESULT and then VERIFY. Refusals are `CANON_<NAME>` with exit 2..26.
- **External sealing.** `aienet0-run bundle --keys DIR --out job.an0b --document FILE --payload FILE`
  (open-humanity#52, merged as
  [`4cbf6526`](https://github.com/aien-dev/open-humanity/commit/4cbf6526458b9251cd48e0a41946a1112de4c279)):
  both flags together, never mixed with shape flags. It signs the unchanged bytes and self-admits them
  with `admit_bundle` before writing output. It validates bytes, not provenance. Protocols pin stays
  `7bfb4ee2`.
- **P-256 stays in Open Humanity.** `canon.om` verifies no signature. The caller runs
  `aienet0-run check` against its pinned executor and verifier keys before ingest; passing ingest alone
  is not authenticated completion. Omega P-256 verification is not claimed, and `canon.om` handles
  only the one-node COMPUTE/MATMUL Aienet-0 shape. It is not a general DAG serializer.
- **Pinned recompute.** `run.sh` requires the recompute binary SHA-256 `d2cd7382…ea12`, the canon
  binary `4d7d2a0b…2b1b` and the canon sources by git blob id. `recovery-build.sh` and
  `canon-build.sh` refuse any omc other than `2c824805…` (exit 3, `BLOCKED`).
- **Crash guards.** The sequencer persists and `sync`s the signed bundle before it proposes DISPATCH,
  and resends using the worker's durable `--retry` state. After a crash, recovery compares an
  already-persisted RESULT field by field with the canonical one (mismatch: Omega exit 33) and appends
  only the matching VERIFY. It never re-dispatches or replaces a completion. Refusals: stale generation
  14, changed operand 24 (checked first), objective 23. The kernel refuses duplicate completions
  (wrong state, 33).
- **`recovery.om`** reads `1\n` followed by the unchanged plan+journal bytes, applies every CORRECT
  and emits the 40-word effective header/node. It has the kernel's 262144-byte buffer: input of
  262143 bytes or more exits 3, and the prefix is not counted.
- **Acceptance:** `tests/goal_microjobs/aienet-m1/run.sh FRESH_DIR` with `OH_TREE`, `PROTOCOLS`,
  `OMEGA_WORKTREE`, `RECOMPUTE_OMC`, `SHA_OMEGA_TREE` and `CANON` set (full command in the doc). It
  writes `summary.tsv`, `mutants.tsv`, `pin-refusals.tsv` and `capacity.tsv`. aien#24 reports
  32 PASS / 0 FAIL and 7/7 mutants KILLED: HOST_TESTED, loopback only.
- **Shell status.** `sequence.sh`, `run.sh`, `canon-build.sh` and `recovery-build.sh` are migration
  adapters under [aien#22](https://github.com/aien-dev/aien/issues/22) (open). Admission, folding and
  RESULT-identity decisions are Omega (`kernel.om`, `canon.om`, `recovery.om`). P1 two-machine, P2
  federation, Core TUR settlement, GPU, hardware and deployment are NOT_RUN.

## 5. Communicate and learn

Follow `omega-communication`. Keep proposed, implemented, exercised, qualified, merged and deployed separate. A receiver needs the minimum sufficient definitions, inputs, constraints, evidence and open uncertainty, not the whole conversation. Never drop a prerequisite just to make a handoff shorter.

When an error repeats:

1. Stop repeating the failed pattern.
2. Reduce the problem to a runnable counterexample.
3. Work out whether the syntax, a compiler limit, a protocol, an authority or the expectation itself was wrong.
4. Check the authoritative source.
5. Make one targeted correction.
6. Rerun the counterexample and the negative control.

Record only the verified causal lesson, with its pin and the condition that would invalidate it. Never turn an untested workaround into an unconditional rule.

## 6. Keep the guides current (part of every task)

Whichever agent makes a change also updates the guides. Do not leave it for someone else. A task that changes something these skills describe is not done until the matching skill matches the new reality.

Before you finish, check whether your change touched any of these, and update the skill that covers it:

| You changed | Update |
|---|---|
| Omega syntax, keywords, types, traps, limits, error codes, host or device words, the compiler or its pin | `omega-encoding` and `writing-omega`, plus the pins in `omega-harness`; add or update the program in `examples/` and rerun `examples/gate.sh` |
| Build, compile, gate or verification commands, or the seed procedure | `omega-harness` sections 3 and 4 |
| Conversion, encoder or bridge behavior, or what it supports | the conversion note in `omega-harness` section 2, and the README |
| Status vocabulary, receipts, report or handoff conventions, wire formats | `omega-communication` |
| Repository purpose, ownership, names, archive state, plan authority, merge or Alpha policy, a resolved or new contradiction | `aien-repositories` |
| Any project repository's purpose, status or links, or a new repository | that repository's entry in the sovereign-intelligence Radicle repository (`rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj`) `index/curated.yml` (layer, evidence, one-line purpose), in the same piece of work |
| A new source of hardware facts, a new use of an NVIDIA SDK tool, or stored NVIDIA-tool output | that repository's `PROVENANCE.md`, and section 4 here if the rule changed |
| These skills, their install method or their layout | the README and the affected skill |

How to do it:

1. Edit the guide in the same piece of work as the change. Give the new source commit and date, and remove any rule the change made untrue; do not just add a contradicting one.
2. If an example or expected output changed, rerun it against the new pin and record what you observed. Never copy a predicted result into the guide.
3. Hand the change in as a Radicle patch on omega-harness (`rad:z39gvwWsnkRZsAConQLjaKiNVLHfW`) with the evidence, linked to the change that caused it: write a READY file (repo, base, head, bundle, gate logs, negative control) and the Radicle publishing lane opens the patch; the desk merges after a signed review of the exact head. Lanes never push to Radicle or GitHub, and the `aien-dev` GitHub org is frozen, so never open a GitHub PR or issue there. If the causing change is not merged yet, say in the READY file that the guide patch is pending until it lands.
4. If you are not allowed to change the guide, or you are unsure, give the desk a note describing exactly what is now stale (the publishing lane can file it as a Radicle issue), and say so in your report. Silence is not an option.
5. Your final report must say one of two things: which guides you updated, or that no guide was affected and why.

## Sources

- Shared public rules: https://www.aienos.com/agents/RULES.md
- Repository contract: https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/AGENTS.md
- Seed construction: https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/seed/omega-from-seed.sh
- Language: https://github.com/aien-dev/omega-mv/blob/55f9b0af47de70a3d06357985cf99ae3e45c016f/docs/one_layer/OMEGESE.md
- OM-2 contract (normative, on main since #801): https://github.com/aien-dev/omega-mv/blob/19f014f2178ca9cd3473728fe00a475a2398c409/spec/omegese-om2.md
- Omega 1.0 roadmap and its acceptance gates (a plan, not a status claim; tracking issues #790..#800): https://github.com/aien-dev/omega-mv/blob/19f014f2178ca9cd3473728fe00a475a2398c409/docs/ROADMAP-1.0.md

When the compiler changes, refresh the pins and the examples. Older measured evidence stays as dated history: correct the guidance rather than rewriting receipts.
