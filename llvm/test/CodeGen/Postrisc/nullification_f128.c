// RUN: clang %cflags -mllvm --enable-nullification=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern f128 right_f128, left_f128;

// CHECK-LABEL: @test_nullify_f128_eq
f128 test_nullify_f128_eq(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a != b)
  // CHECK: nul_one_f128 %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(left_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(right_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    // CHECK: trunc_f128_i64 %r2, %r1
    // CHECK: st_xi64_i128 %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld_i128 %r2, %r3, 160
  // CHECK: add_f128 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_ne
f128 test_nullify_f128_ne(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a == b)
  // CHECK: nul_oeq_f128 %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(left_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(right_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    // CHECK: trunc_f128_i64 %r2, %r1
    // CHECK: st_xi64_i128 %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld_i128 %r2, %r3, 160
  // CHECK: add_f128 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_lt
f128 test_nullify_f128_lt(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a >= b) => swap args => (b <= a)
  // CHECK: nul_oge_f128 %r1, %r2, 2, 4
  if (a < b) {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(left_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(right_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    // CHECK: trunc_f128_i64 %r2, %r1
    // CHECK: st_xi64_i128 %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld_i128 %r2, %r3, 160
  // CHECK: add_f128 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_le
f128 test_nullify_f128_le(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a > b) => swap args => (b < a)
  // CHECK: nul_olt_f128 %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(left_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(right_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    // CHECK: trunc_f128_i64 %r2, %r1
    // CHECK: st_xi64_i128 %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld_i128 %r2, %r3, 160
  // CHECK: add_f128 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_gt
f128 test_nullify_f128_gt(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a <= b)
  // CHECK: nul_oge_f128 %r2, %r1, 2, 4
  if (a > b) {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(left_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(right_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    // CHECK: trunc_f128_i64 %r2, %r1
    // CHECK: st_xi64_i128 %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld_i128 %r2, %r3, 160
  // CHECK: add_f128 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_ge
f128 test_nullify_f128_ge(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a < b)
  // CHECK: nul_olt_f128 %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(left_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld_iprel_i128 %r2, %pcfwd(right_f128)
    // CHECK: add_f128 %r1, %r2, %r1
    // CHECK: trunc_f128_i64 %r2, %r1
    // CHECK: st_xi64_i128 %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld_i128 %r2, %r3, 160
  // CHECK: add_f128 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
