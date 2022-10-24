// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_builtin_f32_isnan
// CDHECK: fcl.ss %r1, %r1, 1
// CHECK: mov %r1, %gz
bool test_builtin_f32_isnan(f32 a) { return __builtin_isnan(a); }

// CHECK-LABEL: @test_builtin_f32_copysign
// CHECK: fmerge.ss %r1, %r2, %r1, %r1
f32 test_builtin_f32_copysign(f32 a, f32 b) { return __builtin_copysignf(a, b); }

// CHECK-LABEL: @test_builtin_f64_copysign
// CHECK: fmerge.sd %r1, %r2, %r1, %r1
f64 test_builtin_f64_copysign(f64 a, f64 b) { return __builtin_copysign(a, b); }

// CHECK-LABEL: @test_builtin_f128_copysign
// CHECK: fmerge.sq %r1, %r2, %r1, %r1
f128 test_builtin_f128_copysign(f128 a, f128 b) { return __builtin_copysignl(a, b); }
