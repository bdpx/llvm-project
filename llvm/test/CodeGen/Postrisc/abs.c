// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// i32/i64 absolute value, absolute difference
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_abs
// CHECK: abs_i64 %r1, %r1
i64 test_i64_abs(i64 a) {  return __builtin_llabs(a); }

// CHECK-LABEL: @test_i32_abs
// CHECK: abs_i32 %r1, %r1
i32 test_i32_abs(i32 a) { return __builtin_labs(a); }

// CHECK-LABEL: @test_i128_abs
// CHECK: abs_i128 %r1, %r1
i128 test_i128_abs(i128 a) {  return a < 0 ? -a : a; }

// CHECK-LABEL: @test_i64_abs_difference
// CHECK: abs_diff_i64 %r1, %r2, %r1
i64 test_i64_abs_difference(i64 a, i64 b) {  return __builtin_llabs(a - b); }

// CHECK-LABEL: @test_i32_abs_difference
// CHECK: abs_diff_i32 %r1, %r2, %r1
i32 test_i32_abs_difference(i32 a, i32 b) { return __builtin_abs(a - b); }

// CHECK-LABEL: @test_i128_abs_difference
// CHECK: abs_diff_i128 %r1, %r2, %r1
i128 test_i128_abs_difference(i128 a, i128 b) {  return a < b ? (b - a) : (a - b); }
