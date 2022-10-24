// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

static f16 f16_zero;
static f32 f32_zero;
static f64 f64_zero;
static f128 f128_zero;

// make static alive
f64 fp_store_zero_dummy_return(void) {
   ++f16_zero;
   ++f32_zero;
   ++f64_zero;
   ++f128_zero;
   return f16_zero + f32_zero + f64_zero + f128_zero;
}

// CHECK-LABEL: @test_store_based_f16_zero
void test_store_based_f16_zero(f16 *ptr, i64 ind64, i32 ind32)
{
  // CHECK: st.h %gz, %r1, 8000
  ptr[4000] = 0.0;
  // CHECK: st.h.r %gz, %pcfwd(f16_zero)
  f16_zero = 0.0;
  // CHECK: st.h.xd %gz, %r1, %r2, 1, 20
  ptr[ind64+10] = 0.0;
  // CHECK: st.h.xw %gz, %r1, %r3, 1, 20
  ptr[ind32+10] = 0.0;
}

// CHECK-LABEL: @test_store_based_f32_zero
void test_store_based_f32_zero(f32 *ptr, i64 ind64, i32 ind32)
{
  // CHECK: st.w %gz, %r1, 16000
  ptr[4000] = 0.0;
  // CHECK: st.w.r %gz, %pcfwd(f32_zero)
  f32_zero = 0.0;
  // CHECK: st.w.xd %gz, %r1, %r2, 2, 40
  ptr[ind64+10] = 0.0;
  // CHECK: st.w.xw %gz, %r1, %r3, 2, 40
  ptr[ind32+10] = 0.0;
}

// CHECK-LABEL: @test_store_based_f64_zero
void test_store_based_f64_zero(f64 *ptr, i64 ind64, i32 ind32)
{
  // CHECK: st.d %gz, %r1, 32000
  ptr[4000] = 0.0;
  // CHECK: st.d.r %gz, %pcfwd(f64_zero)
  f64_zero = 0.0;
  // CHECK: st.d.xd %gz, %r1, %r2, 3, 40
  ptr[ind64+5] = 0.0;
  // CHECK: st.d.xw %gz, %r1, %r3, 3, 40
  ptr[ind32+5] = 0.0;
}

// CHECK-LABEL: @test_store_based_f128_zero
void test_store_based_f128_zero(f128 *ptr, i64 ind64, i32 ind32)
{
  // CHECK: st.q %gz, %r1, 64000
  ptr[4000] = 0.0;
  // CHECK: st.q.r %gz, %pcfwd(f128_zero)
  f128_zero = 0.0;
  // CHECK: st.q.xd %gz, %r1, %r2, 4, 48
  ptr[ind64+3] = 0.0;
  // CHECK: st.q.xw %gz, %r1, %r3, 4, 48
  ptr[ind32+3] = 0.0;
}
