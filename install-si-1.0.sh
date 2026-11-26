#!/bin/sh
# Sovereign Intelligence 1.0 Installer & Fail-Closed Bundle Verifier
# Pure POSIX sh. Zero telemetry. Zero piped remote execution. Zero firmware writes.
set -eu

export DO_NOT_TRACK=1
export DISABLE_TELEMETRY=1
export DISABLE_ERROR_REPORTING=1

SIM_OS=""
SIM_ARCH=""
SIM_GPU=""
DRY_RUN=0
DO_INSTALL=0
BUNDLE_DIR=""
PREFIX="${HOME:-/tmp}/.local"
PROFILE="core"
REPO_BASE="${SI_REPO_BASE:-https://interplane.io/omega}"

usage() {
    cat <<'EOF'
Usage: sh install-si-1.0.sh [OPTIONS]

Options:
  --profile core|studio|full    Component profile (default: core)
  --prefix <dir>                Installation prefix (default: $HOME/.local)
  --verify-bundle <dir>         Verify <dir>/SHA256SUMS.txt fail-closed before any action
  --install                     Install verified bundle artifacts into --prefix
  --dry-run                     Print resolved topology, plan, and verification steps only
  --sim-os linux|darwin|wsl2    Simulate host OS for cross-platform testing
  --sim-arch aarch64|arm64|x86_64  Simulate host CPU architecture
  --sim-gpu gb10|none           Simulate GB10 SM121 presence on linux-aarch64
  -h, --help                    Show this help message
EOF
}

die() {
    printf 'SI_INSTALL FAIL reason=%s\n' "$1" >&2
    exit "${2:-1}"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --profile)
            [ $# -ge 2 ] || die "missing_profile_arg" 2
            PROFILE="$2"
            shift 2
            ;;
        --prefix)
            [ $# -ge 2 ] || die "missing_prefix_arg" 2
            PREFIX="$2"
            shift 2
            ;;
        --verify-bundle)
            [ $# -ge 2 ] || die "missing_verify_bundle_arg" 2
            BUNDLE_DIR="$2"
            shift 2
            ;;
        --install)
            DO_INSTALL=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --sim-os)
            [ $# -ge 2 ] || die "missing_sim_os_arg" 2
            SIM_OS="$2"
            shift 2
            ;;
        --sim-arch)
            [ $# -ge 2 ] || die "missing_sim_arch_arg" 2
            SIM_ARCH="$2"
            shift 2
            ;;
        --sim-gpu)
            [ $# -ge 2 ] || die "missing_sim_gpu_arg" 2
            SIM_GPU="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown_option:$1" 2
            ;;
    esac
done

case "$PROFILE" in
    core|studio|full) ;;
    *) die "unsupported_profile:$PROFILE" 2 ;;
esac

case "$PREFIX" in
    ""|*..*) die "unsafe_prefix:$PREFIX" 2 ;;
esac

detect_os() {
    if [ -n "$SIM_OS" ]; then
        printf '%s' "$SIM_OS"
        return
    fi
    raw_os=$(uname -s 2>/dev/null || printf 'unknown')
    case "$raw_os" in
        Linux)
            if [ -r /proc/version ] && grep -qi 'microsoft' /proc/version 2>/dev/null; then
                printf 'wsl2'
            else
                printf 'linux'
            fi
            ;;
        Darwin)
            printf 'darwin'
            ;;
        *)
            printf '%s' "$raw_os"
            ;;
    esac
}

detect_arch() {
    if [ -n "$SIM_ARCH" ]; then
        printf '%s' "$SIM_ARCH"
        return
    fi
    uname -m 2>/dev/null || printf 'unknown'
}

detect_gb10() {
    if [ -n "$SIM_GPU" ]; then
        printf '%s' "$SIM_GPU"
        return
    fi
    # Read-only hardware topology inspection; never opens GPU device nodes.
    if [ -r /sys/devices/virtual/dmi/id/product_name ] && grep -qi 'DGX Spark' /sys/devices/virtual/dmi/id/product_name 2>/dev/null; then
        printf 'gb10'
        return
    fi
    if [ -r /proc/device-tree/model ] && grep -qi 'GB10\|Spark' /proc/device-tree/model 2>/dev/null; then
        printf 'gb10'
        return
    fi
    for vfile in /sys/bus/pci/devices/*/vendor; do
        [ -r "$vfile" ] || continue
        v=$(cat "$vfile" 2>/dev/null || printf '')
        if [ "$v" = "0x10de" ]; then
            dfile="${vfile%/vendor}/device"
            d=$(cat "$dfile" 2>/dev/null || printf '')
            case "$d" in
                0x2e12|0x2900|0x2b85|0x2c18|0x2c19)
                    printf 'gb10'
                    return
                    ;;
            esac
        fi
    done
    if [ -e /dev/aien-gpu ]; then
        printf 'gb10'
        return
    fi
    printf 'none'
}

HOST_OS=$(detect_os)
HOST_ARCH=$(detect_arch)
HOST_GPU="none"
TOPOLOGY=""

case "$HOST_OS:$HOST_ARCH" in
    linux:aarch64|linux:arm64)
        HOST_GPU=$(detect_gb10)
        case "$HOST_GPU" in
            gb10) TOPOLOGY="linux-aarch64-gb10" ;;
            none) TOPOLOGY="linux-aarch64" ;;
            *) die "unsupported_sim_gpu:$HOST_GPU" 2 ;;
        esac
        ;;
    linux:x86_64|linux:amd64)
        TOPOLOGY="linux-x86_64"
        ;;
    darwin:arm64|darwin:aarch64)
        TOPOLOGY="macos-arm64"
        ;;
    wsl2:x86_64|wsl2:amd64)
        TOPOLOGY="wsl2-x86_64"
        ;;
    *)
        die "unsupported_topology:${HOST_OS}:${HOST_ARCH}" 2
        ;;
esac

sha256_of_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        die "missing_sha256_tool" 2
    fi
}

is_hex64() {
    case "$1" in
        [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_safe_relpath() {
    case "$1" in
        ""|/*|*..*|*" "*|*"	"*|*"*"*|*"?"*|*";"*|*"|"*|*"&"*|*"$"*|*"\`"*)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

VERIFIED_COUNT=0
VERIFIED_LIST=""

verify_bundle() {
    bdir="$1"
    [ -d "$bdir" ] || die "bundle_dir_missing:$bdir" 1
    sums="$bdir/SHA256SUMS.txt"
    [ -r "$sums" ] || die "missing_SHA256SUMS.txt" 1

    VERIFIED_COUNT=0
    VERIFIED_LIST=""

    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            ""|\#*) continue ;;
        esac
        want_hash=$(printf '%s\n' "$line" | awk '{print $1}')
        rel_path=$(printf '%s\n' "$line" | awk '{print $2}')
        extra_col=$(printf '%s\n' "$line" | awk '{print $3}')
        [ -z "$extra_col" ] || die "malformed_checksum_line" 1
        is_hex64 "$want_hash" || die "malformed_sha256_hex" 1
        is_safe_relpath "$rel_path" || die "unsafe_bundle_path:$rel_path" 1
        [ "$rel_path" != "SHA256SUMS.txt" ] || die "self_referential_sums" 1

        target="$bdir/$rel_path"
        [ -f "$target" ] || die "missing_bundle_file:$rel_path" 1
        got_hash=$(sha256_of_file "$target")
        if [ "$got_hash" != "$want_hash" ]; then
            die "sha256_mismatch:$rel_path" 1
        fi
        VERIFIED_COUNT=$((VERIFIED_COUNT + 1))
        VERIFIED_LIST="${VERIFIED_LIST}
${rel_path}"
    done < "$sums"

    [ "$VERIFIED_COUNT" -gt 0 ] || die "empty_SHA256SUMS.txt" 1

    # Fail closed if any regular file in the bundle is omitted from SHA256SUMS.txt
    for candidate in $(cd "$bdir" && find . -type f | sed 's|^\./||' | LC_ALL=C sort); do
        [ "$candidate" = "SHA256SUMS.txt" ] && continue
        found=0
        old_ifs="$IFS"
        IFS='
'
        for listed in $VERIFIED_LIST; do
            [ -z "$listed" ] && continue
            if [ "$candidate" = "$listed" ]; then
                found=1
                break
            fi
        done
        IFS="$old_ifs"
        [ "$found" -eq 1 ] || die "unverified_extra_file:$candidate" 1
    done
}

install_verified_bundle() {
    bdir="$1"
    pfx="$2"
    mkdir -p "$pfx/bin" "$pfx/share/si-1.0"
    cp "$bdir/SHA256SUMS.txt" "$pfx/share/si-1.0/SHA256SUMS.txt"
    old_ifs="$IFS"
    IFS='
'
    for rel in $VERIFIED_LIST; do
        [ -z "$rel" ] && continue
        src="$bdir/$rel"
        base=$(basename "$rel")
        if [ -x "$src" ]; then
            dst="$pfx/bin/$base"
            cp "$src" "$dst.tmp"
            chmod 755 "$dst.tmp"
            mv -f "$dst.tmp" "$dst"
            if [ "$TOPOLOGY" = "macos-arm64" ] && [ "$DRY_RUN" -eq 0 ]; then
                command -v xattr >/dev/null 2>&1 && xattr -d com.apple.quarantine "$dst" 2>/dev/null || true
                command -v codesign >/dev/null 2>&1 && codesign -s - -f "$dst" >/dev/null 2>&1 || true
            fi
        else
            dst="$pfx/share/si-1.0/$base"
            cp "$src" "$dst.tmp"
            chmod 644 "$dst.tmp"
            mv -f "$dst.tmp" "$dst"
        fi
    done
    IFS="$old_ifs"
}

profile_components() {
    case "$PROFILE:$TOPOLOGY" in
        core:linux-aarch64-gb10)  printf 'omc,si,om-route,omega-gpu-driver,omega-sm121-sass' ;;
        studio:linux-aarch64-gb10) printf 'omc,si,om-route,omega-helix,omega-gpu-driver,omega-sm121-sass' ;;
        full:linux-aarch64-gb10)  printf 'omc,si,om-route,omega-helix,omega-gpu-driver,omega-sm121-sass,omega-ng-egraph,omega-wattd,rtl8127-omega' ;;
        core:*)                   printf 'omc,si,om-route' ;;
        studio:*)                 printf 'omc,si,om-route,omega-helix' ;;
        full:*)                   printf 'omc,si,om-route,omega-helix,omega-ng-egraph,omega-seats' ;;
    esac
}

print_topology_guidance() {
    case "$TOPOLOGY" in
        linux-aarch64-gb10)
            printf 'RUNTIME=pure-omega-aarch64-sm121\n'
            printf 'INSTALL_PATH=native-elf-and-zero-cuda-gb10\n'
            printf 'NOTES=DGX Spark GB10 detected; pure seeded Omega native ELF plus SM121 GPU compute (zero external GPU toolkit required)\n'
            ;;
        linux-aarch64)
            printf 'RUNTIME=pure-omega-aarch64-elf\n'
            printf 'INSTALL_PATH=native-static-elf\n'
            printf 'NOTES=Native Linux AArch64 pure seeded Omega ELF toolchain\n'
            ;;
        linux-x86_64)
            printf 'RUNTIME=pure-omega-x86linux-elf\n'
            printf 'INSTALL_PATH=static-x86linux-elf\n'
            printf 'NOTES=Native Linux x86_64 static x86linux omc ELF toolchain\n'
            ;;
        macos-arm64)
            printf 'RUNTIME=pure-omega-a64macos-macho\n'
            printf 'INSTALL_PATH=homebrew-or-verified-terminal-codesign\n'
            printf 'HOMEBREW_CMD=brew tap omega-si/omega %s/homebrew-omega.git && brew install omega-si/omega/omc\n' "$REPO_BASE"
            printf 'MACOS_POST_VERIFY=xattr -d com.apple.quarantine <bin> && codesign -s - -f <bin> (run ONLY after archive and binary SHA-256 pass)\n'
            printf 'NOTES=Apple Silicon macOS Mach-O build; zero notarization fees; avoid raw browser archive launches\n'
            ;;
        wsl2-x86_64)
            printf 'RUNTIME=pure-omega-wsl2-x86linux-elf\n'
            printf 'INSTALL_PATH=wsl2-static-x86linux-plus-online-compiler\n'
            printf 'ONLINE_COMPILER=%s/compile/\n' "$REPO_BASE"
            printf 'NOTES=Windows 10/11 via WSL 2 static x86linux ELF verified with sha256sum -c; no native Windows .exe is shipped\n'
            ;;
    esac
}

if [ -n "$BUNDLE_DIR" ]; then
    verify_bundle "$BUNDLE_DIR"
fi

COMPONENTS=$(profile_components)

printf 'TOPOLOGY=%s\n' "$TOPOLOGY"
printf 'PROFILE=%s\n' "$PROFILE"
printf 'PREFIX=%s\n' "$PREFIX"
printf 'COMPONENTS=%s\n' "$COMPONENTS"
printf 'TELEMETRY=disabled\n'
print_topology_guidance

if [ -n "$BUNDLE_DIR" ]; then
    printf 'VERIFY=PASS files=%s\n' "$VERIFIED_COUNT"
fi

if [ "$DRY_RUN" -eq 1 ]; then
    printf 'MODE=dry-run\n'
    printf 'SI_INSTALL PASS action=dry-run\n'
    exit 0
fi

if [ "$DO_INSTALL" -eq 1 ]; then
    [ -n "$BUNDLE_DIR" ] || die "install_requires_verify_bundle" 2
    install_verified_bundle "$BUNDLE_DIR" "$PREFIX"
    printf 'MODE=install\n'
    printf 'INSTALL=PASS files=%s prefix=%s\n' "$VERIFIED_COUNT" "$PREFIX"
    printf 'SI_INSTALL PASS action=install\n'
    exit 0
fi

if [ -n "$BUNDLE_DIR" ]; then
    printf 'MODE=verify-only\n'
    printf 'SI_INSTALL PASS action=verify-bundle\n'
    exit 0
fi

printf 'MODE=plan-only\n'
printf 'SI_INSTALL PASS action=plan\n'
exit 0
