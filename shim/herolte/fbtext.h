/* SPDX-License-Identifier: GPL-2.0-only */
#pragma once
#include <stdint.h>

/* Board selection: build.sh passes -DBOARD_NAME=\"GRACELTE\" (Galaxy Note7,
 * SM-N930F) and, once the probe has shown it, -DBOARD_FB_BASE=0x...UL. The
 * Note7 value is NOT known yet: it defaults to the S7 address below. */
#ifndef BOARD_NAME
#define BOARD_NAME "HEROLTE"
#endif
/* S-Boot scanout buffer (uniLoader board-herolte.c). */
#ifndef BOARD_FB_BASE
#define BOARD_FB_BASE 0xe2a00000UL
#endif
#define HERO_FB_BASE BOARD_FB_BASE
#define HERO_FB_WIDTH 1440U
#define HERO_FB_HEIGHT 2560U

/* Let CPU writes reach the panel (DECON_F HW trigger), returns old value. */
uint32_t hero_fb_enable(void);
void hero_fb_text(unsigned row, const char *s);
void hero_fb_hex(unsigned row, const char *label, uint64_t value);
