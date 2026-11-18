# Sovereign Intelligence Pack for GB10

This preview brings the signed local Interplane store, the Omega compiler, the first-party round40 model, local tool calls, and a GGUF inference backend together. It targets an NVIDIA DGX Spark with ARM64 Linux, NVIDIA drivers and CUDA 13 runtime libraries. The first install fetches pinned tools and Git histories from Interplane. Use an account with the foundation installer prerequisites, GNU tar, gzip, sha256sum and curl.

Extract the archive and run `./sovereign-intelligence/install` as your user. The installed command is `~/.local/bin/si-pack`. Run `si-pack verify` to check the installed files and signed project history. Run `si-pack demo` for the first-party model's one-file tool example. The model reads a packaged fixture through the tool runner. It does not have access to arbitrary personal files.

Use `si-pack attach /path/to/model.gguf` to serve a compatible local model on 127.0.0.1:8091 through the bundled llama.cpp interoperability runtime. It uses the CPU and stays offline. Ctrl-C stops that server. Set SI_PACK_PORT to choose a different port. The two weight files in adapter/models.tsv also trigger native Omega compilation and reference checking of one quantized row for the detected ARM CPU. This probe does not accelerate the GGUF server. Other model families, GPU kernel synthesis and end-to-end native retrofit remain in development.

The installer keeps each pack in a content-identified directory under ~/.local/share/sovereign-intelligence. Upgrades switch the current link only after staging. Interplane project history and owner keys have their own locations. The foundation installer verifies its own components and preserves existing user commands. This preview has no system service.

The GGUF backend is llama.cpp build 11188 at e85e15cf6. Its packaged binaries are pinned in runtime.sha256. Its CUDA-linked build needs the NVIDIA driver and CUDA 13 shared libraries on the host, including when serving on CPU. The native adapter compiler comes from the seed and patch documented in seed/PROVENANCE.md at the Sovereign Intelligence source revision. See LICENSE.llama, LICENSE.omega, NOTICE.omega and the licenses inside round40 and adapter.

For this preview the checkpoint and model runners were tested on one GB10. The attached GGUF models were Qwen2.5 0.5B Instruct Q8_0 and a TinyStories Llama Q8_0 fixture. GGUF files the bundled runtime cannot load produce a startup error. Tool calls on this release are limited to the first-party model's bundled read-file demo.
