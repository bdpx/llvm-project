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
