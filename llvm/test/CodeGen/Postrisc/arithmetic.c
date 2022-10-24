// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

//  -cc1 -triple postrisc -target-cpu pv1 -S -w -o -

#include "common.h"

i32 test_ldi32(void)
{
   i32 a = 12345778;
   return a;
}

i32 test_ldi32_long(void)
{
   i32 a = 987654321;
   return a;
}

i64 test_ldi64(void)
{
   i64 a = 12345778ull;
   return a;
}

i64 test_ldi64_long(void)
{
   i64 a = 987654321123456789ull;
   return a;
}

// CHECK-LABEL: @test_subfi_i32
i64 test_subfi_i32(i64 a)
{
  return 1234 - a;
}

i32 test_subfi_i64(i32 a)
{
  return 1234 - a;
}

i64 test_addil(i64 a)
{
   i64 b = 9200848539817279407ull;
   a += 123456789123456789ull;
   a |= b;
   return a;
}

i64 test_andil(i64 a)
{
   a &= 123456789123456789ull;
   return a;
}

i64 test_oril(i64 a)
{
   a |= 987654321123456789ull;
   return a;
}

i64 test_addadd(i64 a, i64 b, i64 c)
{
   return a + b + c;
}

i64 test_addsub(i64 a, i64 b, i64 c)
{
   return a + b - c;
}

i64 test_subsub(i64 a, i64 b, i64 c)
{
   return a - b - c;
}


// CHECK-LABEL: @test_mul_i32_i32
i32 test_mul_i32_i32(i32 a, i32 b)
{
  // CHECK: mulws %r1, %r2, %r1
  return a * b;
  // retf 0
}

// CHECK-LABEL: @test_mul_i32_imm
i32 test_mul_i32_imm(i32 a)
{
  // CHECK: mulwsi %r1, %r1, 98765
  return a * 98765;
}

// CHECK-LABEL: @test_mul_i32_imm_ext
i32 test_mul_i32_imm_ext(i32 a)
{
  // CHECK: mulwsi.l %r1, %r1, 98765432
  return a * 98765432;
}

// CHECK-LABEL: @test_mul_u32_imm
u32 test_mul_u32_imm(u32 a)
{
  // FIXME: mulwzi?
  // CHECK: mulwsi %r1, %r1, 98765
  return a * 98765U;
}

// CHECK-LABEL: @test_mul_u32_imm_ext
u32 test_mul_u32_imm_ext(u32 a)
{
  // FIXME: mulwzi.l?
  // CHECK: mulwsi.l %r1, %r1, 98765432
  return a * 98765432U;
}

// CHECK-LABEL: @test_mul_i32_i64
i64 test_mul_i32_i64(i32 a, i32 b)
{
  // CHECK: mulws %r1, %r2, %r1
  return a * b;
  // retf 0
}

// CHECK-LABEL: @test_mul_u32_u64
u64 test_mul_u32_u64(u32 a, u32 b)
{
  // CHECK: mulwz %r1, %r2, %r1
  return a * b;
  // retf 0
}

// CHECK-LABEL: @test_mul_i32_u64
u64 test_mul_i32_u64(i32 a, i32 b)
{
  // FIXME: mulwz?
  // CHECK: mulws %r1, %r2, %r1
  return a * b;
  // retf 0
}

// CHECK-LABEL: @test_mul_i32_i64_imm
i64 test_mul_i32_i64_imm(i32 a)
{
  // CHECK: mulwsi %r1, %r1, 98765
  return a * 98765;
}

// CHECK-LABEL: @test_mul_i32_i64_imm_ext
i64 test_mul_i32_i64_imm_ext(i32 a)
{
  // CHECK: mulwsi.l %r1, %r1, 98765432
  return a * 98765432;
}

// CHECK-LABEL: @test_mul_u32_u64_imm
u64 test_mul_u32_u64_imm(u32 a)
{
  // CHECK: mulwzi %r1, %r1, 98765
  return a * 98765U;
}

// CHECK-LABEL: @test_mul_u32_u64_imm_ext
u64 test_mul_u32_u64_imm_ext(u32 a)
{
  // CHECK: mulwzi.l %r1, %r1, 98765432
  return a * 98765432U;
}


// CHECK-LABEL: @test_mul_i64_i64
i64 test_mul_i64_i64(i64 a, i64 b)
{
  // CHECK: mul %r1, %r2, %r1
  return a * b;
  // retf 0
}
