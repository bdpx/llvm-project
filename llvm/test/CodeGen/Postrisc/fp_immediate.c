// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_fp_immediate_f16
// OLDCHECK: ldhzr %r1, %pcfwd(.LCPI0_0)
// CHECK: ld_imm %r1, 12263
f16 test_fp_immediate_f16(void) {
  return 0.123456f16;
}

// CHECK-LABEL: @test_fp_immediate_f32
// OLDCHECK: ld_iprel_u32 %r1, %pcfwd(.LCPI1_0)
// CHECK: ld_imm.l %r1, 1039980160
f32 test_fp_immediate_f32(void) {
  return 0.123456f;
}

// CHECK-LABEL: @test_fp_immediate_f64
// OLDCHECK: ld_iprel_u64 %r1, %pcfwd(.LCPI2_0)
// CHECK: ld_imm.l %r1, -4629811673862064449
f64 test_fp_immediate_f64(void) {
  return -0.123456;
}

// CHECK-LABEL: @test_fp_immediate_f128
// CHECK: ld_imm.l %r1, -845303600433666493
// CHECK: ld_imm_high.l %r1, 4610553164962720619
f128 test_fp_immediate_f128(void) {
  return 0.123456l;
}

// CHECK-LABEL: @test_fp_immediate_f128_int
// CHECK: ld_imm %r1, 0
// CHECK: ld_imm_high.l %r1, 4612635996473786368
f128 test_fp_immediate_f128_int(void) {
  return 22.0l;
}

// CHECK-LABEL: @test_fp_immediate_f128_denorm
// CHECK: ld_imm %r1, 0
// CHECK: ld_imm_high.l %r1, -8961037358560444416
f128 test_fp_immediate_f128_denorm(void) {
  return -0x4p-15453l;
}
