// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

extern i32 test_mov2_callback(i32 a, i32 b, i32 c, i32 d);

// CHECK-LABEL: @test_mov2
int test_mov2(i32 a, i32 b, i32 c, i32 d)
{
  // CHECK: alloc 11
  i32 ret = a;

  // CHECK: mov2 %r7, %r8, %r3, %r4
  // CHECK: mov2 %r9, %r10, %r2, %r1
  // CHECK: call %r6, %jpc(test_mov2_callback)
  // CHECK: add_i32 %r5, %r7, %r1
  ret += test_mov2_callback(c, d, b, a);

  // CHECK: mov2 %r7, %r8, %r3, %r4
  // CHECK: mov2 %r9, %r10, %r2, %gz
  // CHECK: call %r6, %jpc(test_mov2_callback)
  // CHECK: add_i32 %r2, %r5, %r7
  ret += test_mov2_callback(c, d, b, 0);

  // CHECK: mov2 %r7, %r8, %r3, %r4
  // CHECK: mov2 %r9, %r10, %gz, %gz
  // CHECK: call %r6, %jpc(test_mov2_callback)
  // CHECK: add_i32 %r2, %r2, %r7
  ret += test_mov2_callback(c, d, 0, 0);

  // CHECK: mov2 %r7, %r8, %r3, %gz
  // CHECK: mov2 %r9, %r10, %gz, %gz
  // CHECK: call %r6, %jpc(test_mov2_callback)
  // CHECK: add_i32 %r2, %r2, %r7
  ret += test_mov2_callback(c, 0, 0, 0);

  // CHECK: mov2 %r7, %r8, %gz, %gz
  // CHECK: mov2 %r9, %r10, %gz, %gz
  // CHECK: call %r6, %jpc(test_mov2_callback)
  ret += test_mov2_callback(0, 0, 0, 0);

  // CHECK: add_i32 %r1, %r2, %r7
  // CHECK: retf 0
  return ret;
}
