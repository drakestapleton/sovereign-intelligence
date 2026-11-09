# READY: Plumbline, for the Radicle desk

A hand-off, not an approval. It asks the publishing lane to open one patch and the desk to gate it. Nothing here was pushed to Radicle, nothing is deployed, and no domain was touched.

## What to open

| Field | Value |
|---|---|
| Repository | sovereign-intelligence, `rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj` |
| Base | Radicle `main`, `a32ff45c22733e961264697a48ed5d39305717c6` |
| Change | adds the directory `plumbline/`; changes no existing file |
| Head | one commit on that base; its id is in the hand-off message that carries this file, with a git bundle |
| Also on GitHub | draft, do-not-merge: `drakestapleton/sovereign-intelligence` pull request 10, based on GitHub `main` |

To open the patch from the bundle, on a machine with a Radicle node:

```sh
rad clone rad:z2JJz4RDfZZxKGBLn6UhmW5p9VJQj && cd sovereign-intelligence
git fetch /path/to/plumbline.bundle plumbline:plumbline
git log --oneline -1 plumbline          # compare with the id in the hand-off message
git push rad plumbline:refs/patches
```

## Why it was not pushed from where it was built

The build sandbox cannot speak Radicle's peer protocol. Measured on 2026-11-09: direct TCP to the public seeds' peer port (58776, and 8776) is blocked; the sandbox's web proxy does open a tunnel to them, but carrying the peer protocol through it was refused by the sandbox's own safety rule, and that refusal was not worked around. Radicle has no write path over HTTPS. Radicle 1.10.3 was installed and verified against its published sha256 (`3d78e3ff…6751`), so the only missing piece is a route.

## One thing to reconcile first

GitHub `main` (`b4a96b1`) and Radicle `main` (`a32ff45`) of this repository have diverged since `486e918`: the merge-queue work (`tools/flow.om` and its tests) is only on GitHub, and `a32ff45` "SI links: refresh vetted heads from RIDS.md" is only on Radicle. `seed/` and `stack/` are identical on both, and `sh build.sh` gives the same two compilers on both (omc `45442c7d…080d`, omc-x86 `5e1f6e1f…3f19`). Plumbline reads `repos.tsv` and `README.md`, which differ between the two, so the generated site differs by base; the gate passes on each.

## How it was gated

```sh
sh build.sh && sh plumbline/gate.sh
```

on an x86-64 Linux host, AArch64 programs under qemu-aarch64 (user mode), x86-64 programs native. Status of everything below: HOST_TESTED. Nothing ran on a GPU, in a model or in a serving path.

The gate's own output on each base is the evidence; the hand-off message quotes both runs in full. Each step and its control:

| Step | What must hold | Control that must fail |
|---|---|---|
| H1 | the site generator, built for both targets, writes byte-identical sites | n/a (H2 and H3 are its controls) |
| H2 | bad inputs are refused and nothing is written | wrong ledger total; README without a needed section; registry without a table; `http://` address; a hostile project description must come out escaped |
| H3 | the independent verifier passes the generated site and its own fixtures | a copy of the site with one planted violation; two mutants of the verifier with a rule removed |
| W1 | the wire codec's selftest reproduces its recorded output on both targets | every refusal fixture exits with its code; two mutants of the codec |
| N1 | the Neuralese experiment reproduces its recorded table and verdicts | a tampered peer table; a build with the gradient path cut; a wrong derivative |
| L1 | every Lean file checks with no `sorry` and only standard axioms | `proofs/control/Unproved.lean` must be flagged |

## What the reviewer should know before reading

- **The Neuralese experiment's own verdict is FAIL.** One of six pre-registered criteria (P2) failed and is reported as failed, in its notes and on the site. The gate step N1 passing means "the recorded result reproduces", not "the experiment passed".
- **The forge's repository count is not stated** in this build, because the registry it is counted from is not in the repository. An earlier draft printed the number of projects in `repos.tsv` (83) as that count; the live forge says 30. That was wrong and is fixed: the count is read from the registry's first table when the build is given one.
- **Facts the Rust generator read from the Radicle HTTP API are dropped** (open patch and issue counts, last merged patch, delegate tag, latest change title). The pages link to the patches and issues pages instead.
- **`ipo1` is PROPOSED**, a text encoding of the existing envelope. It is not part of the protocol's specification.
- **The site's invitation to outside builders is labelled PLANNED.** No intake runs.

## NOT_RUN

- Radicle: no patch opened, `tools/flow` not run on it.
- Deployment: none. `scripts/sync-to-hub.sh` of the interplane.io repository is untouched; switching it to this generator is a separate change that needs the owner's say.
- Native AArch64 hardware: every AArch64 result here is under qemu user mode.
- Browsers other than Chromium; screen readers.
- A token count under a real model's tokenizer for `ipo1`: only bytes were measured.
