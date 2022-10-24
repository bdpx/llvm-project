// RUN: clang %cflags -mcmodel=small %s | FileCheck %s --check-prefixes=SMALL
// RUN: clang %cflags -mcmodel=medium %s | FileCheck %s --check-prefixes=MEDIUM
// RUN: clang %cflags -mcmodel=large %s | FileCheck %s --check-prefixes=LARGE
// REQUIRES: postrisc-registered-target

//

#include "common.h"

volatile i64 x_bss = 0;
extern volatile i64 x_bss_extern;

// MEDIUM-LABEL: @test_global_data
i64 test_global_data(i64 a)
{
  // SMALL: ld_iprel_u64 %r2, %pcfwd(x_bss)
  // SMALL: st_iprel_i64 %r2, %pcfwd(x_bss)
  // MEDIUM: ld_iprel_u64.l %r2, %pcfwd_ext(x_bss)
  // MEDIUM: st_iprel_i64.l %r2, %pcfwd_ext(x_bss)
  // LARGE: ld_iprel_u64.l %r2, %pcfwd_ext(x_bss)
  // LARGE: st_iprel_i64.l %r2, %pcfwd_ext(x_bss)
  ++x_bss;
  // SMALL: ld_iprel_u64 %r2, %pcfwd(x_bss_extern)
  // SMALL: st_iprel_i64 %r2, %pcfwd(x_bss_extern)
  // MEDIUM: ld_iprel_u64.l %r2, %pcfwd_ext(x_bss_extern)
  // MEDIUM: st_iprel_i64.l %r2, %pcfwd_ext(x_bss_extern)
  // LARGE: ld_iprel_u64.l %r2, %pcfwd_ext(x_bss_extern)
  // LARGE: st_iprel_i64.l %r2, %pcfwd_ext(x_bss_extern)
  ++x_bss_extern;
  return a;
}

extern i8  global_i8;
extern u8  global_u8;
extern i16 global_i16;
extern u16 global_u16;
extern i32 global_i32;
extern u32 global_u32;
extern i64 global_i64;
extern u64 global_u64;

// SMALL-LABEL: @test_global_i8_ptr
// MEDIUM-LABEL: @test_global_i8_ptr
i8* test_global_i8_ptr(void)
{
  // SMALL: lda_iprel %r1, %pcfwd(global_i8)
  // MEDIUM: lda_iprel.l %r1, %pcfwd_ext(global_i8)
  return &global_i8;
}

// SMALL-LABEL: @test_global_i8
// MEDIUM-LABEL: @test_global_i8
// SMALL: ld_iprel_i8 %r1, %pcfwd(global_i8)
// MEDIUM: ld_iprel_i8.l %r1, %pcfwd_ext(global_i8)
i8 test_global_i8(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8
// MEDIUM-LABEL: @test_global_u8
// SMALL: ld_iprel_u8 %r1, %pcfwd(global_u8)
// MEDIUM: ld_iprel_u8.l %r1, %pcfwd_ext(global_u8)
u8 test_global_u8(void) { return global_u8; }

// SMALL-LABEL: @test_global_i16
// MEDIUM-LABEL: @test_global_i16
// SMALL: ld_iprel_i16 %r1, %pcfwd(global_i16)
// MEDIUM: ld_iprel_i16.l %r1, %pcfwd_ext(global_i16)
i16 test_global_i16(void) { return global_i16; }

// SMALL-LABEL: @test_global_u16
// MEDIUM-LABEL: @test_global_u16
// SMALL: ld_iprel_u16 %r1, %pcfwd(global_u16)
// MEDIUM: ld_iprel_u16.l %r1, %pcfwd_ext(global_u16)
u16 test_global_u16(void) { return global_u16; }

// SMALL-LABEL: @test_global_i8_to_i16
// MEDIUM-LABEL: @test_global_i8_to_i16
// SMALL: ld_iprel_i8 %r1, %pcfwd(global_i8)
// MEDIUM: ld_iprel_i8.l %r1, %pcfwd_ext(global_i8)
i16 test_global_i8_to_i16(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8_to_u16
// MEDIUM-LABEL: @test_global_u8_to_u16
// SMALL: ld_iprel_u8 %r1, %pcfwd(global_u8)
// MEDIUM: ld_iprel_u8.l %r1, %pcfwd_ext(global_u8)
u16 test_global_u8_to_u16(void) { return global_u8; }

// SMALL-LABEL: @test_global_i32
// MEDIUM-LABEL: @test_global_i32
// FIXME: lds4r
// SMALL: ld_iprel_u32 %r1, %pcfwd(global_i32)
// MEDIUM: ld_iprel_u32.l %r1, %pcfwd_ext(global_i32)
i32 test_global_i32(void) { return global_i32; }

// SMALL-LABEL: @test_global_u32
// MEDIUM-LABEL: @test_global_u32
// SMALL: ld_iprel_u32 %r1, %pcfwd(global_u32)
// MEDIUM: ld_iprel_u32.l %r1, %pcfwd_ext(global_u32)
u32 test_global_u32(void) { return global_u32; }

// SMALL-LABEL: @test_global_i8_to_i32
// MEDIUM-LABEL: @test_global_i8_to_i32
// SMALL: ld_iprel_i8 %r1, %pcfwd(global_i8)
// MEDIUM: ld_iprel_i8.l %r1, %pcfwd_ext(global_i8)
i32 test_global_i8_to_i32(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8_to_u32
// MEDIUM-LABEL: @test_global_u8_to_u32
// SMALL: ld_iprel_u8 %r1, %pcfwd(global_u8)
// MEDIUM: ld_iprel_u8.l %r1, %pcfwd_ext(global_u8)
u32 test_global_u8_to_u32(void) { return global_u8; }

// SMALL-LABEL: @test_global_i16_to_i32
// MEDIUM-LABEL: @test_global_i16_to_i32
// SMALL: ld_iprel_i16 %r1, %pcfwd(global_i16)
// MEDIUM: ld_iprel_i16.l %r1, %pcfwd_ext(global_i16)
i32 test_global_i16_to_i32(void) { return global_i16; }

// SMALL-LABEL: @test_global_u16_to_u32
// MEDIUM-LABEL: @test_global_u16_to_u32
// SMALL: ld_iprel_u16 %r1, %pcfwd(global_u16)
// MEDIUM: ld_iprel_u16.l %r1, %pcfwd_ext(global_u16)
u32 test_global_u16_to_u32(void) { return global_u16; }

// SMALL-LABEL: @test_global_i8_to_i64
// MEDIUM-LABEL: @test_global_i8_to_i64
// SMALL: ld_iprel_i8 %r1, %pcfwd(global_i8)
// MEDIUM: ld_iprel_i8.l %r1, %pcfwd_ext(global_i8)
i64 test_global_i8_to_i64(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8_to_u64
// MEDIUM-LABEL: @test_global_u8_to_u64
// SMALL: ld_iprel_u8 %r1, %pcfwd(global_u8)
// MEDIUM: ld_iprel_u8.l %r1, %pcfwd_ext(global_u8)
u64 test_global_u8_to_u64(void) { return global_u8; }

// SMALL-LABEL: @test_global_i16_to_i64
// MEDIUM-LABEL: @test_global_i16_to_i64
// SMALL: ld_iprel_i16 %r1, %pcfwd(global_i16)
// MEDIUM: ld_iprel_i16.l %r1, %pcfwd_ext(global_i16)
i64 test_global_i16_to_i64(void) { return global_i16; }

// SMALL-LABEL: @test_global_u16_to_u64
// MEDIUM-LABEL: @test_global_u16_to_u64
// SMALL: ld_iprel_u16 %r1, %pcfwd(global_u16)
// MEDIUM: ld_iprel_u16.l %r1, %pcfwd_ext(global_u16)
u64 test_global_u16_to_u64(void) { return global_u16; }

// SMALL-LABEL: @test_global_i32_to_i64
// MEDIUM-LABEL: @test_global_i32_to_i64
// SMALL: ld_iprel_i32 %r1, %pcfwd(global_i32)
// MEDIUM: ld_iprel_i32.l %r1, %pcfwd_ext(global_i32)
i64 test_global_i32_to_i64(void) { return global_i32; }

// SMALL-LABEL: @test_global_u32_to_u64
// MEDIUM-LABEL: @test_global_u32_to_u64
// SMALL: ld_iprel_u32 %r1, %pcfwd(global_u32)
// MEDIUM: ld_iprel_u32.l %r1, %pcfwd_ext(global_u32)
u64 test_global_u32_to_u64(void) { return global_u32; }

// SMALL-LABEL: @test_global_i64
// MEDIUM-LABEL: @test_global_i64
// FIXME: lds8r
// SMALL: ld_iprel_u64 %r1, %pcfwd(global_i64)
// MEDIUM: ld_iprel_u64.l %r1, %pcfwd_ext(global_i64)
i64 test_global_i64(void) { return global_i64; }

// SMALL-LABEL: @test_global_u64
// MEDIUM-LABEL: @test_global_u64
// SMALL: ld_iprel_u64 %r1, %pcfwd(global_u64)
// MEDIUM: ld_iprel_u64.l %r1, %pcfwd_ext(global_u64)
u64 test_global_u64(void) { return global_u64; }

