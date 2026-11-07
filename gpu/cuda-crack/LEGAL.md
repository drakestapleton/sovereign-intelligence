# Legal

## Interoperability

This work exists to make my own programs run on hardware I own. The encoder, tables, runtime and driver client were independently implemented from public documentation and open source, and checked with NVIDIA's tools on my own code. No NVIDIA source code is copied here. The launch order credits Mesa NVK (MIT). The driver client is written against NVIDIA's open kernel module headers, which NVIDIA publishes under the MIT licence at https://github.com/NVIDIA/open-gpu-kernel-modules (tag 580.173.02); they are linked, not re-hosted.

The tables in `isa/` are derived by probing my own Omega encoder (`gen/bw_enc_sm121.om`), and checked against machine code my own encoder produced. NVIDIA does not publish SASS encodings. I recovered them from my own probe kernels compiled offline with nvcc 13.0.88 and read with NVIDIA's disassembler, from Mesa NAK sources (MIT, no code copied), and by accepting only encodings the chip ran correctly.

## Not included, and why

| Not here | Why | Instead |
|---|---|---|
| NVIDIA binaries: `nvidia.ko` builds, GSP firmware, libcuda, any cubin or PTX made by nvcc or ptxas | NVIDIA's binaries and firmware | Version 580.173.02 named; get them from NVIDIA |
| Raw `cuobjdump` / `nvdisasm` dumps of nvcc-compiled probe kernels | Output of NVIDIA toolkit binaries under the CUDA EULA | My derived tables (`isa/`) and my own encoder's output (`receipts/.../kernels-om/*.bin`) |
| NVIDIA documents and PDFs (whitepaper, Hot Chips deck, PTX ISA, user guides) | NVIDIA's copyright | Links and one-line quotes with citations in `FIELD-MANUAL.md` |
| NVIDIA's 67 MIT open-module headers | Outside this repository's purpose | Linked at tag 580.173.02, cited by file and line |
| NDA or developer-program material | Not mine to publish | Nothing; none was found in the sources behind this repository |
| Keys, tokens, signing or crypto material of any kind | Security | Nothing |
| Thermal, power, clock or fan limit changes, firmware flashing | Safety | Nothing; none are part of this work |

The `.bin` files under `receipts/cudapp/evidence/CUDAPP-OM-ENCODER/chip-20261027T080240Z/kernels-om/` are raw sm_121 instruction words that my Omega encoder wrote during the 2026-10-27 chip run. nvcc and ptxas did not write them. Their sha256 are pinned by `kernels-om.sha256` in CUDApp `b774723f` (see `receipts/README.md`).

## Licence

Apache License 2.0 (`LICENSE`), the same as CUDApp.

NVIDIA and CUDA are trademarks of NVIDIA Corporation. DGX Spark and GB10 are NVIDIA product names. This project is not affiliated with, sponsored by or endorsed by NVIDIA.
