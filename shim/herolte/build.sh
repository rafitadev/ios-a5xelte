#!/bin/sh
# Build the herolte S-Boot Images: out/probe.Image (stage-0 handoff probe)
# and out/xnu_boot.Image (XNU loader). No packaging or flashing.
# Any bare-metal or Linux aarch64 GCC works, e.g.
#   CROSS=aarch64-none-elf- sh build.sh
# BOARD=gracelte builds the Galaxy Note7 (SM-N930F) variant into out-gracelte/
# (see shim/gracelte/build.sh); FB_BASE=0x... overrides the S-Boot framebuffer
# once the probe has shown it on that phone.
set -eu
cd "$(dirname "$0")"
: "${CROSS:=aarch64-linux-gnu-}"
: "${BOARD:=herolte}"
OUT=out
BOARD_CFLAGS=""
case "$BOARD" in
    herolte) ;;
    gracelte) OUT=out-gracelte; BOARD_CFLAGS="-DBOARD_NAME=\"GRACELTE\" -DBOARD_FB_BASE=0xd8000000UL" ;;
    *) echo "unknown BOARD=$BOARD (herolte or gracelte)" >&2; exit 1 ;;
esac
[ -z "${GPU_RESET:-}" ] || { BOARD_CFLAGS="$BOARD_CFLAGS -DPROBE_GPU_RESET=1"; OUT="$OUT-gpureset"; }
[ -z "${FB_BASE:-}" ] || BOARD_CFLAGS="$BOARD_CFLAGS -DBOARD_FB_BASE=${FB_BASE}UL"
mkdir -p "$OUT"
CFLAGS="$BOARD_CFLAGS -c -O2 -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -nostdlib -fno-asynchronous-unwind-tables -fno-jump-tables -mgeneral-regs-only -mstrict-align -mcpu=cortex-a53 -Wall -Wextra -Werror"

image() {
    name=$1; shift
    objs=""
    for src in "$@"; do
        obj="$OUT/${name}_$(basename "$src" | tr . _).o"
        "${CROSS}gcc" $CFLAGS "$src" -o "$obj"
        objs="$objs $obj"
    done
    "${CROSS}ld" -static -T image.ld --build-id=none --no-warn-rwx-segments $objs -o "$OUT/$name.elf"
    # A raw Image must be position independent: no absolute relocations.
    if "${CROSS}readelf" -r $objs | grep -q 'ABS64'; then
        echo "$name: absolute relocation found" >&2
        exit 1
    fi
    "${CROSS}objcopy" -O binary "$OUT/$name.elf" "$OUT/$name.Image"
    end=$("${CROSS}nm" "$OUT/$name.elf" | awk '$3 == "_image_end" { print $1 }')
    python3 - "$OUT/$name.Image" "$end" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1]).read_bytes()
assert p[56:60] == b'ARMd', 'missing arm64 Image magic'
# --append puts the payload at the 4 KiB-padded end, which must be _image_end.
assert (len(p) + 4095) // 4096 * 4096 == int(sys.argv[2], 16), '_image_end mismatch'
print(f'{sys.argv[1]}: {len(p)} bytes; arm64 Image header OK')
PY
}

image probe probe.S probe.c fbtext.c ../fdt.c
image xnu_boot xnu_boot.S xnu_boot.c fbtext.c ../fdt.c
