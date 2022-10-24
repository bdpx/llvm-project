// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// FLOAT-FLOAT rounding
//
// rint, nearbyint:
// rounds the floating-point argument to an integer value in floating-point format, using the current rounding mode.
// round:
// Computes the nearest integer value to arg (in floating-point format),
// rounding halfway cases away from zero, regardless of the current rounding mode.
// trunc:
// rounds to nearest integer not greater in magnitude than the given value
// floor:
// computes largest integer not greater than the given value
// ceil:
// computes smallest integer not less than the given value

// rounding mode encoding:
// 0 - nearest even
// 1 - floor
// 2 - ceil
// 3 - trunc
// 4 - use current mode

// CHECK-LABEL: @test_round_f32
// CHECK: frndss.even %r1, %r1
f32 test_round_f32(f32 value) { return __builtin_roundf(value); }
// CHECK-LABEL: @test_floor_f32
// CHECK: frndss.floor %r1, %r1
f32 test_floor_f32(f32 value) { return __builtin_floorf(value); }
// CHECK-LABEL: @test_ceil_f32
// CHECK: frndss.ceil %r1, %r1
f32 test_ceil_f32(f32 value) { return __builtin_ceilf(value); }
// CHECK-LABEL: @test_trunc_f32
// CHECK: frndss.trunc %r1, %r1
f32 test_trunc_f32(f32 value) { return __builtin_truncf(value); }
// CHECK-LABEL: @test_nearbyint_f32
// CHECK: frndss.dyn %r1, %r1
f32 test_nearbyint_f32(f32 value) { return __builtin_nearbyintf(value); }
// CHECK-LABEL: @test_rint_f32
// CHECK: frndss.dyn %r1, %r1
f32 test_rint_f32(f32 value) { return __builtin_rintf(value); }


// CHECK-LABEL: @test_round_f64
// CHECK: frndsd.even %r1, %r1
f64 test_round_f64(f64 value) { return __builtin_round(value); }
// CHECK-LABEL: @test_floor_f64
// CHECK: frndsd.floor %r1, %r1
f64 test_floor_f64(f64 value) { return __builtin_floor(value); }
// CHECK-LABEL: @test_ceil_f64
// CHECK: frndsd.ceil %r1, %r1
f64 test_ceil_f64(f64 value) { return __builtin_ceil(value); }
// CHECK-LABEL: @test_trunc_f64
// CHECK: frndsd.trunc %r1, %r1
f64 test_trunc_f64(f64 value) { return __builtin_trunc(value); }
// CHECK-LABEL: @test_nearbyint_f64
// CHECK: frndsd.dyn %r1, %r1
f64 test_nearbyint_f64(f64 value) { return __builtin_nearbyint(value); }
// CHECK-LABEL: @test_rint_f64
// CHECK: frndsd.dyn %r1, %r1
f64 test_rint_f64(f64 value) { return __builtin_rint(value); }



// CHECK-LABEL: @test_round_f128
// CHECK: frndsq.even %r1, %r1
f128 test_round_f128(f128 value) { return __builtin_roundl(value); }
// CHECK-LABEL: @test_floor_f128
// CHECK: frndsq.floor %r1, %r1
f128 test_floor_f128(f128 value) { return __builtin_floorl(value); }
// CHECK-LABEL: @test_ceil_f128
// CHECK: frndsq.ceil %r1, %r1
f128 test_ceil_f128(f128 value) { return __builtin_ceill(value); }
// CHECK-LABEL: @test_trunc_f128
// CHECK: frndsq.trunc %r1, %r1
f128 test_trunc_f128(f128 value) { return __builtin_truncl(value); }
// CHECK-LABEL: @test_nearbyint_f128
// CHECK: frndsq.dyn %r1, %r1
f128 test_nearbyint_f128(f128 value) { return __builtin_nearbyintl(value); }
// CHECK-LABEL: @test_rint_f128
// CHECK: frndsq.dyn %r1, %r1
f128 test_rint_f128(f128 value) { return __builtin_rintl(value); }
