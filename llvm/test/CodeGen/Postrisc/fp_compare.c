// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// f16 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f16_eq
// CHECK: cmp_oeq_f16 %r1, %r1, %r2
bool test_compare_f16_eq(f16 a, f16 b) { return a == b; }

// CHECK-LABEL: @test_compare_f16_ne
// CHECK: cmp_one_f16 %r1, %r1, %r2
bool test_compare_f16_ne(f16 a, f16 b) { return a != b; }

// CHECK-LABEL: @test_compare_f16_lt
// CHECK: cmp_olt_f16 %r1, %r1, %r2
bool test_compare_f16_lt(f16 a, f16 b) { return a < b; }

// CHECK-LABEL: @test_compare_f16_le
// CHECK: cmp_ole_f16 %r1, %r1, %r2
bool test_compare_f16_le(f16 a, f16 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f16_gt
// CHECK: cmp_olt_f16 %r1, %r2, %r1
bool test_compare_f16_gt(f16 a, f16 b) { return a > b; }

// CHECK-LABEL: @test_compare_f16_ge
// CHECK: cmp_ole_f16 %r1, %r2, %r1
bool test_compare_f16_ge(f16 a, f16 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f32 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f32_eq
// CHECK: cmp_oeq_f32 %r1, %r1, %r2
bool test_compare_f32_eq(f32 a, f32 b) { return a == b; }

// CHECK-LABEL: @test_compare_f32_ne
// CHECK: cmp_one_f32 %r1, %r1, %r2
bool test_compare_f32_ne(f32 a, f32 b) { return a != b; }

// CHECK-LABEL: @test_compare_f32_lt
// CHECK: cmp_olt_f32 %r1, %r1, %r2
bool test_compare_f32_lt(f32 a, f32 b) { return a < b; }

// CHECK-LABEL: @test_compare_f32_le
// CHECK: cmp_ole_f32 %r1, %r1, %r2
bool test_compare_f32_le(f32 a, f32 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f32_gt
// CHECK: cmp_olt_f32 %r1, %r2, %r1
bool test_compare_f32_gt(f32 a, f32 b) { return a > b; }

// CHECK-LABEL: @test_compare_f32_ge
// CHECK: cmp_ole_f32 %r1, %r2, %r1
bool test_compare_f32_ge(f32 a, f32 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f64 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f64_eq
// CHECK: cmp_oeq_f64 %r1, %r1, %r2
bool test_compare_f64_eq(f64 a, f64 b) { return a == b; }

// CHECK-LABEL: @test_compare_f64_ne
// CHECK: cmp_one_f64 %r1, %r1, %r2
bool test_compare_f64_ne(f64 a, f64 b) { return a != b; }

// CHECK-LABEL: @test_compare_f64_lt
// CHECK: cmp_olt_f64 %r1, %r1, %r2
bool test_compare_f64_lt(f64 a, f64 b) { return a < b; }

// CHECK-LABEL: @test_compare_f64_le
// CHECK: cmp_ole_f64 %r1, %r1, %r2
bool test_compare_f64_le(f64 a, f64 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f64_gt
// CHECK: cmp_olt_f64 %r1, %r2, %r1
bool test_compare_f64_gt(f64 a, f64 b) { return a > b; }

// CHECK-LABEL: @test_compare_f64_ge
// CHECK: cmp_ole_f64 %r1, %r2, %r1
bool test_compare_f64_ge(f64 a, f64 b) { return a >= b; }

//////////////////////////////////////////////////////////////////
// f128 compare
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_compare_f128_eq
// CHECK: cmp_oeq_f128 %r1, %r1, %r2
bool test_compare_f128_eq(f128 a, f128 b) { return a == b; }

// CHECK-LABEL: @test_compare_f128_ne
// CHECK: cmp_one_f128 %r1, %r1, %r2
bool test_compare_f128_ne(f128 a, f128 b) { return a != b; }

// CHECK-LABEL: @test_compare_f128_lt
// CHECK: cmp_olt_f128 %r1, %r1, %r2
bool test_compare_f128_lt(f128 a, f128 b) { return a < b; }

// CHECK-LABEL: @test_compare_f128_le
// CHECK: cmp_ole_f128 %r1, %r1, %r2
bool test_compare_f128_le(f128 a, f128 b) { return a <= b; }

// CHECK-LABEL: @test_compare_f128_gt
// CHECK: cmp_olt_f128 %r1, %r2, %r1
bool test_compare_f128_gt(f128 a, f128 b) { return a > b; }

// CHECK-LABEL: @test_compare_f128_ge
// CHECK: cmp_ole_f128 %r1, %r2, %r1
bool test_compare_f128_ge(f128 a, f128 b) { return a >= b; }
