// RUN: clang %cflags -mllvm --enable-nullification=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern f64 right_f64, left_f64;

// CHECK-LABEL: @test_nullify_f64_eq
f64 test_nullify_f64_eq(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a != b)
  // CHECK: nul_one_f64 %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    // CHECK: trunc_f64_i64 %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_f64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_ne
f64 test_nullify_f64_ne(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a == b)
  // CHECK: nul_oeq_f64 %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    // CHECK: trunc_f64_i64 %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_f64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_lt
f64 test_nullify_f64_lt(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a >= b) => swap args => (b <= a)
  // CHECK: nul_oge_f64 %r1, %r2, 2, 4
  if (a < b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    // CHECK: trunc_f64_i64 %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_f64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_le
f64 test_nullify_f64_le(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a > b) => swap args => (b < a)
  // CHECK: nul_olt_f64 %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    // CHECK: trunc_f64_i64 %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_f64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_gt
f64 test_nullify_f64_gt(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a <= b)
  // CHECK: nul_oge_f64 %r2, %r1, 2, 4
  if (a > b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    // CHECK: trunc_f64_i64 %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_f64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_ge
f64 test_nullify_f64_ge(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a < b)
  // CHECK: nul_olt_f64 %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(left_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ld_iprel_u64 %r2, %pcfwd(right_f64)
    // CHECK: add_f64 %r1, %r2, %r1
    // CHECK: trunc_f64_i64 %r2, %r1
    // CHECK: st_xi64_i64 %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u64 %r2, %r3, 80
  // CHECK: add_f64 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
