// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_aesenc
v2i64 test_aesenc(v2i64 a, v2i64 b)
{
// CHECK: aes_enc %r1, %r1, %r2
  return __builtin_postrisc_aesenc(a, b);
}

// CHECK-LABEL: @test_aesenclast
v2i64 test_aesenclast(v2i64 a, v2i64 b)
{
// CHECK: aes_enc_last %r1, %r1, %r2
  return __builtin_postrisc_aesenclast(a, b);
}

// CHECK-LABEL: @test_aesdec
v2i64 test_aesdec(v2i64 a, v2i64 b)
{
// CHECK: aes_dec %r1, %r1, %r2
  return __builtin_postrisc_aesdec(a, b);
}

// CHECK-LABEL: @test_aesdeclast
v2i64 test_aesdeclast(v2i64 a, v2i64 b)
{
// CHECK: aes_dec_last %r1, %r1, %r2
  return __builtin_postrisc_aesdeclast(a, b);
}

// CHECK-LABEL: @test_aesimc
v2i64 test_aesimc(v2i64 a)
{
// CHECK: aes_imc %r1, %r1
  return __builtin_postrisc_aesimc(a);
}

// CHECK-LABEL: @test_aeskeygenassist
v2i64 test_aeskeygenassist(v2i64 a)
{
// CHECK: aes_keygen_assist %r1, %r1, 100
   v2i64 c = __builtin_postrisc_aeskeygenassist(a, 100);

// CHECK: aes_keygen_assist %r1, %r1, -1
   c = __builtin_postrisc_aeskeygenassist(c, 255);
   return c;
}
