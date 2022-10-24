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
  // CHECK: nulfo.ne.sq %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: ld.q.r %r2, %pcfwd(left_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld.q.r %r2, %pcfwd(right_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    // CHECK: fcvt.sq.id %r2, %r1, 0
    // CHECK: st.q.xd %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld.q %r2, %r3, 160
  // CHECK: fadd.sq %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_ne
f128 test_nullify_f128_ne(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a == b)
  // CHECK: nulfo.eq.sq %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: ld.q.r %r2, %pcfwd(left_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld.q.r %r2, %pcfwd(right_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    // CHECK: fcvt.sq.id %r2, %r1, 0
    // CHECK: st.q.xd %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld.q %r2, %r3, 160
  // CHECK: fadd.sq %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_lt
f128 test_nullify_f128_lt(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a >= b) => swap args => (b <= a)
  // CHECK: nulfo.le.sq %r2, %r1, 2, 4
  if (a < b) {
    // CHECK: ld.q.r %r2, %pcfwd(left_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld.q.r %r2, %pcfwd(right_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    // CHECK: fcvt.sq.id %r2, %r1, 0
    // CHECK: st.q.xd %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld.q %r2, %r3, 160
  // CHECK: fadd.sq %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_le
f128 test_nullify_f128_le(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a > b) => swap args => (b < a)
  // CHECK: nulfo.lt.sq %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: ld.q.r %r2, %pcfwd(left_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld.q.r %r2, %pcfwd(right_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    // CHECK: fcvt.sq.id %r2, %r1, 0
    // CHECK: st.q.xd %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld.q %r2, %r3, 160
  // CHECK: fadd.sq %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_gt
f128 test_nullify_f128_gt(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a <= b)
  // CHECK: nulfo.le.sq %r1, %r2, 2, 4
  if (a > b) {
    // CHECK: ld.q.r %r2, %pcfwd(left_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld.q.r %r2, %pcfwd(right_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    // CHECK: fcvt.sq.id %r2, %r1, 0
    // CHECK: st.q.xd %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld.q %r2, %r3, 160
  // CHECK: fadd.sq %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f128_ge
f128 test_nullify_f128_ge(f128 a, f128 b, f128 c[])
{
  // CHECK: alloc 4
  f128 ret = a;
  // invert => (a < b)
  // CHECK: nulfo.lt.sq %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: ld.q.r %r2, %pcfwd(left_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    ret += left_f128;
  } else {
    // CHECK: ld.q.r %r2, %pcfwd(right_f128)
    // CHECK: fadd.sq %r1, %r2, %r1
    // CHECK: fcvt.sq.id %r2, %r1, 0
    // CHECK: st.q.xd %gz, %r3, %r2, 4, 32
    ret += right_f128;
    c[(i64)ret+2] = 0.0l;
  }
  // CHECK: ld.q %r2, %r3, 160
  // CHECK: fadd.sq %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}
