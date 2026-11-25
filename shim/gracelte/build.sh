#!/bin/sh
# Galaxy Note7 (SM-N930F, gracelte) S-Boot Images: out-gracelte/probe.Image and
# out-gracelte/xnu_boot.Image, built from the shared Exynos 8890 sources in
# shim/herolte. FB_BASE=0x... overrides the S-Boot framebuffer address once the
# probe has shown it on a Note7 (default: the S7 value, unverified here).
#   CROSS=aarch64-none-elf- FB_BASE=0xe2a00000 sh shim/gracelte/build.sh
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
BOARD=gracelte exec sh "$here/../herolte/build.sh"
