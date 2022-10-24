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
  // CHECK: nulfsqone %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: ldqr %r2, %pcfwd(left_f128)
    // CHECK: faddsq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ldqr %r2, %pcfwd(right_f128)
    // CHECK: faddsq %r1, %r2, %r1
    // CHECK: fcvtsq2id %r2, %r1, 0
    // CHECK: stqx %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ldq %r2, %r3, 160
  // CHECK: faddsq %r1, %r2, %r1
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
  // CHECK: nulfsqoeq %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: ldqr %r2, %pcfwd(left_f128)
    // CHECK: faddsq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ldqr %r2, %pcfwd(right_f128)
    // CHECK: faddsq %r1, %r2, %r1
    // CHECK: fcvtsq2id %r2, %r1, 0
    // CHECK: stqx %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ldq %r2, %r3, 160
  // CHECK: faddsq %r1, %r2, %r1
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
  // CHECK: nulfsqole %r2, %r1, 2, 4
  if (a < b) {
    // CHECK: ldqr %r2, %pcfwd(left_f128)
    // CHECK: faddsq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ldqr %r2, %pcfwd(right_f128)
    // CHECK: faddsq %r1, %r2, %r1
    // CHECK: fcvtsq2id %r2, %r1, 0
    // CHECK: stqx %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ldq %r2, %r3, 160
  // CHECK: faddsq %r1, %r2, %r1
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
  // CHECK: nulfsqolt %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: ldqr %r2, %pcfwd(left_f128)
    // CHECK: faddsq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ldqr %r2, %pcfwd(right_f128)
    // CHECK: faddsq %r1, %r2, %r1
    // CHECK: fcvtsq2id %r2, %r1, 0
    // CHECK: stqx %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ldq %r2, %r3, 160
  // CHECK: faddsq %r1, %r2, %r1
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
  // CHECK: nulfsqole %r1, %r2, 2, 4
  if (a > b) {
    // CHECK: ldqr %r2, %pcfwd(left_f128)
    // CHECK: faddsq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ldqr %r2, %pcfwd(right_f128)
    // CHECK: faddsq %r1, %r2, %r1
    // CHECK: fcvtsq2id %r2, %r1, 0
    // CHECK: stqx %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ldq %r2, %r3, 160
  // CHECK: faddsq %r1, %r2, %r1
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
  // CHECK: nulfsqolt %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: ldqr %r2, %pcfwd(left_f128)
    // CHECK: faddsq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ldqr %r2, %pcfwd(right_f128)
    // CHECK: faddsq %r1, %r2, %r1
    // CHECK: fcvtsq2id %r2, %r1, 0
    // CHECK: stqx %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ldq %r2, %r3, 160
  // CHECK: faddsq %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
