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
  // SMALL: ldz.d.r %r2, %pcfwd(x_bss)
  // SMALL: st.d.r %r2, %pcfwd(x_bss)
  // MEDIUM: ldz.d.r.l %r2, %pcfwd_ext(x_bss)
  // MEDIUM: st.d.r.l %r2, %pcfwd_ext(x_bss)
  // LARGE: ldz.d.r.l %r2, %pcfwd_ext(x_bss)
  // LARGE: st.d.r.l %r2, %pcfwd_ext(x_bss)
  ++x_bss;
  // SMALL: ldz.d.r %r2, %pcfwd(x_bss_extern)
  // SMALL: st.d.r %r2, %pcfwd(x_bss_extern)
  // MEDIUM: ldz.d.r.l %r2, %pcfwd_ext(x_bss_extern)
  // MEDIUM: st.d.r.l %r2, %pcfwd_ext(x_bss_extern)
  // LARGE: ldz.d.r.l %r2, %pcfwd_ext(x_bss_extern)
  // LARGE: st.d.r.l %r2, %pcfwd_ext(x_bss_extern)
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
  // SMALL: ca.rf %r1, %pcfwd(global_i8)
  // MEDIUM: ca.rf.l %r1, %pcfwd_ext(global_i8)
  return &global_i8;
}

// SMALL-LABEL: @test_global_i8
// MEDIUM-LABEL: @test_global_i8
// SMALL: lds.b.r %r1, %pcfwd(global_i8)
// MEDIUM: lds.b.r.l %r1, %pcfwd_ext(global_i8)
i8 test_global_i8(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8
// MEDIUM-LABEL: @test_global_u8
// SMALL: ldz.b.r %r1, %pcfwd(global_u8)
// MEDIUM: ldz.b.r.l %r1, %pcfwd_ext(global_u8)
u8 test_global_u8(void) { return global_u8; }

// SMALL-LABEL: @test_global_i16
// MEDIUM-LABEL: @test_global_i16
// SMALL: lds.h.r %r1, %pcfwd(global_i16)
// MEDIUM: lds.h.r.l %r1, %pcfwd_ext(global_i16)
i16 test_global_i16(void) { return global_i16; }

// SMALL-LABEL: @test_global_u16
// MEDIUM-LABEL: @test_global_u16
// SMALL: ldz.h.r %r1, %pcfwd(global_u16)
// MEDIUM: ldz.h.r.l %r1, %pcfwd_ext(global_u16)
u16 test_global_u16(void) { return global_u16; }

// SMALL-LABEL: @test_global_i8_to_i16
// MEDIUM-LABEL: @test_global_i8_to_i16
// SMALL: lds.b.r %r1, %pcfwd(global_i8)
// MEDIUM: lds.b.r.l %r1, %pcfwd_ext(global_i8)
i16 test_global_i8_to_i16(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8_to_u16
// MEDIUM-LABEL: @test_global_u8_to_u16
// SMALL: ldz.b.r %r1, %pcfwd(global_u8)
// MEDIUM: ldz.b.r.l %r1, %pcfwd_ext(global_u8)
u16 test_global_u8_to_u16(void) { return global_u8; }

// SMALL-LABEL: @test_global_i32
// MEDIUM-LABEL: @test_global_i32
// FIXME: lds4r
// SMALL: ldz.w.r %r1, %pcfwd(global_i32)
// MEDIUM: ldz.w.r.l %r1, %pcfwd_ext(global_i32)
i32 test_global_i32(void) { return global_i32; }

// SMALL-LABEL: @test_global_u32
// MEDIUM-LABEL: @test_global_u32
// SMALL: ldz.w.r %r1, %pcfwd(global_u32)
// MEDIUM: ldz.w.r.l %r1, %pcfwd_ext(global_u32)
u32 test_global_u32(void) { return global_u32; }

// SMALL-LABEL: @test_global_i8_to_i32
// MEDIUM-LABEL: @test_global_i8_to_i32
// SMALL: lds.b.r %r1, %pcfwd(global_i8)
// MEDIUM: lds.b.r.l %r1, %pcfwd_ext(global_i8)
i32 test_global_i8_to_i32(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8_to_u32
// MEDIUM-LABEL: @test_global_u8_to_u32
// SMALL: ldz.b.r %r1, %pcfwd(global_u8)
// MEDIUM: ldz.b.r.l %r1, %pcfwd_ext(global_u8)
u32 test_global_u8_to_u32(void) { return global_u8; }

// SMALL-LABEL: @test_global_i16_to_i32
// MEDIUM-LABEL: @test_global_i16_to_i32
// SMALL: lds.h.r %r1, %pcfwd(global_i16)
// MEDIUM: lds.h.r.l %r1, %pcfwd_ext(global_i16)
i32 test_global_i16_to_i32(void) { return global_i16; }

// SMALL-LABEL: @test_global_u16_to_u32
// MEDIUM-LABEL: @test_global_u16_to_u32
// SMALL: ldz.h.r %r1, %pcfwd(global_u16)
// MEDIUM: ldz.h.r.l %r1, %pcfwd_ext(global_u16)
u32 test_global_u16_to_u32(void) { return global_u16; }

// SMALL-LABEL: @test_global_i8_to_i64
// MEDIUM-LABEL: @test_global_i8_to_i64
// SMALL: lds.b.r %r1, %pcfwd(global_i8)
// MEDIUM: lds.b.r.l %r1, %pcfwd_ext(global_i8)
i64 test_global_i8_to_i64(void) { return global_i8; }

// SMALL-LABEL: @test_global_u8_to_u64
// MEDIUM-LABEL: @test_global_u8_to_u64
// SMALL: ldz.b.r %r1, %pcfwd(global_u8)
// MEDIUM: ldz.b.r.l %r1, %pcfwd_ext(global_u8)
u64 test_global_u8_to_u64(void) { return global_u8; }

// SMALL-LABEL: @test_global_i16_to_i64
// MEDIUM-LABEL: @test_global_i16_to_i64
// SMALL: lds.h.r %r1, %pcfwd(global_i16)
// MEDIUM: lds.h.r.l %r1, %pcfwd_ext(global_i16)
i64 test_global_i16_to_i64(void) { return global_i16; }

// SMALL-LABEL: @test_global_u16_to_u64
// MEDIUM-LABEL: @test_global_u16_to_u64
// SMALL: ldz.h.r %r1, %pcfwd(global_u16)
// MEDIUM: ldz.h.r.l %r1, %pcfwd_ext(global_u16)
u64 test_global_u16_to_u64(void) { return global_u16; }

// SMALL-LABEL: @test_global_i32_to_i64
// MEDIUM-LABEL: @test_global_i32_to_i64
// SMALL: lds.w.r %r1, %pcfwd(global_i32)
// MEDIUM: lds.w.r.l %r1, %pcfwd_ext(global_i32)
i64 test_global_i32_to_i64(void) { return global_i32; }

// SMALL-LABEL: @test_global_u32_to_u64
// MEDIUM-LABEL: @test_global_u32_to_u64
// SMALL: ldz.w.r %r1, %pcfwd(global_u32)
// MEDIUM: ldz.w.r.l %r1, %pcfwd_ext(global_u32)
u64 test_global_u32_to_u64(void) { return global_u32; }

// SMALL-LABEL: @test_global_i64
// MEDIUM-LABEL: @test_global_i64
// FIXME: lds8r
// SMALL: ldz.d.r %r1, %pcfwd(global_i64)
// MEDIUM: ldz.d.r.l %r1, %pcfwd_ext(global_i64)
i64 test_global_i64(void) { return global_i64; }

// SMALL-LABEL: @test_global_u64
// MEDIUM-LABEL: @test_global_u64
// SMALL: ldz.d.r %r1, %pcfwd(global_u64)
// MEDIUM: ldz.d.r.l %r1, %pcfwd_ext(global_u64)
u64 test_global_u64(void) { return global_u64; }

