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
  // CHECK: nulfo.ne.ss %r1, %r2, 2, 4
  if (a == b) {
    // CHECK: ldz.w.r %r2, %pcfwd(left_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ldz.w.r %r2, %pcfwd(right_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    // CHECK: fcvt.ss.id %r2, %r1, 0
    // CHECK: st.w.xd %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.w %r2, %r3, 40
  // CHECK: fadd.ss %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_ne
f32 test_nullify_f32_ne(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a == b)
  // CHECK: nulfo.eq.ss %r1, %r2, 2, 4
  if (a != b) {
    // CHECK: ldz.w.r %r2, %pcfwd(left_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ldz.w.r %r2, %pcfwd(right_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    // CHECK: fcvt.ss.id %r2, %r1, 0
    // CHECK: st.w.xd %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.w %r2, %r3, 40
  // CHECK: fadd.ss %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_lt
f32 test_nullify_f32_lt(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a >= b) => swap args => (b <= a)
  // CHECK: nulfo.le.ss %r2, %r1, 2, 4
  if (a < b) {
    // CHECK: ldz.w.r %r2, %pcfwd(left_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ldz.w.r %r2, %pcfwd(right_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    // CHECK: fcvt.ss.id %r2, %r1, 0
    // CHECK: st.w.xd %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.w %r2, %r3, 40
  // CHECK: fadd.ss %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_le
f32 test_nullify_f32_le(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a > b) => swap args => (b < a)
  // CHECK: nulfo.lt.ss %r2, %r1, 2, 4
  if (a <= b) {
    // CHECK: ldz.w.r %r2, %pcfwd(left_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ldz.w.r %r2, %pcfwd(right_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    // CHECK: fcvt.ss.id %r2, %r1, 0
    // CHECK: st.w.xd %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.w %r2, %r3, 40
  // CHECK: fadd.ss %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_gt
f32 test_nullify_f32_gt(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a <= b)
  // CHECK: nulfo.le.ss %r1, %r2, 2, 4
  if (a > b) {
    // CHECK: ldz.w.r %r2, %pcfwd(left_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ldz.w.r %r2, %pcfwd(right_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    // CHECK: fcvt.ss.id %r2, %r1, 0
    // CHECK: st.w.xd %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.w %r2, %r3, 40
  // CHECK: fadd.ss %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullify_f32_ge
f32 test_nullify_f32_ge(f32 a, f32 b, f32 c[])
{
  // CHECK: alloc 4
  f32 ret = a;
  // invert => (a < b)
  // CHECK: nulfo.lt.ss %r1, %r2, 2, 4
  if (a >= b) {
    // CHECK: ldz.w.r %r2, %pcfwd(left_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    ret += left_f32;
  } else {
    // CHECK: ldz.w.r %r2, %pcfwd(right_f32)
    // CHECK: fadd.ss %r1, %r2, %r1
    // CHECK: fcvt.ss.id %r2, %r1, 0
    // CHECK: st.w.xd %gz, %r3, %r2, 2, 8
    ret += right_f32;
    c[(i64)ret+2] = 0.0;
  }
  // CHECK: ldz.w %r2, %r3, 40
  // CHECK: fadd.ss %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}
