// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_fma_f32
f32 test_fma_f32(f32 a, f32 b, f32 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: fmaddss %r3, %r1, %r2, %r3
  f128 x = __builtin_fmaf(a, b, c);
  // CHECK-NEXT: fnmaddss %r3, %r1, %r2, %r3
  x = __builtin_fmaf(-a, b, x);
  // CHECK: fmsubss %r2, %r1, %r2, %r3
  x = __builtin_fmaf(a, b, -x);
  // CHECK-NEXT: fnmsubss %r1, %r1, %r2, %r2
  x = __builtin_fmaf(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_f64
f64 test_fma_f64(f64 a, f64 b, f64 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: fmaddsd %r3, %r1, %r2, %r3
  f128 x = __builtin_fma(a, b, c);
  // CHECK-NEXT: fnmaddsd %r3, %r1, %r2, %r3
  x = __builtin_fma(-a, b, x);
  // CHECK: fmsubsd %r2, %r1, %r2, %r3
  x = __builtin_fma(a, b, -x);
  // CHECK-NEXT: fnmsubsd %r1, %r1, %r2, %r2
  x = __builtin_fma(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_f128
f128 test_fma_f128(f128 a, f128 b, f128 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: fmaddsq %r3, %r1, %r2, %r3
  f128 x = __builtin_fmal(a, b, c);
  // CHECK-NEXT: fnmaddsq %r3, %r1, %r2, %r3
  x = __builtin_fmal(-a, b, x);
  // CHECK: fmsubsq %r2, %r1, %r2, %r3
  x = __builtin_fmal(a, b, -x);
  // CHECK-NEXT: fnmsubsq %r1, %r1, %r2, %r2
  x = __builtin_fmal(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_v8f16
v8f16 test_fma_v8f16(v8f16 a, v8f16 b, v8f16 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: fmaddph %r3, %r1, %r2, %r3
  v8f16 x = __builtin_postrisc_fma_ph(a, b, c);
  // CHECK-NEXT: fnmaddph %r3, %r1, %r2, %r3
  x = __builtin_postrisc_fma_ph(-a, b, x);
  // CHECK: fmsubph %r2, %r1, %r2, %r3
  x = __builtin_postrisc_fma_ph(a, b, -x);
  // CHECK-NEXT: fnmsubph %r1, %r1, %r2, %r2
  x = __builtin_postrisc_fma_ph(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_v4f32
v4f32 test_fma_v4f32(v4f32 a, v4f32 b, v4f32 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: fmaddps %r3, %r1, %r2, %r3
  v4f32 x = __builtin_postrisc_fma_ps(a, b, c);
  // CHECK-NEXT: fnmaddps %r3, %r1, %r2, %r3
  x = __builtin_postrisc_fma_ps(-a, b, x);
  // CHECK: fmsubps %r2, %r1, %r2, %r3
  x = __builtin_postrisc_fma_ps(a, b, -x);
  // CHECK-NEXT: fnmsubps %r1, %r1, %r2, %r2
  x = __builtin_postrisc_fma_ps(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_v2f64
v2f64 test_fma_v2f64(v2f64 a, v2f64 b, v2f64 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: fmaddpd %r3, %r1, %r2, %r3
  v2f64 x = __builtin_postrisc_fma_pd(a, b, c);
  // CHECK-NEXT: fnmaddpd %r3, %r1, %r2, %r3
  x = __builtin_postrisc_fma_pd(-a, b, x);
  // CHECK: fmsubpd %r2, %r1, %r2, %r3
  x = __builtin_postrisc_fma_pd(a, b, -x);
  // CHECK-NEXT: fnmsubpd %r1, %r1, %r2, %r2
  x = __builtin_postrisc_fma_pd(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}
