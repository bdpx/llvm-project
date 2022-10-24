// RUN: clang %cflags -mllvm --enable-nullification=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern i64 right_bool, left_bool;

// CHECK-LABEL: @test_nullify_bool
i64 test_nullify_bool(bool a, bool b, i64 c[])
{
  // CHECK: alloc 4
  i64 ret = a;
  // (a != 0) => invert => (a == 0)
  // CHECK: nul_bc_imm %r1, 0, 2, 3
  if (a) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    ret += left_bool;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r1, 3, 16
    ret += right_bool;
    c[ret+2] = 0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_i64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_bool_not
i64 test_nullify_bool_not(bool a, bool b, i64 c[])
{
  // CHECK: alloc 4
  i64 ret = a;
  // invert => (a != 0)
  // CHECK: nul_bs_imm %r1, 0, 2, 3
  if (!a) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    ret += left_bool;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r1, 3, 16
    ret += right_bool;
    c[ret+2] = 0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_i64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// FIXME: not nullified
// CHECK-LABEL: @test_nullify_bool_and
i64 test_nullify_bool_and(bool a, bool b, i64 c[])
{
  // CHECK: alloc 4
  i64 ret = a;
  // CHECK: br_bc_imm %r1, 0, .LBB
  // CHECK: br_bc_imm %r2, 0, .LBB
  if (a && b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    // CHECK: jmp .LBB
    ret += left_bool;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r1, 3, 16
    ret += right_bool;
    c[ret+2] = 0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_i64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// FIXME: not nullified
// CHECK-LABEL: @test_nullify_bool_or
i64 test_nullify_bool_or(bool a, bool b, i64 c[])
{
  // CHECK: alloc 4
  i64 ret = a;
  // CHECK: br_bs_imm %r1, 0, .LBB
  // CHECK: br_bs_imm %r2, 0, .LBB
  if (a || b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r1, 3, 16
    // CHECK: jmp .LBB
    ret += left_bool;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_bool)
    // CHECK: add_i64 %r1, %r2, %r1
    ret += right_bool;
    c[ret+2] = 0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_i64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
