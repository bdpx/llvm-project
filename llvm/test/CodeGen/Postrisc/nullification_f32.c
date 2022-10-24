// RUN: clang %cflags -mllvm --enable-nullification=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern f32 right_f32, left_f32;

// CHECK-LABEL: @test_nullify_f32_eq
f32 test_nullify_f32_eq(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a != b)
  // CHECK: nul_one_f32 %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(left_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(right_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    // CHECK: trunc_f32_i64 %r2, %r1
    // CHECK: st_xi64_i32 %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u32 %r2, %r3, 40
  // CHECK: add_f32 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_ne
f32 test_nullify_f32_ne(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a == b)
  // CHECK: nul_oeq_f32 %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(left_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(right_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    // CHECK: trunc_f32_i64 %r2, %r1
    // CHECK: st_xi64_i32 %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u32 %r2, %r3, 40
  // CHECK: add_f32 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_lt
f32 test_nullify_f32_lt(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a >= b) => swap args => (b <= a)
  // CHECK: nul_oge_f32 %r1, %r2, 2, 4
  if (a < b) {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(left_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(right_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    // CHECK: trunc_f32_i64 %r2, %r1
    // CHECK: st_xi64_i32 %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u32 %r2, %r3, 40
  // CHECK: add_f32 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_le
f32 test_nullify_f32_le(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a > b) => swap args => (b < a)
  // CHECK: nul_olt_f32 %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(left_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(right_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    // CHECK: trunc_f32_i64 %r2, %r1
    // CHECK: st_xi64_i32 %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u32 %r2, %r3, 40
  // CHECK: add_f32 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_gt
f32 test_nullify_f32_gt(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a <= b)
  // CHECK: nul_oge_f32 %r2, %r1, 2, 4
  if (a > b) {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(left_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(right_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    // CHECK: trunc_f32_i64 %r2, %r1
    // CHECK: st_xi64_i32 %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u32 %r2, %r3, 40
  // CHECK: add_f32 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_ge
f32 test_nullify_f32_ge(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a < b)
  // CHECK: nul_olt_f32 %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(left_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ld_iprel_u32 %r2, %pcfwd(right_f32)
    // CHECK: add_f32 %r1, %r2, %r1
    // CHECK: trunc_f32_i64 %r2, %r1
    // CHECK: st_xi64_i32 %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ld_u32 %r2, %r3, 40
  // CHECK: add_f32 %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
