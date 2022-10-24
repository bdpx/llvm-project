// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

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
