# GRACELTE (Galaxy Note7 SM-N930F, Exynos 8890): progress

Record build results, probe output, screen reports and iOS behaviour as
separate claims. Plan and hardware delta: `docs/gracelte-bringup.md`.

## 2026-10-23

- Branch `gracelte` forked from `herolte`. Hardware delta taken from
  LineageOS `android_kernel_samsung_universal8890` (lineage-18.1)
  `exynos8890-gracelte_common.dtsi` vs `exynos8890-herolte_common.dtsi`.
  **Source reading only; nothing was run on a Note7.**
- Build only: `shim/gracelte/build.sh` compiles probe and loader for the
  Note7 (aarch64-linux-gnu-gcc 13.2); `tools/mkadt_gracelte.py` builds an ADT.
  The XNU kernel is not rebuilt: gracelte uses `MACHINE_CONFIG=HEROLTE`.
- Not known yet: Note7 framebuffer address, RAM/reserved layout, touch IC
  (sec_ts 0x48 vs Atmel mXT 0x4a), BOOT partition size.

## 2026-10-24 (reported by the owner, with a physical Note7)

- Probe on the Note7: S-Boot framebuffer is `0xd8000000` (S7: `0xe2a00000`).
  Confirmed by the TWRP cmdline (`s3cfb.bootloaderfb=0xd8000000`).
- First XNU boots with the S7 constant: iOS userland ran (`exec maild`, log alive
  360 s), touch (`moves=190`, no I2C retries) and buttons worked, screen stayed black.
- Kernel rebuilt with `A5XELTE_FB_PA=0xd8000000` (commit 749c49c, run 40102874435),
  BOOT image `xnu-boot3.img` (sha256 4291de38...): Apple logo, then it booted
  straight to the **iOS lock screen**. Reported by the owner, no log attached.
- Still CPU-rendered, like the S7: no Mali-T880 driver exists in this tree.
