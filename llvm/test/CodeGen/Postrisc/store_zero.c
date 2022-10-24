// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

static i8 i8_zero;
static u8 u8_zero;
static i16 i16_zero;
static u16 u16_zero;
static i32 i32_zero;
static u32 u32_zero;
static i64 i64_zero;
static u64 u64_zero;
static i128 i128_zero;
static u128 u128_zero;

// make static alive
u64 dummy_return(void) {
   ++i8_zero;
   ++u8_zero;
   ++i16_zero;
   ++u16_zero;
   ++i32_zero;
   ++u32_zero;
   ++i64_zero;
   ++u64_zero;
   i128_zero ^= 1;
   u128_zero ^= 1;
   return i8_zero + u8_zero + i16_zero + u16_zero + i32_zero + u32_zero + i64_zero + u64_zero ^ i128_zero ^ u128_zero;
}

// CHECK-LABEL: @test_store_based_i8_zero
void test_store_based_i8_zero(i8 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: stb %gz, %r1, 4000
  ptr[4000] = 0;
  // CHECK: stbr %gz, %pcfwd(i8_zero)
  i8_zero = 0;
  // CHECK: stbx %gz, %r1, %r2, 0, 10
  ptr[ind64+10] = 0;
  // CHECK: stbx.ws %gz, %r1, %r3, 0, 10
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_u8_zero
void test_store_based_u8_zero(u8 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: stb %gz, %r1, 4000
  ptr[4000] = 0;
  // CHECK: stbr %gz, %pcfwd(u8_zero)
  u8_zero = 0;
  // CHECK: stbx %gz, %r1, %r2, 0, 10
  ptr[ind64+10] = 0;
  // CHECK: stbx.ws %gz, %r1, %r3, 0, 10
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_i16_zero
void test_store_based_i16_zero(i16 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: sth %gz, %r1, 8000
  ptr[4000] = 0;
  // CHECK: sthr %gz, %pcfwd(i16_zero)
  i16_zero = 0;
  // CHECK: sthx %gz, %r1, %r2, 1, 20
  ptr[ind64+10] = 0;
  // CHECK: sthx.ws %gz, %r1, %r3, 1, 20
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_u16_zero
void test_store_based_u16_zero(u16 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: sth %gz, %r1, 8000
  ptr[4000] = 0;
  // CHECK: sthr %gz, %pcfwd(u16_zero)
  u16_zero = 0;
  // CHECK: sthx %gz, %r1, %r2, 1, 20
  ptr[ind64+10] = 0;
  // CHECK: sthx.ws %gz, %r1, %r3, 1, 20
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_i32_zero
void test_store_based_i32_zero(i32 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: stw %gz, %r1, 16000
  ptr[4000] = 0;
  // CHECK: stwr %gz, %pcfwd(i32_zero)
  i32_zero = 0;
  // CHECK: stwx %gz, %r1, %r2, 2, 40
  ptr[ind64+10] = 0;
  // CHECK: stwx.ws %gz, %r1, %r3, 2, 40
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_u32_zero
void test_store_based_u32_zero(u32 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: stw %gz, %r1, 16000
  ptr[4000] = 0;
  // CHECK: stwr %gz, %pcfwd(u32_zero)
  u32_zero = 0;
  // CHECK: stwx %gz, %r1, %r2, 2, 40
  ptr[ind64+10] = 0;
  // CHECK: stwx.ws %gz, %r1, %r3, 2, 40
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_i64_zero
void test_store_based_i64_zero(i64 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: std %gz, %r1, 32000
  ptr[4000] = 0;
  // CHECK: stdr %gz, %pcfwd(i64_zero)
  i64_zero = 0;
  // CHECK: stdx %gz, %r1, %r2, 3, 80
  ptr[ind64+10] = 0;
  // CHECK: stdx.ws %gz, %r1, %r3, 3, 80
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_u64_zero
void test_store_based_u64_zero(u64 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: std %gz, %r1, 32000
  ptr[4000] = 0;
  // CHECK: stdr %gz, %pcfwd(u64_zero)
  u64_zero = 0;
  // CHECK: stdx %gz, %r1, %r2, 3, 80
  ptr[ind64+10] = 0;
  // CHECK: stdx.ws %gz, %r1, %r3, 3, 80
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_i128_zero
void test_store_based_i128_zero(i128 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: stq %gz, %r1, 64000
  ptr[4000] = 0;
  // CHECK: stqr %gz, %pcfwd(i128_zero)
  i128_zero = 0;
  // CHECK: stqx %gz, %r1, %r2, 4, 160
  ptr[ind64+10] = 0;
  // CHECK: stqx.ws %gz, %r1, %r3, 4, 160
  ptr[ind32+10] = 0;
}

// CHECK-LABEL: @test_store_based_u128_zero
void test_store_based_u128_zero(u128 *ptr, i64 ind64, i32 ind32, u32 ind32u)
{
  // CHECK: stq %gz, %r1, 64000
  ptr[4000] = 0;
  // CHECK: stqr %gz, %pcfwd(u128_zero)
  u128_zero = 0;
  // CHECK: stqx %gz, %r1, %r2, 4, 160
  ptr[ind64+10] = 0;
  // CHECK: stqx.ws %gz, %r1, %r3, 4, 160
  ptr[ind32+10] = 0;
}
