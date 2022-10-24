// RUN: clang %cflags -mllvm --enable-nullification=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_nullification_i64_le
i64 test_nullification_i64_le(i64 a, i64 b[], i64 c[])
{
  i64 ret = a;
  // CHECK: ldz.d %r4, %r2, 16
  // CHECK: nuls.le.d %r4, %r1, 3, 4
  if (a < b[2]) {
    // CHECK: ldz.d.xd %r2, %r2, %r1, 3, 8
    // CHECK: muli %r4, %r2, 5
    // CHECK: ldi %r2, 2000
    ret += 5 * b[a+1];
    ret += 2000;
  } else {
    // CHECK: ldz.d.xd %r4, %r3, %r1, 3, 16
    // CHECK: muli %r4, %r4, 3
    // CHECK: st.d.xd %gz, %r2, %r1, 3, 0
    // CHECK: ldi %r2, 3000
    ret += 3 * c[a+2];
    b[a] = 0;
    ret += 3000;
  }
  // CHECK: ldz.d.xd %r3, %r3, %r1, 3, 40
  // CHECK: add %r1, %r1, %r2
  // CHECK: add.add %r1, %r1, %r4, %r3
  ret += c[a+5];

  // CHECK: ret.f 0
  return ret;
}

// CHECK-LABEL: @test_nullification_i64_lt
i64 test_nullification_i64_lt(i64 a, i64 b[], i64 c[])
{
  i64 ret = a;
  // CHECK: ldz.d %r4, %r2, 16
  // CHECK: nuls.lt.d %r4, %r1, 3, 4
  if (a <= b[2]) {
    // CHECK: ldz.d.xd %r2, %r2, %r1, 3, 8
    // CHECK: muli %r4, %r2, 5
    // CHECK: ldi %r2, 2000
    ret += 5 * b[a+1];
    ret += 2000;
  } else {
    // CHECK: ldz.d.xd %r4, %r3, %r1, 3, 16
    // CHECK: muli %r4, %r4, 3
    // CHECK: st.d.xd %gz, %r2, %r1, 3, 0
    // CHECK: ldi %r2, 3000
    ret += 3 * c[a+2];
    b[a] = 0;
    ret += 3000;
  }
  // CHECK: ldz.d.xd %r3, %r3, %r1, 3, 40
  // CHECK: add %r1, %r1, %r2
  // CHECK: add.add %r1, %r1, %r4, %r3
  ret += c[a+5];

  // CHECK: ret.f 0
  return ret;
}

extern i64 right, left;

// CHECK-LABEL: @test_nulu_le_d
i64 test_nulu_le_d(u64 a, u64 b, u64 c[])
{
  // CHECK: alloc 4
  i64 ret = a;
  // CHECK: nulu.le.d %r2, %r1, 2, 3
  if (a < b) {
    // CHECK: ldz.d.r %r2, %pcfwd(left)
    // CHECK: add %r1, %r2, %r1
    ret += left;
  } else {
    // CHECK: ldz.d.r %r2, %pcfwd(right)
    // CHECK: add %r1, %r2, %r1
    // CHECK: st.d.xd %gz, %r3, %r1, 3, 16
    ret += right;
    c[ret+2] = 0;
  }
  // CHECK: ldz.d %r2, %r3, 80
  // CHECK: add %r1, %r2, %r1
  ret += c[10];
  // CHECK: ret.f 0
  return ret;
}
