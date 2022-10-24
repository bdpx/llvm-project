// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

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
