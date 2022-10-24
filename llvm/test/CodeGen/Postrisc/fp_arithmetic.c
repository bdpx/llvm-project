// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// those tests are prepared to not fuse to fma
// those are for mul/add/sub/div only
// don't use mul-add/sub sequences here

// CHECK-LABEL: @test_fp_arithmetic_f16
f16 test_fp_arithmetic_f16(f16 a, f16 b, f16 c, f16 d) {
  f16 res1, res2;
  // CHECK: add_f16 %r3, %r2, %r1
  res1 = a + b;
  // CHECK: sub_f16 %r1, %r1, %r2
  res2 = a - b;
  // CHECK: mul_f16 %r1, %r3, %r1
  res1 = res1 * res2;
  // CHECK: div_f16 %r1, %r1, %r2
  res1 = res1 / b;
  return res1;
}

// CHECK-LABEL: @test_fp_arithmetic_f32
f32 test_fp_arithmetic_f32(f32 a, f32 b, f32 c, f32 d) {
  f32 res1, res2;
  // CHECK: add_f32 %r3, %r2, %r1
  res1 = a + b;
  // CHECK: sub_f32 %r1, %r1, %r2
  res2 = a - b;
  // CHECK: mul_f32 %r1, %r3, %r1
  res1 = res1 * res2;
  // CHECK: div_f32 %r1, %r1, %r2
  res1 = res1 / b;
  return res1;
}

// CHECK-LABEL: @test_fp_arithmetic_f64
f64 test_fp_arithmetic_f64(f64 a, f64 b, f64 c, f64 d) {
  f64 res1, res2;
  // CHECK: add_f64 %r3, %r2, %r1
  res1 = a + b;
  // CHECK: sub_f64 %r1, %r1, %r2
  res2 = a - b;
  // CHECK: mul_f64 %r1, %r3, %r1
  res1 = res1 * res2;
  // CHECK: div_f64 %r1, %r1, %r2
  res1 = res1 / b;
  return res1;
}

// CHECK-LABEL: @test_fp_arithmetic_f128
f128 test_fp_arithmetic_f128(f128 a, f128 b, f128 c, f128 d) {
  f128 res1, res2;
  // CHECK: add_f128 %r3, %r2, %r1
  res1 = a + b;
  // CHECK: sub_f128 %r1, %r1, %r2
  res2 = a - b;
  // CHECK: mul_f128 %r1, %r3, %r1
  res1 = res1 * res2;
  // CHECK: div_f128 %r1, %r1, %r2
  res1 = res1 / b;
  return res1;
}
