# plumbline/proofs: what is proved, about which model

Lean 4 proofs, core library only (no Mathlib). Each file checks with `lean FILE.lean`, prints the axioms every theorem depends on, and carries a negative control: a statement showing the claim is not vacuous.

A proof here is about a model. Each file's header says how the model is tied to the running Omega program, and where that tie is a test and not a proof.

## Check them

```sh
lean plumbline/proofs/Neuralese.lean
lean plumbline/proofs/Share.lean
lean plumbline/proofs/Ipo1.lean
lean plumbline/proofs/Ipo1Control.lean
lean plumbline/proofs/control/Unproved.lean      # must be FLAGGED: it holds a sorry on purpose
```

A file is a checked proof only if all of these hold: `lean` exits 0; no line of its output mentions `sorry` or an error; every theorem appears in a `#print axioms` line; every axiom listed is one of `propext`, `Classical.choice`, `Quot.sound`. Lean exits 0 on an unproved theorem, so the exit status alone decides nothing. `plumbline/gate.sh` step L1 applies exactly this test and requires `control/Unproved.lean` to fail it.

Checked here with Lean 4.35.0 (commit `eb6cafb7290e8bd5f2937522d8d804f58f02bafc`), from the official release archive, sha256 `7289597a44543246c9227b8cae501767e095ce17f6d448b95fc4a8dc97268f6d`.

## What each file proves

| File | Theorems | Claim | Axioms |
|---|---:|---|---|
| `Neuralese.lean` | 8 | **Why the untied model cannot learn it.** If two inputs agree on every training case, no run of gradient steps moves the difference of their weights (`run_keeps_diff`); and two different systems give the same answer on all of those cases (`data_cannot_decide`) while differing on a held-out one (`but_they_differ`). **Why the tied model must.** A tied system that reproduces one case with a 0 and one with a 1 reproduces all sixteen IDs (`tied_generalizes`). Controls: a step with differing inputs does move the difference; a tied system trained on 0 bits only can be wrong. | `propext`, `Quot.sound`, or none |
| `Share.lean` | 3 | The hub's share figure, `(1000 a + t/2) / t` with `t = a + b`, is within half a permille of `1000 a / t` (`permil_nearest`); the nine subsystem figures the hub prints, computed from the ledger's line counts (`shares_as_printed`). Control: rounding down gives a different figure on this data. | `propext`, `Quot.sound`, or none |
| `Ipo1.lean` | 22 | **The `ipo1` token grammar decodes uniquely.** Decoding `enc v` followed by anything returns `v` and exactly the rest (`T1_round_trip`); equal encodings mean equal values (`T2_unique_decodability`); if two encodings, each followed by anything, are equal token for token, then the values are equal and so are the remainders (`T3_prefix_free`); no value starts with `end` (`T4_no_value_starts_with_end`). | none |
| `Ipo1Control.lean` | 6 | Controls for the above: without a fixed arity per shape, and without `end` after a list, two different values share one encoding. | none |
| `control/Unproved.lean` | 0 proved | A true statement left unproved, to test the gate. | `sorryAx` (flagged) |

## What is not proved

- **That the Omega programs implement these models.** `ipo1`'s program is tied to its grammar by a round-trip test over real envelopes, the share function by the nine printed values, the Neuralese model by the program's own measurements (criteria P1 and P6). Those are tests.
- **Floating point.** `Neuralese.lean` works in exact integers; the program computes in IEEE binary64, where the difference drifts by about 1e-14 over a run, as its last column shows.
- **The lexical layer of `ipo1`**: when a string is written bare or quoted, the reserved words, and JSON canonicalization. The grammar proof starts at tokens.
- **Decoder strictness**: that the model decoder refuses every token list that is not a frame.
- **Anything about a real model, a GPU or a serving path.**
