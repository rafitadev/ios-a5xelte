# TWRP zip installer for the Note7 (gracelte)

`tools/gracelte-make-zip.py` builds a zip that TWRP installs (Install, or
Advanced > ADB Sideload). It only writes the BOOT partition.

    python3 tools/gracelte-make-zip.py \
      --stock boot-stock.img --loader xnu_boot.Image --payload payload-4-fast.bin \
      --name "iOS Note7 (8 cores, 1.5 GiB)" --out ios-fast.zip
    python3 tools/gracelte-make-zip.py --image boot-stock.img \
      --name "Restore Android BOOT" --out restore-android.zip

What the zip does: refuses an N935F (gracerlte) or any other model (TWRP props),
refuses an image bigger than the BOOT partition, checks the image md5 before
and after writing (one retry), and copies the BOOT it replaces to
`/sdcard/ios-note7/boot-before-last.img` when storage is writable. The zip never
touches USERDATA, EFS or any other partition.

Tested only in a sandbox with a regular file standing in for BOOT (success,
N935F, S7, small partition, corrupted image, no device props); not yet inside a
real TWRP. If TWRP has no `unzip`, the script aborts before writing anything.
