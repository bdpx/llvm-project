// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_clmul
v2i64 test_clmul(v2i64 a, v2i64 b)
{
  v2i64 c;
  // CHECK: clmul.ll %r3, %r1, %r2
  c = __builtin_postrisc_clmulll(a, b);
  // CHECK: clmul.hl %r1, %r1, %r3
  c = __builtin_postrisc_clmulhl(a, c);
  // CHECK: clmul.hh %r1, %r1, %r2
  c = __builtin_postrisc_clmulhh(c, b);
  return c;
}
