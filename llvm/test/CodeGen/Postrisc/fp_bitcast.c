// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// Those bitcasts are free:
// f16 <=> i16, f32 <=> i32, f64 <=. i64, f128 <=> i128
// expected result: input is output, return immediately

// FIXME:
// CHECK-LABEL: @test_fp_bitcast_i16_to_f16
// CHECK: alloc_sp 2, 16
// CHECK: st_i16 %r1, %sp, 14
// CHECK: ld_u16 %r1, %sp, 14
// CHECK: retf 16
f16 test_fp_bitcast_i16_to_f16(i16 value) { return BITCAST(f16)value; }

// FIXME:
// CHECK-LABEL: @test_fp_bitcast_f16_to_i16
// CHECK: alloc_sp 2, 16
// CHECK: st_i16 %r1, %sp, 14
// CHECK: ld_i16 %r1, %sp, 14
// CHECK: retf 16
i16 test_fp_bitcast_f16_to_i16(f16 value) { return BITCAST(i16)value; }


