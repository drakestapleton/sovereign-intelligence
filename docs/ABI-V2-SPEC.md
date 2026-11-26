# Omega Native Call ABI v2 — Normative Contract (RM7)

> Status: `HOST_VERIFIED` specification and multi-language qualification contract for `omega-bridge` native call ABI v2 (`omega2_*`), closing `docs/ROADMAP-1.0.md` §RM7.
> Scope: Pure seeded OM-2 units compiled by the pinned `seed/out/omc` compiler and bound by `bridge/omega-bridge/src/native.om` (plus pure-Omega shared libraries emitted by `bridge/shlib/shlib.om`).

---

## 1. Normative Sources & Pinned Provenance

| Artifact | Path / Origin | Pinned Identity |
|---|---|---|
| Seeded compiler (`omc`) | `seed/out/omc` (`seed/out/omc.sha256`, `om/units.sh` `OMC_PIN`) | SHA-256 `85b84c6de85083e4d9d2368015c1ddcab3d863aada922be0e63d774dddf23134` |
| Bridge lock (`om/omega-bridge.lock`) | External `omega-bridge` repo commit pinned for `om/units.sh` (`NATIVE_PIN`) | Commit `9a0669d3a2e3f90535149c1838a01911f31d6c56`, `src/native.om` SHA-256 `9788b27a92c8dd365de7052439653de62f89634189a34cb6b3f582cae65dda83` |
| In-tree bridge generator | `bridge/omega-bridge/src/native.om` (imported at `1e24af598fb2`) | SHA-256 `9b850656591efe6d19a0075930ead944e84dd14aef1f41450385e531b9bdf80f` |
| Pure-Omega ELF64 `ET_DYN` builder | `bridge/shlib/shlib.om` | Pure seeded OM-2 (`OMOBJ001` -> ELF64 `ET_DYN`, zero C/linker) |
| Language & RM2 contract spec | `docs/one_layer/OMEGESE.md` (§1–§12) | Contracts: `requires` -> trap `9`, `ensures`/`invariant` -> trap `10` |

**Pin note (recorded honestly):** `om/units.sh` currently checks external `../omega-bridge` at `9a0669d3...` (`NATIVE_PIN = 9788b27a...`), whereas the vendored in-tree generator `bridge/omega-bridge/src/native.om` (used directly by `bridge/abi-v2-spec/gate_abi_v2.sh` without requiring a sibling checkout) is at `9b850656...`. Both implement the exact ABI v2 wire contract specified below.

---

## 2. Unit Framing, Profile Selection & Identity String

### 2.1 Profile Selection (`om2`)
An input unit to `native.om` is bound under **ABI v2** if and only if its first non-`note` line is literally `om2` (no leading/trailing spaces; `om2 diag` and `om2 fmt` are refused with generator trap `10`). Units without `om2` are bound under legacy ABI v1 (`omega_<name>`).

### 2.2 Stdin Wire Framing for `native.om`
Each OM-2 unit supplied on `native`'s stdin has the exact byte sequence:

```text
<exact .om source bytes>
\x00
<8 ASCII decimal digits = byte length of function-mode machine code>
<raw function-mode machine code bytes emitted by seed/out/omc>
omega-unit <UNIT_NAME> <64 lowercase hex digits = SHA-256 of omc>\n
```

- `UNIT_NAME` must be a valid C identifier (`[A-Za-z_][A-Za-z0-9_]*`) and unique across all units in one library.
- `native.om` computes the FIPS 180-4 SHA-256 digest of the exact source bytes before `\x00` (`src=...`) and pairs it with the supplied compiler digest (`omc=...`).
- The embedded machine code is placed byte-for-byte unchanged into `.text.omega_bridge` (`ombr2_code_<UNIT_NAME>`).

### 2.3 Unit Identity Export (`omega2_ident_<UNIT_NAME>`)
Every ABI v2 unit exports a C-linkage identity function and matching compile-time constant across all language bindings:

```c
const char *omega2_ident_<UNIT_NAME>(void);
```

Returned NUL-terminated ASCII string:

```text
omega-ident 1 unit=<UNIT_NAME> abi=2 profile=OM-2 src=<64-hex> omc=<64-hex>[ host=<w1,w2,...>]
```

- The optional ` host=...` suffix lists allowed OM-2 host words in canonical keyword order when compiled in `host` / `x86host` mode; pure units omit it.
- Python's generated `ctypes` binding checks `omega2_ident_<UNIT_NAME>() == OMEGA2_IDENT_<UNIT_NAME>` at module import time and raises `ImportError` on mismatch.
- C/C++, Rust, Zig, and Go bindings expose both the runtime symbol (`omega2_ident_<UNIT_NAME>`) and compile-time constant (`OMEGA2_IDENT_<UNIT_NAME>` / `Omega2Ident_<UNIT_NAME>`).

### 2.4 Export Naming & ABI v1 Isolation
- Each `export fn <NAME> ...` in an OM-2 unit binds as **`omega2_<NAME>`** in source order (maximum 32 exports per unit; maximum 256 bound names across a library; `main` and duplicate names across v1 and v2 are refused).
- If an OM-2 unit contains zero `export fn` lines, its last `fn` is bound as `omega2_<NAME>`.
- ABI v1 symbols use prefix `omega_<NAME>`, while ABI v2 symbols use `omega2_<NAME>`. A caller compiled against the wrong ABI prefix or unit identity fails closed at **link time** (undefined reference) or **load time** (`dlvsym` / `ImportError`).
- Optional layout metadata comments before `om2`:
  - `note bridge c-type <LAYOUT> <C_STRUCT_NAME>` maps layout `<LAYOUT>` to `<C_STRUCT_NAME>` in `api`/`apih`/`apic`/`fapic` output.
  - `note bridge c-define <NAME> <DECIMAL_VALUE>` emits `#define <NAME> <DECIMAL_VALUE>` in `api`/`apih` output.

---

## 3. Calling Convention, Parameter Classes & Aliasing Rules

### 3.1 C Entry Signature
Every exported function has return type `uint32_t` (the ABI v2 status code) and takes `uint64_t *result` as its first argument:

```c
uint32_t omega2_<EXPORT>(uint64_t *result /*, parameter arguments... */);
```

- `result` must be non-null, 8-byte aligned, must not wrap `UINTPTR_MAX`, and must not overlap any writable (`edit` or `out`) or readable (`view`) argument span.
- **Atomicity:** `*result` is written **only** when status is `0` (`OMEGA_OK`). For `void`-returning exports, `*result` is set to `0u` on `OMEGA_OK`. On any non-zero status (`1..14`, `32..36`), `*result` is untouched.
- Signed `long` scalars and return values travel as two's-complement bit patterns in `uint64_t`.

### 3.2 Supported Parameter Classes (6-Slot Budget)
Every export may consume at most **6** Omega argument register slots (`x0..x5` on AArch64; 6 frame slots on x86_64) and at most 6 parameters:

| Class | OM-2 Syntax | Slots | C Binding Signature | Alignment | Length & Null Validation | Overlap Class (`w`) |
|---|---|---|---|---|---|---|
| Scalar | `x ulong` / `x long` | 1 | `uint64_t o_x` | N/A | Any 64-bit value | None |
| Sized array | `a view T N` / `a edit T N` | 1 | `[const] CT *o_a, uint64_t o_a_len` | `sizeof(T)` | Non-null, `o_a_len == N` (`1 <= N <= 16777216`), `lo + N*es <= UINTPTR_MAX` | `0` (`view`) / `1` (`edit`) |
| Unsized slice | `a view T *` / `a edit T *` | **2** | `[const] CT *o_a, uint64_t o_a_len` | `sizeof(T)` (if `len > 0`) | `len == 0`: any ptr (incl. `NULL`), adds no overlap span; `len > 0`: non-null, `lo % es == 0`, `len <= UINT64_MAX/es`, `len*es <= UINTPTR_MAX - lo` | `0` (`view`) / `1` (`edit`) |
| Layout | `p view L` / `p edit L` | 1 | `[const] uint8_t *o_p` | `1` byte | Non-null, fixed `SIZE` bytes (`1 <= SIZE <= 4096`), `lo + SIZE <= UINTPTR_MAX` | `0` (`view`) / `1` (`edit`) |
| Out buffer | `o out T N` | 1 | `CT *o_o` | `sizeof(T)` | Non-null, `1 <= N <= 65536`, total out bytes per call `<= 65536`, `lo + N*es <= UINTPTR_MAX` | **`2` (`out`)** |

**Parameter naming rule:** Parameter names must be valid C identifiers and must not end with `_len`. Generated bindings prefix parameter identifiers with `o_` to avoid keyword collisions across C, C++, Rust, Zig, Python, and Go.

### 3.3 Supported Element Types `T` & Return Types
- **Element types `T`** (all 8 integer types):
  `uchar` (`uint8_t`, 1 B), `ushort` (`uint16_t`, 2 B), `uint` (`uint32_t`, 4 B), `ulong` (`uint64_t`, 8 B),
  `byte` (`int8_t`, 1 B), `short` (`int16_t`, 2 B), `int` (`int32_t`, 4 B), `long` (`int64_t`, 8 B).
- **Return types:** `ulong`, `long`, or `void`.
- Float scalar parameters (`f32`/`f64`) are **not** part of ABI v2 (they belong solely to the explicit ABI v1 `float`/`fhost` profile); private internal `f32`/`f64` arithmetic inside an OM-2 unit is permitted when hardware FP is enabled.

### 3.4 Aliasing & Overlap Matrix (`ombr2_overlap`)
Every active span `[lo, hi)` carries a writability class `w` (`0` = `view`, `1` = `edit` or `result`, `2` = `out`). Two spans overlap iff `sp[i].lo < sp[j].hi && sp[j].lo < sp[i].hi`.

| Span A \ Span B | `view` (`w=0`) | `edit` / `result` (`w=1`) | `out` (`w=2`) |
|---|---|---|---|
| **`view` (`w=0`)** | Allowed | **Refused (`32`)** | **Allowed** (copy-back happens after return) |
| **`edit` / `result` (`w=1`)** | **Refused (`32`)** | **Refused (`32`)** | **Refused (`32`)** |
| **`out` (`w=2`)** | **Allowed** | **Refused (`32`)** | **Refused (`32`)** |

### 3.5 `out` Buffer Staging & Rollback Guarantee
1. Before entering Omega machine code, `ombr2_run` carves each `out T N` buffer (`round_up_16(N * sizeof(T))` bytes) from the top of the thread's Omega stack (or from the calling function's aligned stack frame in `freest` mode) and **zero-fills** all `N * sizeof(T)` bytes.
2. The Omega unit writes solely into this private staging buffer.
3. Only if `ombr_enter` returns **`0` (`OMEGA_OK`)** does `ombr2_run` copy each staging buffer into the caller's destination pointer via `memmove` (allowing safe overlap with any `view` parameter) and store `*result`.
4. If the Omega unit traps (`1..14`) or fails validation (`32..36`), **zero bytes** are copied to any caller `out` buffer and `*result` is not modified.

---

## 4. Complete Status Code Table

| Status | Symbolic Constant | Origin | Meaning & Caller Guarantee |
|---:|---|---|---|
| `0` | `OMEGA_OK` | Normal return | Call succeeded; `out` buffers copied back and `*result` written (`0` for `void`). |
| `1` | Trap 1 (`OVERFLOW`) | Omega runtime | Checked signed/unsigned integer overflow (`add`, `sub`, `mul`, `neg`, `INT64_MIN / -1`). `*result`/`out` untouched. |
| `2` | Trap 2 (`DIV0`) | Omega runtime | Integer division or remainder by zero (`div`, `rem`). `*result`/`out` untouched. |
| `3` | Trap 3 (`BOUNDS`) | Omega runtime | Array/slice/layout/part index or sub-range out of bounds. `*result`/`out` untouched. |
| `4` | Trap 4 (`LOOP_BOUND`) | Omega runtime | Loop exceeded its static `bound N` (or default 1,000,000-iteration cap). `*result`/`out` untouched. |
| `5` | Trap 5 (`CAST`) | Omega runtime | Checked narrowing/sign integer cast out of target range. `*result`/`out` untouched. |
| `6` | Trap 6 (`OOM` / `STACK`) | Omega runtime | Memory/pool capacity exhaustion or explicit `trap 6`. `*result`/`out` untouched. |
| `7` | Trap 7 (`SHIFT`) | Omega runtime | Shift count `>=` bit-width of shifted operand (`shl`, `shr`). `*result`/`out` untouched. |
| `8` | Trap 8 (`RUNTIME`) | Omega runtime | Runtime invariant failure or explicit `trap 8`. `*result`/`out` untouched. |
| `9` | Trap 9 (`REQUIRES`) | Omega RM2 contract / `trap 9` | **RM2 precondition (`requires BOOL`) violated** on function entry (or explicit `trap 9`). `*result`/`out` untouched. |
| `10` | Trap 10 (`ENSURES` / `INVARIANT`) | Omega RM2 contract / `trap 10` | **RM2 postcondition (`ensures BOOL`) or loop invariant (`invariant BOOL`) violated** (or explicit `trap 10`). `*result`/`out` untouched. |
| `11` | Trap 11 (`ARENA_FULL`) | Omega runtime / `trap 11` | Arena capacity exhausted (or explicit `trap 11`). `*result`/`out` untouched. |
| `12` | Trap 12 (`STALE`) | Omega runtime / `trap 12` | Stale generational handle (or explicit `trap 12`). `*result`/`out` untouched. |
| `13` | Trap 13 (`POOL_FULL`) | Omega runtime / `trap 13` | Pool allocation exhausted (or explicit `trap 13`). `*result`/`out` untouched. |
| `14` | Trap 14 (`RETIRED`) | Omega runtime / `trap 14` | Retired resource/slot accessed (or explicit `trap 14`). `*result`/`out` untouched. |
| `32` | `OMEGA_BAD_ARG` | C wrapper pre-check | Null pointer, wrong sized length, misalignment, `n*es` or address-space overflow, or disallowed span overlap. Caught before Omega code executes; `*result`/`out` untouched. |
| `33` | `OMEGA_REENTRY` | C wrapper (`_Thread_local`) | Reentrant entry on a thread already inside an `omega2_*` / `omega_*` call (e.g., from a signal handler such as `SIGUSR1` on the same thread). Outer call remains undisturbed; inner call returns `33` immediately. |
| `34` | `OMEGA_BAD_RT` | `ombr_trap` / `ombr_no_entry` | Embedded code called an unpopulated runtime table slot (`entry[i]`, `i != 2`), supplied a trap code outside `1..14`, or pthread mutex/context management failed in device profile. |
| `35` | `OMEGA_NO_STACK` | `ombr_stack()` | Allocation of the thread's `8 MiB` Omega stack + `8 MiB` `PROT_NONE` guard (`mmap`/`mprotect`/`pthread_setspecific`) failed. |
| `36` | `OMEGA_CONTEXT_BUSY` | Device profile (`predev`) | `omega_native_context_destroy` refused because one or more device mappings remain active in that context. |

### 4.1 Register Preservation, BTI & Stack Architecture (AArch64)
- `ombr_enter` begins with `hint #34` (`bti c`), saves `x19..x30` and `d8..d15` on the caller's stack, anchors caller `sp` in `x19`, points `x7` at the read-only `ombr_rt_table`, switches `sp` to the thread's private `8 MiB` `mmap` stack (above an `8 MiB` `PROT_NONE` guard page region freed automatically on thread exit via `pthread_key_create`), loads `x0..x5`, and enters via `blr x16`.
- Each export trampoline (`ombr2_entry_<EXPORT>`) starts with `hint #34` (`bti c`) and branches to `ombr2_code_<UNIT> + 4*k`, making libraries compiled with `-mbranch-protection=standard` (AArch64 BTI) fully compatible.
- `ombr_trap` and `ombr_no_entry` begin with `hint #38` (`bti jc`), restore `sp` from `x19`, clamp `trap_code` via unsigned `(code - 1) <= 13 ? code : 34`, restore `x19..x30` and `d8..d15`, and return to the C wrapper without touching `*result` or any caller `out` buffer.

---

## 5. Explicit Unsupported & Caller-Contract Failure Modes

The ABI v2 boundary checks pointer nullness, alignment, integer/address overflow, span overlap, and same-thread reentry, but **cannot** enforce properties invisible to a C pointer in user space. Callers remain responsible for the following explicit failure modes:

1. **Forged buffer lengths or dangling pointers:** If a caller passes a non-null, properly aligned pointer with an `o_<name>_len` larger than the caller's actual allocation (or pointing to freed/unmapped memory), the Omega unit will dereference past the caller's object and trigger a hardware fault (`SIGSEGV`/`SIGBUS`), not `OMEGA_BAD_ARG`.
2. **Read-only memory passed as `edit` or `out` or `result`:** Passing a pointer into `.rodata` or a `PROT_READ` mapping to an `edit`, `out`, or `result` parameter passes pointer validation and will raise `SIGSEGV` when written.
3. **Stack exhaustion past the `8 MiB` stack + `8 MiB` guard:** Function-mode units prohibit call cycles and cap local arrays at `4 MiB` per function, so normal overflow hits the `8 MiB` `PROT_NONE` guard cleanly (`SIGSEGV`, without corrupting adjacent mappings). A freestanding (`freest`) caller runs directly on the caller's own stack without a guard allocation and must size its stack accordingly.
4. **Concurrent mutation / data races across threads:** Each thread gets its own `ombr_active` flag and its own `8 MiB` Omega stack, so concurrent calls on different threads are safe **if and only if** callers do not pass overlapping mutable buffers (`edit`/`out`/`result`) across concurrent threads.
5. **Async-signal-safety & signal handler constraints:** Reentering an `omega2_*` export from a signal handler on the same thread cleanly returns `33` (`OMEGA_REENTRY`) without corrupting the active call. However, invoking an export for the *first* time inside a signal handler (when `ombr_stk == NULL`) calls `mmap`/`pthread_once`, which is not async-signal-safe; pre-warm the thread or avoid calling from signal handlers except when testing reentry refusal.
6. **Hardware CET shadow stack (x86_64):** On `x86linux` bindings, the non-local stack unwind in `ombr_trap` restores `%rsp` without unwinding an Intel CET shadow stack; CET shadow-stack enforcement is explicitly unsupported.
7. **RM2 `om2 release` contract erasure:** ABI v2 units MUST start with `om2` (which always executes `requires`, `ensures`, and `invariant` checks at runtime). Compiling under `om2 release` is not accepted by `native.om`'s `prof` check.

---

## 6. FR-7: Shared Objects (`dlopen`) & Symbol Versioning

RM7 explicitly records the status and contract for dynamic shared libraries (`dlopen`/`dlsym`/`dlvsym`) across two complementary paths:

### 6.1 Path A — Pure-Omega Shared Libraries (`bridge/shlib/shlib.om`)
`bridge/shlib/shlib.om` emits a runnable AArch64 Linux ELF64 `ET_DYN` shared library directly from `seed/out/omc`'s `object` mode (`OMOBJ001`) and a declarative `.tsv` table — **with zero C compiler, assembler, or system linker**.

- **Implemented capabilities (verified on DGX Spark via `dlopen`/`dlsym` and `readelf`):**
  - Valid ELF64 `ET_DYN` with `PT_LOAD` (`RX` + `RW`), `PT_DYNAMIC`, `DT_SONAME`, `DT_NEEDED`, `DT_RUNPATH`, `.hash`, `.dynsym`, `.dynstr`, `.dynamic`, `.rela.dyn` (`R_AARCH64_GLOB_DAT`), `.got`, `.bss`, `.shstrtab`.
  - AAPCS64-to-Omega call wrappers preserving `x19..x30` and `d8..d15`, per-call stack probing every 4 KiB up to static call-graph stack depth, and deterministic trap-to-value return (configured per export row in the `.tsv` table).
  - Loadable by both the system dynamic linker (`DT_NEEDED`) and POSIX `dlopen` / `dlsym` from C/Python/Rust/Go/Zig hosts.
- **Explicit current limits of `bridge/shlib/shlib.om` (recorded honestly):**
  - Emits SysV `.hash` only (no `.gnu.hash`).
  - Does **not** yet emit GNU symbol versioning sections (`DT_VERSYM` / `DT_VERDEF` / `DT_VERNEED`, `.gnu.version`, `.gnu.version_d`), `.eh_frame`, or `.note.gnu.property` BTI/GCS notes.
  - Uses direct AAPCS64-to-Omega trap-value wrappers rather than the `omega2_*` status-code/span-validation runtime.

### 6.2 Path B — Symbol-Versioned ABI v2 Shared Objects (`OMEGA_ABI_2.0`)
When deploying an ABI v2 binding (`native c`) as a dynamically loaded Linux shared object (`libomega2_<unit>.so.2`) with strict ABI version enforcement via `dlopen` / `dlvsym`, producers MUST link with an explicit `SONAME` and GNU version script:

```ld
OMEGA_ABI_2.0 {
    global:
        omega2_*;
    local:
        *;
};
```

```sh
gcc -std=c11 -O2 -fPIC -shared -mbranch-protection=standard \
    -Wl,-soname,libomega2_<unit>.so.2 \
    -Wl,--version-script=omega2.ver \
    omega_native.c -o libomega2_<unit>.so.2 -lpthread
```

- **Contract guarantees:**
  - All internal adapter symbols (`ombr_enter`, `ombr_trap`, `ombr2_code_*`, `ombr2_entry_*`) stay hidden (`local: *;`), so `dlsym(h, "ombr_enter") == NULL`.
  - Every `omega2_*` export and `omega2_ident_<unit>` is tagged `@@OMEGA_ABI_2.0`.
  - `dlvsym(handle, "omega2_<export>", "OMEGA_ABI_2.0")` succeeds; requesting any mismatched version tag such as `dlvsym(handle, "omega2_<export>", "OMEGA_ABI_1.0")` fails closed and returns `NULL`.
  - Callers loading via `dlopen` SHOULD additionally verify `omega2_ident_<unit>()` against the pinned `OMEGA2_IDENT_<unit>` string immediately after resolution.

---

## 7. Multi-Language Binding Matrix & Qualification Gate

`bridge/abi-v2-spec/gate_abi_v2.sh` together with pure-Omega verifier `bridge/abi-v2-spec/gate_abi_v2.om` qualifies `bridge/abi-v2-spec/abi_v2_qual.om` across every supported host language on Linux AArch64 (DGX Spark):

| Language | Generated Artifact | Verification Scope |
|---|---|---|
| **C (C11)** | `omega_native.c`, `omega_native.h` | All 22 exports, all 8 element types, all parameter classes, statuses `0`, `1..14` (incl. RM2 `9` `requires`, `10` `ensures` & `invariant`), all `32` `OMEGA_BAD_ARG` classes, live `SIGUSR1` `33` `OMEGA_REENTRY`, `out` rollback on trap, `omega2_ident_*` |
| **C-BTI** | `libomega_native_bti.a` (`-mbranch-protection=standard`) | Full C suite under hardware Branch Target Identification codegen (`hint #34` / `hint #38`) |
| **C++ (C++17)** | `omega_native.h`, `omega_api.h` | `extern "C"` linkage, `static_assert` layout size & field offsets, positive + trap `9`/`10` + `32` + `out` rollback + `omega_api.h` typed inline wrappers |
| **Rust** | `omega_native.rs` (`abi_v2_sys` -> `#![forbid(unsafe_code)]` caller) | Zero-`unsafe` top-level crate over isolated `-sys` FFI, positive calls, traps `1..14`, `32`, `out` rollback, `OMEGA2_IDENT_*` match |
| **Zig** | `omega_native.zig` | Direct `@import("omega_native.zig")`, positive calls, traps `1..14`, `32`, `out` rollback, `OMEGA2_IDENT_*` match |
| **Python (`ctypes`)** | `omega_native.py` | Import-time identity enforcement, positive calls, traps `1..14`, `32`, `out` rollback, scalar range rejection (`ValueError`/`ArgumentError`), tampered-ident `ImportError` negative control |
| **Go (`cgo`)** | `omega_native.go`, `omega_native.h` | Offline cgo package `omeganative`, positive calls, traps `1..14`, `32`, `out` rollback, `Omega2_ident_*` match |
| **FR-7 (`dlopen` / `dlvsym`)** | `bridge/shlib/shlib.om` + `libomega2_qual.so.2` | Pure-Omega `ET_DYN` via `dlopen`/`dlsym` + `readelf`; GNU versioned `OMEGA_ABI_2.0` `dlvsym` PASS + `OMEGA_ABI_1.0` `NULL` refusal + hidden internal symbol check |
| **Link & Tamper Controls** | `gate_abi_v2.om` | Link-time v1/v3 symbol mismatch refusal, tampered `omc` exit `69`, tampered `results.tsv` (`FAIL` or missing mandatory row) exit `1` |
