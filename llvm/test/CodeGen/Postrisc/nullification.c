// RUN: clang %cflags -mllvm --enable-nullification=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_nullification_i64_le
i64 test_nullification_i64_le(i64 a, i64 b[], i64 c[])
{
  i64 ret = a;
  // CHECK: ld_u64 %r4, %r2, 16
  // CHECK: nul_ge_i64 %r1, %r4, 3, 4
  if (a < b[2]) {
    // CHECK: ld_xi64_u64 %r2, %r2, %r1, 3, 8
    // CHECK: mul_imm_i64 %r4, %r2, 5
    // CHECK: ld_imm %r2, 2000
    ret += 5 * b[a+1];
    ret += 2000;
  } else {
    // CHECK: ld_xi64_u64 %r4, %r3, %r1, 3, 16
    // CHECK: mul_imm_i64 %r4, %r4, 3
    // CHECK: st_xi64_i64 %gz, %r2, %r1, 3, 0
    // CHECK: ld_imm %r2, 3000
    ret += 3 * c[a+2];
    b[a] = 0;
    ret += 3000;
  }
  // CHECK: ld_xi64_u64 %r3, %r3, %r1, 3, 40
  // CHECK: add_i64 %r1, %r1, %r2
  // CHECK: add_add_i64 %r1, %r1, %r4, %r3
  ret += c[a+5];

  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullification_i64_lt
i64 test_nullification_i64_lt(i64 a, i64 b[], i64 c[])
{
  i64 ret = a;
  // CHECK: ld_u64 %r4, %r2, 16
  // CHECK: nul_lt_i64 %r4, %r1, 3, 4
  if (a <= b[2]) {
    // CHECK: ld_xi64_u64 %r2, %r2, %r1, 3, 8
    // CHECK: mul_imm_i64 %r4, %r2, 5
    // CHECK: ld_imm %r2, 2000
    ret += 5 * b[a+1];
    ret += 2000;
  } else {
    // CHECK: ld_xi64_u64 %r4, %r3, %r1, 3, 16
    // CHECK: mul_imm_i64 %r4, %r4, 3
    // CHECK: st_xi64_i64 %gz, %r2, %r1, 3, 0
    // CHECK: ld_imm %r2, 3000
    ret += 3 * c[a+2];
    b[a] = 0;
    ret += 3000;
  }
  // CHECK: ld_xi64_u64 %r3, %r3, %r1, 3, 40
  // CHECK: add_i64 %r1, %r1, %r2
  // CHECK: add_add_i64 %r1, %r1, %r4, %r3
  ret += c[a+5];

  // CHECK: retf 0
  return ret;
}

extern i64 right, left;

// CHECK-LABEL: @test_nulu_le_d
i64 test_nulu_le_d(u64 a, u64 b, u64 c[])
{
  // CHECK: alloc 4
  i64 ret = a;
  // CHECK: nul_ge_u64 %r1, %r2, 2, 3
  if (a < b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left)
    // CHECK: add_i64 %r1, %r2, %r1
    ret += left;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right)
    // CHECK: add_i64 %r1, %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r1, 3, 16
    ret += right;
    c[ret+2] = 0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_i64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
