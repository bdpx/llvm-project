// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

//////////////////////////////////////////////////////////////////
// i32/i64 absolute value, absolute difference
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_i64_abs
// CHECK: absd %r1, %r1, %gz
i64 test_i64_abs(i64 a) {  return __builtin_llabs(a); }

// CHECK-LABEL: @test_i32_abs
// CHECK: absd.w %r1, %r1, %gz
i32 test_i32_abs(i32 a) { return __builtin_labs(a); }

// CHECK-LABEL: @test_i64_abs_difference
// CHECK: absd %r1, %r2, %r1
i64 test_i64_abs_difference(i64 a, i64 b) {  return __builtin_llabs(a - b); }

// CHECK-LABEL: @test_i32_abs_difference
// CHECK: absd.w %r1, %r2, %r1
i32 test_i32_abs_difference(i32 a, i32 b) { return __builtin_abs(a - b); }

