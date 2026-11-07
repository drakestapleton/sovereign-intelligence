# Agent prompt: replicate the GB10 / Omega / CUDA++ work from Radicle

Paste this whole file into any coding agent (Claude, GPT, Gemini, a local model, or a person with a shell). It is self-contained. It tells you what to fetch, what to run, what output to expect, what you may claim, and how to report.

Replicate on your machine (clean userspace, no CUDA toolkit, no sudo): `curl -fsSL https://www.aienos.com/replicate | sh`

Let your own local model drive it: `curl -fsSL https://www.aienos.com/replicate | sh -s -- --agent` (or set AIEN_MODEL_URL / AIEN_MODEL). Other options: --chip, --corpus, --yes.

The work being replicated: Drake Stapleton's independently implemented GPU machine-code toolchain for the NVIDIA GB10 (DGX Spark, sm_121). It has four parts:
- Omega, a language whose compiler `omc` grows from 408 hand-written bytes;
- an sm_121 instruction encoder written in Omega;
- CUDA++ (repository CUDApp), a runtime that talks to NVIDIA's open kernel module through ioctls without libcuda;
- receipts from runs on the chip.

Paper: "Reverse Engineering the CUDA Software Stack: An Independently Implemented GPU Machine-Code Toolchain for the NVIDIA GB10", preprint (not peer reviewed), DOI [10.5281/zenodo.23677465](https://doi.org/10.5281/zenodo.23677465).

---

## 0. Rules you follow for the whole job

### 0.1 Stop and report on any mismatch
Every step below has a **Success** line. If what you see differs from it, **stop**. That covers:
- a different hash;
- a different count;
- a non-zero exit where zero is expected, or zero where non-zero is expected;
- a missing file.

Do not retry with changes, patch files, or "work around" anything. Write the report from section 9, with the step number, the exact command, its exit code and the first differing output line. Then wait for the human.

You may only continue past a mismatch when the step itself says the difference is expected. Example: commit heads may move forward; the steps pin exact commits for that reason.

### 0.2 Evidence labels (what a result IS)
Use exactly one per result:

| Label | Meaning |
|---|---|
| SIMULATED | Ran on a model or simulator of the chip (e.g. `hello_gpu --sim`, the host warp simulator). |
| HOST_TESTED | Ran on a CPU host; no GPU involved (compiler rebuilds, encoder byte diffs, table checks). |
| EMULATED | Ran under an emulator (e.g. QEMU) of the target machine. |
| CHIP_TESTED | Ran on a real GB10 and a receipt (log with exit code, hashes, counts) was kept. |
| DEPLOYED | Served real traffic on the chip, on a stated date. |
| NOT_RUN | Not executed. **NOT_RUN is not PASS.** A skipped step, a missing tool, or a target that printed `NOT_RUN` never counts as success. |

When you only re-checked someone else's receipt (hashes and quoted lines), say "receipt verified (HOST_TESTED)". That is not "CHIP_TESTED by me".

### 0.3 Lifecycle words (how far a piece of work got)
These are separate from the labels; never mix them up:
- PROPOSED: written down;
- IMPLEMENTED: code exists;
- EXERCISED: it ran;
- QUALIFIED: passed a predeclared gate for production use;
- MERGED: on the default branch;
- DEPLOYED: in service.

The Omega encoder is IMPLEMENTED, EXERCISED, CHIP_TESTED and MERGED to CUDApp main. It is **not QUALIFIED** for serving.

### 0.4 Every claim needs a negative control
A check that cannot fail proves nothing. For each claim, run or cite a control that **must fail**, and show that it fails:
- a mutated compiler source gives a different compiler hash;
- one flipped encoder bit breaks the byte diff;
- a planted kernel bug makes the chip run FAIL;
- a tampered receipt fails its checksum.

The steps below include these controls. If a control passes when it should fail, that is a mismatch: stop.

### 0.5 Never claim beyond the receipts
Say only what a receipt in these repositories shows, with its path. **Banned claims.** Do not write these, or anything that means the same:
1. "I replaced CUDA", "CUDA is dead", "drop-in replacement".
2. "No NVIDIA software at all". NVIDIA's open kernel module (`nvidia.ko`, `nvidia-uvm.ko`, 580.173.02) and NVIDIA's signed GSP firmware are still in the path. nvcc 13.0.88 and nvdisasm were used offline as oracles.
3. "Omega compiles end to end with no C". Register allocation, kernel builders and parts of the runtime are still C.
4. "Works on any NVIDIA GPU" or "RTX". Only the GB10 (sm_121) has chip receipts. The Ampere sm_86 encoder is NOT_RUN.
5. "Faster than CUDA", or tokens/s comparisons.
6. "115 TFLOPS" or "195 GB/s ceiling" style peak numbers.
7. "Clean-room".
8. "Signed chip receipts". They are hashed logs, not signatures.
9. "Serving with zero CUDA right now". The zero-CUDA serving receipt is dated 2026-10-21. It is a dated fact, not current state.
10. "Peer reviewed". The paper is a preprint.

### 0.6 Safety and legal
- Never change clocks, power, thermal or fan limits, and never flash firmware. Nothing here needs it.
- Do not redistribute NVIDIA binaries, firmware, cubins made by nvcc/ptxas, raw `nvdisasm`/`cuobjdump` dumps of nvcc output, or NVIDIA documents. Link to them instead.
- If you use NVIDIA's CUDA toolkit as an oracle (section 8), use your own licensed install. **Check your own obligations under the NVIDIA CUDA EULA** and the laws on interoperability where you are. This prompt is not legal advice.
- Chip steps (section 7) run on someone's real machine. Get the owner's permission first, and use one GPU job at a time (section 7.0).

---

## 1. Preflight (host)

You need a **Linux AArch64** host. The seed compiler emits AArch64 Linux ELF binaries and runs them, so an x86 host cannot run sections 3 to 5. Report them as NOT_RUN there, or move to an AArch64 machine. Any Linux AArch64 host should work, but the reference run used only the DGX Spark's own CPU. You also need `git`, `make`, `gcc`, `sh`, `sha256sum`, `cmp`, `sed`, `grep` and `awk`, and network access to `rosa.radicle.network`. No CUDA toolkit and no GPU are needed until section 7.

Run every step in a clean shell from one working directory. The reference run used `env -i HOME=<dir> PATH=/usr/bin:/bin R=<dir>/replica`. Set `R` once:

```sh
export R=$HOME/replica
```

**Step 1.1**
```sh
uname -sm; for t in git make gcc sh sha256sum cmp sed grep awk; do command -v $t >/dev/null || echo "MISSING $t"; done; echo preflight done
```
**Success:** `Linux aarch64`, no `MISSING` line, then `preflight done`.

---

## 2. Fetch everything from Radicle

Source: Drake's Radicle seed node `rosa.radicle.network` (node id `z6MkfZDue1TbaNFi3ZzcD9uiTeduPLC52ucdFVuLKZwexxhK`, alias `drake`). Three equivalent ways to get each repository:
- web view: `https://radicle.network/nodes/rosa.radicle.network/rad:<RID>`;
- peer to peer: `rad clone rad:<RID>` (needs the `rad` CLI);
- plain git over HTTPS, as used below: `git clone https://rosa.radicle.network/<RID>.git`.

| Name | RID | Role |
|---|---|---|
| CUDApp | `rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP` | CUDA++ runtime, ioctl driver client, sm_121 encoders (Omega and C), chip receipts |
| omega-mv | `rad:z6do9WDBhuSnvopDkgFdFr1yWA62` | Omega language and the seed chain that builds `omc` |
| omega-bridge | `rad:z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y` | Converts a bounded Omega subset to checked C; CUDApp's mutant controls use it |
| cuda-crack | `rad:z631r2JJiVT8it4tST7RK24hpowi` | The derived sm_121 instruction tables, the checker, and copies of the receipts |
| physics-mv | `rad:z49She8eifZpLd2aiSvk2pph3DMUo` | Earlier home of the `nvrm` driver client (history of the cache bug in 7.4) |
| omega-gpu-driver | `rad:z2xjD5kxUTTBNCryJ6rg9QXpemzei` | Own GB10 kernel driver: host, QEMU and simulator only; nothing has run on the GB10 |
| omega-blas | `rad:z47VdC9EFsF4dFyH1QJ1C2JNJK4JS` | BLAS work in Omega |

**Step 2.1: clone**
```sh
mkdir -p "$R" && cd "$R" && while read name rid; do git clone -q "https://rosa.radicle.network/$rid.git" "$name" || exit 1; echo "$name $(git -C "$name" rev-parse HEAD)"; done <<EOF
CUDApp z4RxD8vXigmWg61nM8miQ8DVPAXEP
omega-mv z6do9WDBhuSnvopDkgFdFr1yWA62
omega-bridge z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y
cuda-crack z631r2JJiVT8it4tST7RK24hpowi
physics-mv z49She8eifZpLd2aiSvk2pph3DMUo
omega-gpu-driver z2xjD5kxUTTBNCryJ6rg9QXpemzei
omega-blas z47VdC9EFsF4dFyH1QJ1C2JNJK4JS
EOF
```
**Success:** seven lines `<name> <40-hex head>` and exit 0. Heads may be newer than these reference values; that alone is not a mismatch, because step 2.2 pins exact commits.

Reference output (2026-11-07):
```text
CUDApp b774723f537cec16a359fe082b8100317a5b5490
omega-mv 6efc45728d5080b0fc5d74016a00ba8bbfcf9698
omega-bridge d8174eddf953ad53e16f19eb5841459df99e24bb
cuda-crack c17646e7bc4215aa413a8acfb66fa9dd3794062c
physics-mv 56d02ae50de6c6be46d6b23380eb7ec5edcca787
omega-gpu-driver 1ac3589c525657cf0698ff0f95557d922d2162ce
omega-blas e3f1b403839b1fc23d54c060c9c0c0c751774edd
```
If a clone fails (a node can be offline), use `rad clone rad:<RID>` (Radicle CLI) instead, or browse `https://radicle.network/nodes/rosa.radicle.network/rad:<RID>`.

**Step 2.2: pin exact commits**
```sh
cd "$R" && git -C CUDApp checkout -q b774723f537cec16a359fe082b8100317a5b5490 && git -C CUDApp rev-parse HEAD && git -C CUDApp merge-base --is-ancestor 010abb1549c48a4be6d63da47101d393f76cb2dd HEAD && echo "E2 receipt commit 010abb15 is inside CUDApp b774723f" && git -C cuda-crack checkout -q 043f993fab0b263eb0edd1a367fee8fee8f6a79b && git -C cuda-crack rev-parse HEAD && git -C omega-mv checkout -q 6efc45728d5080b0fc5d74016a00ba8bbfcf9698 && git -C omega-mv worktree add -q --detach ../omc-f4df8239 f4df82394e35893dcf1354dda69a2fe028d94bc1 && git -C omega-mv worktree add -q --detach ../omc-e5b32567 e5b32567a7aff3ce594e3254a622a846a6cd190b && git -C omega-bridge worktree add -q --detach ../bridge-6a8f0090 6a8f0090913283125f14871272f03d144a102d02 && echo "worktrees: omc-f4df8239 omc-e5b32567 bridge-6a8f0090"
```
**Success**, exit 0:
```text
b774723f537cec16a359fe082b8100317a5b5490
E2 receipt commit 010abb15 is inside CUDApp b774723f
043f993fab0b263eb0edd1a367fee8fee8f6a79b
worktrees: omc-f4df8239 omc-e5b32567 bridge-6a8f0090
```
Why two compiler pins:
- omega-mv `f4df8239` builds omc sha256 `3ad9f10f…`, which cuda-crack uses.
- omega-mv `e5b32567` builds omc sha256 `2c824805…`, which CUDApp `om/units.sh` pins for the encoder build and mutants.
- omega-bridge `6a8f0090` is the Radicle commit whose four files match the hashes CUDApp `om/units.sh` pins.

---

## 3. Rebuild the Omega compiler from seed (HOST_TESTED)

The seed chain starts from `seed/rung0/seed0.hex`: 408 bytes written by hand as hex words, with each AArch64 instruction cited to the Arm ARM. The chain is seed0 → hex1 → asm2 → om4 → omc. Each rung is built by the previous one, and omc must reach a fixpoint: omc built by omc equals itself. No C compiler is involved in this chain.

**Step 3.1: build at f4df8239**
```sh
cd "$R/omc-f4df8239" && sh seed/omega-from-seed.sh
```
**Success:** exit 0, and the output includes:

```text
PASS seed0 408 bytes, rebuilds itself
PASS hex1 776 bytes, born from seed0
PASS asm2 2464 bytes, born from hex1
PASS om4 om4.bin 14224 bytes
PASS omc fixpoint 3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194
PASS fwd exit 0
PASS fwd runs, exit 7
PASS mut exit 0
PASS mut runs, exit 0
PASS cycle exit 9
PASS assign exit 7
RC=0
```

**Step 3.2: hash, and compare with the committed binary**
```sh
cd "$R/omc-f4df8239" && sha256sum seed/out/omc && git diff --exit-code --stat seed/out/omc && echo "rebuilt omc is byte-identical to the committed one"
```
**Success:** exit 0 and
```text
3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194  seed/out/omc
rebuilt omc is byte-identical to the committed one
```

**Step 3.3: build at e5b32567**
```sh
cd "$R/omc-e5b32567" && sh seed/omega-from-seed.sh
```
**Success:** exit 0, output ends with `RC=0`, and it includes `PASS omc fixpoint 2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f`.

**Step 3.4**
```sh
cd "$R/omc-e5b32567" && sha256sum seed/out/omc && git diff --exit-code --stat seed/out/omc && echo "rebuilt omc is byte-identical to the committed one"
```
**Success:** exit 0, `2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f  seed/out/omc`, then the byte-identical line.

**Step 3.5: negative control A, one hand-written seed byte changed (must FAIL)**
```sh
cd "$R" && git -C omega-mv worktree add -q --detach ../omc-neg f4df82394e35893dcf1354dda69a2fe028d94bc1 && cd omc-neg && sed -i "s/^464c457f /464c457e /" seed/rung0/seed0.hex && git diff --stat && sh seed/omega-from-seed.sh
```
**Success = this step FAILS:** the exit status is non-zero (126 in the reference run), and the chain stops at its first rung:
```text
 seed/rung0/seed0.hex | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
seed/omega-from-seed.sh: 19: build/seed/birth/seed0.bin: Exec format error
```
The ELF magic byte is now wrong, so the kernel refuses to run seed0. If this step exits 0, the chain does not depend on the seed, and that is a mismatch.

**Step 3.6: negative control B, one compiler-source constant changed (must give a different compiler)**
```sh
cd "$R/omc-neg" && git checkout -q seed/rung0/seed0.hex && sed -i "s/^global out uchar 16777216\$/global out uchar 16777215/" seed/omc/omc.om && git diff --stat && sh seed/omega-from-seed.sh >/dev/null; sha256sum seed/out/omc; git diff --exit-code --stat seed/out/omc
```
**Success = this step FAILS:** the exit status is 1, and the rebuilt compiler has a different hash from the committed one:
```text
 seed/omc/omc.om | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
455a5d1f3d8621d7d03bf842aac30a46c57808493908c7b0e8a70c92cad9ad60  seed/out/omc
 seed/out/omc | Bin 625676 -> 625744 bytes
 1 file changed, 0 insertions(+), 0 deletions(-)
```
So the sha256 3ad9f10f… in step 3.2 really depends on the compiler source. The chain itself still prints `RC=0` here, because a changed constant is a valid program. The control is that the hash changes, not that the build fails.

---

## 4. The sm_121 instruction tables and the 70 chip kernels (cuda-crack, HOST_TESTED)

cuda-crack derives a table of sm_121 instruction forms from the Omega encoder. It then re-encodes, from those forms alone, all 70 kernels that ran on the chip in the E2 run, and requires every byte to match the chip-run hashes.

**Step 4.1: receipt copies intact.** Run this inside `receipts/`, because the paths in SHA256SUMS are relative to it.
```sh
cd "$R/cuda-crack/receipts" && sha256sum -c --quiet SHA256SUMS && echo "all $(wc -l < SHA256SUMS) receipt files match"
```
**Success:** exit 0, `all 148 receipt files match`. A later cuda-crack commit may add receipts; the count must equal `wc -l` of SHA256SUMS, with zero FAILED lines.

**Step 4.2: regenerate the tables**
```sh
cd "$R/cuda-crack" && OMC="$R/omc-f4df8239/seed/out/omc" sh gen/run.sh && git diff --exit-code --stat isa/ && echo "isa/ regenerated byte-identical"
```
**Success:** exit 0 and
```text
isa/sm121-forms.txt: 471 forms, sha256 587d81e2bc8b3dc6fdb48d477a76b717300732ccdb984f05f5b3df658e58e2d7
isa/ regenerated byte-identical
```

**Step 4.3: check the operand-field records, re-encode the chip kernels, plus four mutants that must be caught**
```sh
cd "$R/cuda-crack" && OMC="$R/omc-f4df8239/seed/out/omc" sh check/check.sh
```
**Success:** exit 0 and exactly these lines:
```text
== real tables: isa/sm121-forms.txt sha256 587d81e2bc8b3dc6fdb48d477a76b717300732ccdb984f05f5b3df658e58e2d7
D records vs F records: reencode exit 0
PASS: fields never overlap, field union = form mask, every width>0 field is exactly its bit span
kernels 70 instructions 13520 unmatched 0
PASS: all 70 rebuilt kernels match kernels-om.sha256 byte for byte
== mutant 1: bit 0 of word 0 flipped in every form that has the NOP's fixed bits and mask
mutated forms: 2
kernels 70 instructions 13520 unmatched 540 sha-mismatched kernels 67
PASS: mutant table caught
== mutant 2: bit 0 of word 0 flipped in the first instruction of the first kernel
reencode exit 4, instructions unmatched: 128 1
PASS: corrupted instruction matches no form
== mutant 3: width of the first D record with width > 1 reduced by one
reencode exit 7
PASS: wrong field width caught
== mutant 4: lowest bit cleared in the mask of the first D record with width > 0
reencode exit 7
PASS: wrong field mask caught
ALL CHECKS PASS
```
These lines are `check/CHECK.txt` at cuda-crack 043f993f. They were observed on the DGX Spark CPU on 2026-11-07, byte-identical to that file; `sh check/check.sh | diff - check/CHECK.txt` must print nothing. The clean-clone reference run pinned the earlier commit c17646e7, whose `check.sh` had no D-records stage and no mutants 3 and 4; it printed the same lines without those stages.

**Step 4.4: same encoder source in both repositories**
```sh
cmp "$R/cuda-crack/gen/bw_enc_sm121.om" "$R/CUDApp/om/encoder/bw_enc_sm121.om" && echo "cuda-crack gen/bw_enc_sm121.om == CUDApp om/encoder/bw_enc_sm121.om"
```
**Success:** exit 0 and the `==` line.

**Step 4.5: negative control, one byte appended to one receipt (must FAIL)**
```sh
cd "$R" && rm -rf neg-receipts && cp -r cuda-crack/receipts neg-receipts && printf x >> neg-receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-hello.log && cd neg-receipts && sha256sum -c --quiet SHA256SUMS
```
**Success = this step FAILS:** exit 1, with exactly one FAILED line naming `om-hello.log` and `WARNING: 1 computed checksum did NOT match`.

---

## 5. Omega encoder vs C encoder in CUDApp (HOST_TESTED)

CUDApp has two independent sm_121 encoders:
- `src/cudapp_om_bw_enc_sm121.c`, written in C;
- `om/encoder/bw_enc_sm121.om`, written in Omega.

Both must emit byte-identical machine code. These steps compile a large part of CUDApp three times. On one core this takes a long time (see the timings in the reference log); that is normal.

**Step 5.1: golden words and fixtures**
```sh
cd "$R/CUDApp" && make test-om-encoder
```
**Success:** exit 0, and the output includes:
```text
PASS: hosted golden-word fixtures through the .om encoder (0 failing checks)
encoder diff: .om and C byte-identical on 145 golden instructions and 14 fixture programs
red check: one flipped bit aborts the encoder diff, as it must
```
The last line is the built-in negative control: a planted flipped bit must make the diff abort. (The CUDApp README mentions an older golden count; 145 is what this commit prints.)

**Step 5.2: the whole kernel corpus, three builds**
This is the default `.om` build, the C build (`CUDAPP_ENCODER=c`) and a diff build that encodes every kernel both ways.
```sh
cd "$R/CUDApp" && make test-om-encoder-corpus
```
**Success:** exit 0 and the final corpus line below.
NOT_RUN in the reference run. The step was still running on one core when this file was published; its result will be added to this file in a later commit. The expected final line is `encoder corpus: 243 distinct kernels identical .om vs C; …, all SAME`; the 243 matches `host/corpus-k-om.sha256` in step 6.2. The reference run has not yet observed this line. If you run the step, report the real output and the exit status.
An earlier recorded run of this target is in cuda-crack at `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/host/corpus.log`; its last line is `encoder corpus: 243 distinct kernels identical .om vs C; diff build 559 program encodes and 32 single-instruction encodes, all SAME`. That is a receipt (HOST_TESTED earlier), not this reference run.

**Step 5.3: negative control, the mutant target without pinned tools must say NOT_RUN (never PASS)**
```sh
cd "$R/CUDApp" && make test-om-encoder-mutants
```
This step must not print PASS. In the reference run (exit 2) it did not print `NOT_RUN: set pinned OMEGA_OMC and OMEGA_BRIDGE`, because `mk/om-encoder.mk` defaults `OMEGA_OMC` and `OMEGA_BRIDGE` to sibling paths. Instead it built the C reference dump, then stopped at `make: *** [mk/om-encoder.mk:88: test-om-encoder-mutants] Error 1`. Success means no PASS line and a non-zero exit.

**Step 5.4: the mutants with pinned tools; every mutant must go red**
```sh
cd "$R/bridge-6a8f0090" && OMEGA_SOURCE="$R/omega-mv" sh tools/bootstrap.sh && sh tools/build.sh && cd "$R/CUDApp" && make test-om-encoder-mutants OMEGA_OMC="$R/omc-e5b32567/seed/out/omc" OMEGA_BRIDGE="$R/bridge-6a8f0090"
```
The first part rebuilds the bridge's own seed compiler from the audited hex rungs of omega-mv `29b12760`, read from your clone through `OMEGA_SOURCE`. The second part builds the bridge with that compiler. **Success:** exit 0, and the output includes:
```text
191b776ef98821597c3e30655da6d680a9b66edbc9ceaca3c39c61ea6df098e9  ../omc
bootstrap fixpoint RC=0
8608fa11f6a2cf1c50db22d871eef16b00d5bc719bc1a222cc3e456984ac5ebf  seed/omc/omc.om
mutant 1 red ('s/^ret or base shl rb o 1 16$/ret or base shl rb o 1 17/'): golden words FAIL, dump vs C DIFFERS
mutant 2 red ('s/^p = 262144$/p = 0/'): golden words FAIL, dump vs C DIFFERS
mutant 3 red ('s/^const NOPC ulong 1032192$/const NOPC ulong 1032193/'): golden words FAIL, dump vs C DIFFERS
```
If you skip the bridge build, the make target stops with `sha256sum: build/compiler.sha256: No such file or directory` and `rebuild required: tools/build.sh`. That result is NOT_RUN, never PASS. A line saying `MUTANT N SURVIVED` is a FAIL.

**Step 5.5: the hello kernel on the host warp simulator (SIMULATED)**
```sh
cd "$R/CUDApp" && make test-hello-sim
```
**Success:** exit 0 (about 2 minutes on one core), and the output ends with:
```text
clean-user cleanup tests: 23 passed, 0 failed (mocked commands only)
sh tests/dx/hello_sim_test.sh build/hello_gpu build/hello_gpu_control
PASS sim-pass (exit 0)
PASS sim-checks
PASS work-line
PASS hashes-printed
PASS same-bits-twice
PASS fault-exit (exit 1)
PASS fault-report
PASS fault-address-is-end-of-a
PASS short-absent-from-default-build (exit 2)
PASS short-exit (exit 1)
PASS short-report
PASS past-end-refused-on-gpu (exit 2)
hello --sim tests: 12 passed, 0 failed
```
The fault, short-read and past-end lines are the built-in negative controls: each one must fail in the stated way. Label this step SIMULATED, never CHIP_TESTED.

---

## 6. Verify the chip receipts on the host (receipt verified, HOST_TESTED)

These steps do not rerun the chip. They check that the receipts named in the claims exist at the pinned commits and say what the claims say. Claim numbers E1 to E12 are Drake's evidence table.

**Step 6.1: E2, the Omega encoder's machine code on the GB10, and its planted-bug control**
```sh
cd "$R/CUDApp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z" && grep -H -e "^checked " -e "^PASS$" -e "^FAIL$" om-hello.log om-hello-control.log && cat summary.txt
```
**Success:** exit 0 and
```text
om-hello.log:checked 1048576 of 1048576 elements: 0 wrong, 0 never written
om-hello.log:PASS
om-hello-control.log:checked 1048576 of 1048576 elements: 1 wrong, 1 never written
om-hello-control.log:FAIL
om doctor rc=0
om hello rc=0
om hello-control rc=1
om gpu_elementwise_test rc=0
om gpu_reconv_test rc=0
om gpu_decode_attn_test rc=0
om gpu_bf16_gemv_test rc=0
om gpu_router_test rc=0
om gpu_matmul_api_test rc=0
c doctor rc=0
c hello rc=0
c hello-control rc=1
c gpu_elementwise_test rc=0
c gpu_reconv_test rc=0
c gpu_decode_attn_test rc=0
c gpu_bf16_gemv_test rc=0
c gpu_router_test rc=0
c gpu_matmul_api_test rc=0
```
The control run (`--bug=short`, a planted bug) must FAIL with rc=1 in both builds. A control that passes would void the run.

**Step 6.2: E3, 70 chip kernels byte-identical between the .om and C encoders, and the 243-kernel host corpus**
```sh
cd "$R/CUDApp/evidence/CUDAPP-OM-ENCODER" && cmp chip-20261027T080240Z/kernels-om.sha256 chip-20261027T080240Z/kernels-c.sha256 && cmp host/corpus-k-om.sha256 host/corpus-k-c.sha256 && wc -l chip-20261027T080240Z/kernels-om.sha256 host/corpus-k-om.sha256 && cd "$R/cuda-crack/receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/kernels-om" && sha256sum -c --quiet ../kernels-om.sha256 && echo "$(ls | wc -l) chip kernel files match kernels-om.sha256"
```
**Success:** exit 0 and
```text
   70 chip-20261027T080240Z/kernels-om.sha256
  243 host/corpus-k-om.sha256
  313 total
70 chip kernel files match kernels-om.sha256
```

**Step 6.3: E6, a vector add built by the seed toolchain ran through the own launcher, with a mutant control**
```sh
cd "$R/omega-mv/evidence/SEED-0/sm121/chip" && cat steps.txt
```
**Success:**
```text
check_words exit=0 want=0 ok
run_seed exit=0 want=0 ok
control_mutant exit=1 want=1 ok
session PASS
```
Limit: `window.txt` in the same directory records a dirty tree (`dirty=3`) at omega-mv `9d5d95ad…`. Say so when you cite E6.

**Step 6.4: E7, the all-Omega driver and launch path ran a vector add once**
```sh
grep -o -e "\"NATIVE_SM121_VECTOR_PASS\"" -e "\"failed_syscalls\": *0" "$R/CUDApp/evidence/speculation/native-kernel/receipt.json"
```
**Success:** both strings printed. Limit: the receipt is at a stale source commit (`0cf8cd7d…`). The current `native/*.om` sources are NOT_RUN on the chip.

**Step 6.5: E8, no CUDA toolkit was used on the E2 run**
```sh
grep -e "NVIDIA kernel module" -e "CUDA toolkit" "$R/CUDApp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-doctor.log"
```
**Success:**
```text
  ok    NVIDIA kernel module: open module 580.173.02 (CUDA++ speaks 580.173.02)
  info  CUDA toolkit: not needed and not used by CUDA++ (one is installed at /usr/local/cuda/bin/nvcc; that is fine)
```

**Step 6.6: E9, exhaustive GPU/CPU parity of FP32 math functions (every one of the 2^32 inputs)**
```sh
cd "$R/omega-mv/evidence/E1-TRANSC-GB10" && for f in *.json blobs/*.log; do h=$(sha256sum "$f" | cut -c1-64); case "$f" in *"$h"*) ;; *) echo "NOT CONTENT-ADDRESSED: $f"; exit 1;; esac; done && echo "$(ls *.json blobs/*.log | wc -l) files: each sha256 equals its file name" && grep -h "verdict=PASS digest=" blobs/*.log | cut -d" " -f1-8
```
**Success:** exit 0 and
```text
16 files: each sha256 equals its file name
RESULT chip SIGMOID checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip TANH checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip SIN checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip COS checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip ERF checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip GELU checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip RSQRT checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip LOG2 checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip EXP checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip LOG checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
RESULT chip EXP2 checked=4294967296 exhaustive=true mismatches=0 unwritten=0 verdict=PASS
```
Read this honestly:
- The blobs at omega-mv HEAD 6efc4572 hold **11** PASS lines. The published claim E9, re-checked on 2026-10-26, says **nine** operations. Report the 11 lines you observe, and keep the claim at nine unless you trace where the other two came from.
- The same blobs also hold earlier lines that are not PASS: NOT_RUN lines, and one SIGMOID run with `mismatches=98304 … verdict=FAIL`. Only the latest session's lines (with `digest=`) carry the claim. Do not hide the earlier lines, and do not count them as PASS.
- This is parity with a frozen CPU sequence, **not** correctly rounded maths. SIN and COS have a restricted domain.

**Step 6.7: E10, large workloads on the C kernel builders**
```sh
cd "$R/CUDApp/evidence" && grep -o "PASS (902 checks)" GEMM-GENERAL-00c9cf9/chip.log && grep -o -m1 "318 of 318 configs pass" ATTN-GENERAL-20261027-4d51f91f/SUMMARY.md
```
**Success:** both lines printed. Limit: these kernels were built by the **C** builders, and the receipt says "not a qualification".

**Step 6.8: E1, served with zero CUDA libraries mapped (DEPLOYED on 2026-10-21 only)**
```sh
cd "$R/omega-mv/evidence/WHAT-OMEGA-IS-20261021" && grep -A1 "count of maps lines" live-serve-no-cuda.txt && grep -o "Open Kernel Module for aarch64  580.173.02" live-serve-no-cuda.txt
```
**Success:** exit 0 and
```text
--- count of maps lines matching libcuda|libcudart|cublas|cudnn|nvrtc|libnvidia-ptxjitcompiler
0
Open Kernel Module for aarch64  580.173.02
```
Limit: the served code was the **C** GPU stack, not Omega kernels. Never write "is serving".

**Not reproducible from public repositories; do not claim them:**
- E4 (Omega-lowered kernels, 645 checks) and E5 (Omega gate kernel, golden tokens) are on draft branches that are not on Radicle.
- E11 (Hive NG lowering) is HOST_TESTED only.

---

## 7. Chip steps (CHIP_TESTED only when you run them on a GB10)

**Every step in this section is a chip step and needs a GB10 (DGX Spark).** The reference agent that wrote this prompt had no GPU access, so all of section 7 is **NOT_RUN** in the reference log. The expected outputs are quoted from the receipts named under each step. Do not run anything here without the machine owner's permission.

### 7.0 Before touching the chip
1. **Driver: NVIDIA open kernel module exactly 580.173.02** (`cat /proc/driver/nvidia/version`). The CUDA++ doctor refuses any other version, because the ioctl structures are version-specific. No CUDA toolkit is needed.
2. **Read NVIDIA's open-gpu-kernel-modules headers before experimenting**, at the same tag: <https://github.com/NVIDIA/open-gpu-kernel-modules/tree/580.173.02>. CUDApp carries the MIT-licensed headers it uses under `CUDApp/third_party/nvidia-open-580.173.02/`. In particular, read:
   - `src/common/sdk/nvidia/inc/nvos.h`, the comment above `NVOS32_ATTR2_GPU_CACHEABLE` (around lines 1112 to 1118);
   - the class headers in `src/common/sdk/nvidia/inc/class/`: `clcec0.h` (BLACKWELL_COMPUTE_B), `clc96f.h` (BLACKWELL_CHANNEL_GPFIFO_A), `clc661.h` (HOPPER_USERMODE_A) and `clc361.h` (`NVC361_NOTIFY_CHANNEL_PENDING`, the doorbell).

   Hardware debugging order: name the symptom → read the manufacturer's docs and the driver source and quote the line → only then design an experiment. If the docs say nothing, write "DOCS SILENT on X".
3. **One GPU job at a time.** If the machine serves anything, take its lock (the reference runs held `/tmp/aien-gb10.lock`), and record server health before and after (the E2 run's `health.txt` shows ok/ok). Check `ps` for other heavy GPU jobs.
4. **After one uncertain completion, stop.** The runtime latches the uncertain completion (`OMEGA_GPU_ENGINE_UNCERTAIN_COMPLETION_BLOCKED`) and refuses further submissions in that process. Find the cause of the first stall; never just retry.

### 7.1 Doctor
```sh
cd "$R/CUDApp" && make doctor
```
Chip step, needs a GB10; expected output from receipt `CUDApp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-doctor.log`: `ok` lines for the kernel module (580.173.02), device files `/dev/nvidiactl /dev/nvidia0 /dev/nvidia-uvm`, `GPU …: NVIDIA GB10 (sm_121)`, then `READY. Next: make hello-gpu`. The doctor reads only `/proc`, `/sys` and `/dev`. Status here: NOT_RUN.

### 7.2 Hello, GPU: 1,048,576 additions with every answer checked on the CPU
```sh
cd "$R/CUDApp" && make hello-gpu
```
Chip step, needs a GB10. The expected output is from receipt `…/chip-20261027T080240Z/om-hello.log`:
- `kernel built in … us: 32 instructions, 12 registers, no compiler run, no cache`;
- `checked 1048576 of 1048576 elements: 0 wrong, 0 never written`;
- machine code sha256 `9e28bd9c46f80584d77238a752e99cecddbc8d622ffbe320885ed2f499e1f075`;
- output sha256 `72d0c1b2928779e83518f0b4c7d101d933cf89f210cd4627e138c33c9ce9b6a6`;
- `PASS`, exit 0.

The machine-code sha256 must match exactly, because the encoder is deterministic. The build time will differ. `CUDAPP_ENCODER=om` is the default, so the bytes come from `om/encoder/bw_enc_sm121.om`. Status here: NOT_RUN.

### 7.3 Planted-bug control (must FAIL)
```sh
cd "$R/CUDApp" && make hello-gpu-control
```
Chip step, needs a GB10. The expected output is from receipt `…/om-hello-control.log`:
- `checked 1048576 of 1048576 elements: 1 wrong, 1 never written`;
- `FAIL`, exit 1;
- the make target then prints `NEGATIVE CONTROL hello-gpu --bug=short: RED as it must (exit 1, the one unwritten answer caught)`.

If this control passes, the checker is broken: stop. Status here: NOT_RUN.

### 7.4 Six suites with the Omega encoder, then the C encoder, and the kernel byte comparison
Each test binary is built by `make` (for example `make build/gpu_elementwise_test`). Its chip gate is `./build/<test> --out <receipt>.json`, as the comments in `CUDApp/Makefile` say. The suites are `gpu_elementwise_test`, `gpu_reconv_test`, `gpu_decode_attn_test`, `gpu_bf16_gemv_test`, `gpu_router_test` and `gpu_matmul_api_test`.

Steps:
1. Run all six with the default `.om` encoder, with `OMEGA_KERNEL_DUMP_DIR=<dir-om>` set so every launched kernel is written out.
2. Rebuild into another output directory with `CUDAPP_ENCODER=c` (e.g. `make OUT_DIR=build-enc-c CUDAPP_ENCODER=c …`).
3. Run the six again with `OMEGA_KERNEL_DUMP_DIR=<dir-c>`.
4. `sha256sum` both dump directories and `cmp` the two lists.

The reference run's own commands are not in a script in the repositories. Check `CUDApp/evidence/CUDAPP-OM-ENCODER/README.md` and `cuda-crack/REPRODUCE.md` for the current invocation before running. Chip step, needs a GB10. The expected output is from receipt `…/chip-20261027T080240Z/summary.txt` and the `om-*.log`/`c-*.log` files:
- every suite rc 0 under both encoders;
- the om suites report checks/failures of elementwise 35/0, reconv 235/0, decode_attn 29/0, bf16_gemv 12/0, router 17/0 and matmul_api 97/0;
- the elementwise suite also runs its own mutant per case and reports it `CAUGHT`;
- `kernels-om.sha256` == `kernels-c.sha256`, 70 lines.

Status here: NOT_RUN.

### 7.5 Other chip receipts you can rerun (CHIP_TESTED when you do)
For each one, read its directory's README for the command:
- E6, the seed vector add: `omega-mv/evidence/SEED-0/sm121/`;
- E9, exhaustive parity of FP32 functions: `omega-mv/evidence/E1-TRANSC-GB10/`;
- E10, GEMM and attention: `CUDApp/evidence/GEMM-GENERAL-00c9cf9/`, `ATTN-GENERAL-20261027-4d51f91f/`.

Status here: NOT_RUN.

### 7.6 The next open chip test (good first extension)
Run the six suites of 7.4 with **all** kernels encoded by the `.om` encoder, and fix its **known open defect**: the `.om` encoder ignores guard predicates except on BRA/EXIT/BAR and one store. Add a predicated-instruction golden word to `make test-om-encoder` first; it must fail before the fix and pass after. Then show the chip byte diff with a mutant control.

---

## 8. Method: how the encodings were learned and checked, and how to extend them

This is the research method. NVIDIA does not publish sm_121 (SASS) instruction encodings.

### 8.1 Learning an encoding
1. **Oracle compilation, one detail at a time.** Write a tiny probe kernel and compile it offline with NVIDIA's `nvcc` (13.0.88 here; use your own licensed install) for `sm_121`. Then change exactly one thing: a register number, an immediate, a modifier, a predicate. Diff the instruction words. A bit range that moves with that one detail is that field.
2. **Read-back.** Disassemble with `nvdisasm` or `cuobjdump -sass` to name the instruction and operands for each word. These dumps are NVIDIA tool output under the EULA. Keep them private and publish only your derived tables (as cuda-crack's `LEGAL.md` does).
3. **Open-source cross-reference.** Mesa's NAK compiler and NVK driver (MIT) describe many Blackwell encodings and the launch order. Read them for understanding; copy no code.
4. **The chip is the judge.** Accept an encoding only after a kernel using it runs on the GB10 and its outputs are checked element by element on the CPU (section 7.2 is the pattern).

### 8.2 Checking an encoder
1. **Golden words.** Freeze known-good instruction words, as `make test-om-encoder` does.
2. **Two independent encoders, byte-identical.** One encoder is in C and one in Omega. A kernel only counts when both emit the same bytes (step 5.2, receipt E3). An error would have to be made twice, independently, in the same way.
3. **Differential testing.** Encode every kernel the runtime builds both ways and diff them (the `build-enc-diff` build in step 5.2).
4. **Mutant controls.** Flip one bit or one constant on purpose and show that each check catches it (steps 3.6, 4.3, 5.4, 7.3).
5. **Exhaustive parity where the input space allows it.** For a 32-bit-input function, run all 4,294,967,296 inputs on the GPU and compare bits with the CPU reference (receipt E9).
6. **Content-addressed receipts.** Name each log by its own sha256, so later edits are detectable (step 6.6).

### 8.3 The driver path without libcuda
CUDA++ opens three device files: `/dev/nvidiactl`, `/dev/nvidia<minor>` and `/dev/nvidia-uvm`. It then issues NVIDIA RM ioctls whose structures come from the open-module headers at 580.173.02. `nvrm_open()` makes eleven calls, summarised from `CUDApp/docs/DRIVER.md` section 1:
1. Reserve virtual addresses, then open `/dev/nvidiactl` and `/dev/nvidia-uvm`.
2. `RM_ALLOC NV01_ROOT_CLIENT`.
3. `UVM_INITIALIZE`, then `UVM_MM_INITIALIZE`.
4. `NV_ESC_CARD_INFO`; open the first valid GPU's device file.
5. `NV0000_CTRL_CMD_GPU_GET_ID_INFO_V2`.
6. `RM_ALLOC NV01_DEVICE_0`, `NV20_SUBDEVICE_0`, `NV01_MEMORY_VIRTUAL`.
7. `NV0080_CTRL_CMD_GPU_GET_CLASSLIST`; refuse to go on without BLACKWELL_COMPUTE_B, BLACKWELL_CHANNEL_GPFIFO_A and HOPPER_USERMODE_A.
8. `RM_ALLOC HOPPER_USERMODE_A` and map 64 KiB of it; the doorbell is the word at `NVC361_NOTIFY_CHANNEL_PENDING`.
9. `NV2080_CTRL_CMD_GR_GET_INFO` (reads sm_121).
10. `RM_ALLOC FERMI_VASPACE_A` with page faulting, externally owned, so UVM manages it.
11. `NV2080_CTRL_CMD_GPU_GET_GID_INFO`, then `UVM_REGISTER_GPU` and `UVM_REGISTER_GPU_VASPACE`.

Memory (`nvrm_alloc()`), the channel (`nvrm_channel()`), submission (`nvrm_enqueue()`, `nvrm_ring()`) and waiting (`m16/m16_gpu_wait.c`) follow in the same document. Read it alongside `CUDApp/nvrm/nvrm.c` and the headers for every field.

### 8.4 The GB10 memory rules (the bug that cost two days)
The GB10's CPU and GPU share memory, but **GPU L2 is not coherent with CPU mappings for GPU-cached system memory**. NVIDIA's comment in `nvos.h` (580.173.02, around lines 1112 to 1118) says that for system memory, GPU caching "will not be coherent with direct CPU mappings", and that the default is "gpu uncached for system memory".

Rules:
1. **Any word the host polls** (completion flag, semaphore, done marker) must be allocated **GPU-uncached** (`GPU_CACHEABLE_NO`; in CUDApp, `nvrm_alloc_gpu_uncached`).
2. **Release sequence:** an `L2_FLUSH_DIRTY` memory operation, then a **second marker** written to uncached memory. The host waits on both. Making the flag uncached without the flush only moves the stall.
3. Symptoms of getting this wrong:
   - about 1066 ms per launch regardless of work;
   - a rare 600 s stall;
   - correct results alone but wrong results under load or on a repeat.

   The runtime refuses a cached completion flag with `OMEGA_GPU_PLAT_REFUSED_CACHE_POLICY`.
4. The whitepaper's "full cache coherency" refers to the CPU-GPU fabric, not to GPU L2. It never permits dropping the flush.

### 8.5 Extending the work
New instruction or new kernel:
1. Probe it (8.1).
2. Add golden words to both encoders.
3. Run `make test-om-encoder` and `make test-om-encoder-corpus` (byte-identical).
4. Add a mutant that must be caught.
5. Only then make the chip run, with a CPU-checked result and a planted-bug control (7.2 and 7.3).

Report each stage with its label: HOST_TESTED, then CHIP_TESTED. New Omega code must be compiled with a pinned omc whose sha256 you state.

---

## 9. Reporting format

Report in this order, in plain text:

```text
REPLICATION REPORT
Agent/model: <name>          Date (UTC): <timestamp>
Host: <uname -sm>, <distro>  GPU: <none | GB10, driver version from /proc/driver/nvidia/version>
Repos (name RID HEAD): <seven lines from step 2.1>
Pins used: CUDApp b774723f, omega-mv f4df8239 + e5b32567, omega-bridge 6a8f0090

Per step:
<step> | <label: HOST_TESTED/SIMULATED/CHIP_TESTED/NOT_RUN> | <exit code> | <PASS/FAIL/MISMATCH> | <one quoted output line>
...
Negative controls: <step> | expected FAIL | observed <exit code, quoted line>

Mismatches (if any): step, command, expected, observed (first differing line), what you did NOT change.
Claims I can make from this run: <each with its receipt path and label>
Claims I cannot make: <NOT_RUN items, and anything in the banned list 0.5>
For hardware investigations, add: DOCS READ (source, line, quote, or DOCS SILENT), OUR CODE (file:line),
EXPERIMENT (smallest repro, one variable), and tags OBSERVED / DOCUMENTED / INFERRED / UNKNOWN.
```

Never report a step as PASS that you did not run. Never round "NOT_RUN" up to anything.
