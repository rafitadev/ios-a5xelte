# gracelte (Galaxy Note7, SM-N930F, Exynos 8890): delta from herolte

`gracelte` = Note7 (N930F). `gracerlte` = Note FE (N935F), a different board.
Same SoC as the S7, so the HEROLTE XNU config, `shim/herolte` loader and
patches 0200-0224 are the starting point. Nothing here is verified on a Note7
yet. Source: LineageOS `android_kernel_samsung_universal8890` (lineage-18.1),
`exynos8890-gracelte_common.dtsi` vs `exynos8890-herolte_common.dtsi`.

## Same as herolte (per the DTS; code should carry over)

| Item | Value |
| --- | --- |
| Touch | `sec,sec_ts` at 0x48 on HSI2C 0x14E10000, IRQ GPA1-0, 28x16 lines, 4095x4095 coords |
| Touch power | `tsp_io` = S2MPS16 LDO2, `tsp_avdd` = S2MPS16 LDO4 (same names as S7) |
| PMIC | S2MPS16 at 0x66 on HSI2C 0x10550000 |
| Buttons | Power GPA2-4, Vol- GPA0-4, Vol+ GPA0-3, Home GPA0-5 |
| Touchkeys | Cypress on i2c-gpio 0x20 (GPE5-2/3), IRQ GPA0-0 |
| DECON_F / DSIM | 0x13960000 / 0x13900000, panel 1440x2560 |
| UFS | 0x155a0000 |

## Different (check before first boot)

| Item | herolte | gracelte | Action |
| --- | --- | --- | --- |
| DRAM bank 1 | 0x80000000 + 0x7E400000 | 0x80000000 + 0x7DC00000 | XNU window 0x90000000..0xb0000000 still inside; confirm with the probe |
| Touch IC | sec_ts 0x48 (alt STM 0x49) | sec_ts 0x48 **or Atmel mXT 0x4a**; `tspid` GPE7-1 | probe both addresses; patch 0211 only speaks sec_ts |
| Panel / reserved memory | S-Boot FB 0xe2a00000 | not in the DTS | **run the probe**; if different, change `A5XELTE_FB_PA` (compile time) and use `mkadt_herolte.py --fb-base` |
| USB | micro-USB | USB-C (S2MM005 CCIC, MAX77854 MUIC) | not needed for boot; needed later for USB networking/charging |
| Battery/charger | S7 | MAX77854 + own battery dtsi | patches 0220/0221 (fuel gauge on HSI2C1) must be re-checked |
| Extras, unused for now | | S Pen (Wacom GPA0-1/GPA0-6), iris, CS47L91 audio | later |

## What exists for gracelte in this repo

| Piece | gracelte entry point | Notes |
| --- | --- | --- |
| Loader + probe | `sh shim/gracelte/build.sh` -> `shim/herolte/out-gracelte/{probe,xnu_boot}.Image` | same sources as the S7; screen text says GRACELTE; `FB_BASE=0x...` overrides the framebuffer |
| BOOT packer | `tools/gracelte-pack-boot.py` | runs `herolte-pack-boot.py` unchanged; pass the Note7's own `--partition-size` |
| ADT | `tools/mkadt_gracelte.py` (or `mkadt_herolte.py --board gracelte`) | adds `samsung,gracelte`, `gracelte-entry`; `--fb-base` for the ADT side |
| Log pull / root flash / root tuning | `tools/gracelte-log-pull.py`, `gracelte-flash-root.py`, `gracelte-tune-ios-root.sh` | same by-name paths; flash state file defaults to `gracelte-flash-root.state` |
| XNU kernel | **`MACHINE_CONFIG=HEROLTE`** (workflow default) | same SoC; patches 0200-0224 are shared, no GRACELTE machine config yet |

Verified here: the loader/probe compile for both boards, the ADT builds, the
tool front ends start. Nothing has run on a Note7.

## Open items (need the phone)

- S-Boot framebuffer address and DECON handoff on the Note7 (probe).
- RAM windows: the `0x90000000..0xb0000000` XNU window and `0x8ffff000` log
  page are the S7's; the Note7 DTB has a smaller first bank and may reserve
  differently.
- Touch IC: patch 0211 only speaks sec_ts at 0x48. The Note7 DTS also lists an
  Atmel mXT at 0x4a; if 0x48 never ACKs, an mXT driver is needed.
- Fuel gauge/charger: the Note7 DTS has the same MAX77854 on HSI2C_1
  (0x13650000) as the S7, so patches 0220/0221 should carry over; the
  capacity comes from the chip, but this is untested.
- Everything else (GPU, Wi-Fi, audio, S Pen, iris, USB-C) is missing, as on the S7.

## Steps

1. Backup BOOT and EFS from TWRP (`/dev/block/platform/155a0000.ufs/by-name/`).
2. `sh shim/gracelte/build.sh`, pack the **probe** with `tools/gracelte-pack-boot.py`
   against the Note7's own BOOT (check `--partition-size`; do not reuse the S7 value).
3. Read from the probe: FDT/initrd/image addresses, framebuffer address, MIDR/MPIDR.
4. `python3 tools/mkadt_gracelte.py gracelte.adt [--fb-base 0x...]`
   then the usual `mkpayload.py` + `pack` flow.
5. Touch: check which address answers (0x48 or 0x4a) before trusting events.
