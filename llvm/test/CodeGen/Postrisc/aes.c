// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_aes
v2i64 test_aes(v2i64 a, v2i64 b)
{
// CHECK: aesimc %r2, %r1
   v2i64 c = __builtin_postrisc_aesimc(a);

// CHECK: aeskeygenassist %r2, %r2, 100
   c = __builtin_postrisc_aeskeygenassist(c, 100);

// CHECK: aeskeygenassist %r2, %r2, -1
   c = __builtin_postrisc_aeskeygenassist(c,255);

// CHECK: aesenc %r2, %r1, %r2
   c = __builtin_postrisc_aesenc(a, c);
// CHECK: aesdec %r2, %r1, %r2
   c = __builtin_postrisc_aesdec(a, c);
// CHECK: aesenclast %r2, %r1, %r2
   c = __builtin_postrisc_aesenclast(a, c);
// CHECK: aesdeclast %r1, %r1, %r2
   c = __builtin_postrisc_aesdeclast(a, c);
   return c;
}
