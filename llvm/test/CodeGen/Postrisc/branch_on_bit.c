// RUN: clang %cflags %s | FileCheck %s --check-prefixes=CHECK
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_bit_1
void test_bit_1(i64 a, i64 b)
{
  // CHECK: bbc %r1, %r2, .LBB0_1
  if (a & (1LL << b))
    goto skip;
  printf("XXX b-bit set %lld %lld\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_2
void test_bit_2(i64 a, i64 b)
{
  // CHECK: bbc %r1, %r2, .LBB1_2
  if ((a & (1LL << b)) == 0LL)
    goto skip;
  printf("yy b-bit set %lld %lld\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_3
void test_bit_3(i64 a, i64 b)
{
  // FIXME:
  // CHECK: bbc %r1, %r2, .LBB2_1
  if (((a >> b) & 1LL))
    goto skip;
  printf("zzz b-bit set %lld %lld\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_4
void test_bit_4(i64 a, i64 b)
{
  // CHECK: bbci %r1, 15, .LBB3_2
  if ((((a >> 15) & 1LL)) == 0)
    goto skip;
  printf("eee b-bit set %lld %lld\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_5
void test_bit_5(i64 a, i64 b)
{
  // CHECK: bbsi %r1, 14, .LBB4_2
  if ((((a >> 14) & 1LL)) == 1)
    goto skip;
  printf("qqq b-bit set %lld %lld\n", a, b);
skip:
  ;
}

//////////////////////////////////////////////////////////////////
// test bit 32 bit
//////////////////////////////////////////////////////////////////

// CHECK-LABEL: @test_bit_i32_1
void test_bit_i32_1(i32 a, i32 b)
{
  // CHECK: bbc %r1, %r2, .LBB5_1
  if (a & (1 << b))
    goto skip;
  printf("XXX b-bit set %d %d\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_i32_2
void test_bit_i32_2(i32 a, i32 b)
{
  // CHECK: bbc %r1, %r2, .LBB6_2
  if ((a & (1 << b)) == 0)
    goto skip;
  printf("yy b-bit set %d %d\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_i32_3
void test_bit_i32_3(i32 a, i32 b)
{
  // FIXME:
  // CHECK: bbc %r1, %r2, .LBB7_1
  if (((a >> b) & 1))
    goto skip;
  printf("zzz b-bit set %d %d\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_i32_4
void test_bit_i32_4(i32 a, i32 b)
{
  // CHECK: bbci %r1, 15, .LBB8_2
  if ((((a >> 15) & 1)) == 0)
    goto skip;
  printf("eee b-bit set %d %d\n", a, b);
skip:
  ;
}

// CHECK-LABEL: @test_bit_i32_5
void test_bit_i32_5(i32 a, i32 b)
{
  // CHECK: bbsi %r1, 14, .LBB9_2
  if ((((a >> 14) & 1)) == 1)
    goto skip;
  printf("qqq b-bit set %d %d\n", a, b);
skip:
  ;
}
