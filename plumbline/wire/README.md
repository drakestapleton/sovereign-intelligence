# wire: ipo1, the INTERPLANE Omegese form

`ipo` turns one canonical JSON value into one line of Omegese-style text and back, without loss.
Objects whose key sequence is in a fixed table of 15 shapes are written as one word and their
values, with no key names. It is written in Omega and built by the seed-grown compiler.

- [`SPEC.md`](SPEC.md): the form, the shape table and its sha256, exit codes, limits, what is not
  covered.
- [`tests/PROVENANCE.md`](tests/PROVENANCE.md): where every test file comes from, and the licence
  of the INTERPLANE fixtures.

The request the form was designed around, 560 bytes of canonical JSON
(`tests/example.json`), is 237 bytes as a frame (`tests/example.ipo`). Over the 39 distinct
INTERPLANE envelopes of `tests/vectors.jsonl`: 24887 bytes of JSON, 12782 bytes of frames.
Bytes only: no tokenizer was run.

**A valid frame is never an authorization.** ipo1 carries a JSON value; it signs nothing, checks
no INTERPLANE schema and decides nothing.

## Files

| Path | What |
|---|---|
| `src/00-core.om` | limits, refusal classes, buffers, the value tree |
| `src/10-json.om` | strict JSON reader, RFC 8785 (JCS) writer |
| `src/20-shape.om` | the shape table and its checks, the bare-string rule |
| `src/30-frame.om` | frame writer (`enc`) and strict frame reader (`dec`) |
| `src/40-main.om` | the modes and `selftest` |
| `tests/vectors.jsonl` | 39 canonical INTERPLANE envelopes, one per line |
| `tests/extracted.jsonl` | the 49 envelopes as extracted, before `ipo canon` |
| `tests/expected.txt` | exact stdout of `ipo selftest < tests/vectors.jsonl` |
| `tests/example.json`, `tests/example.ipo` | the 560-byte request and its frame |
| `tests/edge.jsonl`, `tests/edge-expected.txt` | 56 hand-written values for what the envelopes do not exercise, and their selftest stdout |
| `tests/bad/` | 67 inputs that must be refused; 2 more are generated (below) |
| `tests/drive.om` | test driver: run a command per line, check refusals, fuzz |
| `tests/gen.om` | writes the generated refusal fixtures |
| `tests/subst.om` | replaces exactly one occurrence of a text; makes the mutants |
| `tests/census.om` | per-vector sizes and the check of the shape table's rule |

`ipo` is its five units concatenated in name order; only `00-core.om` starts with `om2`.

## Build

From the repository root, after the repository's build has left the compilers `out/omc`
(AArch64) and `out/omc-x86` (x86-64). The commands are for an x86-64 Linux host with
`qemu-aarch64-static`; on an AArch64 host run `out/omc` and the AArch64 programs directly.
`WORK` is any scratch directory. A compile that fails exits with the Omega error number and the
`&&` then leaves its output not executable: never run it.

```sh
WORK=$(mktemp -d)
QEMU=$(command -v qemu-aarch64-static)

cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om plumbline/wire/src/20-shape.om plumbline/wire/src/30-frame.om plumbline/wire/src/40-main.om | qemu-aarch64-static out/omc > "$WORK"/ipo-a64 && chmod +x "$WORK"/ipo-a64
{ printf 'target x86linux\n'; cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om plumbline/wire/src/20-shape.om plumbline/wire/src/30-frame.om plumbline/wire/src/40-main.om; } | out/omc-x86 > "$WORK"/ipo-x86 && chmod +x "$WORK"/ipo-x86
```

The test programs, for the host:

```sh
{ printf 'target x86linux\n'; cat plumbline/wire/tests/drive.om; } | out/omc-x86 > "$WORK"/drive && chmod +x "$WORK"/drive
{ printf 'target x86linux\n'; cat plumbline/wire/tests/gen.om; } | out/omc-x86 > "$WORK"/gen && chmod +x "$WORK"/gen
{ printf 'target x86linux\n'; cat plumbline/wire/tests/subst.om; } | out/omc-x86 > "$WORK"/subst && chmod +x "$WORK"/subst
{ printf 'target x86linux\n'; cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om plumbline/wire/src/20-shape.om plumbline/wire/src/30-frame.om plumbline/wire/tests/census.om; } | out/omc-x86 > "$WORK"/census && chmod +x "$WORK"/census
```

## Use

```sh
"$WORK"/ipo-x86 canon < value.json          # canonical JSON, one LF
"$WORK"/ipo-x86 enc < value.json            # one ipo1 frame
"$WORK"/ipo-x86 dec < frame.ipo             # canonical JSON, one LF
"$WORK"/ipo-x86 selftest < plumbline/wire/tests/vectors.jsonl
"$WORK"/ipo-x86 shapes                      # the embedded shape table
qemu-aarch64-static "$WORK"/ipo-a64 enc < value.json
```

Exit 0 done, 2 usage, 20 to 50 a refusal class with `ipo: NAME at byte N` on stderr and nothing
on stdout (`SPEC.md` section 5); `selftest` exits 0 or 1.

## Check

Everything below was run as written, from the repository root, on both targets. The output shown
is what was observed.

### 1. selftest, both targets, against the recorded output

```sh
"$WORK"/ipo-x86 selftest < plumbline/wire/tests/vectors.jsonl; echo "exit $?"
qemu-aarch64-static "$WORK"/ipo-a64 selftest < plumbline/wire/tests/vectors.jsonl; echo "exit $?"
```

Both printed:

```
kind=result n=8 json=6366 ipo=3500
kind=tool_request n=31 json=18521 ipo=9282
IPO1 PASS vectors=39 json_bytes=24887 ipo_bytes=12782
exit 0
```

```sh
"$WORK"/ipo-x86 selftest < plumbline/wire/tests/vectors.jsonl | cmp - plumbline/wire/tests/expected.txt; echo "exit $?"
qemu-aarch64-static "$WORK"/ipo-a64 selftest < plumbline/wire/tests/vectors.jsonl | cmp - plumbline/wire/tests/expected.txt; echo "exit $?"
```

Both `exit 0`. A PASS alone does not show that the build holds the pinned table (`SPEC.md`
section 6); the `cmp` with `tests/expected.txt` and checks 2 and 5 do.

### 2. The example

```sh
"$WORK"/ipo-x86 enc < plumbline/wire/tests/example.json | cmp - plumbline/wire/tests/example.ipo; echo "exit $?"
"$WORK"/ipo-x86 dec < plumbline/wire/tests/example.ipo | cmp - plumbline/wire/tests/example.json; echo "exit $?"
qemu-aarch64-static "$WORK"/ipo-a64 enc < plumbline/wire/tests/example.json | cmp - plumbline/wire/tests/example.ipo; echo "exit $?"
qemu-aarch64-static "$WORK"/ipo-a64 dec < plumbline/wire/tests/example.ipo | cmp - plumbline/wire/tests/example.json; echo "exit $?"
wc -c plumbline/wire/tests/example.json plumbline/wire/tests/example.ipo
```

Four times `exit 0`, then `561` and `238` (each with its LF).

### 3. Refusals: 69 files, 92 runs, both targets

67 fixtures are committed in `tests/bad/`. **Two are over 100 KB and are generated**, by
`tests/gen.om`, into `WORK`:

| Generated fixture | Command | Bytes | Must exit |
|---|---|---|---|
| `22-input-over-1mib.json` | `"$WORK"/gen bigjson` | 1048577 | 22 (`TOOBIG`) under `canon` and `enc` |
| `23-decodes-over-1mib.ipo` | `"$WORK"/gen bigipo` | 176013 | 23 (`OUTBIG`) under `dec` |

```sh
"$WORK"/gen bigjson > "$WORK"/22-input-over-1mib.json
"$WORK"/gen bigipo > "$WORK"/23-decodes-over-1mib.ipo
"$WORK"/drive bad "$WORK"/ipo-x86 -- plumbline/wire/tests/bad/* "$WORK"/22-input-over-1mib.json "$WORK"/23-decodes-over-1mib.ipo > "$WORK"/bad-x86.txt; echo "exit $?"
"$WORK"/drive bad "$QEMU" "$WORK"/ipo-a64 -- plumbline/wire/tests/bad/* "$WORK"/22-input-over-1mib.json "$WORK"/23-decodes-over-1mib.ipo > "$WORK"/bad-a64.txt; echo "exit $?"
cmp "$WORK"/bad-x86.txt "$WORK"/bad-a64.txt; echo "exit $?"
```

Three times `exit 0`. Each file has 92 lines `pass NAME MODE exit=C stdout=0 stderr=...` (an
`.ipo` file is run under `dec`, a `.json` file under `canon` and under `enc`), for example

```
pass 45-quoted-could-be-bare.ipo dec exit=45 stdout=0 stderr=ipo: NOTBARE at byte 5
pass 34-u64-task-id.json canon exit=34 stdout=0 stderr=ipo: NUMRANGE at byte 8
pass 22-input-over-1mib.json enc exit=22 stdout=0 stderr=ipo: TOOBIG at byte 1048576
pass 23-decodes-over-1mib.ipo dec exit=23 stdout=0 stderr=ipo: OUTBIG at byte 1048576
```

and ends `BADRUN PASS files=69 runs=92`. Classes 22 to 47 each have at least one file. The classes
that no file can reach:

```sh
"$WORK"/ipo-x86 canon < plumbline/wire; echo "exit $?"
"$WORK"/ipo-x86 enc < plumbline/wire/tests/example.json > /dev/full; echo "exit $?"
```

printed `ipo: IOREAD at byte 0`, `exit 20` (stdin is a directory) and `ipo: IOWRITE at byte 0`,
`exit 21`; the same with `qemu-aarch64-static "$WORK"/ipo-a64`. `BADTABLE` (49) and `NONCANON`
(48) are shown by the mutants below. `CAPACITY` (50) was not exercised: no input of at most
1 MiB reaches it.

The depth bound has its control: 64 levels are accepted, 65 are in `tests/bad/`.

```sh
"$WORK"/gen deepjson64 > "$WORK"/deep64.json
"$WORK"/ipo-x86 enc < "$WORK"/deep64.json | "$WORK"/ipo-x86 dec | cmp - "$WORK"/deep64.json; echo "exit $?"
```

`exit 0` (also with the AArch64 build).

### 4. Both targets byte-identical on every vector

```sh
"$WORK"/drive each "$WORK"/ipo-x86 enc < plumbline/wire/tests/vectors.jsonl > "$WORK"/enc-x86.ipo; echo "exit $?"
"$WORK"/drive each "$QEMU" "$WORK"/ipo-a64 enc < plumbline/wire/tests/vectors.jsonl > "$WORK"/enc-a64.ipo; echo "exit $?"
cmp "$WORK"/enc-x86.ipo "$WORK"/enc-a64.ipo; echo "exit $?"
"$WORK"/drive each "$WORK"/ipo-x86 dec < "$WORK"/enc-x86.ipo | cmp - plumbline/wire/tests/vectors.jsonl; echo "exit $?"
"$WORK"/drive each "$QEMU" "$WORK"/ipo-a64 dec < "$WORK"/enc-a64.ipo | cmp - plumbline/wire/tests/vectors.jsonl; echo "exit $?"
```

Each `drive` printed `drive: lines=39 ok=39 refused=0 kept=39`; every `exit 0`. The 39 frames
are 12821 bytes with their LFs (12782 without).

### 5. The shape table and its rule

```sh
"$WORK"/ipo-x86 shapes | sha256sum
qemu-aarch64-static "$WORK"/ipo-a64 shapes | sha256sum
"$WORK"/census < plumbline/wire/tests/vectors.jsonl | tail -n 1
```

Both sums `cf9e5f47b6659cdc75ca3799e0df2ed72d335bc8bae99db1ad476cf57af5cb43` (the pin of
`SPEC.md`), then `CENSUS PASS shapes=15 sequences=35 objects=282`. Without the `tail`, `census`
also prints one line per vector, the best and worst vector, and one line per key sequence with
its count.

### 6. Edge values

```sh
"$WORK"/ipo-x86 selftest < plumbline/wire/tests/edge.jsonl | cmp - plumbline/wire/tests/edge-expected.txt; echo "exit $?"
qemu-aarch64-static "$WORK"/ipo-a64 selftest < plumbline/wire/tests/edge.jsonl | cmp - plumbline/wire/tests/edge-expected.txt; echo "exit $?"
```

Both `exit 0`; the recorded verdict is `IPO1 PASS vectors=56 json_bytes=1033 ipo_bytes=1654`.

### 7. The vectors, again, from the extraction

```sh
"$WORK"/drive uniq "$WORK"/ipo-x86 canon < plumbline/wire/tests/extracted.jsonl | cmp - plumbline/wire/tests/vectors.jsonl; echo "exit $?"
```

stderr `ipo: NUMRANGE at byte 1650`, `drive: line 31 exit 34`,
`drive: lines=49 ok=48 refused=1 kept=39`; `exit 0` from `cmp`. 49 envelopes found, 1 refused
(an integer above 2^53), 39 distinct. The same with `"$QEMU" "$WORK"/ipo-a64`.

### 8. Mutated inputs

`drive fuzz` makes mutants of every seed line by one byte replaced, deleted or inserted, from a
fixed sequence, and requires of each: refused with exit 20 to 50 and an empty stdout, or accepted
and then consistent (`dec`: `enc` of the output is the mutant itself; `enc`: `dec` of the output
is `canon` of the mutant; `canon`: idempotent).

```sh
"$WORK"/drive each "$WORK"/ipo-x86 enc < plumbline/wire/tests/edge.jsonl > "$WORK"/edge.ipo
cat "$WORK"/enc-x86.ipo "$WORK"/edge.ipo > "$WORK"/seeds.ipo
cat plumbline/wire/tests/vectors.jsonl plumbline/wire/tests/edge.jsonl > "$WORK"/seeds.jsonl
"$WORK"/drive fuzz dec 500 "$WORK"/ipo-x86 < "$WORK"/seeds.ipo | tail -n 1
"$WORK"/drive fuzz enc 500 "$WORK"/ipo-x86 < "$WORK"/seeds.jsonl | tail -n 1
"$WORK"/drive fuzz canon 500 "$WORK"/ipo-x86 < "$WORK"/seeds.jsonl | tail -n 1
"$WORK"/drive fuzz dec 100 "$QEMU" "$WORK"/ipo-a64 < "$WORK"/seeds.ipo | tail -n 1
"$WORK"/drive fuzz enc 100 "$QEMU" "$WORK"/ipo-a64 < "$WORK"/seeds.jsonl | tail -n 1
"$WORK"/drive fuzz canon 100 "$QEMU" "$WORK"/ipo-a64 < "$WORK"/seeds.jsonl | tail -n 1
```

```
FUZZ PASS mode=dec seeds=95 runs=47500 accepted=8289 refused=39211
FUZZ PASS mode=enc seeds=95 runs=47500 accepted=13867 refused=33633
FUZZ PASS mode=canon seeds=95 runs=47500 accepted=13867 refused=33633
FUZZ PASS mode=dec seeds=95 runs=9500 accepted=1658 refused=7842
FUZZ PASS mode=enc seeds=95 runs=9500 accepted=2740 refused=6760
FUZZ PASS mode=canon seeds=95 runs=9500 accepted=2740 refused=6760
```

No run exited with a trap, a signal or `NONCANON`. The AArch64 runs use 100 mutants per seed
because emulation is slow; they are the first 100 of the same sequence.

## Negative controls

Each mutant is the real source with one edit made by `tests/subst.om`, which refuses an edit
that does not apply exactly once:

```sh
"$WORK"/subst 'fail ENOTBARE' 'x' < plumbline/wire/src/30-frame.om > /dev/null; echo "exit $?"
"$WORK"/subst 'no such text' 'x' < plumbline/wire/src/30-frame.om > /dev/null; echo "exit $?"
```

`subst: FROM occurs more than once`, `exit 4`; `subst: FROM does not occur`, `exit 3`.

### a. A bad file that is not refused as named

Check 3 is the positive run. The driver itself fails when it should: mutants c and c2 below
make it print `FAIL` lines and `BADRUN FAIL`, exit 1.

### b. Two keys of one shape swapped in the table

```sh
"$WORK"/subst '"peer\tid\tkind\n"' '"peer\tkind\tid\n"' < plumbline/wire/src/20-shape.om > "$WORK"/mutb-20-shape.om; echo "exit $?"
cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om "$WORK"/mutb-20-shape.om plumbline/wire/src/30-frame.om plumbline/wire/src/40-main.om | qemu-aarch64-static out/omc > "$WORK"/mutb-a64 && chmod +x "$WORK"/mutb-a64
{ printf 'target x86linux\n'; cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om "$WORK"/mutb-20-shape.om plumbline/wire/src/30-frame.om plumbline/wire/src/40-main.om; } | out/omc-x86 > "$WORK"/mutb-x86 && chmod +x "$WORK"/mutb-x86
"$WORK"/mutb-x86 selftest < plumbline/wire/tests/vectors.jsonl; echo "exit $?"
qemu-aarch64-static "$WORK"/mutb-a64 selftest < plumbline/wire/tests/vectors.jsonl; echo "exit $?"
```

Both targets: stdout `IPO1 FAIL line=0 reason=BADTABLE`, stderr `ipo: BADTABLE at byte 118`,
`exit 1`. The swap is caught by the table's own check (keys must ascend), before any vector.

A stronger mutant, b2, removes that check as well:

```sh
"$WORK"/subst 'if ne skcmp sub k 1 k 0' 'if false' < "$WORK"/mutb-20-shape.om > "$WORK"/mutb2-20-shape.om; echo "exit $?"
{ printf 'target x86linux\n'; cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om "$WORK"/mutb2-20-shape.om plumbline/wire/src/30-frame.om plumbline/wire/src/40-main.om; } | out/omc-x86 > "$WORK"/mutb2-x86 && chmod +x "$WORK"/mutb2-x86
"$WORK"/mutb2-x86 selftest < plumbline/wire/tests/vectors.jsonl; echo "exit $?"
"$WORK"/mutb2-x86 selftest < plumbline/wire/tests/vectors.jsonl | cmp - plumbline/wire/tests/expected.txt; echo "exit $?"
"$WORK"/mutb2-x86 enc < plumbline/wire/tests/example.json | cmp - plumbline/wire/tests/example.ipo; echo "exit $?"
"$WORK"/mutb2-x86 shapes | sha256sum
```

**This one passes selftest**: `IPO1 PASS vectors=39 json_bytes=24887 ipo_bytes=13640`, `exit 0`,
because the broken shape never matches and the program stays consistent with itself. It is
caught by the comparisons: `cmp` with `tests/expected.txt` exit 1 (`differ: char 32, line 1`),
`cmp` with `tests/example.ipo` exit 1, and the table's sha256 is `7bc513dc...` instead of the pin.
Run on x86-64 only.

### c. The "must be bare" check of `dec` removed

```sh
"$WORK"/subst 'fail ENOTBARE p' 'p = add p 0' < plumbline/wire/src/30-frame.om > "$WORK"/mutc-30-frame.om; echo "exit $?"
cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om plumbline/wire/src/20-shape.om "$WORK"/mutc-30-frame.om plumbline/wire/src/40-main.om | qemu-aarch64-static out/omc > "$WORK"/mutc-a64 && chmod +x "$WORK"/mutc-a64
{ printf 'target x86linux\n'; cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om plumbline/wire/src/20-shape.om "$WORK"/mutc-30-frame.om plumbline/wire/src/40-main.om; } | out/omc-x86 > "$WORK"/mutc-x86 && chmod +x "$WORK"/mutc-x86
"$WORK"/drive bad "$WORK"/mutc-x86 -- plumbline/wire/tests/bad/* "$WORK"/22-input-over-1mib.json "$WORK"/23-decodes-over-1mib.ipo | grep -v '^pass'
"$WORK"/drive bad "$QEMU" "$WORK"/mutc-a64 -- plumbline/wire/tests/bad/* "$WORK"/22-input-over-1mib.json "$WORK"/23-decodes-over-1mib.ipo | grep -v '^pass'
```

Both targets:

```
FAIL 45-example-quoted-model.ipo dec exit=48 want=45 stdout=0 stderr=ipo: NONCANON at byte 118
FAIL 45-quoted-could-be-bare.ipo dec exit=48 want=45 stdout=0 stderr=ipo: NONCANON at byte 5
BADRUN FAIL files=69 runs=92 failed=2
```

The mutant is caught by two bad files. It still refuses them, with the wrong class: the
re-encode comparison of `dec` (`NONCANON`) stops what the removed check let through. Its
selftest still matches `tests/expected.txt`: selftest feeds `dec` only canonical frames, so only
the bad files see this mutant.

Mutant c2 removes that comparison too:

```sh
"$WORK"/subst 'fail ENONCAN i' 'i = add i 0' < "$WORK"/mutc-30-frame.om > "$WORK"/mutc2-30-frame.om; echo "exit $?"
cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om plumbline/wire/src/20-shape.om "$WORK"/mutc2-30-frame.om plumbline/wire/src/40-main.om | qemu-aarch64-static out/omc > "$WORK"/mutc2-a64 && chmod +x "$WORK"/mutc2-a64
{ printf 'target x86linux\n'; cat plumbline/wire/src/00-core.om plumbline/wire/src/10-json.om plumbline/wire/src/20-shape.om "$WORK"/mutc2-30-frame.om plumbline/wire/src/40-main.om; } | out/omc-x86 > "$WORK"/mutc2-x86 && chmod +x "$WORK"/mutc2-x86
"$WORK"/drive bad "$WORK"/mutc2-x86 -- plumbline/wire/tests/bad/* "$WORK"/22-input-over-1mib.json "$WORK"/23-decodes-over-1mib.ipo | grep -v '^pass'
"$WORK"/drive bad "$QEMU" "$WORK"/mutc2-a64 -- plumbline/wire/tests/bad/* "$WORK"/22-input-over-1mib.json "$WORK"/23-decodes-over-1mib.ipo | grep -v '^pass'
"$WORK"/drive fuzz dec 500 "$WORK"/mutc2-x86 < "$WORK"/seeds.ipo | tail -n 1
```

Both targets:

```
FAIL 45-example-quoted-model.ipo dec exit=0 want=45 stdout=561 stderr=
FAIL 45-quoted-could-be-bare.ipo dec exit=0 want=45 stdout=6 stderr=
BADRUN FAIL files=69 runs=92 failed=2
```

and the fuzz run (x86-64) ends
`FUZZ FAIL mode=dec seeds=95 runs=47500 accepted=9077 refused=38423 failed=788`: 788 mutated
frames were accepted that are not the encoding of their value.

### d. Both targets identical

Checks 1 (selftest stdout), 3 (the 92 refusal lines) and 4 (every frame) are the comparisons.

## Numbers

| | JSON bytes | ipo1 bytes |
|---|---|---|
| all 39 vectors | 24887 | 12782 |
| `kind=tool_request`, 31 vectors | 18521 | 9282 |
| `kind=result`, 8 vectors | 6366 | 3500 |
| best single vector (3, `tests/example.json`) | 560 | 237 |
| worst single vector (2, the unknown-fields fixture) | 703 | 625 |
| 56 edge values, no envelope among them | 1033 | 1654 |

No LF is counted on either side. Best and worst are by ipo/json, from `census`
(`best vector=3 json=560 ipo=237`, `worst vector=2 json=703 ipo=625`).

## Known limits and defects

- Integers only, magnitude at most 2^53; a fraction or exponent is refused even when the value is
  whole (`1.0`). One of the 49 extracted envelopes is refused for an integer above 2^53.
- Object keys must be ASCII; a non-ASCII key is refused, not sorted.
- Inputs and outputs at most 1 MiB, nesting at most 64.
- `true`, `false` and `null` written bare are strings, not the JSON literals (`SPEC.md`
  section 8, note 2). The design allows it; a writer can slip.
- Values that match no shape are longer than their JSON (edge row above).
- `selftest` does not pin the shape table by itself (mutant b2).
- The sha256 of the table and the byte comparisons use `sha256sum` and `cmp`; no Omega program
  here computes a SHA-256.
- Tokens were not measured, only bytes.
- `CAPACITY` (50) has no test. `NONCANON` (48) is reached only in a mutant.
- `drive fuzz` changes one byte per mutant; it does not build structurally new frames.

## What was run where

2026-11-09, x86-64 Linux host. `out/omc` sha256 `45442c7d517fd605507bda5d1ec52493ff182661301cda69a95fc4f77dc6080d`,
`out/omc-x86` sha256 `5e1f6e1f511850f3a5c31000ebc1845ad3b317b7f48d4726c7b0d7d781093f19`. The
AArch64 programs ran under `qemu-aarch64-static` 8.2.2 (user emulation). **Nothing was run on
AArch64 hardware.** The four test programs also compile with `out/omc` for AArch64. Run under
emulation, those builds gave the same bytes as the x86-64 builds in one run each of
`drive each`, `drive bad`, `drive fuzz dec 20`, `census`, `gen bigipo` and `subst`; the checks
above use the x86-64 builds of the test programs.
