# Plumbline

**One agent's version of the INTERPLANE hub, written in Omega and built by the compiler this repository grows from 408 hand-written bytes.**

Plumbline is a named, self-contained version of the work, kept in its own directory so that it can be compared and combined with another version built in parallel. It is not deployed anywhere, and nothing in it touches a domain.

A plumb line is the string with a weight on it that builders use to check that a wall is true. This one drops through four planes, hardware, software, models and agents, and the same rule holds on each: a claim counts only with evidence on the exact revision.

## What INTERPLANE is for

The vision this version was built to, as Drake gave it: INTERPLANE is the place for everybody's space junk to go. The builds that didn't quite work right but have a piece in them that will help somebody else. A welcoming home for builders making slop, where it is taken into the network and turned into something functional, verifiable and replicable.

The overview page of the site says that first. The way through is the verification rule the protocol already has: bring it as it is, pin the exact revision, find the piece whose checks pass while a known bad input fails them, and hand it on with its evidence. An open intake for outside builders is **PLANNED**; it does not run today, and the site says so.

## What is here

| Path | What it is | Status |
|---|---|---|
| [`hub/`](hub/) | the site generator: one Omega program that writes every page, the stylesheet and the picture from this repository's own tables | HOST_TESTED on AArch64 (under qemu) and native x86-64; byte-identical output |
| [`hub/check/`](hub/check/) | the site verifier: an independent Omega program that judges an output directory (no executable script, no outside request, every link and anchor resolves) | HOST_TESTED, both targets |
| [`wire/`](wire/) | `ipo1`, the INTERPLANE Omegese form: a lossless text form of the protocol's JSON envelopes in which known shapes need no keys | HOST_TESTED, both targets; PROPOSED as an encoding, not part of the protocol's specification |
| [`neuralese/nl8/`](neuralese/nl8/) | a pre-registered experiment on why the learned code failed and what repairs it | HOST_TESTED; **the experiment's own verdict is FAIL**: one of six pre-registered criteria failed |
| [`proofs/`](proofs/) | Lean 4 proofs of the mathematics the rest relies on, each with its axiom list and a negative control | checked with Lean 4.35.0, core library only |
| [`gate.sh`](gate.sh) | compiles and runs all of the above on both targets and compares with the recorded outputs | see below |

Nothing here ran on a GPU, inside a model or in a serving path.

## Check it yourself

```sh
sh build.sh                 # grows the compiler from the seed; ends with RC=0
sh plumbline/gate.sh        # ends with RC=0 not_run=N
```

`gate.sh` prints one PASS, FAIL or NOT_RUN line per step and stops at the first FAIL. NOT_RUN is never counted as a pass: on a machine without Lean, or without a way to run one of the two instruction sets, those steps say NOT_RUN and the last line counts them.

To look at the site, serve `out/plumbline/site-a64/` from the root of any static file server. It makes no request to anywhere else.

## The rules it was built under

- Everything that computes is Omega, compiled by the seed-grown `omc`. There is no Rust, Python or JavaScript in the path, no template files and no image files. `gate.sh` only compiles, runs and compares.
- Every number on a page is read from a file of this repository at build time and named with its source. Claims with evidence labels are rendered from the README's own tables, never retyped.
- A build that cannot stand behind its inputs refuses and writes nothing.
- Each check has a control that must fail, and the gate runs it.
- A failed criterion is printed as failed. The Neuralese experiment's is on the site, in red.

## What is not done

- **Not on Radicle yet.** This directory was built in a sandbox that cannot reach Radicle's peer port. [`READY.md`](READY.md) is the hand-off: base, head, how it was gated and the one command that opens the patch.
- **Not deployed.** No page of it has served a visitor.
- **The forge's repository count is not stated**, because the registry it is counted from is not in this repository. Given the registry file, the generator prints the count.
- **`ipo1` is text only**, refuses numbers with a fraction or exponent, and carries no signature. A valid frame is never an authorization.
- **The Lean proofs are about models.** Each file says how its model is tied to the running program and where that tie is only a test.
- Checked in one browser engine at two widths. No screen reader, no other browser.
