// RUN: clang %cflags -mllvm --enable-nullification=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_nullification_i64_le
i64 test_nullification_i64_le(i64 a, i64 b[], i64 c[])
{
  i64 ret = a;
  // CHECK: lddz %r4, %r2, 16
  // CHECK: nuldle %r4, %r1, 3, 4
  if (a < b[2]) {
    // CHECK: lddzx %r2, %r2, %r1, 3, 8
    // CHECK: muli %r4, %r2, 5
    // CHECK: ldi %r2, 2000
    ret += 5 * b[a+1];
    ret += 2000;
  } else {
    // CHECK: lddzx %r4, %r3, %r1, 3, 16
    // CHECK: muli %r4, %r4, 3
    // CHECK: stdx %gz, %r2, %r1, 3, 0
    // CHECK: ldi %r2, 3000
    ret += 3 * c[a+2];
    b[a] = 0;
    ret += 3000;
  }
  // CHECK: lddzx %r3, %r3, %r1, 3, 40
  // CHECK: add %r1, %r1, %r2
  // CHECK: addadd %r1, %r1, %r4, %r3
  ret += c[a+5];

  // CHECK: retf 0
  return ret;
}

// CHECK-LABEL: @test_nullification_i64_lt
i64 test_nullification_i64_lt(i64 a, i64 b[], i64 c[])
{
  i64 ret = a;
  // CHECK: lddz %r4, %r2, 16
  // CHECK: nuldlt %r4, %r1, 3, 4
  if (a <= b[2]) {
    // CHECK: lddzx %r2, %r2, %r1, 3, 8
    // CHECK: muli %r4, %r2, 5
    // CHECK: ldi %r2, 2000
    ret += 5 * b[a+1];
    ret += 2000;
  } else {
    // CHECK: lddzx %r4, %r3, %r1, 3, 16
    // CHECK: muli %r4, %r4, 3
    // CHECK: stdx %gz, %r2, %r1, 3, 0
    // CHECK: ldi %r2, 3000
    ret += 3 * c[a+2];
    b[a] = 0;
    ret += 3000;
  }
  // CHECK: lddzx %r3, %r3, %r1, 3, 40
  // CHECK: add %r1, %r1, %r2
  // CHECK: addadd %r1, %r1, %r4, %r3
  ret += c[a+5];

  // CHECK: retf 0
  return ret;
}

extern i64 right, left;

// CHECK-LABEL: @test_nuldleu
i64 test_nuldleu(u64 a, u64 b, u64 c[])
{
  // CHECK: alloc 4
  i64 ret = a;
  // CHECK: nuldleu %r2, %r1, 2, 3
  if (a < b) {
    // CHECK: lddzr %r2, %pcfwd(left)
    // CHECK: add %r1, %r2, %r1
    ret += left;
  } else {
    // CHECK: lddzr %r2, %pcfwd(right)
    // CHECK: add %r1, %r2, %r1
    // CHECK: stdx %gz, %r3, %r1, 3, 16
    ret += right;
    c[ret+2] = 0;
  }
  // CHECK: lddz %r2, %r3, 80
  // CHECK: add %r1, %r2, %r1
  ret += c[10];
  // CHECK: retf 0
  return ret;
}
