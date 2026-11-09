# NL8: a tied sender and receiver trained through a 4-bit wire

A small pre-registered experiment in Omega. A sender turns a 4-bit ID into one byte, a receiver
turns that byte back into four bits, and both are trained together. The question: does a model whose
weights are the same for every bit position recover IDs it never saw in training, where earlier
learned models scored 0 of 8?

**Result: NL8 FAIL.** One of six pre-registered criteria, P2, failed. The numbers are in
[`RESULTS.md`](RESULTS.md). The plan, written before the first run, is in [`PREREG.md`](PREREG.md).

## What failed before

The earlier experiments are frozen in `/home/user/aien-train/native/neuralese`. The line numbers
below were read in that checkout on 2026-11-09.

- **NL1.** `README.md` line 8 records the learned model as FAIL: it "does not reach all-16 training
  reconstruction and does not beat the fixed or discrete controls". The table at lines 48 to 54 gives
  the learned arm 5/8, 5/8, 6/8 on the held-out parity IDs and the discrete byte 8/8, 8/8, 8/8.
  Line 56 gives the learned full fit as 14/16 on every seed. Line 109 gives a reason for the 14/16:
  four affine thresholds in three real dimensions give at most 15 strict patterns, and 16 are needed.
- **NL1R.** `nl1r/README.md` line 29 describes 48 runs: four arms, seeds 17, 29, 43, masks 65535,
  38505, 39321 and 42405. In the table at lines 33 to 38 every learned arm (affine 3, affine 4,
  nonlinear) scores 0/0/0 on the held-out IDs of masks 39321 and 42405, and the direct byte scores
  8/8/8. Line 40 says that four coordinates remove the capacity obstruction and reach 16/16 on the
  full fit "but do not yield reliable heldout combination recovery". The zeros were checked against
  `nl1r/evidence/public-metrics.json`: the 18 records with arm 0 to 2, mask 39321 or 42405, `q` 0 and
  `subset` 2 all have `acceptedCorrect` 0, and the 6 records of arm 3 have 8.
- **How those models were built.** In `nl1r/capacity.om` the sender (`nsend`, lines 76 to 86) gives
  every message coordinate its own weight for each of the four inputs and its own bias, and the
  receiver (`nrecv`, lines 97 to 118) lets every output read every coordinate. Nothing ties the bit
  positions together. The training loop (`ntrain`, lines 208 to 227) calls `nsend` and then `nrecv`
  directly, so the receiver trains on real-valued coordinates; no quantizer is in the loop.
  `nl1r-task/README.md` line 11 says of its one-byte channels that they are inference-time ablations
  of a continuously trained model and "Neither uses a straight-through gradient".
- **NL7.** `README.md` lines 127 to 133: hand-built codes reach 16/16 and 8/8; the learned arms reach
  at most 15/16 on the full fit and between 0/8 and 6/8 held out. Its verdict at lines 203 to 205:
  recoverability "can be guaranteed by an explicit finite code; this experiment does not establish a
  successful learned language".

In short: the four-coordinate model fits all 16 IDs when it is trained on all of them, and on the
two correlated masks every learned arm got none of the unseen IDs right. A hard-coded byte got all
of them right.

## What NL8 changes

1. **Tied weights.** The sender uses the same two numbers `a`, `b` for every bit position
   (`u_k = a*(2*x_k-1) + b`), the receiver the same two numbers `v`, `c`. Four parameters in total.
   This is the prior under test: position-equivariance.
2. **A real discrete wire, in training too.** Each position sends one bit. The four bits are packed
   into one byte, and the receiver reads that byte and nothing else, in training and in evaluation.
3. **A straight-through estimator.** A 1-bit quantizer has no useful derivative. The backward pass
   hands the receiver's gradient to the sender as if the quantizer were the identity (`ste`,
   `nl8.om` line 181).
4. **An untied arm as the control.** The same code with a full 4x4 sender matrix and per-position
   receiver weights (28 parameters), same data, seeds, optimizer and steps.
5. **Two more arms.** A byte arm with no training (the ID is the byte) and a tied arm trained on
   shuffled targets.

Seeds, masks, learning rate, epoch count, initialization rule, loss and the abstention rule are those
of NL1R. Inputs are coded as -1 and +1 here; NL1R used 0 and 1 (`nl1r/capacity.om` line 72).

## What it shows

- **The tied arm recovers every unseen ID.** 16/16 trained and 8/8 held out on every seed and mask of
  the grid, no wrong answer accepted, no abstention, all 4 wire bits in use (P1 PASS). In the post hoc
  sweep it reaches 8/8 held out on 64 of 64 seeds on both correlated masks.
- **The discrete channel can be trained through.** With the straight-through path cut (mutant M1) the
  tied arm passes only where the initial sender already sends a usable code: 4 of 12 grid rows, and 42
  of 64 seeds in the sweep. Uncut it passes on all of them.
- **Without the prior, the held-out result is fixed by initialization.** On a correlated mask two
  inputs are always equal in training. The untied sender's weights for those two inputs receive the
  same gradient at every step, so their difference stays where the random initialization put it:
  it moved by at most 2.1e-14 in the grid (P6 PASS) and at most 3.5e-14 over 64 seeds. That
  difference is what decides the unseen IDs. So the untied arm's held-out score varies with the seed:
  in the grid it is 0, 4, 0 on mask 39321 and 8, 8, 0 on mask 42405.
- **P2 failed.** It was pre-registered that the untied arm stays below 8/8 on both correlated masks on
  every seed. Two of six runs reached 8/8. They did so with a weight difference that never moved, so
  the 8/8 was not learned. The criterion still failed and is reported as failed.

## What it does not show

- **It does not show a learned language for real models.** The task has 16 IDs and the tied model has
  4 parameters. The tied model can only apply one map to every position, and the task is the same map
  at every position. The prior fits the task by construction. That makes this toy identifiable; it
  says nothing about what prior, if any, would do the same for real activations.
- It does not show that the untied model always fails, or how often it succeeds in general. The sweep
  counts 6 of 64 and 12 of 64 seeds; it is post hoc, and 64 seeds are not a population estimate.
- It does not show that a straight-through estimator is a good gradient. The gradient check covers
  the model without the quantizer only.
- It makes no claim about capacity, compression, noise, cost, energy, other optimizers or schedules,
  or other hardware. Both builds come from one compiler family on one machine, one under emulation.

## Files

| File | What it is |
|---|---|
| `PREREG.md` | The pre-registration. Frozen; sha256 `09f27e8bfb6784c774232d42a05a2e8ef81596f6b944dc87222caf580e84bd5b`. |
| `nl8.om` | Model, training, evaluation, criteria, gradient check, post hoc sweep. |
| `main.om` | `fn main`. The program is `nl8.om` followed by `main.om`. |
| `subst.om` | Replaces exactly one occurrence of a text in a file; used to build the mutants. |
| `expected.tsv` | The exact stdout of `nl8 all`. |
| `expected-peer.tsv` | The exact stdout of `nl8 all PEER`, PEER being the other build's `nl8 table` output. |
| `sweep.txt` | The exact stdout of `nl8 sweep`. Post hoc. |
| `RESULTS.md` | Observed table, verdicts, mutants, controls, deviations. |

## Program

```
nl8 ARM SEED MASK   one row of the grid (ARM 0..3, SEED 1..4294967295, MASK 1..65535)
nl8 table           header and the 48 rows
nl8 all             the table, one line per criterion, then NL8 PASS or NL8 FAIL; exit 0 or 1
nl8 all PEER        the same, with P5 decided by comparing the table with the file PEER
nl8 grad SEED       gradient check without the quantizer; GRAD PASS or GRAD FAIL; exit 0 or 1
nl8 sweep           POST HOC: seeds 1..64 on masks 39321 and 42405, arms 0 and 1
```

Bad arguments exit 2. Table lines contain TABs; verdict lines contain none. `nl8 all` without PEER
prints `P5 FAIL no peer table given (run: nl8 all PEERFILE)`: it does not report a comparison it did
not make.

## Build and run

Compilers and their use are described in `/home/user/omc-bin/README.txt`. Do not run
`sovereign-intelligence/build.sh`. Never run the output of a compile that did not exit 0.

```sh
cd /home/user/sovereign-intelligence/plumbline/neuralese/nl8
mkdir -p /tmp/nl8-scratch/final

cat nl8.om main.om | qemu-aarch64-static /home/user/omc-bin/omc > /tmp/nl8-scratch/final/nl8-a64; echo "compile $?"
{ printf 'target x86linux\n'; cat nl8.om main.om; } | /home/user/omc-bin/omc-x86 > /tmp/nl8-scratch/final/nl8-x86; echo "compile $?"
chmod +x /tmp/nl8-scratch/final/nl8-a64 /tmp/nl8-scratch/final/nl8-x86

qemu-aarch64-static /tmp/nl8-scratch/final/nl8-a64 all > /tmp/nl8-scratch/final/all-a64.txt; echo "exit $?"
/tmp/nl8-scratch/final/nl8-x86 all > /tmp/nl8-scratch/final/all-x86.txt; echo "exit $?"
cmp /tmp/nl8-scratch/final/all-a64.txt expected.tsv; echo "cmp $?"
cmp /tmp/nl8-scratch/final/all-x86.txt expected.tsv; echo "cmp $?"
```

Expected: both compiles print `compile 0`, both runs print `exit 1` (NL8 FAIL), both `cmp` lines print
`cmp 0`. Run time is about 1 second natively and 2 seconds under qemu.

P5, each build given the other build's table:

```sh
qemu-aarch64-static /tmp/nl8-scratch/final/nl8-a64 table > /tmp/nl8-scratch/final/t-a64.tsv; echo "exit $?"
/tmp/nl8-scratch/final/nl8-x86 table > /tmp/nl8-scratch/final/t-x86.tsv; echo "exit $?"
qemu-aarch64-static /tmp/nl8-scratch/final/nl8-a64 all /tmp/nl8-scratch/final/t-x86.tsv > /tmp/nl8-scratch/final/allp-a64.txt; echo "exit $?"
/tmp/nl8-scratch/final/nl8-x86 all /tmp/nl8-scratch/final/t-a64.tsv > /tmp/nl8-scratch/final/allp-x86.txt; echo "exit $?"
cmp /tmp/nl8-scratch/final/allp-a64.txt expected-peer.tsv; echo "cmp $?"
cmp /tmp/nl8-scratch/final/allp-x86.txt expected-peer.tsv; echo "cmp $?"
```

Expected: the two `table` runs exit 0, the two `all` runs exit 1, both `cmp` lines print `cmp 0`, and
both outputs contain the line `P5 PASS`.

Gradient check and sweep:

```sh
qemu-aarch64-static /tmp/nl8-scratch/final/nl8-a64 grad 17; echo "exit $?"
/tmp/nl8-scratch/final/nl8-x86 grad 17; echo "exit $?"
qemu-aarch64-static /tmp/nl8-scratch/final/nl8-a64 sweep > /tmp/nl8-scratch/final/sweep-a64.txt; echo "exit $?"
/tmp/nl8-scratch/final/nl8-x86 sweep > /tmp/nl8-scratch/final/sweep-x86.txt; echo "exit $?"
cmp /tmp/nl8-scratch/final/sweep-a64.txt sweep.txt; echo "cmp $?"
cmp /tmp/nl8-scratch/final/sweep-x86.txt sweep.txt; echo "cmp $?"
```

Expected: both `grad` runs print the same three lines ending `GRAD PASS` and `exit 0`; both sweeps
exit 0 and both `cmp` lines print `cmp 0`. The sweep takes about 4 seconds natively and 10 under qemu.

## Mutants

`subst IN OUT FROM TO` copies IN to OUT with exactly one occurrence of FROM replaced by TO. It exits 1
and writes no file when FROM occurs zero times or more than once. Exit 2 is a bad argument, 3 an
unreadable input, 4 an output that could not be written.

```sh
{ printf 'target x86linux\n'; cat subst.om; } | /home/user/omc-bin/omc-x86 > /tmp/nl8-scratch/final/subst; echo "compile $?"
chmod +x /tmp/nl8-scratch/final/subst

/tmp/nl8-scratch/final/subst nl8.om /tmp/nl8-scratch/final/m1.om "ret gste" "ret mul 0.0f64 gste"; echo "exit $?"
{ printf 'target x86linux\n'; cat /tmp/nl8-scratch/final/m1.om main.om; } | /home/user/omc-bin/omc-x86 > /tmp/nl8-scratch/final/m1-x86; echo "compile $?"
chmod +x /tmp/nl8-scratch/final/m1-x86
/tmp/nl8-scratch/final/m1-x86 all; echo "exit $?"
/tmp/nl8-scratch/final/m1-x86 grad 17; echo "exit $?"

/tmp/nl8-scratch/final/subst nl8.om /tmp/nl8-scratch/final/m2.om "ret div 1.0f64 mul d d" "ret div 1.0f64 d"; echo "exit $?"
{ printf 'target x86linux\n'; cat /tmp/nl8-scratch/final/m2.om main.om; } | /home/user/omc-bin/omc-x86 > /tmp/nl8-scratch/final/m2-x86; echo "compile $?"
chmod +x /tmp/nl8-scratch/final/m2-x86
/tmp/nl8-scratch/final/m2-x86 grad 17; echo "exit $?"

/tmp/nl8-scratch/final/subst nl8.om /tmp/nl8-scratch/final/none.om "ret gsteXYZ" "x"; echo "exit $?"
/tmp/nl8-scratch/final/subst nl8.om /tmp/nl8-scratch/final/many.om "ret 0" "ret 1"; echo "exit $?"
```

Expected: M1 `all` prints `P1 FAIL bad_rows=8 first_seed=17 first_mask=65535` and `NL8 FAIL`, exit 1;
M1 and M2 `grad 17` print `GRAD FAIL`, exit 1; the last two `subst` lines print
`SUBST REFUSED matches=0` and `SUBST REFUSED matches=18`, exit 1, and leave no file. The same steps
work for the AArch64 build with `qemu-aarch64-static /home/user/omc-bin/omc < file` in place of the
x86-64 compile line. Write a mutant to a scratch path, never over `nl8.om`.
