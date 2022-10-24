// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_i1_and
// CHECK: and %r1, %r1, %r2
bool test_i1_and(bool a, bool b) { return a & b; }

// CHECK-LABEL: @test_i1_or
// CHECK: or %r1, %r1, %r2
bool test_i1_or(bool a, bool b) { return a | b; }

// CHECK-LABEL: @test_i1_xor
// CHECK: xor %r1, %r1, %r2
bool test_i1_xor(bool a, bool b) { return a ^ b; }

// CHECK-LABEL: @test_i1_not
// CHECK: xor_imm %r1, %r1, 1
bool test_i1_not(bool a) { return !a; }

// CHECK-LABEL: @test_i1_andn
// NOTE: andn is forbidden for i1
// CHECK: xor_imm %r1, %r1, 1
// CHECK: and %r1, %r2, %r1
bool test_i1_andn(bool a, bool b) { return !a & b; }

// CHECK-LABEL: @test_i1_orn
// NOTE: orn is forbidden for i1
// CHECK: xor_imm %r1, %r1, 1
// CHECK: or %r1, %r2, %r1
bool test_i1_orn(bool a, bool b) { return !a | b; }

// CHECK-LABEL: @test_i1_nand
// NOTE: nand is forbidden for i1
// CHECK: and %r1, %r1, %r2
// CHECK: xor_imm %r1, %r1, 1
bool test_i1_nand(bool a, bool b) { return !(a & b); }

// CHECK-LABEL: @test_i1_to_i32
// do-notning, just return
// CHECK: retf 0
i32 test_i1_to_i32(bool a) { return a; }

// CHECK-LABEL: @test_i1_to_i64
// do-notning, just return
// CHECK: retf 0
i64 test_i1_to_i64(bool a) { return a; }

// CHECK-LABEL: @test_i1_inv
// CHECK: ld_imm %r1, 1
// NOTE:
// yes, it is always true because intermediate conversion to int
// ~0=-1, ~1=-2, both are nonzero, so conversion back to bool is always true
bool test_i1_inv(bool a) { return ~a; }

bool test_imm_to_i1(void)
{
  return -1;
}

// CHECK-LABEL: @test_write_i1
void test_write_i1(void) {
  extern volatile bool test_bool_true;
  extern volatile bool test_bool_false;

  // CHECK: st_iprel_i8 %r1, %pcfwd(test_bool_true)
  test_bool_true = true;
  // CHECK: st_iprel_i8 %gz, %pcfwd(test_bool_false)
  test_bool_false = false;

  extern volatile i8 test_i8_true;
  extern volatile i8 test_i8_false;

  // CHECK: st_iprel_i8 %r1, %pcfwd(test_i8_true)
  test_i8_true = true;
  // CHECK: st_iprel_i8 %gz, %pcfwd(test_i8_false)
  test_i8_false = false;

  extern volatile i16 test_i16_true;
  extern volatile i16 test_i16_false;

  // CHECK: st_iprel_i16 %r1, %pcfwd(test_i16_true)
  test_i16_true = true;
  // CHECK: st_iprel_i16 %gz, %pcfwd(test_i16_false)
  test_i16_false = false;

  extern volatile i32 test_i32_true;
  extern volatile i32 test_i32_false;

  // CHECK: st_iprel_i32 %r1, %pcfwd(test_i32_true)
  test_i32_true = true;
  // CHECK: st_iprel_i32 %gz, %pcfwd(test_i32_false)
  test_i32_false = false;

  extern volatile i64 test_i64_true;
  extern volatile i64 test_i64_false;

  // CHECK: st_iprel_i64 %r1, %pcfwd(test_i64_true)
  test_i64_true = true;
  // CHECK: st_iprel_i64 %gz, %pcfwd(test_i64_false)
  test_i64_false = false;
}
