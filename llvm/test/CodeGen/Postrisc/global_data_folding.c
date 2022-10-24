// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

extern i8  global_array_i8[100];
extern u8  global_array_u8[100];
extern i16 global_array_i16[100];
extern u16 global_array_u16[100];
extern i32 global_array_i32[100];
extern u32 global_array_u32[100];
extern i64 global_array_i64[100];
extern u64 global_array_u64[100];

// CHECK-LABEL: @test_global_array_folding_i8
// CHECK: lds.b.r %r1, %pcfwd(global_array_i8+5)
i8 test_global_array_folding_i8(void) { return global_array_i8[5]; }

// CHECK-LABEL: @test_global_array_folding_i16
// CHECK: lds.h.r %r1, %pcfwd(global_array_i16+10)
i16 test_global_array_folding_i16(void) { return global_array_i16[5]; }

// CHECK-LABEL: @test_global_array_folding_i32
// CHECK: ldz.w.r %r1, %pcfwd(global_array_i32+20)
i32 test_global_array_folding_i32(void) { return global_array_i32[5]; }

// CHECK-LABEL: @test_global_array_folding_i64
// CHECK: ldz.d.r %r1, %pcfwd(global_array_i64+40)
i64 test_global_array_folding_i64(void) { return global_array_i64[5]; }
