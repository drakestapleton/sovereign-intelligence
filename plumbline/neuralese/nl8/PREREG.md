# NL8 pre-registration

Written 2026-11-09 (UTC), before the trainer `nl8.om` was compiled for the first time.
This file is frozen from the first training run on. Any later deviation is recorded in a dated
"Deviation" section of `RESULTS.md`, never here.

What existed when this file was written: three scratch toolchain probes in `/tmp/nl8-scratch/`
(`probe1.om`, `probe2.om`, `probe3.om`). They test compiler features (arguments, text output, float
printing, file open) and print the first four xorshift32 draws of seeds 17, 29 and 43. None of them
contains a model, a training loop or an evaluation. No line of `nl8.om` had been compiled.

Compilers (sha256 of the files in `/home/user/omc-bin/`):

| File | sha256 |
|---|---|
| `omc` (AArch64 ELF, run under `qemu-aarch64-static`) | `45442c7d517fd605507bda5d1ec52493ff182661301cda69a95fc4f77dc6080d` |
| `omc-x86` (native x86-64 ELF) | `5e1f6e1f511850f3a5c31000ebc1845ad3b317b7f48d4726c7b0d7d781093f19` |

## 1. Hypothesis

The frozen experiments in `/home/user/aien-train/native/neuralese` (NL1, NL1R) record that every
learned arm scores 0/8 on the held-out IDs of masks 39321 and 42405 while a hard-coded byte scores
8/8. NL8 tests one explanation: the missing ingredient is a prior, not capacity and not epochs.

If sender and receiver are position-equivariant (the same weights for every bit position) and are
trained through a 1-bit quantizer with a straight-through estimator, then learning identifies the
code from any of the four masks, and the held-out IDs are recovered exactly, over a real 4-bit
channel. The same model with the tying removed, with the same data, seeds, optimizer and steps,
must still fail on the correlated masks.

## 2. Task and data

- An ID is 0..15. Input bit j of an ID is `x_j = (id >> j) & 1`, j = 0..3. The target is the same
  four bits.
- A training mask is a 16-bit number; ID i is trained when bit i of the mask is 1 and held out
  otherwise. Masks: 65535 (all 16 IDs), 38505 (even parity), 39321 (IDs with x0 == x1), 42405 (IDs
  with x0 == x2).
- Seeds: 17, 29, 43.

## 3. Model

For each position k in 0..3:

- Sender pre-activation `u_k` (per arm, below); `h_k = softsign(u_k)`, `softsign(t) = t / (1 + |t|)`.
- Message bit `m_k = 1` if `h_k >= 0`, else 0.
- The wire is one real byte `m_0 | m_1<<1 | m_2<<2 | m_3<<3`, written to a `uchar` array of length 1.
- The receiver is computed from that byte alone: it reads the byte, refuses a value above 15, and
  decodes `s_k = +1` if bit k is set, else `-1`. It reads no sender input, no ID and no target.
- Receiver pre-activation `z_k = v_k * s_k + c_k`; score `o_k = (1 + softsign(z_k)) / 2`.
- Decision bit k is 1 if `o_k >= 0.5`, else 0. The case ABSTAINS if any `|o_k - 0.5| < 0.1` (the
  NL1R rule). A case is accepted-correct when it does not abstain and all four decision bits equal
  the true bits; wrong-accepted when it does not abstain and at least one bit differs.

Arms:

| Arm | Name | Sender | Receiver | Parameters |
|---|---|---|---|---|
| 0 | tied | `u_k = a*(2*x_k-1) + b` | `z_k = v*s_k + c` | 4: a, b, v, c |
| 1 | untied | `u_k = b_k + sum_j A[j][k]*(2*x_j-1)` (full 4x4 matrix) | `z_k = v_k*s_k + c_k` | 28: A (16), b (4), v (4), c (4) |
| 2 | byte | no training; message byte = id | reads the bits: `o_k` = bit k of the byte (1.0 or 0.0) | 0 |
| 3 | shuffled | arm 0, trained on targets from the fixed derangement `(id+1) & 15` | arm 0 | 4 |

Arm 3 is evaluated against the true targets (the bits of `id`). It is a negative control.

## 4. Training

- Loss for one case: `sum over k of (o_k - t_k)^2`, where `t_k` is the target bit (`x_k`, or the bit
  of `(id+1) & 15` in arm 3). Nothing else is added: no regularizer, no margin term, no penalty for
  confidence, no abstention term.
- Forward pass in training: the quantized `s_k`, decoded from the wire byte, exactly as in
  evaluation. The model trains on what the wire carries.
- Backward pass: straight-through estimator, `d s_k / d h_k` taken as 1. With
  `slope(t) = 1 / (1 + |t|)^2`:
  - `gz_k = (o_k - t_k) * slope(z_k)` (this is dL/dz_k: the factor 2 of the square and the factor
    1/2 of the score cancel);
  - `dL/dv_k = gz_k * s_k`, `dL/dc_k = gz_k`;
  - `gu_k = (gz_k * v_k) * slope(u_k)` (dL/du_k through the straight-through step);
  - tied: `dL/da = sum_k gu_k*(2*x_k-1)`, `dL/db = sum_k gu_k`, `dL/dv = sum_k gz_k*s_k`,
    `dL/dc = sum_k gz_k`, sums in ascending k;
  - untied: `dL/dA[j][k] = gu_k*(2*x_j-1)`, `dL/db_k = gu_k`.
- Optimizer: online SGD, learning rate 0.1, 2000 epochs; each epoch visits the trained IDs in
  ascending order, one update per ID; no schedule, no momentum, no early stopping. All gradients of
  a step come from the parameters before the step; all parameters then change together. A step that
  would make a parameter non-finite or larger than 1e6 in absolute value stops the program with
  exit status 82 and no table.
- Initialization: xorshift32 (`x ^= x<<13; x ^= x>>17; x ^= x<<5`, 32-bit) seeded with the seed.
  Each parameter is `(rng mod 33 - 16) / 64`, one draw per parameter, in this order:
  - arms 0 and 3: a, b, v, c;
  - arm 1: `A[j][k]` with j (input) outer and k (position) inner, index `j*4+k`, then `b_0..b_3`,
    then `v_0..v_3`, then `c_0..c_3`.
- Arithmetic: IEEE binary64, one operation per word, no fused multiply-add. `u_k` of arm 1 is
  summed as `b_k`, then j = 0, 1, 2, 3.
- Nothing is tuned. No seed, mask, epoch count, learning rate, order or threshold is chosen after
  seeing an outcome.

## 5. Grid

4 arms x 3 seeds x 4 masks = 48 runs, printed arm-major, then seed, then mask:

- arms 0, 1, 2, 3
- seeds 17, 29, 43
- masks 65535, 38505, 39321, 42405

Every run evaluates all 16 IDs after training, each through sender, wire byte and receiver.

## 6. Acceptance criteria (verbatim)

- P1 arm 0: on every seed and mask, all trained IDs accepted-correct, all held-out IDs accepted-correct (8/8 where there is a held-out set), zero wrong-accepted, zero abstentions.
- P2 arm 1: on masks 39321 and 42405, held-out accepted-correct is below 8 on every seed.
- P3 arm 2: 16/16 and 8/8 everywhere.
- P4 arm 3: full-fit accepted-correct against true targets is below 16 on every seed.
- P5 determinism: the AArch64 build (under qemu-aarch64-static) and the native x86-64 build print byte-identical result tables.
- P6 lemma check, executable: in arm 1 on masks 39321 and 42405, for each k the difference A[p][k]-A[q][k] between the two always-equal inputs (p,q = 0,1 for 39321; 0,2 for 42405) after training equals its value at initialization within 1e-9 in absolute value; print the largest drift. Its control: on mask 65535 the largest drift must exceed 1e-3 on at least one seed.

NL8 passes only if all six hold. A criterion that fails is reported as failed, with its numbers.
The criteria are not edited.

## 7. How the program computes each criterion (fixed now)

Row columns, TAB separated: `arm seed mask trained_ok trained_n heldout_ok heldout_n wrong_accepted
abstained wire_bits max_drift`.

- `trained_ok` / `trained_n`: accepted-correct trained IDs / trained IDs. `heldout_ok` /
  `heldout_n`: the same for held-out IDs. `wrong_accepted` and `abstained` count over all 16 IDs.
  In arm 3 all of these are against the true targets.
- `wire_bits`: measured, not declared. The number of bit positions of the wire byte (of 8) that
  take both values over the 16 evaluated IDs. A collapsed channel shows 0; a full 4-bit code shows 4.
- `max_drift`, arm 1 only (other arms print `NA`): with
  `drift(p,q) = max over k of |(A[p][k]-A[q][k]) after training - (A[p][k]-A[q][k]) at init|`,
  mask 39321 prints `drift(0,1)`, mask 42405 prints `drift(0,2)`, masks 65535 and 38505 print
  `max(drift(0,1), drift(0,2))`. Printed with 6 significant digits, truncated, as `d.ddddde-XX`.
  The comparisons of P6 use the binary64 value, not the printed text.
- P1: every one of the 12 arm-0 rows has `trained_ok == trained_n`, `heldout_ok == heldout_n`,
  `wrong_accepted == 0` and `abstained == 0`.
- P2: each of the 6 arm-1 rows with mask 39321 or 42405 has `heldout_ok < 8`.
- P3: every one of the 12 arm-2 rows has `trained_ok == trained_n` and `heldout_ok == heldout_n`.
- P4: "full-fit" is the mask-65535 run, as in the NL1R result table. Each of the 3 arm-3 rows with
  mask 65535 has `trained_ok + heldout_ok < 16`. The other arm-3 rows are printed and reported but
  are not part of P4.
- P5: a result table is the header line plus the 48 rows. `nl8 table` prints exactly that.
  `nl8 all PEER` builds its own table, reads the file PEER (the other build's `nl8 table` output)
  and compares the two byte for byte. `nl8 all` without PEER cannot establish P5 and prints
  `P5 FAIL` (no pass is reported for a comparison that was not made). P5 holds when
  `nl8 all PEER` prints `P5 PASS` on both builds, each given the other build's table.
- P6: lemma part: each of the 6 arm-1 rows with mask 39321 or 42405 has `max_drift <= 1e-9`.
  Control part: the largest `max_drift` of the 3 arm-1 rows with mask 65535 is `> 1e-3`. P6 holds
  when both parts hold.

`nl8 all` prints the table, then one line per criterion (`P1 PASS` or `P1 FAIL <detail>`), then
`NL8 PASS` or `NL8 FAIL`; exit status 0 or 1. Bad arguments exit 2.

## 8. Checks and negative controls fixed in advance

Gradient self-check, `nl8 grad SEED`: for arm 0 and arm 1 with the quantizer removed (`s_k`
replaced by `h_k`, so the straight-through step is an exact derivative), the hand-written gradient
is compared with central differences (step 1e-6) of the loss, for every parameter and all 16 IDs
with true targets. The point is the seeded initialization plus a small fixed offset per parameter
(arm 0: parameter i gets `2^i * 1e-4`; arm 1: parameter i gets `2^(i div 4) * 1e-4`). The offset
keeps every `u_k` at least 1e-4 away from 0, where softsign has a kink in its second derivative and
a central difference is off by about the step. The largest absolute difference must be below 1e-7
for both arms.

Mutants are built with `subst.om`, which replaces exactly one occurrence of a text and refuses zero
or several matches.

- M1 "ste-cut": the straight-through path is cut, so the sender receives zero gradient
  (`ret gste` becomes `ret mul 0.0f64 gste`). Predictions, written before any run:
  - `grad`: FAIL. The sender entries of the hand-written gradient are zero, the central differences
    are not.
  - `all`, arm 0: the sender stays at its initial a and b. From the xorshift draws (mod 33: seed 17
    gives 0, 32; seed 29 gives 0, 24; seed 43 gives 18, 29) the initial (a, b) are (-16/64, 16/64),
    (-16/64, 8/64) and (2/64, 13/64). Seeds 17 and 43 send the same byte, 15, for every ID
    (`a+b >= 0` and `b-a >= 0`), so no row of those seeds can have every ID accepted-correct and
    their `wire_bits` is 0. Seed 29 sends the inverted bits, which a receiver can still decode, so
    its rows are expected to pass with `wire_bits` 4. Expected line:
    `P1 FAIL` with 8 bad rows, first at seed 17, mask 65535.
  - P6: the untied sender matrix never moves, so every drift is exactly 0; the lemma part holds
    trivially and the control part fails. Expected `P6 FAIL`.
  - P3 and P5 are unaffected (PASS). P2 and P4 are expected to stay PASS (lower confidence).
    Expected last line `NL8 FAIL`, exit 1.
- M2 "slope": a wrong derivative (`ret div 1.0f64 mul d d` becomes `ret div 1.0f64 d`, that is
  `1/(1+|t|)` in place of `1/(1+|t|)^2`). Prediction: `grad` FAIL. Only the gradient check is run
  for M2.
- P5 control: `nl8 all PEER` with a peer table in which one byte was changed must print `P5 FAIL`
  and `NL8 FAIL`, exit 1.
- `subst` controls: a FROM text with no match, and one with several matches, must each exit 1 and
  write no output file.
- P2 and P4 are themselves the negative controls of P1: the same code with the tying removed, and
  the tied code with wrong targets, must not pass.

## 9. Threats noted in advance

- P2 can fail by luck. On a correlated mask the untied sender's `A[p][k]-A[q][k]` stays at its
  initial value. If that value happens to have the right sign for both tied-together positions and
  to outweigh the other weights of its column, a run reaches 8/8 without having learned which input
  to follow. If that happens it is reported as a P2 failure.
- The 16-ID domain is tiny. Nothing here is a statement about real models.
- P5 compares two builds of one compiler family on one machine (one of them under emulation). It is
  not a statement about other hardware.
