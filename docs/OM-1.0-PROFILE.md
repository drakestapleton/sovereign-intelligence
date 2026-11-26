# Omega `OM-1.0` Frozen Language Profile & 1.x Compatibility Contract (RM11)

```text
Document:   docs/OM-1.0-PROFILE.md
Milestone:  RM11 (docs/ROADMAP-1.0.md)
Status:     DRAFT READY FOR 1.0 FREEZE (normative specification; tag freeze requires all RM1..RM10 gates PASS at one release commit)
Scope:      Exact union of OM-1, OM-2, RM2 contracts, RM4 runtime pools, RM5 text, RM6 digest modules, dual infix surface, RM7 FFI, RM8 diagnostics, and RM9 declared targets
```

## 1. Purpose and Profile Boundaries

`OM-1.0` is the single frozen language and toolchain profile for the Omega 1.0 release. Any construct, host word, target, or diagnostic behavior listed in this specification is supported under the 1.x compatibility promise (§9); **anything not listed here is unsupported regardless of whether a draft compiler accepts it.**

Opt-in header lines (first line that is neither blank nor `note`):

| Profile Header | Mode | Semantics |
| --- | --- | --- |
| *(omitted)* | `OM-1` | Frozen OM-1 baseline; preserves C1/C2 compatibility for legacy units |
| `om2`, `om2 debug`, `om1.0`, `om1.0 debug` | `OM-1.0` Debug (default) | Full `OM-1.0` profile with all runtime checks and executable contracts enforced |
| `om2 release`, `om1.0 release` | `OM-1.0` Release | Full `OM-1.0` profile with spec-justified contract erasure (`omc-check` reports every `kept`/`erased` rule) |
| `om2 diag [debug\|release]` | `OM-1.0` Diagnostics | Emits structured `omc-diag` / `omc-check` records on stderr alongside standard single-line diagnostics |

`om1.0` and `om2` denote the same `OM-1.0` source semantics; `seed/modules/rm6/modlink.om` normalizes `om1.0` headers cleanly to `om2` when driving `seed/out/omc` so `seed/out/omc`'s birth fixpoint and C2 manifest stay untouched.

---

## 2. Exact Language Union of `OM-1.0`

### 2.1 Core Foundation: OM-1 (`docs/one_layer/OMEGESE.md` §§3, 9, 10)

- **Types:** `bool` (`true`/`false`), unsigned integers `uchar`/`u8`, `ushort`/`u16`, `uint`/`u32`, `ulong`/`u64`, signed integers `byte`/`i8`, `short`/`i16`, `int`/`i32`, `long`/`i64`, IEEE 754 floats `f32`/`f64`, bounded quantity `qty`, and function-result-only `void`. No implicit conversions.
- **Prefix Canonical Syntax:** One statement per line; fixed-arity prefix operators (`add`, `sub`, `mul`, `div`, `rem`, `and`, `or`, `xor`, `shl`, `shr`, `eq`, `ne`, `lt`, `le`, `gt`, `ge`, `neg`, `not`, `fsqrt`, `fabs`, `fmin`, `fmax`, `fma`, `bitcast`); structured blocks (`fn`, `if`/`else`, `while`, `for`, `struct`) terminated by `end`; `note` comments; definite assignment within lexical scope; non-short-circuiting `and`/`or`.
- **Bounded Execution & 14 Traps:** Every loop is bounded (`while COND bound N` and `for i T K [bound N]`, `N` in `1..9223372036854775807`; default `1000000` without `bound`, trap 4 on overrun). All 14 traps (`1..14`) terminate with process exit `100 + N` in program mode or status `N` in function mode:
  - `1 OVERFLOW`, `2 DIV0`, `3 BOUNDS`, `4 LOOP_BOUND`, `5 CAST`, `6 OOM` (8 MiB stack), `7 SHIFT`, `8 RUNTIME`, `9 REQUIRES`, `10 ENSURES`, `11 ARENA_FULL`, `12 STALE`, `13 POOL_FULL`, `14 RETIRED`.
- **Identifiers & Compiler Capacity (No-Caps Rule, OMEGESE §9.6):** Up to 63-byte identifiers (`manifest-c2-longnames.txt`; 8 bytes for `abstract`/`layout`/layout-field/IR names); 6 parameter slots per function; 16-register scalar pool (`error 12`); dynamic growing compiler arena bounded only by host memory or `OMC_MEMORY_MAX` (`error 26` on malformed ceiling).
- **Host Words (Program Mode, Linux AArch64 / x86-64):** The 80 audited host words (`fopen`..`pwrite`, `chown`..`symlnk`, `getuid`..`execpure`, `shutdown`..`peername`, `monons`..`random`, `dit`, `scrub`, plus checked device/mapping words `devctl`..`kfdres`). Every host word returns `long` (`>= 0` or `-errno`) and checks slice bounds before kernel invocation.

### 2.2 Checked Systems Slice: OM-2 (`spec/omegese-om2.md`, errata E1..E18)

- Lowercase hexadecimal literals (`0x...`) and unsigned bit rotations (`rotr`, `rotl`, trap 7 on shift >= width).
- Unsized checked slices: `view T *` (read-only) and `edit T *` (writable) parameters occupying 2 parameter slots (pointer + runtime count `len`), plus checked sub-slice argument form `part A off n` (trap 3 on overrun; never on globals, error 19).
- Explicit opt-in transformations: `for i T K unroll` (`K` in `1..64`) and `fn ... to T inline`.
- Initialization & encapsulation: `edit T N fresh` (definite write-before-read, error 27), `abstract NAME T [ops ...]` with `seal`/`open` (error 28) and `holds NAME dup32`.
- External wire/binary layouts: `layout NAME SIZE` / `field F T [COUNT] at OFF little|big` / `end` (error 29).
- Function-mode ABI outputs: `out T N` (copied out only on status 0) and `export fn` (up to 32 exported entries per function-mode unit).

### 2.3 Executable Contracts: RM2 (`docs/one_layer/OMEGESE.md` §12)

- Function preconditions (`requires C`) and postconditions (`ensures C`, with `result` naming the return value) at the top of a function body; loop invariants (`invariant C`) as the first line of a loop body.
- **Purity Rule:** Contract clauses permit only pure integer/boolean expressions (no function calls, no floats, no host words; violation is `error 30`).
- **Soundness & Erasure:** Failing `requires` traps `9` (exit `109`); failing `ensures` or `invariant` traps `10` (exit `110`). `om1.0 debug` / `om2` checks every clause at runtime; `om1.0 release` / `om2 release` erases only clauses permitted by the spec, reporting every decision (`kept` / `erased` + rule) under `diag`. IR mode refuses contract units explicitly rather than dropping them.

### 2.4 Memory Model & Run-Time Pools: RM4 (`docs/RUNTIME-POOLS.md`, OMEGESE §9.15)

- **Decision 24 Retained:** No general-purpose heap, no garbage collector, no `free`.
- **Storage Tiers:**
  1. Stack-local fixed arrays (`new T N v`, up to 4 MiB per function).
  2. Static global arrays (`global NAME T N`, up to 16,777,216 elements / 1 GiB total).
  3. **Run-time pools (`global NAME T *`):** Zero-length at startup, grown monotonically via `r = enlarge NAME n` (`mmap` / `mremap`, zero-filled new elements, never shrinks). Returns `0` on success, `-22` (`EINVAL`) on `n * sizeof(T) >= 2^63` overflow, or `-12` (`ENOMEM`) on host refusal — leaving existing contents intact. Every `get`, `put`, `len`, `read`, `write` checks the runtime length (trap 3) and obeys soundness rule B1 (load pool slot strictly after evaluating operands).
  4. Explicit OS mappings (`mapnew`..`mapbind`) for device/large-buffer I/O.
- **No Implicit Allocation:** No existing word allocates hidden heap memory.

### 2.5 Byte & UTF-8 Text Library: RM5 (`seed/text/text.om`)

- Composable, zero-global, zero-host-word pure-Omega unit providing:
  - Byte comparison & search: `tx_eq`, `tx_cmp`, `tx_find`, `tx_field`.
  - Strict integer parse/format (no wrap, range refusal): `tx_pdec`, `tx_phex`, `tx_pdeci`, `tx_fdec`, `tx_fdeci`, `tx_fhex`.
  - Strict RFC 3629 UTF-8 validation, decode, length, and encode (rejecting overlong forms, surrogates `U+D800..U+DFFF`, values `> U+10FFFF`, and truncated sequences): `tx_u8ok`, `tx_u8dec`, `tx_u8len`, `tx_u8enc`.
- Function-mode `text` literals remain explicitly refused with `error 9` (OMEGESE §9.12); caller-owned `view uchar *` / `edit uchar *` slices operate identically in both program and function modes.

### 2.6 Digest-Addressed Modules & Separate Compilation: RM6 (`seed/modules/rm6/modlink.om`, `seed/modules/driver.om`)

- **Normative Import Form:**
  ```omega
  import <alias> sha256:<64-hex> pin:<64-hex>
  ```
- **Content-Addressed Resolution:** Modules resolve strictly by SHA-256 digest from `MOD_STORE_DIR` (or explicit `--store <dir>`). No ambient filesystem search paths, no unpinned version ranges, no network fetches.
- **Visibility Rule:** Only declarations marked `export fn <name>` are visible across module boundaries via `<alias>.<name>`. Private `fn` definitions are inaccessible from importing modules (`ML_ERR_VISIBILITY = 47`).
- **Mandatory Fail-Closed Checks:** Every build/link verifies:
  1. Compiler binary SHA-256 matches both `--pin` and every import's `pin:<64-hex>` (`ML_ERR_PIN = 41`).
  2. Every resolved module's canonical body SHA-256 matches `sha256:<64-hex>` (`ML_ERR_DIGEST = 40`).
  3. Every module's profile (`om1.0`/`om2`, debug vs release) is valid and consistent (`ML_ERR_PROFILE = 42`).
  4. No duplicate `export fn` names exist across the linked DAG (`ML_ERR_DUP_EXPORT = 43`).
  5. The import graph is strictly acyclic via 3-color DFS (`ML_ERR_CYCLE = 44`).
  6. Missing store entries refuse immediately (`ML_ERR_MISSING = 45`), leaving output paths absent.
- **Link Parity:** Linking separately authored modules into program-mode ELFs or function-mode machine-code libraries produces bit-exact output matching single-unit concatenated builds.

### 2.7 Dual Surface Syntax (Optional Human-Readable Infix): `seed/ng/infix/`

- `OM-1.0` preserves canonical prefix `.om` as the sole normative interchange and seed-compiler input form.
- Developers may author or read `OM-1.0` in clean human-readable infix syntax via `seed/ng/infix/infix_front.om` and bidirectional `seed/ng/infix/om_fmt.om` (`--to-infix` / `--to-prefix`):
  - Standard arithmetic/bitwise precedence, array indexing `buf[i * 4 + 2]`, `fn name(a: ulong) -> ulong { ... }`, `if`/`else`, `for i in 0..n`, `while cond bound N`, `view`/`edit`, `//` comments.
  - Lowers deterministically to canonical prefix `OM-1.0` yielding the **exact same `ΩIR` and SHA-256 `SEMANTIC_ID`** as hand-written prefix `.om`, with fail-closed refusal on malformed precedence, unclosed delimiters, or reserved-word collisions.

---

## 3. Foreign Function Interface: RM7 (`omega-bridge` ABI v2)

- **Symbol & Identity Binding:** Function-mode units export `omega2_<name>` symbols bound to an exact immutable identity string (`omega2_ident`) embedding source SHA-256, `omc` compiler SHA-256, ABI version (`2`), and profile (`OM-2` / `OM-1.0`).
- **Status Codes:** `0` success; `1..14` Omega runtime/contract traps (never UB); `32` invalid argument (null pointer, aliasing `edit`/`out`, bad length — rejected before Omega code runs); `33` forbidden reentry.
- **Byte-Traceable Rust & Zig Integrations:** `#![forbid(unsafe_code)]` Rust lock/parity bridge (`bridge/rust-trace/`) and optional Zig ABI v2 plugin (`bridge/tensorfold-omega/`) verify source/binary/proof SHA-256 locks fail-closed at build time.

---

## 4. Stable Diagnostic & Error-Code Registry: RM8 (`seed/omc/error-codes.reg`)

The canonical human diagnostic prefix `omc: line N: error E` on stderr (with empty stdout on refusal) is frozen for `OM-1.0`. All 30 `omc` exit codes:

| Code | Class | Meaning |
| --- | --- | --- |
| `1` | io | Compiler stdin unreadable |
| `2` | io | Compiler stdout unwritable |
| `3` | emitted | Unknown name or field, or word unavailable in mode |
| `4` | emitted | Line ends early (missing operand) |
| `5` | emitted | Extra words after complete statement |
| `6` | emitted | Malformed number or token |
| `7` | emitted | Type mismatch |
| `8` | emitted | Number out of range for type or construct |
| `9` | emitted | Word or declaration disallowed in this position/mode |
| `10` | emitted | Duplicate declared name |
| `11` | emitted | Ambiguous bare numeric literal without context type |
| `12` | emitted | Register pool exhausted (16 scalar slots) |
| `13` | emitted | Name exceeds length limit (63 B general; 8 B abstract/layout/IR) |
| `14` | emitted | Capacity exceeded (host OOM, `OMC_MEMORY_MAX`, nesting, or expansion bound) |
| `15` | emitted | Missing `end` |
| `16` | emitted | Syntax error or unknown/misplaced keyword |
| `17` | emitted | Unreachable statement after `ret`/`break`/`continue`/`trap`/`exit` |
| `18` | emitted | Non-void function can reach `end` without `ret` |
| `19` | emitted | Global passed as argument or aliased array passed twice |
| `20` | emitted | Write to read-only `view` or `text` |
| `21` | emitted | Constant array index out of bounds |
| `22` | emitted | Malformed `text` literal or invalid escape |
| `23` | emitted | Array or global size capacity exceeded |
| `24` | emitted | Branch displacement out of range |
| `25` | emitted | Construct unavailable on selected `target` |
| `26` | io | Malformed `OMC_MEMORY_MAX` environment ceiling |
| `27` | emitted | `fresh` scratch element read before definite write |
| `28` | emitted | `abstract` `seal` outside constructor or unsupported `holds` |
| `29` | emitted | `layout` declaration out of bounds, overlapping, or misplaced |
| `30` | emitted | Contract clause (`requires`/`ensures`/`invariant`) misplaced or impure |

Extended machine-readable diagnostics are selected via `OMC_DIAGNOSTICS=2` or `om2 diag`.

---

## 5. Declared 1.0 Target Matrix & Honest Evidence Discipline (RM9)

Every target declares its exact transport tier and separates host/emulated evidence from physical silicon evidence (`seed/ng/multi_target/vendor_targets.om`). Unlisted targets are unsupported.

| Target | Directive / Transport | Tier | Honest Evidence Boundary |
| --- | --- | --- | --- |
| Linux AArch64 (Grace X925/A725) | default (`seed/out/omc` ELF64) | Tier-1 Native | `HOST_VERIFIED` + `PHYSICAL_SILICON` (DGX Spark) |
| AArch64 UEFI PE32+ | `target a64efi` (`aienux`) | Tier-2 Bare-Metal | `EXERCISED_EMULATED` (QEMU/EDK2); physical boot separate ceremony |
| Linux x86-64 / Windows WSL 2 | `target x86linux` (static ELF64) | Tier-1 Native | `EMULATED` (QEMU x86-64); physical x86-64 `NOT_RUN` |
| macOS Apple Silicon | `target a64macos` / `@ng a64 macho` | Tier-1 Native | `HOST_VERIFIED` Mach-O emit; physical Mac qualification separate |
| NVIDIA GB10 Blackwell (`sm_121`) | Zero-CUDA `/dev/nvidia0` + `ΩIR -> SM121` | Tier-1 Native | `HOST_VERIFIED` in CPU gates; `PHYSICAL_SILICON` only in authorized GB10 windows |
| NVIDIA RTX 5090 (`sm_120`) | `TargetDesc` + Tier-0 SPIR-V fallback | Tier-0 / Planned T1 | `HOST_VERIFIED` / `PHYSICAL_SILICON=NOT_RUN` |
| AMD MI300X (`gfx942`) & Strix Halo (`gfx1151`) | `/dev/kfd` HSACO + `TargetDesc` | Tier-1 / Tier-0 | `HOST_VERIFIED` (`card.tsv` prior MI300X receipt); local `PHYSICAL_SILICON=NOT_RUN` |
| Intel Arc Xe2 (`drm/xe`) | `/dev/dri/renderD128` CCS + `TargetDesc` | Tier-1 / Tier-0 | `HOST_VERIFIED` / `PHYSICAL_SILICON=NOT_RUN` |
| Universal Tier-0 (`SPIR-V` / `WASM`) | `irspirv` / `irwasm` / `mt_route` fallback | Tier-0 Interop | `HOST_VERIFIED` (CPU/VM oracle); GPU execution `NOT_RUN` |

---

## 6. Explicitly Excluded from `OM-1.0`

Unless added by a recorded architectural decision and a new profile specification:

- Shared-memory multi-threading and lock-free atomics (FR-6).
- General constant-time or microarchitectural side-channel guarantees beyond `dit`/`scrub`.
- Arbitrary C-ABI struct packing outside explicit `layout` definitions (FR-2).
- Manual `free` or garbage-collected heap allocation (Decision 24).
- Arbitrary dynamic shared-library loading (`dlopen`) or silent fallback across hardware contracts.
- Any hardware qualification claim on chips not physically executed and receipted under `evidence/`.

---

## 7. Written 1.x Compatibility Promise (C1 / C2 / C3 / C4)

Every compiler release numbered `1.x` (e.g., `1.0`, `1.1`, `1.2`) commits to four binding invariants:

1. **C1 — Semantic & Diagnostic Preservation:** Every `OM-1.0` program (whether accepted or refused) MUST preserve its compile verdict, exact `omc` error code (`1..30`) and line number, stdout bytes, exit status, runtime trap code (`1..14`), and trap evaluation order on every later `1.x` compiler.
2. **C2 — Machine-Code Byte Identity (Manifest Scope):** Every unit listed in `seed/qualification/om2/manifest-c2.txt` (as amended only by reviewed, explicitly named `manifest-c2-*.txt` deltas) MUST compile to byte-identical output or identical refusal. Opt-in features added in `1.x` never alter code emitted for units that do not opt into them.
3. **C3 — Self-Hosting Seed Birth Invariant:** Every `1.x` release MUST reproduce `seed/out/omc` bit-for-bit from the 408-byte `seed/rung0/seed0.hex` ladder (`om4(omc.om) == omc(omc.om) == omc(omc(omc.om))`) and record its compiler SHA-256, source commit, birth log, and RM1..RM10 receipts immutably under `evidence/`.
4. **C4 — Proof-Gated Optimization Only:** No `1.x` optimization may erase a bounds check, overflow check, shift check, or contract clause without a documented, verified proof rule (e.g., Lean 4 / `EGP3` witness). Missing proof always preserves the checked emission or refuses with a named obligation.

### Deprecation and Evolution Policy

- **Additive `1.x` Changes:** New library units, new opt-in targets (`target <name>`), non-breaking diagnostic detail under `OMC_DIAGNOSTICS=2`, and proof-preserving optimizations are permitted within `1.x` provided C1, C2, C3, and C4 hold across the full conformance suite.
- **Breaking Changes Require a New Profile:** Any change that alters C1 semantics, reserves a previously legal identifier in `OM-1.0` units, changes trap ordering, or breaks C2 without a reviewed delta MUST introduce a new explicit opt-in profile header (e.g., `om2.0` backed by `spec/omegese-om2.0.md`). Existing `om1.0` / `om2` units continue compiling under `OM-1.0` rules without silent behavioral drift.
