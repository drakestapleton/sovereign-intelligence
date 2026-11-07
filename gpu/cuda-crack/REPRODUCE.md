# Reproduce

## Without a GPU: the tables and the chip kernels

See the five-minute path in `README.md`. It needs only a Linux machine that runs the pinned Omega seed compiler (omega-mv `seed/` says which platform it targets) and the pinned omc, sha256 `3ad9f10f64309e7acf8a725082b28e23a2a4aeb07e98322fb4dc0fcd8fc93194`.

```sh
rad clone rad:z6do9WDBhuSnvopDkgFdFr1yWA62 omega-mv     # or: git clone https://www.aienos.com/rad/z6do9WDBhuSnvopDkgFdFr1yWA62.git omega-mv
# build or fetch seed/out/omc as omega-mv's seed/README describes, then check its sha256
OMC=$PWD/omega-mv/seed/out/omc
rad clone rad:z631r2JJiVT8it4tST7RK24hpowi cuda-crack    # or: git clone https://www.aienos.com/rad/z631r2JJiVT8it4tST7RK24hpowi.git cuda-crack
cd cuda-crack
(cd receipts && sha256sum -c SHA256SUMS)
OMC=$OMC gen/run.sh && git diff --exit-code isa/
OMC=$OMC check/check.sh          # expect: ALL CHECKS PASS
```

## On a GB10 (DGX Spark): run my machine code yourself

You need: Linux on the Spark's ARM CPU, NVIDIA's open kernel module **580.173.02** (the doctor refuses other versions), NVIDIA's signed GSP firmware that the module loads, `git`, `make` and a C compiler. No CUDA toolkit.

```sh
rad clone rad:z4RxD8vXigmWg61nM8miQ8DVPAXEP CUDApp    # or: git clone https://www.aienos.com/rad/z4RxD8vXigmWg61nM8miQ8DVPAXEP.git CUDApp
cd CUDApp
git checkout b774723f537cec16a359fe082b8100317a5b5490
make doctor               # reads /proc, /sys and /dev only; names any problem and its fix
make hello-gpu            # vector add of 1,048,576 elements, every answer checked on the CPU; PASS, exit 0
make hello-gpu-control    # the planted-bug control: must FAIL, exit 1
```

`CUDAPP_ENCODER=om` is the default, so the machine code comes from the Omega encoder `om/encoder/bw_enc_sm121.om`, the same file as `gen/bw_enc_sm121.om` here. Compare your logs with mine in `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/` (`om-doctor.log`, `om-hello.log`, `om-hello-control.log`). `build/hello_gpu --sim` runs the same kernel on the host simulator with no GPU.

The kernel byte check behind E3 (70 chip kernels, Omega encoder vs C encoder) and the host corpus (243 kernels) are `make test-om-encoder-corpus` and `make test-om-encoder-mutants` in CUDApp; their outputs are in `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/host/`.

These are research results on one chip family. Running them on your machine is at your own risk; nothing here changes clocks, power, thermal or fan limits, or flashes firmware.
