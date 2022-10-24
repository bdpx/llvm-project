// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_i128_load_store
f128 test_i128_load_store(f128 *p)
{
  f128 temp = p[1];
  p[0] = temp;
  return p[3];
}

extern void test_builtin_va_consume_i32(const char *str, int x);
extern void test_builtin_va_consume_f64(double x);
extern void test_builtin_va_consume_f128(f128 x);

// CHECK-LABEL: @test_builtin_va
i32 test_builtin_va(const char *str/*r1*/, .../*r2, r3, r4*/)
{
  __builtin_va_list a;
  __builtin_va_start(a,str);

  i32 x = __builtin_va_arg(a, i32);
  test_builtin_va_consume_i32(str, x);

  f64 y = __builtin_va_arg(a, f64);
  test_builtin_va_consume_f64(y);

  f128 z = __builtin_va_arg(a, f128);
  test_builtin_va_consume_f128(z);
  __builtin_va_end(a);
  return x;
}

// CHECK-LABEL: @test_test_builtin_va
i32 test_test_builtin_va(i32 x, f64 y, f128 z)
{
  // CHECK: call %r4, %jpc(test_builtin_va)
  return test_builtin_va("test", x, y, z, x, y, z, x, y, z, x, y, z, x, y, z, x, y, z, x, y, z, x, y, x, z);
}
