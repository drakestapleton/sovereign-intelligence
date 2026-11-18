# Open-model row qualification

On Linux AArch64, run the following from the Sovereign Intelligence source checkout with its pinned `out/omc` available. Set `OMC` to use an existing copy with the identical SHA-256. The host launcher uses Bash and GNU coreutils. The model and compiler stay on the user's machine.

```sh
tools/adapter/qualify /path/to/model.gguf
tools/adapter/check /path/to/qwen.gguf /path/to/stories.gguf
```

The launcher identifies each file by size and complete SHA-256 before compiling a kernel or allocating tensor storage. Only the two exact little-endian GGUF v3 files in models.tsv are admitted. Their reference directory entries identify the architecture, tokenizer family, Q8_0 attention tensor, row width and byte offset. The whitelist lets an unknown file fail without trusting its size fields or parsing its metadata. The tokenizer family is reported by identity. Tokenization itself is untested.

| File | Architecture | Tokenizer | Input revision |
| --- | --- | --- | --- |
| qwen2.5-0.5b-instruct-q8_0.gguf | qwen2 | gpt2 | [Qwen](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/blob/9217f5db79a29953eb74d5343926648285ec7e67/qwen2.5-0.5b-instruct-q8_0.gguf) |
| stories15M-q8_0.gguf | llama | llama | [ggml-org](https://huggingface.co/ggml-org/models/blob/499bc8821c6b12b4e53c5bffcb21ec206f212d81/tinyllamas/stories15M-q8_0.gguf) |

## What runs

The adapter takes the first row of `blk.0.attn_q.weight`, verifies the row digest, instantiates the ggml-omega template at the exact block count and compiles a native Linux AArch64 ELF. It multiplies the row by the repeating activation vector `i % 7 - 3` and checks the four result bytes against an independently decoded reference. A cache hit must match the pinned binary digest and pass the row check again. Entries are atomically published after parity passes. Set `SI_ADAPTER_CACHE` to choose a scratch cache.

The read-only probe records OS release, CPU ISA and MIDRs, total RAM, display PCI IDs and the bound driver. Its output is part of the cache key alongside the model, source, compiler and expected executable digests. The implemented fallback is host execution, including on a GB10 host. The program opens no GPU nodes. Only the row width specializes the arithmetic. CPU ISA determines the executable target. Individual CPU core types do not select different instruction sequences.

## Source trail and limits

* Sovereign Intelligence base e659ab3defe05c03ac1dd6cb39f8aa4626b905b1. Its seed/PINS.tsv compiler SHA-256 is 45442c7d517fd605507bda5d1ec52493ff182661301cda69a95fc4f77dc6080d. The Spark test used an existing matching compiler. The seed rebuild belongs to the repository gate.
* ggml-omega a30322c90191507c46c1b74783d722d617d4514c. dq8.om.in is kernels/dq8.om verbatim and half.om is the h2f function from kernels/math.om. See LICENSE.ggml-omega. Its CI pins the Qwen bytes. Its separate evidence/gb10-model-20261029.json records fixed-prompt greedy agreement with differing logits on earlier GB10 runs.
* Omega omega-mv ace307db4283dffb9e8b2fadb6c91d5d47452c14, gpu/nvidia/om/admission/chip_admit.om, identifies display PCI 10de:2e12 as sm_121. CUDApp 21d8de285f713adf09e0d6ba6db2b37139d0674e, backend/hw/manifest.tsv, distinguishes observed identity from admission for an operation. Neither source grants this adapter GPU execution.
* MojoLlama 249949d1c3fe839bb5e156f91e9c5fd8d3dc7990, src/mojollama/gguf/reader.mojo, reads the entire file through Python. The separate gguf_arch.mojo scanner documents a file-size limit. Neither is a runtime dependency of this bounded adapter.

For independent reproduction install gguf==0.17.1 in a test environment and run `python reference.py QWEN.gguf STORIES.gguf` from this directory. Compare the metadata, tensor location, row digest and float bits with models.tsv. receipt.txt records the two real inputs and the controls. No whole-model inference, logit parity, throughput, arbitrary GGUF parsing, Safetensors, GPU code generation or public installer integration was exercised.
