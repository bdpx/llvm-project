// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

/*
   1 - eq
   2 - lt
   4 - gt
   2|4 - ne
   2|1 - le
   4|1 - ge
*/
//////////////////////////////////////////////////////////////////
// f16 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f16_eq
// CHECK: fcmpshoeq %r1, %r1, %r2
bool test_compare_f16_eq(f16 a, f16 b) { return a == b; }

// CHECK-LABEL: @test_compare_f16_ne
// CHECK: fcmpshone %r1, %r1, %r2
bool test_compare_f16_ne(f16 a, f16 b) { return a != b; }

// CHECK-LABEL: @test_compare_f16_lt
// CHECK: fcmpsholt %r1, %r1, %r2
bool test_compare_f16_lt(f16 a, f16 b) { return a < b; }

// CHECK-LABEL: @test_compare_f16_le
// CHECK: fcmpshole %r1, %r1, %r2
bool test_compare_f16_le(f16 a, f16 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f16_gt
// CHECK: fcmpsholt %r1, %r2, %r1
bool test_compare_f16_gt(f16 a, f16 b) { return a > b; }

// CHECK-LABEL: @test_compare_f16_ge
// CHECK: fcmpshole %r1, %r2, %r1
bool test_compare_f16_ge(f16 a, f16 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f32 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f32_eq
// CHECK: fcmpssoeq %r1, %r1, %r2
bool test_compare_f32_eq(f32 a, f32 b) { return a == b; }

// CHECK-LABEL: @test_compare_f32_ne
// CHECK: fcmpssone %r1, %r1, %r2
bool test_compare_f32_ne(f32 a, f32 b) { return a != b; }

// CHECK-LABEL: @test_compare_f32_lt
// CHECK: fcmpssolt %r1, %r1, %r2
bool test_compare_f32_lt(f32 a, f32 b) { return a < b; }

// CHECK-LABEL: @test_compare_f32_le
// CHECK: fcmpssole %r1, %r1, %r2
bool test_compare_f32_le(f32 a, f32 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f32_gt
// CHECK: fcmpssolt %r1, %r2, %r1
bool test_compare_f32_gt(f32 a, f32 b) { return a > b; }

// CHECK-LABEL: @test_compare_f32_ge
// CHECK: fcmpssole %r1, %r2, %r1
bool test_compare_f32_ge(f32 a, f32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f64 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f64_eq
// CHECK: fcmpsdoeq %r1, %r1, %r2
bool test_compare_f64_eq(f64 a, f64 b) { return a == b; }

// CHECK-LABEL: @test_compare_f64_ne
// CHECK: fcmpsdone %r1, %r1, %r2
bool test_compare_f64_ne(f64 a, f64 b) { return a != b; }

// CHECK-LABEL: @test_compare_f64_lt
// CHECK: fcmpsdolt %r1, %r1, %r2
bool test_compare_f64_lt(f64 a, f64 b) { return a < b; }

// CHECK-LABEL: @test_compare_f64_le
// CHECK: fcmpsdole %r1, %r1, %r2
bool test_compare_f64_le(f64 a, f64 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f64_gt
// CHECK: fcmpsdolt %r1, %r2, %r1
bool test_compare_f64_gt(f64 a, f64 b) { return a > b; }

// CHECK-LABEL: @test_compare_f64_ge
// CHECK: fcmpsdole %r1, %r2, %r1
bool test_compare_f64_ge(f64 a, f64 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f128 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f128_eq
// CHECK: fcmpsqoeq %r1, %r1, %r2
bool test_compare_f128_eq(f128 a, f128 b) { return a == b; }

// CHECK-LABEL: @test_compare_f128_ne
// CHECK: fcmpsqone %r1, %r1, %r2
bool test_compare_f128_ne(f128 a, f128 b) { return a != b; }

// CHECK-LABEL: @test_compare_f128_lt
// CHECK: fcmpsqolt %r1, %r1, %r2
bool test_compare_f128_lt(f128 a, f128 b) { return a < b; }

// CHECK-LABEL: @test_compare_f128_le
// CHECK: fcmpsqole %r1, %r1, %r2
bool test_compare_f128_le(f128 a, f128 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f128_gt
// CHECK: fcmpsqolt %r1, %r2, %r1
bool test_compare_f128_gt(f128 a, f128 b) { return a > b; }

// CHECK-LABEL: @test_compare_f128_ge
// CHECK: fcmpsqole %r1, %r2, %r1
bool test_compare_f128_ge(f128 a, f128 b) { return a >= b; }

