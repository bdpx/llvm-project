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
  // CHECK: nulfo.ne.sd %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: ldz.d.r %r2, %pcfwd(left_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ldz.d.r %r2, %pcfwd(right_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    // CHECK: fcvt.sd.id %r2, %r1, 0
    // CHECK: st.d.xd %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.d %r2, %r3, 80
  // CHECK: fadd.sd %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_ne
f64 test_nullify_f64_ne(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a == b)
  // CHECK: nulfo.eq.sd %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: ldz.d.r %r2, %pcfwd(left_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ldz.d.r %r2, %pcfwd(right_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    // CHECK: fcvt.sd.id %r2, %r1, 0
    // CHECK: st.d.xd %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.d %r2, %r3, 80
  // CHECK: fadd.sd %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_lt
f64 test_nullify_f64_lt(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a >= b) => swap args => (b <= a)
  // CHECK: nulfo.le.sd %r2, %r1, 2, 4
  if (a < b) {
    // CHECK: ldz.d.r %r2, %pcfwd(left_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ldz.d.r %r2, %pcfwd(right_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    // CHECK: fcvt.sd.id %r2, %r1, 0
    // CHECK: st.d.xd %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.d %r2, %r3, 80
  // CHECK: fadd.sd %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_le
f64 test_nullify_f64_le(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a > b) => swap args => (b < a)
  // CHECK: nulfo.lt.sd %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: ldz.d.r %r2, %pcfwd(left_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ldz.d.r %r2, %pcfwd(right_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    // CHECK: fcvt.sd.id %r2, %r1, 0
    // CHECK: st.d.xd %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.d %r2, %r3, 80
  // CHECK: fadd.sd %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_gt
f64 test_nullify_f64_gt(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a <= b)
  // CHECK: nulfo.le.sd %r1, %r2, 2, 4
  if (a > b) {
    // CHECK: ldz.d.r %r2, %pcfwd(left_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ldz.d.r %r2, %pcfwd(right_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    // CHECK: fcvt.sd.id %r2, %r1, 0
    // CHECK: st.d.xd %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.d %r2, %r3, 80
  // CHECK: fadd.sd %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f64_ge
f64 test_nullify_f64_ge(f64 a, f64 b, f64 c[])
{
  // CHECK: alloc 4
  f64 ret = a;
  // invert => (a < b)
  // CHECK: nulfo.lt.sd %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: ldz.d.r %r2, %pcfwd(left_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    ret += left_f64;
  } else {
    // CHECK: ldz.d.r %r2, %pcfwd(right_f64)
    // CHECK: fadd.sd %r1, %r2, %r1
    // CHECK: fcvt.sd.id %r2, %r1, 0
    // CHECK: st.d.xd %gz, %r3, %r2, 3, 16
    ret += right_f64;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.d %r2, %r3, 80
  // CHECK: fadd.sd %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}
