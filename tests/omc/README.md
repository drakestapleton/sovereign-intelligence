# tests/omc: compiler words beyond the imported harness

`harness/` is the Omega harness imported verbatim (`harness/PROVENANCE.md`), so a word this repository
adds to `seed/omc/omc.om` cannot be documented or tested there. Its guide notes are here, written as the
rows the harness guide (`harness/skills/writing-omega/SKILL.md`) gains when it takes the word. Its examples
are in `examples/`, in the harness format (`NAME.om`, `NAME.expect`, optional `NAME.stdout`), and
`build.sh` runs them on both targets:

```sh
EXAMPLES_ROOT=tests/omc sh tests/examples.sh out/omc out/omc-x86 [qemu-aarch64-static]
```

Every rule below was observed with the compilers `build.sh` grows from `seed/` (pins in
`seed/PINS.tsv`), on AArch64 and on x86-64 through `target x86linux`, with the same results on both.

## count (OM-2)

`count A off n v` is a `ulong`: how many of the `n` elements of `A` from `off` equal `v`.

| | |
|---|---|
| unit | OM-2 only (the first line that is not blank or `note` is `om2`); in an OM-1 unit `count` is an ordinary name |
| A | the name of a `uchar` array: a local, a global, a text, or a `view` / `edit` parameter, sized or unsized (`*`) |
| off, n | `ulong`; a bare number takes `ulong` |
| v | `uchar`; a bare number takes `uchar` (0..255) |
| result | `ulong`, 0..n |
| traps | 3 when the slice is outside `A`: unless `n <= len A` and `off <= len A - n`. Nothing else |
| order | the four values are read left to right; then the slice is checked; then the elements are read |

The slice check is the one `read` and `write` make (`vs_chk` in `seed/omc/omc.om`): `off + n` is never
formed, so it cannot wrap (`count_trap3_wrap.om`). An in-bounds slice never traps, including `n = 0` at
`off = len A` (`count_word.om`). The word replaces the loop

```
c = ulong 0
for i ulong n bound N
if eq get A add off i v
c = add c 1
end
end
```

with one machine loop, 16 bytes per pass (AArch64: `LD1`, `CMEQ`, `SUB` in NEON lanes; x86-64: `MOVDQU`,
`PCMPEQB`, `PSUBB` in SSE2, which every x86-64 CPU has), summed every 255 passes, and the last 0..15 bytes
one at a time. The loop above costs about 37 x86-64 instructions per byte under omc-x86, because every
name lives in a stack slot; `count` measured at over 20 GB/s on a cached 1 MiB buffer.

### Rows for the harness guide

Section 4, Words:

| Kind | Words |
|---|---|
| arrays (OM-2) | `count A off n v` |

Section 5, Traps: the row "array index or I/O slice out of bounds", trap 3, gains `count`'s slice
(`count_trap3.om`, `count_trap3_wrap.om`).

Section 9, OM-2 units, gains: "`count A off n v`, the number of `uchar` elements of `A[off, off+n)` equal to
`v`, the slice checked as `read` checks it (trap 3)".

Section 11, Compiler errors: `count` adds no error number. Each refusal is an existing code with its
existing meaning; code 26 is still never emitted.

| Code | Refusal of count | Example |
|---|---|---|
| 3 | `count` in an OM-1 unit (an unknown name or function) | `count_err03_om1` |
| 4 | fewer than four values (reported on the next line, as every error 4) | `count_err04_short` |
| 7 | `A` not a `uchar` array: another element type, a scalar, a struct or layout, a `const` | `count_err07_element`, `count_err07_scalar`, `count_err07_struct` |
| 7 | `off` or `n` not `ulong`, `v` not `uchar` | `count_err07_offset`, `count_err07_value` |
| 8 | a bare number `v` outside 0..255 | `count_err08_value` |
| 9 | `part` as `A` (`part` is only a call argument) | `count_err09_part` |
| 16 | `count` as a name in an OM-2 unit, or as a statement | `count_err16_name`, `count_err16_statement` |
| 27 | `A` a tracked `fresh` array (it leaves the analysis, as with `read` and `write`) | `count_err27_fresh` |
| 30 | `count` in a `requires`, `ensures` or `invariant` clause | `count_err30_contract` |

Section 12, Common mistakes:

| Mistake | Write instead | Refusal | Example |
|---|---|---|---|
| `count a 0 n 10` on its own line | `k = count a 0 n 10` | error 16 | `count_err16_statement` |
| `count a 0 n 10` with `a` a `uint` array | a `uchar` array, or a loop | error 7 | `count_err07_element` |
| `count a o n c` with `c` an `int` | `uchar c` | error 7 | `count_err07_value` |
| a loop that checks `add off n` against `len a` itself | `count`, which checks `off <= len a - n` | wraps for huge `off` | `count_trap3_wrap` |

Section 14, Example index: OM-2 and contracts gain `count_word`; traps gain `count_trap3`,
`count_trap3_wrap`; refusals gain `count_err*`.

### What build.sh checks

- step 10: the 16 examples here pass on both targets;
- step 11 (negative control): `seed/omc/omc.om` with the one line `vs_chk e ro rn` of `fn cnt_word`
  deleted builds a compiler whose `count` reads without checking. That compiler must fail
  `count_trap3` and `count_trap3_wrap` (no exit 103) on every target that runs, while `count_word` still
  passes, so the failure is the missing check and nothing else.
