# gracelte GPU (Mali-T880 MP12): what is known and the staged plan

State (updated after merging upstream herolte 4777db5): the S7 author added
Mali-T880 XNU patches 0225-0236 (probe, first job, fragment clear, triangle,
textured quad, experimental GPU present). They are boot-arg gated (`herogpu=N`,
`sweetfb_gpu=1`); a default boot is still CPU-rendered like before. On this
branch the Mali patches draw into the Note7 scanout (`HG_FB_PA` in 0227 is
0xd8000000, not the S7's 0xe2a00000). Nothing below was run on a Note7 yet.
The probe stages further down are a bare-metal check done before that merge.

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
