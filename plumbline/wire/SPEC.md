# ipo1: the INTERPLANE Omegese form, version 1

`ipo1` is a lossless text re-encoding of one canonical JSON value. Objects whose key sequence is
in a fixed table (a *shape*) are written positionally: one word, then the values, with no key
names and no brackets. It is written for readers and writers that pay per token of text
(language models), so it is a text form, not a binary one.

The program `ipo` (Omega source in `src/`) is the reference: where this text and the program
disagree, that is a defect to report, and `tests/` decides which one is wrong.

Source of the vectors: INTERPLANE commit `708b4daed1900ed9da7907fd30a583f468eb9c1b`
(`tests/PROVENANCE.md`).

## 1. What ipo1 is not

- **No authority.** A valid frame means "this text is the canonical encoding of a JSON value".
  It is never an authorization, a policy decision or proof of who sent it. INTERPLANE's own rule
  stands unchanged: a valid envelope is structurally understandable, never authorized.
- **No signatures and no digests.** INTERPLANE digests are SHA-256 over canonical JSON. To check
  one, decode the frame (`ipo dec`) and hash the JSON bytes (without the final LF). Nothing in
  ipo1 is signed and `ipo` computes no digest.
- **No floats in v1.** Only integers of magnitude at most 2^53 are carried (section 2).
- **Text only.** No binary form, no compression, no streaming: one frame is one value of at most
  1 MiB, and both sides hold the same shape table.
- **Not INTERPLANE validation.** `ipo` checks JSON and frame syntax, not the INTERPLANE schema.

## 2. Canonical JSON (`ipo canon`)

Input is one RFC 8259 JSON value in UTF-8, with JSON whitespace allowed around tokens. Output is
its RFC 8785 (JCS) serialization, then one LF. Within the limits below the output is exactly what
JCS defines; outside them the input is refused, never approximated.

| Item | Rule | Refusal |
|---|---|---|
| `null` `true` `false` | written as is | |
| number | accepted only as `-?(0\|[1-9][0-9]*)`, not `-0`, magnitude at most 9007199254740992 (2^53); written verbatim. Up to 2^53 every integer is exact in binary64 and JCS writes it with these digits | malformed `BADNUM`; a fraction or exponent `NUMFLOAT` (also `1.0` and `1e2`); above 2^53 `NUMRANGE`; `-0` `NEGZERO` |
| string | every JSON escape is decoded, `\uXXXX` and surrogate pairs included, to UTF-8; written with JCS escaping: `\"` `\\` `\b` `\f` `\n` `\r` `\t`, other bytes below 0x20 as `\u00xx` in lowercase hex, everything else literal (U+007F and all non-ASCII included) | bad escape, raw control byte or no closing quote `JSTR`; invalid UTF-8 (overlong, surrogate, above U+10FFFF, truncated) `BADUTF8`; a lone surrogate escape `SURROG` |
| object | keys sorted by UTF-16 code unit. **Limit:** every key must be ASCII, where that order is byte order; a non-ASCII key is refused rather than sorted wrongly. No key twice (compared after unescaping) | `KEYNASC`, `DUPKEY` |
| nesting | arrays and objects nest at most 64 deep | `DEPTH` |
| size | input at most 1048576 bytes; output at most 1048576 bytes, its LF included | `TOOBIG`, `OUTBIG` |
| other | anything that is not one JSON value | `JSYNTAX`; bytes after the value `JTRAIL` |

## 3. The frame

A frame is one line:

```
frame  = "ipo1" SP value LF
value  = "nil" / "yes" / "no" / number / string / array / object / shaped
number = the canonical integer of section 2, verbatim
string = bare / quoted
bare   = ( a-z / "_" ) 0*63( a-z / 0-9 / "_" / "." / "-" )     ; and not a reserved word
quoted = the JCS string literal of section 2, verbatim           ; starts and ends with "
array  = "arr" *( SP value ) SP "end"
object = "obj" *( SP key SP value ) SP "end"
key    = string
shaped = WORD n( SP value )           ; WORD a shape word, n the number of keys of its shape
```

- `nil`, `yes`, `no` are JSON `null`, `true`, `false`.
- **Reserved words:** `ipo1 nil yes no obj arr end`, the three JSON literals `true false null`,
  and the 15 shape words of section 4. A string equal to one of them, as a value or as a key, is
  written quoted.
- **`true`, `false` and `null` are no token of the form.** As a bare token, in any position, each
  is refused (`JSONWORD`): a writer with JSON habits must get a refusal, not a different value.
  The quoted strings `"true"`, `"false"` and `"null"` are ordinary strings and are accepted.
- Tokens are separated by exactly one space (0x20). A frame has no leading space, no trailing
  space and no double space. Spaces inside a quoted string are part of the string.
- No byte 0x00 to 0x1F occurs in a frame except its final LF. JCS already escapes those bytes
  inside strings. The byte 0x7F occurs only inside a quoted string, where JCS writes U+007F
  literally (see section 8, note 1).
- `shaped` stands for the object whose keys, in JCS order, are exactly the keys of the shape, and
  whose values are the n values in that order. It has no `end`.
- `obj` keys are ASCII, in JCS order, each once.

### One frame per value

The encoder has no choices, and the decoder refuses every frame the encoder would not write:

| Rule | Refusal by `ipo dec` |
|---|---|
| a string that matches `bare` and is not reserved is written bare, as a value and as a key | `NOTBARE` |
| an object whose key sequence is a shape's is written with the shape word | `NOTSHAPE` |
| `obj` keys ascend strictly in byte order | `KEYORDER` |
| the bare tokens `true`, `false` and `null` do not occur, as a value or as a key | `JSONWORD` |
| an `obj` key is a string (not a number, not another reserved word) | `FRKEY` |
| quoted strings use exactly the JCS spelling (`\/`, `A`, `\u001F` are refused) | `FRSTR` |
| numbers are canonical integers | `BADNUM` `NUMFLOAT` `NUMRANGE` `NEGZERO` |
| every shape has all of its values and every `arr` and `obj` is closed | `FRARITY` |
| nothing follows the value | `FRTRAIL` |
| single spaces, no control bytes, `ipo1` first, LF last | `FRSPACE` `FRCTL` `FRMAGIC` `FRNOLF` |
| a token is a value | `FRWORD` |

After these checks `ipo dec` writes the decoded value as a frame again and compares it with its
input, byte for byte (`NONCANON`). No input is known that reaches that refusal in the unmodified
program; it is the backstop that makes "dec accepted F" imply "enc of the result is F".

So for canonical JSON `J` and any frame `F`: `dec(enc(J)) = J`, and if `dec(F)` is accepted then
`enc(dec(F)) = F`.

### Example

The 445-byte canonical JSON of vector 33 of `tests/vectors.jsonl`:

```
{"destination":{"id":"aien","kind":"runtime"},"interplane_version":"0.1","message_id":"m-5","parent_id":null,"payload":{"arguments":{"content":"hello world","path":"notes/today.md"},"kind":"tool_request","provenance":{"dialect":"openai","parser_version":"1"},"request_id":"call-prov-03","tool":{"name":"write_file","namespace":null}},"source":{"id":"synthetic-notes","kind":"model"},"timestamp":"2026-10-06T00:00:05Z","trace_id":"trace-prov-01"}
```

is the 209-byte frame (LF not counted):

```
ipo1 env peer aien runtime "0.1" m-5 nil treq wfile "hello world" "notes/today.md" tool_request prov3 openai "1" call-prov-03 tool write_file nil peer synthetic-notes model "2026-10-06T00:00:05Z" trace-prov-01
```

`tests/example.json` (560 bytes and LF) and `tests/example.ipo` (237 bytes and LF) are the
request the form was designed around: `.steps[0].envelope` of INTERPLANE's
`conformance/fixtures/17-replay.json`.

## 4. The shape table

The table is data embedded in the program (`src/20-shape.om`, one `text` per line) and printed by
`ipo shapes`: one line per shape, `word TAB key TAB key ... LF`, sorted by word.

- Bytes: 806. **sha256:** `cf9e5f47b6659cdc75ca3799e0df2ed72d335bc8bae99db1ad476cf57af5cb43`
- A shape word is 1 to 8 bytes, `a-z` then `a-z0-9`, unique, and not one of
  `ipo1 nil yes no obj arr end true false null`. A shape has at least 2 keys, printable ASCII, in strictly
  ascending byte order (JCS order). No two shapes have the same key sequence. `ipo` checks all of
  this at every start and refuses to run any mode with a table that breaks it (`BADTABLE`).
- The table is part of the form. A different table needs a different frame word, never `ipo1`.

| Word | Keys, in order |
|---|---|
| `env` | destination, interplane_version, message_id, parent_id, payload, source, timestamp, trace_id |
| `expo` | floor, inputs |
| `peer` | id, kind |
| `prov` | coercion, dialect, dialect_version, model, parser_version, raw_name, source_call_id, source_digest, source_turn |
| `prov2` | coercion, dialect, dialect_version, exposure, model, parser_version, raw_name, source_call_id, source_digest, source_turn |
| `prov3` | dialect, parser_version |
| `rcpt` | ack_digest, ack_record_id, grant_digest, grant_id, intent_digest, intent_id, request_id, state, trace_id |
| `res` | data, decision, error, kind, provenance, request_id, status |
| `rprov` | capability, content_kind, duration_ms, runtime, trust, trusted |
| `tool` | name, namespace |
| `treq` | arguments, kind, provenance, request_id, tool |
| `treq2` | arguments, extensions, kind, provenance, request_id, tool |
| `wfile` | content, path |
| `wrote` | bytes_written, path |
| `wrote2` | bytes_written, path, receipt |

**How it was built.** A key sequence gets a shape exactly when at least 2 objects of
`tests/vectors.jsonl` have it, it has at least 2 keys, and every key is printable ASCII. The words
were chosen by hand. `tests/census.om` recounts this from the vectors: 282 objects, 35 distinct key
sequences, 15 of them with a shape, none missing, none unjustified
(`CENSUS PASS shapes=15 sequences=35 objects=282`).

## 5. The program

`ipo MODE`, stdin to stdout. Every output is a function of the bytes on stdin and of MODE: `ipo`
reads no clock, file, environment or network. When it refuses it writes nothing to stdout.

| Mode | stdin | stdout |
|---|---|---|
| `canon` | any JSON value | canonical JSON, one LF |
| `enc` | any JSON value | its frame |
| `dec` | one frame | canonical JSON, one LF |
| `selftest` | canonical JSON values, one per line | per-kind lines and a verdict (section 6) |
| `shapes` | not read | the shape table |

### Exit status

| Status | Meaning |
|---|---|
| 0 | done (selftest: PASS) |
| 1 | selftest: FAIL |
| 2 | usage: not exactly one argument, or an unknown mode |
| 20 to 51 | a refusal class, below. stderr has one line `ipo: NAME at byte N` |
| 100 and above | an Omega trap. No input is known to cause one; it would be a defect of `ipo` |

N is the byte offset in the input (in `selftest`, in the line or in its frame) where the reader
stopped; for `TOOBIG` and `OUTBIG` it is the limit.

| Status | NAME | Refused |
|---|---|---|
| 20 | `IOREAD` | stdin cannot be read |
| 21 | `IOWRITE` | stdout cannot be written. The only refusal after which stdout may hold part of the output |
| 22 | `TOOBIG` | input over 1048576 bytes |
| 23 | `OUTBIG` | output over 1048576 bytes |
| 24 | `DEPTH` | arrays, objects or shapes nested more than 64 deep (JSON and frames) |
| 25 | `JSYNTAX` | not a JSON value |
| 26 | `JTRAIL` | bytes after the JSON value |
| 27 | `JSTR` | JSON string: bad escape, raw control byte, no closing quote |
| 28 | `BADUTF8` | invalid UTF-8 in a string (JSON and frames) |
| 29 | `SURROG` | lone surrogate escape |
| 30 | `DUPKEY` | a key twice in one JSON object |
| 31 | `KEYNASC` | a non-ASCII key (JSON and frames) |
| 32 | `BADNUM` | malformed number (JSON and frames) |
| 33 | `NUMFLOAT` | a number with a fraction or an exponent (JSON and frames) |
| 34 | `NUMRANGE` | an integer of magnitude above 2^53 (JSON and frames) |
| 35 | `NEGZERO` | `-0` (JSON and frames) |
| 36 | `FRNOLF` | the frame does not end with LF (also: empty input) |
| 37 | `FRCTL` | a byte 0x00 to 0x1F before the final LF |
| 38 | `FRMAGIC` | the frame does not start with `ipo1` and a space |
| 39 | `FRSPACE` | a leading, trailing or double space, or a quoted string not followed by a space or the LF |
| 40 | `FRWORD` | a token that is no value: unknown word, `ipo1` as a value |
| 41 | `FRARITY` | `end` or the end of the frame where a value is required: a shape short of values, an open `arr` or `obj`, a key without a value |
| 42 | `FRTRAIL` | a token after the value |
| 43 | `FRKEY` | an `obj` key that is not a string |
| 44 | `FRSTR` | a quoted string that is not the JCS spelling |
| 45 | `NOTBARE` | a quoted string or key that must be bare |
| 46 | `NOTSHAPE` | an `obj` whose key sequence is a shape's |
| 47 | `KEYORDER` | `obj` keys not strictly ascending (out of order, or a key twice) |
| 48 | `NONCANON` | the frame is not the encoding of its value (backstop, section 3) |
| 49 | `BADTABLE` | the embedded shape table breaks its rules |
| 50 | `CAPACITY` | an internal pool is full: 1048576 values or 1179648 pool bytes per input (not reachable within the 1 MiB input limit), or more than 64 kinds in `selftest` |
| 51 | `JSONWORD` | the bare token `true`, `false` or `null` in a frame, as a value or as an `obj` key. N is where the token starts |

Reasons that appear only in a `selftest` verdict (exit 1): `NOTCANON` a line is not its own
canonical JSON, `ROUNDTRIP` dec(enc(line)) is not the line, `REENC` enc(dec(frame)) is not the
frame, `NOLF` the last line has no LF, `NOVECTORS` stdin is empty. A refusal class met while
handling a line is reported under its own NAME.

### Limits

| What | Limit |
|---|---|
| input of `canon`, `enc`, `dec`; one line of `selftest` | 1048576 bytes |
| output | 1048576 bytes, LF included |
| stdin of `selftest` | 8388608 bytes |
| nesting | 64 |
| integer magnitude | 9007199254740992 |
| bare string, bare key | 64 bytes |
| shapes; keys in all shapes | 256; 4096 |
| distinct kinds in `selftest` | 64 |

## 6. `ipo selftest`

stdin is a file of canonical JSON values, one per line, each line ended by LF. For each line, in
this order: canon(line) must be the line; frame = enc(line); dec(frame) must be the line, byte for
byte; enc(dec(frame)) must be the frame.

stdout on success, exit 0:

```
kind=<payload.kind or -> n=<vectors> json=<bytes> ipo=<bytes>     one line per kind, sorted by kind
IPO1 PASS vectors=N json_bytes=A ipo_bytes=B                       the last line
```

The kind of a line is its `payload.kind` when the line is an object whose `payload` is an object
whose `kind` is a string matching `bare`'s pattern; otherwise `-`. `json` and `json_bytes` count
the bytes of the lines and `ipo` and `ipo_bytes` the bytes of their frames, **neither counting
the LF**.

stdout on failure, exit 1, is the single line `IPO1 FAIL line=K reason=NAME` (K counts from 1;
0 means before the first line), and stderr has the `ipo: NAME at byte N` line.

**What a PASS does not show.** It shows that this build of `ipo` round-trips these lines. It does
not show that the build holds the pinned table: a build with another valid table also passes,
with other byte counts. Compare stdout with `tests/expected.txt`, the output of `ipo shapes`
with the sha256 above, and `ipo enc < tests/example.json` with `tests/example.ipo`.

## 7. Measured on the vectors

39 distinct envelopes (`tests/vectors.jsonl`); `tests/expected.txt` is the selftest output:

```
kind=result n=8 json=6366 ipo=3500
kind=tool_request n=31 json=18521 ipo=9282
IPO1 PASS vectors=39 json_bytes=24887 ipo_bytes=12782
```

Smallest ratio: vector 3, 560 bytes to 237 (`tests/example.json`). Largest: vector 2, 703 bytes
to 625: it is the unknown-fields fixture, where one extra key in the envelope, the payload and
the provenance takes each of them out of its shape. Both from `tests/census.om`.

Only bytes were measured. **Tokens were not measured**: no tokenizer was run, so the per-token
cost for a given model is not known from this work.

## 8. Notes on the design

The design was given; these are the places where implementing it showed a consequence.

1. **0x7F.** "ASCII control bytes are refused" cannot include 0x7F inside a quoted string: JCS
   writes U+007F literally, so refusing it would make some JSON strings impossible to carry.
   ipo1 refuses 0x00 to 0x1F everywhere and admits 0x7F only inside a quoted string.
2. **`true`, `false` and `null` are reserved.** In the first draft they matched the bare
   pattern, so `ipo1 true` was the JSON string `"true"` while the boolean is `ipo1 yes`: a
   writer falling back into JSON habits produced a valid frame with another meaning. The form
   was changed before release: the three words are reserved, the strings are written quoted, and
   a bare `true`, `false` or `null` is refused with its own class, `JSONWORD` (51). A word that
   only starts like one (`truex`, `nulls`) is still an ordinary bare string.
3. **Unshaped values cost more than JSON.** `[]` is `arr end`, `{"a":1}` is `obj a 1 end`. The
   58 hand-written values of `tests/edge.jsonl` are 1069 bytes as JSON and 1716 as frames. The
   form only pays where shapes match.
4. **A shape is all or nothing.** One unknown key puts the whole object back to `obj` with every
   key name (vector 2 above).
5. **The reader needs the table** (806 bytes) to read any shaped frame.
6. **Constant values are still written.** `treq` always carries the word `tool_request`, `env`
   always carries the version string: a shape fixes keys, not values.
7. **Integers above 2^53 are refused, not rounded.** One envelope of the INTERPLANE fixtures
   carries `"task":15330623940039986179` and is therefore not in the vectors
   (`tests/PROVENANCE.md`). JCS serializes numbers as binary64, so such a number is not written
   back with its own digits by a JCS writer either.
