// RUN: clang %cflags -Xclang -fnative-half-type %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target
// -fexperimental-strict-floating-point

#include "common.h"

#if !__has_builtin(__builtin_fmaf16)
  #error "there is no __builtin_fmaf16"
#endif

#if __has_constexpr_builtin(__builtin_fmaf16)
  #warning "has constexpr __builtin_fmaf16"
#else
  #warning "has NO constexpr __builtin_fmaf16"
#endif

// FIXME: __builtin_fmaf16
// CHECK-LABEL: @test_fma_f16
f16 test_fma_f16(f16 a, f16 b, f16 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: madd_f16 %r3, %r1, %r2, %r3
  f16 x = __builtin_fmaf16(a, b, c);
  // CHECK-NEXT: nmadd_f16 %r3, %r1, %r2, %r3
  x = __builtin_fmaf16(-a, b, x);
  // CHECK: msub_f16 %r2, %r1, %r2, %r3
  x = __builtin_fmaf16(a, b, -x);
  // CHECK-NEXT: nmsub_f16 %r1, %r1, %r2, %r2
  x = __builtin_fmaf16(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_f32
f32 test_fma_f32(f32 a, f32 b, f32 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: madd_f32 %r3, %r1, %r2, %r3
  f32 x = __builtin_fmaf(a, b, c);
  // CHECK-NEXT: nmadd_f32 %r3, %r1, %r2, %r3
  x = __builtin_fmaf(-a, b, x);
  // CHECK: msub_f32 %r2, %r1, %r2, %r3
  x = __builtin_fmaf(a, b, -x);
  // CHECK-NEXT: nmsub_f32 %r1, %r1, %r2, %r2
  x = __builtin_fmaf(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_f64
f64 test_fma_f64(f64 a, f64 b, f64 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: madd_f64 %r3, %r1, %r2, %r3
  f64 x = __builtin_fma(a, b, c);
  // CHECK-NEXT: nmadd_f64 %r3, %r1, %r2, %r3
  x = __builtin_fma(-a, b, x);
  // CHECK: msub_f64 %r2, %r1, %r2, %r3
  x = __builtin_fma(a, b, -x);
  // CHECK-NEXT: nmsub_f64 %r1, %r1, %r2, %r2
  x = __builtin_fma(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_f128
f128 test_fma_f128(f128 a, f128 b, f128 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: madd_f128 %r3, %r1, %r2, %r3
  f128 x = __builtin_fmal(a, b, c);
  // CHECK-NEXT: nmadd_f128 %r3, %r1, %r2, %r3
  x = __builtin_fmal(-a, b, x);
  // CHECK: msub_f128 %r2, %r1, %r2, %r3
  x = __builtin_fmal(a, b, -x);
  // CHECK-NEXT: nmsub_f128 %r1, %r1, %r2, %r2
  x = __builtin_fmal(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_v8f16
v8f16 test_fma_v8f16(v8f16 a, v8f16 b, v8f16 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: madd_vf16 %r3, %r1, %r2, %r3
  v8f16 x = __builtin_postrisc_madd_vf16(a, b, c);
  // CHECK-NEXT: nmadd_vf16 %r3, %r1, %r2, %r3
  x = __builtin_postrisc_madd_vf16(-a, b, x);
  // CHECK: msub_vf16 %r2, %r1, %r2, %r3
  x = __builtin_postrisc_madd_vf16(a, b, -x);
  // CHECK-NEXT: nmsub_vf16 %r1, %r1, %r2, %r2
  x = __builtin_postrisc_madd_vf16(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_v4f32
v4f32 test_fma_v4f32(v4f32 a, v4f32 b, v4f32 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: madd_vf32 %r3, %r1, %r2, %r3
  v4f32 x = __builtin_postrisc_madd_vf32(a, b, c);
  // CHECK-NEXT: nmadd_vf32 %r3, %r1, %r2, %r3
  x = __builtin_postrisc_madd_vf32(-a, b, x);
  // CHECK: msub_vf32 %r2, %r1, %r2, %r3
  x = __builtin_postrisc_madd_vf32(a, b, -x);
  // CHECK-NEXT: nmsub_vf32 %r1, %r1, %r2, %r2
  x = __builtin_postrisc_madd_vf32(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}

// CHECK-LABEL: @test_fma_v2f64
v2f64 test_fma_v2f64(v2f64 a, v2f64 b, v2f64 c)
{
  // CHECK: alloc 4
  // CHECK-NEXT: madd_vf64 %r3, %r1, %r2, %r3
  v2f64 x = __builtin_postrisc_madd_vf64(a, b, c);
  // CHECK-NEXT: nmadd_vf64 %r3, %r1, %r2, %r3
  x = __builtin_postrisc_madd_vf64(-a, b, x);
  // CHECK: msub_vf64 %r2, %r1, %r2, %r3
  x = __builtin_postrisc_madd_vf64(a, b, -x);
  // CHECK-NEXT: nmsub_vf64 %r1, %r1, %r2, %r2
  x = __builtin_postrisc_madd_vf64(-a, x, -x);
  // CHECK-NEXT: retf 0
  return x;
}
