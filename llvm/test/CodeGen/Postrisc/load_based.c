// RUN: clang %cflags %s | FileCheck %s
// REQUIRES: postrisc-registered-target

#include "common.h"

// CHECK-LABEL: @test_load_based_u32
u32 test_load_based_u32(u32* ptr)
{
  // CHECK: ldz.w %r1, %r1, 16000
  return ptr[4000];
}

// CHECK-LABEL: @test_load_based_u16
u16 test_load_based_u16(u16* ptr)
{
  // CHECK: ldz.h %r1, %r1, 8000
  return ptr[4000];
}

// CHECK-LABEL: @test_load_based_u8
u8 test_load_based_u8(u8* ptr)
{
  // CHECK: ldz.b %r1, %r1, 4000
  return ptr[4000];
}

// CHECK-LABEL: @test_load_based_i32
i32 test_load_based_i32(i32* ptr)
{
  // FIXME:
  // CHECK: ldz.w %r1, %r1, 16000
  return ptr[4000];
}

// CHECK-LABEL: @test_load_based_i16
i16 test_load_based_i16(i16* ptr)
{
  // CHECK: lds.h %r1, %r1, 8000
  return ptr[4000];
}

// CHECK-LABEL: @test_load_based_i8
i8 test_load_based_i8(i8* ptr)
{
  // CHECK: lds.b %r1, %r1, 4000
  return ptr[4000];
}

