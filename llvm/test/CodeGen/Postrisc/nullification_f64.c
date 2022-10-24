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
  // CHECK: nulfsdone %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: lddzr %r2, %pcfwd(left_f64)
    // CHECK: faddsd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: lddzr %r2, %pcfwd(right_f64)
    // CHECK: faddsd %r1, %r2, %r1
    // CHECK: fcvtsd2id %r2, %r1, 0
    // CHECK: stdx %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: lddz %r2, %r3, 80
  // CHECK: faddsd %r1, %r2, %r1
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
  // CHECK: nulfsdoeq %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: lddzr %r2, %pcfwd(left_f64)
    // CHECK: faddsd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: lddzr %r2, %pcfwd(right_f64)
    // CHECK: faddsd %r1, %r2, %r1
    // CHECK: fcvtsd2id %r2, %r1, 0
    // CHECK: stdx %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: lddz %r2, %r3, 80
  // CHECK: faddsd %r1, %r2, %r1
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
  // CHECK: nulfsdole %r2, %r1, 2, 4
  if (a < b) {
    // CHECK: lddzr %r2, %pcfwd(left_f64)
    // CHECK: faddsd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: lddzr %r2, %pcfwd(right_f64)
    // CHECK: faddsd %r1, %r2, %r1
    // CHECK: fcvtsd2id %r2, %r1, 0
    // CHECK: stdx %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: lddz %r2, %r3, 80
  // CHECK: faddsd %r1, %r2, %r1
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
  // CHECK: nulfsdolt %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: lddzr %r2, %pcfwd(left_f64)
    // CHECK: faddsd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: lddzr %r2, %pcfwd(right_f64)
    // CHECK: faddsd %r1, %r2, %r1
    // CHECK: fcvtsd2id %r2, %r1, 0
    // CHECK: stdx %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: lddz %r2, %r3, 80
  // CHECK: faddsd %r1, %r2, %r1
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
  // CHECK: nulfsdole %r1, %r2, 2, 4
  if (a > b) {
    // CHECK: lddzr %r2, %pcfwd(left_f64)
    // CHECK: faddsd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: lddzr %r2, %pcfwd(right_f64)
    // CHECK: faddsd %r1, %r2, %r1
    // CHECK: fcvtsd2id %r2, %r1, 0
    // CHECK: stdx %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: lddz %r2, %r3, 80
  // CHECK: faddsd %r1, %r2, %r1
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
  // CHECK: nulfsdolt %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: lddzr %r2, %pcfwd(left_f64)
    // CHECK: faddsd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: lddzr %r2, %pcfwd(right_f64)
    // CHECK: faddsd %r1, %r2, %r1
    // CHECK: fcvtsd2id %r2, %r1, 0
    // CHECK: stdx %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: lddz %r2, %r3, 80
  // CHECK: faddsd %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
