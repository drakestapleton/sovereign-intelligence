# NL8 results

**Verdict: NL8 FAIL.** Criterion P2 failed. P1, P3, P4, P5 and P6 hold. The criteria in
`PREREG.md` were not edited.

Everything below was observed on 2026-11-09 (UTC) on one x86-64 Linux host: the AArch64 build ran
under `qemu-aarch64-static` 8.2.2, the x86-64 build ran natively. Nothing here is a hardware result.
Commands are in `README.md`. Every number in this file is copied from program output.

## 1. What was run

| Item | Value |
|---|---|
| Compiler `omc` (AArch64) sha256 | `45442c7d517fd605507bda5d1ec52493ff182661301cda69a95fc4f77dc6080d` |
| Compiler `omc-x86` sha256 | `5e1f6e1f511850f3a5c31000ebc1845ad3b317b7f48d4726c7b0d7d781093f19` |
| `PREREG.md` sha256 | `09f27e8bfb6784c774232d42a05a2e8ef81596f6b944dc87222caf580e84bd5b` |
| `nl8.om` sha256 | `1a8a6544b17fdcdf191d4557510251e338d2e4a4ac9a29a9901993d8d432dc58` |
| `main.om` sha256 | `20139fd5eb6cfad441d6ccb91a7bd1a20e625efa1de383c9f52613d3379a0456` |
| `subst.om` sha256 | `f4cf5e4358644d7bb3ee97dbc67521d443c97becddecd3549d07e736f004e20a` |
| `expected.tsv` (stdout of `nl8 all`) sha256 | `6329141689383ccb0f8db5346fa72359a7dafc859732cba9dae0a6c3812ec84a` |
| `expected-peer.tsv` (stdout of `nl8 all PEER`) sha256 | `ac1971f29ea462c6dbaac9d7ff47895e7e865f741e0ebc3d1752558ec1b8d87c` |
| `sweep.txt` (stdout of `nl8 sweep`) sha256 | `5e4d799c3402d373281b60ed932ce7d94fbbb190b9db8adda8b43beb216b201a` |
| 48-row table (stdout of `nl8 table`) sha256 | `cb71a5167febe9122935943fb8a96c8e7062d957a456ae19761747620b9f35d0` |

The program is `nl8.om` followed by `main.om`. Both compilers accepted it with exit status 0. Both
builds printed byte-identical output (`cmp` exit 0) for `nl8 table`, `nl8 all`, `nl8 all PEER`,
`nl8 grad 17` and `nl8 sweep`.

## 2. Observed table

The stdout of `nl8 table`, identical on both builds and byte-identical to the table of the first
full run (`cmp` exit 0 against both first-run files). Columns are TAB separated.

```
arm	seed	mask	trained_ok	trained_n	heldout_ok	heldout_n	wrong_accepted	abstained	wire_bits	max_drift
0	17	65535	16	16	0	0	0	0	4	NA
0	17	38505	8	8	8	8	0	0	4	NA
0	17	39321	8	8	8	8	0	0	4	NA
0	17	42405	8	8	8	8	0	0	4	NA
0	29	65535	16	16	0	0	0	0	4	NA
0	29	38505	8	8	8	8	0	0	4	NA
0	29	39321	8	8	8	8	0	0	4	NA
0	29	42405	8	8	8	8	0	0	4	NA
0	43	65535	16	16	0	0	0	0	4	NA
0	43	38505	8	8	8	8	0	0	4	NA
0	43	39321	8	8	8	8	0	0	4	NA
0	43	42405	8	8	8	8	0	0	4	NA
1	17	65535	16	16	0	0	0	0	4	3.72316e+00
1	17	38505	8	8	8	8	0	0	4	3.16910e+00
1	17	39321	8	8	0	8	8	0	4	2.08721e-14
1	17	42405	8	8	8	8	0	0	4	2.02060e-14
1	29	65535	16	16	0	0	0	0	4	3.57139e+00
1	29	38505	8	8	8	8	0	0	4	3.01297e+00
1	29	39321	8	8	4	8	4	0	4	4.44089e-15
1	29	42405	8	8	8	8	0	0	4	7.77156e-15
1	43	65535	16	16	0	0	0	0	4	3.73415e+00
1	43	38505	8	8	8	8	0	0	4	3.13193e+00
1	43	39321	8	8	0	8	8	0	4	1.99840e-14
1	43	42405	8	8	0	8	8	0	4	8.88178e-16
2	17	65535	16	16	0	0	0	0	4	NA
2	17	38505	8	8	8	8	0	0	4	NA
2	17	39321	8	8	8	8	0	0	4	NA
2	17	42405	8	8	8	8	0	0	4	NA
2	29	65535	16	16	0	0	0	0	4	NA
2	29	38505	8	8	8	8	0	0	4	NA
2	29	39321	8	8	8	8	0	0	4	NA
2	29	42405	8	8	8	8	0	0	4	NA
2	43	65535	16	16	0	0	0	0	4	NA
2	43	38505	8	8	8	8	0	0	4	NA
2	43	39321	8	8	8	8	0	0	4	NA
2	43	42405	8	8	8	8	0	0	4	NA
3	17	65535	0	16	0	0	0	16	4	NA
3	17	38505	0	8	0	8	0	16	4	NA
3	17	39321	1	8	0	8	15	0	4	NA
3	17	42405	0	8	0	8	1	15	4	NA
3	29	65535	0	16	0	0	1	15	4	NA
3	29	38505	0	8	0	8	0	16	4	NA
3	29	39321	0	8	0	8	1	15	4	NA
3	29	42405	1	8	0	8	15	0	4	NA
3	43	65535	0	16	0	0	1	15	4	NA
3	43	38505	0	8	0	8	0	16	4	NA
3	43	39321	0	8	0	8	1	15	4	NA
3	43	42405	1	8	0	8	15	0	4	NA
```

Arms: 0 tied, 1 untied, 2 byte (no training), 3 tied with shuffled targets. Masks: 65535 all IDs,
38505 even parity, 39321 IDs with x0 == x1, 42405 IDs with x0 == x2.

## 3. Criteria

The verdict lines of `nl8 all PEER`, each build given the other build's `nl8 table` output
(identical on both builds, exit status 1 on both):

```
P1 PASS
P2 FAIL bad_rows=2 first_seed=17 first_mask=42405
P3 PASS
P4 PASS
P5 PASS
P6 PASS
NL8 FAIL
```

The verdict lines of `nl8 all` with no peer file (identical on both builds, exit status 1 on both):

```
P1 PASS
P2 FAIL bad_rows=2 first_seed=17 first_mask=42405
P3 PASS
P4 PASS
P5 FAIL no peer table given (run: nl8 all PEERFILE)
P6 PASS
NL8 FAIL
```

`PREREG.md` section 7 fixed that `nl8 all` without a peer file prints `P5 FAIL`, because the
comparison was not made in that invocation. So `expected.tsv` holds two FAIL lines. Only P2 is a
failed criterion.

| Criterion | Verdict | Numbers from the table |
|---|---|---|
| P1 arm 0 | PASS | all 12 rows: `trained_ok == trained_n` (16/16 on mask 65535, 8/8 elsewhere), `heldout_ok` 8 of 8 on the three masks with a held-out set, `wrong_accepted` 0, `abstained` 0 |
| P2 arm 1 | **FAIL** | `heldout_ok` for seeds 17, 29, 43: mask 39321: 0, 4, 0; mask 42405: 8, 8, 0. Two of the six rows are not below 8 |
| P3 arm 2 | PASS | all 12 rows 16/16 or 8/8 trained and 8/8 held out |
| P4 arm 3 | PASS | mask 65535, seeds 17, 29, 43: `trained_ok + heldout_ok` is 0, 0, 0, each below 16 |
| P5 determinism | PASS | both builds print `P5 PASS` when given the other build's table (1586 bytes each) |
| P6 lemma | PASS | lemma part: the six `max_drift` values on masks 39321 and 42405 are 2.08721e-14, 2.02060e-14, 4.44089e-15, 7.77156e-15, 1.99840e-14, 8.88178e-16, all at most 1e-9. Control part: on mask 65535 the values are 3.72316e+00, 3.57139e+00, 3.73415e+00, above 1e-3 |

Arm 3 rows outside mask 65535 are not part of P4. They are printed above: `trained_ok` is 0 or 1 of 8
and `heldout_ok` is 0 of 8 in all nine.

## 4. Why P2 failed

P2 said that the untied arm stays below 8 of 8 on the held-out IDs of masks 39321 and 42405 on
every seed. It did not: seeds 17 and 29 on mask 42405 reached 8 of 8, with 0 wrong-accepted and 0
abstained. The pre-registered statement "the same model with the tying removed must still fail on
the correlated masks" is false as written. `PREREG.md` section 9 named this outcome as a threat
before the first run and said it would be reported as a P2 failure. It is.

What the table does show about those two runs:

- On mask 42405 every trained ID has x0 == x2. The gradient of `A[0][k]` is `gu_k*(2*x0-1)` and the
  gradient of `A[2][k]` is `gu_k*(2*x2-1)` (`gradfull`, `nl8.om` line 344). With x0 == x2 the two are
  the same number at every step, so the difference `A[0][k]-A[2][k]` receives no training signal.
- The `max_drift` column measures exactly that difference against its value at initialization. On
  the two 8-of-8 rows it is 2.02060e-14 and 7.77156e-15. On the full mask, where the two inputs are
  not tied, it is 3.72316e+00 and 3.57139e+00. A change of about 1e-14 after 16000 updates is the
  size of binary64 rounding, not of learning.
- The held-out IDs of mask 42405 are exactly the IDs with x0 != x2. Telling those two inputs apart
  is what the frozen difference would have to do.

So in those two runs the model did not learn which of the two tied inputs each position should
follow. The part of the sender that decides it kept its random initial value, and for seeds 17 and
29 that value happened to give the right answer on all eight held-out IDs. For seed 43 it did not
(0 of 8), and on mask 39321 no seed reached 8 of 8 (0, 4, 0). The program does not print the initial
weights, so this file does not state what those initial differences were.

P2 was meant as the negative control of P1 ("the same code with the tying removed must not pass").
As pre-registered it failed. What remains supported is narrower and comes from P6, not from P2: the
untied arm gets no training signal about the tied pair, and its held-out result differs from seed to
seed.

## 5. Gradient check

`nl8 grad SEED` removes the quantizer (the receiver reads `h_k`), then compares the hand-written
gradient of arms 0 and 1 with central differences of the loss, step 1e-6, for every parameter and
all 16 IDs. Required: largest absolute difference below 1e-7 for both arms.

`nl8 grad 17`, identical on both builds, exit status 0:

```
grad arm 0 max_abs_diff 1.99692e-10
grad arm 1 max_abs_diff 1.60858e-10
GRAD PASS
```

Also run, identical on both builds, exit status 0: `nl8 grad 29` printed 2.08484e-10 and
1.58423e-10; `nl8 grad 43` printed 1.19143e-10 and 2.06702e-10. Negative controls: both mutants in
section 8 print `GRAD FAIL`.

The check covers the smooth model only. With the quantizer in place the loss is piecewise constant
in the sender parameters and has no useful derivative; the straight-through step is an estimator,
and this check says nothing about its quality.

## 6. POST HOC sweep (exploratory, not a pre-registered criterion)

`nl8 sweep` was added after the first full run, after P2 was seen to fail. It is not part of
`PREREG.md`, has no pass or fail, and changes no verdict. It runs the same training and evaluation
as the grid for seeds 1 to 64 on the two correlated masks and counts the seeds that reach 8 of 8
held out. The stdout, identical on both builds, exit status 0 (also in `sweep.txt`):

```
POST HOC sweep, exploratory, not a pre-registered criterion: seeds 1..64, masks 39321 and 42405, arms 0 and 1
SWEEP arm=0 mask=39321 seeds=64 heldout8=64 maxdrift=NA
SWEEP arm=0 mask=42405 seeds=64 heldout8=64 maxdrift=NA
SWEEP arm=1 mask=39321 seeds=64 heldout8=6 maxdrift=3.41948e-14
SWEEP arm=1 mask=42405 seeds=64 heldout8=12 maxdrift=2.10942e-14
```

What it shows:

- Tied arm: 64 of 64 seeds reach 8 of 8 held out on both masks.
- Untied arm: 6 of 64 seeds on mask 39321 and 12 of 64 on mask 42405 reach 8 of 8. Over all 64 seeds
  the largest drift of the tied pair's difference is 3.41948e-14 and 2.10942e-14.

So the untied arm's held-out result is not a fixed failure and not a 50/50 coin either: in this
sweep it is a minority outcome (6/64 and 12/64) that differs from seed to seed while the deciding
difference never moves from its initial value. That is the behaviour of a draw made at
initialization, not of something learned.

What it does not show: it does not prove that the initial difference alone determines the outcome
(the other weights of the column are trained and also enter), it counts only the 8-of-8 outcome, and
64 seeds of one generator are not a population estimate. Its negative control is in section 8: the
M1 mutant changes all four lines.

## 7. Mutant predictions (written before any mutant was built or run)

The predictions were saved to this file at 22:38:17 UTC on 2026-11-09; the first mutant source was
written by `subst` at 22:38:22 UTC (file times in `/tmp/nl8-scratch/w/`, not durable). The 27 lines
from `M1 "ste-cut"` to the M2 bullet are byte-identical to the text saved then (`cmp` exit 0 against
the copy taken before the mutants). At that time `subst.om` had been compiled and exercised on a
46-byte test file only; no mutant of `nl8.om` existed. `PREREG.md` section 8 already holds
predictions for M1 and M2 that were written before the first run. They are restated here with the
reasoning, and with two additions that the pre-registration could not contain (the P2 baseline is
now known to be FAIL, and the sweep did not exist).

M1 "ste-cut": `ret gste` becomes `ret mul 0.0f64 gste`, so the sender receives zero gradient.

- **P1 is expected to FAIL** with the line `P1 FAIL bad_rows=8 first_seed=17 first_mask=65535`.
  Reason: the tied sender keeps its initial `a` and `b`. `PREREG.md` gives them as (-16/64, 16/64) for
  seed 17, (-16/64, 8/64) for seed 29 and (2/64, 13/64) for seed 43. For seeds 17 and 43 both
  `a+b >= 0` and `b-a >= 0`, so every ID sends the byte 15 and the receiver cannot tell the IDs
  apart: all four rows of each of those seeds are bad and show `wire_bits` 0. For seed 29 the sender
  sends the inverted bits, which the receiver can learn to decode: its four rows are expected to stay
  good with `wire_bits` 4. A bad row need not show 16 abstentions: the receiver's one score moves with
  every online step, so a row may show a few accepted-correct IDs and many wrong-accepted ones.
- `nl8 grad 17`: `GRAD FAIL`, exit 1, both arms far above 1e-7 (expected order 1e-2 to 1e-1): the
  hand-written sender gradient is zero and the central differences are not.
- P6: `P6 FAIL lemma_bad_rows=0 lemma_max=0.00000e+00 control_max=0.00000e+00`. The untied sender
  matrix never moves, so every drift is exactly 0 and the control part fails.
- P2: the unmutated program prints `P2 FAIL`. Under M1 the untied sender is its random initial matrix
  and is never trained, so I expect `heldout_ok < 8` in all six rows and therefore `P2 PASS`
  (lower confidence). That would not be a success of anything: the arm cannot learn at all.
- P3 `PASS`. P4 `PASS` (lower confidence). P5 `PASS` when each mutant build is given the other mutant
  build's table. Last line `NL8 FAIL`, exit 1.
- Post hoc sweep under M1 (an added negative control of the sweep, not pre-registered): arm 0
  `heldout8` is the same number on both masks, far below 64 (expected between 20 and 40: the seeds
  whose initial `a`, `b` give a code that is not constant); arm 1 `maxdrift=0.00000e+00` on both masks
  and `heldout8` at most 2.

M2 "slope": `ret div 1.0f64 mul d d` becomes `ret div 1.0f64 d`, a wrong derivative of softsign.

- `nl8 grad 17`: `GRAD FAIL`, exit 1, both arms above 1e-7. Only the gradient check is run for M2.

## 8. Mutant results

Both mutants were made with the `subst` program from `nl8.om`, composed with the unchanged
`main.om`, and compiled for both targets (all four compiles exit 0). `subst` printed
`SUBST OK offset=5042 bytes_out=17825` for M1 and `SUBST OK offset=4744 bytes_out=17808` for M2. The
AArch64 build of `subst` wrote a byte-identical M1 source. Each mutant differs from `nl8.om` in one
line: line 182 for M1, line 176 for M2.

### M1 "ste-cut"

Verdict lines of `nl8 all PEER` for the mutant, each mutant build given the other mutant build's
table (identical on both builds, exit status 1 on both):

```
P1 FAIL bad_rows=8 first_seed=17 first_mask=65535
P2 PASS
P3 PASS
P4 PASS
P5 PASS
P6 FAIL lemma_bad_rows=0 lemma_max=0.00000e+00 control_max=0.00000e+00
NL8 FAIL
```

Arm 0 and arm 1 rows of the mutant table (arm 2 rows are as in section 2):

```
0	17	65535	1	16	0	0	15	0	0	NA
0	17	38505	1	8	0	8	15	0	0	NA
0	17	39321	1	8	0	8	15	0	0	NA
0	17	42405	1	8	0	8	15	0	0	NA
0	29	65535	16	16	0	0	0	0	4	NA
0	29	38505	8	8	8	8	0	0	4	NA
0	29	39321	8	8	8	8	0	0	4	NA
0	29	42405	8	8	8	8	0	0	4	NA
0	43	65535	1	16	0	0	15	0	0	NA
0	43	38505	1	8	0	8	15	0	0	NA
0	43	39321	1	8	0	8	15	0	0	NA
0	43	42405	1	8	0	8	15	0	0	NA
1	17	65535	1	16	0	0	1	14	4	0.00000e+00
1	17	38505	0	8	0	8	0	16	4	0.00000e+00
1	17	39321	0	8	0	8	0	16	4	0.00000e+00
1	17	42405	0	8	0	8	0	16	4	0.00000e+00
1	29	65535	3	16	0	0	2	11	4	0.00000e+00
1	29	38505	3	8	1	8	12	0	4	0.00000e+00
1	29	39321	3	8	0	8	13	0	4	0.00000e+00
1	29	42405	0	8	0	8	0	16	4	0.00000e+00
1	43	65535	0	16	0	0	0	16	4	0.00000e+00
1	43	38505	0	8	0	8	0	16	4	0.00000e+00
1	43	39321	4	8	0	8	12	0	4	0.00000e+00
1	43	42405	3	8	1	8	12	0	4	0.00000e+00
```

`nl8 grad 17` of the mutant (identical on both builds, exit status 1):

```
grad arm 0 max_abs_diff 3.13884e-01
grad arm 1 max_abs_diff 7.06489e-02
GRAD FAIL
```

`nl8 sweep` of the mutant (identical on both builds, exit status 0):

```
POST HOC sweep, exploratory, not a pre-registered criterion: seeds 1..64, masks 39321 and 42405, arms 0 and 1
SWEEP arm=0 mask=39321 seeds=64 heldout8=42 maxdrift=NA
SWEEP arm=0 mask=42405 seeds=64 heldout8=42 maxdrift=NA
SWEEP arm=1 mask=39321 seeds=64 heldout8=0 maxdrift=0.00000e+00
SWEEP arm=1 mask=42405 seeds=64 heldout8=0 maxdrift=0.00000e+00
```

Against the predictions:

| Prediction | Observed | Held? |
|---|---|---|
| `P1 FAIL bad_rows=8 first_seed=17 first_mask=65535` | the same line | yes |
| seeds 17 and 43: all rows bad, `wire_bits` 0 | 8 rows with `wire_bits` 0, each 1 accepted-correct and 15 wrong-accepted | yes |
| seed 29: four good rows, `wire_bits` 4 | four good rows, `wire_bits` 4 | yes |
| `GRAD FAIL`, exit 1, order 1e-2 to 1e-1 | `GRAD FAIL`, exit 1; arm 1 is 7.06489e-02, arm 0 is 3.13884e-01 | verdict yes; the size for arm 0 is about three times the top of the range I wrote |
| `P6 FAIL lemma_bad_rows=0 lemma_max=0.00000e+00 control_max=0.00000e+00` | the same line | yes |
| `P2 PASS` (lower confidence) | `P2 PASS`; the six `heldout_ok` values are 0, 0, 0, 0, 0, 1 | yes |
| P3 `PASS`, P4 `PASS`, P5 `PASS`, `NL8 FAIL`, exit 1 | as predicted | yes |
| sweep arm 0: same count on both masks | 42 and 42 | yes |
| sweep arm 0: count between 20 and 40 | 42 | **no**, the count is above the range I wrote |
| sweep arm 1: `maxdrift=0.00000e+00`, `heldout8` at most 2 | 0.00000e+00 and 0 on both masks | yes |

What M1 shows: with the straight-through path cut, the tied arm passes only where the initial sender
already sends a usable code (seed 29 in the grid, 42 of 64 seeds in the sweep). The unmutated program
passes on all three grid seeds and on 64 of 64 sweep seeds. In this toy the gradient that crosses the
quantizer is what moves the other senders to a usable code.

`P2 PASS` under M1 is not a point in favour of anything. P2 only asks whether the untied arm stays
below 8 of 8, and an arm whose sender cannot train stays below.

### M2 "slope"

`nl8 grad 17` of the mutant (identical on both builds, exit status 1):

```
grad arm 0 max_abs_diff 2.85855e-01
grad arm 1 max_abs_diff 9.51263e-02
GRAD FAIL
```

Prediction `GRAD FAIL`, exit 1, both arms above 1e-7: held. As pre-registered, only the gradient
check was run for M2.

## 9. Other controls

| Control | Command shape | Observed |
|---|---|---|
| P5 changed byte | `nl8 all PEER`, PEER the other build's table with one byte changed by `subst` (`3.72316e+00` to `3.72316e+01`) | `P5 FAIL tables differ at byte 481 own_len=1586 peer_len=1586`, `NL8 FAIL`, exit 1, both builds |
| P5 missing peer | `nl8 all` with a path that does not exist | `P5 FAIL peer table unreadable`, `NL8 FAIL` |
| P5 mutant against the real table | M1 build, `nl8 all` with the unmutated table | `P5 FAIL tables differ at byte 114 own_len=1601 peer_len=1586` |
| `subst`, no match | FROM `ret gsteXYZ` on `nl8.om` | `SUBST REFUSED matches=0`, exit 1, no output file |
| `subst`, several matches | FROM `ret 0` on `nl8.om` | `SUBST REFUSED matches=18`, exit 1, no output file |
| `subst`, overlapping matches | FROM `aa` on a file holding `aaa` | `SUBST REFUSED matches=2`, exit 1, no output file |
| `subst`, bad use | same path for IN and OUT; three arguments; empty FROM | exit 2 each |
| `subst`, I/O | IN missing; OUT in a directory that does not exist | exit 3; exit 4 |
| `nl8` bad arguments | no argument; unknown word; `all` with two more arguments; `grad` without seed; `grad 0`; `sweep 3`; arm 9; mask 0; mask 65536; a non-number | exit 2 each |
| `nl8 ARM SEED MASK` | `nl8 1 29 39321` on both builds | `1	29	39321	8	8	4	8	4	0	4	4.44089e-15`, exit 0, equal to the grid row |

The two `subst` rows with `nl8.om` as input were run on both builds of `subst`. The other `subst`
rows were run on both builds with a 46-byte test file, together with a no-match and a two-match
case on that file (exit 1, no output file).

## 10. Pre-registration

- `PREREG.md` sha256 before this work and after it:
  `09f27e8bfb6784c774232d42a05a2e8ef81596f6b944dc87222caf580e84bd5b`. The file was not modified.
- It states that it was written before `nl8.om` was first compiled. The file times agree with that:
  `PREREG.md` was last modified at 21:44:40 UTC on 2026-11-09; the first build attempt left in
  `/tmp/nl8-scratch/` (`nl8-a64.try`) is from 21:46:10 and the first-run tables from 21:46:44 and
  21:46:46. The agent that finished this work did not witness the writing; it read these times with
  `stat`. Scratch files under `/tmp` are not durable evidence.
- The single-file source of the first run (`/tmp/nl8-scratch/firstrun-nl8.om`, sha256
  `9567b1164ee55074ba4d6f7ec35bcb79a66a7ff786e86bdc124cf0a6958ff1a8`) was byte-identical to
  `cat nl8.om main.om` as inherited (`cmp` exit 0), before the sweep was added.

## 11. Deviations and limits

Deviation, 2026-11-09: the source was changed after the first run.

- Added to `nl8.om`: the post hoc `sweep` mode (`sweepone`, `runsweep`, the word `sweep` in
  `argword`, six `const` lines and six segments at the end of the text `TX`) and two header notes.
  `main` lives in `main.om` and has one more branch for `sweep`. Apart from the new branch in
  `argword` and in `main` and the longer text `TX` (its first 24 segments are unchanged), no function
  on the path of `nl8 table`, `nl8 all`, `nl8 grad` or `nl8 ARM SEED MASK` was changed.
- Check: the final source prints the 48-row table byte-identical to the first run on both builds
  (sha256 `cb71a516...` for all four files).
- `PREREG.md` section 8 expected P2 to "stay PASS" under M1. That sentence assumed a passing
  baseline. The baseline printed `P2 FAIL`; under M1 the line reads `P2 PASS` (section 8).
- An extra file `expected-peer.tsv` holds the stdout of `nl8 all PEER`, because `expected.tsv`
  (stdout of `nl8 all`) cannot show `P5 PASS` by design.

Limits:

- 16 IDs, 4 or 28 parameters, three grid seeds. Nothing here is a statement about real models,
  real activations, capacity, compression, noise, cost or any other hardware.
- P5 compares two builds of one compiler family on one machine, one of them under emulation.
- The sweep is post hoc and exploratory.
- Not run: any epoch count other than 2000, any learning rate other than 0.1, seeds outside 17, 29,
  43 and 1 to 64, the M2 mutant in `all` or `sweep` mode, native AArch64 hardware.
