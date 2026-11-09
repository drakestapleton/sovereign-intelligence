# Where the test data of ipo1 comes from

Every file of `tests/` that is not an Omega program is listed here with how it was made. Commands
are written from the root of this repository unless a line says otherwise; `WORK` is a scratch
directory and `"$WORK"/ipo-x86`, `"$WORK"/drive` and `"$WORK"/gen` are built as `README.md` says.

## Source

| | |
|---|---|
| Project | INTERPLANE, Radicle `rad:zNhNbqYvgSBEHBq9vvE8xpbcBzGa` |
| Commit | `708b4daed1900ed9da7907fd30a583f468eb9c1b` (clean checkout) |
| Paths read | `conformance/**` and `provenance/fixtures/**/*.json` |
| Licence | Apache-2.0 |

The licence, quoted from that commit:

- `README.md`, section "License": "Apache-2.0 for the protocol, schemas, fixtures and the Rust
  reference SDK (`LICENSE`)."
- `docs/adr/0002-licensing.md`: "Protocol, schemas, specifications, fixtures, the Rust crates, the
  Python package, examples and the probe: **Apache-2.0**."
- `LICENSE` begins "Apache License / Version 2.0, January 2004 /
  http://www.apache.org/licenses/".

The extracted envelopes below are copies of parts of those fixtures and stay under Apache-2.0.
(The same README puts `adapters/aien` and the catalog records of `adapters/odysseus` under
AGPL-3.0-or-later; nothing was read from `adapters/`.)

## `extracted.jsonl`: the one use of jq

jq 1.7 was used once, as fixture preparation, to pull every envelope (every JSON object that has
the key `interplane_version`, at any depth) out of the fixture files. From the root of an
INTERPLANE checkout at the commit above:

```sh
find conformance provenance/fixtures -type f -name '*.json' | LC_ALL=C sort | xargs jq -c '.. | objects | select(has("interplane_version"))' > extracted.jsonl
```

`conformance/` holds only `.json` files besides `README.md` and `TRUST-DIGEST.txt`, so the name
filter leaves out no fixture there. Observed: jq exit 0; 210 files read, 28 of them hold at least
one envelope; **49 envelopes**, one per line, 32601 bytes, sha256
`1011b69147374820a99298175ff7e33c7bb8468c3c73cfb2fa4613dbf9c2c237`. jq keeps each object's own key
order and number spelling; nothing here relies on jq for canonical form.

## `vectors.jsonl`: canonical and distinct, by `ipo canon`

```sh
"$WORK"/drive uniq "$WORK"/ipo-x86 canon < plumbline/wire/tests/extracted.jsonl > plumbline/wire/tests/vectors.jsonl
```

Observed on stderr (exit 1, because one line is refused):

```
ipo: NUMRANGE at byte 1650
drive: line 31 exit 34
drive: lines=49 ok=48 refused=1 kept=39
```

| | |
|---|---|
| envelopes found | 49 |
| refused by `ipo canon` | 1 |
| canonical | 48 |
| distinct (`vectors.jsonl`) | 39 lines, 24926 bytes, sha256 `73c60e515434377686ef9ea9b4cc452f70264996390d801bab95297bff8efdc9` |

**The refused envelope** is line 31 of `extracted.jsonl`: the `result` envelope with
`message_id` `m-3` and `trace_id` `real-run-04` from
`provenance/fixtures/real-waldo-aien-chain/records/interplane/trace.json`. Its payload carries
`"task":15330623940039986179`, an integer above 2^53 = 9007199254740992, which ipo1 v1 refuses
(`NUMRANGE`, exit 34) instead of rounding. No envelope has a number with a fraction or an
exponent: `NUMFLOAT` is hit by 0 envelopes, `NUMRANGE` by 1.

The same command with `"$(command -v qemu-aarch64-static)" "$WORK"/ipo-a64` in place of
`"$WORK"/ipo-x86` writes the same 24926 bytes (`cmp` exit 0).

Check that is not part of the build: for the 48 accepted lines, `jq -cS .` (sorted keys, compact)
gave byte-identical output to `ipo canon`. The vectors are ASCII only and hold no escape, so this
agreement says nothing about strings outside ASCII; `edge.jsonl` covers those.

## `example.json`, `example.ipo`

From the root of the INTERPLANE checkout, then of this repository:

```sh
jq -c '.steps[0].envelope' conformance/fixtures/17-replay.json | "$WORK"/ipo-x86 canon > plumbline/wire/tests/example.json
"$WORK"/ipo-x86 enc < plumbline/wire/tests/example.json > plumbline/wire/tests/example.ipo
```

`example.json` is 561 bytes (560 and LF) and is also line 3 of `vectors.jsonl`. `example.ipo` is
238 bytes (237 and LF).

## `expected.txt`, `edge-expected.txt`

The stdout of `"$WORK"/ipo-x86 selftest` on `vectors.jsonl` and on `edge.jsonl`. The AArch64
build printed the same bytes.

## `edge.jsonl`

56 values written by hand for this work (not from INTERPLANE), then made canonical and distinct
with `drive uniq ... canon`. They cover what the vectors do not: the three literals; integers at
plus and minus 2^53; the empty string; strings equal to each fixed word and to shape words;
strings at 64 and 65 bytes; strings that must be quoted (capital letter, leading digit or minus,
space, solidus); every JCS escape, `\u0000`, U+007F as a literal byte, 2-, 3- and 4-byte UTF-8,
a surrogate pair escape; empty and nested arrays and objects; the empty key; keys that must be
quoted; keys whose order depends on byte values; objects that are a shape, a subset of one, a
superset of one, and shapes inside shapes; and 64 nested arrays.

## `bad/`: inputs that must be refused

A file is named `CODE-what.EXT`: `.ipo` files go to `ipo dec`, `.json` files to `ipo canon` and to
`ipo enc`, and each run must exit with CODE and write nothing to stdout. 67 files are committed.
Two more are over 100 KB and are made in `WORK` at check time, never committed:

```sh
"$WORK"/gen bigjson > "$WORK"/22-input-over-1mib.json     # 1048577 bytes
"$WORK"/gen bigipo > "$WORK"/23-decodes-over-1mib.ipo     # 176013 bytes
```

That is 69 files and 92 runs. `24-nested-65-deep.json` and `24-nested-65-deep.ipo` were written
once by `gen deepjson` and `gen deepipo`. All others were typed; their bytes, with `\n` LF, `\t`
TAB, `\r` CR and `\xNN` one byte:

| File | Bytes |
|---|---|
| `25-empty-input.json` | (none) |
| `25-trailing-comma.json` | `{"a":1,}\n` |
| `26-two-values.json` | `{"a":1} {"b":2}\n` |
| `27-raw-tab-in-string.json` | `"a\tb"\n` (a real TAB) |
| `27-unknown-escape.json` | `"a` backslash `xb"\n` |
| `27-unterminated-string.json` | `"abc\n` |
| `28-byte-ff-in-string.json` | `"a\xffb"\n` |
| `28-byte-ff-in-string.ipo` | `ipo1 "a\xffb"\n` |
| `28-overlong-utf8.json` | `"\xc0\x80"\n` |
| `28-utf8-encoded-surrogate.json` | `"\xed\xa0\x80"\n` |
| `29-lone-high-surrogate.json` | `"` backslash `ud800"\n` |
| `29-lone-low-surrogate.json` | `"` backslash `udc00"\n` |
| `30-duplicate-key.json` | `{"a":1,"a":2}\n` |
| `30-duplicate-key-by-escape.json` | `{"a":1,"` backslash `u0061":2}\n` |
| `31-non-ascii-key.json` | `{"\xc3\xa9":1}\n` |
| `31-non-ascii-key.ipo` | `ipo1 obj "\xc3\xa9" 1 end\n` |
| `32-leading-zero.json`, `.ipo` | `01\n`; `ipo1 01\n` |
| `32-lone-minus.json` | `-\n` |
| `33-exponent.json` | `1e3\n` |
| `33-fraction.json`, `.ipo` | `{"n":1.5}\n`; `ipo1 1.5\n` |
| `34-above-2-53.json`, `.ipo` | `9007199254740993\n`; `ipo1 9007199254740993\n` |
| `34-u64-task-id.json` | `{"task":15330623940039986179}\n` (the number of the refused envelope) |
| `35-minus-zero.json`, `.ipo` | `-0\n`; `ipo1 -0\n` |
| `36-empty-input.ipo` | (none) |
| `36-no-final-lf.ipo` | `ipo1 nil` |
| `37-crlf.ipo` | `ipo1 nil\r\n` |
| `37-tab-as-separator.ipo` | `ipo1 arr\t1 end\n` |
| `37-two-frames.ipo` | `ipo1 nil\nipo1 nil\n` |
| `38-json-not-a-frame.ipo` | `{"a":1}\n` |
| `38-no-magic.ipo` | `nil\n` |
| `38-wrong-magic.ipo` | `ipo2 nil\n` |
| `39-double-space.ipo` | `ipo1 arr  1 end\n` |
| `39-leading-space.ipo` | ` ipo1 nil\n` |
| `39-no-space-after-string.ipo` | `ipo1 arr "a b"x end\n` |
| `39-trailing-space.ipo` | `ipo1 nil \n` |
| `40-json-braces.ipo` | `ipo1 {}\n` |
| `40-magic-as-value.ipo` | `ipo1 arr ipo1 end\n` |
| `40-unknown-word.ipo` | `ipo1 Peer mock runtime\n` |
| `41-key-without-value.ipo` | `ipo1 obj a end\n` |
| `41-shape-cut-by-end.ipo` | `ipo1 arr peer mock end\n` |
| `41-shape-too-few-values.ipo` | `ipo1 peer mock\n` |
| `41-unclosed-arr.ipo` | `ipo1 arr 1 2\n` |
| `42-token-after-shape.ipo` | `ipo1 peer mock runtime extra\n` |
| `42-two-values.ipo` | `ipo1 1 2\n` |
| `43-fixed-word-as-key.ipo` | `ipo1 obj nil 1 end\n` |
| `43-number-as-key.ipo` | `ipo1 obj 12 a end\n` |
| `43-shape-word-as-key.ipo` | `ipo1 obj tool 1 end\n` |
| `44-solidus-escape.ipo` | `ipo1 "a` backslash `/b"\n` |
| `44-u-escape-of-lf.ipo` | `ipo1 "` backslash `u000a"\n` |
| `44-u-escape-of-printable.ipo` | `ipo1 "` backslash `u0041"\n` |
| `44-unterminated-string.ipo` | `ipo1 "abc\n` |
| `44-uppercase-hex.ipo` | `ipo1 "` backslash `u001F"\n` |
| `45-quoted-could-be-bare.ipo` | `ipo1 "abc"\n` |
| `45-quoted-key-could-be-bare.ipo` | `ipo1 obj "a" 1 end\n` |
| `46-obj-with-shape-keys.ipo` | `ipo1 obj id mock kind runtime end\n` |
| `47-key-twice.ipo` | `ipo1 obj a 1 a 2 end\n` |
| `47-keys-out-of-order.ipo` | `ipo1 obj b 1 a 2 end\n` |

Four files are `example.ipo` with one change each:

| File | Change |
|---|---|
| `41-example-last-value-missing.ipo` | the last token ` trace-17` removed |
| `42-example-extra-token.ipo` | ` trace-18` added after the last token |
| `45-example-quoted-model.ipo` | the first `mock-model` written `"mock-model"` |
| `46-example-peer-as-obj.ipo` | the first `peer mock runtime` written `obj id mock kind runtime end` |

Refusal classes with no file, and why: `IOREAD` (20) and `IOWRITE` (21) need a broken stdin or
stdout, shown in `README.md`; `BADTABLE` (49) needs another program, the table mutant of
`README.md`; `NONCANON` (48) is reached only by the second mutant there; `CAPACITY` (50) is not
reachable by an input of at most 1 MiB.
