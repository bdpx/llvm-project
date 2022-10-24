// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// f16 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f16_eq
// CHECK: fcmpo.eq.sh %r1, %r1, %r2
bool test_compare_f16_eq(f16 a, f16 b) { return a == b; }

// CHECK-LABEL: @test_compare_f16_ne
// CHECK: fcmpo.ne.sh %r1, %r1, %r2
bool test_compare_f16_ne(f16 a, f16 b) { return a != b; }

// CHECK-LABEL: @test_compare_f16_lt
// CHECK: fcmpo.lt.sh %r1, %r1, %r2
bool test_compare_f16_lt(f16 a, f16 b) { return a < b; }

// CHECK-LABEL: @test_compare_f16_le
// CHECK: fcmpo.le.sh %r1, %r1, %r2
bool test_compare_f16_le(f16 a, f16 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f16_gt
// CHECK: fcmpo.lt.sh %r1, %r2, %r1
bool test_compare_f16_gt(f16 a, f16 b) { return a > b; }

// CHECK-LABEL: @test_compare_f16_ge
// CHECK: fcmpo.le.sh %r1, %r2, %r1
bool test_compare_f16_ge(f16 a, f16 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f32 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f32_eq
// CHECK: fcmpo.eq.ss %r1, %r1, %r2
bool test_compare_f32_eq(f32 a, f32 b) { return a == b; }

// CHECK-LABEL: @test_compare_f32_ne
// CHECK: fcmpo.ne.ss %r1, %r1, %r2
bool test_compare_f32_ne(f32 a, f32 b) { return a != b; }

// CHECK-LABEL: @test_compare_f32_lt
// CHECK: fcmpo.lt.ss %r1, %r1, %r2
bool test_compare_f32_lt(f32 a, f32 b) { return a < b; }

// CHECK-LABEL: @test_compare_f32_le
// CHECK: fcmpo.le.ss %r1, %r1, %r2
bool test_compare_f32_le(f32 a, f32 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f32_gt
// CHECK: fcmpo.lt.ss %r1, %r2, %r1
bool test_compare_f32_gt(f32 a, f32 b) { return a > b; }

// CHECK-LABEL: @test_compare_f32_ge
// CHECK: fcmpo.le.ss %r1, %r2, %r1
bool test_compare_f32_ge(f32 a, f32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f64 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f64_eq
// CHECK: fcmpo.eq.sd %r1, %r1, %r2
bool test_compare_f64_eq(f64 a, f64 b) { return a == b; }

// CHECK-LABEL: @test_compare_f64_ne
// CHECK: fcmpo.ne.sd %r1, %r1, %r2
bool test_compare_f64_ne(f64 a, f64 b) { return a != b; }

// CHECK-LABEL: @test_compare_f64_lt
// CHECK: fcmpo.lt.sd %r1, %r1, %r2
bool test_compare_f64_lt(f64 a, f64 b) { return a < b; }

// CHECK-LABEL: @test_compare_f64_le
// CHECK: fcmpo.le.sd %r1, %r1, %r2
bool test_compare_f64_le(f64 a, f64 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f64_gt
// CHECK: fcmpo.lt.sd %r1, %r2, %r1
bool test_compare_f64_gt(f64 a, f64 b) { return a > b; }

// CHECK-LABEL: @test_compare_f64_ge
// CHECK: fcmpo.le.sd %r1, %r2, %r1
bool test_compare_f64_ge(f64 a, f64 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f128 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f128_eq
// CHECK: fcmpo.eq.sq %r1, %r1, %r2
bool test_compare_f128_eq(f128 a, f128 b) { return a == b; }

// CHECK-LABEL: @test_compare_f128_ne
// CHECK: fcmpo.ne.sq %r1, %r1, %r2
bool test_compare_f128_ne(f128 a, f128 b) { return a != b; }

// CHECK-LABEL: @test_compare_f128_lt
// CHECK: fcmpo.lt.sq %r1, %r1, %r2
bool test_compare_f128_lt(f128 a, f128 b) { return a < b; }

// CHECK-LABEL: @test_compare_f128_le
// CHECK: fcmpo.le.sq %r1, %r1, %r2
bool test_compare_f128_le(f128 a, f128 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f128_gt
// CHECK: fcmpo.lt.sq %r1, %r2, %r1
bool test_compare_f128_gt(f128 a, f128 b) { return a > b; }

// CHECK-LABEL: @test_compare_f128_ge
// CHECK: fcmpo.le.sq %r1, %r2, %r1
bool test_compare_f128_ge(f128 a, f128 b) { return a >= b; }
