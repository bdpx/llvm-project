// RUN: clang %cflags -mllvm --enable-pre-post-update=1 %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_post_update
i64 test_post_update(i64 a, i64 b[], i64 c[])
{
  i64 ret = 0;
  // CHECK: ldz.d.mia %r5, %r2, 8
  // CHECK: ldz.d.mia %r6, %r3, 8
  // CHECK: addi %r1, %r1, -1
  // CHECK: mul.add %r4, %r6, %r5, %r4
  // CHECK: b.ne.d %r1, %gz, .LBB
  for (i64 i=0; i<a; i++) {
    ret += b[i] * c[i];
  }
  // CHECK: ret.f 0
  return ret;
}

