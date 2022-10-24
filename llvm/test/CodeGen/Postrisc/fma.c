// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_fma_f32
f32 test_fma_f32(f32 a, f32 b, f32 c)
{
// CHECK: fmaddss %r1, %r1, %r2, %r3
   f32 x = __builtin_fmaf(a,b,c);
   return x;
}

// CHECK-LABEL: @test_fma_f64
f64 test_fma_f64(f64 a, f64 b, f64 c)
{
// CHECK: fmaddsd %r1, %r1, %r2, %r3
   f64 x = __builtin_fma(a,b,c);
   return x;
}

// CHECK-LABEL: @test_fma_f128
f128 test_fma_f128(f128 a, f128 b, f128 c)
{
// CHECK: fmaddsq %r3, %r1, %r2, %r3
   f128 x = __builtin_fmal(a,b,c);
// CHECK: fnmaddsq %r3, %r1, %r2, %r3
   x = __builtin_fmal(-a,b,x);
// CHECK: fmsubsq %r2, %r1, %r2, %r3
   x = __builtin_fmal(a,b,-x);
// CHECK: fnmsubsq %r1, %r1, %r2, %r2
   x = __builtin_fmal(-a,x,-x);
   return x;
}

#if 0
// CDHECK-LABEL: @test_fma_v4f32
v4f32 test_fma_v4f32(v4f32 a, v4f32 b, v4f32 c)
{
  // CFHECK: fmaddps %r3, %r1, %r2, %r3
  v4f32 x = __builtin_postrisc_fma_ps(a,b,c);
  // CDHECK: fnmaddps %r3, %r1, %r2, %r3
  x = __builtin_postrisc_fma_ps(-a,b,x);
  // CDHECK: fmsubps %r2, %r1, %r2, %r3
  x = __builtin_postrisc_fma_ps(a,b,-x);
  // CDHECK: fnmsubps %r1, %r1, %r2, %r2
  x = __builtin_postrisc_fma_ps(-a,x,-x);
  return x;
}

// CDHECK-LABEL: @test_fma_v2f64
v2f64 test_fma_v2f64(v2f64 a, v2f64 b, v2f64 c)
{
  // CFHECK: fmaddpd %r3, %r1, %r2, %r3
  // v2f64 x = __builtin_postrisc_fma_pd(a,b,c);
  // CDHECK: fnmaddpd %r3, %r1, %r2, %r3
  x = __builtin_postrisc_fma_pd(-a,b,x);
  // CDHECK: fmsubpd %r2, %r1, %r2, %r3
  x = __builtin_postrisc_fma_pd(a,b,-x);
  // CDHECK: fnmsubpd %r1, %r1, %r2, %r2
  x = __builtin_postrisc_fma_pd(-a,x,-x);
  return x;
}
#endif
