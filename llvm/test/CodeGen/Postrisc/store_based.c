// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_store_based_u32
void test_store_based_u32(u32* ptr, u32 value)
{
  // CHECK: st.w %r2, %r1, 16000
  ptr[4000] = value;
}

// CHECK-LABEL: @test_store_based_u16
void test_store_based_u16(u16* ptr, u16 value)
{
  // CHECK: st.h %r2, %r1, 8000
  ptr[4000] = value;
}

// CHECK-LABEL: @test_store_based_u8
void test_store_based_u8(u8* ptr, u8 value)
{
  // CHECK: st.b %r2, %r1, 4000
  ptr[4000] = value;
}

// CHECK-LABEL: @test_store_based_i32
void test_store_based_i32(i32* ptr, i32 value)
{
  // CHECK: st.w %r2, %r1, 16000
  ptr[4000] = value;
}

// CHECK-LABEL: @test_store_based_i16
void test_store_based_i16(i16* ptr, i16 value)
{
  // CHECK: st.h %r2, %r1, 8000
  ptr[4000] = value;
}

// CHECK-LABEL: @test_store_based_i8
void test_store_based_i8(i8* ptr, i8 value)
{
  // CHECK: st.b %r2, %r1, 4000
  ptr[4000] = value;
}

