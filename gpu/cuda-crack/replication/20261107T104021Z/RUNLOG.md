# RUNLOG: replicate.sh

- Date (UTC): 2026-11-07T10:40:21Z
- Host: Linux 7.0.0-1019-nvidia aarch64
- Workspace: ~/aien-replicate-20261107T104021Z (HOME inside the run)
- Environment of every step: env -i HOME=~/aien-replicate-20261107T104021Z PATH=/usr/bin:/bin R=~/aien-replicate-20261107T104021Z/replica LC_ALL=C sh -c '<command>'
- Seeds: https://www.aienos.com/rad, then https://rosa.radicle.network
- Steps: AGENT-PROMPT.md at cuda-crack 7ad53bab4cbc120b690fd2ca42fbcc5e25c476c9 (rad:z631r2JJiVT8it4tST7RK24hpowi)
- replicate-inner.sh sha256 4a8807face7971db81ca4adc40a86f8ef23a8423b8876e2385b6dc337294ea0a

### 1.1-preflight (HOST_TESTED): PASS

```sh
uname -sm; for t in git make gcc sh sha256sum cmp sed grep awk; do command -v $t >/dev/null || echo "MISSING $t"; done; echo preflight done
```

rc=0, 0s, 2 output lines

```text
Linux aarch64
preflight done
```

### 2.1-clone (HOST_TESTED): PASS

```sh
mkdir -p "$R" && cd "$R" && while read name rid; do ok=0; for src in "$RAD_HTTP" "$RAD_HTTP2"; do if git clone -q "$src/$rid.git" "$name" </dev/null; then ok=1; break; fi; rm -rf "./$name"; done; [ $ok = 1 ] || { echo "could not clone $name rad:$rid"; exit 1; }; echo "$name $(git -C "$name" rev-parse HEAD) $src"; done <<EOF
CUDApp z4RxD8vXigmWg61nM8miQ8DVPAXEP
omega-mv z6do9WDBhuSnvopDkgFdFr1yWA62
omega-bridge z3Hr9ZaiKHwwuNzPK5M8c7uw6pj7y
cuda-crack z631r2JJiVT8it4tST7RK24hpowi
physics-mv z49She8eifZpLd2aiSvk2pph3DMUo
omega-gpu-driver z2xjD5kxUTTBNCryJ6rg9QXpemzei
omega-blas z47VdC9EFsF4dFyH1QJ1C2JNJK4JS
EOF
```

rc=0, 13s, 7 output lines

```text
CUDApp 9714eba8f1ff5bca218edb075386f813eb524d9d https://www.aienos.com/rad
omega-mv da8b7e66ec179388d20c2b2baabdcd87cf4ab7b9 https://www.aienos.com/rad
omega-bridge 882e3c061723205fbaf34c8a949e1be3451ac9e7 https://www.aienos.com/rad
cuda-crack 7ad53bab4cbc120b690fd2ca42fbcc5e25c476c9 https://www.aienos.com/rad
physics-mv 56d02ae50de6c6be46d6b23380eb7ec5edcca787 https://www.aienos.com/rad
omega-gpu-driver 1ac3589c525657cf0698ff0f95557d922d2162ce https://www.aienos.com/rad
omega-blas e3f1b403839b1fc23d54c060c9c0c0c751774edd https://www.aienos.com/rad
```

### 2.2-pins (HOST_TESTED): PASS

```sh
cd "$R" && git -C CUDApp checkout -q b774723f537cec16a359fe082b8100317a5b5490 && git -C CUDApp rev-parse HEAD && git -C CUDApp merge-base --is-ancestor 010abb1549c48a4be6d63da47101d393f76cb2dd HEAD && echo "E2 receipt commit 010abb15 is inside CUDApp b774723f" && git -C cuda-crack checkout -q 043f993fab0b263eb0edd1a367fee8fee8f6a79b && git -C cuda-crack rev-parse HEAD && git -C omega-mv checkout -q 6efc45728d5080b0fc5d74016a00ba8bbfcf9698 && git -C omega-mv rev-parse HEAD && git -C omega-mv worktree add -q --detach ../omc-f4df8239 f4df82394e35893dcf1354dda69a2fe028d94bc1 && git -C omega-mv worktree add -q --detach ../omc-e5b32567 e5b32567a7aff3ce594e3254a622a846a6cd190b && git -C omega-bridge worktree add -q --detach ../bridge-6a8f0090 6a8f0090913283125f14871272f03d144a102d02 && echo "worktrees: omc-f4df8239 omc-e5b32567 bridge-6a8f0090"
```

rc=0, 4s, 5 output lines

```text
b774723f537cec16a359fe082b8100317a5b5490
E2 receipt commit 010abb15 is inside CUDApp b774723f
043f993fab0b263eb0edd1a367fee8fee8f6a79b
6efc45728d5080b0fc5d74016a00ba8bbfcf9698
worktrees: omc-f4df8239 omc-e5b32567 bridge-6a8f0090
```

### 3.1-seed-f4df8239 (HOST_TESTED): PASS

```sh
cd "$R/omc-f4df8239" && sh seed/omega-from-seed.sh
```

rc=0, 1s, 12 output lines

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

### 3.2-sha-f4df8239 (HOST_TESTED): PASS

```sh
cd "$R/omc-f4df8239" && sha256sum seed/out/omc && git diff --exit-code --stat seed/out/omc && echo "rebuilt omc is byte-identical to the committed one"
```

rc=0, 1s, 2 output lines

```text
3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194  seed/out/omc
rebuilt omc is byte-identical to the committed one
```

### 3.3-seed-e5b32567 (HOST_TESTED): PASS

```sh
cd "$R/omc-e5b32567" && sh seed/omega-from-seed.sh
```

rc=0, 0s, 12 output lines

```text
PASS seed0 408 bytes, rebuilds itself
PASS hex1 776 bytes, born from seed0
PASS asm2 2464 bytes, born from hex1
PASS om4 om4.bin 14224 bytes
PASS omc fixpoint 2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f
PASS fwd exit 0
PASS fwd runs, exit 7
PASS mut exit 0
PASS mut runs, exit 0
PASS cycle exit 9
PASS assign exit 7
RC=0
```

### 3.4-sha-e5b32567 (HOST_TESTED): PASS

```sh
cd "$R/omc-e5b32567" && sha256sum seed/out/omc && git diff --exit-code --stat seed/out/omc && echo "rebuilt omc is byte-identical to the committed one"
```

rc=0, 1s, 2 output lines

```text
2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f  seed/out/omc
rebuilt omc is byte-identical to the committed one
```

### 3.5-neg-seed-byte (HOST_TESTED): PASS

```sh
cd "$R" && git -C omega-mv worktree add -q --detach ../omc-neg f4df82394e35893dcf1354dda69a2fe028d94bc1 && cd omc-neg && sed -i "s/^464c457f /464c457e /" seed/rung0/seed0.hex && git diff --stat && sh seed/omega-from-seed.sh
```

rc=126, 7s, 3 output lines, control failed as it must (exit 126)

```text
 seed/rung0/seed0.hex | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
seed/omega-from-seed.sh: 19: build/seed/birth/seed0.bin: Exec format error
```

### 3.6-neg-compiler-source (HOST_TESTED): PASS

```sh
cd "$R/omc-neg" && git checkout -q seed/rung0/seed0.hex && sed -i "s/^global out uchar 16777216\$/global out uchar 16777215/" seed/omc/omc.om && git diff --stat && sh seed/omega-from-seed.sh >/dev/null; sha256sum seed/out/omc; git diff --exit-code --stat seed/out/omc
```

rc=1, 1s, 5 output lines, control failed as it must (exit 1)

```text
 seed/omc/omc.om | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
455a5d1f3d8621d7d03bf842aac30a46c57808493908c7b0e8a70c92cad9ad60  seed/out/omc
 seed/out/omc | Bin 625676 -> 625744 bytes
 1 file changed, 0 insertions(+), 0 deletions(-)
```

### 4.1-crack-receipts (HOST_TESTED): PASS

```sh
cd "$R/cuda-crack/receipts" && sha256sum -c --quiet SHA256SUMS && echo "all $(wc -l < SHA256SUMS) receipt files match"
```

rc=0, 0s, 1 output lines

```text
all 148 receipt files match
```

### 4.2-crack-gen (HOST_TESTED): PASS

```sh
cd "$R/cuda-crack" && OMC="$R/omc-f4df8239/seed/out/omc" sh gen/run.sh && git diff --exit-code --stat isa/ && echo "isa/ regenerated byte-identical"
```

rc=0, 1s, 2 output lines

```text
isa/sm121-forms.txt: 471 forms, sha256 587d81e2bc8b3dc6fdb48d477a76b717300732ccdb984f05f5b3df658e58e2d7
isa/ regenerated byte-identical
```

### 4.3-crack-check (HOST_TESTED): PASS

```sh
cd "$R/cuda-crack" && OMC="$R/omc-f4df8239/seed/out/omc" sh check/check.sh
```

rc=0, 1s, 19 output lines

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

### 4.4-same-encoder (HOST_TESTED): PASS

```sh
cmp "$R/cuda-crack/gen/bw_enc_sm121.om" "$R/CUDApp/om/encoder/bw_enc_sm121.om" && echo "cuda-crack gen/bw_enc_sm121.om == CUDApp om/encoder/bw_enc_sm121.om"
```

rc=0, 0s, 1 output lines

```text
cuda-crack gen/bw_enc_sm121.om == CUDApp om/encoder/bw_enc_sm121.om
```

### 4.5-neg-tampered-receipt (HOST_TESTED): PASS

```sh
cd "$R" && rm -rf neg-receipts && cp -r cuda-crack/receipts neg-receipts && printf x >> neg-receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-hello.log && cd neg-receipts && sha256sum -c --quiet SHA256SUMS
```

rc=1, 0s, 2 output lines, control failed as it must (exit 1)

```text
./cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-hello.log: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```

### 5.1-om-encoder (HOST_TESTED): PASS

```sh
cd "$R/CUDApp" && make test-om-encoder
```

rc=0, 80s, 13 output lines

```text
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -pthread -Isrc -o build/om-encoder/codegen_om tests/test_omega_codegen_freestanding.c src/omega_blackwell_codegen.c src/omega_blackwell_matmul.c src/sha256.c src/cudapp_om_amp_runtime.c src/cudapp_om_ampere_enc_sm86.c src/cudapp_om_attn_mirror_plan.c src/cuda
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -pthread -Isrc -DCUDAPP_MIGRATION_PENDING_ENCODER_DIFF -o build/om-encoder/codegen_diff tests/test_omega_codegen_freestanding.c \
	src/omega_blackwell_codegen.c src/omega_blackwell_matmul.c src/sha256.c src/cudapp_om_amp_runtime.c src/cudapp_om_ampere_enc_sm86.c src/cudapp_om_attn_mirror_plan.c src/cudapp_om_attn_mirror_step.c src/cudapp_om_binding.c src/cudapp_om_bw_enc_sm121.c src/cudapp_om_cache_runtime.c src/cudapp_om_clos
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -pthread -Isrc -DCUDAPP_MIGRATION_PENDING_ENCODER_DIFF -DCUDAPP_ENCODER_DIFF_SELFTEST -o build/om-encoder/codegen_diff_red \
	tests/test_omega_codegen_freestanding.c src/omega_blackwell_codegen.c src/omega_blackwell_matmul.c src/sha256.c src/cudapp_om_amp_runtime.c src/cudapp_om_ampere_enc_sm86.c src/cudapp_om_attn_mirror_plan.c src/cudapp_om_attn_mirror_step.c src/cudapp_om_binding.c src/cudapp_om_bw_enc_sm121.c src/cuda
build/om-encoder/codegen_om --golden
PASS: hosted golden-word fixtures through the .om encoder (0 failing checks)
rm -f build/om-encoder/diff.log
CUDAPP_ENCODER_DIFF_LOG=build/om-encoder/diff.log build/om-encoder/codegen_diff --golden
PASS: hosted golden-word fixtures through the .om encoder (0 failing checks)
CUDAPP_ENCODER_DIFF_LOG=build/om-encoder/diff.log build/om-encoder/codegen_diff --dump > build/om-encoder/dump_diff.txt
encoder diff: .om and C byte-identical on 145 golden instructions and 14 fixture programs
red check: one flipped bit aborts the encoder diff, as it must
```

### 5.3-neg-mutants-unpinned (HOST_TESTED): PASS

```sh
cd "$R/CUDApp" && make test-om-encoder-mutants
```

rc=2, 8s, 23 output lines, control failed as it must (exit 2)

```text
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_engine.o src/omega_gpu_engine.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_platform.o src/omega_gpu_platform.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_blackwell_encoder.o src/omega_blackwell_encoder.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_blackwell_codegen.o src/omega_blackwell_codegen.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_blackwell_matmul.o src/omega_blackwell_matmul.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_blackwell_qmd.o src/omega_blackwell_qmd.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_blackwell_realize.o src/omega_blackwell_realize.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/sha256.o src/sha256.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_session.o src/omega_gpu_session.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_fmt.o src/omega_gpu_fmt.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_matmul_api.o src/omega_gpu_matmul_api.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_attention_api.o src/omega_gpu_attention_api.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_serving.o src/omega_gpu_serving.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/omega_gpu_wait.o src/omega_gpu_wait.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/cudapp_freest_revision.o src/cudapp_freest_revision.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/cudapp_freest_epoch.o src/cudapp_freest_epoch.c
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -ffreestanding -fno-builtin -fno-stack-protector -U_FORTIFY_SOURCE -DOMEGA_GPU_NO_POSIX -DOMEGA_NUMERIC_CPU_ONLY -Isrc -c -o build/gpu_fs/cudapp_freest_f16.o src/cudapp_freest_f16.c
gcc -r -nostdlib -o build/gpu_fs/omega_gpu_freestanding.o build/gpu_fs/omega_gpu_engine.o build/gpu_fs/omega_gpu_platform.o build/gpu_fs/omega_blackwell_encoder.o build/gpu_fs/omega_blackwell_codegen.o build/gpu_fs/omega_blackwell_matmul.o build/gpu_fs/omega_blackwell_qmd.o build/gpu_fs/omega_blackw
freestanding GPU link (17 files): only memcmp memcpy memset strcmp strlen undefined
gcc -std=gnu11 -O2 -Wall -Wextra -Werror -Isrc -DOMEGA_GPU_NO_POSIX -o build/test_codegen_freestanding tests/test_omega_codegen_freestanding.c \
	build/gpu_fs/omega_blackwell_codegen.o build/gpu_fs/omega_blackwell_matmul.o build/gpu_fs/sha256.o build/gpu_fs/cudapp_freest_f16.o
./build/test_codegen_freestanding --dump > build/om-encoder/c-dump.txt
make: *** [mk/om-encoder.mk:88: test-om-encoder-mutants] Error 1
```

### 5.4-om-encoder-mutants (HOST_TESTED): PASS

```sh
cd "$R/bridge-6a8f0090" && OMEGA_SOURCE="$R/omega-mv" sh tools/bootstrap.sh && sh tools/build.sh && cat build/compiler.sha256 && cd "$R/CUDApp" && make test-om-encoder-mutants OMEGA_OMC="$R/omc-e5b32567/seed/out/omc" OMEGA_BRIDGE="$R/bridge-6a8f0090"
```

rc=0, 10s, 23 output lines

```text
om4.bin 14224 bytes
source=29b12760f4c962606411d6bf25032aedef063301
8608fa11f6a2cf1c50db22d871eef16b00d5bc719bc1a222cc3e456984ac5ebf  seed/omc/omc.om
191b776ef98821597c3e30655da6d680a9b66edbc9ceaca3c39c61ea6df098e9  ../omc
bootstrap fixpoint RC=0
69d629df170a24ba0c2cb6d41dbfaed520e248e0d723236dd32abf0581524d84  src/toc.om
1b782077c4308d2d7f5c809e472d9de04c99d41f0129fb0a90c44965b7ddcb04  build/bridge
./build/test_codegen_freestanding --dump > build/om-encoder/c-dump.txt
generating portable unit bw_enc_sm121 (bridge-seeded)
generating portable unit revision (bridge-freest)
generating portable unit epoch (bridge-freest)
generating portable unit f16 (bridge-freest)
mutant 1 red ('s/^ret or base shl rb o 1 16$/ret or base shl rb o 1 17/'): golden words FAIL, dump vs C DIFFERS
generating portable unit bw_enc_sm121 (bridge-seeded)
generating portable unit revision (bridge-freest)
generating portable unit epoch (bridge-freest)
generating portable unit f16 (bridge-freest)
mutant 2 red ('s/^p = 262144$/p = 0/'): golden words FAIL, dump vs C DIFFERS
generating portable unit bw_enc_sm121 (bridge-seeded)
generating portable unit revision (bridge-freest)
generating portable unit epoch (bridge-freest)
generating portable unit f16 (bridge-freest)
mutant 3 red ('s/^const NOPC ulong 1032192$/const NOPC ulong 1032193/'): golden words FAIL, dump vs C DIFFERS
```

### 5.5-hello-sim (SIMULATED): PASS

```sh
cd "$R/CUDApp" && make test-hello-sim
```

rc=0, 75s, 173 output lines (first 8 and last 25 shown; full output logs/5.5-hello-sim.log)

```text
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
cc -std=gnu11 -Wall -Wextra -Werror -MMD -MP -D_GNU_SOURCE -O2 -Isrc -I./m16 -I./nvrm -I./third_party/nvidia-open-580.173.02/src/common/sdk/nvidia/inc -I./third_party/nvidia-open-580.173.02/kernel-open/common/inc -I./third_party/nvidia-open-580.173.02/kernel-open/nvidia-uvm -I./third_party/nvidia-op
[...]
PASS owned-account-cleanup
PASS one-owned-account-deletion
PASS created_again-exit-3
PASS created_again-never-enters-gpu
PASS created_again-only-expected-privilege
PASS distinct-candidate-names
PASS temp_failure-exit-3
PASS temp_failure-never-enters-gpu
PASS temp_failure-only-expected-privilege
PASS temp-failure-no-privilege
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

### 6.1-E2-hello-receipt (receipt verified): PASS

```sh
cd "$R/CUDApp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z" && grep -H -e "^checked " -e "^PASS$" -e "^FAIL$" om-hello.log om-hello-control.log && cat summary.txt
```

rc=0, 0s, 22 output lines

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

### 6.2-E3-chip-kernels (receipt verified): PASS

```sh
cd "$R/CUDApp/evidence/CUDAPP-OM-ENCODER" && cmp chip-20261027T080240Z/kernels-om.sha256 chip-20261027T080240Z/kernels-c.sha256 && cmp host/corpus-k-om.sha256 host/corpus-k-c.sha256 && wc -l chip-20261027T080240Z/kernels-om.sha256 host/corpus-k-om.sha256 && cd "$R/cuda-crack/receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/kernels-om" && sha256sum -c --quiet ../kernels-om.sha256 && echo "$(ls | wc -l) chip kernel files match kernels-om.sha256"
```

rc=0, 0s, 4 output lines

```text
   70 chip-20261027T080240Z/kernels-om.sha256
  243 host/corpus-k-om.sha256
  313 total
70 chip kernel files match kernels-om.sha256
```

### 6.3-E6-seed-vecadd (receipt verified): PASS

```sh
cd "$R/omega-mv/evidence/SEED-0/sm121/chip" && cat steps.txt
```

rc=0, 0s, 4 output lines

```text
check_words exit=0 want=0 ok
run_seed exit=0 want=0 ok
control_mutant exit=1 want=1 ok
session PASS
```

### 6.4-E7-native-launch (receipt verified): PASS

```sh
grep -o -e "\"NATIVE_SM121_VECTOR_PASS\"" -e "\"failed_syscalls\": *0" "$R/CUDApp/evidence/speculation/native-kernel/receipt.json"
```

rc=0, 0s, 2 output lines

```text
"NATIVE_SM121_VECTOR_PASS"
"failed_syscalls": 0
```

### 6.5-E8-doctor (receipt verified): PASS

```sh
grep -e "NVIDIA kernel module" -e "CUDA toolkit" "$R/CUDApp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/om-doctor.log"
```

rc=0, 0s, 2 output lines

```text
  ok    NVIDIA kernel module: open module 580.173.02 (CUDA++ speaks 580.173.02)
  info  CUDA toolkit: not needed and not used by CUDA++ (one is installed at /usr/local/cuda/bin/nvcc; that is fine)
```

### 6.6-E9-exhaustive (receipt verified): PASS

```sh
cd "$R/omega-mv/evidence/E1-TRANSC-GB10" && for f in *.json blobs/*.log; do h=$(sha256sum "$f" | cut -c1-64); case "$f" in *"$h"*) ;; *) echo "NOT CONTENT-ADDRESSED: $f"; exit 1;; esac; done && echo "$(ls *.json blobs/*.log | wc -l) files: each sha256 equals its file name" && grep -h "verdict=PASS digest=" blobs/*.log | cut -d" " -f1-8
```

rc=0, 1s, 12 output lines

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

### 6.7-E10-builders (receipt verified): PASS

```sh
cd "$R/CUDApp/evidence" && grep -o "PASS (902 checks)" GEMM-GENERAL-00c9cf9/chip.log && grep -o -m1 "318 of 318 configs pass" ATTN-GENERAL-20261027-4d51f91f/SUMMARY.md
```

rc=0, 0s, 2 output lines

```text
PASS (902 checks)
318 of 318 configs pass
```

### 6.8-E1-no-cuda (receipt verified): PASS

```sh
cd "$R/omega-mv/evidence/WHAT-OMEGA-IS-20261021" && grep -A1 "count of maps lines" live-serve-no-cuda.txt && grep -o "Open Kernel Module for aarch64  580.173.02" live-serve-no-cuda.txt
```

rc=0, 0s, 3 output lines

```text
--- count of maps lines matching libcuda|libcudart|cublas|cudnn|nvrtc|libnvidia-ptxjitcompiler
0
Open Kernel Module for aarch64  580.173.02
```

### 5.2-om-encoder-corpus

NOT_RUN: optional, long (three CUDApp builds on one core); run with --corpus

### 7-chip

NOT_RUN: chip steps are off by default; run with --chip on a GB10

## Summary

| step | label | rc | result | seconds | required | note |
|---|---|---|---|---|---|---|
| 1.1-preflight | HOST_TESTED | 0 | PASS | 0 | req |  |
| 2.1-clone | HOST_TESTED | 0 | PASS | 13 | req |  |
| 2.2-pins | HOST_TESTED | 0 | PASS | 4 | req |  |
| 3.1-seed-f4df8239 | HOST_TESTED | 0 | PASS | 1 | req |  |
| 3.2-sha-f4df8239 | HOST_TESTED | 0 | PASS | 1 | req |  |
| 3.3-seed-e5b32567 | HOST_TESTED | 0 | PASS | 0 | req |  |
| 3.4-sha-e5b32567 | HOST_TESTED | 0 | PASS | 1 | req |  |
| 3.5-neg-seed-byte | HOST_TESTED | 126 | PASS | 7 | req | control failed as it must (exit 126) |
| 3.6-neg-compiler-source | HOST_TESTED | 1 | PASS | 1 | req | control failed as it must (exit 1) |
| 4.1-crack-receipts | HOST_TESTED | 0 | PASS | 0 | req |  |
| 4.2-crack-gen | HOST_TESTED | 0 | PASS | 1 | req |  |
| 4.3-crack-check | HOST_TESTED | 0 | PASS | 1 | req |  |
| 4.4-same-encoder | HOST_TESTED | 0 | PASS | 0 | req |  |
| 4.5-neg-tampered-receipt | HOST_TESTED | 1 | PASS | 0 | req | control failed as it must (exit 1) |
| 5.1-om-encoder | HOST_TESTED | 0 | PASS | 80 | req |  |
| 5.3-neg-mutants-unpinned | HOST_TESTED | 2 | PASS | 8 | req | control failed as it must (exit 2) |
| 5.4-om-encoder-mutants | HOST_TESTED | 0 | PASS | 10 | req |  |
| 5.5-hello-sim | SIMULATED | 0 | PASS | 75 | req |  |
| 6.1-E2-hello-receipt | receipt verified | 0 | PASS | 0 | req |  |
| 6.2-E3-chip-kernels | receipt verified | 0 | PASS | 0 | req |  |
| 6.3-E6-seed-vecadd | receipt verified | 0 | PASS | 0 | req |  |
| 6.4-E7-native-launch | receipt verified | 0 | PASS | 0 | req |  |
| 6.5-E8-doctor | receipt verified | 0 | PASS | 0 | req |  |
| 6.6-E9-exhaustive | receipt verified | 0 | PASS | 1 | req |  |
| 6.7-E10-builders | receipt verified | 0 | PASS | 0 | req |  |
| 6.8-E1-no-cuda | receipt verified | 0 | PASS | 0 | req |  |
| 5.2-om-encoder-corpus | HOST_TESTED | - | NOT_RUN | 0 | opt | optional, long (three CUDApp builds on one core); run with --corpus |
| 7-chip | CHIP_TESTED | - | NOT_RUN | 0 | opt | chip steps are off by default; run with --chip on a GB10 |

