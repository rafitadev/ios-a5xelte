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
