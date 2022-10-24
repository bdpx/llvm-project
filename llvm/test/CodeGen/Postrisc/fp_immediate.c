// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_fp_immediate_f16
// CHECK: ldhzr %r1, %pcfwd(.LCPI0_0)
f16 test_fp_immediate_f16(void) {
  return 0.123456f16;
}

// CHECK-LABEL: @test_fp_immediate_f32
// CHECK: ldwzr %r1, %pcfwd(.LCPI1_0)
f32 test_fp_immediate_f32(void) {
  return 0.123456f;
}

// CHECK-LABEL: @test_fp_immediate_f64
// CHECK: lddzr %r1, %pcfwd(.LCPI2_0)
f64 test_fp_immediate_f64(void) {
  return 0.123456;
}

// CHECK-LABEL: @test_fp_immediate_f128
// CHECK: ldqr %r1, %pcfwd(.LCPI3_0)
f128 test_fp_immediate_f128(void) {
  return 0.123456l;
}
