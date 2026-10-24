# gracelte GPU (Mali-T880 MP12): what is known and the staged plan

State: **no GPU support**. iOS is CPU-rendered (`sw_new_context`, then a copy to
the DECON scanout buffer), as on the S7. Nothing here touches Mali yet.

Hardware, from LineageOS `exynos8890.dtsi` (read from source, unmeasured):

| Item | Value |
| --- | --- |
| Mali registers | `0x14AC0000`, size 0x5000 |
| IRQs (GIC SPI) | JOB 225, MMU 226, GPU 224 |
| Power domain | pd-g3d, PMU `0x105c0000 + 0x4060` (CONFIG), `+0x4064` (STATUS) |

## Stage 1 (done, read-only): `probe.Image` reads G3D state

The probe prints `G3D CONFIG`, `G3D STATUS`; only if `STATUS & 0xf == 0xf` it
also prints `MALI GPU ID`, `SHADER/TILER/L2/JS PRESENT`. If G3D is off it
prints `G3D OFF: GPU NOT READ` and writes nothing. Expected on a T880 MP12:
GPU ID product 0x0880, SHADER PRESENT 0xfff. The values are not known until a
Note7 runs it.

Result (owner's photo, Note7 N930F, read by eye so recheck digits): the probe
printed the GPU lines, not `G3D OFF`, so S-Boot leaves G3D powered with its
clock running and the Mali registers answer. GPU ID shows product 0x0880
(Mali-T880); JS PRESENT 7, tiler/L2 present 1, shader mask with 12 cores.

## Stage 2 (opt-in, writes registers): `GPU_RESET=1`

`BOARD=gracelte GPU_RESET=1 sh shim/herolte/build.sh` ->
`shim/herolte/out-gracelte-gpureset/probe.Image`. After the reads it soft-resets
the GPU (waits for RESET_COMPLETED), powers L2, tiler and shaders (waits for the
READY bitmaps), prints each result, then soft-resets again. Offsets checked
against `drivers/gpu/arm/t8xx/r12p0/mali_midg_regmap.h` (Samsung/Lineage).

## Stages that need the phone and the result of stage 1
3. Job submission and GPU MMU (Midgard, Panfrost-style) from a kernel service.
4. An iOS-side bridge (Apple's AGX stack expects its own GPU); not solved in
   this tree even for the A5's Mali-T720.
