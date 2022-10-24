// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// Those bitcasts are free:
// f16 <=> i16, f32 <=> i32, f64 <=. i64, f128 <=> i128
// expected result: input is output, return immediately

// FIXME:
// CHECK-LABEL: @test_fp_bitcast_i16_to_f16
// CHECK: allocsp 2, 16
// CHECK: sth %r1, %sp, 14
// CHECK: ldhz %r1, %sp, 14
// CHECK: retf 16
f16 test_fp_bitcast_i16_to_f16(i16 value) { return BITCAST(f16)value; }

// FIXME:
// CHECK-LABEL: @test_fp_bitcast_f16_to_i16
// CHECK: allocsp 2, 16
// CHECK: sth %r1, %sp, 14
// CHECK: ldhs %r1, %sp, 14
// CHECK: retf 16
i16 test_fp_bitcast_f16_to_i16(f16 value) { return BITCAST(i16)value; }

// CHECK-LABEL: @test_fp_bitcast_i32_to_f32
// CHECK: alloc 2
// CHECK: retf 0
f32 test_fp_bitcast_i32_to_f32(i32 value) { return BITCAST(f32)value; }

// CHECK-LABEL: @test_fp_bitcast_f32_to_i32
// CHECK: alloc 2
// CHECK: retf 0
i32 test_fp_bitcast_f32_to_i32(f32 value) { return BITCAST(i32)value; }

// CHECK-LABEL: @test_fp_bitcast_i64_to_f64
// CHECK: alloc 2
// CHECK: retf 0
f64 test_fp_bitcast_i64_to_f64(i64 value) { return BITCAST(f64)value; }

// CHECK-LABEL: @test_fp_bitcast_f64_to_i64
// CHECK: alloc 2
// CHECK: retf 0
i64 test_fp_bitcast_f64_to_i64(f64 value) { return BITCAST(i64)value; }

// CHECK-LABEL: @test_fp_bitcast_i128_to_f128
// CHECK: alloc 2
// CHECK: retf 0
f128 test_fp_bitcast_i128_to_f128(i128 value) { return BITCAST(f128)value; }

// CHECK-LABEL: @test_fp_bitcast_f128_to_i128
// CHECK: alloc 2
// CHECK: retf 0
i128 test_fp_bitcast_f128_to_i128(f128 value) { return BITCAST(i128)value; }


