#!/bin/sh
# All operations are inside main. An interrupted pipe before the final call installs nothing.
main() (
    set -eu
    umask 077
    if [ "$(uname -s)/$(uname -m)" != Linux/aarch64 ] || ! command -v nvidia-smi >/dev/null 2>&1; then
        echo 'This Sovereign Intelligence preview requires an NVIDIA DGX Spark running ARM64 Linux.' >&2
        exit 2
    fi
    [ "$(nvidia-smi --query-gpu=name --format=csv,noheader)" = 'NVIDIA GB10' ] || { echo 'This preview requires one NVIDIA GB10.' >&2; exit 2; }
    tmp=$(mktemp -d)
    trap 'rm -rf -- "$tmp"' EXIT
    cd "$tmp"
    curl --proto '=https' --proto-redir '=https' -fLsS --retry 3 'https://interplane.io/drakestapleton/sovereign-intelligence/releases/download/gb10-preview-20261118.1/sovereign-intelligence-gb10.tar.gz' -o pack.tar.gz
    printf '%s  pack.tar.gz\n' 'daf88ced333426a82f8fb2ebfb73a30c08a7199651c95fbbc58cb0fd1c1514b3' | sha256sum -c -
    tar -xzf pack.tar.gz
    sh sovereign-intelligence/install
)
main "$@"
